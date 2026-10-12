/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: qiyas_events.dart
/// Purpose: Notification event catalog: qiyas events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: qiyas_events.dart
/// Module:    Qiyas
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

enum QiyasNotificationEvent implements NotificationEvent {
  perspectivesAxesCreated(
    key: 'perspectives_axes_created',
    group: '',
    titleEn: 'Perspectives and Axes Successfully Created',
    titleAr: 'تم إنشاء المناظير والمحاور بنجاح',
    bodyEn: 'The perspectives and axes for {{frameworkName}} have been successfully created by {{employeeName}} and are now available for evidence assignment and champion configuration. Please review the new structure before proceeding.',
    bodyAr: 'تم إنشاء المناظير والمحاور لـ {{frameworkName}} بنجاح بواسطة {{employeeName}} وأصبحت متاحة لتعيين الأدلة وتهيئة السفراء. يرجى مراجعة الهيكل الجديد قبل المتابعة.',
    variables: {TemplateVariable.frameworkName, TemplateVariable.employeeName},
  ),
  championAssignedToEvidence(
    key: 'champion_assigned_to_evidence',
    group: '',
    titleEn: 'Digital Transformation Champion Assigned',
    titleAr: 'تم تعيين سفير التحول الرقمي',
    bodyEn: 'A Digital Transformation Champion has been assigned to {{documentName}}. The champion is now responsible for coordinating evidence submission and fulfilling all required actions associated with this document within the designated timeframe.',
    bodyAr: 'تم تعيين سفير التحول الرقمي للمستند {{documentName}}. يتولى السفير الآن مسؤولية تنسيق تقديم الأدلة وإنجاز جميع الإجراءات المطلوبة المرتبطة بهذا المستند في غضون الإطار الزمني المحدد.',
    variables: {TemplateVariable.documentName},
  ),
  evidenceSubmittedForReview(
    key: 'evidence_submitted_for_review',
    group: '',
    titleEn: 'Evidence Submitted for Supervisor Review',
    titleAr: 'تم إرسال الدليل للمراجعة',
    bodyEn: '{{documentName}} has been successfully submitted by the assigned Digital Transformation Champion and is currently pending formal review by the designated supervisor. An automated reminder will be issued if no action is taken within the required timeframe.',
    bodyAr: 'تم تقديم المستند {{documentName}} بنجاح من قِبَل سفير التحول الرقمي المعيّن وهو حالياً قيد المراجعة الرسمية من قِبَل المشرف المختص. سيتم إرسال تذكير تلقائي في حال عدم اتخاذ أي إجراء خلال المدة المحددة.',
    variables: {TemplateVariable.documentName},
  ),
  evidenceStatusApproved(
    key: 'evidence_status_approved',
    group: '',
    titleEn: 'Evidence Status Updated to Approved',
    titleAr: 'تحديث حالة الدليل إلى معتمد',
    bodyEn: 'The approval status of {{documentName}} has been formally updated to Approved.No further action is required.',
    bodyAr: 'تم تحديث حالة الموافقة على المستند {{documentName}} رسمياً إلى معتمد. يستوفي الدليل الآن جميع المعايير المطلوبة ويُعدّ صالحاً للفترة الزمنية للقياس المرتبطة. لا يُستلزم اتخاذ أي إجراء إضافي.',
    variables: {TemplateVariable.documentName},
  ),
  evidenceStatusRejected(
    key: 'evidence_status_rejected',
    group: '',
    titleEn: 'Evidence Status Updated to Rejected',
    titleAr: 'تحديث حالة الدليل إلى مرفوض',
    bodyEn: 'The approval status of {{documentName}} has been formally updated to Rejected. Please review the feedback provided by the supervisor, address all identified issues, and resubmit a revised version for reconsideration at your earliest convenience.',
    bodyAr: 'تم تحديث حالة الموافقة على المستند {{documentName}} رسمياً إلى مرفوض. يرجى مراجعة الملاحظات المقدمة من المشرف ومعالجة جميع المشكلات المحددة وإعادة تقديم نسخة معدّلة لإعادة النظر فيها في أقرب وقت ممكن.',
    variables: {TemplateVariable.documentName},
  ),
  evidenceOverdue(
    key: 'evidence_overdue',
    group: '',
    titleEn: 'Evidence Submission Overdue — Immediate Action Required',
    titleAr: 'تجاوز موعد تقديم الدليل — مطلوب إجراء فوري',
    bodyEn: '{{documentName}} has exceeded its designated submission deadline and is now recorded as overdue in the system. Please take immediate action to avoid further escalation and any potential impact on your organisation\'s measurement score.',
    bodyAr: 'تجاوز المستند {{documentName}} الموعد النهائي للتقديم المحدد وتم تسجيله في النظام كمتأخر. يرجى اتخاذ إجراء فوري لتجنب مزيد من التصعيد وأي تأثير محتمل على درجة القياس لمنظمتك.',
    variables: {TemplateVariable.documentName},
  ),
  championReassigned(
    key: 'champion_reassigned',
    group: '',
    titleEn: 'Digital Transformation Champion Reassigned',
    titleAr: 'تمت إعادة تعيين سفير التحول الرقمي',
    bodyEn: 'The Digital Transformation Champion for {{documentName}} has been formally reassigned. The newly assigned champion will assume full responsibility for evidence coordination effective immediately. Previous assignment records have been updated accordingly.',
    bodyAr: 'تمت إعادة تعيين سفير التحول الرقمي للمستند {{documentName}} رسمياً. سيتولى السفير المعيّن حديثاً المسؤولية الكاملة عن تنسيق الأدلة بشكل فوري. تم تحديث سجلات التعيين السابقة وفقاً لذلك.',
    variables: {TemplateVariable.documentName},
  ),
  sendReminder(
    key: 'send_reminder',
    group: '',
    titleEn: 'Reminder Notification Issued',
    titleAr: 'تم إصدار إشعار تذكير',
    bodyEn: 'An automated reminder has been issued to the assigned Digital Transformation Champion regarding {{documentName}}, which remains pending submission. The champion is expected to take the necessary action promptly to avoid the evidence being recorded as overdue.',
    bodyAr: 'تم إصدار تذكير تلقائي للسفير المعيّن بشأن المستند {{documentName}} الذي لا يزال ينتظر التقديم. من المتوقع أن يتخذ السفير الإجراء اللازم في أقرب وقت لتجنب تسجيل الدليل كمتأخر.',
    variables: {TemplateVariable.documentName},
  ),
  measurementFileDeleted(
    key: 'measurement_file_deleted',
    group: '',
    titleEn: 'Measurement File Permanently Removed',
    titleAr: 'تم حذف ملف القياس نهائياً',
    bodyEn: 'The measurement file {{fileName}} has been permanently removed from the system by {{employeeName}}. This action is irreversible. If this deletion was made in error, please contact your system administrator immediately.',
    bodyAr: 'تم حذف ملف القياس {{fileName}} نهائياً من النظام بواسطة {{employeeName}}. هذا الإجراء لا رجعة فيه. إذا تم الحذف عن طريق الخطأ يرجى التواصل مع مسؤول النظام فوراً.',
    variables: {TemplateVariable.fileName, TemplateVariable.employeeName},
  ),
  perspectivesAxesEdited(
    key: 'perspectives_axes_edited',
    group: '',
    titleEn: 'Perspectives and Axes Names Successfully Updated',
    titleAr: 'تم تحديث أسماء المناظير والمحاور بنجاح',
    bodyEn: 'The names of the perspectives and axes within {{frameworkName}} have been updated by {{employeeName}}. Please review the revised naming structure to ensure alignment with your measurement framework before proceeding.',
    bodyAr: 'تم تحديث أسماء المناظير والمحاور ضمن {{frameworkName}} بواسطة {{employeeName}}. يرجى مراجعة هيكل التسمية المعدّل للتأكد من توافقه مع إطار القياس الخاص بك قبل المتابعة.',
    variables: {TemplateVariable.frameworkName, TemplateVariable.employeeName},
  );

  const QiyasNotificationEvent({
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
  AppModule get module => AppModule.qiyas;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static QiyasNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
