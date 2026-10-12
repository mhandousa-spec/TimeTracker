// ***************************** FILE INFO ***************************** //
// File Name: assign_shift_page.dart
// Purpose: Provides the Assign Shift employee selection flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/19-Custom_Employee_Card.dart';
import '../../../../../../core/custom/35-custom_search_widget_custom.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/6-custom_button_with_svg.dart';
import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import 'package:knowticed_plus/features/../core/helper/main_helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../controller/shift_assignment_cubit.dart';
import '../../controller/shift_assignment_state.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/shift_model.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Page for assigning one selected shift to multiple employees.
class AssignShiftPage extends StatefulWidget {
  const AssignShiftPage({super.key});

  @override
  State<AssignShiftPage> createState() => _AssignShiftPageState();
}

class _AssignShiftPageState extends State<AssignShiftPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
          child: BlocConsumer<ShiftAssignmentCubit, ShiftAssignmentState>(
            listener: _listenToState,
            builder: (context, state) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumb(localization),
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        _buildDetails(localization, state),
                        SizedBox(height: 14.h),
                        _buildEmployeeSection(localization, state),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildActions(localization, state),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(S localization) {
    return PaginationAppBar(
      screensTitles: [
        localization.humanResources,
        localization.shiftsManagement,
        localization.assignShift,
      ],
    );
  }

  Widget _buildDetails(S localization, ShiftAssignmentState state) {
    final cubit = context.read<ShiftAssignmentCubit>();
    final branches = cubit.visibleBranches();
    final shifts = cubit.visibleShifts();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _locationDropdown(localization, state)),
            SizedBox(width: 14.w),
            Expanded(child: _branchDropdown(localization, state, branches)),
            SizedBox(width: 14.w),
            Expanded(child: _shiftDropdown(localization, state, shifts)),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(width: 338.w, child: _departmentDropdown(localization, state)),
      ],
    );
  }

  Widget _locationDropdown(S localization, ShiftAssignmentState state) {
    return CustomDropdown<String>(
      label: localization.location,
      hint: localization.location,
      value: state.selectedLocationId,
      items: state.locations
          .map((location) => DropdownItem<String>(
                value: location.id,
                label: location.name,
              ))
          .toList(),
      onChanged: (value) {
        final cubit = context.read<ShiftAssignmentCubit>();
        cubit.selectLocation(
          value == state.selectedLocationId ? null : value,
        );
      },
      fillColor: AppColors.background,
    );
  }

  Widget _branchDropdown(
    S localization,
    ShiftAssignmentState state,
    List<BranchModel> branches,
  ) {
    return CustomDropdown<String>(
      label: localization.branch,
      hint: localization.branch,
      value: state.selectedBranchId,
      enabled: state.selectedLocationId != null,
      items: branches
          .map((branch) => DropdownItem<String>(
                value: branch.id,
                label: branch.name,
              ))
          .toList(),
      onChanged: (value) {
        final cubit = context.read<ShiftAssignmentCubit>();
        cubit.selectBranch(value == state.selectedBranchId ? null : value);
      },
      fillColor: AppColors.background,
      emptyWidget: const SizedBox.shrink(),
    );
  }

  Widget _shiftDropdown(
    S localization,
    ShiftAssignmentState state,
    List<ShiftModel> shifts,
  ) {
    return CustomDropdown<String>(
      label: localization.shifts,
      hint: localization.shifts,
      value: state.selectedShiftId,
      enabled: state.selectedBranchId != null,
      items: shifts
          .map((shift) => DropdownItem<String>(
                value: shift.id,
                label: '${shift.toEntity().startTimeLabel} - '
                    '${shift.toEntity().endTimeLabel}',
              ))
          .toList(),
      onChanged: (value) {
        final cubit = context.read<ShiftAssignmentCubit>();
        cubit.selectShift(value == state.selectedShiftId ? null : value);
      },
      fillColor: AppColors.background,
      emptyWidget: const SizedBox.shrink(),
    );
  }

  Widget _departmentDropdown(S localization, ShiftAssignmentState state) {
    return CustomDropdown<String>(
      label: localization.department,
      hint: localization.department,
      value: state.selectedDepartmentId,
      items: state.departments
          .map((department) => DropdownItem<String>(
                value: department.departmentID ?? '',
                label: FormatHelper.capitalize(department.departmentName ?? ''),
              ))
          .where((item) => item.value.isNotEmpty)
          .toList(),
      onChanged: (value) {
        final cubit = context.read<ShiftAssignmentCubit>();
        cubit.selectDepartment(
          value == state.selectedDepartmentId ? null : value,
        );
      },
      fillColor: AppColors.background,
    );
  }

  Widget _buildEmployeeSection(
    S localization,
    ShiftAssignmentState state,
  ) {
    final cubit = context.read<ShiftAssignmentCubit>();
    final employees = cubit.visibleEmployees();
    final visibleIds =
        employees.map((employee) => employee.id).whereType<String>();
    final allSelected = employees.isNotEmpty &&
        visibleIds.every(state.selectedEmployeeIds.contains);
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            localization.employeeInformation,
            style: StyleText.fontSize16Weight600,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: AppSearchTextField(
                // expanded: false — AppSearchTextField supplies its own Expanded;
                // nesting it inside this one throws ParentDataWidget.
                expanded: false,
                controller: _searchController,
                onChanged: cubit.updateSearchQuery,
                fillColor: AppColors.background,
              ),
            ),
            SizedBox(width: 12.w),
            customButtonWithSvg(
              title: allSelected
                  ? localization.deselectAll
                  : localization.selectAll,
              function: employees.isEmpty
                  ? () {}
                  : allSelected
                      ? cubit.clearVisibleEmployees
                      : cubit.selectAllVisibleEmployees,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.textButton,
              ),
              color: employees.isEmpty
                  ? AppColors.disabledGrey
                  : AppColors.primary,
              image: AppAssets.selectAll,
              widthImage: 18.sp,
              heightImage: 18.sp,
              colorBorder: AppColors.transparent,
              svgColor: AppColors.textButton,
            ),
          ],
        ),
        SizedBox(height: 14.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 3
                : constraints.maxWidth >= 650
                    ? 2
                    : 1;
            final itemWidth =
                (constraints.maxWidth - ((columns - 1) * 12.w)) / columns;
            return Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: employees.map((employee) {
                return SizedBox(
                  width: itemWidth,
                  child: _EmployeeSelectionCard(
                    employee: employee,
                    selected: state.selectedEmployeeIds.contains(employee.id),
                    onTap: () {
                      final id = employee.id;
                      if (id != null) cubit.toggleEmployee(id);
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions(S localization, ShiftAssignmentState state) {
    final cubit = context.read<ShiftAssignmentCubit>();
    final enabled = state.selectedLocationId != null &&
        state.selectedBranchId != null &&
        state.selectedShiftId != null &&
        state.selectedEmployeeIds.isNotEmpty &&
        !state.isSubmitting;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(
          localization.discard,
          AppColors.disabledGrey,
          () => Navigator.of(context).pop(),
        ),
        _actionButton(
          localization.submit,
          enabled ? AppColors.primary : AppColors.disabledGrey,
          enabled ? () => _confirmSubmit(cubit) : () {},
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

  Future<void> _confirmSubmit(ShiftAssignmentCubit cubit) async {
    final localization = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
      confirmTitle: localization.confirm,
      confirmSubtitle: localization.confirmAssignShift,
      confirmYesText: localization.yes,
      confirmNoText: localization.no,
      onConfirm: () async {
        unawaited(showLoadingIndicator());
        final success = await cubit.submitAssignments();
        hideLoadingIndicator();
        return success;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/successful.json',
      successTitle: localization.success,
      successSubtitle: localization.assignedEmployees,
      onSuccessComplete: () {
        if (mounted) Navigator.of(context).pop(true);
      },
    );
  }

  void _listenToState(BuildContext context, ShiftAssignmentState state) {
    if (state.errorMessage == null || state.errorMessage!.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.errorMessage!)),
    );
  }
}

/// Displays one selectable employee card in the assignment grid.
class _EmployeeSelectionCard extends StatelessWidget {
  const _EmployeeSelectionCard({
    required this.employee,
    required this.selected,
    required this.onTap,
  });

  final HrEmployeeEntity employee;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PersonChipCard(
      name: FormatHelper.capitalize(employee.getFirstAndLastName()),
      subtitle1: employee.title == null
          ? null
          : FormatHelper.capitalize(employee.title!),
      subtitle2: employee.email == null
          ? null
          : FormatHelper.capitalize(employee.email!),
      avatar: _avatarOf(employee.photo),
      backgroundColor: AppColors.background,
      isSelected: selected,
      onTap: onTap,
    );
  }

  ImageProvider? _avatarOf(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    return photo.startsWith('assets/')
        ? AssetImage(photo)
        : NetworkImage(photo);
  }
}
