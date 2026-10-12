// ****************** FILE INFO ******************
// File Name: crm_template_special_field_editors.dart
// Purpose: Specialized CRM template field editors for advanced field types
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/helpers/crm_controls_dropdown_helper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_inputs.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_type_row.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_link_inputs.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_options_editor.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateDescriptionEditor extends StatelessWidget {
  const CrmTemplateDescriptionEditor({
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
    return _SpecialEditorShell(
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
          right: CrmTemplateSwitchRow(
            title: S.current.crmShowBothLanguages,
            value: model.field.showBothLanguages,
            readOnly: readOnly,
            onChanged: (bool value) {
              model.field = model.field.copyWith(showBothLanguages: value);
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

class CrmTemplateLinkEditor extends StatelessWidget {
  const CrmTemplateLinkEditor({
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
    return _SpecialEditorShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        CrmTemplateLinkSettingsSection(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
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

class CrmTemplateFileEditor extends StatelessWidget {
  const CrmTemplateFileEditor({
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
    return _SpecialEditorShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        _FileConstraintsSection(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
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

class CrmTemplateDateEditor extends StatelessWidget {
  const CrmTemplateDateEditor({
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

  DateTime? _parseDate(String text) {
    if (text.isEmpty) return null;
    final List<String> parts = text.split('/');
    if (parts.length == 3) {
      final int? day = int.tryParse(parts[0]);
      final int? month = int.tryParse(parts[1]);
      final int? year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.tryParse(text);
  }

  @override
  Widget build(BuildContext context) {
    return _SpecialEditorShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        buildResponsiveFields(
          context: context,
          left: CustomDropdownCalendar(
            label: S.current.crmDateRangeFrom,
            hint: S.current.crmSelectDate,
            enabled: !readOnly,
            value: _parseDate(model.dateFromController.text),
            fillColor: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            labelStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
            hintStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
            ),
            onChanged: (DateTime? val) {
              model.dateFromController.text = val != null
                  ? '${val.day.toString().padLeft(2, '0')}/${val.month.toString().padLeft(2, '0')}/${val.year}'
                  : '';
              onChanged();
            },
          ),
          right: CustomDropdownCalendar(
            label: S.current.crmDateRangeTo,
            hint: S.current.crmSelectDate,
            enabled: !readOnly,
            value: _parseDate(model.dateToController.text),
            fillColor: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
            labelStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
            hintStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
            ),
            onChanged: (DateTime? val) {
              model.dateToController.text = val != null
                  ? '${val.day.toString().padLeft(2, '0')}/${val.month.toString().padLeft(2, '0')}/${val.year}'
                  : '';
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

class CrmTemplateTimeEditor extends StatelessWidget {
  const CrmTemplateTimeEditor({
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
    return _SpecialEditorShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        buildResponsiveFields(
          context: context,
          left: _IconLabeledField(
            title: S.current.crmFrom,
            hint: S.current.crmSelectTime,
            controller: model.timeFromController,
            icon: AppAssets.timeSelectorIcon,
            readOnly: readOnly,
          ),
          right: _IconLabeledField(
            title: S.current.crmTo,
            hint: S.current.crmSelectTime,
            controller: model.timeToController,
            icon: AppAssets.timeSelectorIcon,
            readOnly: readOnly,
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

class CrmTemplateSwitchEditor extends StatelessWidget {
  const CrmTemplateSwitchEditor({
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
    return _SpecialEditorShell(
      model: model,
      fieldTypes: fieldTypes,
      onChanged: onChanged,
      readOnly: readOnly,
      children: [
        CrmTemplateOptionsEditor(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
          title: S.current.crmItems,
          infoMessage: S.current.crmSwitchInfoMessage,
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmMultipleChoose,
            value: model.boolConfig(
              CrmFirestoreKeys.MULTIPLE_CHOOSE_KEY,
              fallback: true,
            ),
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(CrmFirestoreKeys.MULTIPLE_CHOOSE_KEY, value);
              onChanged();
            },
          ),
          right: const SizedBox.shrink(),
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

class _SpecialEditorShell extends StatelessWidget {
  const _SpecialEditorShell({
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

class _FileConstraintsSection extends StatelessWidget {
  const _FileConstraintsSection({
    required this.model,
    required this.onChanged,
    required this.readOnly,
  });

  static const List<String> _sizeUnits = ['KB', 'MB'];

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.current.crmConstraints,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateLabeledField(
            title: S.current.crmMaximumNumber,
            controller: model.maximumNumberController,
            readOnly: readOnly,
          ),
          right: buildResponsiveFields(
            context: context,
            left: CrmTemplateLabeledField(
              title: S.current.crmSize,
              controller: model.fileSizeController,
              readOnly: readOnly,
            ),
            right: CrmTemplateDropdownBox(
              title: '',
              value: model.stringConfig(
                CrmFirestoreKeys.FILE_SIZE_UNIT_KEY,
                fallback: '',
              ),
              items: _sizeUnits,
              readOnly: readOnly,
              onChanged: (String value) {
                model.setConfig(CrmFirestoreKeys.FILE_SIZE_UNIT_KEY, value);
                onChanged();
              },
            ),
          ),
        ),
        SizedBox(height: 16.sp),
        _FileTypesDropdown(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}

class _FileTypesDropdown extends StatelessWidget {
  const _FileTypesDropdown({
    required this.model,
    required this.onChanged,
    required this.readOnly,
  });

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final List<MultiSelectDropdownItem<String>> items =
        CrmControlsDropdownHelper.allowedFileTypeDropdownItems;
    return buildResponsiveFields(
      context: context,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.crmFileTypes,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.sp),
          CustomMultiSelectDropdown<String>(
            values: model.selectedFileTypes(),
            hint: S.current.crmChoose,
            enabled: !readOnly,
            overlayElevation: 0,
            maxOverlayHeight: 260.sp,
            fillColor: AppColors.background,
            items: items,
            valueStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
            ),
            hintStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.grey,
            ),
            itemStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
            ),
            selectedTextBuilder:
                (List<MultiSelectDropdownItem<String>> values) {
              if (values.length == items.length) return S.current.crmAllTypes;
              return values.map((item) => item.label).join(', ');
            },
            onChanged: (List<String> values) {
              model.setConfig(CrmFirestoreKeys.FILE_TYPES_KEY, values);
              onChanged();
            },
          ),
        ],
      ),
      right: const SizedBox.shrink(),
    );
  }
}

class _IconLabeledField extends StatelessWidget {
  const _IconLabeledField({
    required this.title,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.readOnly,
  });

  final String title;
  final String hint;
  final TextEditingController controller;
  final String icon;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
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
        CustomTextField(
          controller: controller,
          hint: hint,
          readOnly: readOnly,
          suffixIcon: CustomSvgImage(
            assetPath: icon,
            width: 18.sp,
            height: 18.sp,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
