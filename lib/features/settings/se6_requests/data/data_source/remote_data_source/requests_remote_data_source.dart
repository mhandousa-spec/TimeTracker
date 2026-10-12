/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: requests_remote_data_source.dart
/// Purpose: Every Firestore call behind the change-request flow.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N01. Four reads and four writes were spread across
/// three pages and the GetX controller. They are collected here unchanged in
/// behaviour — same collections, same document shapes — so the pages can be
/// reduced to dispatching intents.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/models/change_request_mapper.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_field_mapping.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';

class RequestsRemoteDataSource {
  RequestsRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// The format the list screens render; kept alongside the server timestamp
  /// exactly as the submit page wrote it.
  static final DateFormat _displayFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  CollectionReference<Map<String, dynamic>> get _requests => _db
      .doc(RequestCollectionPaths.rolesDoc)
      .collection(RequestCollectionPaths.requestsCollection);

  /// Function Name: [readForEmployee]
  ///
  /// Purpose: Every request raised by one employee, newest first.
  Future<List<ChangeRequest>> readForEmployee(String employeeId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _requests
        .where(ChangeRequestMapper.keyEmployeeId, isEqualTo: employeeId)
        .orderBy(ChangeRequestMapper.keyRequestDate, descending: true)
        .get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            ChangeRequestMapper.fromDocument(doc.id, doc.data()))
        .toList();
  }

  /// Function Name: [read]
  ///
  /// Purpose: One request, or `null` when the document is gone.
  Future<ChangeRequest?> read(String requestId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _requests.doc(requestId).get();

    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return ChangeRequestMapper.fromDocument(doc.id, data);
  }

  /// Function Name: [employeeExists]
  ///
  /// Purpose: Whether the employee profile document is present.
  Future<bool> employeeExists(String employeeId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db
        .doc(RequestCollectionPaths.employeeDoc(employeeId))
        .get();
    return doc.exists;
  }

  /// Function Name: [create]
  ///
  /// Purpose: Write one request document with an auto-generated id.
  Future<void> create(ChangeRequest request) {
    return _requests.doc().set(
          ChangeRequestMapper.toSubmission(
            request,
            formattedDate: _displayFormat.format(DateTime.now()),
          ),
        );
  }

  /// Function Name: [updateStatus]
  ///
  /// Purpose: Move a request to a new status.
  ///
  /// [reason] (ADDED 30/9/2026, Role QA p.34): the reviewer's reason for the
  /// decision — approval or rejection. Stored on the request when given.
  Future<void> updateStatus(String requestId, RequestStatus status,
      {String reason = ''}) {
    return _requests.doc(requestId).update(<String, dynamic>{
      ChangeRequestMapper.keyStatus: status.wireValue,
      ChangeRequestMapper.keyUpdatedAt: FieldValue.serverTimestamp(),
      if (reason.trim().isNotEmpty)
        ChangeRequestMapper.keyDecisionReason: reason.trim(),
    });
  }

  /// Function Name: [applyChangesToEmployee]
  ///
  /// Purpose: Append every approved change to the employee's history document.
  ///
  /// Throws [StateError] when the employee document is missing — the caller
  /// converts that into a [Failure] rather than marking the request approved.
  ///
  /// FIXED 13/8/2026: this looped straight into `updateFieldSynchronized` for
  /// every change. That method ends in `default: throw ArgumentError`, and it
  /// rejects `mobilePhone` unless the value is a `MobilePhone` instance — a
  /// request only ever carries strings. So a request touching the phone, the
  /// country code, or any emergency-contact field threw on the first such
  /// entry, the loop died, and *no* field was written, including the ones that
  /// mapped correctly. Two changes: phone members are folded into a rebuilt
  /// `MobilePhone`, and an unwritable field is now skipped and reported rather
  /// than discarding the rest of the batch.
  ///
  /// Returns the request field names that could not be applied. An empty list
  /// means everything was written.
  Future<List<String>> applyChangesToEmployee({
    required String employeeId,
    required List<FieldChange> changes,
  }) async {
    final DocumentReference<Map<String, dynamic>> employeeRef =
        _db.doc(RequestCollectionPaths.employeeDoc(employeeId));

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await employeeRef.get();
    if (!snapshot.exists) {
      throw StateError('Employee document not found for id $employeeId');
    }

    // CHANGED 9/10/2026 — the append loop moved, unchanged, into the pure
    // [applyChangesToHistory] so the Health / Emergency-contact approval can
    // be unit-tested without Firestore. This method still reads, applies and
    // writes exactly as before.
    final ({NewEmployeeModelHistory history, List<String> skipped}) applied =
        applyChangesToHistory(
      NewEmployeeModelHistory.fromMap(snapshot.data()),
      changes,
    );

    await employeeRef.update(applied.history.toMap());

    return applied.skipped;
  }

  /// Function Name: [applyChangesToHistory]
  ///
  /// Purpose: Append every approved change to an employee history — the pure
  ///          half of [applyChangesToEmployee] (ADDED 9/10/2026).
  ///
  /// Each change goes through `updateFieldSynchronized`, the Employees_Info
  /// append helper: ONE new revision per change, i.e. one new entry in
  /// `timestamps` and one in EVERY synchronized field list (the new value for
  /// the changed field, the last value repeated for the rest). The current
  /// value of every field is therefore its last element, and the lists stay
  /// as long as `timestamps`.
  ///
  /// Parameters:
  /// - [history]: the employee document as read.
  /// - [changes]: the request's field changes.
  ///
  /// Returns: the appended history, and the request field names that could
  ///          not be applied (empty when everything was written).
  static ({NewEmployeeModelHistory history, List<String> skipped})
      applyChangesToHistory(
    NewEmployeeModelHistory history,
    List<FieldChange> changes,
  ) {
    final List<String> skipped = <String>[];

    // Phone members are collected first: `phones`, `countryCode` and
    // `countryApp` are three entries in the request but one object on the
    // model, so they have to be merged before a single write.
    final Map<String, String> phoneMembers = <String, String>{};

    for (final FieldChange change in changes) {
      final String modelField =
          RequestFieldMapping.toModelField(change.fieldName);

      if (RequestFieldMapping.isMobilePhoneField(modelField)) {
        phoneMembers[RequestFieldMapping.mobilePhoneMember(modelField)] =
            change.newValue;
        continue;
      }

      if (!RequestFieldMapping.isKnown(change.fieldName)) {
        skipped.add(change.fieldName);
        continue;
      }

      try {
        history = history.updateFieldSynchronized(modelField, change.newValue);
      } on ArgumentError {
        // The model refused the value (wrong runtime type for this field).
        // One bad entry must not cost the caller the other changes.
        skipped.add(change.fieldName);
      }
    }

    if (phoneMembers.isNotEmpty) {
      history = history.updateFieldSynchronized(
        'mobilePhone',
        _mergedMobilePhone(history, phoneMembers),
      );
    }

    // 9/10/2026: the write moved back into [applyChangesToEmployee].
    return (history: history, skipped: skipped);
  }

  /// Function Name: [_mergedMobilePhone]
  ///
  /// Purpose: Build the `MobilePhone` an approval should store, keeping the
  ///          members the request did not touch.
  ///
  /// The model holds each member as a history list; only the newest entry is
  /// displayed, so a change appends rather than replaces. Mirrors
  /// `_updateMobilePhoneField` in the user-management approval screen, which is
  /// the only other place that writes this object correctly.
  ///
  /// `static` since 9/10/2026 (it never used instance state) so the pure
  /// [applyChangesToHistory] can call it.
  static MobilePhone _mergedMobilePhone(
    NewEmployeeModelHistory history,
    Map<String, String> members,
  ) {
    final MobilePhone current = history.mobilePhone.isNotEmpty
        ? history.mobilePhone.last
        : MobilePhone();

    List<String> appended(List<String>? existing, String? value) {
      final List<String> next = List<String>.of(existing ?? const <String>[]);
      if (value != null) next.add(value);
      return next;
    }

    return MobilePhone(
      phones: appended(current.phones, members['phones']),
      countryCode: appended(current.countryCode, members['countryCode']),
      countryApp: appended(current.countryApp, members['countryApp']),
      timestamps: List<Timestamp>.of(current.timestamps ?? const <Timestamp>[])
        ..add(Timestamp.now()),
    );
  }
}
