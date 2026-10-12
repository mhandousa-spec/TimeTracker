// ******************* FILE INFO *******************
// File Name: service_provider_selector
// Description: Pure provider-selection logic extracted from ServicesManagerCubit
//              (workload balancing / round-robin candidate picking).
// Module: services_management_module / data / helper
// *************************************************

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

/// Encapsulates the algorithm that chooses which provider a new request is
/// assigned to, based on historical workload. Holds no UI/cubit state.
class ServiceProviderSelector {
  ServiceProviderSelector({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> selectProviderForNewRequest({
    required List<EmployeeEntityModell> providers,
    String? parentServiceId,
  }) async {
    if (providers.isEmpty) return null;
    if (providers.length == 1) {
      return convertEmployeeToMap(providers.first);
    }

    try {
      if (parentServiceId != null && parentServiceId.isNotEmpty) {
        // ✅ Query the RequestServices collection directly.
        // ⚠️ Must use the Firestore key, not the Dart property name.
        // 'parentServiceId' matched nothing, so history was always empty and
        // every provider tied at 0 workload → the same person won every time.
        final historicalDocs = await _firestore
            .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
            .where(ServicesHistoryModel.kParentServiceId,
                arrayContains: parentServiceId)
            .get();

        final candidates = providers.map((e) => {
          'email': e.email ?? '',
          'firstName': e.firstName ?? '',
          'lastName': e.lastName ?? '',
          'firstNameInArabic': e.firstNameInArabic ?? '',
          'lastNameInArabic': e.lastNameInArabic ?? '',
        }).where((m) => (m['email'] ?? '').toString().isNotEmpty).toList();

        return selectProviderByTotalWorkload(
          candidates: candidates,
          allHistoricalDocs: historicalDocs.docs,
        );
      }
    } catch (e, s) {
      // Silently swallowing this is what hid the field-name bug for so long.
      debugPrint('❌ selectProviderForNewRequest failed, '
          'falling back to providers.first: $e');
      debugPrintStack(stackTrace: s);
    }

    return convertEmployeeToMap(providers.first);
  }

  Map<String, dynamic> convertEmployeeToMap(EmployeeEntityModell employee) {
    return {
      'id': employee.id ?? '',
      'email': employee.email ?? '',
      'firstName': employee.firstName ?? '',
      'lastName': employee.lastName ?? '',
      'firstNameInArabic': employee.firstNameInArabic ?? '',
      'lastNameInArabic': employee.lastNameInArabic ?? '',
      'middleName': employee.middleName ?? '',
      'middleNameInArabic': employee.middleNameInArabic ?? '',
      'departmentId': employee.departmentId ?? '',
      'title': employee.title ?? '',
      'titleInArabic': employee.titleInArabic ?? '',
      'role': employee.role ?? '',
      'gender': employee.gender ?? '',
      'workLocation': employee.workLocation ?? '',
      'status': employee.status ?? 'active',
    };
  }

  Map<String, dynamic>? pickProviderFromRecentDocs({
    required List<Map<String, dynamic>> candidates,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> recentDocs,
    required DateTime startToday,
    required DateTime endToday,
    int perDayCap = 2,
    required Function isActiveStatus,
    required Function toMinutes,
  }) {
    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;

    final emails = candidates
        .map((c) => (c['email'] ?? '').toString().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (emails.isEmpty) return candidates.first;

    final Map<String, double> minutes = {for (final e in emails) e: 0.0};
    final Map<String, int> count = {for (final e in emails) e: 0};
    final Map<String, int> today = {for (final e in emails) e: 0};

    for (final d in recentDocs) {
      final data = d.data();
      final prov = data['provider'];
      if (prov is! Map) continue;

      final email = (prov['email'] ?? '').toString().toLowerCase();
      if (!emails.contains(email)) continue;

      final st = (data['state'] ?? '').toString();
      if (!isActiveStatus(st)) continue;

      final ts = data['createdAt'] ?? data['serviceNameEnglishTimestamp'];
      if (ts is! Timestamp) continue;
      final created = ts.toDate();

      final unit = data['selectedDurationUnit'] is Map
          ? data['selectedDurationUnit']['value']?.toString()
          : data['selectedDurationUnit']?.toString();

      final valStr = data['durationOfServices'] is Map
          ? data['durationOfServices']['value']?.toString()
          : data['durationOfServices']?.toString();

      final mins = toMinutes(double.tryParse(valStr ?? '0') ?? 0, unit);

      minutes[email] = (minutes[email] ?? 0) + mins;
      count[email] = (count[email] ?? 0) + 1;

      if (!created.isBefore(startToday) && created.isBefore(endToday)) {
        today[email] = (today[email] ?? 0) + 1;
      }
    }

    final filtered = (perDayCap > 0)
        ? candidates.where((c) {
      final e = (c['email'] ?? '').toString().toLowerCase();
      return (today[e] ?? 0) < perDayCap;
    }).toList()
        : candidates.toList();

    final pool = filtered.isNotEmpty ? filtered : candidates;

    pool.sort((a, b) {
      final ea = (a['email'] ?? '').toString().toLowerCase();
      final eb = (b['email'] ?? '').toString().toLowerCase();
      final mA = minutes[ea] ?? 0;
      final mB = minutes[eb] ?? 0;
      if (mA != mB) return mA.compareTo(mB);
      final cA = count[ea] ?? 0;
      final cB = count[eb] ?? 0;
      if (cA != cB) return cA.compareTo(cB);
      return ea.compareTo(eb);
    });

    final best = pool.first;
    final be = (best['email'] ?? '').toString().toLowerCase();
    final bm = minutes[be] ?? 0;
    final bc = count[be] ?? 0;

    final tied = pool.where((c) {
      final e = (c['email'] ?? '').toString().toLowerCase();
      return (minutes[e] ?? 0) == bm && (count[e] ?? 0) == bc;
    }).toList();

    if (tied.length <= 1) return best;
    tied.shuffle(Random());
    return tied.first;
  }

  Future<Map<String, dynamic>?> computeProvider({
    required List<EmployeeEntityModell> providerServices,
  }) {
    final candidates = (providerServices)
        .map((e) => {
      'email': e.email,
      'firstName': e.firstName,
      'lastName': e.lastName,
      'firstNameInArabic': e.firstNameInArabic,
      'lastNameInArabic': e.lastNameInArabic,
      'title': e.title,
      'titleInArabic': e.titleInArabic,
      'mobilePhone': (e.mobilePhone == null)
          ? null
          : {
        'countryApp': e.mobilePhone?.countryApp,
        'countryCode': e.mobilePhone?.countryCode,
        'phone': e.mobilePhone?.phone,
      },
    })
        .where((m) => (m['email'] ?? '').toString().isNotEmpty)
        .toList();

    return selectServiceProviderLite(
      candidates: candidates,
      windowDays: 7,
      perDayCap: 2,
    );
  }

  Map<String, dynamic>? selectProviderByTotalWorkload({
    required List<Map<String, dynamic>> candidates,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> allHistoricalDocs,
  }) {
    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;

    final Map<String, double> totalWorkload = {};
    final Map<String, int> totalAssignments = {};

    for (final candidate in candidates) {
      final email = (candidate['email'] ?? '').toString().toLowerCase();
      totalWorkload[email] = 0.0;
      totalAssignments[email] = 0;
    }

    for (final doc in allHistoricalDocs) {
      final data = doc.data();

      // ⚠️ Firestore keys, not Dart property names. Reading
      // 'assignedProviderEmail' / 'provider' always missed, so every
      // provider's workload stayed at 0.
      final assignedEmail = _lastString(
        data[ServicesHistoryModel.kAssignedProviderEmail],
      ).toLowerCase();

      if (assignedEmail.isNotEmpty && totalWorkload.containsKey(assignedEmail)) {
        final minutes = calculateWorkloadMinutes(data);
        totalWorkload[assignedEmail] = (totalWorkload[assignedEmail] ?? 0) + minutes;
        totalAssignments[assignedEmail] = (totalAssignments[assignedEmail] ?? 0) + 1;

      }
    }

    final sortedCandidates = List<Map<String, dynamic>>.from(candidates);
    sortedCandidates.sort((a, b) {
      final emailA = (a['email'] ?? '').toString().toLowerCase();
      final emailB = (b['email'] ?? '').toString().toLowerCase();

      final workloadA = totalWorkload[emailA] ?? 0.0;
      final workloadB = totalWorkload[emailB] ?? 0.0;

      if (workloadA != workloadB) {
        return workloadA.compareTo(workloadB);
      }

      final assignmentsA = totalAssignments[emailA] ?? 0;
      final assignmentsB = totalAssignments[emailB] ?? 0;
      if (assignmentsA != assignmentsB) {
        return assignmentsA.compareTo(assignmentsB);
      }

      return emailA.compareTo(emailB);
    });

    // ⚠️ Without this, providers tied on workload AND assignment count always
    // resolve alphabetically — so the alphabetically-first provider took every
    // request. Break genuine ties at random, like pickProviderFromRecentDocs.
    final best = sortedCandidates.first;
    final bestEmail = (best['email'] ?? '').toString().toLowerCase();
    final bestWorkload = totalWorkload[bestEmail] ?? 0.0;
    final bestAssignments = totalAssignments[bestEmail] ?? 0;

    final tied = sortedCandidates.where((c) {
      final e = (c['email'] ?? '').toString().toLowerCase();
      return (totalWorkload[e] ?? 0.0) == bestWorkload &&
          (totalAssignments[e] ?? 0) == bestAssignments;
    }).toList();

    if (tied.length <= 1) return best;

    tied.shuffle(Random());
    return tied.first;
  }

  /// Reads the newest entry of a Firestore field that may be stored either as
  /// a history list (this module's convention) or as a bare scalar.
  static String _lastString(dynamic raw) {
    if (raw == null) return '';
    if (raw is List) return raw.isEmpty ? '' : raw.last.toString().trim();
    return raw.toString().trim();
  }

  double calculateWorkloadMinutes(Map<String, dynamic> data) {
    // ⚠️ Firestore keys ('Duration_Of_Services' / 'Selected_Duration_Unit'),
    // not the camelCase Dart property names.
    final value = double.tryParse(
          _lastString(data[ServicesHistoryModel.kDurationOfServices]),
        ) ??
        0.0;

    var unit = _lastString(data[ServicesHistoryModel.kSelectedDurationUnit]);
    if (unit.isEmpty) unit = 'minutes';

    switch (unit.toLowerCase()) {
      case 'hours':
      case 'hour':
      case 'h':
        return value * 60;
      case 'days':
      case 'day':
      case 'd':
        return value * 1440;
      case 'weeks':
      case 'week':
      case 'w':
        return value * 10080;
      default:
        return value;
    }
  }

  double toMinutes(double v, String? unit) {
    switch ((unit ?? '').toLowerCase()) {
      case 'minutes':
        return v;
      case 'hours':
        return v * 60;
      case 'days':
        return v * 60 * 24;
      case 'weeks':
        return v * 60 * 24 * 7;
      default:
        return v;
    }
  }

  bool isActiveStatus(String s) {
    s = s.toLowerCase();
    return s == 'pending' || s == 'approved' || s == 'inprogress' || s == 'done';
  }

  Future<Map<String, dynamic>?> selectServiceProviderLite({
    required List<Map<String, dynamic>> candidates,
    int windowDays = 7,
    int perDayCap = 2,
  }) async {
    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;

    try {
      final now = DateTime.now();
      final startWindow = now.subtract(Duration(days: windowDays));
      final startToday = DateTime(now.year, now.month, now.day);
      final endToday = startToday.add(Duration(days: 1));

      final recentDocs = await _firestore
          .collectionGroup('user')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startWindow))
          .get();

      return pickProviderFromRecentDocs(
        candidates: candidates,
        recentDocs: recentDocs.docs,
        startToday: startToday,
        endToday: endToday,
        perDayCap: perDayCap,
        isActiveStatus: isActiveStatus,
        toMinutes: toMinutes,
      );
    } catch (e) {
      return candidates.first;
    }
  }
}
