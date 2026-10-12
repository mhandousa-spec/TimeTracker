// ****************** FILE INFO ******************
// File Name: crm_deals_toolbar.dart
// Purpose: Primary search/filter/sort/+Add toolbar using shared CustomSearchFilterSortBar and secondary view switchers
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_view_mode_toggle_bar.dart';
import 'crm_deals_filter_dialog.dart';

class CrmDealsToolbar extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String currentSort;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onAddDeal;
  final VoidCallback onExport;
  final VoidCallback onAddView;
  final bool isGridView;
  final ValueChanged<bool> onViewModeChanged;
  final String? activeStage;
  final String? activeCategory;
  final double? activeValueFrom;
  final double? activeValueTo;
  final DateTime? activeStartDate;
  final DateTime? activeCloseDate;
  final String? activeEmployee;
  final void Function({
    String? stage,
    String? category,
    double? expectedValueFrom,
    double? expectedValueTo,
    DateTime? startDate,
    DateTime? closeDate,
    String? assignedEmployee,
  }) onApplyFilter;

  const CrmDealsToolbar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.currentSort,
    required this.onSortChanged,
    required this.onAddDeal,
    required this.onExport,
    required this.onAddView,
    required this.isGridView,
    required this.onViewModeChanged,
    this.activeStage,
    this.activeCategory,
    this.activeValueFrom,
    this.activeValueTo,
    this.activeStartDate,
    this.activeCloseDate,
    this.activeEmployee,
    required this.onApplyFilter,
  });

  @override
  State<CrmDealsToolbar> createState() => _CrmDealsToolbarState();
}

class _CrmDealsToolbarState extends State<CrmDealsToolbar> {
  String _savedView = 'Saved View';

  bool get _hasActiveFilters =>
      widget.activeStage != null ||
      widget.activeCategory != null ||
      widget.activeValueFrom != null ||
      widget.activeValueTo != null ||
      widget.activeStartDate != null ||
      widget.activeCloseDate != null ||
      widget.activeEmployee != null;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: <Widget>[
        // 1. Primary Shared CRM Search + Filter + Sort Bar
        CustomSearchFilterSortBar<String, String>(
          searchController: widget.searchController,
          onSearchChanged: widget.onSearchChanged,
          searchHint: FormatHelper.localizedString(
            englishName: 'Search',
            arabicName: 'بحث',
          ),
          showFilter: true,
          onFilterTap: () => CrmDealsFilterDialog.show(
            context,
            initialStage: widget.activeStage,
            initialCategory: widget.activeCategory,
            initialValueFrom: widget.activeValueFrom,
            initialValueTo: widget.activeValueTo,
            initialStartDate: widget.activeStartDate,
            initialCloseDate: widget.activeCloseDate,
            initialEmployee: widget.activeEmployee,
            onApply: widget.onApplyFilter,
          ),
          isFilterActive: _hasActiveFilters,
          filterTitle: FormatHelper.localizedString(
            englishName: 'Filter',
            arabicName: 'تصفية',
          ),
          showSort: true,
          sortItems: const <String>['newest', 'oldest'],
          selectedSort: widget.currentSort,
          sortLabelBuilder: (String item) => item == 'oldest'
              ? FormatHelper.localizedString(
                  englishName: 'Oldest',
                  arabicName: 'الأقدم',
                )
              : FormatHelper.localizedString(
                  englishName: 'Newest',
                  arabicName: 'الأحدث',
                ),
          onSortChanged: (String? val) {
            if (val != null) widget.onSortChanged(val);
          },
          sortTitle: FormatHelper.localizedString(
            englishName: 'Sort',
            arabicName: 'ترتيب',
          ),
          trailingChildren: <Widget>[
            customButtonWithSvg(
              title: FormatHelper.localizedString(
                englishName: 'Add',
                arabicName: 'إضافة',
              ),
              image: AppAssets.add,
              widthImage: 16.sp,
              heightImage: 16.sp,
              colorBorder: Colors.transparent,
              svgColor: AppColors.text,
              color: AppColors.primary,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.bold,
              ),
              function: widget.onAddDeal,
            ),
          ],
        ),

        SizedBox(height: 16.sp),

        // 2. Secondary Toolbar: Saved View & Add View (in Table mode) + Export + Grid/Table switch
        CrmViewModeToggleBar(
          isGridView: widget.isGridView,
          onViewModeChanged: widget.onViewModeChanged,
          unselectedColor: AppColors.white,
          showExport: true,
          onExport: widget.onExport,
          leadingChildren: <Widget>[
            if (!widget.isGridView && !isMobile) ...<Widget>[
              SizedBox(
                width: 150.sp,
                child: CustomDropdown<String>(
                  hint: 'Saved View',
                  value: _savedView,
                  items: const <String>[
                    'Saved View',
                    'Default View',
                    'Active Deals',
                  ]
                      .map((s) => DropdownItem<String>(value: s, label: s))
                      .toList(),
                  fillColor: AppColors.card,
                  onChanged: (val) => setState(() => _savedView = val),
                ),
              ),
              SizedBox(width: 12.sp),
              customButtonWithSvg(
                title: FormatHelper.localizedString(
                  englishName: 'Add View',
                  arabicName: 'إضافة عرض',
                ),
                image: AppAssets.crmAddView,
                widthImage: 16.sp,
                heightImage: 16.sp,
                colorBorder: Colors.transparent,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                function: widget.onAddView,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
