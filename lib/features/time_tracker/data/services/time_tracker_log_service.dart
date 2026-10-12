/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_log_service.dart
/// Purpose: Declares `TimeTrackerLogService` — writes Time Tracker actions to
///          System Logs.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Actions (phase-1 brief, 8/10/2026): Check In · Check Out · Pause ·
/// Resume · Create Request · Cancel Request · Approve · Reject · Cancel After
/// Approving · Create / Edit / Status / Remove Request Type · Create / Edit /
/// Status / Delete Location · Assign / Reassign / Remove Employee · Create /
/// Edit / Delete Group · Edit Vacation Balance · (8/10/2026, phase 2)
/// Create / Cancel Attendance Transaction. Same pattern as
/// `TodoLogService` (injectable, lower-case action strings).
/// Updated: 9/10/2026 - phase 4: + Request Cancellation · Approve / Reject
/// Cancellation · Send Reminder (every state change of a request is logged).
///
/// `SystemLogsController.systemLogsAction` is documented fire-and-forget and
/// never throws, so no try/catch is needed here.

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

class TimeTrackerLogService {
  const TimeTrackerLogService();

  static const String actionCheckIn = 'check in';
  static const String actionCheckOut = 'check out';
  static const String actionPause = 'pause attendance';
  static const String actionResume = 'resume attendance';
  static const String actionCreateRequest = 'create time tracker request';
  static const String actionCancelRequest = 'cancel time tracker request';
  static const String actionApprove = 'approve time tracker request';
  static const String actionReject = 'reject time tracker request';
  static const String actionCancelAfterApproving =
      'cancel time tracker request after approving';
  static const String actionCreateRequestType = 'create request type';
  static const String actionEditRequestType = 'edit request type';
  static const String actionChangeRequestTypeStatus =
      'change request type status';
  static const String actionRemoveRequestType = 'remove request type';
  static const String actionCreateLocation = 'create location';
  static const String actionEditLocation = 'edit location';
  static const String actionChangeLocationStatus = 'change location status';
  static const String actionDeleteLocation = 'delete location';
  static const String actionAssignEmployee = 'assign employee location';
  static const String actionReassignEmployee = 'reassign employee location';
  static const String actionRemoveEmployee = 'remove employee assignment';
  static const String actionCreateGroup = 'create time tracker group';
  static const String actionEditGroup = 'edit time tracker group';
  static const String actionDeleteGroup = 'delete time tracker group';
  static const String actionEditVacationBalance = 'edit vacation balance';
  static const String actionCreateTransaction = 'create attendance transaction';
  static const String actionCancelTransaction = 'cancel attendance transaction';
  static const String actionRequestCancellation = 'request time tracker cancellation';
  static const String actionApproveCancellation = 'approve time tracker cancellation';
  static const String actionRejectCancellation = 'reject time tracker cancellation';
  static const String actionSendReminder = 'send time tracker request reminder';

  /// Every action, for tests and the admin's log filter.
  static const List<String> allActions = <String>[
    actionCheckIn,
    actionCheckOut,
    actionPause,
    actionResume,
    actionCreateRequest,
    actionCancelRequest,
    actionApprove,
    actionReject,
    actionCancelAfterApproving,
    actionCreateRequestType,
    actionEditRequestType,
    actionChangeRequestTypeStatus,
    actionRemoveRequestType,
    actionCreateLocation,
    actionEditLocation,
    actionChangeLocationStatus,
    actionDeleteLocation,
    actionAssignEmployee,
    actionReassignEmployee,
    actionRemoveEmployee,
    actionCreateGroup,
    actionEditGroup,
    actionDeleteGroup,
    actionEditVacationBalance,
    actionCreateTransaction,
    actionCancelTransaction,
    actionRequestCancellation,
    actionApproveCancellation,
    actionRejectCancellation,
    actionSendReminder,
  ];

  /// Function Name: [log]
  ///
  /// Purpose: Record one Time Tracker activity under `Modules.timeTracker`.
  ///
  /// Parameters:
  ///   [String] action: one of the `action…` constants above.
  ///
  /// Return type: [void] — fire-and-forget.
  void log(String action) {
    AppControllers.systemLogs.systemLogsAction(
      action,
      module: Modules.timeTracker,
    );
  }
}
