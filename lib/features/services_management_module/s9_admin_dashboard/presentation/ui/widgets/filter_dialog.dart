// ******************* FILE INFO *******************
// File Name: filter_dialog.dart
// Description: Filter dialog for service requests with department, status, and date filters
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah
// Last Update: [Current Date]
import 'package:get/get.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart'; // ✅ Updated import
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ServiceRequestFilterDialog {
  /// Show filter dialog and return selected filters
  static Future<Map<String, dynamic>?> show(
      BuildContext context,
      List<ServicesHistoryModel> models, { // ✅ Updated type
        String? currentDepartment,
        String? currentStatus,
        DateTime? currentDate,
      }) async {
    String? selectedDepartment = currentDepartment;
    String? selectedStatus = currentStatus;
    DateTime? selectedDate = currentDate;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final List<String> statuses = [
      "approved",
      "done",
      "cancel",
      "rejected",
      "inprogress",
      "branchsla",
      "pending",
    ];

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: AppColors.transparent,
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: 645.sp,
                  height: isMobile ? 238.sp : 220.sp,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(context, lightMode),
                        SizedBox(height: 15.sp),

                        // Filters
                        isMobile
                            ? _buildMobileFilters(
                          context,
                          setState,
                          selectedDepartment,
                          selectedStatus,
                          selectedDate,
                          statuses,
                          lightMode,
                          isArabic,
                              (val) => selectedDepartment = val,
                              (val) => selectedStatus = val,
                              (val) => selectedDate = val,
                        )
                            : _buildTabletFilters(
                          context,
                          setState,
                          selectedDepartment,
                          selectedStatus,
                          selectedDate,
                          statuses,
                          lightMode,
                          isArabic,
                              (val) => selectedDepartment = val,
                              (val) => selectedStatus = val,
                              (val) => selectedDate = val,
                        ),

                        SizedBox(height: 15.sp),

                        // Buttons
                        _buildButtons(
                          context,
                          setState,
                          selectedDepartment,
                          selectedStatus,
                          selectedDate,
                              () {
                            selectedDepartment = null;
                            selectedStatus = null;
                            selectedDate = null;
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ==================== HEADER ====================

  static Widget _buildHeader(BuildContext context, bool lightMode) {
    return Row(
      children: [
        Container(
          width: 30.sp,
          height: 30.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: ClipOval(
              child: SvgPicture.asset(
                "assets/icons_assets/main_icons_assets/filter_sliders.svg",
                width: 13.sp,
                height: 13.sp,
                fit: BoxFit.fill,
                color: AppColors.textButton,
              ),
            ),
          ),
        ),
        SizedBox(width: 6.sp),
        Text(
          S.of(context).Filter,
          style: StyleText.fontSize16Weight500.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================

  static Widget _buildMobileFilters(
      BuildContext context,
      StateSetter setState,
      String? selectedDepartment,
      String? selectedStatus,
      DateTime? selectedDate,
      List<String> statuses,
      bool lightMode,
      bool isArabic,
      ValueChanged<String?> onDepartmentChanged,
      ValueChanged<String?> onStatusChanged,
      ValueChanged<DateTime?> onDateChanged,
      ) {
    return Column(
      children: [
        _buildDepartmentField(
          context,
          selectedDepartment,
              (val) => setState(() => onDepartmentChanged(val)),
          lightMode,
          isArabic,
        ),
        SizedBox(height: 15.sp),
        _buildRequestDateField(
          context,
          selectedDate,
              (val) => setState(() => onDateChanged(val)),
          lightMode,
        ),
        SizedBox(height: 15.sp),
        _buildStatusField(
          context,
          statuses,
          selectedStatus,
              (val) => setState(() => onStatusChanged(val)),
          lightMode,
          isArabic,
        ),
      ],
    );
  }

  // ==================== TABLET LAYOUT ====================

  static Widget _buildTabletFilters(
      BuildContext context,
      StateSetter setState,
      String? selectedDepartment,
      String? selectedStatus,
      DateTime? selectedDate,
      List<String> statuses,
      bool lightMode,
      bool isArabic,
      ValueChanged<String?> onDepartmentChanged,
      ValueChanged<String?> onStatusChanged,
      ValueChanged<DateTime?> onDateChanged,
      ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDepartmentField(
                context,
                selectedDepartment,
                    (val) => setState(() => onDepartmentChanged(val)),
                lightMode,
                isArabic,
              ),
            ),
            SizedBox(width: 20.sp),
            Expanded(
              child: _buildRequestDateField(
                context,
                selectedDate,
                    (val) => setState(() => onDateChanged(val)),
                lightMode,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.sp),
        Row(
          children: [
            Expanded(
              child: _buildStatusField(
                context,
                statuses,
                selectedStatus,
                    (val) => setState(() => onStatusChanged(val)),
                lightMode,
                isArabic,
              ),
            ),
            SizedBox(width: 20.sp),
            Expanded(child: Container())
          ],
        ),
      ],
    );
  }

  // ==================== FILTER FIELDS ====================

  static Widget _buildDepartmentField(
      BuildContext context,
      String? selectedDepartment,
      ValueChanged<String?> onChanged,
      bool lightMode,
      bool isArabic,
      ) {
    // W22: dynamic department-name map sourced from the department controller.
    final enToAr = context.read<MainCoreDepartmentCubit>().enToAr;

    // Bug report p.30 ("Branding"): once a value was picked the field showed
    // only "Operations" / "Done" with nothing saying WHAT it was. Every field
    // now carries its title above the box, like the Form Builder filter.
    return CustomDropdown<String>(
      label: S.of(context).department,
      height: 38,
      value:
          enToAr.keys.contains(selectedDepartment) ? selectedDepartment : null,
      hint: S.of(context).chooseHere,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.r),
      maxOverlayHeight: 120.sp,
      valueStyle: StyleText.fontSize12Weight400.copyWith(
        color: lightMode ? AppColors.blackButton : AppColors.white,
      ),
      itemStyle: StyleText.fontSize12Weight400.copyWith(
        color: lightMode ? AppColors.blackButton : AppColors.white,
      ),
      items: enToAr.entries
          .map((e) => DropdownItem<String>(
                value: e.key,
                label: isArabic ? e.value : e.key,
              ))
          .toList(),
      onChanged: (v) => onChanged(v),
    );
  }

  static Widget _buildRequestDateField(
      BuildContext context,
      DateTime? selectedDate,
      ValueChanged<DateTime?> onDatePicked,
      bool lightMode,
      ) {
    // Bug report p.29/p.30: was a hand-made box that opened Material's
    // showDatePicker. It is now the app's standard date field + picker
    // (CustomDropdownCalendar) — same title, height, arrows and
    // Cancel / Set Date buttons as every other date filter.
    return CustomDropdownCalendar(
      label: S.of(context).requestDate,
      hint: S.of(context).chooseTheDate,
      value: selectedDate,
      height: 38,
      fillColor: AppColors.background,
      onChanged: (DateTime? d) {
        if (d != null) onDatePicked(d);
      },
    );
  }

  static Widget _buildStatusField(
      BuildContext context,
      List<String> statuses,
      String? selectedStatus,
      ValueChanged<String?> onChanged,
      bool lightMode,
      bool isArabic,
      ) {
    String localize(String status) {
      if (!isArabic) return status;
      switch (status) {
        case "approved":
          return "تمت الموافقة";
        case "done":
          return "تم";
        case "cancel":
          return "أُلغي";
        case "rejected":
          return "مرفوض";
        case "inprogress":
          return "قيد التنفيذ";
        case "branchsla":
          return "انتهت المهلة";
        case "pending":
          return "قيد الانتظار";
        default:
          return status;
      }
    }

    return CustomDropdown<String>(
      label: S.of(context).status,
      height: 38,
      value: statuses.contains(selectedStatus) ? selectedStatus : null,
      hint: S.of(context).chooseHere,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.r),
      maxOverlayHeight: 120.sp,
      valueStyle: StyleText.fontSize12Weight400.copyWith(
        color: lightMode ? AppColors.blackButton : AppColors.white,
      ),
      itemStyle: StyleText.fontSize12Weight400.copyWith(
        color: lightMode ? AppColors.blackButton : AppColors.white,
      ),
      items: statuses
          .map((status) => DropdownItem<String>(
                value: status,
                label:
                    FormatHelper.capitalize(isArabic ? localize(status) : status),
              ))
          .toList(),
      onChanged: (v) => onChanged(v),
    );
  }

  // ==================== BUTTONS ====================

  static Widget _buildButtons(
      BuildContext context,
      StateSetter setState,
      String? selectedDepartment,
      String? selectedStatus,
      DateTime? selectedDate,
      VoidCallback onReset,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: S.of(context).Reset,
          function: () {
            setState(() {
              onReset();
            });
          },
          color: AppColors.grey,
          radius: 8.r,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.black,
          ),
          height: 38.sp,
          width: 135.sp,
        ),
        customButton(
          title: S.of(context).Apply,
          function: () {
            Navigator.pop(context, {
              'department': selectedDepartment,
              'status': selectedStatus,
              'date': selectedDate,
            });
          },
          color: AppColors.primary,
          radius: 8.r,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          height: 38.sp,
          width: 135.sp,
        ),
      ],
    );
  }
}
