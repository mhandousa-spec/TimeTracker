// ****************** FILE INFO ******************
// File Name: crm_template_section_details_panel.dart
// Purpose: Section details editor with saved sections picker
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_shared_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateSectionDetailsPanel extends StatelessWidget {
  const CrmTemplateSectionDetailsPanel({
    required this.isExpanded,
    required this.nameEnController,
    required this.nameArController,
    required this.onToggle,
    required this.showSavedSectionsSelector,
    required this.savedSections,
    required this.selectedSavedSectionId,
    required this.onSavedSectionChanged,
    this.readOnly = false,
    this.onRemove,
    this.showRemove = false,
    this.nameEnError,
    this.nameArError,
    super.key,
  });

  final bool isExpanded;
  final TextEditingController nameEnController;
  final TextEditingController nameArController;
  final VoidCallback onToggle;
  final VoidCallback? onRemove;
  final bool showRemove;
  final bool showSavedSectionsSelector;
  final List<CrmSavedSectionModel> savedSections;
  final String selectedSavedSectionId;
  final ValueChanged<String> onSavedSectionChanged;
  final bool readOnly;
  final String? nameEnError;
  final String? nameArError;

  @override
  Widget build(BuildContext context) {
    return CrmTemplateSectionShell(
      title: S.current.crmSectionDetails,
      isExpanded: isExpanded,
      showToggle: !readOnly,
      onToggleExpand: onToggle,
      trailingActions: !readOnly && showRemove && onRemove != null
          ? CustomDeleteIcon(
              color: AppColors.red,
              svgColor: AppColors.white,
              onTap: onRemove!,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSavedSectionsSelector) ...[
            SizedBox(
              width: 260.sp,
              child: CustomDropdown<String>(
                value: selectedSavedSectionId.isEmpty
                    ? null
                    : selectedSavedSectionId,
                hint: S.current.crmSavedSections,
                items: savedSections
                    .map(
                      (section) => DropdownItem<String>(
                        value: section.id,
                        label: _sectionLabel(section),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) onSavedSectionChanged(value);
                },
                enabled: !readOnly,
                fillColor: AppColors.primary.withAlpha(46),
              ),
            ),
            SizedBox(height: 16.sp),
          ],
          buildResponsiveFields(
            context: context,
            left: _SectionNameField(
              title: S.current.crmSectionName,
              controller: nameEnController,
              readOnly: readOnly,
              errorText: nameEnError,
            ),
            right: _SectionNameField(
              title: S.current.crmSectionNameAr,
              controller: nameArController,
              textDirection: TextDirection.rtl,
              alignRight: true,
              readOnly: readOnly,
              errorText: nameArError,
            ),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(CrmSavedSectionModel section) {
    final String name = section.nameEn.trim();
    if (name.isNotEmpty) return name;
    return section.nameAr.trim();
  }
}

class _SectionNameField extends StatelessWidget {
  const _SectionNameField({
    required this.title,
    required this.controller,
    required this.readOnly,
    this.textDirection,
    this.alignRight = false,
    this.errorText,
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
