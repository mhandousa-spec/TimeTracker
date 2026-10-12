/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/build_configuration_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_configuration_section.dart
/// Purpose: Extended configuration-section builders for the create-knowledge form.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import '../../../../main_controller/presentation/ui/core_widgets/select_chip.dart';
import '../../../../main_controller/presentation/ui/widgets/doc_type_drop_menu.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget buildConfigurationSection(
  BuildContext context, {
  required CreateKnowledgeModel? submittedDocument,
  required String dropDownMenuText,
  required Function(String?) onDocumentTypeChanged,
  required String? employeeDepartment,
  required bool limitDepartmentAvailability,
  required Function(bool) onLimitDepartmentToggle,
  required List<DepartmentModelPro> availableDepartments,
  required String departmentMenuText,
  required List<String> selectedDepartments,
  required Map<String, bool> departmentSelections,
  required Function(String) onDepartmentAdd,
  required Function(String) onDepartmentRemove,
  required bool schedulePublishing,
  required Function(bool) onSchedulePublishingToggle,
  required DateTime? startDate,
  required TimeOfDay? startTime,
  required Function(DateTime) onStartDateSelected,
  required Function(TimeOfDay) onStartTimeSelected,
  required DateTime? endDate,
  required TimeOfDay? endTime,
  required Function(DateTime) onEndDateSelected,
  required Function(TimeOfDay) onEndTimeSelected,
  required bool hasInitializedDepartments,
  required bool hasInitializedSchedule,
  required Function() onDepartmentsInitialized,
  required Function() onScheduleInitialized,
  required Function(bool, Map<String, bool>) onDepartmentsInitializedWithData,
  required Function(bool, DateTime?, TimeOfDay?, DateTime?, TimeOfDay?)
  onScheduleInitializedWithData,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final lightMode = Theme.of(context).brightness == Brightness.light;

  return Container(
    width: ScreenUtil().screenWidth,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: lightMode ? AppColors.white : AppColors.background,
    ),
    padding: EdgeInsets.all(15.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          _buildDocumentTypeDropdown(
            context,
            submittedDocument: submittedDocument,
            dropDownMenuText: dropDownMenuText,
            onDocumentTypeChanged: onDocumentTypeChanged,
          ),
          SizedBox(height: 33.h),
          _buildOwningDepartmentField(
            context,
            employeeDepartment: employeeDepartment,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildDocumentTypeDropdown(
                  context,
                  submittedDocument: submittedDocument,
                  dropDownMenuText: dropDownMenuText,
                  onDocumentTypeChanged: onDocumentTypeChanged,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: _buildOwningDepartmentField(
                  context,
                  employeeDepartment: employeeDepartment,
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 20.h),
        _buildLimitDepartmentSection(
          context,
          submittedDocument: submittedDocument,
          limitDepartmentAvailability: limitDepartmentAvailability,
          onLimitDepartmentToggle: onLimitDepartmentToggle,
          availableDepartments: availableDepartments,
          departmentMenuText: departmentMenuText,
          selectedDepartments: selectedDepartments,
          departmentSelections: departmentSelections,
          onDepartmentAdd: onDepartmentAdd,
          onDepartmentRemove: onDepartmentRemove,
          hasInitializedDepartments: hasInitializedDepartments,
          onDepartmentsInitialized: onDepartmentsInitialized,
          onDepartmentsInitializedWithData: onDepartmentsInitializedWithData,
        ),
        SizedBox(height: 25.h),
        _buildSchedulePublishingSection(
          context,
          submittedDocument: submittedDocument,
          schedulePublishing: schedulePublishing,
          onSchedulePublishingToggle: onSchedulePublishingToggle,
          startDate: startDate,
          startTime: startTime,
          onStartDateSelected: onStartDateSelected,
          onStartTimeSelected: onStartTimeSelected,
          endDate: endDate,
          endTime: endTime,
          onEndDateSelected: onEndDateSelected,
          onEndTimeSelected: onEndTimeSelected,
          hasInitializedSchedule: hasInitializedSchedule,
          onScheduleInitialized: onScheduleInitialized,
          onScheduleInitializedWithData: onScheduleInitializedWithData,
        ),
      ],
    ),
  );
}

Widget _buildDocumentTypeDropdown(
  BuildContext context, {
  required CreateKnowledgeModel? submittedDocument,
  required String dropDownMenuText,
  required Function(String?) onDocumentTypeChanged,
}) {
  final currentDocType =
      submittedDocument?.currentKnowledgeDocumentType ?? dropDownMenuText;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      docTypeDropMenu(
        context,
        dropDownMenuText: currentDocType,
        onChanged: (value) {
          if (value != null) {
            onDocumentTypeChanged(value.toString());
            log('You choose $value');
          }
        },
      ),
    ],
  );
}

Widget _buildOwningDepartmentField(
  BuildContext context, {
  required String? employeeDepartment,
}) {
  final lightMode = Theme.of(context).brightness == Brightness.light;

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
      SizedBox(height: 8.h),
      Container(
        width: ScreenUtil().screenWidth,
        height: 36.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: lightMode
              ? AppColors.background
              : AppColors.chatBackground,
        ),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 8.sp,
          vertical: 7.sp,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            employeeDepartment ?? '',
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
  BuildContext context, {
  required CreateKnowledgeModel? submittedDocument,
  required bool limitDepartmentAvailability,
  required Function(bool) onLimitDepartmentToggle,
  required List<DepartmentModelPro> availableDepartments,
  required String departmentMenuText,
  required List<String> selectedDepartments,
  required Map<String, bool> departmentSelections,
  required Function(String) onDepartmentAdd,
  required Function(String) onDepartmentRemove,
  required bool hasInitializedDepartments,
  required Function() onDepartmentsInitialized,
  required Function(bool, Map<String, bool>) onDepartmentsInitializedWithData,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final lightMode = Theme.of(context).brightness == Brightness.light;

  // Initialize departments from document if needed
  _initializeDepartmentsFromDocument(
    submittedDocument: submittedDocument,
    hasInitializedDepartments: hasInitializedDepartments,
    onDepartmentsInitialized: onDepartmentsInitialized,
    onDepartmentsInitializedWithData: onDepartmentsInitializedWithData,
  );

  return SizedBox(
    width: isMobile ? double.infinity : ScreenUtil().screenWidth * 0.42,
    child: Column(
      children: [
        _buildSwitchRow(
          context,
          label: S.of(context).limit_department_availability,
          value: limitDepartmentAvailability,
          onToggle: onLimitDepartmentToggle,
          lightMode: lightMode,
        ),
        if (limitDepartmentAvailability) ...[
          SizedBox(height: 15.h),
          _buildDepartmentSelector(
            context,
            isMobile: isMobile,
            lightMode: lightMode,
            availableDepartments: availableDepartments,
            departmentMenuText: departmentMenuText,
            selectedDepartments: selectedDepartments,
            onDepartmentAdd: onDepartmentAdd,
            onDepartmentRemove: onDepartmentRemove,
          ),
        ],
      ],
    ),
  );
}

void _initializeDepartmentsFromDocument({
  required CreateKnowledgeModel? submittedDocument,
  required bool hasInitializedDepartments,
  required Function() onDepartmentsInitialized,
  required Function(bool, Map<String, bool>) onDepartmentsInitializedWithData,
}) {
  if (submittedDocument == null || hasInitializedDepartments) return;

  final limitedDepts = submittedDocument.currentLimitedDepartmentsList;
  if (limitedDepts.isNotEmpty) {
    final Map<String, bool> newSelections = {};
    for (var dept in limitedDepts) {
      newSelections[dept] = true;
    }
    onDepartmentsInitializedWithData(true, newSelections);
  } else {
    onDepartmentsInitialized();
  }
}

Widget _buildSwitchRow(
  BuildContext context, {
  required String label,
  required bool value,
  required Function(bool) onToggle,
  required bool lightMode,
}) {
  return Row(
    children: [
      Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
      ),
      const Spacer(),
      FlutterSwitch(
        value: value,
        onToggle: onToggle,
        width: 38.sp,
        height: 22.sp,
        activeColor: AppColors.secondaryPrimary,
        borderRadius: 20.sp,
        padding: 3.sp,
        toggleSize: 16.sp,
        inactiveColor: AppColors.grey,
      ),
    ],
  );
}

Widget _buildDepartmentSelector(
  BuildContext context, {
  required bool isMobile,
  required bool lightMode,
  required List<DepartmentModelPro> availableDepartments,
  required String departmentMenuText,
  required List<String> selectedDepartments,
  required Function(String) onDepartmentAdd,
  required Function(String) onDepartmentRemove,
}) {
  final departmentNames = availableDepartments
      .map((dept) => dept.departmentName!)
      .toList();

  return SelectChip(
    title: departmentMenuText,
    departments: departmentNames,
    selectedDepartments: selectedDepartments,
    width: MediaQuery.of(context).size.width - 60.w,
    menuWidth: isMobile ? 310.w : ScreenUtil().screenWidth * 0.429,
    color: lightMode ? AppColors.background : AppColors.chatBackground,
    triggerHeight: 36.0,
    singleSelect: false,
    apper: true,
    menuItemHeight: 45.h,
    onAdd: onDepartmentAdd,
    onRemove: onDepartmentRemove,
  );
}

Widget _buildSchedulePublishingSection(
  BuildContext context, {
  required CreateKnowledgeModel? submittedDocument,
  required bool schedulePublishing,
  required Function(bool) onSchedulePublishingToggle,
  required DateTime? startDate,
  required TimeOfDay? startTime,
  required Function(DateTime) onStartDateSelected,
  required Function(TimeOfDay) onStartTimeSelected,
  required DateTime? endDate,
  required TimeOfDay? endTime,
  required Function(DateTime) onEndDateSelected,
  required Function(TimeOfDay) onEndTimeSelected,
  required bool hasInitializedSchedule,
  required Function() onScheduleInitialized,
  required Function(bool, DateTime?, TimeOfDay?, DateTime?, TimeOfDay?)
  onScheduleInitializedWithData,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final lightMode = Theme.of(context).brightness == Brightness.light;

  // Initialize schedule from document if needed
  _initializeScheduleFromDocument(
    submittedDocument: submittedDocument,
    hasInitializedSchedule: hasInitializedSchedule,
    onScheduleInitialized: onScheduleInitialized,
    onScheduleInitializedWithData: onScheduleInitializedWithData,
  );

  return SizedBox(
    width: isMobile ? double.infinity : ScreenUtil().screenWidth * 0.42,
    child: Column(
      children: [
        _buildSwitchRow(
          context,
          label: S.of(context).schedule_publishing,
          value: schedulePublishing,
          onToggle: onSchedulePublishingToggle,
          lightMode: lightMode,
        ),
        if (schedulePublishing) ...[
          SizedBox(height: 13.h),
          _buildDateTimePicker(
            context,
            label: S.of(context).start_date,
            date: startDate,
            time: startTime,
            onDateSelected: onStartDateSelected,
            onTimeSelected: onStartTimeSelected,
            lightMode: lightMode,
          ),
          SizedBox(height: 15.h),
          _buildDateTimePicker(
            context,
            label: S.of(context).end_date,
            date: endDate,
            time: endTime,
            onDateSelected: onEndDateSelected,
            onTimeSelected: onEndTimeSelected,
            lightMode: lightMode,
          ),
        ],
      ],
    ),
  );
}

void _initializeScheduleFromDocument({
  required CreateKnowledgeModel? submittedDocument,
  required bool hasInitializedSchedule,
  required Function() onScheduleInitialized,
  required Function(bool, DateTime?, TimeOfDay?, DateTime?, TimeOfDay?)
  onScheduleInitializedWithData,
}) {
  if (submittedDocument == null || hasInitializedSchedule) return;

  final schedulePublishing = submittedDocument.currentSchedulePublishing;
  if (schedulePublishing) {
    final startDate = submittedDocument.currentStartDateTime!.toDate();
    final startTime = TimeOfDay.fromDateTime(startDate);
    final endDate = submittedDocument.currentEndDateTime!.toDate();
    final endTime = TimeOfDay.fromDateTime(endDate);

    onScheduleInitializedWithData(
      schedulePublishing,
      startDate,
      startTime,
      endDate,
      endTime,
    );
  } else {
    onScheduleInitialized();
  }
}

Widget _buildDateTimePicker(
  BuildContext context, {
  required String label,
  required DateTime? date,
  required TimeOfDay? time,
  required Function(DateTime) onDateSelected,
  required Function(TimeOfDay) onTimeSelected,
  required bool lightMode,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: StyleText.fontSize14Weight500.copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
      ),
      SizedBox(height: 4.h),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildDateField(
              context,
              date: date,
              onDateSelected: onDateSelected,
              lightMode: lightMode,
            ),
          ),
          SizedBox(width: 10.h),
          Expanded(
            flex: 1,
            child: _buildTimeField(
              context,
              time: time,
              onTimeSelected: onTimeSelected,
              lightMode: lightMode,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildDateField(
  BuildContext context, {
  required DateTime? date,
  required Function(DateTime) onDateSelected,
  required bool lightMode,
}) {
  return GestureDetector(
    onTap: () => _showDatePickerDialog(context, onDateSelected),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: lightMode ? AppColors.background : AppColors.chatBackground,
      ),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 8.sp,
        vertical: 10.sp,
      ),
      child: Row(
        children: [
          Text(
            date == null ? 'DD/MM/YYYY' : DateFormat('dd/MM/yyyy').format(date),
            style: StyleText.fontSize12Weight400.copyWith(
              color: lightMode
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ),
          ),
          const Spacer(),
          CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
            height: 16.h,
            width: 16.w,
          ),
        ],
      ),
    ),
  );
}

Future<void> _showDatePickerDialog(
  BuildContext context,
  Function(DateTime) onDateSelected,
) async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    onDateSelected(pickedDate);
    log('Selected date: ${pickedDate.toString()}');
  }
}

Widget _buildTimeField(
  BuildContext context, {
  required TimeOfDay? time,
  required Function(TimeOfDay) onTimeSelected,
  required bool lightMode,
}) {
  final formattedTime = MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(time ?? TimeOfDay.now(), alwaysUse24HourFormat: true);

  return GestureDetector(
    onTap: () => _showTimePickerDialog(context, onTimeSelected),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: lightMode ? AppColors.background : AppColors.chatBackground,
      ),
      padding: EdgeInsetsDirectional.only(
        start: 8.w,
        end: 10.w,
        top: 10.w,
        bottom: 10.w,
      ),
      child: Row(
        children: [
          Text(
            time == null ? '00:00' : formattedTime,
            style: StyleText.fontSize12Weight400.copyWith(
              color: lightMode
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ),
          ),
          const Spacer(),
          CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_clock.svg',
            height: 16.h,
            width: 16.w,
          ),
        ],
      ),
    ),
  );
}

Future<void> _showTimePickerDialog(
  BuildContext context,
  Function(TimeOfDay) onTimeSelected,
) async {
  final pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (pickedTime != null) {
    onTimeSelected(pickedTime);
    log('Selected time: ${pickedTime.format(context)}');
  }
}
