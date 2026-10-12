/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_calendar_events.dart
/// Module:    Time Tracker & Attendance
/// Purpose: Every calendar entry the Time Tracker module can place on the
///          calendar.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 6 (brief §B), same shape as `todo_calendar_events.dart`.
/// `TimeTrackerCalendarSource.entries` builds every card from these through
/// `CalendarEventModel.fromType`:
///   * the employee's OWN approved leaves (every day covered), pending
///     requests (marked pending), transactions (pending / approved, on the
///     corrected day), late and absent days (from Attendance);
///   * for an approver: the requests whose current step waits for them, on
///     every requested day.
///
/// ⚠️ NO `{{requestType}}` IN THE TITLES. The record's name (the request
/// type, or "Requester · Type" for an approval) is the card's `taskName`;
/// only the late card carries `{{minutes}}`.
///
/// Status codes reuse chips that already exist on the calendar screen —
/// 'Scheduled' (approved leave = a planned day off) and 'Pending Approval'
/// (waiting for a decision). Late / Absent / Attendance Corrected have no
/// chip of their own (status = the English title); they are reached through
/// "All" and the "Time Tracker & Attendance" module chip. Colour = the Time
/// Tracker entry of `CalendarModulePalette` (0xFFFF814A).

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum TimeTrackerCalendarEvent implements CalendarEventType {
  leaveApproved(
    key: 'leave_approved',
    scope: 'Requests',
    trigger: 'Leave Request Approved',
    titleEn: 'Approved Leave',
    titleAr: 'إجازة معتمدة',
    descriptionEn:
        'Your leave request covering this day has been approved. Attendance is not required on this day.',
    descriptionAr: 'تمت الموافقة على طلب الإجازة الذي يشمل هذا اليوم. لا يلزم تسجيل الحضور في هذا اليوم.',
    statusCode: 'Scheduled',
    variables: <TemplateVariable>{},
    schedulingNote:
        'One entry per day from the start to the end date of the employee\'s own approved leave request (approved, or approved and under a cancellation review), clamped to the loaded window. Transactions are not leave.',
  ),

  requestPending(
    key: 'request_pending',
    scope: 'Requests',
    trigger: 'Leave Request Pending',
    titleEn: 'Request Pending Approval',
    titleAr: 'طلب بانتظار الموافقة',
    descriptionEn: 'Your request covering this day is awaiting a decision from your approvers.',
    descriptionAr: 'طلبك الذي يشمل هذا اليوم بانتظار قرار جهة الاعتماد.',
    statusCode: 'Pending Approval',
    variables: <TemplateVariable>{},
    schedulingNote:
        'One entry per day of the employee\'s own pending (or under review) leave request, clamped to the loaded window. Removed once the request is decided or canceled.',
  ),

  transactionPending(
    key: 'transaction_pending',
    scope: 'Attendance',
    trigger: 'Attendance Correction Submitted',
    titleEn: 'Attendance Correction Pending',
    titleAr: 'تصحيح حضور بانتظار الموافقة',
    descriptionEn: 'Your attendance correction for this day is awaiting a decision from your approvers.',
    descriptionAr: 'طلب تصحيح الحضور لهذا اليوم بانتظار قرار جهة الاعتماد.',
    statusCode: 'Pending Approval',
    variables: <TemplateVariable>{},
    schedulingNote: 'On the corrected (check-in) day of the employee\'s own pending transaction, at the requested check-in time.',
  ),

  transactionApproved(
    key: 'transaction_approved',
    scope: 'Attendance',
    trigger: 'Attendance Correction Approved',
    titleEn: 'Attendance Corrected',
    titleAr: 'تم تصحيح الحضور',
    descriptionEn: 'Your attendance correction for this day has been approved and applied to your attendance record.',
    descriptionAr: 'تمت الموافقة على تصحيح الحضور لهذا اليوم وتطبيقه على سجل حضورك.',
    statusCode: '',
    variables: <TemplateVariable>{},
    schedulingNote: 'On the corrected (check-in) day of the employee\'s own approved transaction, at the corrected check-in time.',
  ),

  lateArrival(
    key: 'late_arrival',
    scope: 'Attendance',
    trigger: 'Late Attendance Recorded',
    titleEn: 'Late Arrival',
    titleAr: 'تأخر في الحضور',
    descriptionEn: 'You checked in {{minutes}} minutes after the start of your shift on this day.',
    descriptionAr: 'سجلت حضورك بعد {{minutes}} دقيقة من بداية ورديتك في هذا اليوم.',
    statusCode: '',
    variables: <TemplateVariable>{TemplateVariable.minutes},
    schedulingNote: 'On every attendance day of the employee stored as late, at the first check-in time.',
  ),

  absentDay(
    key: 'absent_day',
    scope: 'Attendance',
    trigger: 'Absence Recorded',
    titleEn: 'Absent',
    titleAr: 'غياب',
    descriptionEn:
        'No attendance was recorded for this working day. If this is incorrect, please submit an attendance correction request.',
    descriptionAr: 'لم يتم تسجيل أي حضور في يوم العمل هذا. إذا كان ذلك غير صحيح يرجى تقديم طلب تصحيح حضور.',
    statusCode: '',
    variables: <TemplateVariable>{},
    schedulingNote: 'On every attendance day of the employee stored as absent (written by the absent-day sweep).',
  ),

  approvalPending(
    key: 'approval_pending',
    scope: 'Approvals',
    trigger: 'Request Awaiting Your Approval',
    titleEn: 'Awaiting Your Approval',
    titleAr: 'بانتظار موافقتك',
    descriptionEn: 'A request covering this day is awaiting your decision. Please review it at your earliest convenience.',
    descriptionAr: 'يوجد طلب يشمل هذا اليوم بانتظار قرارك. يرجى مراجعته في أقرب وقت.',
    statusCode: 'Pending Approval',
    variables: <TemplateVariable>{},
    schedulingNote:
        'For an approver: one entry per requested day of every request whose CURRENT step waits for them (ApprovalService.mayDecide), clamped to the loaded window.',
  );

  const TimeTrackerCalendarEvent({
    required this.key,
    required this.scope,
    required this.trigger,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.statusCode,
    required this.variables,
    required this.schedulingNote,
  });

  @override
  final String key;
  @override
  final String scope;
  @override
  final String trigger;
  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String descriptionEn;
  @override
  final String descriptionAr;
  @override
  final String statusCode;
  @override
  final Set<TemplateVariable> variables;
  @override
  final String schedulingNote;

  /// `CalendarModulePalette.timeTracker`.
  @override
  int get colorValue => 0xFFFF814A;

  @override
  int get reminderOffsetDays => 0;

  @override
  AppModule get module => AppModule.timeTracker;

  /// `<module>_<key>` — see [CalendarEventType.id].
  @override
  String get id => '${module.key}_$key';

  /// The card opens an attendance DAY (Attendance tab filtered to it), not
  /// a request.
  bool get opensAttendanceDay =>
      this == TimeTrackerCalendarEvent.lateArrival || this == TimeTrackerCalendarEvent.absentDay;

  /// Function Name: [fromKey]
  ///
  /// Purpose: Resolve a stored key back to its enum value.
  ///
  /// Return type: [TimeTrackerCalendarEvent?]
  static TimeTrackerCalendarEvent? fromKey(String key) {
    for (final TimeTrackerCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
