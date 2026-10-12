// ****************** FILE INFO ******************
// File Name: crm_controls_defaults.dart
// Purpose: Default CRM client types and field type catalog seed data
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';

abstract class CrmControlsDefaults {
  static List<CrmFieldTypeModel> fieldTypesForClientType(String clientTypeId) {
    final List<CrmFieldTypeModel> items =
        fieldTypes().where((CrmFieldTypeModel type) {
      return type.isAllowedForClientType(clientTypeId);
    }).toList();
    items.sort(
      (CrmFieldTypeModel a, CrmFieldTypeModel b) => a.order.compareTo(b.order),
    );
    return items;
  }

  static List<String> expectedFieldTypeIdsForClientType(String clientTypeId) {
    return fieldTypesForClientType(clientTypeId)
        .map((CrmFieldTypeModel type) => type.id)
        .toList()
      ..sort();
  }

  static List<CrmClientTypeModel> clientTypes({
    required String userEmail,
  }) {
    final CrmAuditModel audit = CrmAuditModel.now(userEmail: userEmail);
    return [
      CrmClientTypeModel(
        id: 'government',
        title: 'Government',
        nameEn: 'Government',
        nameAr: 'الجهات الحكومية',
        svgAsset: AppAssets.crmGovernment,
        iconKey: 'crmGovernment',
        systemKey: 'government',
        isDefault: true,
        order: 1,
        audit: audit,
      ),
      CrmClientTypeModel(
        id: 'person',
        title: 'Person',
        nameEn: 'Person',
        nameAr: 'فرد',
        svgAsset: AppAssets.crmPerson,
        iconKey: 'crmPerson',
        systemKey: 'person',
        isDefault: true,
        order: 2,
        audit: audit,
      ),
      CrmClientTypeModel(
        id: 'company',
        title: 'Company',
        nameEn: 'Company',
        nameAr: 'شركة',
        svgAsset: AppAssets.crmCompanies,
        iconKey: 'crmCompanies',
        systemKey: 'company',
        isDefault: true,
        order: 3,
        audit: audit,
      ),
    ];
  }

  static List<CrmFieldTypeModel> fieldTypes() {
    const List<String> shared = ['*'];
    const List<String> companyOnly = ['company'];
    const List<String> governmentOnly = ['government'];
    const List<String> personOnly = ['person'];
    const List<String> defaultTypes = ['person', 'company', 'government'];
    return const [
      CrmFieldTypeModel(
        id: 'image',
        nameEn: 'Image',
        nameAr: 'صورة',
        iconKey: 'image',
        valueType: 'string',
        inputType: 'image',
        allowedClientTypeIds: shared,
        order: 1,
      ),
      CrmFieldTypeModel(
        id: 'text',
        nameEn: 'Text Field',
        nameAr: 'حقل نص',
        iconKey: 'text',
        valueType: 'string',
        inputType: 'text',
        allowedClientTypeIds: shared,
        order: 2,
      ),
      CrmFieldTypeModel(
        id: 'email',
        nameEn: 'Email',
        nameAr: 'البريد الإلكتروني',
        iconKey: 'email',
        valueType: 'string',
        inputType: 'email',
        allowedClientTypeIds: shared,
        order: 3,
      ),
      CrmFieldTypeModel(
        id: 'phone',
        nameEn: 'Phone',
        nameAr: 'الهاتف',
        iconKey: 'phone',
        valueType: 'string',
        inputType: 'phone',
        allowedClientTypeIds: shared,
        order: 4,
      ),
      CrmFieldTypeModel(
        id: 'address',
        nameEn: 'Address',
        nameAr: 'العنوان',
        iconKey: 'address',
        valueType: 'map',
        inputType: 'address',
        allowedClientTypeIds: shared,
        order: 5,
      ),
      CrmFieldTypeModel(
        id: 'dropdown',
        nameEn: 'Drop Down',
        nameAr: 'قائمة منسدلة',
        iconKey: 'dropdown',
        valueType: 'string',
        inputType: 'dropdown',
        allowedClientTypeIds: shared,
        order: 6,
      ),
      CrmFieldTypeModel(
        id: 'radio',
        nameEn: 'Radio',
        nameAr: 'اختيار واحد',
        iconKey: 'radio',
        valueType: 'string',
        inputType: 'radio',
        allowedClientTypeIds: shared,
        order: 7,
      ),
      CrmFieldTypeModel(
        id: 'checkbox',
        nameEn: 'Check Box',
        nameAr: 'مربع اختيار',
        iconKey: 'checkbox',
        valueType: 'bool',
        inputType: 'checkbox',
        allowedClientTypeIds: shared,
        order: 8,
      ),
      CrmFieldTypeModel(
        id: 'description',
        nameEn: 'Description',
        nameAr: 'وصف',
        iconKey: 'description',
        valueType: 'string',
        inputType: 'description',
        allowedClientTypeIds: shared,
        order: 9,
      ),
      CrmFieldTypeModel(
        id: 'attachment',
        nameEn: 'Attachment',
        nameAr: 'مرفق',
        iconKey: 'attachment',
        valueType: 'list',
        inputType: 'attachment',
        allowedClientTypeIds: shared,
        order: 10,
      ),
      CrmFieldTypeModel(
        id: 'link',
        nameEn: 'Link',
        nameAr: 'رابط',
        iconKey: 'link',
        valueType: 'string',
        inputType: 'link',
        allowedClientTypeIds: shared,
        order: 11,
      ),
      CrmFieldTypeModel(
        id: 'digital_signature',
        nameEn: 'Attached Digital Signature',
        nameAr: 'توقيع رقمي مرفق',
        iconKey: 'signature',
        valueType: 'string',
        inputType: 'signature',
        allowedClientTypeIds: shared,
        order: 12,
      ),
      CrmFieldTypeModel(
        id: 'date',
        nameEn: 'Date Selector',
        nameAr: 'اختيار التاريخ',
        iconKey: 'date',
        valueType: 'timestamp',
        inputType: 'date',
        allowedClientTypeIds: shared,
        order: 13,
      ),
      CrmFieldTypeModel(
        id: 'time',
        nameEn: 'Time Selector',
        nameAr: 'اختيار الوقت',
        iconKey: 'time',
        valueType: 'string',
        inputType: 'time',
        allowedClientTypeIds: shared,
        order: 14,
      ),
      CrmFieldTypeModel(
        id: 'switch',
        nameEn: 'Switch',
        nameAr: 'مفتاح',
        iconKey: 'switch',
        valueType: 'bool',
        inputType: 'switch',
        allowedClientTypeIds: shared,
        order: 15,
      ),
      CrmFieldTypeModel(
        id: 'tag',
        nameEn: 'Tag',
        nameAr: 'وسم',
        iconKey: 'tag',
        valueType: 'list',
        inputType: 'tag',
        allowedClientTypeIds: shared,
        order: 16,
      ),
      CrmFieldTypeModel(
        id: 'company_size',
        nameEn: 'Company Size',
        nameAr: 'حجم الشركة',
        iconKey: 'companySize',
        valueType: 'string',
        inputType: 'dropdown',
        allowedClientTypeIds: companyOnly,
        order: 17,
      ),
      CrmFieldTypeModel(
        id: 'website',
        nameEn: 'Website',
        nameAr: 'الموقع الإلكتروني',
        iconKey: 'website',
        valueType: 'string',
        inputType: 'link',
        allowedClientTypeIds: ['company', 'government'],
        order: 18,
      ),
      CrmFieldTypeModel(
        id: 'sector',
        nameEn: 'Sector',
        nameAr: 'القطاع',
        iconKey: 'sector',
        valueType: 'string',
        inputType: 'dropdown',
        allowedClientTypeIds: governmentOnly,
        order: 19,
      ),
      CrmFieldTypeModel(
        id: 'industry',
        nameEn: 'Industry',
        nameAr: 'الصناعة',
        iconKey: 'industry',
        valueType: 'string',
        inputType: 'dropdown',
        allowedClientTypeIds: companyOnly,
        order: 20,
      ),
      CrmFieldTypeModel(
        id: 'preferred_language',
        nameEn: 'Preferred Language',
        nameAr: 'اللغة المفضلة',
        iconKey: 'preferredLanguage',
        valueType: 'string',
        inputType: 'dropdown',
        allowedClientTypeIds: personOnly,
        order: 21,
      ),
      CrmFieldTypeModel(
        id: 'business_initiation_date',
        nameEn: 'Business Initiation Date',
        nameAr: 'تاريخ بدء التعامل',
        iconKey: 'date',
        valueType: 'timestamp',
        inputType: 'date',
        allowedClientTypeIds: defaultTypes,
        order: 22,
      ),
      CrmFieldTypeModel(
        id: 'purchasing_value',
        nameEn: 'Purchasing Value',
        nameAr: 'قيمة الشراء',
        iconKey: 'purchasingValue',
        valueType: 'num',
        inputType: 'text',
        allowedClientTypeIds: defaultTypes,
        order: 23,
      ),
    ];
  }
}
