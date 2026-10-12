// ****************** FILE INFO ******************
// File Name: crm_template_demo_data.dart
// Purpose: Demo data models used to render CRM template control screens.
// Author: Mohand Adel
// Created At: 04/08/2026

class CrmTemplateSummaryData {
  const CrmTemplateSummaryData({
    required this.name,
    required this.author,
    required this.createdAt,
    required this.fieldCount,
    required this.status,
  });

  final String name;
  final String author;
  final String createdAt;
  final int fieldCount;
  final String status;
}

class CrmTemplateElementData {
  const CrmTemplateElementData({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.badgeCount,
    this.isSection = false,
  });

  final String title;
  final String subtitle;
  final String assetPath;
  final int? badgeCount;
  final bool isSection;
}

class CrmTemplatePreviewFieldData {
  const CrmTemplatePreviewFieldData({
    required this.label,
    required this.placeholder,
    this.value,
    this.isValidated = false,
    this.isImage = false,
    this.isPhone = false,
  });

  final String label;
  final String placeholder;
  final String? value;
  final bool isValidated;
  final bool isImage;
  final bool isPhone;
}

class CrmTemplatePreviewSectionData {
  const CrmTemplatePreviewSectionData({
    required this.title,
    required this.fields,
    this.showImage = false,
  });

  final String title;
  final List<CrmTemplatePreviewFieldData> fields;
  final bool showImage;
}

class CrmTemplatePreviewPageData {
  const CrmTemplatePreviewPageData({
    required this.title,
    required this.sections,
  });

  final String title;
  final List<CrmTemplatePreviewSectionData> sections;
}

abstract class CrmTemplateDemoData {
  static const List<String> clientTypeTabs = <String>[
    'Individuals',
    'Company',
    'Government',
    'X Type',
  ];

  static const List<CrmTemplateSummaryData> templates =
      <CrmTemplateSummaryData>[
    CrmTemplateSummaryData(
      name: 'Temp Name',
      author: 'Aya Ahmed',
      createdAt: '7/12/2026',
      fieldCount: 5,
      status: 'Inactive',
    ),
    CrmTemplateSummaryData(
      name: 'Temp Name',
      author: 'Aya Ahmed',
      createdAt: '7/12/2026',
      fieldCount: 5,
      status: 'Active',
    ),
    CrmTemplateSummaryData(
      name: 'Temp Name',
      author: 'Aya Ahmed',
      createdAt: '7/12/2026',
      fieldCount: 5,
      status: 'Active',
    ),
    CrmTemplateSummaryData(
      name: 'Temp Name',
      author: 'Aya Ahmed',
      createdAt: '7/12/2026',
      fieldCount: 5,
      status: 'Active',
    ),
    CrmTemplateSummaryData(
      name: 'Temp Name',
      author: 'Aya Ahmed',
      createdAt: '7/12/2026',
      fieldCount: 5,
      status: 'Active',
    ),
    CrmTemplateSummaryData(
      name: 'Temp Name',
      author: 'Aya Ahmed',
      createdAt: '7/12/2026',
      fieldCount: 5,
      status: 'Inactive',
    ),
  ];
}
