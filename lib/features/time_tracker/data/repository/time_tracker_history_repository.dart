/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_history_repository.dart
/// Purpose: Declares `TimeTrackerHistoryRepository<T>` — the shared
///          read / write / error-cleaning logic of every Time Tracker
///          collection repository.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Each concrete repository only says WHICH collection, HOW to map its
/// entity (a model's `fromMap` / `row`) and what is VALID; this base turns
/// Firestore failures into clean `Exception`s (MASTER_CODE_REVIEW §11:
/// try/catch lives in repositories and cubits only) and stamps the audit
/// trio on every row. Writes are refused without a signed-in email — a row
/// never lands without `Modified_By`.
/// Updated: 9/10/2026 - code review: [checkStored] (a repository can refuse
/// a write INSIDE the transaction — compare-and-set, finding 2) and
/// [isReadable] (a document the app cannot read is skipped, not guessed).

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';

abstract class TimeTrackerHistoryRepository<T> {
  TimeTrackerHistoryRepository({
    required TimeTrackerRemoteDataSource remoteDataSource,
    required TimeTrackerAccess access,
  })  : remote = remoteDataSource,
        _access = access;

  final TimeTrackerRemoteDataSource remote;
  final TimeTrackerAccess _access;

  /// The collection, e.g. `TimeTrackerFirestorePaths.requests`.
  String get collectionPath;

  /// Used in error messages ("Could not save the request type").
  String get entityLabel;

  /// Document -> entity.
  T decode(TimeTrackerDocument document);

  /// Entity -> the new value of every field of one history row.
  Map<String, Object?> encode(
    T entity, {
    required String id,
    required TimeTrackerAudit audit,
  });

  /// Business rules checked before any write; throws `Exception(message)`.
  void validate(T entity) {}

  /// ADDED 9/10/2026 (code review finding 2): checked INSIDE the write's
  /// transaction against the stored document (null = none) — throwing
  /// aborts the write. Default: nothing.
  void checkStored(T entity, Map<String, dynamic>? stored) {}

  /// ADDED 9/10/2026 (code review): false = the document cannot be read as
  /// a [T] (e.g. an unknown status) — lists skip it, [fetchOne] answers null.
  bool isReadable(TimeTrackerDocument document) => true;

  /// Function Name: [watchAll]
  ///
  /// Purpose: Live list of every entity of the collection.
  ///
  /// Return type: [Stream<List<T>>] — errors arrive as clean `Exception`s.
  Stream<List<T>> watchAll() => watchDocuments(
        () => remote.watchCollection(collectionPath),
      );

  /// Function Name: [watchDocuments]
  ///
  /// Purpose: Wrap any document stream: decode + clean errors. Resolving the
  /// path throws synchronously (no company / bad email), so [open] runs
  /// inside the try.
  ///
  /// Return type: [Stream<List<T>>]
  Stream<List<T>> watchDocuments(
    Stream<List<TimeTrackerDocument>> Function() open,
  ) {
    final Stream<List<TimeTrackerDocument>> stream;
    try {
      stream = open();
    } catch (error) {
      return Stream<List<T>>.error(clean(error, 'load the ${entityLabel}s'));
    }
    return stream
        .map((List<TimeTrackerDocument> docs) =>
            List<T>.unmodifiable(docs.where(isReadable).map(decode)))
        .handleError(
          (Object error) => throw clean(error, 'load the ${entityLabel}s'),
        );
  }

  /// Function Name: [fetchOne]
  ///
  /// Purpose: One entity by id, or null when missing.
  ///
  /// Return type: [Future<T?>]
  Future<T?> fetchOne(String id) async {
    try {
      final TimeTrackerDocument? doc = await remote.fetchDocument(collectionPath, id);
      return doc == null || !isReadable(doc) ? null : decode(doc);
    } catch (error) {
      throw clean(error, 'load the $entityLabel');
    }
  }

  /// Function Name: [write]
  ///
  /// Purpose: Validate, then append [entity] as the next history row.
  ///
  /// Parameters:
  ///   [T] entity
  ///   [String?] id: null = new auto id; else that document.
  ///   [bool] mustExist: an update — refuse to recreate a vanished doc.
  ///
  /// Return type: [Future<T>] — the stored entity.
  Future<T> write(T entity, {required String? id, required bool mustExist, NewDocId? newId}) async {
    validate(entity);
    final String actor = _actor();
    try {
      final TimeTrackerDocument doc = await remote.appendRow(
        relativePath: collectionPath,
        id: id,
        mustExist: mustExist,
        newId: newId,
        row: (String docId, Map<String, dynamic>? stored) {
          checkStored(entity, stored);
          return encode(
            entity,
            id: docId,
            audit: TimeTrackerAudit.next(stored, actor: actor, now: DateTime.now()),
          );
        },
      );
      return decode(doc);
    } catch (error) {
      throw clean(error, 'save the $entityLabel');
    }
  }

  /// Function Name: [createOnly]
  ///
  /// Purpose: Validate, then create document [id] with [entity] as its first
  /// row — skipped (false) when the document already exists. Added 8/10/2026
  /// for the absent-day sweep (owner decision 20).
  ///
  /// Return type: [Future<bool>] — true when created.
  Future<bool> createOnly(T entity, {required String id}) async {
    validate(entity);
    final String actor = _actor();
    try {
      return await remote.createIfAbsent(
        relativePath: collectionPath,
        id: id,
        row: (String docId, Map<String, dynamic>? stored) => encode(
          entity,
          id: docId,
          audit: TimeTrackerAudit.next(stored, actor: actor, now: DateTime.now()),
        ),
      );
    } catch (error) {
      throw clean(error, 'save the $entityLabel');
    }
  }

  /// Function Name: [requireId]
  ///
  /// Purpose: Refuse an update of an entity that was never saved.
  ///
  /// Return type: [String] — [id], throws `Exception` when empty.
  String requireId(String id) {
    if (id.trim().isEmpty) {
      throw Exception('This $entityLabel has no id, so it cannot be saved.');
    }
    return id;
  }

  /// Function Name: [keyOf]
  ///
  /// Purpose: Build a document id (e.g. from an email) — a bad key surfaces as
  /// a clean `Exception`, never a raw `StateError`.
  ///
  /// Return type: [String]
  String keyOf(String Function() build) {
    try {
      return build();
    } catch (error) {
      throw clean(error, 'resolve the $entityLabel');
    }
  }

  /// The signed-in e-mail every row is stamped with (throws when signed
  /// out). Public since 9/10/2026 for multi-document writes.
  String actor() => _actor();

  String _actor() {
    final String email = _access.currentUserEmail.trim().toLowerCase();
    if (email.isEmpty) {
      throw Exception('No signed-in user — cannot save the $entityLabel.');
    }
    return email;
  }

  /// Function Name: [clean]
  ///
  /// Purpose: A message-safe `Exception` for [error].
  ///
  /// Return type: [Exception]
  Exception clean(Object error, String action) {
    if (error is FirebaseException) {
      return Exception('Could not $action (${error.code}).');
    }
    if (error is StateError) return Exception(error.message);
    if (error is Exception) return error;
    return Exception('Could not $action: $error');
  }
}
