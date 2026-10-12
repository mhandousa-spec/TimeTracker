/// Module: services_management_module
/// Description: `selectServiceProviderApproval` — workload-balanced provider
///              selection for the approval flow (part of csv_helper.dart).
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: cloud_firestore, core/network/get_base_url.dart (via csv_helper.dart)
/// Revision History: Initial version — auto-split from csv_helper.dart to keep
///                    each physical file ≤800 LOC (audit fix #1).
// Auto-split from csv_helper.dart — part of the same library.
part of 'csv_helper.dart';

Future<Map<String, dynamic>?> selectServiceProviderApproval(
    String currentServiceDocId, {
      int lookbackDays = 7,
      bool rotateWithinSameParent = false,
      bool respectExistingAssignment = true,
    }) async
{
  if (kDebugMode) print('');
  if (kDebugMode) print('🎯 ========== selectServiceProviderApproval CALLED ==========');
  if (kDebugMode) print('🎯 Request ID: $currentServiceDocId');
  if (kDebugMode) print('🎯 Parameters:');
  if (kDebugMode) print('   - lookbackDays: $lookbackDays');
  if (kDebugMode) print('   - rotateWithinSameParent: $rotateWithinSameParent');
  if (kDebugMode) print('   - respectExistingAssignment: $respectExistingAssignment');
  if (kDebugMode) print('🎯 =========================================================');
  if (kDebugMode) print('');

  final firestore = FirebaseFirestore.instance;
  final String tenantRoot = getBaseUrl(FirestoreCollections.requestServicesRoot);
  final now = DateTime.now();
  final cutoff = now.subtract(Duration(days: lookbackDays));

  String _s(dynamic v) => v?.toString() ?? '';

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  double _minutesFromModel(ServicesHistoryModel model) {
    final value = _toDouble(model.currentDurationOfServices);
    final unit = _s(model.currentSelectedDurationUnit).toLowerCase();
    switch (unit) {
      case 'minutes': case 'minute': case 'min': case 'm': return value;
      case 'hours':   case 'hour':   case 'h':             return value * 60.0;
      case 'days':    case 'day':    case 'd':             return value * 1440.0;
      case 'weeks':   case 'week':   case 'w':             return value * 10080.0;
      default: return value;
    }
  }

  List<Map<String, dynamic>> _providersFromModel(ServicesHistoryModel model) {
    return model.currentProviderServices.map((e) => e.toJson()).toList();
  }

  DateTime? _timestampFromModel(ServicesHistoryModel model) {
    final t = model.currentDurationOfServicesTimestamp;
    return t?.toDate();
  }

  String _assignedEmailFromModel(ServicesHistoryModel model) {
    final assignedEmail = model.assignedProviderEmail;

    if (assignedEmail == null || assignedEmail.isEmpty) {
      return '';
    }

    final validEmails = assignedEmail
        .where((email) =>
    email != null &&
        email.toString().trim().isNotEmpty)
        .map((email) => email.toString().trim().toLowerCase())
        .toList();

    return validEmails.isEmpty ? '' : validEmails.last;
  }

  String _extractParentServiceId(dynamic rawValue) {
    if (rawValue == null) return '';

    if (rawValue is List && rawValue.isNotEmpty) {
      return rawValue[0]?.toString() ?? '';
    }

    if (rawValue is String) {
      return rawValue;
    }

    return '';
  }

  int _seedFrom(String s) => s.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);

  try {
    // ✅ FIXED: Search directly in requestServices collection, not collectionGroup
    if (kDebugMode) print('📍 Searching in collection: $tenantRoot');
    if (kDebugMode) print('📍 Looking for document: $currentServiceDocId');

    // Get the current service document directly
    final currentDocRef = firestore.collection(tenantRoot).doc(currentServiceDocId);
    final currentDocSnapshot = await currentDocRef.get();

    if (!currentDocSnapshot.exists) {
      if (kDebugMode) print('❌ Document not found at path: ${currentDocRef.path}');
      return null;
    }

    if (kDebugMode) print('✅ Document found!');

    final currentData = currentDocSnapshot.data();
    if (currentData == null) {
      if (kDebugMode) print('❌ Document data is null');
      return null;
    }

    final currentModel = ServicesHistoryModel.fromJson(currentData, currentServiceDocId);

    // Extract current parent
    final currentParentRaw = currentData['parentServiceId'];
    final currentParent = _extractParentServiceId(currentParentRaw);
    if (kDebugMode) print('📋 Parent Service ID: $currentParent');

    var currentProviders = _providersFromModel(currentModel);
    if (kDebugMode) print('📋 Available providers: ${currentProviders.length}');

    if (currentProviders.isEmpty) {
      if (kDebugMode) print('⚠️  No providers for this service');
      return null;
    }

    // Log provider details
    for (var i = 0; i < currentProviders.length; i++) {
      if (kDebugMode) print('   Provider $i: ${currentProviders[i]['email']} - ${currentProviders[i]['firstName']} ${currentProviders[i]['lastName']}');
    }

    // Check existing assignment if respectExistingAssignment is true
    if (respectExistingAssignment) {
      final existingAssigned = _assignedEmailFromModel(currentModel);
      if (kDebugMode) print('🔍 Checking existing assignment: $existingAssigned');

      if (existingAssigned.isNotEmpty) {
        final existingProvider = currentProviders.firstWhere(
              (p) => _s(p['email']).toLowerCase() == existingAssigned,
          orElse: () => currentProviders.first,
        );
        if (kDebugMode) print('✅ Using existing assigned provider: $existingAssigned');
        if (kDebugMode) print('   Provider details: ${existingProvider['firstName']} ${existingProvider['lastName']}');
        return existingProvider;
      } else {
        if (kDebugMode) print('⚠️  No existing assignment found');
      }
    }

    if (currentProviders.length == 1) {
      final only = currentProviders.first;
      final email = _s(only['email']).toLowerCase();
      await currentDocRef.update({'assignedProviderEmail': [email]});
      if (kDebugMode) print('✅ Only one provider, assigned: $email');
      return only;
    }

    // Count workload across ALL requests
    final thisServiceProviderEmails = currentProviders
        .map((p) => _s(p['email']).toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();

    if (kDebugMode) print('📊 Calculating workload for providers: $thisServiceProviderEmails');

    final Map<String, double> emailTotalMinutes = {};
    final Map<String, int>    emailFrequency    = {};
    final Map<String, int>    emailParentFreq   = {};

    // Initialize counters
    for (final email in thisServiceProviderEmails) {
      emailTotalMinutes[email] = 0.0;
      emailFrequency[email] = 0;
      emailParentFreq[email] = 0;
    }

    // ✅ FIXED: Get all documents from requestServices collection
    if (kDebugMode) print('📊 Fetching all requests from: $tenantRoot');
    final allRequestsSnapshot = await firestore.collection(tenantRoot).get();
    if (kDebugMode) print('📊 Found ${allRequestsSnapshot.docs.length} total requests');

    for (final doc in allRequestsSnapshot.docs) {
      try {
        final data = doc.data();
        final model = ServicesHistoryModel.fromJson(data, doc.id);

        final ts = _timestampFromModel(model);
        if (ts != null && ts.isBefore(cutoff)) continue;

        final assignedEmail = _assignedEmailFromModel(model);
        final modelParentId = _extractParentServiceId(data['parentServiceId']);

        // Only count if this provider is in our current service's provider list
        if (assignedEmail.isNotEmpty && thisServiceProviderEmails.contains(assignedEmail)) {
          final minutes = _minutesFromModel(model);
          emailTotalMinutes[assignedEmail] = (emailTotalMinutes[assignedEmail] ?? 0) + minutes;
          emailFrequency[assignedEmail] = (emailFrequency[assignedEmail] ?? 0) + 1;

          if (rotateWithinSameParent && modelParentId == currentParent) {
            emailParentFreq[assignedEmail] = (emailParentFreq[assignedEmail] ?? 0) + 1;
          }
        }
      } catch (e) {
        if (kDebugMode) print('⚠️  Error processing document ${doc.id}: $e');
        continue;
      }
    }

    if (kDebugMode) print('📊 Workload distribution:');
    for (final email in thisServiceProviderEmails) {
      if (kDebugMode) print('  $email: ${emailTotalMinutes[email]?.toStringAsFixed(1)}min, ${emailFrequency[email]} requests');
    }

    // Sort by workload (least busy first)
    currentProviders.sort((a, b) {
      final ea = _s(a['email']).toLowerCase();
      final eb = _s(b['email']).toLowerCase();

      final ma = emailTotalMinutes[ea] ?? 0.0;
      final mb = emailTotalMinutes[eb] ?? 0.0;
      if (ma != mb) return ma.compareTo(mb);

      if (rotateWithinSameParent) {
        final pa = emailParentFreq[ea] ?? 0;
        final pb = emailParentFreq[eb] ?? 0;
        if (pa != pb) return pa.compareTo(pb);
      }

      final fa = emailFrequency[ea] ?? 0;
      final fb = emailFrequency[eb] ?? 0;
      if (fa != fb) return fa.compareTo(fb);

      final seed = _seedFrom(currentServiceDocId);
      int tieHash(String email) => _seedFrom('$seed|$email');
      return tieHash(ea).compareTo(tieHash(eb));
    });

    final chosen = currentProviders.first;
    final chosenEmail = _s(chosen['email']).toLowerCase();

    if (kDebugMode) print('✅ Selected provider: $chosenEmail');
    if (kDebugMode) print('   Provider: ${chosen['firstName']} ${chosen['lastName']}');
    if (kDebugMode) print('   Workload: ${emailTotalMinutes[chosenEmail]?.toStringAsFixed(1)}min, ${emailFrequency[chosenEmail]} requests');

    // Update with clean email
    await currentDocRef.update({'assignedProviderEmail': [chosenEmail]});

    if (kDebugMode) print('🎯 ========== selectServiceProviderApproval SUCCESS ==========');
    if (kDebugMode) print('');

    return chosen;

  } catch (e, stackTrace) {
    if (kDebugMode) print('❌ Error: $e');
    if (kDebugMode) print('❌ Stack: $stackTrace');
    if (kDebugMode) print('🎯 ========== selectServiceProviderApproval FAILED ==========');
    if (kDebugMode) print('');
    return null;
  }
}




