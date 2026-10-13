/// Module: time_tracker / domain / constants
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_firestore_paths.dart
/// Purpose: Declares `TimeTrackerFirestorePaths` — every collection path the
///          Time Tracker module reads or writes, relative to the company root.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
/// Updated: 9/10/2026 - phase 3: group pictures (`Group_Images` folder).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): `Vacation_Balances` is
/// ONE document per employee per year ([vacationBalanceDocId] =
/// `{email}_{year}`) and request comments live in the sub-collection
/// `Requests/{requestId}/Comments/{commentId}` ([requestComments]).
///
/// All paths go through `getBaseUrl(...)` in the data sources, i.e.
/// `Demo/{companyId}/<path>` — and the data sources refuse to resolve them
/// while `ApiConstants.baseUri` is empty (same guard as To-Do).
///
/// LAYOUT (owner decision 16, 8/10/2026 — FINAL SPEC §2): one collection per
/// feature under the module document, so the Firebase console shows
/// Modules → time_tracker → Attendance / Requests / …:
///
///   Demo/{cid}/Modules/time_tracker                         (a REAL document)
///     Attendance/{email}_{yyyy-MM-dd}
///     Requests/{autoId}            (leave requests AND transactions)
///       Comments/{commentId}       (one document per comment, 9/10/2026)
///     Request_Types/{autoId}
///     Locations/{autoId}           (no-HR companies)
///     Location_Assignments/{email} (no-HR companies)
///     Groups/{autoId}
///     Vacation_Balances/{email}_{year}  (one per employee per year, 9/10/2026)
///     Notification_Log/{refId}__{event}__{ms}
///
/// With HR the module READS `Modules/hr/Shifts`, `Modules/hr/Shift_Assignments`
/// and `Modules/hr/Locations` (names from `HrApiConstants`).
///
/// Every document is an "indexed history" document: every field is a list
/// and the doc carries `timestamps` (`Timestamp`s) — see
/// `TimeTrackerHistoryCodec`. Emails are trimmed + lower-cased ([emailKey]).

import 'package:knowticed_plus/core/helper/hr/hr_api_constants.dart';

class TimeTrackerFirestorePaths {
  const TimeTrackerFirestorePaths._();

  /// The licence / role-module key (`Demo_Permissions/{cid}.time_tracker`,
  /// the role's `Current_Selected_Modules`).
  static const String moduleKey = 'time_tracker';

  /// The module document. Must exist as a real document (written `{}` with
  /// merge once if missing) so the console lists its collections.
  static const String root = 'Modules/time_tracker';

  static const String attendance = '$root/Attendance';
  static const String requests = '$root/Requests';
  static const String requestTypes = '$root/Request_Types';
  static const String locations = '$root/Locations';
  static const String locationAssignments = '$root/Location_Assignments';
  static const String groups = '$root/Groups';
  static const String vacationBalances = '$root/Vacation_Balances';
  static const String notificationLog = '$root/Notification_Log';

  /// ADDED 13/10/2026 (owner decision 48): one counter document per id
  /// series (`REQ-2026`, `TRX-2026`, `LOC`, `GRP`, `RQT`, `CMT__{request}`)
  /// holding `Last_Number`.
  static const String counters = '$root/Counters';

  /// Firebase STORAGE folder (not Firestore) for request / transaction
  /// attachments: `Demo/{cid}/Modules/time_tracker/Request_Attachments/
  /// {email}/{ms}_{file}`. Added 8/10/2026 (phase 2).
  static const String requestAttachmentsStorage = '$root/Request_Attachments';

  /// Storage folder of group pictures (phase 3, 9/10/2026).
  static const String groupImagesStorage = '$root/Group_Images';

  /// HR-owned set-up data, read when the company has the HR module.
  static const String hrShifts =
      '${HrApiConstants.hrModulePath}/${HrApiConstants.shiftsCollection}';
  static const String hrShiftAssignments =
      '${HrApiConstants.hrModulePath}/${HrApiConstants.shiftAssignmentsCollection}';
  static const String hrLocations =
      '${HrApiConstants.hrModulePath}/${HrApiConstants.locationsCollection}';

  /// `Demo/{companyId}/time_tracker_module_permissions/{roleId}` — the role
  /// grants. Must match the admin app's `<module>_module_permissions` naming.
  static const String rolePermissions = 'time_tracker_module_permissions';

  /// Function Name: [emailKey]
  ///
  /// Purpose: The key for [email] — trimmed and lower-cased. Refuses an empty
  /// email (or one containing `/`, which would split the path), so a write can
  /// never land on an unscoped document.
  ///
  /// Parameters:
  ///   [String] email
  ///
  /// Return type: [String] — throws `StateError` on a bad email.
  static String emailKey(String email) {
    final String key = email.trim().toLowerCase();
    if (key.isEmpty) {
      throw StateError(
        'No email — the Time Tracker document path cannot be resolved.',
      );
    }
    if (key.contains('/')) {
      throw StateError('Invalid email for a Time Tracker path: "$key".');
    }
    return key;
  }

  /// Function Name: [dateKey]
  ///
  /// Purpose: `yyyy-MM-dd` of [date] (local calendar day).
  ///
  /// Parameters:
  ///   [DateTime] date
  ///
  /// Return type: [String]
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Function Name: [attendanceDocId]
  ///
  /// Purpose: `{email}_{yyyy-MM-dd}` — one attendance document per employee
  /// per day.
  ///
  /// Parameters:
  ///   [String] email: see [emailKey].
  ///   [DateTime] date: the calendar day.
  ///
  /// Return type: [String] — throws `StateError` on a bad email.
  static String attendanceDocId(String email, DateTime date) =>
      '${emailKey(email)}_${dateKey(date)}';

  /// Function Name: [attendancePrefix]
  ///
  /// Purpose: `{email}_` — the id prefix shared by every attendance document
  /// of one employee (used for a document-id range query).
  ///
  /// Parameters:
  ///   [String] email
  ///
  /// Return type: [String]
  static String attendancePrefix(String email) => '${emailKey(email)}_';

  /// Function Name: [vacationBalanceDocId]
  ///
  /// Purpose: ADDED 9/10/2026 (data model, owner) — `{email}_{year}`: one
  /// vacation balance document per employee per calendar year. A new year
  /// is a new document (no roll-over inside a document).
  ///
  /// Parameters:
  ///   [String] email: see [emailKey].
  ///   [int] year: the balance year (four digits).
  ///
  /// Return type: [String] — throws `StateError` on a bad email or year.
  static String vacationBalanceDocId(String email, int year) {
    if (year < 1000 || year > 9999) {
      throw StateError('Invalid vacation balance year: $year.');
    }
    return '${emailKey(email)}_$year';
  }

  /// Function Name: [requestComments]
  ///
  /// Purpose: ADDED 9/10/2026 (data model, owner) — the Comments
  /// sub-collection of request [requestId]
  /// (`Requests/{requestId}/Comments`, one document per comment).
  ///
  /// Parameters:
  ///   [String] requestId
  ///
  /// Return type: [String] — throws `StateError` on an empty id or one
  /// containing `/` (which would change the path depth).
  static String requestComments(String requestId) {
    final String id = requestId.trim();
    if (id.isEmpty || id.contains('/')) {
      throw StateError('Invalid request id for the comments path: "$requestId".');
    }
    return '$requests/$id/Comments';
  }

  /// Function Name: [notificationLogDocId]
  ///
  /// Purpose: `{requestOrDayId}__{event}__{ms}` — one marker per notification
  /// already sent (same dedupe scheme as To-Do).
  ///
  /// Parameters:
  ///   [String] refId: the request id or attendance day id.
  ///   [String] eventKey: the notification event key.
  ///   [int] millis: the due time the event belongs to.
  ///
  /// Return type: [String]
  static String notificationLogDocId(
    String refId,
    String eventKey,
    int millis,
  ) =>
      '${refId}__${eventKey}__$millis';
}
