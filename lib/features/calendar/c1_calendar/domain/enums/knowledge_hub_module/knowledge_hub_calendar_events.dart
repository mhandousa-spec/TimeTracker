/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_calendar_events.dart
/// Module:    Knowledge Hub
/// Purpose: Every calendar entry the Knowledge Hub module can place on the
///          calendar.
/// Author: Knowticed Plus team
/// Created at: 18/8/2026
///
/// Written to close the Knowledge Hub half of "Knowticed Plus — Notification
/// & Validation" §2 (Calendar Event Triggers). `calendar_data_service
/// .getKnowledgeHubCalendarEvents` already produced these entries, but built
/// every one of them from literals — hardcoded English/Arabic strings glued
/// together with ` / `, a hardcoded colour and a hardcoded status. Services,
/// Role Management and User Access all had a `*_calendar_events.dart`;
/// Knowledge Hub was the one module still un-migrated.
///
/// Wording is aligned with `notification/domain/enums/knowledge_hub_module/
/// knowledge_hub_events.dart` so a calendar card and the notification that
/// accompanies it read the same.
///
/// ⚠️ NO `{{documentName}}` PLACEHOLDER. The notification bodies interpolate
/// the document name, but on the calendar it is already the card's
/// `taskName` (every call site passes the bilingual `taskName`), so
/// repeating it in the body would print it twice. `variables` is asserted
/// against the call site in [CalendarEventModel.fromType], so declaring an
/// unused placeholder here would throw at runtime.
///
/// ─── TWO DELIBERATE DEPARTURES FROM THE SPEC TABLE ───────────────────
///
/// 1. `reminderOffsetDays` is 0 on [documentValidityExpiring], not -14.
///    The spec's note reads "Reminder appears 14 days prior to the document
///    End Date", but the existing builder places the card ON the end date
///    and uses the 14-day window only to decide which bucket the card falls
///    into. Shifting the date here would move every expiry card two weeks
///    earlier and detach it from the date it is about. The window test stays
///    at the call site; the card stays on the expiry date.
///
/// 2. [documentExpiringSoon] is not in the spec table. It is the builder's
///    real ">14 days out" bucket and dropping it would silently delete
///    cards, so it is catalogued rather than discarded.
///
/// ─── ONE BUG FIXED IN PASSING ────────────────────────────────────────
/// The builder emitted `status: 'Expiring Soon'`, but the filter chip in
/// `calendar_screen.dart` is `'Expiring'` and filtering is an exact string
/// compare (`event.status == englishStatus`). Every ">14 days" card was
/// therefore invisible under its own chip. [documentExpiringSoon] carries
/// `statusCode: 'Expiring'` so the chip finally matches — the same class of
/// fix the file already documents twice for 'Pending Approval'.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum KnowledgeHubCalendarEvent implements CalendarEventType {
  // ── Publication ───────────────────────────────────────────────────────────

  documentPublished(
    key: 'document_published',
    scope: 'Publication',
    trigger: 'Document Published (immediate)',
    titleEn: 'Document Published and Effective',
    titleAr: 'تم نشر المستند وأصبح سارياً',
    descriptionEn:
        'This document has been officially published and is now active. The document is accessible to its designated audience and is in full effect as of the publication date.',
    descriptionAr:
        'تم نشر هذا المستند رسمياً وهو الآن ساري المفعول. يمكن للجمهور المحدد الوصول إليه اعتباراً من تاريخ النشر.',
    statusCode: 'Release',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    schedulingNote:
        'Appears on calendar immediately upon publication. Expiry date is visible if an End Date is set.',
  ),

  documentScheduled(
    key: 'document_scheduled',
    scope: 'Publication',
    trigger: 'Document Scheduled for Publication',
    titleEn: 'Document Scheduled',
    titleAr: 'تمت جدولة المستند للنشر',
    descriptionEn:
        'This document is scheduled for publication and will become active automatically on the planned publish date. No further action is required unless the schedule is changed.',
    descriptionAr:
        'هذا المستند مجدول للنشر وسيصبح ساري المفعول تلقائياً في تاريخ النشر المخطط. لا يُستلزم اتخاذ أي إجراء ما لم يتم تعديل الجدول.',
    statusCode: 'Scheduled',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    schedulingNote:
        'Calendar entry is created at the point of scheduling, reflecting the planned publish date. Placed on `startDateTime` and shown only while that date is still in the future.',
  ),

  // ── Validity ──────────────────────────────────────────────────────────────

  documentExpiringSoon(
    key: 'document_expiring_soon',
    scope: 'Validity',
    trigger: 'End Date Set, More Than 14 Days Away',
    titleEn: 'Document Validity Expiring',
    titleAr: 'انتهاء صلاحية المستند',
    descriptionEn:
        'This document is approaching its expiration date and will be automatically archived once its validity period ends, unless it is renewed or extended.',
    descriptionAr:
        'يقترب هذا المستند من تاريخ انتهاء صلاحيته وسيتم أرشفته تلقائياً عند انتهاء فترة سريانه ما لم يتم تجديده أو تمديده.',
    statusCode: 'Expiring',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the document `endDateTime` while that date is more than 14 days away. Not in the spec table — this is the builder\'s existing long-range bucket, kept so no card is lost.',
  ),

  documentValidityExpiring(
    key: 'document_validity_expiring',
    scope: 'Validity',
    trigger: 'Expiring in 14 Days',
    titleEn: 'Document Validity Expiring Soon',
    titleAr: 'اقتراب انتهاء صلاحية المستند',
    descriptionEn:
        'This document expires within the next fourteen days and will be automatically archived on the date shown, unless it is renewed or extended. Please initiate the necessary action to maintain the document\'s validity.',
    descriptionAr:
        'ستنتهي صلاحية هذا المستند خلال الأيام الأربعة عشر القادمة وسيتم أرشفته تلقائياً في التاريخ المعروض ما لم يتم تجديده أو تمديده. يرجى اتخاذ الإجراء اللازم للحفاظ على سريانه.',
    statusCode: 'Reminders',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    schedulingNote:
        'Spec: "Reminder appears 14 days prior to the document End Date. Requires immediate owner action." Implemented as a window test at the call site — the card sits on `endDateTime` and is raised as a reminder once that date is 0–14 days away, rather than being shifted two weeks earlier.',
  ),

  // ── Approval cycle ────────────────────────────────────────────────────────

  approvalPending(
    key: 'approval_pending',
    scope: 'Approvals',
    trigger: 'Approval Pending',
    titleEn: 'Approval Request Pending',
    titleAr: 'طلب موافقة بانتظار المراجعة',
    descriptionEn:
        'This document has been submitted and is pending your formal review as {{roleName}}. Please evaluate the document and take the appropriate action in accordance with the review process.',
    descriptionAr:
        'تم تقديم هذا المستند وهو بانتظار مراجعتك الرسمية بصفتك {{roleName}}. يرجى تقييم المستند واتخاذ الإجراء المناسب وفقاً لعملية المراجعة المعتمدة.',
    statusCode: 'Pending Approval',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.roleName},
    schedulingNote:
        'Calendar entry is generated automatically at the time of submission to the approver. Placed on the latest `timestamps` entry, and shown only to the creator\'s supervisor, a super admin, or a Knowledge Hub approver.',
  );

  const KnowledgeHubCalendarEvent({
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
  AppModule get module => AppModule.knowledgeHub;

  /// `<module>_<key>` — see [CalendarEventType.id].
  @override
  String get id => '${module.key}_$key';

  static KnowledgeHubCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
