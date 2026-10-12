// Auto-split from csv_helper.dart — part of the same library.
part of 'csv_helper.dart';

Future<Map<String, dynamic>?> selectServiceProviderRequest(
    String currentServiceDocId, {
      int lookbackDays = 7,
      bool rotateWithinSameParent = true,
      int perDayCap = 2,
      bool respectExistingAssignment = true,
      bool allowReassignIfCapExceeded = true,
    })

async {
  final firestore = FirebaseFirestore.instance;
  final userPath = firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .where("Email_Requester",arrayContains: employeeFunctionHelper.email);


  // ---------- helpers ----------
  String _s(dynamic v) => (v ?? '').toString();

  double _toMinutes(num value, String unit) {
    switch (unit.toLowerCase()) {
      case 'minutes':
      case 'minute':
      case 'min':
      case 'm':
        return value.toDouble();
      case 'hours':
      case 'hour':
      case 'h':
        return value * 60.0;
      case 'days':
      case 'day':
      case 'd':
        return value * 1440.0;
      case 'weeks':
      case 'week':
      case 'w':
        return value * 10080.0;
      default:
        return value.toDouble();
    }
  }

  double _minutesFromModel(ServicesHistoryModel model) {
    final valStr = model.currentDurationOfServices;
    final unitStr = model.currentSelectedDurationUnit;
    final numVal = num.tryParse(valStr) ?? 0;
    return _toMinutes(numVal, unitStr);
  }

  List<Map<String, dynamic>> _providersFromModel(ServicesHistoryModel model) {
    return model.currentProviderServices.map((e) => e.toJson()).toList();
  }

  DateTime? _timestampFromModel(ServicesHistoryModel model) {
    final ts = model.currentDurationOfServicesTimestamp;
    return ts.toDate();
  }

  String _assignedEmailFromModel(ServicesHistoryModel model) {
    final assignedEmail = model.assignedProviderEmail;

    if (assignedEmail == null || assignedEmail.isEmpty) {
      return '';
    }

    // Filter out empty/null strings and get last valid email
    final validEmails = assignedEmail
        .where((email) =>
    email != null &&
        email.toString().trim().isNotEmpty &&
        email.toString().trim() != '')
        .map((email) => email.toString().trim().toLowerCase())
        .toList();

    return validEmails.isEmpty ? '' : validEmails.last;
  }

  bool _isActiveStatus(String s) {
    s = s.toLowerCase();
    return s == 'pending' || s == 'approved' || s == 'inprogress' || s == 'done';
  }

  int _seedFrom(String s) => s.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);

  // ✅ UPDATED: Include all Arabic fields that your UI expects
  Map<String, dynamic> _normalizeProvider(Map<String, dynamic> p) {
    return {
      'email'              : _s(p['email']).toLowerCase(),
      'firstName'          : _s(p['firstName']),
      'lastName'           : _s(p['lastName']),
      'firstNameInArabic'  : _s(p['firstNameInArabic']),
      'lastNameInArabic'   : _s(p['lastNameInArabic']),
      'middleName'         : _s(p['middleName']),
      'middleNameInArabic' : _s(p['middleNameInArabic']),
      'title'              : _s(p['title']),
      'titleInArabic'      : _s(p['titleInArabic']),
      'gender'             : _s(p['gender']),
      'photo'              : _s(p['photo']),
      'department'         : _s(p['department']),
      'departmentId'       : p['departmentId'],
      'workLocation'       : _s(p['workLocation']),
      'role'               : _s(p['role']),
      'status'             : _s(p['status']),
      'supervisor'         : _s(p['supervisor']),
      'mobilePhone'        : _s((p['mobilePhone'] is Map) ? p['mobilePhone']['phone'] : p['mobilePhone']),
      'mobileCountryCode'  : _s((p['mobilePhone'] is Map) ? p['mobilePhone']['countryCode'] : ''),
      'id'                 : p['id'],
      'officePhone'        : p['officePhone'],
      'homePhone'          : p['homePhone'],
      'extension'          : p['extension'],
      'nationality'        : _s(p['nationality']),
      'language'           : _s(p['language']),
      'skills'             : p['skills'],
      'bio'                : _s(p['bio']),
      'hobbies'            : p['hobbies'],
      'academicHistory'    : p['academicHistory'],
      'maritalStatus'      : _s(p['maritalStatus']),
      'birthDay'           : p['birthDay'],
      'nationalId'         : _s(p['nationalId']),
      'passport'           : _s(p['passport']),
      'drivingLicenseId'   : _s(p['drivingLicenseId']),
      'imageUrl'           : _s(p['imageUrl']),
      'country'            : _s(p['country']),
      'state'              : _s(p['state']),
      'city'               : _s(p['city']),
      'province'           : _s(p['province']),
      'street'             : _s(p['street']),
      'postalCode'         : _s(p['postalCode']),
      'carPlates'          : p['carPlates'],
      'activationDate'     : p['activationDate'],
      'deactivationDate'   : p['deactivationDate'],
      'firstLogin'         : p['firstLogin'],
      'lastLogin'          : p['lastLogin'],
      'nationalIdExpirationDate': p['nationalIdExpirationDate'],
      'passportExpirationDate': p['passportExpirationDate'],
    };
  }

  final now = DateTime.now();
  final cutoff = now.subtract(Duration(days: lookbackDays));
  final startToday = DateTime(now.year, now.month, now.day);
  final endToday = startToday.add(const Duration(days: 1));

  // ---------- accumulators ----------
  final Map<String, double> emailTotalDuration = {};
  final Map<String, int>    emailFrequency     = {};
  final Map<String, int>    emailParentFreq    = {};
  final Map<String, int>    emailTodayCount    = {};

  // 1) Load all requests under this requester scope
  final servicesSnapshot = await userPath.get();

  // locate current doc
  DocumentSnapshot<Map<String, dynamic>>? currentDocSnap;
  ServicesHistoryModel? currentModel;

  for (final doc in servicesSnapshot.docs) {
    if (doc.id == currentServiceDocId) {
      currentDocSnap = doc;
      currentModel = ServicesHistoryModel.fromJson(doc.data()!, doc.id);
      break;
    }
  }

  if (currentDocSnap == null || !currentDocSnap.exists || currentModel == null) return null;

  // scan for load stats
  for (final serviceDoc in servicesSnapshot.docs) {
    final data = serviceDoc.data();
    if (data == null) continue;

    final model = ServicesHistoryModel.fromJson(data, serviceDoc.id);

    // only consider active statuses inside lookback
    final ts = _timestampFromModel(model);
    if (ts == null || ts.isBefore(cutoff)) continue;

    final state = model.currentState;
    if (!_isActiveStatus(state)) continue;

    // providers who were candidates for this service
    final durationInMin = _minutesFromModel(model);
    final providers = _providersFromModel(model);

    for (final p in providers) {
      final email = _s(p['email']).toLowerCase();
      if (email.isEmpty) continue;
      emailTotalDuration[email] = (emailTotalDuration[email] ?? 0) + durationInMin;
      emailFrequency[email]     = (emailFrequency[email]     ?? 0) + 1;
    }

    // track daily assignments for perDayCap
    final assignedEmail = _assignedEmailFromModel(model);
    if (assignedEmail.isNotEmpty && !ts.isBefore(startToday) && ts.isBefore(endToday)) {
      emailTodayCount[assignedEmail] = (emailTodayCount[assignedEmail] ?? 0) + 1;
    }
  }

  final currentParentId = currentModel.currentParentServiceId;
  final currentProvidersRaw = _providersFromModel(currentModel);
  if (currentProvidersRaw.isEmpty) return null;

  // 2) Optional: penalize same-parent recent assignees
  if (rotateWithinSameParent && currentParentId.isNotEmpty) {
    for (final serviceDoc in servicesSnapshot.docs) {
      final data = serviceDoc.data();
      if (data == null) continue;

      final model = ServicesHistoryModel.fromJson(data, serviceDoc.id);

      if (model.currentParentServiceId != currentParentId) continue;

      final ts = _timestampFromModel(model);
      if (ts == null || ts.isBefore(cutoff)) continue;

      final assignedEmail = _assignedEmailFromModel(model);
      if (assignedEmail.isEmpty) continue;

      emailParentFreq[assignedEmail] = (emailParentFreq[assignedEmail] ?? 0) + 1;
    }
  }

  // ---------- if already assigned & we respect it, return that provider ----------
  final existingAssigned = _assignedEmailFromModel(currentModel);
  if (respectExistingAssignment && existingAssigned.isNotEmpty) {
    final found = currentProvidersRaw.firstWhere(
          (p) => _s(p['email']).toLowerCase() == existingAssigned,
      orElse: () => const {},
    );
    if (found.isNotEmpty) {
      return _normalizeProvider(found);
    }
  }

  // 3) Apply daily cap filter if enabled
  List<Map<String, dynamic>> pool;
  if (perDayCap > 0) {
    final filtered = currentProvidersRaw.where((p) {
      final e = _s(p['email']).toLowerCase();
      if (e.isEmpty) return false;
      final usedToday = emailTodayCount[e] ?? 0;
      return usedToday < perDayCap;
    }).toList();

    pool = filtered.isNotEmpty
        ? filtered
        : (allowReassignIfCapExceeded ? currentProvidersRaw : const []);
  } else {
    pool = currentProvidersRaw.toList();
  }

  if (pool.isEmpty) {
    return null;
  }

  if (pool.length == 1) {
    final chosen = _normalizeProvider(pool.first);
    final chosenEmail = chosen['email'] as String;
    await firestore.runTransaction((tx) async {
      final fresh = await tx.get(currentDocSnap!.reference);
      if (!fresh.exists) return;

      final freshModel = ServicesHistoryModel.fromJson(fresh.data()!, fresh.id);
      final freshAssigned = _assignedEmailFromModel(freshModel);

      if (respectExistingAssignment && freshAssigned.isNotEmpty) return;

      tx.update(currentDocSnap!.reference, {
        'assignedProviderEmail': [chosenEmail],
        'assignedProvider'     : [chosenEmail],
      });
    });
    return chosen;
  }

  // 4) Sort by load balancing criteria
  final seed = _seedFrom(currentServiceDocId);
  int tieHash(String email) => _seedFrom('$seed|$email');

  pool.sort((a, b) {
    final ea = _s(a['email']).toLowerCase();
    final eb = _s(b['email']).toLowerCase();

    final da = emailTotalDuration[ea] ?? 0.0;
    final db = emailTotalDuration[eb] ?? 0.0;
    if (da != db) return da.compareTo(db);

    final pa = emailParentFreq[ea] ?? 0;
    final pb = emailParentFreq[eb] ?? 0;
    if (pa != pb) return pa.compareTo(pb);

    final fa = emailFrequency[ea] ?? 0;
    final fb = emailFrequency[eb] ?? 0;
    if (fa != fb) return fa.compareTo(fb);

    return tieHash(ea).compareTo(tieHash(eb));
  });

  // 5) Persist chosen email atomically & return
  final chosen = _normalizeProvider(pool.first);
  final chosenEmail = chosen['email'] as String;

  await firestore.runTransaction((tx) async {
    final fresh = await tx.get(currentDocSnap!.reference);
    if (!fresh.exists) return;

    final freshModel = ServicesHistoryModel.fromJson(fresh.data()!, fresh.id);
    final freshAssigned = _assignedEmailFromModel(freshModel);

    if (respectExistingAssignment && freshAssigned.isNotEmpty) return;

    tx.update(currentDocSnap!.reference, {
      'assignedProviderEmail': [chosenEmail],
      'assignedProvider'     : [chosenEmail],
    });
  });

  // print("✅ RETURNING FULL PROVIDER DATA: $chosen");

  return chosen;
}






/// ******************* FILE INFO *******************
/// File Name: selectServiceProviderApproval_FIXED.dart
/// Description: Fixed version that searches in the correct collection
/// Created by: Amr Mesbah
/// Last Update: [Current Date]

