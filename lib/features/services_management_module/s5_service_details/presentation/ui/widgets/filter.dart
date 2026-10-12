// ******************* FILE INFO *******************
// File Name: filter
// Description: Filter.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************

// ----------------------------- 🔍 Search & Filter Dialog (PERSISTENT) -----------------------------
import 'package:get/get.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/core/custom/53-custom_date_pic.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/56-custom_services_multi_select.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'dart:ui' as ui;
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Future<Map<String, dynamic>?> showFilterDialog(
    BuildContext context,
    List<ServicesHistoryModel> models, {
      List<String>? initialDepartments,
      List<String>? initialStatuses,
      DateTime? initialDate,
      String? initialSortBy,
      bool isEmployeesTab = false,
    }) async {
  // W14: no try/catch in this UI free function (§11.2).
  // ✅ Get department controller
  final departmentController = context.read<MainCoreDepartmentCubit>();

    // ✅ Initialize from parent (persisted values)
    List<String> selectedDepartments = initialDepartments ?? [];
    List<String> selectedStatuses = initialStatuses ?? [];
    String? selectedSortBy = initialSortBy;

    // normalize date to yyyy-mm-dd (drop time)
    DateTime? selectedDate = (initialDate == null)
        ? null
        : DateTime(initialDate.year, initialDate.month, initialDate.day);

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ UPDATED: Bilingual status map (English key -> Arabic label)
    final Map<String, String> statusMap = {
      "Done": S.of(context).status_done,
      "Approved": S.of(context).sm_approved,
      "In Progress": S.of(context).status_inprogress,
      "Pending": S.of(context).status_pending,
      "Rejected": S.of(context).status_rejected,
      "Canceled": S.of(context).status_cancel,
      "Breached SLA": S.of(context).sm_breachedSla,
    };

    // ✅ Get status keys (English - used internally)
    final List<String> statusKeys = statusMap.keys.toList();

    // ✅ Get status display labels (Arabic or English - shown to user)
    final List<String> statusLabels = statusMap.values.toList();

    // ✅ Sort options for employees tab (bilingual)
    final Map<String, String> sortOptionsMap = {
      "Done": S.of(context).status_done,
      "Breached SLA": S.of(context).sm_breachedSla,
    };

    final List<String> sortKeys = sortOptionsMap.keys.toList();
    final List<String> sortLabels = sortOptionsMap.values.toList();

    // ✅ Get dynamic departments from controller
    final allDepartments = isArabic
        ? departmentController.departmentsArabicName
        : departmentController.departmentsEnglishName;

    // Get date range from models using FieldHistory timestamps
    final allDates = models
        .where((m) => m.timestamps.isNotEmpty)
        .map((m) {
      final timestamp = m.timestamps.first;
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime(date.year, date.month, date.day);
    })
        .toList()
      ..sort();

    final DateTime? minDate = allDates.isNotEmpty ? allDates.first : null;
    final DateTime? maxDate = allDates.isNotEmpty ? allDates.last : null;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final isMobile = ContextExtension(context).isPhone;
        final lightMode = Theme.of(dialogContext).brightness == Brightness.light;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: lightMode ? AppColors.white : AppColors.chatBackground,
          child: StatefulBuilder(
            builder: (builderContext, setDialogState) {
              return Container(
                width: isMobile ? null : 645.sp,
                constraints: BoxConstraints(
                  maxWidth: 645.sp,
                  minWidth: isMobile ? 300.sp : 500.sp,
                ),
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.white : AppColors.chatBackground,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.all(15.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 30.sp,
                          height: 30.sp,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/icons_assets/main_icons_assets/filter_sliders.svg",
                              width: 13.sp,
                              height: 13.sp,
                              fit: BoxFit.scaleDown,
                              color: AppColors.textButton,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Text(
                          S.of(builderContext).Filter,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: lightMode ? AppColors.blackButton : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.sp),

                    // Form Fields
                    _buildFormFields(
                      context: builderContext,
                      isMobile: isMobile,
                      isArabic: isArabic,
                      lightMode: lightMode,
                      isEmployeesTab: isEmployeesTab,
                      selectedDepartments: selectedDepartments,
                      selectedDate: selectedDate,
                      selectedStatuses: selectedStatuses,
                      selectedSortBy: selectedSortBy,
                      minDate: minDate,
                      maxDate: maxDate,
                      allDepartments: allDepartments,
                      statusKeys: statusKeys,
                      statusLabels: statusLabels,
                      statusMap: statusMap,
                      sortKeys: sortKeys,
                      sortLabels: sortLabels,
                      sortOptionsMap: sortOptionsMap,
                      onDepartmentsChanged: (dept) {
                        setDialogState(() {
                          if (selectedDepartments.contains(dept)) {
                            selectedDepartments.remove(dept);
                          } else {
                            selectedDepartments.add(dept);
                          }
                        });
                      },
                      onDateChanged: (val) => setDialogState(() => selectedDate = val),
                      onStatusesChanged: (status) {
                        setDialogState(() {
                          if (selectedStatuses.contains(status)) {
                            selectedStatuses.remove(status);
                          } else {
                            selectedStatuses.add(status);
                          }
                        });
                      },
                      onSortByChanged: (val) => setDialogState(() => selectedSortBy = val),
                    ),

                    SizedBox(height: 25.sp),

                    // Buttons
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: customButton(
                            title: S.of(builderContext).Reset,
                            function: () {
                              setDialogState(() {
                                selectedDepartments.clear();
                                selectedStatuses.clear();
                                selectedDate = null;
                                selectedSortBy = null;
                              });
                            },
                            color: lightMode ? AppColors.grey : AppColors.mediumGrey,
                            radius: 8.r,
                            textStyle: StyleText.fontSize16Weight500.copyWith(color: lightMode ? AppColors.black : AppColors.white ),
                            height: 42.sp,
                          ),
                        ),
                        SizedBox(width: 15.sp),
                        Expanded(
                          child: customButton(
                            title: S.of(builderContext).Apply,
                            function: () {
                              Navigator.of(dialogContext).pop({
                                'departments': selectedDepartments,
                                'statuses': selectedStatuses,
                                'date': selectedDate,
                                'sortBy': selectedSortBy,
                              });
                            },
                            color: AppColors.primary,
                            radius: 8.r,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            height: 42.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
}

Widget _buildFormFields({
  required BuildContext context,
  required bool isMobile,
  required bool isArabic,
  required bool lightMode,
  required bool isEmployeesTab,
  required List<String> selectedDepartments,
  required DateTime? selectedDate,
  required List<String> selectedStatuses,
  required String? selectedSortBy,
  required DateTime? minDate,
  required DateTime? maxDate,
  required List<String> allDepartments,
  required List<String> statusKeys,
  required List<String> statusLabels,
  required Map<String, String> statusMap,
  required List<String> sortKeys,
  required List<String> sortLabels,
  required Map<String, String> sortOptionsMap,
  required Function(String) onDepartmentsChanged,
  required Function(DateTime?) onDateChanged,
  required Function(String) onStatusesChanged,
  required Function(String?) onSortByChanged,
}) {
  // ✅ Department Multi-Select Dropdown (BOTH TABS)
  final departmentDropdown = AppMultiSelectDropdown(
    selectedItems: selectedDepartments,
    items: allDepartments,

    textButton: selectedDepartments.isEmpty
        ? null
        : '${selectedDepartments.length} ${S.of(context).department}${selectedDepartments.length > 1 ? 's' : ''} ${S.of(context).sm_selected}',
    hintText: S.of(context).department,
    onChanged: (value) => onDepartmentsChanged(value as String),
    width: isMobile ? double.infinity : 300.sp,
    height: 38.sp,
  //  menuWidth: isMobile ? 300.sp : 280.sp,
    fillColor: lightMode ? AppColors.background : AppColors.background,
    textStyle: StyleText.fontSize12Weight400.copyWith(
      color: AppColors.secondaryText,
    ),
    textColor: AppColors.secondaryText,
    forceDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
  );

  // ✅ Date Picker Field (REQUESTED SERVICES ONLY)
  final datePickerField = _buildDatePickerField(
    context: context,
    isMobile: isMobile,
    lightMode: lightMode,
    isArabic: isArabic,
    selectedDate: selectedDate,
    minDate: minDate,
    maxDate: maxDate,
    onDateChanged: onDateChanged,
  );

  final statusDropdown = _buildBilingualMultiSelect(
    context: context,
    isMobile: isMobile,
    lightMode: lightMode,
    isArabic: isArabic,
    selectedKeys: selectedStatuses,
    itemKeys: statusKeys,
    itemLabels: statusLabels,
    labelMap: statusMap,
    hintText: S.of(context).status,
    onChanged: onStatusesChanged,
  );

  // ✅ UPDATED: Sort By Dropdown with bilingual support
  final sortByDropdown = _buildBilingualSingleSelect(
    context: context,
    isMobile: isMobile,
    lightMode: lightMode,
    isArabic: isArabic,
    selectedKey: selectedSortBy,
    itemKeys: sortKeys,
    itemLabels: sortLabels,
    labelMap: sortOptionsMap,
    // Services mobile QA p.14: the hint read "Sort" over a list of statuses
    // (Done / Breached SLA). It reads "Status", like the Requested Services
    // tab.
    hintText: S.of(context).status,
    onChanged: onSortByChanged,
  );

  // ✅ CONDITIONAL LAYOUT BASED ON TAB
  if (isEmployeesTab) {
    // EMPLOYEES TAB: Department + Sort By
    if (isMobile) {
      return Column(
        children: [
          departmentDropdown,
          SizedBox(height: 15.sp),
          sortByDropdown,
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: departmentDropdown),
          SizedBox(width: 15.sp),
          Expanded(child: sortByDropdown),
        ],
      );
    }
  } else {
    // REQUESTED SERVICES TAB: Department + Date + Status
    if (isMobile) {
      return Column(
        children: [
          departmentDropdown,
          SizedBox(height: 15.sp),
          datePickerField,
          SizedBox(height: 15.sp),
          statusDropdown,
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: departmentDropdown),
              SizedBox(width: 15.sp),
              Expanded(child: datePickerField),
            ],
          ),
          SizedBox(height: 15.sp),
          Row(
            children: [
              Expanded(child: statusDropdown),
              SizedBox(width: 15.sp),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      );
    }
  }
}

// ✅ NEW: Bilingual Multi-Select Widget
// ✅ NEW: Bilingual Multi-Select Widget
// ✅ NEW: Bilingual Multi-Select Widget
Widget _buildBilingualMultiSelect({
  required BuildContext context,
  required bool isMobile,
  required bool lightMode,
  required bool isArabic,
  required List<String> selectedKeys,
  required List<String> itemKeys,
  required List<String> itemLabels,
  required Map<String, String> labelMap,
  required String hintText,
  required Function(String) onChanged,
}) {
  // ✅ Create display text for selected items
  String? displayText;
  if (selectedKeys.isNotEmpty) {
    final translatedItems = selectedKeys.map((key) => labelMap[key] ?? key).toList();
    displayText = translatedItems.join(', ');

    // If too long, show count instead
    if (displayText.length > 50) {
      displayText = '${selectedKeys.length} ${S.of(context).sm_selected2}';
    }
  }

  return AppMultiSelectDropdown(
    selectedItems: selectedKeys,
    items: itemKeys,
    itemLabelMap: labelMap, // ✅ CRITICAL: Pass translation map
    textButton: displayText,
    hintText: hintText,
    onChanged: (value) => onChanged(value as String),
    width: isMobile ? double.infinity : 300.sp,
    height: 38.sp,
    //menuWidth: isMobile ? 300.sp : 280.sp,
    fillColor: lightMode ? AppColors.background : AppColors.background,
    textStyle: StyleText.fontSize12Weight400.copyWith(
      color: AppColors.secondaryText
    ),
    textColor: AppColors.secondaryBlack,
    forceDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
  );
}

// ✅ NEW: Bilingual Single-Select Widget
Widget _buildBilingualSingleSelect({
  required BuildContext context,
  required bool isMobile,
  required bool lightMode,
  required bool isArabic,
  required String? selectedKey,
  required List<String> itemKeys,
  required List<String> itemLabels,
  required Map<String, String> labelMap,
  required String hintText,
  required Function(String?) onChanged,
})
{
  return CustomDropdown<String>(
    key: ValueKey('dropdown_${selectedKey ?? DateTime.now().millisecondsSinceEpoch}'),
    value: selectedKey,
    items: itemKeys
        .map((key) => DropdownItem<String>(
              value: key,
              label: labelMap[key] ?? key,
            ))
        .toList(),
    onChanged: onChanged,
    fillColor: AppColors.background,
    hint: hintText,
    hintStyle: StyleText.fontSize12Weight400.copyWith(
      color: AppColors.secondaryText,
    ),
    // QA p.14: this chevron was fainter than the Department one above it.
    // Same asset, size, padding and colour as the multi-select's chevron.
    suffixIcon: _filterTrailingIcon(
        'assets/icons_assets/main_icons_assets/chevron_down.svg'),
    suffixIconPadding: EdgeInsetsDirectional.only(start: 8.w, end: 12.w),
  );
}

/// The trailing glyph every field in this dialog uses: a 20.sp box, the
/// glyph centred in it, in the multi-select chevron's colour. QA p.9 / p.25:
/// the calendar icon (15, no box, 12 from the edge) sat off the line the
/// two chevrons above and below it make.
Widget _filterTrailingIcon(String asset, {double glyph = 20}) {
  return SizedBox(
    width: 20.sp,
    height: 20.sp,
    child: Center(
      child: CustomSvgImage(
        assetPath: asset,
        width: glyph.sp,
        height: glyph.sp,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          AppColors.text.withOpacity(0.6),
          BlendMode.srcIn,
        ),
      ),
    ),
  );
}

// ✅ Updated date picker field widget using DatePicker class
Widget _buildDatePickerField({
  required BuildContext context,
  required bool isMobile,
  required bool lightMode,
  required bool isArabic,
  required DateTime? selectedDate,
  required DateTime? minDate,
  required DateTime? maxDate,
  required Function(DateTime?) onDateChanged,
}) {
  return GestureDetector(
    onTap: () async {
      final result = await DatePicker().showDatePicker(
        context,
        selectedDate != null ? [selectedDate] : [],
        selectedDate,
        CalendarDatePicker2Type.single,
        firstDate: minDate ?? DateTime(2020),
      );

      if (result != null && result.isNotEmpty && result.first != null) {
        onDateChanged(result.first);
      }
    },
    // Services mobile QA p.9 / p.25 ("same font style", icons on one line):
    // this was a hand-made box — its own padding, 15pt icon hugging the edge,
    // plain Text for the hint — so the label started left of "Department" /
    // "Status" and the calendar sat off the chevrons' line. It is now the
    // same InputDecorator the multi-select trigger (CustomMultiSelectDropdown)
    // draws: same content padding, same hint style, same 20.sp trailing box
    // with the same 8 / 12 insets.
    child: SizedBox(
      width: isMobile ? double.infinity : 300.sp,
      child: InputDecorator(
        isEmpty: selectedDate == null,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide.none,
          ),
          suffixIcon: Padding(
            padding: EdgeInsetsDirectional.only(start: 8.w, end: 12.w),
            child: _filterTrailingIcon(
              'assets/icons_assets/roles_assets/calendar.svg',
              glyph: 16,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(),
          hintText: selectedDate == null ? S.of(context).RequestDate : null,
          hintStyle: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        child: selectedDate == null
            ? null
            : Text(
                DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en')
                    .format(selectedDate),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryBlack,
                ),
              ),
      ),
    ),
  );
}
