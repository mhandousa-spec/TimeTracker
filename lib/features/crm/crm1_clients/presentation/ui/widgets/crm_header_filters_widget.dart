// ****************** FILE INFO ******************
// File Name: crm_header_filters_widget.dart
// Purpose: Dashboard tabs and externally controlled filters for CRM clients
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/4-custom_dropdwon_range_calander.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_dashboard_view_data.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmHeaderFiltersWidget extends StatelessWidget {
  final int selectedTab;
  final List<CrmDashboardOption> cityOptions;
  final List<CrmDashboardOption> countryOptions;
  final List<CrmDashboardOption> statusOptions;
  final List<CrmDashboardOption> clientTypeOptions;
  final String selectedCity;
  final String selectedCountry;
  final String selectedStatus;
  final String selectedClientTypeId;
  final DateTime? calendarStartDate;
  final DateTime? calendarEndDate;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onClientTypeChanged;
  final void Function(DateTime? start, DateTime? end) onCalendarChanged;

  const CrmHeaderFiltersWidget({
    super.key,
    required this.selectedTab,
    required this.cityOptions,
    required this.countryOptions,
    required this.statusOptions,
    required this.clientTypeOptions,
    required this.selectedCity,
    required this.selectedCountry,
    required this.selectedStatus,
    required this.selectedClientTypeId,
    required this.calendarStartDate,
    required this.calendarEndDate,
    required this.onTabChanged,
    required this.onCityChanged,
    required this.onCountryChanged,
    required this.onStatusChanged,
    required this.onClientTypeChanged,
    required this.onCalendarChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomSegmentedTabs(
          tabs: <String>[S.current.crmDashboardTab, S.current.crmSectionsTab],
          selectedIndex: selectedTab,
          onTabSelected: onTabChanged,
          containerColor: AppColors.card,
          selectedColor: AppColors.primary,
          unselectedColor: AppColors.card,
          selectedTextColor: AppColors.white,
          unselectedTextColor: AppColors.secondaryBlack,
          borderRadius: 8.sp,
          spacing: 8.sp,
          tabHorizontalPadding: 18.sp,
          tabVerticalPadding: 8.sp,
        ),
        if (selectedTab == 0) ...<Widget>[
          SizedBox(height: 16.sp),
          if (isMobile)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  _DashboardFilterDropdown(
                    width: 112.sp,
                    hint: S.current.crmCity,
                    value: selectedCity.isEmpty ? null : selectedCity,
                    options: cityOptions,
                    onChanged: onCityChanged,
                  ),
                  SizedBox(width: 8.sp),
                  _DashboardFilterDropdown(
                    width: 112.sp,
                    hint: S.current.crmCountry,
                    value: selectedCountry.isEmpty ? null : selectedCountry,
                    options: countryOptions,
                    onChanged: onCountryChanged,
                  ),
                  SizedBox(width: 8.sp),
                  _DashboardFilterDropdown(
                    width: 112.sp,
                    hint: S.current.crmStatus,
                    value: selectedStatus.isEmpty ? null : selectedStatus,
                    options: statusOptions,
                    onChanged: onStatusChanged,
                  ),
                  SizedBox(width: 8.sp),
                  _DashboardFilterDropdown(
                    width: 128.sp,
                    hint: S.current.crmClientType,
                    value: selectedClientTypeId.isEmpty
                        ? null
                        : selectedClientTypeId,
                    options: clientTypeOptions,
                    onChanged: onClientTypeChanged,
                  ),
                  SizedBox(width: 8.sp),
                  SizedBox(
                    width: 150.sp,
                    child: CustomDropdownRangeCalendar(
                      startDate: calendarStartDate,
                      endDate: calendarEndDate,
                      hint: S.current.calendar,
                      fillColor: AppColors.card,
                      borderRadius: BorderRadius.circular(10.sp),
                      hintStyle:
                          StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
                        color: AppColors.secondaryBlack,
                      ),
                      valueStyle:
                          StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.black,
                      ),
                      onChanged: onCalendarChanged,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8.sp,
              runSpacing: 8.sp,
              alignment: WrapAlignment.end,
              children: <Widget>[
                _DashboardFilterDropdown(
                  width: 112.sp,
                  hint: S.current.crmCity,
                  value: selectedCity.isEmpty ? null : selectedCity,
                  options: cityOptions,
                  onChanged: onCityChanged,
                ),
                _DashboardFilterDropdown(
                  width: 112.sp,
                  hint: S.current.crmCountry,
                  value: selectedCountry.isEmpty ? null : selectedCountry,
                  options: countryOptions,
                  onChanged: onCountryChanged,
                ),
                _DashboardFilterDropdown(
                  width: 112.sp,
                  hint: S.current.crmStatus,
                  value: selectedStatus.isEmpty ? null : selectedStatus,
                  options: statusOptions,
                  onChanged: onStatusChanged,
                ),
                _DashboardFilterDropdown(
                  width: 128.sp,
                  hint: S.current.crmClientType,
                  value: selectedClientTypeId.isEmpty
                      ? null
                      : selectedClientTypeId,
                  options: clientTypeOptions,
                  onChanged: onClientTypeChanged,
                ),
                SizedBox(
                  width: 150.sp,
                  child: CustomDropdownRangeCalendar(
                    startDate: calendarStartDate,
                    endDate: calendarEndDate,
                    hint: S.current.calendar,
                    fillColor: AppColors.card,
                    borderRadius: BorderRadius.circular(10.sp),
                    hintStyle:
                        StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
                      color: AppColors.secondaryBlack,
                    ),
                    valueStyle: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.black,
                    ),
                    onChanged: onCalendarChanged,
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}

class _DashboardFilterDropdown extends StatelessWidget {
  final double width;
  final String hint;
  final String? value;
  final List<CrmDashboardOption> options;
  final ValueChanged<String?> onChanged;

  const _DashboardFilterDropdown({
    required this.width,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomDropdown<String>(
        hint: hint,
        value: value,
        items: options
            .map(
              (CrmDashboardOption option) => DropdownItem<String>(
                value: option.value.isEmpty ? option.label : option.value,
                label: option.label,
              ),
            )
            .toList(),
        onChanged: (String? selectedValue) {
          final CrmDashboardOption? option = options
              .cast<CrmDashboardOption?>()
              .firstWhere(
                (CrmDashboardOption? item) =>
                    (item?.value.isEmpty == true ? item?.label : item?.value) ==
                    selectedValue,
                orElse: () => null,
              );
          if (option?.value.isEmpty == true) {
            onChanged(null);
            return;
          }
          onChanged(selectedValue);
        },
        fillColor: AppColors.card,
        borderRadius: BorderRadius.circular(10.sp),
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
          color: AppColors.secondaryBlack,
        ),
        valueStyle: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.black,
        ),
      ),
    );
  }
}
