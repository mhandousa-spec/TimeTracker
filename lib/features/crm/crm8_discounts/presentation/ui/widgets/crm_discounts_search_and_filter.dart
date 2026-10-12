// ****************** FILE INFO ******************
// File Name: crm_discounts_search_and_filter.dart
// Purpose: CRM discounts toolbar adapter using the shared search, filter, and sort bar
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmDiscountsSearchAndFilter extends StatelessWidget {
  const CrmDiscountsSearchAndFilter({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.onAddTap,
    this.onSearchChanged,
    this.onStatusChanged,
    this.selectedSort,
    this.onSortChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final String selectedStatus;
  final ValueChanged<String>? onStatusChanged;
  final String? selectedSort;
  final ValueChanged<String?>? onSortChanged;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return CustomSearchFilterSortBar<String, String>(
      searchController: searchController,
      onSearchChanged: onSearchChanged,
      searchHint: S.current.crmSearch,
      showFilter: true,
      selectedFilter: selectedStatus,
      isFilterActive: selectedStatus.isNotEmpty && selectedStatus != 'All',
      filterTitle: S.current.crmFilter,
      filterItems: const <String>['All', 'Active', 'Inactive'],
      filterLabelBuilder: (String value) => switch (value) {
        'All' => S.current.crmAll,
        'Active' => S.current.crmStatusActive,
        _ => S.current.crmStatusInactive,
      },
      onFilterChanged: (String? value) {
        if (value != null) onStatusChanged?.call(value);
      },
      showSort: true,
      selectedSort: selectedSort,
      sortTitle: S.current.crmSort,
      sortItems: const <String>[
        'newest',
        'oldest',
        'a_z',
        'z_a',
        'high_low',
        'low_high',
      ],
      sortLabelBuilder: (String value) => switch (value) {
        'newest' => S.current.crmSortNewest,
        'oldest' => S.current.crmSortOldest,
        'a_z' => S.current.crmSortNameAZ,
        'z_a' => S.current.crmSortNameZA,
        'high_low' => '${S.current.crmValue}: High to Low',
        _ => '${S.current.crmValue}: Low to High',
      },
      onSortChanged: onSortChanged,
      trailingActionsBuilder: (BuildContext context, bool isPhone) => <Widget>[
        customButtonWithSvg(
          title: isPhone ? '' : S.current.crmAdd,
          function: onAddTap,
          textStyle: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.black,
          ),
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: AppAssets.crmPlusBold,
          svgColor: AppColors.black,
          widthImage: 16.sp,
          heightImage: 16.sp,
        ),
      ],
    );
  }
}
