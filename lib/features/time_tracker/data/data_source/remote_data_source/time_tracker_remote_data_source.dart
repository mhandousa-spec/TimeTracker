/// Module: time_tracker / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_remote_data_source.dart
/// Purpose: Declares `TimeTrackerRemoteDataSource` — the only class that
///          reads / writes the module's own Firestore documents
///          (`Demo/{cid}/Modules/time_tracker/<Collection>/<doc>`).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Collection-agnostic on purpose: every Time Tracker collection uses the
/// same "indexed history" write — read the stored document in a transaction,
/// append one row to every field + `timestamps` (`TimeTrackerHistoryCodec`),
/// write it back with a full `set`. The repositories decide WHAT the row is.
///
/// Guards (same as To-Do): refuses to resolve any path while
/// `ApiConstants.baseUri` is empty (no company signed in) — the path would
/// otherwise collapse to a top-level collection Firestore happily accepts.
/// Before the first write of a session it makes sure
/// `Demo/{cid}/Modules/time_tracker` is a REAL document (`{}` with merge,
/// only when missing) so the Firebase console lists its collections.
///
/// Throws on failure; turning throws into clean messages is the
/// repositories' job, so there is no try/catch here.
///
/// Updated: 8/10/2026 - [createIfAbsent] (create-only write used by the
/// absent-day sweep, owner decision 20).
/// Updated: 9/10/2026 - code review: [watchArrayContains] (an employee's
/// own requests — finding 9) and [appendRows] (a request decision and its
/// balance / attendance effect in ONE transaction — findings 2 + 3).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';

/// Builds the next history row from the document id and the stored data
/// (null on create).
typedef HistoryRowBuilder = Map<String, Object?> Function(
  String id,
  Map<String, dynamic>? stored,
);

/// Like [HistoryRowBuilder], but may answer null = leave this document
/// untouched (ADDED 9/10/2026 — e.g. a refund with no balance stored).
typedef OptionalHistoryRowBuilder = Map<String, Object?>? Function(
  String id,
  Map<String, dynamic>? stored,
);

/// ADDED 13/10/2026 (owner decision 48): a readable id for a NEW document —
/// `{prefix}-{0001}` from the per-company counter [counterKey] (default
/// [prefix]), taken inside the same transaction as the write: REQ-2026-0001,
/// TRX-2026-0001, LOC-0001, GRP-0001, RQT-0001, CMT-0001 (per request).
class NewDocId {
  const NewDocId(this.prefix, {String? counterKey}) : _counterKey = counterKey;

  final String prefix;
  final String? _counterKey;

  String get counterKey => _counterKey ?? prefix;

  /// The id for counter value [n].
  String idFor(int n) => '$prefix-${n.toString().padLeft(4, '0')}';

  /// Field of the counter document.
  static const String lastNumber = 'Last_Number';
}

/// One document of a multi-document history write ([TimeTrackerRemoteDataSource.appendRows]).
class HistoryRowWrite {
  const HistoryRowWrite({
    required this.relativePath,
    required this.id,
    required this.row,
    this.mustExist = false,
    this.newId,
  });

  /// With [id] null: the readable id series of the new document (null = an
  /// automatic Firestore id).
  final NewDocId? newId;

  /// The collection.
  final String relativePath;

  /// The document id; null = a new auto id.
  final String? id;

  /// Refuse to create (an update of a deleted doc).
  final bool mustExist;

  /// The next row from the stored data. Throwing aborts the WHOLE write.
  final OptionalHistoryRowBuilder row;
}

class TimeTrackerRemoteDataSource {
  TimeTrackerRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// The company base the module document was last ensured for.
  String? _ensuredFor;

  /// `Demo/{companyId}/<relativePath>`, refusing an empty company.
  String _resolve(String relativePath) {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the '
        'Time Tracker path "$relativePath" cannot be resolved.',
      );
    }
    return getBaseUrl(relativePath);
  }

  CollectionReference<Map<String, dynamic>> _collection(String relativePath) =>
      _firestore.collection(_resolve(relativePath));

  static List<TimeTrackerDocument> _documents(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) =>
      snapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                TimeTrackerDocument(id: d.id, data: d.data()),
          )
          .toList(growable: false);

  /// Function Name: [ensureModuleDocument]
  ///
  /// Purpose: Create `Demo/{cid}/Modules/time_tracker` as `{}` (merge) when
  /// it does not exist. Checked once per company per session.
  ///
  /// Return type: [Future<void>]
  Future<void> ensureModuleDocument() async {
    final String path = _resolve(TimeTrackerFirestorePaths.root);
    if (_ensuredFor == path) return;
    final DocumentReference<Map<String, dynamic>> ref = _firestore.doc(path);
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set(<String, dynamic>{}, SetOptions(merge: true));
    }
    _ensuredFor = path;
  }

  /// Function Name: [watchCollection]
  ///
  /// Purpose: Live read of every document in [relativePath].
  ///
  /// Parameters:
  ///   [String] relativePath: e.g. `TimeTrackerFirestorePaths.requests`.
  ///
  /// Return type: [Stream<List<TimeTrackerDocument>>]
  Stream<List<TimeTrackerDocument>> watchCollection(String relativePath) =>
      _collection(relativePath).snapshots().map(_documents);

  /// Function Name: [watchIdPrefix]
  ///
  /// Purpose: Live read of the documents whose id starts with [prefix]
  /// (a document-id range — e.g. one employee's attendance days).
  ///
  /// Parameters:
  ///   [String] relativePath
  ///   [String] prefix
  ///
  /// Return type: [Stream<List<TimeTrackerDocument>>]
  Stream<List<TimeTrackerDocument>> watchIdPrefix(
    String relativePath,
    String prefix,
  ) =>
      _collection(relativePath)
          .orderBy(FieldPath.documentId)
          .startAt(<Object>[prefix])
          .endAt(<Object>['$prefix'])
          .snapshots()
          .map(_documents);

  /// Function Name: [watchArrayContains]
  ///
  /// Purpose: ADDED 9/10/2026 (code review finding 9) — live read of the
  /// documents whose history list [field] contains [value] (e.g. one
  /// employee's requests: `Requester_Email` never changes, so its history
  /// only ever holds that e-mail).
  ///
  /// Return type: [Stream<List<TimeTrackerDocument>>]
  Stream<List<TimeTrackerDocument>> watchArrayContains(
    String relativePath,
    String field,
    Object value,
  ) =>
      _collection(relativePath)
          .where(field, arrayContains: value)
          .snapshots()
          .map(_documents);

  /// Function Name: [fetchCollection]
  ///
  /// Purpose: One-shot read of every document in [relativePath].
  ///
  /// Return type: [Future<List<TimeTrackerDocument>>]
  Future<List<TimeTrackerDocument>> fetchCollection(String relativePath) async =>
      _documents(await _collection(relativePath).get());

  /// Function Name: [fetchDocument]
  ///
  /// Purpose: One-shot read of [id] in [relativePath].
  ///
  /// Return type: [Future<TimeTrackerDocument?>] — null when missing.
  Future<TimeTrackerDocument?> fetchDocument(
    String relativePath,
    String id,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _collection(relativePath).doc(id).get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return TimeTrackerDocument(id: snapshot.id, data: data);
  }

  /// Function Name: [appendRow]
  ///
  /// Purpose: Append one history row in a transaction (creating the document
  /// when it does not exist, unless [mustExist]).
  ///
  /// Parameters:
  ///   [String] relativePath: the collection.
  ///   [String?] id: the document id; null = a new auto id.
  ///   [bool] mustExist: refuse to create (an update of a deleted doc).
  ///   [HistoryRowBuilder] row: the new value of EVERY field.
  ///
  /// Return type: [Future<TimeTrackerDocument>] — the written document.
  Future<TimeTrackerDocument> appendRow({
    required String relativePath,
    required String? id,
    required bool mustExist,
    required HistoryRowBuilder row,
    NewDocId? newId,
  }) async {
    final CollectionReference<Map<String, dynamic>> collection =
        _collection(relativePath);
    await ensureModuleDocument();
    return _firestore.runTransaction<TimeTrackerDocument>(
      (Transaction tx) async {
        final Map<String, int> taken = <String, int>{};
        final DocumentReference<Map<String, dynamic>> ref = id != null
            ? collection.doc(id)
            : (newId == null ? collection.doc() : await _allocate(tx, collection, newId, taken));
        final DocumentSnapshot<Map<String, dynamic>> stored = await tx.get(ref);
        if (mustExist && !stored.exists) {
          throw StateError('This record no longer exists.');
        }
        final Map<String, dynamic>? old = stored.exists ? stored.data() : null;
        final Map<String, dynamic> data = TimeTrackerHistoryCodec.append(
          old: old,
          values: row(ref.id, old),
          now: DateTime.now(),
        );
        _writeCounters(tx, taken);
        tx.set(ref, data);
        return TimeTrackerDocument(id: ref.id, data: data);
      },
    );
  }

  /// The next free readable id of [newId] (inside [tx]; [taken] collects the
  /// counter values to write once every read is done).
  Future<DocumentReference<Map<String, dynamic>>> _allocate(
    Transaction tx,
    CollectionReference<Map<String, dynamic>> collection,
    NewDocId newId,
    Map<String, int> taken,
  ) async {
    int n = taken[newId.counterKey] ??
        (((await tx.get(_collection(TimeTrackerFirestorePaths.counters).doc(newId.counterKey)))
                    .data()?[NewDocId.lastNumber] as num?)
                ?.toInt() ??
            0);
    // Skip an id that already exists (a counter reset by hand).
    for (int guard = 0; guard < 50; guard++) {
      n++;
      final DocumentReference<Map<String, dynamic>> ref = collection.doc(newId.idFor(n));
      if (!(await tx.get(ref)).exists) {
        taken[newId.counterKey] = n;
        return ref;
      }
    }
    throw StateError('Could not find a free ${newId.prefix} number.');
  }

  void _writeCounters(Transaction tx, Map<String, int> taken) {
    for (final MapEntry<String, int> e in taken.entries) {
      tx.set(_collection(TimeTrackerFirestorePaths.counters).doc(e.key),
          <String, Object>{NewDocId.lastNumber: e.value}, SetOptions(merge: true));
    }
  }

  /// Function Name: [appendRows]
  ///
  /// Purpose: ADDED 9/10/2026 (code review findings 2 + 3) — append one
  /// history row to SEVERAL documents in ONE transaction: every document is
  /// read first, then each builder gets its stored data (a builder that
  /// throws — e.g. a compare-and-set that finds a newer row — aborts every
  /// write; one that answers null leaves its document untouched), then all
  /// rows are written together. Firestore retries the whole transaction on
  /// contention, so the builders always see the latest data.
  ///
  /// Parameters:
  ///   [List<HistoryRowWrite>] writes
  ///
  /// Return type: [Future<List<TimeTrackerDocument?>>] — per write, the
  /// written document (null = untouched).
  Future<List<TimeTrackerDocument?>> appendRows(List<HistoryRowWrite> writes) async {
    await ensureModuleDocument();
    return _firestore.runTransaction<List<TimeTrackerDocument?>>((Transaction tx) async {
      final Map<String, int> taken = <String, int>{};
      final List<DocumentReference<Map<String, dynamic>>> refs = <DocumentReference<Map<String, dynamic>>>[];
      for (final HistoryRowWrite w in writes) {
        final NewDocId? newId = w.newId;
        refs.add(w.id != null
            ? _collection(w.relativePath).doc(w.id)
            : (newId == null
                ? _collection(w.relativePath).doc()
                : await _allocate(tx, _collection(w.relativePath), newId, taken)));
      }
      final List<DocumentSnapshot<Map<String, dynamic>>> stored =
          <DocumentSnapshot<Map<String, dynamic>>>[
        for (final DocumentReference<Map<String, dynamic>> ref in refs) await tx.get(ref),
      ];
      final List<TimeTrackerDocument?> out = <TimeTrackerDocument?>[];
      final DateTime now = DateTime.now();
      for (int i = 0; i < writes.length; i++) {
        final Map<String, dynamic>? old = stored[i].exists ? stored[i].data() : null;
        if (writes[i].mustExist && old == null) {
          throw StateError('This record no longer exists.');
        }
        final Map<String, Object?>? values = writes[i].row(refs[i].id, old);
        if (values == null) {
          out.add(null);
          continue;
        }
        out.add(TimeTrackerDocument(
          id: refs[i].id,
          data: TimeTrackerHistoryCodec.append(old: old, values: values, now: now),
        ));
      }
      _writeCounters(tx, taken);
      for (int i = 0; i < writes.length; i++) {
        final TimeTrackerDocument? doc = out[i];
        if (doc != null) tx.set(refs[i], doc.data);
      }
      return out;
    });
  }

  /// Function Name: [fetchArrayContains]
  ///
  /// Purpose: ADDED 9/10/2026 (debug demo data) — one-shot read of the
  /// documents whose history list [field] contains [value] (e.g. every
  /// document tagged `Is_Demo: [true]`).
  ///
  /// Return type: [Future<List<TimeTrackerDocument>>]
  Future<List<TimeTrackerDocument>> fetchArrayContains(
    String relativePath,
    String field,
    Object value,
  ) async =>
      _documents(await _collection(relativePath).where(field, arrayContains: value).get());

  /// Function Name: [deleteDocument]
  ///
  /// Purpose: ADDED 9/10/2026 — hard-delete document [id]. Used ONLY by the
  /// debug "Remove demo data" tool (kDebugMode), and only for documents it
  /// tagged itself (`Is_Demo`); every app feature keeps its soft delete /
  /// status history.
  ///
  /// Return type: [Future<void>]
  Future<void> deleteDocument(String relativePath, String id) =>
      _collection(relativePath).doc(id).delete();

  /// Function Name: [createIfAbsent]
  ///
  /// Purpose: Create document [id] with its FIRST history row only when it
  /// does not exist yet — never touches an existing document (idempotent;
  /// used by the absent-day sweep).
  ///
  /// Parameters:
  ///   [String] relativePath: the collection.
  ///   [String] id: the document id.
  ///   [HistoryRowBuilder] row: the value of every field (stored is null).
  ///
  /// Return type: [Future<bool>] — true when it was created.
  Future<bool> createIfAbsent({
    required String relativePath,
    required String id,
    required HistoryRowBuilder row,
  }) async {
    final CollectionReference<Map<String, dynamic>> collection =
        _collection(relativePath);
    await ensureModuleDocument();
    final DocumentReference<Map<String, dynamic>> ref = collection.doc(id);
    return _firestore.runTransaction<bool>((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> stored = await tx.get(ref);
      if (stored.exists) return false;
      tx.set(
        ref,
        TimeTrackerHistoryCodec.append(
          old: null,
          values: row(ref.id, null),
          now: DateTime.now(),
        ),
      );
      return true;
    });
  }
}
