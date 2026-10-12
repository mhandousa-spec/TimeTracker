// ****************** FILE INFO ******************
// File Name: crm_template_preview_page.dart
// Purpose: Preview page for CRM control templates.
// Author: Mohand Adel
// Created At: 04/08/2026

import 'dart:io';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_demo_data.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_shared_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplatePreviewPage extends StatefulWidget {
  const CrmTemplatePreviewPage({
    required this.templateName,
    required this.clientType,
    this.layoutPages,
    this.templateSections = const <CrmTemplateSectionModel>[],
    this.templateFields = const <CrmTemplateFieldModel>[],
    super.key,
  });

  final String templateName;
  final String clientType;
  final dynamic layoutPages;

  /// Sections from the Firestore template, used to auto-populate fields
  /// under each section in the preview.
  final List<CrmTemplateSectionModel> templateSections;

  /// Fields from the Firestore template, keyed by sectionId,
  /// auto-placed under each section in the preview.
  final List<CrmTemplateFieldModel> templateFields;

  @override
  State<CrmTemplatePreviewPage> createState() => _CrmTemplatePreviewPageState();
}

class _CrmTemplatePreviewPageState extends State<CrmTemplatePreviewPage> {
  late List<CrmTemplatePreviewPageData> _pagesData;
  late List<bool> _expandedPages;

  @override
  void initState() {
    super.initState();
    _pagesData = _buildPreviewPages();
    _expandedPages = List<bool>.filled(_pagesData.length, true);
  }

  List<CrmTemplatePreviewPageData> _buildPreviewPages() {
    if (widget.layoutPages is! List || (widget.layoutPages as List).isEmpty) {
      return _defaultPages;
    }

    // Build a lookup map: sectionId -> sorted list of fields.
    final Map<String, List<CrmTemplateFieldModel>> fieldsBySectionId =
        <String, List<CrmTemplateFieldModel>>{};
    for (final CrmTemplateFieldModel field in widget.templateFields) {
      if (field.sectionId != null && !field.isDeleted) {
        fieldsBySectionId
            .putIfAbsent(field.sectionId!, () => <CrmTemplateFieldModel>[])
            .add(field);
      }
    }
    // Sort fields within each section by order.
    for (final List<CrmTemplateFieldModel> list in fieldsBySectionId.values) {
      list.sort(
        (CrmTemplateFieldModel a, CrmTemplateFieldModel b) =>
            a.order.compareTo(b.order),
      );
    }

    final List<CrmTemplatePreviewPageData> result =
        <CrmTemplatePreviewPageData>[];
    final dynamic rawPages = widget.layoutPages;

    for (final dynamic rawPage in rawPages) {
      final String pageTitle = (rawPage.title as String?) ?? 'Page';
      final List<CrmTemplatePreviewSectionData> sections =
          <CrmTemplatePreviewSectionData>[];

      final dynamic rows = rawPage.rows;
      if (rows is List) {
        for (final dynamic row in rows) {
          final bool isSectionMode = (row.isSectionMode as bool?) ?? false;
          final dynamic col1 = row.column1;
          final dynamic col2 = row.column2;
          final String rowTitle = (row.title as String?) ?? '';

          if (isSectionMode && col1 != null && col1.selectedItemName != null) {
            // ── Section row ──────────────────────────────────────────────────
            final String secName = col1.selectedItemName as String;
            final String secId = (col1.selectedItemId as String?) ?? '';

            // Auto-populate fields that belong to this section from Firestore.
            final List<CrmTemplatePreviewFieldData> sectionFields =
                _buildSectionFields(secId, fieldsBySectionId);

            sections.add(
              CrmTemplatePreviewSectionData(
                title: secName,
                showImage: _sectionShowsImage(secName),
                fields: sectionFields,
              ),
            );
          } else {
            // ── Field row ────────────────────────────────────────────────────
            // Each custom field row (e.g. First Row, Second Row, etc.) gets
            // its own separate section / white container card.
            final List<CrmTemplatePreviewFieldData> rowFields =
                <CrmTemplatePreviewFieldData>[];

            if (col1 != null && col1.selectedItemName != null) {
              final String name = col1.selectedItemName as String;
              rowFields.add(_createFieldData(name));
            }
            if (col2 != null && col2.selectedItemName != null) {
              final String name = col2.selectedItemName as String;
              rowFields.add(_createFieldData(name));
            }

            if (rowFields.isNotEmpty) {
              sections.add(
                CrmTemplatePreviewSectionData(
                  title: rowTitle.isNotEmpty
                      ? rowTitle
                      : S.current.crmFieldDetails,
                  showImage: false,
                  fields: rowFields,
                ),
              );
            }
          }
        }
      }

      if (sections.isNotEmpty) {
        result.add(
          CrmTemplatePreviewPageData(
            title: pageTitle,
            sections: sections,
          ),
        );
      }
    }

    return result.isNotEmpty ? result : _defaultPages;
  }

  /// Function Name: _buildSectionFields
  ///
  /// Purpose: Returns preview field data for all Firestore fields that belong
  /// to [sectionId]. Falls back to empty list if no mapping exists.
  ///
  /// Parameters:
  /// - sectionId: The Firestore section document ID
  /// - fieldsBySectionId: Pre-built lookup map
  ///
  /// Returns: `List<CrmTemplatePreviewFieldData>`
  static List<CrmTemplatePreviewFieldData> _buildSectionFields(
    String sectionId,
    Map<String, List<CrmTemplateFieldModel>> fieldsBySectionId,
  ) {
    final List<CrmTemplateFieldModel>? fields = fieldsBySectionId[sectionId];
    if (fields == null || fields.isEmpty) {
      return <CrmTemplatePreviewFieldData>[];
    }
    return fields
        .map(
          (CrmTemplateFieldModel f) => _createFieldData(f.nameEn),
        )
        .toList();
  }

  /// Function Name: _sectionShowsImage
  ///
  /// Purpose: Returns true when the section name implies it contains a
  /// profile/client image (e.g., Client Details).
  ///
  /// Parameters:
  /// - name: Section display name
  ///
  /// Returns: bool
  static bool _sectionShowsImage(String name) {
    final String lower = name.toLowerCase();
    return lower.contains('client detail') ||
        lower.contains('profile') ||
        lower.contains('personal');
  }

  static CrmTemplatePreviewFieldData _createFieldData(String name) {
    final String lower = name.toLowerCase();

    if (lower.contains('image') ||
        lower.contains('photo') ||
        lower.contains('picture') ||
        lower.contains('logo') ||
        lower.contains('avatar')) {
      return CrmTemplatePreviewFieldData(
        label: name,
        placeholder: 'Upload Image',
        isImage: true,
      );
    }

    if (name.toLowerCase().contains('phone')) {
      return CrmTemplatePreviewFieldData(
        label: name,
        placeholder: 'Text Here',
        isPhone: true,
      );
    }
    if (name.toLowerCase().contains('email')) {
      return CrmTemplatePreviewFieldData(
        label: name,
        placeholder: 'Text Here',
      );
    }
    if (name == 'National ID') {
      return const CrmTemplatePreviewFieldData(
        label: 'National ID',
        placeholder: '148555555555555555555555555526',
        value: '148555555555555555555555555526',
        isValidated: true,
      );
    }

    if (lower.contains('date')) {
      return CrmTemplatePreviewFieldData(
        label: name,
        placeholder: 'Select Date',
      );
    }

    if (lower.contains('select') ||
        lower.contains('choice') ||
        lower.contains('type') ||
        lower.contains('language') ||
        lower.contains('channel') ||
        lower.contains('country') ||
        lower.contains('city') ||
        lower.contains('tag')) {
      return CrmTemplatePreviewFieldData(
        label: name,
        placeholder: 'Choose',
      );
    }

    return CrmTemplatePreviewFieldData(
      label: name,
      placeholder: 'Text Here',
    );
  }

  static const List<CrmTemplatePreviewPageData> _defaultPages =
      <CrmTemplatePreviewPageData>[
    CrmTemplatePreviewPageData(
      title: 'Page 1',
      sections: <CrmTemplatePreviewSectionData>[
        CrmTemplatePreviewSectionData(
          title: 'Client Details',
          showImage: true,
          fields: <CrmTemplatePreviewFieldData>[
            CrmTemplatePreviewFieldData(
              label: 'Client Image',
              placeholder: 'Upload Image',
              isImage: true,
            ),
            CrmTemplatePreviewFieldData(
              label: 'Client First Name',
              placeholder: 'Text Here',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Client Last Name',
              placeholder: 'Text Here',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Phone',
              placeholder: 'Text Here',
              isPhone: true,
            ),
            CrmTemplatePreviewFieldData(
              label: 'Email',
              placeholder: 'Text Here',
            ),
            CrmTemplatePreviewFieldData(
              label: 'National ID',
              placeholder: '148555555555555555555555555526',
              value: '148555555555555555555555555526',
              isValidated: true,
            ),
            CrmTemplatePreviewFieldData(
              label: 'Preferred Language',
              placeholder: 'Choose',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Preferred Contact Channel',
              placeholder: 'Choose',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Business Initiation Date',
              placeholder: 'Select Date',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Tags',
              placeholder: 'Choose',
            ),
          ],
        ),
        CrmTemplatePreviewSectionData(
          title: 'Address',
          fields: <CrmTemplatePreviewFieldData>[
            CrmTemplatePreviewFieldData(
              label: 'Country',
              placeholder: 'Choose',
            ),
            CrmTemplatePreviewFieldData(
              label: 'City',
              placeholder: 'Choose',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Province',
              placeholder: 'Text Here',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Street',
              placeholder: 'Text Here',
            ),
          ],
        ),
      ],
    ),
    CrmTemplatePreviewPageData(
      title: 'Page 2',
      sections: <CrmTemplatePreviewSectionData>[
        CrmTemplatePreviewSectionData(
          title: 'Client Details',
          showImage: true,
          fields: <CrmTemplatePreviewFieldData>[
            CrmTemplatePreviewFieldData(
              label: 'Client Image',
              placeholder: 'Upload Image',
              isImage: true,
            ),
            CrmTemplatePreviewFieldData(
              label: 'Client First Name',
              placeholder: 'Text Here',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Client Last Name',
              placeholder: 'Text Here',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Phone',
              placeholder: 'Text Here',
              isPhone: true,
            ),
            CrmTemplatePreviewFieldData(
              label: 'Email',
              placeholder: 'Text Here',
            ),
          ],
        ),
        CrmTemplatePreviewSectionData(
          title: 'Address',
          fields: <CrmTemplatePreviewFieldData>[
            CrmTemplatePreviewFieldData(
              label: 'Country',
              placeholder: 'Choose',
            ),
            CrmTemplatePreviewFieldData(
              label: 'City',
              placeholder: 'Choose',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Province',
              placeholder: 'Text Here',
            ),
            CrmTemplatePreviewFieldData(
              label: 'Street',
              placeholder: 'Text Here',
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: 'Page 1',
        onFirstTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              for (int i = 0; i < _pagesData.length; i++) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _pagesData[i].title,
                      style: StyleText.fontSize23Weight400.copyWith(
                        color: AppColors.secondaryBlack,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _expandedPages[i] = !_expandedPages[i];
                        });
                      },
                      child: Text(
                        _expandedPages[i] ? 'Hide' : 'Show',
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.sp),
                if (_expandedPages[i]) ...[
                  for (final CrmTemplatePreviewSectionData section
                      in _pagesData[i].sections) ...[
                    _PreviewSectionCard(section: section),
                    SizedBox(height: 18.sp),
                  ],
                ],
              ],
              SizedBox(height: 16.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: S.current.crmDiscard,
                    function: () => CrmNavigationHelper.pop(context),
                    color: AppColors.lightGrey,
                    textStyle: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  customButton(
                    title: S.current.crmSave,
                    function: () async {
                      await CrmControlDialogs.showSuccessDialog(
                        context: context,
                        title: 'Successful!',
                        subtitle: 'submit successfully.',
                        onComplete: () {
                          CrmNavigationHelper.pop(context);
                        },
                      );
                    },
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewSectionCard extends StatelessWidget {
  const _PreviewSectionCard({
    required this.section,
  });

  final CrmTemplatePreviewSectionData section;

  @override
  Widget build(BuildContext context) {
    final bool hasImageField = section.fields.any(
      (CrmTemplatePreviewFieldData f) =>
          f.isImage ||
          f.label.toLowerCase().contains('image') ||
          f.label.toLowerCase().contains('photo') ||
          f.label.toLowerCase().contains('picture') ||
          f.label.toLowerCase().contains('logo') ||
          f.label.toLowerCase().contains('avatar'),
    );

    final List<CrmTemplatePreviewFieldData> formFields = hasImageField
        ? section.fields
            .where(
              (CrmTemplatePreviewFieldData f) =>
                  !f.isImage &&
                  !f.label.toLowerCase().contains('image') &&
                  !f.label.toLowerCase().contains('photo') &&
                  !f.label.toLowerCase().contains('picture') &&
                  !f.label.toLowerCase().contains('logo') &&
                  !f.label.toLowerCase().contains('avatar'),
            )
            .toList()
        : section.fields;

    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < formFields.length; i += 2) {
      final CrmTemplatePreviewFieldData leftField = formFields[i];
      final CrmTemplatePreviewFieldData? rightField =
          (i + 1 < formFields.length) ? formFields[i + 1] : null;

      rows.add(
        buildResponsiveFields(
          context: context,
          left: _PreviewFieldBox(field: leftField),
          right: rightField != null
              ? _PreviewFieldBox(field: rightField)
              : const SizedBox.shrink(),
        ),
      );
    }

    return CrmTemplateSectionShell(
      title: section.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImageField) ...[
            CustomImagePicker(
              radius: 42.r,
              badgeRadius: 13.r,
              placeholderSvg: AppAssets.image,
              badgeSvg: AppAssets.camera,
              onImagePicked: (File file) {},
            ),
            SizedBox(height: 16.sp),
          ],
          for (int rIdx = 0; rIdx < rows.length; rIdx++) ...[
            rows[rIdx],
            if (rIdx < rows.length - 1) SizedBox(height: 16.sp),
          ],
        ],
      ),
    );
  }
}

class _PreviewFieldBox extends StatelessWidget {
  const _PreviewFieldBox({
    required this.field,
  });

  final CrmTemplatePreviewFieldData field;

  @override
  Widget build(BuildContext context) {
    final bool isChoice = field.placeholder == 'Choose';

    if (isChoice) {
      return CustomDropdown<String>(
        label: field.label,
        hint: field.placeholder,
        value: field.value,
        enabled: false,
        items: field.value != null
            ? <DropdownItem<String>>[
                DropdownItem<String>(
                  value: field.value!,
                  label: field.value!,
                ),
              ]
            : const <DropdownItem<String>>[],
      );
    }

    if (field.isPhone) {
      return CustomTextField(
        label: field.label,
        hint: field.placeholder,
        initialValue: field.value,
        readOnly: true,
        enabled: false,
      );
    }

    return CustomTextField(
      label: field.label,
      hint: field.placeholder,
      initialValue: field.value,
      readOnly: true,
      enabled: false,
    );
  }
}
