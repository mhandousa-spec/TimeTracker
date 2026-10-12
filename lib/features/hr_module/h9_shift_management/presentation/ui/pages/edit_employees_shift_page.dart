// ***************************** FILE INFO ***************************** //
// File Name: edit_employees_shift_page.dart
// Purpose: Selects employees for the temporary shift-edit flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import 'dart:async';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/35-custom_search_widget_custom.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/helper/hr/hr_routes.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../../../core/helper/main_helper/pagination_app_bar.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/branch_model.dart';
import '../../../data/models/shift_assignment_model.dart';
import '../../../data/models/shift_model.dart';
import '../../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../utils/edit_shift_selection.dart';
import '../../controller/shift_management_cubit.dart';
import '../../controller/shift_management_state.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';
import '../widgets/edit_employee_shift_dialog.dart';
import '../widgets/edit_shift_employee_card.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// First page of the employee shift-edit flow.
class EditEmployeesShiftPage extends StatefulWidget {
  const EditEmployeesShiftPage({super.key});

  @override
  State<EditEmployeesShiftPage> createState() => _EditEmployeesShiftPageState();
}

class _EditEmployeesShiftPageState extends State<EditEmployeesShiftPage> {
  late final TextEditingController _searchController;
  final Set<String> _selectedEmployeeIds = {};
  String? _locationId;
  String? _branchId;
  String? _shiftId;
  String? _departmentId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _locationId = context.read<ShiftManagementCubit>().state.selectedLocationId;
  }

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
              if (state is ShiftManagementLoading) {
                return const CircleProgressMaster();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: [
                      localization.humanResources,
                      localization.shiftsManagement,
                      localization.edit,
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilters(localization, state),
                          SizedBox(height: 14.h),
                          _buildEmployees(localization, state),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  _buildActions(localization, state),
                  SizedBox(height: 14.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(S localization, ShiftManagementState state) {
    final branches = state.branches
        .where((branch) => branch.locationId == _locationId)
        .toList();
    final shifts = state.shifts.where((shift) {
      final locationMatches = shift.locationId == _locationId;
      final branchMatches = _branchId == null || shift.branchId == _branchId;
      return locationMatches && branchMatches;
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;
            return DynamicHeightGrid(
              widgets: [_branchDropdown(localization, branches)],
              crossAxisCount: crossAxisCount,
              horizontalSpacing: 12.w,
              verticalSpacing: 12.h,
            );
          },
        ),
        SizedBox(height: 12.h),
        _buildShiftChips(localization, shifts),
      ],
    );
  }

  Widget _branchDropdown(S localization, List<BranchModel> branches) {
    return CustomDropdown<String>(
      label: localization.branch,
      hint: localization.branch,
      value: _branchId,
      enabled: branches.isNotEmpty,
      items: branches
          .map((branch) => DropdownItem(value: branch.id, label: branch.name))
          .toList(),
      onChanged: (value) => setState(() {
        _branchId = value == _branchId ? null : value;
        _shiftId = null;
      }),
      fillColor: AppColors.card,
    );
  }

  Widget _buildShiftChips(S localization, List<ShiftModel> shifts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...shifts.map(
            (shift) => _filterChip(
              label: '${shift.toEntity().startTimeLabel} - '
                  '${shift.toEntity().endTimeLabel}',
              selected: _shiftId == shift.id,
              onTap: () => setState(() {
                _shiftId = _shiftId == shift.id ? null : shift.id;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 10.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(label, style: StyleText.fontSize12Weight400),
        ),
      ),
    );
  }

  Widget _buildEmployees(S localization, ShiftManagementState state) {
    final employees = _visibleEmployees(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localization.employeeInformation,
            style: StyleText.fontSize16Weight600),
        SizedBox(height: 10.h),
        Row(
          children: [
            AppSearchTextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              fillColor: AppColors.card,
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 190.w,
              child: _departmentDropdown(localization),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (employees.isEmpty)
          const SizedBox.shrink()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1200
                  ? 3
                  : constraints.maxWidth >= 768
                      ? 2
                      : 1;
              final width =
                  (constraints.maxWidth - ((columns - 1) * 12.w)) / columns;
              return Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: employees
                    .map((employee) => SizedBox(
                          width: width,
                          child: EditShiftEmployeeCard(
                            name: FormatHelper.capitalize(
                                employee.getFirstAndLastName()),
                            subtitle1: employee.title == null
                                ? null
                                : FormatHelper.capitalize(employee.title!),
                            subtitle2: FormatHelper.capitalize(
                                _departmentName(employee.departmentId)),
                            avatar: _avatarOf(employee.photo),
                            isSelected:
                                _selectedEmployeeIds.contains(employee.id),
                            onTap: () {
                              final id = employee.id;
                              if (id == null) return;
                              setState(() {
                                _selectedEmployeeIds.contains(id)
                                    ? _selectedEmployeeIds.remove(id)
                                    : _selectedEmployeeIds.add(id);
                              });
                            },
                            onEdit: () =>
                                _showEditEmployeeDialog(employee, state),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _departmentDropdown(S localization) {
    final departments = _departmentCubit?.departmentModels ?? const [];
    return CustomDropdown<String>(
      hint: localization.department,
      value: _departmentId,
      items: departments
          .map(
            (department) => DropdownItem<String>(
              value: department.departmentID ?? '',
              label: FormatHelper.capitalize(department.departmentName ?? ''),
            ),
          )
          .where((item) => item.value.isNotEmpty && item.label.isNotEmpty)
          .toList(),
      onChanged: (value) => setState(
        () => _departmentId = value == _departmentId ? null : value,
      ),
      fillColor: AppColors.card,
      emptyWidget: const SizedBox.shrink(),
    );
  }

  List<HrEmployeeEntity> _visibleEmployees(ShiftManagementState state) {
    final assignments = {
      for (final assignment in state.assignments)
        assignment.employeeId: assignment,
    };
    final shifts = {for (final shift in state.shifts) shift.id: shift};
    final query = _searchController.text.trim().toLowerCase();
    return state.employees.where((employee) {
      final assignment = employee.id == null ? null : assignments[employee.id];
      final shift = assignment == null ? null : shifts[assignment.shiftId];
      final locationMatches = _locationId != null &&
          shift != null &&
          shift.locationId == _locationId;
      final branchMatches = _branchId == null || shift?.branchId == _branchId;
      final shiftMatches = _shiftId == null || shift?.id == _shiftId;
      final departmentMatches =
          _departmentId == null || employee.departmentId == _departmentId;
      final searchable = [
        employee.id,
        employee.getFullName(),
        employee.getFullNameArabic(),
      ].whereType<String>().join(' ').toLowerCase();
      return locationMatches &&
          branchMatches &&
          shiftMatches &&
          departmentMatches &&
          (query.isEmpty || searchable.contains(query));
    }).toList();
  }

  Widget _buildActions(S localization, ShiftManagementState state) {
    final enabled = _selectedEmployeeIds.isNotEmpty && _locationId != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _actionButton(
          localization.next,
          enabled ? AppColors.primary : AppColors.disabledGrey,
          enabled ? _goNext : () {},
        ),
      ],
    );
  }

  Widget _actionButton(String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 155.w,
      child: customButton(
        title: title,
        function: onPressed,
        textStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.textButton,
        ),
        color: color,
        borderColor: AppColors.transparent,
      ),
    );
  }

  /// Method Name: _showEditEmployeeDialog
  ///
  /// Purpose: Opens the single-employee shift editor with the employee's
  /// current assignment prefilled.
  ///
  /// Parameters:
  /// - [employee]: The assigned employee whose shift will be edited.
  /// - [state]: Provides assignment and shift definitions.
  ///
  /// Returns: Completes after the dialog is dismissed.
  Future<void> _showEditEmployeeDialog(
    HrEmployeeEntity employee,
    ShiftManagementState state,
  ) async {
    final employeeId = employee.id;
    if (employeeId == null) return;
    final assignment = _assignmentFor(state, employeeId);
    final currentShift = assignment == null
        ? null
        : _findShift(state.shifts, assignment.shiftId);
    if (currentShift == null) return;

    await showDialog<bool>(
      context: context,
      builder: (_) => EditEmployeeShiftDialog(
        employee: employee,
        departmentName: _departmentName(employee.departmentId),
        locations: state.locations,
        branches: state.branches,
        shifts: state.shifts,
        currentShift: currentShift,
        onSave: (shiftId) => _confirmSingleEmployeeEdit(employeeId, shiftId),
      ),
    );
  }

  /// Method Name: _confirmSingleEmployeeEdit
  ///
  /// Purpose: Confirms and persists one employee's new shift assignment.
  ///
  /// Parameters:
  /// - [employeeId]: Stable employee assignment document ID.
  /// - [shiftId]: The selected target shift ID.
  ///
  /// Returns: True only after the assignment is successfully persisted.
  Future<bool> _confirmSingleEmployeeEdit(
    String employeeId,
    String shiftId,
  ) async {
    final localization = S.of(context);
    var success = false;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
      confirmTitle: localization.confirm,
      confirmSubtitle: localization.confirmEditEmployeeShift,
      confirmYesText: localization.yes,
      confirmNoText: localization.no,
      onConfirm: () async {
        unawaited(showLoadingIndicator());
        success = await context
            .read<ShiftManagementCubit>()
            .updateEmployeeAssignments(
          employeeIds: [employeeId],
          shiftId: shiftId,
        );
        hideLoadingIndicator();
        return success;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/successful.json',
      successTitle: localization.success,
      successSubtitle: localization.successfullyEditedEmployeeShift,
    );
    return success;
  }

  ShiftAssignmentModel? _assignmentFor(
    ShiftManagementState state,
    String employeeId,
  ) {
    for (final assignment in state.assignments) {
      if (assignment.employeeId == employeeId) return assignment;
    }
    return null;
  }

  ShiftModel? _findShift(List<ShiftModel> shifts, String shiftId) {
    for (final shift in shifts) {
      if (shift.id == shiftId) return shift;
    }
    return null;
  }

  void _goNext() {
    Navigator.of(context).pushNamed(
      HRRoutes.hrModuleEditEmployeesShiftPreviewPage,
      arguments: EditShiftSelection(
        cubit: context.read<ShiftManagementCubit>(),
        employeeIds: Set.unmodifiable(_selectedEmployeeIds),
        locationId: _locationId!,
        branchId: _branchId,
        shiftId: _shiftId,
      ),
    );
  }

  String _departmentName(String? departmentId) {
    if (departmentId == null) return '';
    final cubit = _departmentCubit;
    if (cubit == null) return '';
    if (!cubit.departmentIds.contains(departmentId)) return '';
    return FormatHelper.capitalize(cubit.getDepartmentName(departmentId, null));
  }

  /// Method Name: _departmentCubit
  ///
  /// Purpose: Reads the shared department controller when it is registered
  /// without making the edit route depend on its registration order.
  ///
  /// Returns: The registered department controller, or null when unavailable.
  MainCoreDepartmentCubit? get _departmentCubit {
    if (!Get.isRegistered<MainCoreDepartmentCubit>()) return null;
    return Get.find<MainCoreDepartmentCubit>();
  }

  ImageProvider? _avatarOf(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    return photo.startsWith('assets/')
        ? AssetImage(photo)
        : NetworkImage(photo);
  }
}
