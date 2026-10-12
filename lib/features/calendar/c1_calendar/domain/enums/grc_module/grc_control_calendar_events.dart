/// Module: calendar / c1_calendar / domain / enums / grc_module
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_control_calendar_events.dart
/// Purpose: The GRC **Control / Control Champion / Control Owner** calendar
///          entries — the date-driven half of those spec sections. Sibling of
///          [GrcModuleCalendarEvent] and [GrcPolicyCalendarEvent], same shape.
/// Author: Knowticed Plus team
/// Created At: 16/9/2026
///
/// SOURCE DATES
/// ------------
/// * Assignment start date  = the control's Start Date (a champion / owner
///   covers a control from the day the control starts).
/// * Submission due date    = the control's End Date — the same date
///   computeAssignmentControlTab uses to decide "Overdue".
/// * Reassignment requests  = the request's own Start / End Date.
///
/// Every entry is DERIVED on read in calendar_data_service
/// (getGrcControlCalendarEvents), so "created immediately" and "existing entry
/// is updated automatically" hold by construction.
///
/// ONE COLOUR FOR GRC: `CalendarModulePalette.grc` (0xFFB5AF3D) on every entry.
///
/// ⚠️ `statusCode` is ENGLISH ONLY — see CalendarEventType.statusCode.
library;

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum GrcControlCalendarEvent implements CalendarEventType {
  controlStartDateReached(
    key: 'control_start_date_reached',
    scope: 'GRC Module - Control',
    trigger: 'Control Start Date Reached',
    titleEn: 'Control Start Date Reached',
    titleAr: 'تم الوصول إلى تاريخ بدء الضبط',
    descriptionEn: '{{controlName}} has been activated today.',
    descriptionAr: 'تم تفعيل الضبط {{controlName}} اليوم.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote: 'Highlighted on the activation day only — the copy says "today". Audience: the module owners.',
  ),

  championAssignmentStartDateReached(
    key: 'champion_assignment_start_date_reached',
    scope: 'GRC Module – Control Champion',
    trigger: 'Control Assignment Start Date Reached',
    titleEn: 'Control Assignment Start Date Reached',
    titleAr: 'تم الوصول إلى تاريخ بدء التعيين',
    descriptionEn: 'You have been assigned to {{controlName}} today.',
    descriptionAr: 'تم تعيينك كبطل للضبط {{controlName}} اليوم.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote: 'Highlighted on the assignment start date (the control start date) for each assigned champion, on that day only.',
  ),

  ownerAssignmentStartDateReached(
    key: 'owner_assignment_start_date_reached',
    scope: 'GRC Module – Control Owner',
    trigger: 'Control Assignment Start Date Reached',
    titleEn: 'Control Assignment Start Date Reached',
    titleAr: 'تم الوصول إلى تاريخ بدء التعيين',
    descriptionEn: 'You have been assigned to {{controlName}} today.',
    descriptionAr: 'تم تعيينك كمالك للضبط {{controlName}} اليوم.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote: 'Highlighted on the assignment start date for each assigned owner, on that day only.',
  ),

  championStartDateDefined(
    key: 'champion_start_date_defined',
    scope: 'GRC Module – Control Champion',
    trigger: 'Control Champion Start Date Defined',
    titleEn: 'Control Champion Assignment Scheduled',
    titleAr: 'تمت جدولة تعيين بطل الضبط',
    descriptionEn: '{{controlName}} assignment starts on {{startDate}}.',
    descriptionAr: 'يبدأ تعيينك للضبط {{controlName}} بتاريخ {{startDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote: 'Created as soon as the champion is assigned; placed on the start date while it is still today or ahead.',
  ),

  championStartDateReached(
    key: 'champion_start_date_reached',
    scope: 'GRC Module – Control Champion',
    trigger: 'Control Champion Start Date Reached',
    titleEn: 'Control Champion Assignment Starts Today',
    titleAr: 'يبدأ تعيين بطل الضبط اليوم',
    descriptionEn: 'Your Control Champion assignment for {{controlName}} starts today.',
    descriptionAr: 'يبدأ تعيينك كبطل للضبط {{controlName}} اليوم.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote: 'Highlighted on the start date. Emitted for approved reassignment requests (the regular path uses championAssignmentStartDateReached, which is the same moment).',
  ),

  submissionDueDateDefined(
    key: 'submission_due_date_defined',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due Date Defined',
    titleEn: 'Control Champion Submission Scheduled',
    titleAr: 'تمت جدولة موعد تسليم بطل الضبط',
    descriptionEn: 'Evidence for {{controlName}} is due on {{dueDate}}.',
    descriptionAr: 'موعد تسليم دليل الضبط {{controlName}} بتاريخ {{dueDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.dueDate},
    schedulingNote: 'Placed on the submission due date (the control end date) as soon as it exists; hidden once evidence is submitted.',
  ),

  submissionDueIn14Days(
    key: 'submission_due_in_14_days',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due in 14 Days',
    titleEn: 'Control Champion Submission Due Soon',
    titleAr: 'اقتراب موعد تسليم بطل الضبط',
    descriptionEn: 'Evidence for {{controlName}} is due on {{dueDate}}.',
    descriptionAr: 'موعد تسليم دليل الضبط {{controlName}} بتاريخ {{dueDate}}.',
    statusCode: 'Reminder',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: -14,
    variables: {TemplateVariable.controlName, TemplateVariable.dueDate},
    schedulingNote: 'Placed 14 days before the due date; skipped when that day has passed or evidence is already submitted.',
  ),

  submissionDueToday(
    key: 'submission_due_today',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due Date Reached',
    titleEn: 'Control Champion Submission Due Today',
    titleAr: 'موعد تسليم بطل الضبط اليوم',
    descriptionEn: 'Evidence for {{controlName}} is due today ({{dueDate}}).',
    descriptionAr: 'موعد تسليم دليل الضبط {{controlName}} اليوم ({{dueDate}}).',
    statusCode: 'Due Today',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.dueDate},
    schedulingNote: 'Highlighted on the due date itself, only on that day and only while nothing is submitted.',
  ),

  submissionOverdue(
    key: 'submission_overdue',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due Date Passed',
    titleEn: 'Control Champion Submission Overdue',
    titleAr: 'تسليم بطل الضبط متأخر',
    descriptionEn: 'Evidence for {{controlName}} was due on {{dueDate}}.',
    descriptionAr: 'كان موعد تسليم دليل الضبط {{controlName}} بتاريخ {{dueDate}}.',
    statusCode: 'Overdue',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 1,
    variables: {TemplateVariable.controlName, TemplateVariable.dueDate},
    schedulingNote: 'Placed on the first day after the due date when no submitted status was recorded.',
  ),

  championStartDateUpdated(
    key: 'champion_start_date_updated',
    scope: 'GRC Module – Control Champion',
    trigger: 'Control Champion Start Date Updated',
    titleEn: 'Control Champion Start Date Updated',
    titleAr: 'تم تحديث تاريخ بدء تعيين بطل الضبط',
    descriptionEn: '{{controlName}} start date updated from {{oldStartDate}} to {{newStartDate}}.',
    descriptionAr: 'تم تحديث تاريخ بدء الضبط {{controlName}} من {{oldStartDate}} إلى {{newStartDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.oldStartDate, TemplateVariable.newStartDate},
    schedulingNote: 'Placed on the NEW start date; the old date stops producing cards by construction (derived on read).',
  ),

  submissionDueDateUpdated(
    key: 'submission_due_date_updated',
    scope: 'GRC Module – Control Champion',
    trigger: 'Submission Due Date Updated',
    titleEn: 'Control Champion Submission Due Date Updated',
    titleAr: 'تم تحديث موعد تسليم بطل الضبط',
    descriptionEn: '{{controlName}} due date updated from {{oldEndDate}} to {{newEndDate}}.',
    descriptionAr: 'تم تحديث موعد تسليم الضبط {{controlName}} من {{oldEndDate}} إلى {{newEndDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.oldEndDate, TemplateVariable.newEndDate},
    schedulingNote: 'Placed on the NEW due date; derived on read like every GRC entry.',
  ),

  championReassignmentPending(
    key: 'champion_reassignment_pending',
    scope: 'GRC Module – Control Champion Request',
    trigger: 'Reassignment Request Submitted',
    titleEn: 'Control Champion Reassignment Pending Approval',
    titleAr: 'طلب إعادة تعيين بطل الضبط بانتظار الموافقة',
    descriptionEn: '{{requesterName}} requested reassigning {{controlName}} from {{startDate}}.',
    descriptionAr: 'طلب {{requesterName}} إعادة تعيين الضبط {{controlName}} اعتباراً من {{startDate}}.',
    statusCode: 'Pending',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.requesterName, TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote: 'For the approvers (module owners) while the request is pending, placed on the requested start date — the day the decision is needed by.',
  ),

  championReassignmentApproved(
    key: 'champion_reassignment_approved',
    scope: 'GRC Module – Control Champion Request',
    trigger: 'Reassignment Request Approved',
    titleEn: 'Control Champion Assignment Scheduled',
    titleAr: 'تمت جدولة تعيين بطل الضبط',
    descriptionEn: '{{controlName}} assignment starts on {{startDate}}.',
    descriptionAr: 'يبدأ تعيينك للضبط {{controlName}} بتاريخ {{startDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote: 'For the newly assigned champion, on the approved start date while it is today or ahead.',
  ),

  championAssignmentEndsToday(
    key: 'champion_assignment_ends_today',
    scope: 'GRC Module – Control Champion Request',
    trigger: 'Control Champion Assignment Ends Today',
    titleEn: 'Control Champion Assignment Ends Today',
    titleAr: 'ينتهي تعيين بطل الضبط اليوم',
    descriptionEn: 'Your Control Champion assignment for {{controlName}} ends today.',
    descriptionAr: 'ينتهي تعيينك كبطل للضبط {{controlName}} اليوم.',
    statusCode: 'Expiring',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote: 'For the assigned champion, on the approved end date only.',
  ),

  ownerStartDateDefined(
    key: 'owner_start_date_defined',
    scope: 'GRC Module – Control Owner',
    trigger: 'Control Owner Start Date Defined',
    titleEn: 'Control Owner Assignment Scheduled',
    titleAr: 'تمت جدولة تعيين مالك الضبط',
    descriptionEn: '{{controlName}} ownership starts on {{startDate}}.',
    descriptionAr: 'تبدأ ملكيتك للضبط {{controlName}} بتاريخ {{startDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote: 'Created as soon as the owner is assigned; placed on the start date while it is today or ahead.',
  ),

  ownerStartDateReached(
    key: 'owner_start_date_reached',
    scope: 'GRC Module – Control Owner',
    trigger: 'Control Owner Start Date Reached',
    titleEn: 'Control Owner Assignment Starts Today',
    titleAr: 'يبدأ تعيين مالك الضبط اليوم',
    descriptionEn: 'Your Control Owner assignment for {{controlName}} starts today.',
    descriptionAr: 'يبدأ تعيينك كمالك للضبط {{controlName}} اليوم.',
    statusCode: 'Active',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote: 'Highlighted on the start date. Emitted for approved reassignment requests (the regular path uses ownerAssignmentStartDateReached).',
  ),

  ownerStartDateUpdated(
    key: 'owner_start_date_updated',
    scope: 'GRC Module – Control Owner',
    trigger: 'Control Owner Start Date Updated',
    titleEn: 'Control Owner Start Date Updated',
    titleAr: 'تم تحديث تاريخ بدء تعيين مالك الضبط',
    descriptionEn: '{{controlName}} start date updated from {{oldStartDate}} to {{newStartDate}}.',
    descriptionAr: 'تم تحديث تاريخ بدء الضبط {{controlName}} من {{oldStartDate}} إلى {{newStartDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.oldStartDate, TemplateVariable.newStartDate},
    schedulingNote: 'Placed on the NEW start date.',
  ),

  ownerReassignmentPending(
    key: 'owner_reassignment_pending',
    scope: 'GRC Module – Control Owner Request',
    trigger: 'Reassignment Request Submitted',
    titleEn: 'Control Owner Reassignment Pending Approval',
    titleAr: 'طلب إعادة تعيين مالك الضبط بانتظار الموافقة',
    descriptionEn: '{{requesterName}} requested reassigning {{controlName}} from {{startDate}}.',
    descriptionAr: 'طلب {{requesterName}} إعادة تعيين الضبط {{controlName}} اعتباراً من {{startDate}}.',
    statusCode: 'Pending',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.requesterName, TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote: 'For the approvers while pending, on the requested start date.',
  ),

  ownerReassignmentApproved(
    key: 'owner_reassignment_approved',
    scope: 'GRC Module – Control Owner Request',
    trigger: 'Reassignment Request Approved',
    titleEn: 'Control Owner Assignment Scheduled',
    titleAr: 'تمت جدولة تعيين مالك الضبط',
    descriptionEn: '{{controlName}} ownership starts on {{startDate}}.',
    descriptionAr: 'تبدأ ملكيتك للضبط {{controlName}} بتاريخ {{startDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName, TemplateVariable.startDate},
    schedulingNote: 'For the newly assigned owner, on the approved start date while it is today or ahead.',
  ),

  ownerAssignmentEndsToday(
    key: 'owner_assignment_ends_today',
    scope: 'GRC Module – Control Owner Request',
    trigger: 'Control Owner Assignment Ends Today',
    titleEn: 'Control Owner Assignment Ends Today',
    titleAr: 'ينتهي تعيين مالك الضبط اليوم',
    descriptionEn: 'Your Control Owner assignment for {{controlName}} ends today.',
    descriptionAr: 'ينتهي تعيينك كمالك للضبط {{controlName}} اليوم.',
    statusCode: 'Expiring',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.controlName},
    schedulingNote: 'For the assigned owner, on the approved end date only. (The spec lists this row for champions; owners get the same card for symmetry.)',
  );

  const GrcControlCalendarEvent({
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
  final int colorValue;
  @override
  final int reminderOffsetDays;
  @override
  final Set<TemplateVariable> variables;
  @override
  final String schedulingNote;

  @override
  AppModule get module => AppModule.grc;

  @override
  String get id => '${module.key}_$key';

  static GrcControlCalendarEvent? fromKey(String key) {
    for (final GrcControlCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
