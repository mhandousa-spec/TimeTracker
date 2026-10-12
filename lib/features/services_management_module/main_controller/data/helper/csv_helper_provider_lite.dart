/// Module: services_management_module
/// Description: `selectServiceProviderLite` — lightweight, persistence-aware
///              provider auto-assignment (part of csv_helper.dart).
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: cloud_firestore, core/network/get_base_url.dart (via csv_helper.dart)
/// Revision History: Initial version — auto-split from csv_helper.dart to keep
///                    each physical file ≤800 LOC (audit fix #1).
// Auto-split from csv_helper.dart — part of the same library.
part of 'csv_helper.dart';

double _toMinutes(double v, String? unit) {
  switch ((unit ?? '').toLowerCase()) {
    case 'minutes': return v;
    case 'hours':   return v * 60;
    case 'days':    return v * 60 * 24;
    case 'weeks':   return v * 60 * 24 * 7;
    default:        return v;
  }
}

bool _isActiveStatus(String s) {
  s = s.toLowerCase();
  return s == 'pending' || s == 'approved' || s == 'inprogress' || s == 'done';
}


Future<Map<String, dynamic>?> selectServiceProviderLite({
  required List<Map<String, dynamic>> candidates,

  // ---- NEW optional params to enable persistence ----
  String? serviceId,                                // CreateServices doc id; if provided, we can persist / honor manual
  String createServicesCollection =
      FirestoreCollections.createServicesRoot,      // will be prefixed by getBaseUrl(...)
  bool enablePersistence = true,                    // whether to write back after auto-pick
  String assignedProviderField = 'assignedProvider',
  String assignedEmailField = 'assignedProviderEmail',
  String manualFlagField = 'assignedProviderManual',

  // ---- selection knobs ----
  int windowDays = 7,
  int perDayCap = 2, // 0 to disable per-day cap
}) async
{
  // 0) quick exits
  if (candidates.isEmpty) return null;
  if (candidates.length == 1) {
    // Optionally persist single candidate if serviceId provided and no manual override
    final single = candidates.first;
    if (serviceId != null && enablePersistence) {
      final fs = FirebaseFirestore.instance;
      final docRef = fs.collection(getBaseUrl(createServicesCollection)).doc(serviceId);
      final snap = await docRef.get();
      final data = snap.data();

      final hasManual = (data != null && (data[manualFlagField] == true));
      if (!hasManual) {
        await docRef.update({
          assignedProviderField: FieldValue.arrayUnion([single]),
          assignedEmailField: FieldValue.arrayUnion([(single['email'] ?? '').toString().toLowerCase()]),
          manualFlagField: FieldValue.arrayUnion([false]),
          'timestamps': FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
        });
      }
    }
    return single;
  }

  final fs = FirebaseFirestore.instance;
  final now = DateTime.now();
  final from = now.subtract(Duration(days: windowDays));
  final startToday = DateTime(now.year, now.month, now.day);
  final endToday = startToday.add(const Duration(days: 1));

  // 1) If serviceId present, check manual override or existing assignment
  if (serviceId != null) {
    final docRef = fs.collection(getBaseUrl(createServicesCollection)).doc(serviceId);
    final snap = await docRef.get();
    final data = snap.data();

    if (data != null) {
      // Handle list format for manualFlag
      bool isManual = false;
      if (data[manualFlagField] is List && (data[manualFlagField] as List).isNotEmpty) {
        isManual = (data[manualFlagField] as List).last == true;
      } else if (data[manualFlagField] is bool) {
        isManual = data[manualFlagField] as bool;
      }

      // Handle list format for assignedProvider
      Map<String, dynamic>? existingProvider;
      if (data[assignedProviderField] is List && (data[assignedProviderField] as List).isNotEmpty) {
        final lastEntry = (data[assignedProviderField] as List).last;
        if (lastEntry is Map) {
          existingProvider = Map<String, dynamic>.from(lastEntry);
        }
      } else if (data[assignedProviderField] is Map) {
        existingProvider = Map<String, dynamic>.from(data[assignedProviderField]);
      }

      // If manually set -> always respect it and return
      if (isManual && existingProvider != null) {
        return existingProvider;
      }
    }
  }

  // 2) Build candidate email set
  final emails = candidates
      .map((c) => (c['email'] ?? '').toString().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toSet();
  if (emails.isEmpty) return candidates.first;

  // 3) ✅ UPDATED: Query RequestServices collection directly (no collectionGroup)
  final requestServicesPath = getBaseUrl(FirestoreCollections.requestServicesRoot);

  // Path may be any odd-segment length
  // (e.g. Demo/{id}/Modules/services/RequestServices).
  // Firestore.collection() accepts a full slash-delimited path directly.
  final CollectionReference<Map<String, dynamic>> requestsCollection =
      fs.collection(requestServicesPath);

  // Query recent requests
  final recent = await requestsCollection
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
      .get();

  final Map<String, double> minutes = { for (final e in emails) e: 0.0 };
  final Map<String, int>    count   = { for (final e in emails) e: 0   };
  final Map<String, int>    today   = { for (final e in emails) e: 0   };

  for (final d in recent.docs) {
    final row = d.data();

    // ✅ UPDATED: Handle assignedProviderEmail field (list format)
    String email = '';

    if (row['Assigned_Provider_Email'] != null) {
      final assignedEmail = row['Assigned_Provider_Email'];
      if (assignedEmail is List && assignedEmail.isNotEmpty) {
        email = assignedEmail.last.toString().toLowerCase();
      } else if (assignedEmail is String) {
        email = assignedEmail.toLowerCase();
      }
    }

    // Fallback to provider field
    if (email.isEmpty) {
      final prov = row['provider'];
      if (prov is Map) {
        email = (prov['email'] ?? '').toString().toLowerCase();
      }
    }

    if (!emails.contains(email)) continue;

    // ✅ UPDATED: Handle list format for state
    String state = '';
    if (row['state'] is List && (row['state'] as List).isNotEmpty) {
      state = (row['state'] as List).last.toString();
    } else if (row['state'] is String) {
      state = row['state'].toString();
    }

    if (!_isActiveStatus(state)) continue;

    final ts = row['createdAt'] ?? row['serviceNameEnglishTimestamp'];
    if (ts is! Timestamp) continue;
    final created = ts.toDate();

    // ✅ UPDATED: Handle list format for selectedDurationUnit
    String? unit;
    if (row['Selected_Duration_Unit'] is List && (row['Selected_Duration_Unit'] as List).isNotEmpty) {
      unit = (row['Selected_Duration_Unit'] as List).last?.toString();
    } else if (row['Selected_Duration_Unit'] is Map) {
      unit = row['Selected_Duration_Unit']['value']?.toString();
    } else {
      unit = row['Selected_Duration_Unit']?.toString();
    }

    // ✅ UPDATED: Handle list format for durationOfServices
    String? valStr;
    if (row['durationOfServices'] is List && (row['durationOfServices'] as List).isNotEmpty) {
      valStr = (row['durationOfServices'] as List).last?.toString();
    } else if (row['durationOfServices'] is Map) {
      valStr = row['durationOfServices']['value']?.toString();
    } else {
      valStr = row['durationOfServices']?.toString();
    }

    final mins = _toMinutes(double.tryParse(valStr ?? '0') ?? 0, unit);

    minutes[email] = (minutes[email] ?? 0) + mins;
    count[email]    = (count[email] ?? 0) + 1;

    if (!created.isBefore(startToday) && created.isBefore(endToday)) {
      today[email] = (today[email] ?? 0) + 1;
    }
  }

  // 4) daily cap filter (optional)
  final filtered = (perDayCap > 0)
      ? candidates.where((c) {
    final e = (c['email'] ?? '').toString().toLowerCase();
    return (today[e] ?? 0) < perDayCap;
  }).toList()
      : candidates.toList();

  final pool = filtered.isNotEmpty ? filtered : candidates;

  // 5) rank by total minutes then by count (fairness)
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

  // 6) random among tied best
  final best = pool.first;
  final be = (best['email'] ?? '').toString().toLowerCase();
  final bm = minutes[be] ?? 0;
  final bc = count[be] ?? 0;

  final tied = pool.where((c) {
    final e = (c['email'] ?? '').toString().toLowerCase();
    return (minutes[e] ?? 0) == bm && (count[e] ?? 0) == bc;
  }).toList();

  final chosen = (tied.length <= 1)
      ? best
      : (tied..shuffle(Random())).first;

  // 7) ✅ UPDATED: persist result using array format
  if (serviceId != null && enablePersistence) {
    final docRef = fs.collection(getBaseUrl(createServicesCollection)).doc(serviceId);
    final snap = await docRef.get();
    final data = snap.data();

    // Check if manually set
    bool isManual = false;
    if (data != null) {
      if (data[manualFlagField] is List && (data[manualFlagField] as List).isNotEmpty) {
        isManual = (data[manualFlagField] as List).last == true;
      } else if (data[manualFlagField] is bool) {
        isManual = data[manualFlagField] as bool;
      }
    }

    if (!isManual) {
      await docRef.update({
        assignedProviderField: FieldValue.arrayUnion([chosen]),
        assignedEmailField: FieldValue.arrayUnion([(chosen['email'] ?? '').toString().toLowerCase()]),
        manualFlagField: FieldValue.arrayUnion([false]),
        'timestamps': FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
      });
    }
  }

  return chosen;
}






