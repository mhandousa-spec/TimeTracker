/// Module: roles / r2_user_management / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: licence_seat_guard.dart
/// Purpose: Reads what [ModuleUserLimitRule] needs from Firestore — once for
///          the screens (a snapshot), and again INSIDE the transaction that
///          writes a grant (the authoritative check).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 — per-module user limits enforced in the client.
///
/// ─── WHAT IT READS ───────────────────────────────────────────────────
///   * `Demo_Requests/{companyId}` → `Demo_Details.Modules_User_Limits` and
///     `Number_Of_Users` (written by Knowticed Admin).
///   * `Demo/{cid}/User_Management` → who holds which role. This is where
///     every User Management grant is written. (The old counter read
///     `Users_Access`, which only Admin's seeding writes — so it counted ~0.)
///   * `Demo/{cid}/Users_Access` and `Demo/{cid}/Users Access` → ONLY for
///     employees with no `User_Management` document. Admin seeds the Master
///     Admin into `Users_Access` and never into `User_Management`, and HR's
///     employee bulk upload writes `Users Access`; those people hold a seat
///     too. A `User_Management` document always wins over them.
///   * `Demo/{cid}/Roles` + `Demo/{cid}/Subscription_Admin` → role name →
///     modules (the same two collections `RoleRepository.getUnDeletedRoles`
///     merges). Role fields are read under both spellings (`Name` /
///     `roleName`, `Selected_Modules` / `selectedModules`) — the old counter
///     only knew the camelCase pair, which only the seeded Master Admin has.
///
/// ─── WHY A GUARD DOCUMENT ────────────────────────────────────────────
/// A client Firestore transaction can `get` single documents but cannot run a
/// query, so "count the holders" cannot itself be a transactional read. Two
/// admins granting the last seat to two DIFFERENT users at the same moment
/// would each count 9 of 10 and both commit.
///
/// The fix is the standard optimistic-lock pattern: every checked grant also
/// reads and writes ONE shared document, [guardDocId] in `User_Management`.
/// Firestore aborts and retries a transaction whose read documents changed
/// before it committed, so of two concurrent grants the second is retried —
/// and its retry re-runs the count (the queries below run inside the
/// transaction callback) and sees the first grant. Grants are serialised per
/// company; ordinary reads are unaffected.
///
/// The guard lives inside `User_Management` because that is the collection
/// this screen is already allowed to write. It carries no `Role`, so every
/// reader of the collection (`ScheduledAccessApplier`, this class) skips it.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/network/api_constants.dart' hide FirebaseCollections;
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';

/// Thrown inside the transaction to abort it when the rule refuses.
class LicenceSeatLimitException implements Exception {
  const LicenceSeatLimitException(this.verdict);

  final LimitVerdict verdict;

  @override
  String toString() => 'LicenceSeatLimitException(${verdict.violations.length})';
}

class LicenceSeatGuard {
  LicenceSeatGuard({
    FirebaseFirestore? firestore,
    required AccessDateParser parseDate,
    Map<String, DateTime?> Function()? deactivatedOn,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _parseDate = parseDate,
        _deactivatedOn = deactivatedOn;

  final FirebaseFirestore _firestore;
  final AccessDateParser _parseDate;
  final Map<String, DateTime?> Function()? _deactivatedOn;

  /// The shared document every checked grant reads and writes. Not a
  /// `__x__` id — Firestore reserves those.
  static const String guardDocId = '_licence_seat_guard';

  static const String _userManagement = 'User_Management';

  /// Fallback access collections, read only for employees with no
  /// `User_Management` document (see the file header).
  static const List<String> _seedCollections = <String>[
    'Users_Access',
    'Users Access',
  ];

  static const List<String> _roleCollections = <String>[
    'Roles',
    'Subscription_Admin',
  ];

  /// The company id the app is signed into (`Demo/{companyId}`).
  String get companyId {
    final String baseUri = ApiConstants.baseUri;
    return baseUri.contains('/') ? baseUri.split('/').last : baseUri;
  }

  String _requireCompanyId() {
    final String id = companyId.trim();
    // No company → no way to read the limits → refuse (fail closed).
    if (id.isEmpty) throw StateError('No company id — cannot read user limits.');
    return id;
  }

  DocumentReference<Map<String, dynamic>> _limitsRef(String cid) =>
      _firestore.collection(FirebaseCollections.demoRequests).doc(cid);

  CollectionReference<Map<String, dynamic>> get _accessCollection =>
      _firestore.collection(getBaseUrl(_userManagement));

  DocumentReference<Map<String, dynamic>> get _guardRef =>
      _accessCollection.doc(guardDocId);

  Map<String, DateTime?> _deactivations() {
    try {
      return _deactivatedOn?.call() ?? const <String, DateTime?>{};
    } catch (_) {
      // Without deactivation dates every record counts — the strict side.
      return const <String, DateTime?>{};
    }
  }

  /// Function Name: [readSnapshot]
  ///
  /// Purpose: Everything the rule needs, read outside any transaction — for
  /// the usage lines and the pre-check on the User Management screens.
  ///
  /// Returns: [Future<LicenceUsageSnapshot>]. THROWS on any read failure; the
  /// caller must treat that as "cannot verify" and block.
  Future<LicenceUsageSnapshot> readSnapshot() async {
    final String cid = _requireCompanyId();
    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      _limitsRef(cid).get(),
      _readRecords(),
      _readRoles(),
    ]);
    final DocumentSnapshot<Map<String, dynamic>> limitsDoc =
        results[0] as DocumentSnapshot<Map<String, dynamic>>;
    return LicenceUsageSnapshot(
      limits: LicenceLimits.fromDemoRequest(limitsDoc.data()),
      records: results[1] as List<SeatRecord>,
      roles: results[2] as RoleModulesIndex,
      deactivatedOn: _deactivations(),
    );
  }

  /// Function Name: [checkInTransaction]
  ///
  /// Purpose: The authoritative check, run as the first step of the
  /// transaction that writes [proposed].
  ///
  /// Reads the limits document, the guard document and every target's
  /// `User_Management` document through [tx] (so a concurrent change to any of
  /// them retries this transaction), re-counts the holders, and either throws
  /// [LicenceSeatLimitException] — aborting with nothing written — or bumps
  /// the guard document so a concurrent grant is retried against this one.
  ///
  /// Every other failure (read refused, offline, malformed data) is thrown
  /// as-is and also aborts the write: the check fails CLOSED.
  Future<void> checkInTransaction(
    Transaction tx, {
    required List<ProposedAssignment> proposed,
    required String actorEmail,
  }) async {
    final String cid = _requireCompanyId();

    final DocumentSnapshot<Map<String, dynamic>> limitsDoc =
        await tx.get(_limitsRef(cid));
    final LicenceLimits limits = LicenceLimits.fromDemoRequest(limitsDoc.data());
    if (limits.isEmpty) return; // Admin set no limit at all — nothing to guard.

    final DocumentSnapshot<Map<String, dynamic>> guardDoc =
        await tx.get(_guardRef);

    final List<String> targetIds = proposed
        .map((ProposedAssignment p) => p.employeeId)
        .where((String id) => id.trim().isNotEmpty)
        .toSet()
        .toList();
    final List<DocumentSnapshot<Map<String, dynamic>>> targets =
        await Future.wait(<Future<DocumentSnapshot<Map<String, dynamic>>>>[
      for (final String id in targetIds) tx.get(_accessCollection.doc(id)),
    ]);

    // The queries run inside the callback, so a retried transaction counts
    // again from scratch.
    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      _readRecords(),
      _readRoles(),
    ]);

    // The targets' own documents as the transaction saw them go LAST, so they
    // win over whatever the collection query returned for the same ids (the
    // rule keeps the later record). A target with no document keeps its
    // fallback record, if any (e.g. the seeded Master Admin).
    final List<SeatRecord> records = <SeatRecord>[
      ...results[0] as List<SeatRecord>,
      for (final DocumentSnapshot<Map<String, dynamic>> doc in targets)
        if (doc.data() != null)
          SeatRecord.fromAccessDoc(doc.id, doc.data()!, parseDate: _parseDate),
    ];

    final LimitVerdict verdict = ModuleUserLimitRule.evaluate(
      limits: limits,
      roles: results[1] as RoleModulesIndex,
      records: records,
      proposed: proposed,
      now: DateTime.now(),
      deactivatedOn: _deactivations(),
    );
    if (!verdict.allowed) throw LicenceSeatLimitException(verdict);

    final int version =
        StoredValue.currentInt(guardDoc.data()?['Version']) ?? 0;
    tx.set(
      _guardRef,
      <String, dynamic>{
        'Doc_Type': 'licence_seat_guard',
        'Version': version + 1,
        'Updated_At': FieldValue.serverTimestamp(),
        'Updated_By': actorEmail,
      },
      SetOptions(merge: true),
    );
  }

  /// Every access record: the fallback collections first, `User_Management`
  /// last, so the rule's "later record wins" gives `User_Management`
  /// precedence. Fallback records are dropped for anyone who has a
  /// `User_Management` document.
  Future<List<SeatRecord>> _readRecords() async {
    final List<QuerySnapshot<Map<String, dynamic>>> snaps =
        await Future.wait(<Future<QuerySnapshot<Map<String, dynamic>>>>[
      _accessCollection.get(),
      for (final String name in _seedCollections)
        _firestore.collection(getBaseUrl(name)).get(),
    ]);

    final QuerySnapshot<Map<String, dynamic>> managed = snaps.first;
    final Set<String> managedIds = <String>{
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in managed.docs)
        if (d.id != guardDocId) d.id,
    };

    final List<SeatRecord> records = <SeatRecord>[];
    for (final QuerySnapshot<Map<String, dynamic>> seed in snaps.skip(1)) {
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in seed.docs) {
        if (managedIds.contains(d.id)) continue;
        records.add(_recordOf(d.id, d.data()));
      }
    }
    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in managed.docs) {
      if (d.id == guardDocId) continue;
      records.add(_recordOf(d.id, d.data()));
    }
    return records;
  }

  SeatRecord _recordOf(String docId, Map<String, dynamic> data) {
    // Keyed by the document id (= employee id); `Employee_Id` only when the
    // id is somehow blank.
    final String id = docId.trim().isNotEmpty
        ? docId
        : (StoredValue.currentString(data['Employee_Id']) ?? '');
    return SeatRecord.fromAccessDoc(id, data, parseDate: _parseDate);
  }

  Future<RoleModulesIndex> _readRoles() async {
    final List<QuerySnapshot<Map<String, dynamic>>> snaps =
        await Future.wait(<Future<QuerySnapshot<Map<String, dynamic>>>>[
      for (final String name in _roleCollections)
        _firestore.collection(getBaseUrl(name)).get(),
    ]);
    return RoleModulesIndex.fromRoleDocs(<MapEntry<String, Map<String, dynamic>>>[
      for (final QuerySnapshot<Map<String, dynamic>> snap in snaps)
        for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
          MapEntry<String, Map<String, dynamic>>(d.id, d.data()),
    ]);
  }
}
