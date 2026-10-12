/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: services_calendar_events.dart
/// Module:    Service Management
/// Purpose: Every calendar entry the services module can place on the calendar.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Written to complete CR-SKEL-CAL-N03: `calendar_data_service.dart` was
/// already migrated onto `CalendarEventModel.fromType` and referenced this
/// enum at nine call sites, but the file itself was never added — the calendar
/// side had the `CalendarEventType` interface and none of the per-module
/// files the interface's own header calls for.
///
/// Wording is aligned with `notification/domain/enums/services_module/
/// services_events.dart` so a calendar card and the notification that
/// accompanies it read the same. Where the calendar splits one notification
/// by audience (requester / provider / management), the shared phrasing is
/// kept and only the addressee changes.
///
/// ⚠️ NO `{{serviceName}}` PLACEHOLDER. The notification bodies interpolate
/// the service name, but on the calendar it is already the card's `taskName`
/// (every call site passes `taskName: taskName`), so repeating it in the body
/// would print it twice. Only entries whose call site actually passes a
/// variable declare one — `variables` is asserted against the call site in
/// [CalendarEventModel.fromType], so declaring an unused placeholder here
/// would throw at runtime.
///
/// ─── UPDATED 1/9/2026 ────────────────────────────────────────────────────
///
/// The revised §2 of "Knowticed Plus — Notification & Validation" expands the
/// Service block from two rows to six, and adds an audience note that the
/// builder was not honouring: completion is seen by "Manager, Service
/// Provider, and Requester", and the in-progress entry "records the actual
/// start date".
///
/// Three entries were added for the two sides that had no card:
/// [inProgressForProvider], [doneForProvider] and [doneForManagement]. The
/// approval-cycle rows of the spec ("Service Request Pending Decision") were
/// already covered by [pendingApproval] / [approvalApproved] /
/// [approvalRejected], and "New Service Assignment" by [assignedToProvider].

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum ServicesCalendarEvent implements CalendarEventType {
  // ── Approval cycle ────────────────────────────────────────────────────────

  pendingApproval(
    key: 'pending_approval',
    scope: 'Approvals',
    trigger: 'Request Reaches Your Step in the Approval Cycle',
    titleEn: 'Action Required — Service Request Pending Approval',
    titleAr: 'مطلوب إجراء — طلب خدمة بانتظار الموافقة',
    descriptionEn:
        'This service request has been submitted and requires your formal review and decision. Please assess the request and take the appropriate action at your earliest convenience.',
    descriptionAr:
        'تم تقديم طلب الخدمة ويستلزم مراجعتك الرسمية واتخاذ القرار المناسب. يرجى تقييم الطلب واتخاذ الإجراء المناسب في أقرب وقت.',
    statusCode: 'Pending Approval',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the timestamp of the step that made it the signed-in user\'s turn. Shown only while `myState` is pending.',
  ),

  approvalApproved(
    key: 'approval_approved',
    scope: 'Approvals',
    trigger: 'You Approved the Request',
    titleEn: 'Service Request Approved',
    titleAr: 'تمت الموافقة على طلب الخدمة',
    descriptionEn:
        'This service request has been reviewed and formally approved. The service will be executed in accordance with the agreed scope and timeline.',
    descriptionAr:
        'تمت مراجعة طلب الخدمة والموافقة عليه رسمياً. سيتم تنفيذ الخدمة وفقاً للنطاق والجدول الزمني المتفق عليهما.',
    statusCode: 'Milestone',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the approver\'s own timestamp when the cycle recorded one, otherwise on the first timestamp. Kept visible after approval so the cycle stays auditable.',
  ),

  approvalRejected(
    key: 'approval_rejected',
    scope: 'Approvals',
    trigger: 'You Rejected the Request',
    titleEn: 'Service Request Declined',
    titleAr: 'تم رفض طلب الخدمة',
    descriptionEn:
        'This service request has been reviewed and declined. Please refer to the provided remarks for further clarification, and resubmit if applicable.',
    descriptionAr:
        'تمت مراجعة طلب الخدمة ورفضه. يرجى الرجوع إلى الملاحظات المقدمة لمزيد من التوضيح وإعادة التقديم إذا كان ذلك مناسباً.',
    statusCode: 'Milestone',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Same date rule as [approvalApproved]. Kept visible after rejection.',
  ),

  // ── Provider side ─────────────────────────────────────────────────────────

  assignedToProvider(
    key: 'assigned_to_provider',
    scope: 'Provider',
    trigger: 'Request Assigned to You for Fulfilment',
    titleEn: 'New Service Request Assigned',
    titleAr: 'تم تعيين طلب خدمة جديد إليك',
    descriptionEn:
        'A new service request has been formally assigned to you for execution. Please review the request details and proceed with fulfilment in accordance with the agreed service level.',
    descriptionAr:
        'تم تعيين طلب خدمة جديد إليك رسمياً للتنفيذ. يرجى مراجعة تفاصيل الطلب والمضي في التنفيذ وفقاً لمستوى الخدمة المتفق عليه.',
    statusCode: 'Assigned',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Raised for the signed-in user when they are the assigned provider. Placed on the assignment timestamp.',
  ),

  dueForProvider(
    key: 'due_for_provider',
    scope: 'Provider',
    trigger: 'SLA Deadline for a Request Assigned to You',
    titleEn: 'Service Level Agreement Reminder',
    titleAr: 'تذكير بـ اتفاقية مستوى الخدمة',
    descriptionEn:
        'This service request is due on {{dueDate}}. Please prioritise its completion to ensure full compliance with the agreed service timeframe.',
    descriptionAr:
        'هذا الطلب مستحق بتاريخ {{dueDate}}. يرجى إيلاء أولوية لإنجازه لضمان الامتثال الكامل للإطار الزمني المتفق عليه.',
    statusCode: 'Due',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.dueDate},
    schedulingNote:
        'Placed on the SLA deadline computed from the assignment date and the service\'s SLA, not on a stored field.',
  ),

  /// ADDED 1/9/2026 — §2 "Service Status Changed to In Progress".
  ///
  /// The spec row says the entry "records the actual start date", and the
  /// provider — the person who performed the status change — had no card on
  /// that date. [dueForProvider] sits on the DEADLINE, so a provider looking
  /// at their calendar could see when a job was due and when it was assigned,
  /// but never when work on it actually started. The requester had that card
  /// ([inProgressForRequester]) and the provider did not.
  inProgressForProvider(
    key: 'in_progress_for_provider',
    scope: 'Provider',
    trigger: 'You Moved the Request to In Progress',
    titleEn: 'Service In Progress',
    titleAr: 'بدأ العمل على الخدمة',
    descriptionEn:
        'Work on this service request is under way. It is due for completion by {{dueDate}}. Please update the request status once the work is finished.',
    descriptionAr:
        'العمل على طلب الخدمة جارٍ حالياً ومن المقرر إنجازه بحلول {{dueDate}}. يرجى تحديث حالة الطلب فور الانتهاء من العمل.',
    // See [inProgressForRequester] — 'InProgress' with no space, because
    // calendar_screen.dart compares `status.toLowerCase() == 'inprogress'`.
    statusCode: 'InProgress',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.dueDate},
    schedulingNote:
        'Placed on the timestamp paired with the first `InProgress` entry in the status history — the real start, not the assignment date and not the deadline.',
  ),

  /// ADDED 1/9/2026 — §2 "Service Completion Date Reached": "all relevant
  /// parties are notified simultaneously".
  ///
  /// Completion was a REQUESTER-ONLY card. The provider who did the work saw
  /// their request vanish from the calendar the moment they closed it —
  /// nothing marked the day it was delivered.
  doneForProvider(
    key: 'done_for_provider',
    scope: 'Provider',
    trigger: 'You Completed the Request',
    titleEn: 'Service Completed',
    titleAr: 'اكتملت الخدمة',
    descriptionEn:
        'This service request has been marked as completed and closed. No further action is required unless the requester raises a follow-up.',
    descriptionAr:
        'تم وضع علامة على طلب الخدمة كمكتمل وإغلاقه. لا يُستلزم اتخاذ أي إجراء إضافي ما لم يقدم مقدم الطلب متابعة.',
    // See [doneForRequester] — matched lowercased by the Duration chip.
    statusCode: 'Done',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the completion timestamp, the same date as [doneForRequester]; the two are the same moment seen from the two sides.',
  ),

  slaBreachedProvider(
    key: 'sla_breached_provider',
    scope: 'Provider',
    trigger: 'SLA Deadline Passed — Request Still Open',
    titleEn: 'Critical Alert — Service Level Agreement Breached',
    titleAr: 'تنبيه عاجل — خرق اتفاقية مستوى الخدمة',
    descriptionEn:
        'This service request has exceeded the agreed SLA. This constitutes a breach of the service commitment and requires immediate escalation and corrective action.',
    descriptionAr:
        'تجاوز طلب الخدمة اتفاقية مستوى الخدمة المتفق عليها. يُعدّ ذلك إخلالاً بالتزامات الخدمة ويستوجب التصعيد الفوري واتخاذ الإجراء التصحيحي.',
    statusCode: 'SLA',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the breached deadline itself, so the card sits on the date the commitment was missed rather than today.',
  ),

  // ── Requester side ────────────────────────────────────────────────────────

  inProgressForRequester(
    key: 'in_progress_for_requester',
    scope: 'Requester',
    trigger: 'Your Request Moved to In Progress',
    titleEn: 'Service Request Currently in Progress',
    titleAr: 'طلب الخدمة قيد التنفيذ',
    descriptionEn:
        'Your service request is actively being processed and is expected to complete by {{dueDate}}. You will receive a notification upon completion of the service.',
    descriptionAr:
        'طلب الخدمة قيد التنفيذ الفعلي حالياً ومن المتوقع إنجازه بحلول {{dueDate}}. سيتم إشعارك عند اكتمال تنفيذ الخدمة.',
    // ⚠️ 'InProgress', not 'In Progress'. calendar_screen.dart buckets
    // `status.toLowerCase() == 'inprogress'` under the Duration chip; a space
    // would fail that comparison and drop the card out of every filter.
    statusCode: 'InProgress',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.dueDate},
    schedulingNote:
        'Spans from the in-progress timestamp to the SLA deadline; the card is placed on the start and the deadline is carried in the body.',
  ),

  doneForRequester(
    key: 'done_for_requester',
    scope: 'Requester',
    trigger: 'Your Request Completed Within SLA',
    titleEn: 'Service Request Completed Successfully',
    titleAr: 'تم إنجاز طلب الخدمة بنجاح',
    descriptionEn:
        'Your service request has been completed successfully and within the agreed service timeframe. Please review the outcome and contact the service team if any follow-up is required.',
    descriptionAr:
        'تم إنجاز طلب الخدمة بنجاح وضمن الإطار الزمني المتفق عليه. يرجى مراجعة النتيجة والتواصل مع فريق الخدمة في حال الحاجة إلى أي متابعة.',
    // See [inProgressForRequester] — 'Done' is matched lowercased and also
    // buckets under the Duration chip.
    statusCode: 'Done',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Chosen over [doneAfterSlaForRequester] when the completion timestamp is on or before the computed SLA deadline.',
  ),

  doneAfterSlaForRequester(
    key: 'done_after_sla_for_requester',
    scope: 'Requester',
    trigger: 'Your Request Completed After the SLA Deadline',
    titleEn: 'Service Request Completed — Outside Agreed Timeframe',
    titleAr: 'تم إنجاز طلب الخدمة — خارج الإطار الزمني المتفق عليه',
    descriptionEn:
        'Your service request has been completed, though it exceeded the agreed service level timeframe. Please review the outcome and contact the service team if any follow-up is required.',
    descriptionAr:
        'تم إنجاز طلب الخدمة، إلا أنه تجاوز الإطار الزمني المتفق عليه في اتفاقية مستوى الخدمة. يرجى مراجعة النتيجة والتواصل مع فريق الخدمة في حال الحاجة إلى أي متابعة.',
    statusCode: 'Done',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Same placement as [doneForRequester]; only the wording differs, chosen when the completion timestamp is after the SLA deadline.',
  ),

  slaBreachedRequester(
    key: 'sla_breached_requester',
    scope: 'Requester',
    trigger: 'SLA Deadline Passed on Your Request',
    titleEn: 'Service Level Agreement Exceeded',
    titleAr: 'تم تجاوز اتفاقية مستوى الخدمة',
    descriptionEn:
        'Your service request has exceeded the agreed service level timeframe. The matter is currently under review, and appropriate action will be taken to resolve it promptly.',
    descriptionAr:
        'تجاوز طلب الخدمة الإطار الزمني المتفق عليه في اتفاقية مستوى الخدمة. يجري حالياً مراجعة الأمر واتخاذ الإجراء المناسب لمعالجته في أقرب وقت.',
    statusCode: 'SLA',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    schedulingNote:
        'Same breached deadline as [slaBreachedProvider]; raised for the requester instead of the assignee.',
  ),

  // ── Management escalation ─────────────────────────────────────────────────

  slaBreachedManagement(
    key: 'sla_breached_management',
    scope: 'Management',
    trigger: 'SLA Breached on a Request in Your Department',
    titleEn: 'Critical Alert — Service Level Agreement Breached',
    titleAr: 'تنبيه عاجل — خرق اتفاقية مستوى الخدمة',
    descriptionEn:
        'A service request in {{departmentName}} has exceeded the agreed SLA. This constitutes a breach of the service commitment and requires immediate escalation and corrective action.',
    descriptionAr:
        'تجاوز أحد طلبات الخدمة في {{departmentName}} اتفاقية مستوى الخدمة المتفق عليها. يُعدّ ذلك إخلالاً بالتزامات الخدمة ويستوجب التصعيد الفوري واتخاذ الإجراء التصحيحي.',
    statusCode: 'SLA',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.departmentName},
    schedulingNote:
        'The escalation copy of [slaBreachedProvider], raised for department management. Carries the department so a manager over several can tell the cards apart.',
  ),

  /// ADDED 1/9/2026 — the management half of §2 "Service Completion Date
  /// Reached", whose note reads "all relevant parties are notified
  /// simultaneously".
  ///
  /// Middle management previously appeared in the Services builder for
  /// exactly one thing: an SLA breach. A manager therefore saw only the
  /// failures in their department and never a completion, which makes the
  /// calendar read as a list of problems rather than a record of work.
  doneForManagement(
    key: 'done_for_management',
    scope: 'Management',
    trigger: 'A Request in Your Department Was Completed',
    titleEn: 'Service Completed',
    titleAr: 'اكتملت الخدمة',
    descriptionEn:
        'A service request in {{departmentName}} has been completed and closed. No escalation is required.',
    descriptionAr:
        'تم إنجاز أحد طلبات الخدمة في {{departmentName}} وإغلاقه. لا يستلزم الأمر أي تصعيد.',
    statusCode: 'Done',
    colorValue: 0xFF0095FF,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.departmentName},
    schedulingNote:
        'Same completion timestamp as [doneForRequester] and [doneForProvider]. Raised only when the manager is neither the provider nor the requester, so nobody gets two cards for one completion.',
  );

  const ServicesCalendarEvent({
    required this.key,
    required this.scope,
    required this.trigger,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.statusCode,
    required this.colorValue,
    required this.reminderOffsetDays,
    required this.schedulingNote,
    this.variables = const <TemplateVariable>{},
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
  final int colorValue;
  @override
  final int reminderOffsetDays;
  @override
  final String schedulingNote;
  @override
  final Set<TemplateVariable> variables;

  @override
  AppModule get module => AppModule.services;

  @override
  String get id => '${module.key}_$key';

  static ServicesCalendarEvent? fromKey(String key) {
    for (final ServicesCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
