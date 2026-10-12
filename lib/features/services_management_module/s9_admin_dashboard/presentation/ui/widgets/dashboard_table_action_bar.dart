// ******************* FILE INFO *******************
// File Name: dashboard_table_action_bar.dart
// Description: Search, Filter, and Export action bar for the dashboard table
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/admin_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/export.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_admin_export_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/filter_table.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/dashboard_table_section.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';



/// Signature for [DashboardTableActionBar.onChanged].
typedef DashboardTableFiltersChanged = void Function(
  String searchQuery,
  List<String> departments,
  List<String> statuses,
  DateTime? date,
);

class DashboardTableActionBar extends StatefulWidget {
  final DashboardAdminState state;

  /// FIX 25/9/2026 (bug report p7/p25 "Filter not work"): the search text and
  /// the filter dialog result only lived in this widget's State — the table
  /// under it was always built with empty filters. Every change is now
  /// reported here so the parent can pass it to the table.
  final DashboardTableFiltersChanged? onChanged;

  const DashboardTableActionBar({
    super.key,
    required this.state,
    this.onChanged,
  });

  @override
  State<DashboardTableActionBar> createState() =>
      _DashboardTableActionBarState();
}

class _DashboardTableActionBarState extends State<DashboardTableActionBar> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _activeDepartments = [];
  List<String> _activeStatuses = [];
  DateTime? _activeDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged?.call(
        _searchController.text.trim(),
        _activeDepartments,
        _activeStatuses,
        _activeDate,
      );

  bool get _hasActiveFilters =>
      _activeDepartments.isNotEmpty ||
          _activeStatuses.isNotEmpty ||
          _activeDate != null;

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return Container(
      margin: EdgeInsets.only(bottom: 15.sp),
      child: Row(
        children: [
          // ── Search ──────────────────────────────────────────────────────
          AppSearchTextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {});
              _notify();
            },
          ),
          SizedBox(width: 10.sp),

          // ── Filter ──────────────────────────────────────────────────────
          CustomFilterIcon(
            color: _hasActiveFilters ? AppColors.primary : AppColors.card,
            borderColor: AppColors.transparent,
            svgColor: _hasActiveFilters
                ? AppColors.textButton
                : (lightMode ? AppColors.secondaryText : AppColors.grey),
            title: S.of(context).Filter,
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: _hasActiveFilters
                  ? AppColors.textButton
                  : (lightMode ? AppColors.secondaryText : AppColors.grey),
            ),
            onTap: () async {
              final result = await TableFilterDialog.show(
                context,
                activeDepartments: _activeDepartments,
                activeStatuses: _activeStatuses,
                activeDate: _activeDate,
              );
              if (result != null) {
                setState(() {
                  _activeDepartments =
                  List<String>.from(result['departments'] ?? []);
                  _activeStatuses =
                  List<String>.from(result['statuses'] ?? []);
                  _activeDate = result['date'];
                });
                _notify();
              }
            },
          ),
          // ── Export ──────────────────────────────────────────────────────
          if (ServicesModuleAccess.canExportRequestedServices) ...[
          SizedBox(width: 10.sp),

          GestureDetector(
            onTap: () async {
              final fileName = await ExportFileDialog.show(context);
              if (fileName != null && fileName.isNotEmpty) {
                await AdminExportService.exportRequestsToCSV(
                  context: context,
                  fileName: fileName,
                  displayedItems: widget.state.displayedItems,
                  selectStatus: widget.state.selectStatus,
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
              child: !isMobile
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons_assets/main_icons_assets/export_arrow.svg",
                    width: 20.sp,
                    height: 20.sp,
                    color: AppColors.textButton,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    S.of(context).export,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ],
              )
                  : Center(
                child: SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/export_arrow.svg",
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.textButton,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
          ],
        ],
      ),
    );
  }
}

/// Action bar + requests table wired together, so search and the Filter
/// dialog actually filter the table (bug report p7/p25).
class DashboardFilterableRequestsTable extends StatefulWidget {
  final DashboardAdminState state;
  final bool isMobile;

  /// When false only the action bar is drawn (the Statistics tab keeps the
  /// bar but shows its own content below it).
  final bool showTable;

  const DashboardFilterableRequestsTable({
    super.key,
    required this.state,
    required this.isMobile,
    this.showTable = true,
  });

  @override
  State<DashboardFilterableRequestsTable> createState() =>
      _DashboardFilterableRequestsTableState();
}

class _DashboardFilterableRequestsTableState
    extends State<DashboardFilterableRequestsTable> {
  String _search = '';
  List<String> _departments = const [];
  List<String> _statuses = const [];
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardTableActionBar(
          state: widget.state,
          onChanged: (search, departments, statuses, date) => setState(() {
            _search = search;
            _departments = List<String>.from(departments);
            _statuses = List<String>.from(statuses);
            _date = date;
          }),
        ),
        if (widget.showTable)
          DashboardTableSection(
            selectStatus: widget.state.selectStatus,
            searchQuery: _search,
            activeDepartments: _departments,
            activeStatuses: _statuses,
            activeDate: _date,
            isMobile: widget.isMobile,
            displayedItems: widget.state.displayedItems,
            isLoadingRequests: widget.state.isLoadingRequests,
          ),
      ],
    );
  }
}
