// ****************** FILE INFO ******************
// File Name: crm_template_field_inputs.dart
// Purpose: Shared input rows for CRM template field editor
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/58-default_switch_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/enums/crm_controls_enums.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/helpers/crm_controls_dropdown_helper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateNameRow extends StatelessWidget {
  const CrmTemplateNameRow({
    required this.model,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return buildResponsiveFields(
      context: context,
      left: CrmTemplateLabeledField(
        title: 'Field Name',
        controller: model.nameEnController,
        readOnly: readOnly,
        errorText: model.nameEnError,
      ),
      right: CrmTemplateLabeledField(
        title: 'اسم الحقل',
        controller: model.nameArController,
        textDirection: TextDirection.rtl,
        alignRight: true,
        readOnly: readOnly,
        errorText: model.nameArError,
      ),
    );
  }
}

class CrmTemplateMaxAndValidationRow extends StatelessWidget {
  const CrmTemplateMaxAndValidationRow({
    required this.model,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final List<String> selectedValidations =
        model.selectedTextValidationTypes();
    final List<MultiSelectDropdownItem<String>> dropdownItems =
        CrmControlsDropdownHelper.validationMultiSelectDropdownItems;

    return buildResponsiveFields(
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
      right: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.crmValidation,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.sp),
          CustomMultiSelectDropdown<String>(
            values: selectedValidations,
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
            selectedTextBuilder:
                (List<MultiSelectDropdownItem<String>> values) {
              if (values.isEmpty) return S.current.crmChoose;
              return values.map((item) => item.label).join(', ');
            },
            onChanged: (List<String> values) {
              model.setConfig(
                CrmFirestoreKeys.VALIDATION_TYPES_KEY,
                values,
              );
              model.field = model.field.copyWith(
                validationType: values.join(','),
              );
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class CrmTemplateRequiredAndErrorsRow extends StatelessWidget {
  const CrmTemplateRequiredAndErrorsRow({
    required this.model,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
            title: S.current.crmMakeFieldRequired,
            value: model.field.isRequired,
            readOnly: readOnly,
            onChanged: (bool value) {
              model.field = model.field.copyWith(isRequired: value);
              onChanged();
            },
          ),
          right: const SizedBox.shrink(),
        ),
        if (model.field.isRequired) ...[
          SizedBox(height: 16.sp),
          buildResponsiveFields(
            context: context,
            left: CrmTemplateLabeledField(
              title: 'Error Message',
              controller: model.errorEnController,
              readOnly: readOnly,
              errorText: model.errorEnError,
            ),
            right: CrmTemplateLabeledField(
              title: 'رسالة خطأ',
              controller: model.errorArController,
              textDirection: TextDirection.rtl,
              alignRight: true,
              readOnly: readOnly,
              errorText: model.errorArError,
            ),
          ),
        ],
      ],
    );
  }
}

class CrmTemplatePhoneOptionsSection extends StatelessWidget {
  const CrmTemplatePhoneOptionsSection({
    required this.model,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return buildResponsiveFields(
      context: context,
      left: CrmTemplateSwitchInput(
        title: S.current.crmAllowMultiplePhone,
        value: model.boolConfig(
          CrmFirestoreKeys.ALLOW_MULTIPLE_KEY,
          fallback: true,
        ),
        controller: model.maxController,
        inputTitle: S.current.crmMaxNumber,
        readOnly: readOnly,
        onChanged: (bool value) {
          model.setConfig(CrmFirestoreKeys.ALLOW_MULTIPLE_KEY, value);
          model.setConfig(CrmFirestoreKeys.ALLOW_MULTIPLE_VALUES_KEY, value);
          onChanged();
        },
      ),
      right: CrmTemplateSwitchDropdown(
        title: S.current.crmCountryCode,
        value: model.boolConfig(
          CrmFirestoreKeys.COUNTRY_CODE_ENABLED_KEY,
          fallback: true,
        ),
        dropdownValue: model.stringConfig(
          CrmFirestoreKeys.COUNTRY_CODE_KEY,
          fallback: 'Countries',
        ),
        items: const ['Countries'],
        readOnly: readOnly,
        onSwitchChanged: (bool value) {
          model.setConfig(CrmFirestoreKeys.COUNTRY_CODE_ENABLED_KEY, value);
          onChanged();
        },
        onDropdownChanged: (String value) {
          model.setConfig(CrmFirestoreKeys.COUNTRY_CODE_KEY, value);
          onChanged();
        },
      ),
    );
  }
}

class CrmTemplateImageConstraintsSection extends StatelessWidget {
  const CrmTemplateImageConstraintsSection({
    required this.model,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  static const List<String> _sizeUnits = ['KB', 'MB'];

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final String unit = model.stringConfig(
      CrmFirestoreKeys.IMAGE_SIZE_UNIT_KEY,
      fallback: 'MB',
    );
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
              controller: model.imageSizeController,
              readOnly: readOnly,
            ),
            right: CrmTemplateDropdownBox(
              title: '',
              value: unit,
              items: _sizeUnits,
              readOnly: readOnly,
              onChanged: (String value) {
                model.setConfig(CrmFirestoreKeys.IMAGE_SIZE_UNIT_KEY, value);
                onChanged();
              },
            ),
          ),
        ),
        SizedBox(height: 16.sp),
        CrmTemplateImageTypesDropdown(
          model: model,
          onChanged: onChanged,
          readOnly: readOnly,
        ),
      ],
    );
  }
}

class CrmTemplateImageTypesDropdown extends StatelessWidget {
  const CrmTemplateImageTypesDropdown({
    required this.model,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final List<String> selectedTypes = model.selectedImageTypes();
    final List<MultiSelectDropdownItem<String>> items =
        CrmTemplateFieldEditModel.defaultImageTypes
            .map(
              (String type) => MultiSelectDropdownItem<String>(
                value: type,
                label: type,
              ),
            )
            .toList();
    return buildResponsiveFields(
      context: context,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.crmImageTypes,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.sp),
          CustomMultiSelectDropdown<String>(
            values: selectedTypes,
            hint: S.current.crmChoose,
            enabled: !readOnly,
            overlayElevation: 0,
            maxOverlayHeight: 260.sp,
            items: items,
            fillColor: AppColors.background,
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
              model.setConfig(CrmFirestoreKeys.IMAGE_TYPES_KEY, values);
              onChanged();
            },
          ),
        ],
      ),
      right: const SizedBox.shrink(),
    );
  }
}

class CrmTemplateSwitchDropdown extends StatelessWidget {
  const CrmTemplateSwitchDropdown({
    required this.title,
    required this.value,
    required this.dropdownValue,
    required this.items,
    required this.onSwitchChanged,
    required this.onDropdownChanged,
    required this.readOnly,
    super.key,
  });

  final String title;
  final bool value;
  final String dropdownValue;
  final List<String> items;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<String> onDropdownChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CrmTemplateSwitchRow(
          title: title,
          value: value,
          readOnly: readOnly,
          onChanged: onSwitchChanged,
        ),
        if (value) ...[
          SizedBox(height: 8.sp),
          CrmTemplateDropdownBox(
            title: '',
            value: dropdownValue,
            items: items,
            readOnly: readOnly,
            onChanged: onDropdownChanged,
          ),
        ],
      ],
    );
  }
}

class CrmTemplateSwitchInput extends StatelessWidget {
  const CrmTemplateSwitchInput({
    required this.title,
    required this.value,
    required this.controller,
    required this.inputTitle,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final String title;
  final bool value;
  final TextEditingController controller;
  final String inputTitle;
  final ValueChanged<bool> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CrmTemplateSwitchRow(
          title: title,
          value: value,
          readOnly: readOnly,
          onChanged: onChanged,
        ),
        if (value) ...[
          SizedBox(height: 8.sp),
          CustomTextField(
            controller: controller,
            hint: inputTitle,
            readOnly: readOnly,
          ),
        ],
      ],
    );
  }
}

class CrmTemplateSwitchRow extends StatelessWidget {
  const CrmTemplateSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
          ),
        ),
        IgnorePointer(
          ignoring: readOnly,
          child: DefaultSwitchButton(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class CrmTemplateDropdownBox extends StatelessWidget {
  const CrmTemplateDropdownBox({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final CrmValidationTypeEnum? valEnum =
        CrmValidationTypeEnum.fromValue(value);
    final String displayLabel =
        (valEnum != null && value.isNotEmpty) ? valEnum.localizedLabel : value;

    if (readOnly) {
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
            controller: TextEditingController(text: displayLabel),
            readOnly: true,
          ),
        ],
      );
    }

    final List<String> filteredItems =
        items.where((String item) => item.trim().isNotEmpty).toList();
    final List<String> values = (value.isEmpty || filteredItems.contains(value))
        ? filteredItems
        : <String>[value, ...filteredItems];
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
        CustomDropdown<String>(
          value: value.isEmpty ? null : value,
          hint: S.current.crmChoose,
          items: values.map((item) {
            final CrmValidationTypeEnum? itemValEnum =
                CrmValidationTypeEnum.fromValue(item);
            final String label = (itemValEnum != null && item.isNotEmpty)
                ? itemValEnum.localizedLabel
                : item;
            return DropdownItem<String>(value: item, label: label);
          }).toList(),
          onChanged: (String? selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}

class CrmTemplateLabeledField extends StatelessWidget {
  const CrmTemplateLabeledField({
    required this.title,
    required this.controller,
    required this.readOnly,
    this.textDirection,
    this.alignRight = false,
    this.errorText,
    super.key,
  });

  final String title;
  final TextEditingController controller;
  final TextDirection? textDirection;
  final bool alignRight;
  final bool readOnly;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
          hint: alignRight ? S.current.crmWriteHere : S.current.crmTextHere,
          textDirection: textDirection,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          readOnly: readOnly,
          errorText: errorText,
        ),
      ],
    );
  }
}
