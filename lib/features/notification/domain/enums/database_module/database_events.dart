/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: database_events.dart
/// Purpose: Notification event catalog: database events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: database_events.dart
/// Module:    Database Management
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

enum DatabaseNotificationEvent implements NotificationEvent {
  databaseCreated(
    key: 'database_created',
    group: '',
    titleEn: 'New Database Created',
    titleAr: 'تم إنشاء قاعدة بيانات جديدة',
    bodyEn: '{{employeeName}} has created the database {{databaseName}}. The database is now accessible. You may proceed to define tables, configure access permissions, and manage data as required.',
    bodyAr: 'قام {{employeeName}} بإنشاء قاعدة البيانات {{databaseName}}. أصبحت قاعدة البيانات متاحة. يمكنك الآن تحديد الجداول وتهيئة أذونات الوصول وإدارة البيانات حسب الحاجة.',
    variables: {TemplateVariable.employeeName, TemplateVariable.databaseName},
  ),
  tableCreated(
    key: 'table_created',
    group: '',
    titleEn: 'New Table Added to Database',
    titleAr: 'تمت إضافة جدول جديد إلى قاعدة البيانات',
    bodyEn: '{{employeeName}} has created the table {{tableName}} within {{databaseName}}. The table is now available for data entry, field configuration, and access management.',
    bodyAr: 'قام {{employeeName}} بإنشاء الجدول {{tableName}} داخل {{databaseName}}. أصبح الجدول متاحاً الآن لإدخال البيانات وتهيئة الحقول وإدارة الوصول.',
    variables: {TemplateVariable.employeeName, TemplateVariable.tableName, TemplateVariable.databaseName},
  ),
  tableUpdated(
    key: 'table_updated',
    group: '',
    titleEn: 'Table Details Updated',
    titleAr: 'تم تحديث تفاصيل الجدول',
    bodyEn: '{{employeeName}} has updated the details of {{tableName}}. Changes may include modifications to the table name, description, or associated metadata. Please review the updates as necessary.',
    bodyAr: 'قام {{employeeName}} بتحديث تفاصيل الجدول {{tableName}}. قد تشمل التغييرات تعديلات على اسم الجدول أو وصفه أو البيانات الوصفية المرتبطة به. يرجى مراجعة التحديثات عند الحاجة.',
    variables: {TemplateVariable.employeeName, TemplateVariable.tableName},
  ),
  accessGranted(
    key: 'access_granted',
    group: '',
    titleEn: 'Database Access Rights Granted',
    titleAr: 'تم منح حقوق الوصول إلى قاعدة البيانات',
    bodyEn: 'You have been granted {{permissionLevel}} access to {{databaseName}} / {{tableName}}, effective from {{startDate}} to {{endDate}}. Please ensure access is exercised in compliance with the applicable data governance policy.',
    bodyAr: 'تم منحك صلاحية {{permissionLevel}} على {{databaseName}} / {{tableName}} اعتباراً من {{startDate}} حتى {{endDate}}. يرجى التأكد من ممارسة الوصول وفقاً لسياسة حوكمة البيانات المعمول بها.',
    variables: {TemplateVariable.permissionLevel, TemplateVariable.databaseName, TemplateVariable.tableName, TemplateVariable.startDate, TemplateVariable.endDate},
  ),
  accessUpdated(
    key: 'access_updated',
    group: '',
    titleEn: 'Database Access Permissions Revised',
    titleAr: 'تم تعديل أذونات الوصول إلى قاعدة البيانات',
    bodyEn: 'Your access permissions for {{databaseName}} / {{tableName}} have been updated. Please review the revised access scope to understand any changes to your authorised data interactions.',
    bodyAr: 'تم تعديل أذونات وصولك إلى {{databaseName}} / {{tableName}}. يرجى مراجعة نطاق الوصول المعدّل لفهم أي تغييرات طرأت على تفاعلاتك المرخّصة مع البيانات.',
    variables: {TemplateVariable.databaseName, TemplateVariable.tableName},
  ),
  accessRevoked(
    key: 'access_revoked',
    group: '',
    titleEn: 'Database Access Rights Revoked',
    titleAr: 'تم سحب حقوق الوصول إلى قاعدة البيانات',
    bodyEn: 'Your access to {{databaseName}} / {{tableName}} has been formally revoked by {{employeeName}}. You no longer have authorisation to view or interact with the associated data.',
    bodyAr: 'تم سحب صلاحية وصولك إلى {{databaseName}} / {{tableName}} رسمياً بواسطة {{employeeName}}. لم يعد لديك تفويض لعرض البيانات المرتبطة أو التفاعل معها.',
    variables: {TemplateVariable.databaseName, TemplateVariable.tableName, TemplateVariable.employeeName},
  ),
  accessExpired(
    key: 'access_expired',
    group: '',
    titleEn: 'Database Access Period Expired',
    titleAr: 'انتهاء فترة الوصول إلى قاعدة البيانات',
    bodyEn: 'Your authorised access to {{databaseName}} / {{tableName}} has reached its expiration date and has been automatically terminated. Please contact your system administrator if a renewal is required.',
    bodyAr: 'انتهت فترة وصولك المرخّص إلى {{databaseName}} / {{tableName}} وتم إنهاؤها تلقائياً. يرجى التواصل مع مسؤول النظام إذا كان التجديد مطلوباً.',
    variables: {TemplateVariable.databaseName, TemplateVariable.tableName},
  ),
  viewableFieldsUpdated(
    key: 'viewable_fields_updated',
    group: '',
    titleEn: 'Data Visibility Permissions Updated',
    titleAr: 'تم تحديث أذونات عرض البيانات',
    bodyEn: 'The fields available for viewing within {{tableName}} have been updated. Your data visibility scope has been adjusted accordingly. Please log in to review the revised field access.',
    bodyAr: 'تم تعديل الحقول المتاحة للعرض داخل جدول {{tableName}}. تم تعديل نطاق رؤيتك للبيانات وفقاً لذلك. يرجى تسجيل الدخول لمراجعة وصول الحقول المعدّل.',
    variables: {TemplateVariable.tableName},
  ),
  commentAdded(
    key: 'comment_added',
    group: '',
    titleEn: 'New Comment Posted',
    titleAr: 'تم نشر تعليق جديد',
    bodyEn: '{{employeeName}} has added a comment to {{databaseName}} / {{tableName}}. Please review the comment at your earliest convenience and respond if required.',
    bodyAr: 'قام {{employeeName}} بإضافة تعليق على {{databaseName}} / {{tableName}}. يرجى مراجعة التعليق في أقرب وقت والرد عليه إذا كان ذلك مطلوباً.',
    variables: {TemplateVariable.employeeName, TemplateVariable.databaseName, TemplateVariable.tableName},
  ),
  bulkAccessUpdate(
    key: 'bulk_access_update',
    group: '',
    titleEn: 'Bulk Access Permissions Update Executed',
    titleAr: 'تم تنفيذ تحديث جماعي أذونات الوصول',
    bodyEn: 'Access permissions for multiple employees have been updated for {{databaseName}} / {{tableName}} by {{employeeName}}. Affected users will receive individual notifications reflecting their updated access rights.',
    bodyAr: 'تم تحديث أذونات الوصول لعدد من الموظفين على {{databaseName}} / {{tableName}} بواسطة {{employeeName}}. سيتلقى المستخدمون المتأثرون إشعارات فردية تعكس حقوق وصولهم المحدّثة.',
    variables: {TemplateVariable.databaseName, TemplateVariable.tableName, TemplateVariable.employeeName},
  ),
  tableStructureUpdated(
    key: 'table_structure_updated',
    group: '',
    titleEn: 'Table Structure Modified',
    titleAr: 'تم تعديل هيكل الجدول',
    bodyEn: 'The structural configuration of {{tableName}} has been modified. These changes may affect how data is displayed, entered, or managed. Please review the updated structure before proceeding.',
    bodyAr: 'تم تعديل التهيئة الهيكلية للجدول {{tableName}}. قد تؤثر هذه التغييرات على طريقة عرض البيانات أو إدخالها أو إدارتها. يرجى مراجعة الهيكل المحدّث قبل المتابعة.',
    variables: {TemplateVariable.tableName},
  ),
  columnAdded(
    key: 'column_added',
    group: '',
    titleEn: 'New Column Added to Table',
    titleAr: 'تمت إضافة عمود جديد إلى الجدول',
    bodyEn: 'A new column, {{columnName}}, has been successfully added to {{tableName}}. Please review the updated table structure to ensure alignment with your data requirements.',
    bodyAr: 'تمت إضافة عمود جديد باسم {{columnName}} بنجاح إلى الجدول {{tableName}}. يرجى مراجعة هيكل الجدول المحدّث للتأكد من توافقه مع متطلبات بياناتك.',
    variables: {TemplateVariable.columnName, TemplateVariable.tableName},
  ),
  tableDeleted(
    key: 'table_deleted',
    group: '',
    titleEn: 'Table Permanently Removed',
    titleAr: 'تم حذف الجدول نهائياً',
    bodyEn: 'The table {{tableName}} has been permanently removed from {{databaseName}}. This action is irreversible. If this deletion was made in error, please contact your system administrator immediately.',
    bodyAr: 'تم حذف الجدول {{tableName}} نهائياً من قاعدة البيانات {{databaseName}}. هذا الإجراء لا رجعة فيه. إذا تم الحذف عن طريق الخطأ يرجى التواصل مع مسؤول النظام فوراً.',
    variables: {TemplateVariable.tableName, TemplateVariable.databaseName},
  );

  const DatabaseNotificationEvent({
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
  AppModule get module => AppModule.database;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static DatabaseNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
