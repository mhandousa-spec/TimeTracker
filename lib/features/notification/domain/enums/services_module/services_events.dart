/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: services_events.dart
/// Purpose: Notification event catalog: services events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: services_events.dart
/// Module:    Service Management
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

enum ServicesNotificationEvent implements NotificationEvent {
  requestSubmitted(
    key: 'request_submitted',
    group: '',
    titleEn: 'Service Request Successfully Submitted',
    titleAr: 'تم تقديم طلب الخدمة بنجاح',
    bodyEn: 'Your service request for {{serviceName}} has been submitted successfully and is currently being processed. You will be notified of any status updates throughout the fulfilment process.',
    bodyAr: 'تم تقديم طلب الخدمة {{serviceName}} بنجاح وهو قيد المعالجة حالياً. سيتم إشعارك بأي تحديثات على حالة الطلب خلال مراحل التنفيذ.',
    variables: {TemplateVariable.serviceName},
  ),
  requestApproved(
    key: 'request_approved',
    group: '',
    titleEn: 'Service Request Approved',
    titleAr: 'تمت الموافقة على طلب الخدمة',
    bodyEn: 'Your service request for {{serviceName}} has been reviewed and formally approved. The service will be executed in accordance with the agreed scope and timeline.',
    bodyAr: 'تمت مراجعة طلب الخدمة {{serviceName}} والموافقة عليه رسمياً. سيتم تنفيذ الخدمة وفقاً للنطاق والجدول الزمني المتفق عليهما.',
    variables: {TemplateVariable.serviceName},
  ),
  requestRejected(
    key: 'request_rejected',
    group: '',
    titleEn: 'Service Request Declined',
    titleAr: 'تم رفض طلب الخدمة',
    bodyEn: 'Your service request for {{serviceName}} has been reviewed and declined. Please refer to the provided remarks for further clarification, and resubmit if applicable.',
    bodyAr: 'تمت مراجعة طلب الخدمة {{serviceName}} ورفضه. يرجى الرجوع إلى الملاحظات المقدمة لمزيد من التوضيح وإعادة التقديم إذا كان ذلك مناسباً.',
    variables: {TemplateVariable.serviceName},
  ),
  requestInProgress(
    key: 'request_in_progress',
    group: '',
    titleEn: 'Service Request Currently in Progress',
    titleAr: 'طلب الخدمة قيد التنفيذ',
    bodyEn: 'Your service request for {{serviceName}} is actively being processed. You will receive a notification upon completion of the service.',
    bodyAr: 'طلب الخدمة {{serviceName}} قيد التنفيذ الفعلي حالياً. سيتم إشعارك عند اكتمال تنفيذ الخدمة.',
    variables: {TemplateVariable.serviceName},
  ),
  requestDone(
    key: 'request_done',
    group: '',
    titleEn: 'Service Request Completed Successfully',
    titleAr: 'تم إنجاز طلب الخدمة بنجاح',
    bodyEn: 'Your service request for {{serviceName}} has been completed successfully. Please review the outcome and contact the service team if any follow-up is required.',
    bodyAr: 'تم إنجاز طلب الخدمة {{serviceName}} بنجاح. يرجى مراجعة النتيجة والتواصل مع فريق الخدمة في حال الحاجة إلى أي متابعة.',
    variables: {TemplateVariable.serviceName},
  ),
  requestSlaExceed(
    key: 'request_sla_exceed',
    group: '',
    titleEn: 'Service Level Agreement Exceeded',
    titleAr: 'تم تجاوز اتفاقية مستوى الخدمة',
    bodyEn: 'Your service request for {{serviceName}} has exceeded the agreed service level timeframe. The matter is currently under review, and appropriate action will be taken to resolve it promptly.',
    bodyAr: 'تجاوز طلب الخدمة {{serviceName}} الإطار الزمني المتفق عليه في اتفاقية مستوى الخدمة. يجري حالياً مراجعة الأمر واتخاذ الإجراء المناسب لمعالجته في أقرب وقت.',
    variables: {TemplateVariable.serviceName},
  ),
  needsApproval(
    key: 'needs_approval',
    group: '',
    titleEn: 'Action Required — Service Request Pending Approval',
    titleAr: 'مطلوب إجراء — طلب خدمة بانتظار الموافقة',
    bodyEn: 'The service request for {{serviceName}} has been submitted and requires your formal review and decision. Please assess the request and take the appropriate action at your earliest convenience.',
    bodyAr: 'تم تقديم طلب الخدمة {{serviceName}} ويستلزم مراجعتك الرسمية واتخاذ القرار المناسب. يرجى تقييم الطلب واتخاذ الإجراء المناسب في أقرب وقت.',
    variables: {TemplateVariable.serviceName},
  ),
  slaApproachingManager(
    key: 'sla_approaching_manager',
    group: '',
    titleEn: 'Service Level Agreement Deadline Approaching',
    titleAr: 'اقتراب الموعد النهائي اتفاقية مستوى الخدمة',
    bodyEn: 'The service request for {{serviceName}} is approaching its SLA deadline. Immediate monitoring or intervention may be required to ensure timely resolution and compliance with service commitments.',
    bodyAr: 'يقترب طلب الخدمة {{serviceName}} من الموعد النهائي اتفاقية مستوى الخدمة. قد تكون المراقبة الفورية أو التدخل ضرورياً لضمان الحل في الوقت المناسب والالتزام بتعهدات الخدمة.',
    variables: {TemplateVariable.serviceName},
  ),
  slaBreachedManager(
    key: 'sla_breached_manager',
    group: '',
    titleEn: 'Critical Alert — Service Level Agreement Breached',
    titleAr: 'تنبيه عاجل — خرق اتفاقية مستوى الخدمة',
    bodyEn: 'The service request for {{serviceName}} has exceeded the agreed SLA. This constitutes a breach of the service commitment and requires immediate escalation and corrective action.',
    bodyAr: 'تجاوز طلب الخدمة {{serviceName}} اتفاقية مستوى الخدمة المتفق عليها. يُعدّ ذلك إخلالاً بالتزامات الخدمة ويستوجب التصعيد الفوري واتخاذ الإجراء التصحيحي.',
    variables: {TemplateVariable.serviceName},
  ),
  reviewReminderManager(
    key: 'review_reminder_manager',
    group: '',
    titleEn: 'Pending Review — Reminder Issued',
    titleAr: 'تذكير — طلب خدمة بانتظار المراجعة',
    bodyEn: 'An automated reminder has been issued regarding the service request for {{serviceName}}, which remains pending formal review. Please ensure the appropriate action is taken without further delay.',
    bodyAr: 'تم إصدار تذكير تلقائي بشأن طلب الخدمة {{serviceName}} الذي لا يزال ينتظر المراجعة الرسمية. يرجى التأكد من اتخاذ الإجراء المناسب دون مزيد من التأخير.',
    variables: {TemplateVariable.serviceName},
  ),
  newAssignmentProvider(
    key: 'new_assignment_provider',
    group: '',
    titleEn: 'New Service Request Assigned',
    titleAr: 'تم تعيين طلب خدمة جديد إليك',
    bodyEn: 'A new service request for {{serviceName}} has been formally assigned to you for execution. Please review the request details and proceed with fulfilment in accordance with the agreed service level.',
    bodyAr: 'تم تعيين طلب خدمة جديد لـ {{serviceName}} إليك رسمياً للتنفيذ. يرجى مراجعة تفاصيل الطلب والمضي في التنفيذ وفقاً مستوى الخدمة المتفق عليه.',
    variables: {TemplateVariable.serviceName},
  ),
  slaReminderProvider(
    key: 'sla_reminder_provider',
    group: '',
    titleEn: 'Service Level Agreement Reminder',
    titleAr: 'تذكير بـ اتفاقية مستوى الخدمة',
    bodyEn: 'This is a reminder that the service request for {{serviceName}} is approaching its SLA deadline. Please prioritize its completion to ensure full compliance with the agreed service timeframe.',
    bodyAr: 'هذا تذكير بأن طلب الخدمة {{serviceName}} يقترب من الموعد النهائي اتفاقية مستوى الخدمة. يرجى إيلاء أولوية لإنجازه لضمان الامتثال الكامل للإطار الزمني المتفق عليه.',
    variables: {TemplateVariable.serviceName},
  ),
  requestCancelled(
    key: 'request_cancelled',
    group: '',
    titleEn: 'Service Request Cancelled',
    titleAr: 'تم إلغاء طلب الخدمة',
    bodyEn: 'The service request for {{serviceName}} has been formally cancelled. No further action is required on your part. Please update your task queue accordingly.',
    bodyAr: 'تم إلغاء طلب الخدمة {{serviceName}} رسمياً. لا يُستلزم اتخاذ أي إجراء إضافي من جانبك. يرجى تحديث قائمة مهامك وفقاً لذلك.',
    variables: {TemplateVariable.serviceName},
  ),
  completionConfirmedProvider(
    key: 'completion_confirmed_provider',
    group: '',
    titleEn: 'Service Completed — Status Update Required',
    titleAr: 'تم إنجاز الخدمة — مطلوب تحديث الحالة',
    bodyEn: 'The service request for {{serviceName}} has been successfully completed. Please update the request status to reflect the completion and proceed with any required next steps.',
    bodyAr: 'تم إنجاز طلب الخدمة {{serviceName}} بنجاح. يرجى تحديث حالة الطلب لتعكس الإنجاز والمضي في أي خطوات تالية مطلوبة.',
    variables: {TemplateVariable.serviceName},
  );

  const ServicesNotificationEvent({
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
  AppModule get module => AppModule.services;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static ServicesNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
