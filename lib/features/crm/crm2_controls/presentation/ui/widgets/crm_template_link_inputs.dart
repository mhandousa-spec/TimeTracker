// ****************** FILE INFO ******************
// File Name: crm_template_link_inputs.dart
// Purpose: Link-specific input controls for CRM template fields
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/helpers/crm_controls_dropdown_helper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_inputs.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateLinkSettingsSection extends StatelessWidget {
  const CrmTemplateLinkSettingsSection({
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
        CrmTemplateLabeledField(
          title: S.current.crmFormat,
          controller: model.formatController,
          readOnly: readOnly,
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: _SpecificLinkTypesControl(
            model: model,
            onChanged: onChanged,
            readOnly: readOnly,
          ),
          right: CrmTemplateSwitchInput(
            title: S.current.crmAddMoreLink,
            value: model.boolConfig(
              CrmFirestoreKeys.ADD_MORE_LINK_ENABLED_KEY,
              fallback: true,
            ),
            controller: model.maxController,
            inputTitle: S.current.crmMaxNumber,
            readOnly: readOnly,
            onChanged: (bool value) {
              model.setConfig(
                CrmFirestoreKeys.ADD_MORE_LINK_ENABLED_KEY,
                value,
              );
              onChanged();
            },
          ),
        ),
        SizedBox(height: 16.sp),
        buildResponsiveFields(
          context: context,
          left: CrmTemplateSwitchRow(
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
          right: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SpecificLinkTypesControl extends StatelessWidget {
  const _SpecificLinkTypesControl({
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
        CrmControlsDropdownHelper.purchasingValidationDropdownItems;
    return Column(
      children: [
        CrmTemplateSwitchRow(
          title: S.current.crmSpecificLinkTypes,
          value: model.boolConfig(
            CrmFirestoreKeys.SPECIFIC_LINK_TYPES_ENABLED_KEY,
            fallback: true,
          ),
          readOnly: readOnly,
          onChanged: (bool value) {
            model.setConfig(
              CrmFirestoreKeys.SPECIFIC_LINK_TYPES_ENABLED_KEY,
              value,
            );
            onChanged();
          },
        ),
        SizedBox(height: 8.sp),
        CustomMultiSelectDropdown<String>(
          values: model.selectedLinkTypes(),
          hint: S.current.crmChoose,
          enabled: !readOnly &&
              model.boolConfig(
                CrmFirestoreKeys.SPECIFIC_LINK_TYPES_ENABLED_KEY,
                fallback: true,
              ),
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
          selectedTextBuilder: (List<MultiSelectDropdownItem<String>> values) {
            return values.map((item) => item.label).join(', ');
          },
          onChanged: (List<String> values) {
            model.setConfig(CrmFirestoreKeys.LINK_TYPES_KEY, values);
            onChanged();
          },
        ),
      ],
    );
  }
}
