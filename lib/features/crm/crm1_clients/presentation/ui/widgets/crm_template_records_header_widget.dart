// ****************** FILE INFO ******************
// File Name: crm_template_records_header_widget.dart
// Purpose: Shared header controls for CRM template client records views
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_clients_search_sort_bar_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmTemplateRecordsHeaderWidget extends StatelessWidget {
  final List<StatusChipItem> statusItems;
  final String selectedStatusKey;
  final ValueChanged<String> onStatusChanged;
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? selectedSortOption;
  final ValueChanged<String?>? onSortChanged;
  final VoidCallback onDashboardTap;
  final VoidCallback onBulkUploadTap;
  final VoidCallback onAddTap;
  final VoidCallback onAddViewTap;
  final VoidCallback onExportTap;
  final List<String> savedViewOptions;
  final String? selectedSavedView;
  final ValueChanged<String?> onSavedViewChanged;
  final List<String> tagOptions;
  final String? selectedTag;
  final ValueChanged<String?> onTagChanged;
  final bool isGridView;
  final VoidCallback onGridTap;
  final VoidCallback onListTap;

  const CrmTemplateRecordsHeaderWidget({
    super.key,
    required this.statusItems,
    required this.selectedStatusKey,
    required this.onStatusChanged,
    required this.searchController,
    this.onSearchChanged,
    this.selectedSortOption,
    this.onSortChanged,
    required this.onDashboardTap,
    required this.onBulkUploadTap,
    required this.onAddTap,
    required this.onAddViewTap,
    required this.onExportTap,
    required this.savedViewOptions,
    required this.selectedSavedView,
    required this.onSavedViewChanged,
    required this.tagOptions,
    required this.selectedTag,
    required this.onTagChanged,
    required this.isGridView,
    required this.onGridTap,
    required this.onListTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Dashboard button on right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customButton(
                title: S.current.crmDashboardTab,
                function: onDashboardTap,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: StatusChipFilter(
              items: statusItems,
              selectedKey: selectedStatusKey,
              onSelected: onStatusChanged,
              selectedColor: AppColors.primary,
              unselectedColor: AppColors.card,
            ),
          ),
          SizedBox(height: 14.sp),

          // Search Row: AppSearchTextField + Sort Button + Square + Add Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CrmClientsSearchSortBarWidget(
                  controller: searchController,
                  selectedSortOption: selectedSortOption,
                  onChanged: onSearchChanged,
                  onSortChanged: onSortChanged,
                  showFilterButton: false,
                ),
              ),
              SizedBox(width: 8.sp),
              customButtonWithSvg(
                title: '',
                function: onAddTap,
                textStyle: StyleText.fontSize14Weight600,
                color: AppColors.primary,
                colorBorder: AppColors.transparent,
                image: AppAssets.add,
                widthImage: 20.sp,
                heightImage: 20.sp,
                svgColor: AppColors.black,
              ),
            ],
          ),
          SizedBox(height: 14.sp),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StatusChipFilter(
                items: statusItems,
                selectedKey: selectedStatusKey,
                onSelected: onStatusChanged,
                selectedColor: AppColors.primary,
                unselectedColor: AppColors.card,
              ),
            ),
            SizedBox(width: 12.sp),
            customButtonWithSvg(
              title: S.current.crmDashboardTab,
              function: onDashboardTap,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              image: '',
              widthImage: 0,
              heightImage: 0,
            ),
          ],
        ),
        SizedBox(height: 16.sp),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CrmClientsSearchSortBarWidget(
                controller: searchController,
                selectedSortOption: selectedSortOption,
                onChanged: onSearchChanged,
                onSortChanged: onSortChanged,
                showFilterButton: false,
              ),
            ),
            SizedBox(width: 12.sp),
            customButtonWithSvg(
              title: S.current.crmBulkUpload,
              function: onBulkUploadTap,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              image: AppAssets.upload,
              widthImage: 16.sp,
              heightImage: 16.sp,
              svgColor: AppColors.black,
            ),
            SizedBox(width: 12.sp),
            customButtonWithSvg(
              title: S.current.crmAdd,
              function: onAddTap,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              image: AppAssets.add,
              widthImage: 20.sp,
              heightImage: 20.sp,
              svgColor: AppColors.black,
            ),
          ],
        ),
        SizedBox(height: 16.sp),
        Row(
          children: [
            _HeaderDropdown(
              hint: S.current.crmSavedView,
              value: selectedSavedView,
              options: savedViewOptions,
              onChanged: onSavedViewChanged,
            ),
            SizedBox(width: 12.sp),
            _HeaderDropdown(
              hint: S.current.crmTags,
              value: selectedTag,
              options: tagOptions,
              onChanged: onTagChanged,
            ),
            const Spacer(),
            customButtonWithSvg(
              title: S.current.crmAddView,
              function: onAddViewTap,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              image: AppAssets.crmAddView,
              widthImage: 20.sp,
              heightImage: 20.sp,
              svgColor: AppColors.black,
            ),
            SizedBox(width: 12.sp),
            customButtonWithSvg(
              title: S.current.crmExport,
              function: onExportTap,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              image: AppAssets.export,
              widthImage: 20.sp,
              heightImage: 20.sp,
              svgColor: AppColors.black,
            ),
            SizedBox(width: 12.sp),
            customGridButton(
              function: onGridTap,
              isSelected: isGridView,
              color: AppColors.card,
              selectedColor: AppColors.primary,
              svgColor: AppColors.black,
              selectedSvgColor: AppColors.black,
            ),
            SizedBox(width: 12.sp),
            customTableButton(
              function: onListTap,
              isSelected: !isGridView,
              color: AppColors.card,
              selectedColor: AppColors.primary,
              svgColor: AppColors.black,
              selectedSvgColor: AppColors.black,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _HeaderDropdown({
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130.sp,
      child: CustomDropdown<String>(
        hint: hint,
        value: value,
        items: options
            .map(
              (String item) => DropdownItem<String>(value: item, label: item),
            )
            .toList(),
        onChanged: (String? value) => onChanged(value),
        fillColor: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
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
