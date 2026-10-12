/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_events.dart
/// Purpose: Notification event catalog: knowledge hub events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: knowledge_hub_events.dart
/// Module:    Knowledge Hub
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

enum KnowledgeHubNotificationEvent implements NotificationEvent {
  documentSubmitted(
    key: 'document_submitted',
    group: '',
    titleEn: 'Document Submitted for Review',
    titleAr: 'تم إرسال المستند للمراجعة',
    bodyEn: '{{documentName}} has been successfully submitted and is currently under formal review by the designated authority. A follow-up reminder will be issued if no action is taken within the required timeframe.',
    bodyAr: 'تم إرسال المستند {{documentName}} بنجاح وهو قيد المراجعة الرسمية من قِبَل الجهة المختصة. سيتم إرسال تذكير تلقائي في حال عدم اتخاذ أي إجراء خلال المدة المحددة.',
    variables: {TemplateVariable.documentName},
  ),
  documentApproved(
    key: 'document_approved',
    group: '',
    titleEn: 'Document Approved',
    titleAr: 'تمت الموافقة على المستند',
    bodyEn: '{{documentName}} has been reviewed and formally approved. All required evaluation criteria have been satisfied. The document is now eligible for publication.',
    bodyAr: 'تمت مراجعة المستند {{documentName}} والموافقة عليه رسمياً. استوفى المستند جميع معايير التقييم المطلوبة وأصبح جاهزاً للنشر.',
    variables: {TemplateVariable.documentName},
  ),
  documentRejected(
    key: 'document_rejected',
    group: '',
    titleEn: 'Document Approval Declined',
    titleAr: 'تم رفض الموافقة على المستند',
    bodyEn: '{{documentName}} has not met the required approval criteria and has been formally declined. Please refer to the reviewer\'s feedback and submit a revised version for re-evaluation.',
    bodyAr: 'لم يستوفِ المستند {{documentName}} معايير الموافقة المطلوبة وتم رفضه رسمياً. يرجى الرجوع إلى ملاحظات المراجع وإعادة تقديم نسخة معدّلة للتقييم.',
    variables: {TemplateVariable.documentName},
  ),
  documentPublished(
    key: 'document_published',
    group: '',
    titleEn: 'Document Published and Effective',
    titleAr: 'تم نشر المستند وأصبح سارياً',
    bodyEn: '{{documentName}} has been officially published and is now active. The document is accessible to its designated audience and is in full effect as of the publication date.',
    bodyAr: 'تم نشر المستند {{documentName}} رسمياً وهو الآن ساري المفعول. يمكن للجمهور المحدد الوصول إليه اعتباراً من تاريخ النشر.',
    variables: {TemplateVariable.documentName},
  ),
  documentRemoved(
    key: 'document_removed',
    group: '',
    titleEn: 'Document Withdrawn from Circulation',
    titleAr: 'تم سحب المستند من التداول',
    bodyEn: '{{documentName}} has been formally withdrawn and is no longer active or applicable. Any references to this document should be discontinued with immediate effect.',
    bodyAr: 'تم سحب المستند {{documentName}} رسمياً ولم يعد سارياً أو معمولاً به. يجب وقف الإشارة إلى هذا المستند بشكل فوري.',
    variables: {TemplateVariable.documentName},
  ),
  documentExpiringIn14Days(
    key: 'document_expiring_in_14_days',
    group: '',
    titleEn: 'Document Validity Expiring Soon',
    titleAr: 'اقتراب انتهاء صلاحية المستند',
    bodyEn: '{{documentName}} is approaching its expiration date and will be automatically archived on {{endDate}} unless renewed or extended. Please initiate the necessary action to maintain the document\'s validity.',
    bodyAr: 'يقترب المستند {{documentName}} من تاريخ انتهاء صلاحيته وسيتم أرشفته تلقائياً بتاريخ {{endDate}} ما لم يتم تجديده أو تمديده. يرجى اتخاذ الإجراء اللازم للحفاظ على سريانه.',
    variables: {TemplateVariable.documentName, TemplateVariable.endDate},
  ),
  documentArchived(
    key: 'document_archived',
    group: '',
    titleEn: 'Document Archived — Validity Period Expired',
    titleAr: 'تمت أرشفة المستند — انتهت صلاحيته',
    bodyEn: '{{documentName}} has been archived upon reaching its designated expiration date. The document remains accessible for audit and reference purposes but is no longer in active use.',
    bodyAr: 'تمت أرشفة المستند {{documentName}} عند انتهاء فترة صلاحيته المحددة. لا يزال المستند متاحاً لأغراض المراجعة والتدقيق غير أنه لم يعد قيد الاستخدام الفعلي.',
    variables: {TemplateVariable.documentName},
  ),
  revisionRequested(
    key: 'revision_requested',
    group: '',
    titleEn: 'Document Returned for Revision',
    titleAr: 'تمت إعادة المستند للتعديل',
    bodyEn: '{{documentName}} has been returned following reviewer assessment. Revisions are required prior to resubmission. Please address all reviewer comments and resubmit the updated version for re-evaluation.',
    bodyAr: 'تمت إعادة المستند {{documentName}} بعد تقييم المراجع. يتطلب المستند إجراء تعديلات قبل إعادة تقديمه. يرجى معالجة جميع ملاحظات المراجع وإعادة تقديم النسخة المعدّلة.',
    variables: {TemplateVariable.documentName},
  ),
  inquiryOrCommentSubmitted(
    key: 'inquiry_or_comment_submitted',
    group: '',
    titleEn: 'New Inquiry Received',
    titleAr: 'تم استلام استفسار جديد',
    bodyEn: 'A new inquiry has been submitted regarding {{documentName}}. Please review the inquiry at your earliest convenience and provide the appropriate response.',
    bodyAr: 'تم استلام استفسار جديد بخصوص المستند {{documentName}}. يرجى مراجعة الاستفسار في أقرب وقت ممكن وتقديم الرد المناسب.',
    variables: {TemplateVariable.documentName},
  ),
  reviewReminderIssued(
    key: 'review_reminder_issued',
    group: '',
    titleEn: 'Pending Review — Reminder Notification',
    titleAr: 'تذكير — مستند بانتظار المراجعة',
    bodyEn: 'This is an automated reminder that {{documentName}} remains pending formal review. The assigned authority has been notified and is expected to take the necessary action promptly.',
    bodyAr: 'هذا تذكير تلقائي بأن المستند {{documentName}} لا يزال ينتظر المراجعة الرسمية. تم إشعار الجهة المختصة ومن المتوقع اتخاذ الإجراء اللازم في أقرب وقت.',
    variables: {TemplateVariable.documentName},
  ),
  reviewRequestReceived(
    key: 'review_request_received',
    group: '',
    titleEn: 'Review Request Assigned to You',
    titleAr: 'تم تعيين طلب مراجعة إليك',
    bodyEn: 'A formal review request has been assigned to you for {{documentName}}. Please evaluate the document and take the appropriate action in accordance with the review process.',
    bodyAr: 'تم تعيين طلب مراجعة رسمي إليك بخصوص المستند {{documentName}}. يرجى تقييم المستند واتخاذ الإجراء المناسب وفقاً لعملية المراجعة المعتمدة.',
    variables: {TemplateVariable.documentName},
  );

  const KnowledgeHubNotificationEvent({
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
  AppModule get module => AppModule.knowledgeHub;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static KnowledgeHubNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
