// ****************** FILE INFO ******************
// File Name: crm_template_defaults.dart
// Purpose: Default sections and fields for CRM template drafts
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

abstract class CrmTemplateDefaults {
  /// Version of the default sections/fields catalog below. Bump this whenever
  /// the defaults change so that existing templates are re-synced once on the
  /// next app session (see
  /// `CrmTemplatesRemoteDataSource.syncDefaultsForAllTemplates`).
  static const int defaultsVersion = 1;

  static const List<Map<String, String>> standardDecisionRoleOptions =
      <Map<String, String>>[
    {'en': 'Decision Maker', 'ar': 'صانع القرار'},
    {'en': 'Final Approver', 'ar': 'المعتمد النهائي'},
    {'en': 'Budget Holder', 'ar': 'المسؤول عن الميزانية'},
    {'en': 'Technical Evaluator', 'ar': 'المقيم الفني'},
    {'en': 'Technical Contact', 'ar': 'جهة الاتصال الفنية'},
    {'en': 'Business Stakeholder', 'ar': 'المعني بالأعمال'},
    {'en': 'Influencer', 'ar': 'المؤثر'},
    {'en': 'Recommender', 'ar': 'الموصي'},
    {'en': 'End User', 'ar': 'المستخدم النهائي'},
    {'en': 'Gatekeeper', 'ar': 'حارس البوابة'},
    {'en': 'Procurement Contact', 'ar': 'جهة الاتصال للمشتريات'},
    {'en': 'Executive Sponsor', 'ar': 'الراعي التنفيذي'},
    {'en': 'Primary Contact', 'ar': 'جهة الاتصال الرئيسية'},
    {'en': 'Secondary Contact', 'ar': 'جهة الاتصال الثانوية'},
    {'en': 'Billing Contact', 'ar': 'جهة الاتصال للفوترة'},
    {'en': 'Legal Contact', 'ar': 'جهة الاتصال القانونية'},
    {'en': 'Other', 'ar': 'أخرى'},
  ];

  static const List<Map<String, String>> standardPhoneTypeOptions =
      <Map<String, String>>[
    {'en': 'Mobile', 'ar': 'جوال'},
    {'en': 'Work', 'ar': 'عمل'},
    {'en': 'Office', 'ar': 'مكتب'},
    {'en': 'Direct Line', 'ar': 'خط مباشر'},
    {'en': 'Home', 'ar': 'منزل'},
    {'en': 'Fax', 'ar': 'فاكس'},
    {'en': 'WhatsApp', 'ar': 'واتساب'},
    {'en': 'Extension', 'ar': 'تحويلة'},
    {'en': 'Other', 'ar': 'أخرى'},
  ];

  static String pointOfContactSectionId(String templateId) {
    return '${templateId}_point_of_contact';
  }

  static String addressSectionId(String templateId) {
    return '${templateId}_address';
  }

  static List<CrmTemplateSectionModel> sections({
    required String templateId,
    required String clientTypeId,
    required String userEmail,
  }) {
    final CrmAuditModel audit = CrmAuditModel.now(userEmail: userEmail);
    return [
      CrmTemplateSectionModel(
        id: pointOfContactSectionId(templateId),
        templateId: templateId,
        clientTypeId: clientTypeId,
        nameEn: 'Point of Contact',
        nameAr: 'نقطة الاتصال',
        systemKey: 'point_of_contact',
        isDefault: true,
        order: 1,
        audit: audit,
      ),
      CrmTemplateSectionModel(
        id: addressSectionId(templateId),
        templateId: templateId,
        clientTypeId: clientTypeId,
        nameEn: 'Address',
        nameAr: 'العنوان',
        systemKey: 'address',
        isDefault: true,
        order: 2,
        audit: audit,
      ),
    ];
  }

  static List<CrmTemplateFieldModel> fields({
    required String templateId,
    required String clientTypeId,
    required String userEmail,
  }) {
    final CrmAuditModel audit = CrmAuditModel.now(userEmail: userEmail);
    final String poc = pointOfContactSectionId(templateId);
    final String address = addressSectionId(templateId);
    return [
      _field(templateId, clientTypeId, poc, 'first_name', 'text', 'First Name',
          'الاسم الأول', 1, audit,
          isRequired: true, maxLengthEnabled: true),
      _field(templateId, clientTypeId, poc, 'last_name', 'text', 'Last Name',
          'اسم العائلة', 2, audit,
          isRequired: true, maxLengthEnabled: true),
      _field(templateId, clientTypeId, poc, 'job_title', 'text', 'Job Title',
          'المسمى الوظيفي', 3, audit,
          isRequired: true, showBothLanguages: false, maxLengthEnabled: true),
      _field(templateId, clientTypeId, poc, 'department', 'dropdown',
          'Department', 'القسم', 4, audit,
          allowSearch: false,
          optionRows: const [
            {'en': '', 'ar': ''},
          ]),
      _field(templateId, clientTypeId, poc, 'decision_role', 'dropdown',
          'Decision Role', 'دور القرار', 5, audit,
          isRequired: true,
          allowSearch: false,
          optionRows: standardDecisionRoleOptions),
      _field(
        templateId,
        clientTypeId,
        poc,
        'preferred_contact_channel',
        'dropdown',
        'Preferred Contact Channel',
        'قناة التواصل المفضلة',
        6,
        audit,
        allowSearch: false,
        optionRows: const [
          {'en': 'Email', 'ar': 'البريد الإلكتروني'},
          {'en': 'Phone Call', 'ar': 'مكالمة هاتفية'},
          {'en': 'WhatsApp', 'ar': 'واتساب'},
          {'en': 'SMS', 'ar': 'رسالة نصية'},
          {'en': 'LinkedIn', 'ar': 'لينكد إن'},
        ],
      ),
      _field(templateId, clientTypeId, poc, 'email', 'email', 'Email',
          'البريد الإلكتروني', 7, audit,
          isRequired: true,
          allowMultiple: true,
          unique: true,
          maxLengthEnabled: true,
          formatExample: ''),
      _field(templateId, clientTypeId, poc, 'phone_number', 'phone',
          'Phone Number', 'رقم الهاتف', 8, audit,
          isRequired: true,
          allowMultiple: true,
          unique: true,
          maxLengthEnabled: true,
          formatExample: ''),
      _field(templateId, clientTypeId, poc, 'phone_type', 'dropdown',
          'Phone Type', 'نوع الهاتف', 9, audit,
          allowSearch: false, optionRows: standardPhoneTypeOptions),
      _field(templateId, clientTypeId, address, 'country', 'address', 'Country',
          'الدولة', 1, audit,
          isRequired: true,
          addressComponent: 'Country',
          supportedDataScope: 'continents_countries',
          addressSelectors: const ['Continents', 'Countries']),
      _field(templateId, clientTypeId, address, 'city', 'address', 'City',
          'المدينة', 2, audit,
          addressComponent: 'City',
          supportedDataScope: 'countries_cities',
          addressSelectors: const ['Countries', 'Cities']),
      _field(templateId, clientTypeId, address, 'state_province', 'address',
          'State / Province', 'الولاية / المحافظة', 3, audit,
          addressComponent: 'State / Province',
          supportedDataScope: 'countries_cities',
          addressSelectors: const ['Countries', 'Cities']),
      _field(templateId, clientTypeId, address, 'postal_zip_code', 'address',
          'Postal / ZIP Code', 'الرمز البريدي', 4, audit,
          addressComponent: 'Postal / ZIP Code',
          supportedDataScope: 'countries_cities',
          addressSelectors: const ['Countries', 'Cities']),
    ];
  }

  static CrmTemplateFieldModel _field(
    String templateId,
    String clientTypeId,
    String sectionId,
    String systemKey,
    String fieldTypeId,
    String nameEn,
    String nameAr,
    int order,
    CrmAuditModel audit, {
    bool isRequired = false,
    bool showBothLanguages = true,
    bool allowSearch = false,
    bool allowMultiple = false,
    bool unique = false,
    bool maxLengthEnabled = false,
    String formatExample = '',
    String addressComponent = '',
    String supportedDataScope = '',
    List<String> addressSelectors = const [],
    List<Map<String, String>> optionRows = const [],
  }) {
    final List<String> options = optionRows
        .map((Map<String, String> option) => option['en'] ?? '')
        .where((String value) => value.isNotEmpty)
        .toList();
    final Map<String, dynamic> configuration = {
      CrmFirestoreKeys.FIELD_KIND_KEY: fieldTypeId,
      CrmFirestoreKeys.IS_ENABLED_KEY: true,
      CrmFirestoreKeys.TRIM_SPACES_KEY: true,
      CrmFirestoreKeys.ENABLE_SEARCH_KEY: allowSearch,
      CrmFirestoreKeys.ALLOW_SEARCH_KEY: allowSearch,
      CrmFirestoreKeys.ALLOW_MULTIPLE_VALUES_KEY: allowMultiple,
      CrmFirestoreKeys.ALLOW_MULTIPLE_KEY: allowMultiple,
      CrmFirestoreKeys.IS_UNIQUE_KEY: unique,
      CrmFirestoreKeys.UNIQUE_KEY: unique,
      CrmFirestoreKeys.MAX_LENGTH_ENABLED_KEY: maxLengthEnabled,
      CrmFirestoreKeys.MAX_LENGTH_KEY: null,
      CrmFirestoreKeys.FORMAT_EXAMPLE_KEY: formatExample,
      if (fieldTypeId == 'address')
        CrmFirestoreKeys.ALLOW_SPECIAL_CHARACTERS_KEY: true,
      if (addressComponent.isNotEmpty)
        CrmFirestoreKeys.ADDRESS_COMPONENT_KEY: addressComponent,
      if (addressSelectors.isNotEmpty)
        CrmFirestoreKeys.ADDRESS_COMPONENTS_KEY: addressSelectors,
      if (supportedDataScope.isNotEmpty)
        CrmFirestoreKeys.SUPPORTED_DATA_SCOPE_KEY: supportedDataScope,
      if (optionRows.isNotEmpty)
        CrmFirestoreKeys.DEFAULT_OPTIONS_KEY: _options(optionRows),
    };

    return CrmTemplateFieldModel(
      id: '${sectionId}_$systemKey',
      templateId: templateId,
      clientTypeId: clientTypeId,
      sectionId: sectionId,
      fieldTypeId: fieldTypeId,
      nameEn: nameEn,
      nameAr: nameAr,
      isRequired: isRequired,
      showBothLanguages: showBothLanguages,
      options: options,
      systemKey: systemKey,
      isDefault: true,
      configuration: configuration,
      order: order,
      audit: audit,
    );
  }

  static List<Map<String, dynamic>> _options(
    List<Map<String, String>> optionRows,
  ) {
    return List<Map<String, dynamic>>.generate(optionRows.length, (int index) {
      final Map<String, String> row = optionRows[index];
      return {
        CrmFirestoreKeys.OPTION_ID_KEY: 'option_${index + 1}',
        CrmFirestoreKeys.OPTION_LABEL_EN_KEY: row['en'] ?? '',
        CrmFirestoreKeys.OPTION_LABEL_AR_KEY: row['ar'] ?? '',
        CrmFirestoreKeys.OPTION_IS_DEFAULT_KEY: true,
        CrmFirestoreKeys.OPTION_IS_DELETED_KEY: false,
        CrmFirestoreKeys.OPTION_ORDER_KEY: index + 1,
      };
    });
  }
}
