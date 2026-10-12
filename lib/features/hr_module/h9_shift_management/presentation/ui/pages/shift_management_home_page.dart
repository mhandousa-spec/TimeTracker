// ***************************** FILE INFO ***************************** //
// File Name: shift_management_home_page.dart
// Purpose: Displays local shift-management location and branch filters.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:async';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/constants/hr_module/hr_assets.dart';
import 'package:knowticed_plus/core/helper/hr/hr_routes.dart';
import 'package:knowticed_plus/features/../core/helper/main_helper/pagination_app_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/shift_management_cubit.dart';
import '../../controller/shift_management_state.dart';
import '../../../data/models/shift_model.dart';
import '../../../../h2_employees/utils/employee_excel_exporter.dart';
import '../../../../h2_employees/utils/employee_table_value_resolver.dart';
import '../../../../h2_employees/utils/enums/employee_upload_controllers/employee_info.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../widgets/add_shift_dialog.dart';
import '../widgets/edit_shift_dialog.dart';
import '../widgets/shift_management_department_filter_dialog.dart';
import '../widgets/shift_management_employee_table.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays the initial local shift-management filters.
class ShiftManagementHomePage extends StatefulWidget {
  const ShiftManagementHomePage({super.key});

  @override
  State<ShiftManagementHomePage> createState() =>
      _ShiftManagementHomePageState();
}

class _ShiftManagementHomePageState extends State<ShiftManagementHomePage> {
  final _searchController = TextEditingController();
  final EmployeeExcelExporter _excelExporter = EmployeeExcelExporter();
  String? _departmentId;
  bool _isExporting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: BlocBuilder<ShiftManagementCubit, ShiftManagementState>(
            builder: (context, state) {
              final cubit = context.read<ShiftManagementCubit>();
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaginationAppBar(
                      screensTitles: [
                        localization.humanResources,
                        localization.shiftsManagement,
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildFilterTabs(
                      items: _locationChipItems(state),
                      selectedKey: state.selectedLocationId ??
                          (state.locations.isEmpty
                              ? ShiftManagementCubit.allKey
                              : state.locations.first.id),
                      onSelected: (key) => cubit.selectLocation(
                        key,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildFilterTabs(
                      items: _branchChipItems(localization, state, cubit),
                      selectedKey:
                          state.selectedBranchId ?? ShiftManagementCubit.allKey,
                      onSelected: (key) => cubit.selectBranch(
                        key == ShiftManagementCubit.allKey ? null : key,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _buildShiftFilters(localization, state, cubit),
                    SizedBox(height: 14.h),
                    _buildActions(localization, cubit),
                    SizedBox(height: 18.h),
                    ShiftManagementEmployeeTable(
                      rows: cubit.visibleAssignedEmployees(
                        departmentId: _departmentId,
                      ),
                      showBranch: state.selectedBranchId == null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<StatusChipItem> _locationChipItems(ShiftManagementState state) {
    return [
      ...state.locations.map(
        (location) => StatusChipItem(
          key: location.id,
          label: location.name,
          count: 0,
        ),
      ),
    ];
  }

  List<StatusChipItem> _branchChipItems(
    S localization,
    ShiftManagementState state,
    ShiftManagementCubit cubit,
  ) {
    final assignedRows = cubit.visibleAssignedEmployees(
      departmentId: _departmentId,
      ignoreBranchFilter: true,
    );
    final branchCounts = <String, int>{};
    for (final row in assignedRows) {
      branchCounts.update(row.branch.id, (count) => count + 1,
          ifAbsent: () => 1);
    }
    return [
      StatusChipItem(
        key: ShiftManagementCubit.allKey,
        label: localization.all,
        count: assignedRows.length,
      ),
      ...cubit.visibleBranches().map(
            (branch) => StatusChipItem(
              key: branch.id,
              label: branch.name,
              count: branchCounts[branch.id] ?? 0,
            ),
          ),
    ];
  }

  Widget _buildShiftFilters(
    S localization,
    ShiftManagementState state,
    ShiftManagementCubit cubit,
  ) {
    final shifts = state.shifts.where((shift) {
      final matchesLocation = state.selectedLocationId == null ||
          shift.locationId == state.selectedLocationId;
      final matchesBranch = state.selectedBranchId == null ||
          shift.branchId == state.selectedBranchId;
      return matchesLocation && matchesBranch;
    }).toList();
    final availableKeys = shifts.map((shift) => shift.id).toSet();
    final selectedKey = availableKeys.contains(state.selectedShiftKey)
        ? state.selectedShiftKey
        : ShiftManagementCubit.allKey;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ShiftTimeChip(
            label: localization.all,
            isSelected: selectedKey == ShiftManagementCubit.allKey,
            onTap: () => cubit.selectShift(null),
          ),
          ...shifts.map((shift) {
            return _ShiftTimeChip(
              label: '${localization.shiftStarts}: '
                  '${shift.toEntity().startTimeLabel} - '
                  '${shift.toEntity().endTimeLabel}',
              isSelected: selectedKey == shift.id,
              onTap: () => cubit.selectShift(shift.id),
              onEdit: () => _showEditShiftDialog(context, cubit, shift),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterTabs({
    required List<StatusChipItem> items,
    required String selectedKey,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusChipFilter(
          items: items,
          selectedKey: selectedKey,
          onSelected: onSelected,
          chipSpacing: 18.sp,
        ),
      ],
    );
  }

  Widget _buildActions(
    S localization,
    ShiftManagementCubit cubit,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = AppSearchTextField(
          controller: _searchController,
          onChanged: cubit.updateSearchQuery,
        );
        final filterButton = CustomFilterIcon(
          title: localization.filter,
          onTap: () => _showDepartmentFilter(context),
          color: AppColors.card,
          svgColor: AppColors.inverseBase,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.inverseBase,
          ),
        );
        final assignShiftButton = customButtonWithSvg(
          title: localization.assignShift,
          function: () => _openAssignShiftPage(cubit),
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
          color: AppColors.primary,
          image: HRAssets.hrAssignShift,
          widthImage: 20.sp,
          heightImage: 20.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        );
        final shiftButton = customButtonWithSvg(
          title: localization.shifts,
          function: () => _showAddShiftDialog(context, cubit),
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
          color: AppColors.primary,
          image: HRAssets.hrShiftSchedule,
          widthImage: 20.sp,
          heightImage: 20.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        );
        final editButton = customButtonWithSvg(
          title: localization.edit,
          function: () => _openEmployeeEditPage(cubit),
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
          color: AppColors.primary,
          image: AppAssets.edit,
          widthImage: 20.sp,
          heightImage: 20.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
        );
        final bottomActions = [
          customButtonWithSvg(
            title: localization.export,
            function: () => _exportAssignedEmployees(context, cubit),
            textStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            ),
            color: AppColors.primary,
            image: AppAssets.export,
            widthImage: 20.sp,
            heightImage: 20.sp,
            colorBorder: AppColors.transparent,
            svgColor: AppColors.textButton,
          ),
        ];
        final topActions = [
          filterButton,
          assignShiftButton,
          shiftButton,
        ];

        final topRow = [
          searchField,
          SizedBox(width: 16.w),
          ..._spacedWidgets(topActions, 12.w),
        ];

        final bottomRow = [
          editButton,
          const Spacer(),
          ..._spacedWidgets(bottomActions, 12.w),
        ];

        if (constraints.maxWidth < 720.w) {
          return Column(
            children: [
              Row(children: [searchField]),
              SizedBox(height: 12.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: topActions,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  editButton,
                  const Spacer(),
                  Wrap(
                    spacing: 8.w,
                    children: bottomActions,
                  ),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(children: topRow),
            SizedBox(height: 12.h),
            Row(children: bottomRow),
          ],
        );
      },
    );
  }

  /// Method Name: [_showDepartmentFilter]
  ///
  /// Purpose: Opens the department-only filter used by Shift Management.
  ///
  /// Parameters:
  /// - [context]: Provides the dialog navigator and localization scope.
  ///
  /// Returns: Completes after the filter dialog is dismissed.
  Future<void> _showDepartmentFilter(BuildContext context) async {
    final departmentCubit = Get.find<MainCoreDepartmentCubit>();
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final items = departmentCubit.departmentIds
        .map(
          (id) => DropdownItem<String>(
            value: id,
            label: departmentCubit.getDepartmentName(id, isEnglish),
          ),
        )
        .toList();

    await showDialog<void>(
      context: context,
      builder: (_) => ShiftManagementDepartmentFilterDialog(
        items: items,
        selectedDepartmentId: _departmentId,
        onApply: (value) => setState(() => _departmentId = value),
      ),
    );
  }

  /// Method Name: [_exportAssignedEmployees]
  ///
  /// Purpose: Exports the currently visible Shift Management table rows to
  /// an Excel workbook.
  ///
  /// Parameters:
  /// - [context]: Provides localized labels and dialog presentation.
  /// - [cubit]: Supplies the active Shift Management filters and rows.
  ///
  /// Returns: Completes after the workbook is saved and feedback is shown.
  Future<void> _exportAssignedEmployees(
    BuildContext context,
    ShiftManagementCubit cubit,
  ) async {
    if (_isExporting) return;

    final localization = S.of(context);
    final departmentCubit = Get.find<MainCoreDepartmentCubit>();
    final showBranch = cubit.state.selectedBranchId == null;
    final assignedRows = cubit.visibleAssignedEmployees(
      departmentId: _departmentId,
    );
    final headers = <String>[
      localization.number,
      localization.employeeId,
      localization.firstName,
      localization.lastName,
      localization.department,
      localization.jobTitle,
      if (showBranch) localization.branch,
      localization.startTime,
      localization.endTime,
    ];
    final rows = assignedRows.indexed.map((entry) {
      final index = entry.$1;
      final row = entry.$2;
      final employee = row.employee;
      return <String>[
        '${index + 1}',
        EmployeeTableValueResolver.valueFor(
          employee: employee,
          field: EmployeeInfo.id,
          departmentCubit: departmentCubit,
        ),
        EmployeeTableValueResolver.valueFor(
          employee: employee,
          field: EmployeeInfo.firstName,
          departmentCubit: departmentCubit,
        ),
        EmployeeTableValueResolver.valueFor(
          employee: employee,
          field: EmployeeInfo.lastName,
          departmentCubit: departmentCubit,
        ),
        _departmentName(employee.departmentId, departmentCubit),
        EmployeeTableValueResolver.valueFor(
          employee: employee,
          field: EmployeeInfo.englishTitle,
          departmentCubit: departmentCubit,
        ),
        if (showBranch) row.branch.name,
        row.shift.toEntity().startTimeLabel,
        row.shift.toEntity().endTimeLabel,
      ];
    }).toList(growable: false);

    setState(() => _isExporting = true);
    unawaited(showLoadingIndicator());
    var exportSucceeded = false;

    try {
      await _excelExporter.export(
        headers: headers,
        rows: rows,
        fileName: 'shift_management',
      );
      exportSucceeded = true;
    } catch (_) {
      exportSucceeded = false;
    } finally {
      hideLoadingIndicator();
      if (mounted) setState(() => _isExporting = false);
    }

    if (!context.mounted) return;
    if (exportSucceeded) {
      await CustomDialogManager.showSuccess(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/successful.json',
        title: localization.downloadSuccessTitle,
        subtitle: localization.successDownloadFile,
      );
      return;
    }
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
      title: localization.downloadFailed,
      subtitle: localization.failedToDownloadFile,
    );
  }

  /// Method Name: [_departmentName]
  ///
  /// Purpose: Resolves the employee's department name for export.
  ///
  /// Parameters:
  /// - [departmentId]: Stable employee department identifier.
  /// - [departmentCubit]: Shared department data resolver.
  ///
  /// Returns: The localized department name, or an empty value.
  String _departmentName(
    String? departmentId,
    MainCoreDepartmentCubit departmentCubit,
  ) {
    if (departmentId == null ||
        !departmentCubit.departmentIds.contains(departmentId)) {
      return '';
    }
    return departmentCubit.getDepartmentName(departmentId, null);
  }

  void _showAddShiftDialog(
    BuildContext context,
    ShiftManagementCubit cubit,
  ) {
    final state = cubit.state;
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddShiftDialog(
          initialLocationId: state.selectedLocationId,
          initialBranchId: state.selectedBranchId,
        ),
      ),
    );
  }

  /// Method Name: [_openAssignShiftPage]
  ///
  /// Purpose: Opens assignment flow and refreshes table assignments on return.
  ///
  /// Parameters:
  /// - [cubit]: Shift Management controller owning the table state.
  ///
  /// Returns: Completes after the assignment flow and refresh finish.
  Future<void> _openAssignShiftPage(ShiftManagementCubit cubit) async {
    await Navigator.of(context).pushNamed(HRRoutes.hrModuleAssignShiftPage);
    if (mounted) await cubit.loadAssignments();
  }

  /// Method Name: [_openEmployeeEditPage]
  ///
  /// Purpose: Opens a fresh employee-selection edit flow without carrying
  /// selections from the Home page.
  ///
  /// Parameters:
  /// - [cubit]: Shift Management controller supplying the current data.
  ///
  /// Returns: Completes after the selection page is closed.
  Future<void> _openEmployeeEditPage(ShiftManagementCubit cubit) async {
    await Navigator.of(context).pushNamed(
      HRRoutes.hrModuleEditEmployeesShiftPage,
      arguments: cubit,
    );
    if (mounted) await cubit.loadAssignments();
  }

  void _showEditShiftDialog(
    BuildContext context,
    ShiftManagementCubit cubit,
    ShiftModel shift,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: EditShiftDialog(shift: shift),
      ),
    );
  }

  List<Widget> _spacedWidgets(List<Widget> widgets, double spacing) {
    final spaced = <Widget>[];
    for (var index = 0; index < widgets.length; index++) {
      if (index > 0) spaced.add(SizedBox(width: spacing));
      spaced.add(widgets[index]);
    }
    return spaced;
  }
}

/// Renders one compact shift-time filter card from the reference design.
class _ShiftTimeChip extends StatelessWidget {
  const _ShiftTimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 12.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          height: 38.h,
          padding: EdgeInsetsDirectional.only(start: 12.w, end: 8.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
                  color: isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText,
                ),
              ),
              SizedBox(width: 8.w),
              if (onEdit != null) ...[
                SizedBox(width: 8.w),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(4.r),
                  child: CustomSvgImage(
                    assetPath: AppAssets.edit,
                    width: 18.sp,
                    height: 18.sp,
                    color: isSelected
                        ? AppColors.textButton
                        : AppColors.inverseBase,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
