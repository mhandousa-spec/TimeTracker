// ******************* FILE INFO *******************
// File Name: details_action_bar.dart
// Description: Search + Filter + Export action bar for Dashboard Details
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/request_statistics_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/filter_dialog.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_admin_details_export_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class DetailsActionBar extends StatelessWidget {
  final DashboardDetailsState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterApplied;
  final Function({
  String? department,
  String? status,
  DateTime? date,
  bool clearDepartment,
  bool clearStatus,
  bool clearDate,
  }) onFilterResult;
  final String locale;
  final ServiceRequestExportHelper exportHelper;

  const DetailsActionBar({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterApplied,
    required this.onFilterResult,
    required this.locale,
    required this.exportHelper,
  });

  bool get _hasActiveFilter =>
      (state.activeDepartment?.isNotEmpty == true) ||
          (state.activeStatus?.isNotEmpty == true) ||
          state.activeDate != null;

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return Row(
      children: [
        // ── Search ─────────────────────────────────────────────────────────
        AppSearchTextField(
          controller: searchController,
          onChanged: onSearchChanged,
        ),

        SizedBox(width: 10.w),

        // ── Filter ─────────────────────────────────────────────────────────
        CustomFilterIcon(
          color: _hasActiveFilter ? AppColors.primary : AppColors.card,
          borderColor: AppColors.transparent,
          svgColor: _hasActiveFilter
              ? AppColors.textButton
              : AppColors.secondaryText,
          title: S.of(context).Filter,
          // Text follows the icon: on the primary (active) fill it must be
          // textButton, or it disappears into the yellow (bug report p27).
          textStyle: StyleText.fontSize16Weight400.copyWith(
              color: _hasActiveFilter
                  ? AppColors.textButton
                  : AppColors.secondaryText),
          onTap: () async {
            final result = await ServiceRequestFilterDialog.show(
              context,
              state.filteredItems.map((item) {
                return ServicesHistoryModel.fromJson(
                  item['raw'] as Map<String, dynamic>,
                  item['docId'] as String,
                );
              }).toList(),
              currentDepartment: state.activeDepartment,
              currentStatus: state.activeStatus,
              currentDate: state.activeDate,
            );

            if (result != null) {
              onFilterResult(
                department: result['department'],
                status: result['status'],
                date: result['date'],
                clearDepartment: result['department'] == null,
                clearStatus: result['status'] == null,
                clearDate: result['date'] == null,
              );
            }
          },
        ),

        // ── Export (only on Requested Services tab) ─────────────────────────
        if (state.showRequestedServices &&
            ServicesModuleAccess.canExportRequestedServices) ...[
          SizedBox(width: 10.sp),
          GestureDetector(
            onTap: () async {
              final fileName = await exportHelper.showFileNameDialog(context);
              if (fileName != null && fileName.isNotEmpty) {
                await exportHelper.exportFilteredItemsToCSV(
                  context,
                  state.displayedItems,
                  fileName,
                  locale,
                  state.enToArDepartments,
                );
              }
            },
            child: Container(
              width: isMobile ? 38.w : 100.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: isMobile
                  ? Center(
                child: SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/export_arrow.svg',
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.textButton,
                  fit: BoxFit.scaleDown,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons_assets/main_icons_assets/export_arrow.svg',
                    width: 20.sp,
                    height: 20.sp,
                    color: AppColors.textButton,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    S.of(context).export,
                    style: StyleText.fontSize16Weight400.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
