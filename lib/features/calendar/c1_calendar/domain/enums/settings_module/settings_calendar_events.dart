/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: settings_calendar_events.dart
/// Module:    Settings
/// Purpose: Every calendar entry the settings change-request flow can place on
///          the calendar.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// The Settings module raised notifications but never a calendar entry, so a
/// change request waiting on a reviewer existed in two places that do not look
/// like a schedule — the inbox and the Requests queue — and nowhere that
/// answers "what needs me this week". `features/calendar` had per-module event
/// files for knowledge hub, services, role management and user access; this is
/// the fifth.
///
/// ─── AUDIENCE ────────────────────────────────────────────────────────
/// Two audiences, and the split is the whole point of the file:
///
///   * [changeRequestPendingReview] is for the REVIEWERS — anyone whose role
///     carries `Users_Requests`. It is the only entry here that represents
///     work, so it is the only one with a pending status code.
///   * [changeRequestSubmitted], [changeRequestApproved] and
///     [changeRequestRejected] are for the employee who raised the request.
///     They are a record of what happened, not a task, so they carry
///     `Milestone`.
///
/// A reviewer who submits their own request sees both, which is correct: one
/// card says they asked, the other says someone has to answer.
///
/// ─── WORDING ─────────────────────────────────────────────────────────
/// Aligned with `notification/domain/enums/settings_module/settings_events.dart`
/// so a calendar card and the notification that accompanies it read the same.
///
/// ⚠️ NO SECTION PLACEHOLDER. The section — `Personal Information`,
/// `Health Insurance`, `Emergency Contact` — is the card's `taskName` at every
/// call site, so repeating it in the body would print it twice. This is the
/// same rule `services_calendar_events.dart` documents for `{{serviceName}}`.
/// `variables` is asserted against the call site by
/// [CalendarEventModel.fromType], so an unused placeholder here throws at
/// runtime rather than rendering blank.
///
/// ⚠️ STATUS CODES ARE ENGLISH AND MUST STAY MATCHED. `statusCode` is compared
/// as a raw string by the calendar screen's filter chips. Both codes used here
/// — `Pending Approval` and `Milestone` — already exist in that screen's
/// `statusTypes` list and in both directions of its Arabic status map, so these
/// entries are filterable in both languages without touching it. Inventing a
/// new code would silently drop every card from every chip in Arabic.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum SettingsCalendarEvent implements CalendarEventType {
  // ── Reviewer side ─────────────────────────────────────────────────────────

  changeRequestPendingReview(
    key: 'change_request_pending_review',
    scope: 'Change Requests',
    trigger: 'A Change Request Is Awaiting Your Review',
    titleEn: 'Action Required — Change Request Pending Review',
    titleAr: 'مطلوب إجراء — طلب تعديل بانتظار المراجعة',
    // 21/9/2026 — Settings bug report p.5 ("check the message"): names the
    // section instead of the vague "this information".
    descriptionEn:
        '{{employeeName}} has submitted a request to update their {{documentName}}. Your review and approval are required before the changes can be applied.',
    descriptionAr:
        'قام {{employeeName}} بتقديم طلب لتعديل {{documentName}}. يرجى مراجعة الطلب واتخاذ القرار المناسب قبل تطبيق التعديلات.',
    statusCode: 'Pending Approval',
    colorValue: 0xFF4527A0,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.employeeName, TemplateVariable.documentName},
    schedulingNote:
        'Placed on the request date. Raised only for a signed-in user whose role carries the Users_Requests permission, and only while the request is still pending — a decided request stops being work, so the card disappears and is replaced by the employee-facing outcome entry.',
  ),

  // ── Employee side ─────────────────────────────────────────────────────────

  changeRequestSubmitted(
    key: 'change_request_submitted',
    scope: 'Change Requests',
    trigger: 'You Submitted a Change Request',
    titleEn: 'Change Request Submitted',
    titleAr: 'تم تقديم طلب التعديل',
    descriptionEn:
        'Your request to update this information has been submitted and is awaiting review. You will be notified once a decision has been made.',
    descriptionAr:
        'تم تقديم طلبك لتعديل هذه البيانات وهو بانتظار المراجعة. سيتم إشعارك فور اتخاذ القرار.',
    statusCode: 'Milestone',
    colorValue: 0xFF4527A0,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the request date, for the employee who raised it. Shown only while the request is pending; once decided it is replaced by the approved or rejected entry so the same request never occupies two cards on the same day.',
  ),

  changeRequestApproved(
    key: 'change_request_approved',
    scope: 'Change Requests',
    trigger: 'Your Change Request Was Approved',
    titleEn: 'Change Request Approved',
    titleAr: 'تمت الموافقة على طلب التعديل',
    descriptionEn:
        'Your request to update this information has been approved and the changes have been applied successfully.',
    descriptionAr:
        'تمت الموافقة على طلبك لتعديل هذه البيانات، وتم تطبيق التعديلات بنجاح.',
    statusCode: 'Milestone',
    colorValue: 0xFF4527A0,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the decision date (`updatedAt`), falling back to the request date on older documents that predate that field. Kept visible afterwards so the request stays auditable.',
  ),

  changeRequestRejected(
    key: 'change_request_rejected',
    scope: 'Change Requests',
    trigger: 'Your Change Request Was Rejected',
    titleEn: 'Change Request Rejected',
    titleAr: 'تم رفض طلب التعديل',
    descriptionEn:
        'Your request to update this information has been rejected. Please review the reason given and submit a new request if further changes are required.',
    descriptionAr:
        'تم رفض طلبك لتعديل هذه البيانات. يرجى مراجعة سبب الرفض وإعادة تقديم الطلب إذا لزم الأمر.',
    statusCode: 'Milestone',
    colorValue: 0xFF4527A0,
    reminderOffsetDays: 0,
    schedulingNote:
        'Same date rule as [changeRequestApproved]. The reason itself lives on the request and in the rejection notification, not on the card — a calendar entry is a pointer, not a record.',
  );

  const SettingsCalendarEvent({
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
  // CHANGED 21/9/2026 — Settings bug report p.5: the reviewer's
  // "pending review" card belongs to User Management (where the request is
  // decided), not Settings. The employee's own entries stay under Settings.
  //
  // 21/9/2026 — widened: all four change-request entries (every value of
  // this enum) are User Management, matching the notifications.
  AppModule get module => AppModule.userManagement;

  @override
  String get id => '${module.key}_$key';

  static SettingsCalendarEvent? fromKey(String key) {
    for (final SettingsCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
