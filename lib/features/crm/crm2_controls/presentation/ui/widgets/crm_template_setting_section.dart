// ****************** FILE INFO ******************
// File Name: crm_template_setting_section.dart
// Purpose: Category selector panel for CRM template element forms
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_shared_widgets.dart';

import 'package:knowticed_plus/features/crm/crm2_controls/domain/helpers/crm_controls_dropdown_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateSettingSection extends StatelessWidget {
  const CrmTemplateSettingSection({
    required this.isExpanded,
    required this.selectedCategory,
    required this.onToggle,
    required this.onCategoryChanged,
    super.key,
  });

  final bool isExpanded;
  final String selectedCategory;
  final VoidCallback onToggle;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return CrmTemplateSectionShell(
      title: S.current.crmSetting,
      isExpanded: isExpanded,
      onToggleExpand: onToggle,
      child: buildResponsiveFields(
        context: context,
        left: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.crmCategory,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.sp),
            CustomDropdown<String>(
              value: selectedCategory.isEmpty ? null : selectedCategory,
              hint: S.current.crmChoose,
              items: CrmControlsDropdownHelper.categoryDropdownItems,
              onChanged: (String? value) {
                if (value != null) onCategoryChanged(value);
              },
            ),
          ],
        ),
        right: const SizedBox.shrink(),
      ),
    );
  }
}
