// ****************** FILE INFO ******************
// File Name: crm_template_value_signature_website_editors.dart
// Purpose: Specialized CRM template editors for value, signature, and website fields
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_inputs.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_type_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplatePurchasingValueEditor extends StatelessWidget {
  const CrmTemplatePurchasingValueEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return _EditorShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchInput(
            title: S.current.crmMaxCharacters,
            value: model.boolConfig(CrmFirestoreKeys.MAX_LENGTH_ENABLED_KEY),
            controller: model.maxController,
            inputTitle: S.current.crmTextHere,
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.MAX_LENGTH_ENABLED_KEY, value);
              onChanged();
            },
          ),
          right: _MultiSelectBox(
            title: S.current.crmValidation,
            values: model.selectedPurchasingValidationTypes(),
            items: CrmTemplateFieldEditModel.purchasingValidationTypes,
            readOnly: readOnly,
            onChanged: (List<String> values) {
              model.setConfig(
                CrmFirestoreKeys.VALUE_VALIDATION_TYPES_KEY,
                values,
              );
              model.field = model.field.copyWith(
                validationType: values.join(','),
              );
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateRequiredAndErrorsRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}

class CrmTemplateSignatureEditor extends StatelessWidget {
  const CrmTemplateSignatureEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final String saveFormat = model.stringConfig(
      CrmFirestoreKeys.SAVE_FORMAT_KEY,
      fallback: 'File',
    );
    final List<String> typeItems = saveFormat == 'Image'
        ? CrmTemplateFieldEditModel.defaultImageTypes
        : CrmTemplateFieldEditModel.defaultSignatureFileTypes;
    return _EditorShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        buildResponsiveFields(
          context: context,
          left: CrmTemplateDropdownBox(
            title: S.current.crmSaveFormat,
            value: saveFormat,
            items: CrmTemplateFieldEditModel.signatureSaveFormats,
            readOnly: readOnly,
            onChanged: (String value) {
              model.setConfig(CrmFirestoreKeys.SAVE_FORMAT_KEY, value);
              model.setConfig(
                CrmFirestoreKeys.SIGNATURE_TYPES_KEY,
                value == 'Image'
                    ? CrmTemplateFieldEditModel.defaultImageTypes
                    : CrmTemplateFieldEditModel.defaultSignatureFileTypes,
              );
              onChanged();
            },
          ),
          right: _MultiSelectBox(
            title: S.current.crmType,
            values: model.selectedSignatureTypes(),
            items: typeItems,
            readOnly: readOnly,
            onChanged: (List<String> values) {
              model.setConfig(CrmFirestoreKeys.SIGNATURE_TYPES_KEY, values);
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateRequiredAndErrorsRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}

class CrmTemplateWebsiteEditor extends StatelessWidget {
  const CrmTemplateWebsiteEditor({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return _EditorShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        CrmTemplateLabeledField(
          title: S.current.crmFormatExample,
          controller: model.formatController,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmAutoAddHttps,
            value: model.boolConfig(
              CrmFirestoreKeys.AUTO_ADD_HTTPS_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.AUTO_ADD_HTTPS_KEY, value);
              onChanged();
            },
          ),
          right: CrmTemplateSwitchRow(
            title: S.current.crmTrimSpaces,
            value: model.boolConfig(
              CrmFirestoreKeys.TRIM_SPACES_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.TRIM_SPACES_KEY, value);
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateRequiredAndErrorsRow(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}

class _EditorShell extends StatelessWidget {
  const _EditorShell({
    required this.model,
    required this.fieldTypes,
    required this.onChanged,
    required this.readOnly,
    required this.children,
  });

  final CrmTemplateFieldEditModel model;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onChanged;
  final bool readOnly;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CrmTemplateFieldTypeRow(
          model: model,
          fieldTypes: fieldTypes,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        CrmTemplateNameRow(model: model, readOnly: readOnly),
        SizedBox(height: 16.sp),
        ...children,
      ],
    );
  }
}

class _MultiSelectBox extends StatelessWidget {
  const _MultiSelectBox({
    required this.title,
    required this.values,
    required this.items,
    required this.onChanged,
    required this.readOnly,
  });

  final String title;
  final List<String> values;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final List<MultiSelectDropdownItem<String>> dropdownItems = items
        .map(
          (String value) => MultiSelectDropdownItem<String>(
            value: value,
            label: value,
          ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.sp),
        CustomMultiSelectDropdown<String>(
          values: values,
          hint: S.current.crmChoose,
          enabled: !readOnly,
          overlayElevation: 0,
          maxOverlayHeight: 260.sp,
          fillColor: AppColors.background,
          items: dropdownItems,
          valueStyle: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.black,
          ),
          hintStyle: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.grey,
          ),
          itemStyle: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.black,
          ),
          selectedTextBuilder: (List<MultiSelectDropdownItem<String>> values) {
            return values.map((item) => item.label).join(', ');
          },
          onChanged: onChanged,
        ),
      ],
    );
  }
}
