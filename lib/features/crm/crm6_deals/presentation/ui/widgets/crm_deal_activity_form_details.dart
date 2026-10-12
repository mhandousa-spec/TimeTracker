// ****************** FILE INFO ******************
// File Name: crm_deal_activity_form_details.dart
// Purpose: Form fields section for Deal Activity details (Activity Type, Subject, Assigned To, Dates, Tags, Notes)
// Author: Mohand Adel
// Created At: 29/08/2026

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_activity_read_only_employee_card.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_overview_employee_picker.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmDealActivityFormDetails extends StatelessWidget {
  final bool isReadOnly;
  final bool submitted;
  final String? selectedActivityType;
  final List<String> activityTypes;
  final ValueChanged<String?> onActivityTypeChanged;
  final TextEditingController subjectEnController;
  final TextEditingController subjectArController;
  final List<CrmTeamMemberModel> employees;
  final CrmTeamMemberModel? selectedEmployee;
  final ValueChanged<CrmTeamMemberModel?> onEmployeeSelected;
  final TextEditingController employeeSearchController;
  final TextEditingController dueDateController;
  final TextEditingController dueTimeController;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final String? selectedTag;
  final List<String> tags;
  final ValueChanged<String?> onTagChanged;
  final TextEditingController noteEnController;
  final TextEditingController noteArController;
  final VoidCallback onFormStateChanged;

  const CrmDealActivityFormDetails({
    super.key,
    required this.isReadOnly,
    required this.submitted,
    required this.selectedActivityType,
    required this.activityTypes,
    required this.onActivityTypeChanged,
    required this.subjectEnController,
    required this.subjectArController,
    required this.employees,
    required this.selectedEmployee,
    required this.onEmployeeSelected,
    required this.employeeSearchController,
    required this.dueDateController,
    required this.dueTimeController,
    required this.onPickDate,
    required this.onPickTime,
    required this.selectedTag,
    required this.tags,
    required this.onTagChanged,
    required this.noteEnController,
    required this.noteArController,
    required this.onFormStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Activity Details',
        arabicName: 'تفاصيل النشاط',
      ),
      showHideToggle: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Activity Type (Single half-row field)
          buildResponsiveFields(
            context: context,
            left: isReadOnly
                ? CustomTextField(
                    controller: TextEditingController(
                        text: selectedActivityType ?? 'Communication'),
                    label: 'Activity Type',
                    readOnly: true,
                    fillColor: AppColors.background,
                  )
                : CustomDropdown<String>(
                    label: 'Activity Type',
                    hint: 'Choose',
                    value: selectedActivityType,
                    items: activityTypes
                        .map((String type) => DropdownItem<String>(
                              value: type,
                              label: type,
                            ))
                        .toList(),
                    onChanged: (String? val) {
                      onActivityTypeChanged(val);
                      onFormStateChanged();
                    },
                    errorText: submitted && selectedActivityType == null
                        ? 'Field Required'
                        : null,
                    fillColor: AppColors.background,
                  ),
            right: const SizedBox.shrink(),
          ),

          SizedBox(height: 14.sp),

          // 2. Subject / الموضوع (Bilingual pair of fields)
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: subjectEnController,
              label: 'Subject',
              hint: 'Text Here',
              readOnly: isReadOnly,
              onChanged: (_) => onFormStateChanged(),
              errorText: !isReadOnly &&
                      submitted &&
                      subjectEnController.text.trim().isEmpty
                  ? 'Field Required'
                  : null,
              fillColor: AppColors.background,
            ),
            right: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: CustomTextField(
                controller: subjectArController,
                label: 'الموضوع',
                hint: 'اكتب هنا',
                textAlign: TextAlign.right,
                readOnly: isReadOnly,
                onChanged: (_) => onFormStateChanged(),
                errorText: !isReadOnly &&
                        submitted &&
                        subjectArController.text.trim().isEmpty
                    ? 'الحقل مطلوب'
                    : null,
                fillColor: AppColors.background,
              ),
            ),
          ),

          SizedBox(height: 16.sp),

          // 3. Assigned To Section
          Text(
            FormatHelper.localizedString(
              englishName: 'Assigned To',
              arabicName: 'تعيين إلى',
            ),
            style: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.sp),
          if (isReadOnly)
            CrmDealActivityReadOnlyEmployeeCard(
              employee: selectedEmployee,
            )
          else
            CrmDealOverviewEmployeePicker(
              searchController: employeeSearchController,
              employees: employees,
              selectedEmployee: selectedEmployee,
              onEmployeeSelected: (CrmTeamMemberModel? emp) {
                onEmployeeSelected(emp);
                onFormStateChanged();
              },
              onSearchChanged: onFormStateChanged,
            ),

          SizedBox(height: 16.sp),

          // 4. Due Date & Time (Responsive pair of fields)
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: dueDateController,
              label: 'Due Date',
              hint: 'Select Date',
              readOnly: true,
              onTap: onPickDate,
              suffixIcon: Padding(
                padding: EdgeInsets.all(10.sp),
                child: CustomSvgImage(
                  assetPath: AppAssets.calendar,
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.darkGrey,
                ),
              ),
              errorText: !isReadOnly &&
                      submitted &&
                      dueDateController.text.trim().isEmpty
                  ? 'Field Required'
                  : null,
              fillColor: AppColors.background,
            ),
            right: CustomTextField(
              controller: dueTimeController,
              label: 'Time',
              hint: 'Select Time',
              readOnly: true,
              onTap: onPickTime,
              suffixIcon: Icon(
                Icons.access_time_rounded,
                size: 18.sp,
                color: AppColors.darkGrey,
              ),
              errorText: !isReadOnly &&
                      submitted &&
                      dueTimeController.text.trim().isEmpty
                  ? 'Field Required'
                  : null,
              fillColor: AppColors.background,
            ),
          ),

          SizedBox(height: 14.sp),

          // 5. Tags (Single half-row field)
          buildResponsiveFields(
            context: context,
            left: isReadOnly
                ? CustomTextField(
                    controller:
                        TextEditingController(text: selectedTag ?? 'Deals'),
                    label: 'Tags',
                    readOnly: true,
                    fillColor: AppColors.background,
                  )
                : CustomDropdown<String>(
                    label: 'Tags',
                    hint: 'Choose',
                    value: selectedTag,
                    items: tags
                        .map((String tag) => DropdownItem<String>(
                              value: tag,
                              label: tag,
                            ))
                        .toList(),
                    onChanged: (String? val) {
                      onTagChanged(val);
                      onFormStateChanged();
                    },
                    fillColor: AppColors.background,
                  ),
            right: const SizedBox.shrink(),
          ),

          SizedBox(height: 14.sp),

          // 6. Note / ملاحظة (Bilingual text areas with character counter)
          buildResponsiveFields(
            context: context,
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomTextField(
                  controller: noteEnController,
                  label: 'Note',
                  hint: 'Description',
                  maxLines: 4,
                  readOnly: isReadOnly,
                  onChanged: (_) => onFormStateChanged(),
                  fillColor: AppColors.background,
                ),
                if (!isReadOnly) ...<Widget>[
                  SizedBox(height: 4.sp),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${noteEnController.text.length}/500',
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            right: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomTextField(
                    controller: noteArController,
                    label: 'ملاحظة',
                    hint: 'اكتب هنا',
                    textAlign: TextAlign.right,
                    maxLines: 4,
                    readOnly: isReadOnly,
                    onChanged: (_) => onFormStateChanged(),
                    fillColor: AppColors.background,
                  ),
                  if (!isReadOnly) ...<Widget>[
                    SizedBox(height: 4.sp),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${noteArController.text.length}/٥٠٠',
                        style:
                            StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
