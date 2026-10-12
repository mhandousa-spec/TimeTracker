/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/configuration_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: configuration_section.dart
/// Purpose: Widget for document configuration section with owning department dropdown
/// Author: Youssef Khaled
/// Created At: 22/10/2025
/// Updated: Added dropdown for owning department selection with permission check

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';
import 'dart:math' as math;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import '../../../../main_controller/presentation/ui/core_widgets/select_chip.dart';
import '../../../../main_controller/presentation/ui/widgets/doc_type_drop_menu.dart';
import './date_time_picker.dart';

// ✅ ADD THESE IMPORTS FOR PERMISSION CHECK
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ConfigurationSection extends StatelessWidget {
  final String dropDownMenuText;
  final String employeeDepartment;
  final bool limitDepartmentAvailability;
  final bool schedulePublishing;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final List<DepartmentModelPro> availableDepartments;
  final Map<String, bool> departmentSelections;
  final CreateKnowledgeModel? submittedDocument;
  final String? selectedOwningDepartmentId;  // ✅ NEW
  final ValueChanged<String?> onDocTypeChanged;
  final ValueChanged<String?> onOwningDepartmentChanged;  // ✅ NEW
  final ValueChanged<bool> onLimitDepartmentToggle;
  final ValueChanged<bool> onSchedulePublishingToggle;
  final ValueChanged<DateTime> onStartDateSelected;
  final ValueChanged<TimeOfDay> onStartTimeSelected;
  final ValueChanged<DateTime> onEndDateSelected;
  final ValueChanged<TimeOfDay> onEndTimeSelected;
  final ValueChanged<String> onDepartmentAdded;
  final ValueChanged<String> onDepartmentRemoved;

  const ConfigurationSection({
    super.key,
    required this.dropDownMenuText,
    required this.employeeDepartment,
    required this.limitDepartmentAvailability,
    required this.schedulePublishing,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.availableDepartments,
    required this.departmentSelections,
    required this.submittedDocument,
    required this.selectedOwningDepartmentId,  // ✅ NEW
    required this.onDocTypeChanged,
    required this.onOwningDepartmentChanged,  // ✅ NEW
    required this.onLimitDepartmentToggle,
    required this.onSchedulePublishingToggle,
    required this.onStartDateSelected,
    required this.onStartTimeSelected,
    required this.onEndDateSelected,
    required this.onEndTimeSelected,
    required this.onDepartmentAdded,
    required this.onDepartmentRemoved,
  });

  // ✅ NEW: Check if user has permission to select owning department
  bool _hasSelectOwningDepartmentPermission() {
    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      return employeeController.isHasPermission(
        module: Modules.knowledgeHub,
        section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
        permission: KnowledgeHubPermissions.selectOwningDepartment,
      );
    } catch (e) {
      debugPrint('⚠️ Error checking permission: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsivePage.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: lightMode
            ? AppColors.white
            : AppColors.chatBackground,
      ),
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildDocumentTypeDropdown(context),
            SizedBox(height: 15.h),
            _buildOwningDepartmentField(context, lightMode),
          ] else
            ...[
              Row(
                children: [
                  Expanded(child: _buildDocumentTypeDropdown(context)),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _buildOwningDepartmentField(context, lightMode),
                  ),
                ],
              ),
            ],
          SizedBox(height: 20.h),
          _buildLimitDepartmentSection(context, isMobile, lightMode),
          SizedBox(height: 25.h),
          _buildSchedulePublishingSection(context, isMobile, lightMode),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeDropdown(BuildContext context) {
    String currentDocType = submittedDocument != null
        ? submittedDocument!.currentKnowledgeDocumentType
        : dropDownMenuText;

    return docTypeDropMenu(
      context,
      dropDownMenuText: currentDocType,
      onChanged: onDocTypeChanged,
    );
  }

  String _getLocalizedDepartmentName(BuildContext context, String departmentId) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    try {
      final departmentController = Get.find<MainCoreDepartmentCubit>();

      String? localizedName;
      if (isArabic) {
        localizedName = departmentController.getArabicDepartmentNameFromDepartmentId(
          departmentId: departmentId,
        );
      } else {
        localizedName = departmentController.getEnglishDepartmentNameFromDepartmentId(
          departmentId: departmentId,
        );
      }

      return localizedName ?? employeeDepartment;
    } catch (e) {
      debugPrint('⚠️ Error getting department name: $e');
      return employeeDepartment;
    }
  }

  // ✅ UPDATED: Build owning department field - dropdown if has permission, otherwise read-only
  Widget _buildOwningDepartmentField(BuildContext context, bool lightMode) {
    final hasPermission = _hasSelectOwningDepartmentPermission();

    if (hasPermission) {
      return _buildOwningDepartmentDropdown(context, lightMode);
    } else {
      return _buildOwningDepartmentReadOnly(context, lightMode);
    }
  }

  // ✅ NEW: Dropdown for owning department (when user has permission)
  Widget _buildOwningDepartmentDropdown(BuildContext context, bool lightMode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Create list of department items for dropdown - format: {"key": departmentId, "value": displayName}
    final List<Map<String, String>> departmentItems = availableDepartments.map((dept) {
      final displayName = isArabic
          ? (dept.departmentNameInArabic ?? dept.departmentName ?? 'Unknown')
          : (dept.departmentName ?? 'Unknown');

      return {
        "key": dept.departmentID ?? '',
        "value": isArabic ? displayName : FormatHelper.capitalize(displayName),
      };
    }).toList();

    // Find the current display value for the selected department
    String currentDisplayValue = selectedOwningDepartmentId ?? '';
    if (selectedOwningDepartmentId != null) {
      final selectedDept = departmentItems.firstWhere(
            (item) => item["key"] == selectedOwningDepartmentId,
        orElse: () => {"key": selectedOwningDepartmentId!, "value": employeeDepartment},
      );
      currentDisplayValue = selectedDept["key"] ?? selectedOwningDepartmentId!;
    }

    // FIXED 18/8/2026: this used to be wrapped in `SizedBox(height: 36)`.
    // With `label` set, CustomDropdown returns a Column of
    // [label, 6sp gap, trigger] — about 63pt — so clamping the whole widget
    // to 36 produced the "BOTTOM OVERFLOWED BY 27 PIXELS" stripe under
    // "Owning Department". `height` sizes the trigger alone, which is what
    // was actually wanted; the label then sizes itself and the Row above
    // keeps both columns aligned.
    //
    // FIXED 30/8/2026: `key: ValueKey(selectedOwningDepartmentId)` removed —
    // same reason as the Document Type dropdown. A key derived from the
    // selected value recreates the dropdown's State on every pick, disposing it
    // while its close animation is still running. See `_removeOverlayEntry` in
    // 1-custom_dropdown.dart.
    return CustomDropdown<String>(
      value: currentDisplayValue,
      items: departmentItems
          .map((e) => DropdownItem<String>(
                value: e['key'] ?? '',
                label: e['value'] ?? '',
              ))
          .toList(),
      onChanged: (v) => onOwningDepartmentChanged(v),
      label: S.of(context).owning_department,
      hint: S.of(context).owning_department,
      height: 36,
      // triggerPadding: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }

  // ✅ NEW: Read-only field for owning department (when user does NOT have permission)
  Widget _buildOwningDepartmentReadOnly(BuildContext context, bool lightMode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Get the display name
    String displayName = employeeDepartment;

    if (selectedOwningDepartmentId != null) {
      try {
        final departmentController = Get.find<MainCoreDepartmentCubit>();

        if (isArabic) {
          displayName = departmentController.getArabicDepartmentNameFromDepartmentId(
            departmentId: selectedOwningDepartmentId!,
          ) ?? employeeDepartment;
        } else {
          displayName = departmentController.getEnglishDepartmentNameFromDepartmentId(
            departmentId: selectedOwningDepartmentId!,
          ) ?? employeeDepartment;
        }
      } catch (e) {
        debugPrint('⚠️ Error getting department name: $e');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).owning_department,
          style: StyleText.fontSize14Weight400.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: ScreenUtil().screenWidth,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: lightMode ? AppColors.background : AppColors.background,
          ),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 8.sp,
            vertical: 3.sp,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              isArabic ? displayName : FormatHelper.capitalize(displayName),
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitDepartmentSection(
      BuildContext context,
      bool isMobile,
      bool lightMode,
      )
  {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      children: [
        isMobile ? Row(
          children: [
            Text(
              S.of(context).limit_department_availability,
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
            const Spacer(),
            CustomRtlSwitch(
              value: limitDepartmentAvailability,
              onToggle: onLimitDepartmentToggle,
              activeColor: AppColors.secondaryPrimary,
              inactiveColor: AppColors.grey,
              isRtl: isArabic,
            ),
          ],
        ): Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    S.of(context).limit_department_availability,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  CustomRtlSwitch(
                    value: limitDepartmentAvailability,
                    onToggle: onLimitDepartmentToggle,
                    activeColor: AppColors.secondaryPrimary,
                    inactiveColor: AppColors.grey,
                    isRtl: isArabic,
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
            SizedBox(width: 15.sp),
          ],
        ),
        if (limitDepartmentAvailability) ...[
          SizedBox(height: 15.h),
          isMobile ?_buildDepartmentSelector(context, isMobile, lightMode):  Row(
            children: [
              Expanded(child: _buildDepartmentSelector(context, isMobile, lightMode),),
              Expanded(child: Container()),
              SizedBox(width: 15.sp),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDepartmentSelector(
      BuildContext context,
      bool isMobile,
      bool lightMode,
      )
  {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final Map<String, String> englishToArabic = {};
    final Map<String, String> arabicToEnglish = {};

    for (final dept in availableDepartments) {
      final englishName = dept.departmentName ?? '';
      final arabicName = dept.departmentNameInArabic ?? englishName;

      if (englishName.isNotEmpty) {
        englishToArabic[englishName] = arabicName;
        arabicToEnglish[arabicName] = englishName;
      }
    }

    final List<String> departmentNames = availableDepartments.map((dept) {
      if (isArabic) {
        return dept.departmentNameInArabic ?? dept.departmentName ?? '';
      } else {
        return dept.departmentName ?? '';
      }
    }).toList();

    final List<String> selectedDepartmentNames = departmentSelections.entries
        .where((entry) => entry.value)
        .map((entry) {
      if (isArabic) {
        return englishToArabic[entry.key] ?? entry.key;
      } else {
        return entry.key;
      }
    })
        .toList();

    return SelectChip(
      title: S.of(context).department,
      departments: departmentNames,
      selectedDepartments: selectedDepartmentNames,
      width: MediaQuery.of(context).size.width - 10.w,
      menuWidth: isMobile ? 310.w : ScreenUtil().screenWidth * 0.429,
      color: lightMode ? AppColors.background : AppColors.background,
      singleSelect: false,
      apper: true,
      menuItemHeight: 30.h,
      capitalizeDepartments: true,
      onAdd: (displayName) {
        final originalKey = isArabic
            ? (arabicToEnglish[displayName] ?? displayName)
            : displayName;
        onDepartmentAdded(originalKey);
      },
      onRemove: (displayName) {
        final originalKey = isArabic
            ? (arabicToEnglish[displayName] ?? displayName)
            : displayName;
        onDepartmentRemoved(originalKey);
      },
    );
  }

  Widget _buildSchedulePublishingSection(
      BuildContext context,
      bool isMobile,
      bool lightMode,
      )
  {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SizedBox(
      child:  Column(
        children: [
          isMobile ? Row(
            children: [
              Text(
                S.of(context).schedule_publishing,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
              const Spacer(),
              CustomRtlSwitch(
                value: schedulePublishing,
                onToggle: onSchedulePublishingToggle,
                activeColor: AppColors.secondaryPrimary,
                inactiveColor: AppColors.grey,
                isRtl: isArabic,
              ),
            ],
          ):  Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      S.of(context).schedule_publishing,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    CustomRtlSwitch(
                      value: schedulePublishing,
                      onToggle: onSchedulePublishingToggle,
                      activeColor: AppColors.secondaryPrimary,
                      inactiveColor: AppColors.grey,
                      isRtl: isArabic,
                    ),
                  ],
                ),
              ),
              Expanded(child: ClipRRect()),
              SizedBox(width: 15.sp),
            ],
          ),
          if (schedulePublishing) ...[

            isMobile ? Column(
              children: [
                SizedBox(height: 13.h),
                DateTimePicker(
                  label: S.of(context).start_date,
                  date: startDate,
                  time: startTime,
                  onDateSelected: onStartDateSelected,
                  onTimeSelected: onStartTimeSelected,
                  lightMode: lightMode,
                  isEndDate: false,
                ),
                SizedBox(height: 15.h),
                DateTimePicker(
                  label: S.of(context).end_date,
                  date: endDate,
                  time: endTime,
                  onDateSelected: onEndDateSelected,
                  onTimeSelected: onEndTimeSelected,
                  lightMode: lightMode,
                  isEndDate: true,
                  minDate: startDate,
                  startDate: startDate,
                  startTime: startTime,
                ),
              ],
            ):  Row(
              children: [
                Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 13.h),
                        DateTimePicker(
                          label: S.of(context).start_date,
                          date: startDate,
                          time: startTime,
                          onDateSelected: onStartDateSelected,
                          onTimeSelected: onStartTimeSelected,
                          lightMode: lightMode,
                          isEndDate: false,
                        ),
                        SizedBox(height: 15.h),
                        DateTimePicker(
                          label: S.of(context).end_date,
                          date: endDate,
                          time: endTime,
                          onDateSelected: onEndDateSelected,
                          onTimeSelected: onEndTimeSelected,
                          lightMode: lightMode,
                          isEndDate: true,
                          minDate: startDate,
                          startDate: startDate,
                          startTime: startTime,
                        ),
                      ],
                    )
                ),
                Expanded(child: Column()),
                SizedBox(width: 15.sp),
              ],
            )
          ],
        ],
      ),
    );
  }
}

// ✅ Custom RTL Switch Widget with 180-degree rotation support
class CustomRtlSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onToggle;
  final Color activeColor;
  final Color inactiveColor;
  final Color? toggleColor;
  final bool isRtl;
  final double? height;
  final double? width;
  final double? padding;
  final double? borderRadius;
  final double? toggleSize;

  const CustomRtlSwitch({
    super.key,
    required this.value,
    required this.onToggle,
    required this.activeColor,
    required this.inactiveColor,
    this.toggleColor,
    this.isRtl = false,
    this.height,
    this.width,
    this.padding,
    this.borderRadius,
    this.toggleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(isRtl ? math.pi : 0),
      child: FlutterSwitch(
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        toggleColor: toggleColor ?? AppColors.colorWhite,
        height: height ?? 22.sp,
        width: width ?? 38.sp,
        padding: padding ?? 3.sp,
        borderRadius: borderRadius ?? 20.sp,
        toggleSize: toggleSize ?? 16.sp,
        value: value,
        onToggle: onToggle,
      ),
    );
  }
}
