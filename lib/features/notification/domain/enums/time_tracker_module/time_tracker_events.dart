/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_events.dart
/// Purpose: Notification event catalog: time tracker events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
/// Updated: 9/10/2026 - Time Tracker phase 4: + [requestCanceled] (an
///          approved request canceled — by HR, or the employee's
///          cancellation accepted). None of the 15 events said "canceled";
///          same formal style as the catalogue.
/// Updated: 9/10/2026 - Time Tracker phase 6: + [missedCheckOut] (the
///          "forgot to check out" reminder of the client sweep).
/// Updated: 9/10/2026 - Time Tracker QA KP-TT-011: [pendingApprovalsManager]
///          singular / plural ({{countedRequests}}) + [supersededBodies].

/// ************************* FILE INFO *************************
/// File Name: time_tracker_events.dart
/// Module:    Time Tracker & Attendance
/// Purpose:   Every notification this module can raise, with its default
///            bilingual title/body exactly as specified in
///            "Knowticed Plus — Notification & Validation".
///
/// The enum is the DEFAULT / RESET source only. At runtime
/// AppNotificationSender reads `notification_templates/<module>_<key>`
/// from Firestore first, so any text an admin edits in Notification
/// Control still wins. Editing this file changes the fallback + the
/// "Reset to default" value.
///
/// RULE: never write an event key as a raw string. Use this enum.

import '../notification_event.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

enum TimeTrackerNotificationEvent implements NotificationEvent {
  breakCompleted(
    key: 'break_completed',
    group: '',
    titleEn: 'Break Period Concluded',
    titleAr: 'انتهاء فترة الاستراحة',
    bodyEn: 'Your designated break period ended at {{time}}. Regular working hours have resumed. Please ensure full compliance with the applicable time and attendance policy.',
    bodyAr: 'انتهت فترة استراحتك المحددة في {{time}}. استُؤنفت ساعات العمل الاعتيادية. يرجى الالتزام الكامل بسياسة الوقت والحضور المعتمدة.',
    variables: {TemplateVariable.time},
  ),
  breakDurationExceeded(
    key: 'break_duration_exceeded',
    group: '',
    titleEn: 'Authorised Break Duration Exceeded',
    titleAr: 'تجاوز المدة المسموح بها للاستراحة',
    bodyEn: 'Your break has exceeded the permitted duration as defined by the organisational break policy. Please adhere to the approved break schedule to avoid policy non-compliance.',
    bodyAr: 'تجاوزت استراحتك المدة المسموح بها وفقاً لسياسة الاستراحات التنظيمية. يرجى الالتزام بجدول الاستراحات المعتمد لتجنب مخالفة السياسة.',
    variables: const {},
  ),
  lateArrivalRecorded(
    key: 'late_arrival_recorded',
    group: '',
    titleEn: 'Late Attendance Recorded',
    titleAr: 'تم تسجيل تأخر في الحضور',
    bodyEn: 'Your attendance record indicates that you checked in {{minutes}} minutes after your scheduled shift commencement time. This has been logged in the attendance system for review.',
    bodyAr: 'تشير سجلات حضورك إلى أنك سجّلت حضورك بعد {{minutes}} دقيقة من الوقت المحدد لبدء وردية عملك. تم توثيق ذلك في نظام الحضور للمراجعة.',
    variables: {TemplateVariable.minutes},
  ),
  shiftUpdated(
    key: 'shift_updated',
    group: '',
    titleEn: 'Shift Schedule Updated',
    titleAr: 'تم تحديث جدول الوردية',
    bodyEn: 'Your shift schedule has been revised. Please review the updated shift details in the system to ensure compliance with the new assigned working hours.',
    bodyAr: 'تم تعديل جدول وردية عملك. يرجى مراجعة تفاصيل الوردية المحدّثة في النظام لضمان الالتزام بساعات العمل الجديدة المحددة لك.',
    variables: const {},
  ),
  workLocationUpdatedSelf(
    key: 'work_location_updated_self',
    group: '',
    titleEn: 'Assigned Work Location Updated',
    titleAr: 'تم تحديث موقع العمل المعين لك',
    bodyEn: 'Your assigned work location has been updated. Please review the revised location details in the system and ensure compliance with the updated assignment.',
    bodyAr: 'تم تحديث موقع عملك المعين. يرجى مراجعة تفاصيل الموقع المحدّثة في النظام والالتزام بالتعيين الجديد.',
    variables: const {},
  ),
  workLocationUpdatedManagement(
    key: 'work_location_updated_management',
    group: '',
    titleEn: 'Work Location Revised by Management',
    titleAr: 'تم تعديل موقع العمل من قِبَل الإدارة',
    bodyEn: 'Your work location assignment has been updated by management. This change is effective immediately. Please ensure full compliance with the new work location requirements.',
    bodyAr: 'تم تعديل تعيين موقع عملك من قِبَل الإدارة. يسري هذا التغيير بشكل فوري. يرجى الالتزام الكامل بمتطلبات موقع العمل الجديد.',
    variables: const {},
  ),
  automaticCheckOutApplied(
    key: 'automatic_check_out_applied',
    group: '',
    titleEn: 'Automatic Check-Out Recorded',
    titleAr: 'تم تسجيل خروج تلقائي',
    bodyEn: 'An automatic check-out has been applied to your attendance record upon completion of your scheduled shift or in accordance with applicable system policy. No further action is required.',
    bodyAr: 'تم تطبيق تسجيل خروج تلقائي على سجل حضورك عند انتهاء وردية عملك المجدولة أو وفقاً لسياسة النظام المعمول بها. لا يُستلزم اتخاذ أي إجراء إضافي.',
    variables: const {},
  ),
  requestApprovedAttendanceLeave(
    key: 'request_approved_attendance_leave',
    group: '',
    titleEn: 'Request Approved',
    titleAr: 'تمت الموافقة على الطلب',
    bodyEn: 'Your {{requestType}} request has been reviewed and formally approved. The relevant adjustment will be reflected in your attendance record accordingly.',
    bodyAr: 'تمت مراجعة طلب {{requestType}} المقدم منك والموافقة عليه رسمياً. سينعكس التعديل المعني على سجل حضورك وفقاً لذلك.',
    variables: {TemplateVariable.requestType},
  ),
  requestRejected(
    key: 'request_rejected',
    group: '',
    titleEn: 'Request Declined',
    titleAr: 'تم رفض الطلب',
    bodyEn: 'Your {{requestType}} request has been reviewed and declined. Please refer to the decision remarks for further information or consult your direct manager for clarification.',
    bodyAr: 'تمت مراجعة طلب {{requestType}} المقدم منك ورفضه. يرجى الرجوع إلى ملاحظات القرار للاطلاع على مزيد من المعلومات أو التواصل مع مديرك المباشر للاستيضاح.',
    variables: {TemplateVariable.requestType},
  ),
  attendanceCorrectionApproved(
    key: 'attendance_correction_approved',
    group: '',
    titleEn: 'Attendance Correction Request Approved',
    titleAr: 'تمت الموافقة على طلب تصحيح الحضور',
    bodyEn: 'Your attendance correction request has been reviewed and formally approved. The correction has been applied to your attendance record with immediate effect.',
    bodyAr: 'تمت مراجعة طلب تصحيح الحضور المقدم منك والموافقة عليه رسمياً. تم تطبيق التصحيح على سجل حضورك بشكل فوري.',
    variables: const {},
  ),
  attendanceCorrectionRejected(
    key: 'attendance_correction_rejected',
    group: '',
    titleEn: 'Attendance Correction Request Declined',
    titleAr: 'تم رفض طلب تصحيح الحضور',
    bodyEn: 'Your attendance correction request has been reviewed and declined. Please resubmit with the appropriate supporting documentation if you believe the correction is warranted.',
    bodyAr: 'تمت مراجعة طلب تصحيح الحضور المقدم منك ورفضه. يرجى إعادة تقديمه مع المستندات الداعمة المناسبة إذا كنت ترى أن التصحيح ضروري.',
    variables: const {},
  ),
  vacationEntitlementExhausted(
    key: 'vacation_entitlement_exhausted',
    group: '',
    titleEn: 'Annual Leave Entitlement Fully Utilised',
    titleAr: 'استنفاد رصيد الإجازة السنوية',
    bodyEn: 'You have reached the maximum permitted number of annual leave days for the current entitlement period. Any further leave requests will be subject to HR review and approval.',
    bodyAr: 'لقد استنفدت الحد الأقصى المسموح به من أيام الإجازة السنوية للفترة الاستحقاقية الحالية. ستخضع طلبات الإجازة الإضافية لمراجعة وموافقة إدارة الموارد البشرية.',
    variables: const {},
  ),
  // CHANGED 9/10/2026 (Time Tracker QA KP-TT-011): "1 requests" / "1
  // طلبات" — the body now uses {{countedRequests}} (the number with its
  // noun in correct grammar, both languages) and wording that fits one or
  // many. The old default is in [supersededBodies]: a stored template that
  // still holds it is read with this text instead.
  pendingApprovalsManager(
    key: 'pending_approvals_manager',
    group: '',
    titleEn: 'Action Required — Pending Approval Requests',
    titleAr: 'مطلوب إجراء — طلبات بانتظار الموافقة',
    bodyEn: 'You currently have {{countedRequests}} pending your review and formal decision. Please take action at your earliest convenience to avoid delays in the approval workflow.',
    bodyAr: 'لديك حالياً {{countedRequests}} بانتظار مراجعتك وقرارك الرسمي. يرجى اتخاذ الإجراء في أقرب وقت لتفادي التأخير في سير عمل الموافقة.',
    variables: {TemplateVariable.count, TemplateVariable.countedRequests},
  ),
  breakPolicyViolationManagerHr(
    key: 'break_policy_violation_manager_hr',
    group: '',
    titleEn: 'Break Policy Non-Compliance Detected',
    titleAr: 'تم رصد عدم امتثال لسياسة الاستراحات',
    bodyEn: 'A break policy non-compliance incident has been identified and requires review. Please assess the matter and take corrective action to ensure adherence to the organisation\'s break policy.',
    bodyAr: 'تم تحديد حادثة عدم امتثال لسياسة الاستراحات وتستوجب المراجعة. يرجى تقييم الأمر واتخاذ الإجراء التصحيحي لضمان الالتزام بسياسة الاستراحات التنظيمية.',
    variables: const {},
  ),
  requestCanceled(
    key: 'request_canceled',
    group: '',
    titleEn: 'Request Canceled',
    titleAr: 'تم إلغاء الطلب',
    bodyEn: 'Your {{requestType}} request has been canceled. Please refer to the cancellation remarks for further information.',
    bodyAr: 'تم إلغاء طلب {{requestType}} المقدم منك. يرجى الرجوع إلى ملاحظات الإلغاء للاطلاع على مزيد من المعلومات.',
    variables: {TemplateVariable.requestType},
  ),
  missedCheckIn(
    key: 'missed_check_in',
    group: '',
    titleEn: 'Check-In Not Recorded',
    titleAr: 'لم يتم تسجيل الحضور',
    bodyEn: 'No attendance check-in was recorded for your scheduled shift. If this was due to a valid reason, please submit an attendance correction request with the appropriate supporting documentation.',
    bodyAr: 'لم يتم تسجيل أي حضور لوردية عملك المجدولة. إذا كان ذلك لسبب مشروع يرجى تقديم طلب تصحيح حضور مع المستندات الداعمة المناسبة.',
    variables: const {},
  ),
  // ADDED 9/10/2026 — Time Tracker phase 6: the "forgot to check out"
  // reminder (sent once by the client sweep, 30 minutes after the shift end).
  // None of the 16 events covered it; same formal style as the catalogue.
  missedCheckOut(
    key: 'missed_check_out',
    group: '',
    titleEn: 'Check-Out Not Recorded',
    titleAr: 'لم يتم تسجيل الانصراف',
    bodyEn: '30 minutes have passed since the end of your scheduled shift and no check-out has been recorded. Please record your check-out, or submit an attendance correction request if you have already left.',
    bodyAr: 'مرت 30 دقيقة على انتهاء ورديتك المجدولة ولم يتم تسجيل انصرافك بعد. يرجى تسجيل الانصراف، أو تقديم طلب تصحيح حضور إذا كنت قد غادرت بالفعل.',
    variables: {},
  );

  const TimeTrackerNotificationEvent({
    required this.key,
    required this.group,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.variables,
  });

  @override
  final String key;

  /// Sub-section this event belongs to inside the module (may be empty).
  @override
  final String group;

  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String bodyEn;
  @override
  final String bodyAr;
  @override
  final Set<TemplateVariable> variables;

  @override
  AppModule get module => AppModule.timeTracker;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static TimeTrackerNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }

  /// ADDED 9/10/2026 (QA KP-TT-011): earlier DEFAULT bodies (EN, AR) this
  /// catalogue replaced, by event key. A stored template whose body is still
  /// exactly one of them (seeded, never edited) is read with today's
  /// default (`NotificationTemplateService.getTemplate`); an edited text is
  /// kept. Same rule as the Cloud Functions' `SUPERSEDED`.
  static const Map<String, List<String>> supersededBodies = <String, List<String>>{
    'pending_approvals_manager': <String>[
      'You currently have {{count}} requests pending your review and formal decision. Please process these at your earliest convenience to avoid delays in the approval workflow.',
      'لديك حالياً {{count}} طلبات بانتظار مراجعتك واتخاذ القرار الرسمي بشأنها. يرجى معالجة هذه الطلبات في أقرب وقت لتفادي التأخير في سير عمل الموافقة.',
    ],
  };
}
