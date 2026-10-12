// ****************** FILE INFO ******************
// File Name: crm_deals_search_bar.dart
// Purpose: CRM deals toolbar adapter using the shared search, filter, and sort bar
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

class CrmDealsSearchBar extends StatelessWidget {
  const CrmDealsSearchBar({
    super.key,
    required this.searchController,
    required this.onAddTap,
    this.onSearchChanged,
    this.selectedStatus,
    this.onStatusChanged,
    this.selectedSort,
    this.onSortChanged,
    this.addButtonTitle = '',
  });

  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? selectedStatus;
  final ValueChanged<String>? onStatusChanged;
  final String? selectedSort;
  final ValueChanged<String?>? onSortChanged;
  final VoidCallback onAddTap;
  final String addButtonTitle;

  @override
  Widget build(BuildContext context) {
    return CustomSearchFilterSortBar<String, String>(
      searchController: searchController,
      onSearchChanged: onSearchChanged,
      searchHint: S.current.crmSearch,
      showFilter: true,
      selectedFilter: selectedStatus,
      isFilterActive: selectedStatus != null && selectedStatus != 'All',
      filterTitle: S.current.crmFilter,
      filterItems: const <String>['All', 'Active', 'Inactive'],
      filterLabelBuilder: (String value) => switch (value) {
        'All' => S.current.crmAll,
        'Active' => S.current.crmActive,
        _ => S.current.crmInactive,
      },
      onFilterChanged: (String? value) {
        if (value != null) onStatusChanged?.call(value);
      },
      showSort: true,
      selectedSort: selectedSort,
      sortTitle: S.current.crmSort,
      sortItems: const <String>[
        'name_asc',
        'name_desc',
        'date_desc',
        'date_asc',
      ],
      sortLabelBuilder: (String value) => switch (value) {
        'name_asc' => S.current.crmSortNameAZ,
        'name_desc' => S.current.crmSortNameZA,
        'date_desc' => S.current.crmSortNewest,
        _ => S.current.crmSortOldest,
      },
      onSortChanged: onSortChanged,
      trailingActionsBuilder: (BuildContext context, bool isPhone) => <Widget>[
        customButtonWithSvg(
          title: isPhone
              ? ''
              : (addButtonTitle.isEmpty ? S.current.crmAdd : addButtonTitle),
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
