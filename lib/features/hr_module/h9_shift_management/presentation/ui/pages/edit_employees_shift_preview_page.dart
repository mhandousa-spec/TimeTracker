// ***************************** FILE INFO ***************************** //
// File Name: edit_employees_shift_preview_page.dart
// Purpose: Reviews and persists employee shift modifications.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import 'dart:async';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/19-Custom_Employee_Card.dart';
import '../../../../../../core/custom/8-custom_filter_app.dart';
import '../../../../../../core/custom/35-custom_search_widget_custom.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../../../core/helper/main_helper/pagination_app_bar.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/branch_model.dart';
import '../../../data/models/location_model.dart';
import '../../../data/models/shift_model.dart';
import '../../../utils/edit_shift_selection.dart';
import '../../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';
import '../../controller/shift_management_cubit.dart';
import '../../controller/shift_management_state.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Second page of the employee shift-edit flow.
class EditEmployeesShiftPreviewPage extends StatefulWidget {
  const EditEmployeesShiftPreviewPage({required this.selection, super.key});

  final EditShiftSelection selection;

  @override
  State<EditEmployeesShiftPreviewPage> createState() =>
      _EditEmployeesShiftPreviewPageState();
}

class _EditEmployeesShiftPreviewPageState
    extends State<EditEmployeesShiftPreviewPage> {
  late final TextEditingController _searchController;
  late final Set<String> _selectedEmployeeIds;
  String? _locationId;
  String? _branchId;
  String? _shiftId;
  String? _departmentFilterId;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedEmployeeIds = {...widget.selection.employeeIds};
    _locationId = widget.selection.locationId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final state = context.watch<ShiftManagementCubit>().state;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
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
                  child: _buildContent(localization, state),
                ),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 8.h),
                Text(_errorMessage!,
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red)),
              ],
              SizedBox(height: 12.h),
              _buildActions(localization),
              SizedBox(height: 14.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(S localization, ShiftManagementState state) {
    final employees = _visibleEmployees(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localization.summary, style: StyleText.fontSize18Weight500),
        SizedBox(height: 10.h),
        _buildSummaryContainer(localization, state),
        SizedBox(height: 14.h),
        _buildEmployeeSelectionContainer(localization, state, employees),
      ],
    );
  }

  /// Method Name: _buildSummaryContainer
  ///
  /// Purpose: Renders the summary tiles in their own card below the title.
  ///
  /// Parameters:
  /// - [localization]: Provides the localized summary labels.
  /// - [state]: Supplies the selected employee and target-shift data.
  ///
  /// Returns: The standalone summary card.
  Widget _buildSummaryContainer(
    S localization,
    ShiftManagementState state,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: _buildSummary(localization, state),
    );
  }

  /// Method Name: _buildEmployeeSelectionContainer
  ///
  /// Purpose: Groups the target filters and selected employee information in
  /// the second card of the review page.
  ///
  /// Parameters:
  /// - [localization]: Provides localized field and empty-state labels.
  /// - [state]: Supplies target options and selected employees.
  /// - [employees]: Contains the employees visible under the local filter.
  ///
  /// Returns: The target-selection and employee-information card.
  Widget _buildEmployeeSelectionContainer(
    S localization,
    ShiftManagementState state,
    List<HrEmployeeEntity> employees,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTargetFilters(localization, state),
          SizedBox(height: 14.h),
          _buildDepartmentChips(state),
          SizedBox(height: 14.h),
          Text(localization.employeeInformation,
              style: StyleText.fontSize16Weight600),
          SizedBox(height: 10.h),
          Row(
            children: [
              AppSearchTextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                fillColor: AppColors.background,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildEmployeeCards(localization, employees),
        ],
      ),
    );
  }

  Widget _buildSummary(S localization, ShiftManagementState state) {
    final departmentCount = _selectedEmployees(state)
        .map((employee) => employee.departmentId)
        .whereType<String>()
        .toSet()
        .length;
    final targetShift = _findShift(state.shifts, _shiftId);
    final shiftLabel = targetShift == null
        ? localization.custom
        : '${targetShift.toEntity().startTimeLabel} - '
            '${targetShift.toEntity().endTimeLabel}';
    return Row(
      children: [
        Expanded(
          child: _summaryTile(
              localization.totalEmployees, '${_selectedEmployeeIds.length}'),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child:
              _summaryTile(localization.totalDepartments, '$departmentCount'),
        ),
        SizedBox(width: 12.w),
        Expanded(child: _summaryTile(localization.shifts, shiftLabel)),
      ],
    );
  }

  Widget _summaryTile(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(title, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryBlack)),
          SizedBox(height: 6.h),
          Text(value, style: StyleText.fontSize16Weight500),
        ],
      ),
    );
  }

  Widget _buildTargetFilters(S localization, ShiftManagementState state) {
    final branches = state.branches
        .where((branch) => branch.locationId == _locationId)
        .toList();
    final shifts = state.shifts
        .where((shift) =>
            shift.locationId == _locationId && shift.branchId == _branchId)
        .toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 700 ? 2 : 1;
        return DynamicHeightGrid(
          widgets: [
            _locationDropdown(localization, state.locations),
            _branchDropdown(localization, branches),
            _shiftDropdown(localization, shifts),
          ],
          crossAxisCount: crossAxisCount,
          horizontalSpacing: 12.w,
          verticalSpacing: 12.h,
        );
      },
    );
  }

  Widget _locationDropdown(S localization, List<LocationModel> locations) {
    return CustomDropdown<String>(
      label: localization.location,
      hint: localization.location,
      value: _locationId,
      items: locations
          .map((location) =>
              DropdownItem(value: location.id, label: location.name))
          .toList(),
      onChanged: (value) => setState(() {
        _locationId = value;
        _branchId = null;
        _shiftId = null;
      }),
      fillColor: AppColors.background,
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
        _branchId = value;
        _shiftId = null;
      }),
      fillColor: AppColors.background,
      emptyWidget: const SizedBox.shrink(),
    );
  }

  Widget _shiftDropdown(S localization, List<ShiftModel> shifts) {
    return CustomDropdown<String>(
      label: localization.shifts,
      hint: localization.shifts,
      value: _shiftId,
      enabled: shifts.isNotEmpty,
      items: shifts
          .map((shift) => DropdownItem(
                value: shift.id,
                label: '${shift.toEntity().startTimeLabel} - '
                    '${shift.toEntity().endTimeLabel}',
              ))
          .toList(),
      onChanged: (value) => setState(() => _shiftId = value),
      fillColor: AppColors.background,
      emptyWidget: const SizedBox.shrink(),
    );
  }

  Widget _buildDepartmentChips(ShiftManagementState state) {
    final counts = <String, int>{};
    for (final employee in _selectedEmployees(state)) {
      final departmentId = employee.departmentId;
      if (departmentId != null) {
        counts.update(departmentId, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    final departmentCubit = _departmentCubit;
    if (departmentCubit == null) return const SizedBox.shrink();
    final items = <StatusChipItem>[
      StatusChipItem(
        key: ShiftManagementCubit.allKey,
        label: S.of(context).all,
        count: _selectedEmployeeIds.length,
      ),
      ...counts.entries.map(
        (entry) => StatusChipItem(
          key: entry.key,
          label: FormatHelper.capitalize(
            departmentCubit.getDepartmentName(entry.key, null),
          ),
          count: entry.value,
        ),
      ),
    ];
    return StatusChipFilter(
      items: items,
      selectedKey: _departmentFilterId ?? ShiftManagementCubit.allKey,
      onSelected: (key) => setState(() {
        _departmentFilterId = key == ShiftManagementCubit.allKey ? null : key;
      }),
      chipSpacing: 18.sp,
    );
  }

  Widget _buildEmployeeCards(
    S localization,
    List<HrEmployeeEntity> employees,
  ) {
    if (employees.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 3
            : constraints.maxWidth >= 768
                ? 2
                : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 12.w)) / columns;
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: employees
              .map((employee) => SizedBox(
                    width: width,
                    child: PersonChipCard(
                      name: employee.getFirstAndLastName(),
                      subtitle1: employee.title,
                      subtitle2: _departmentName(employee.departmentId),
                      avatar: _avatarOf(employee.photo),
                      showCheckBox: false,
                      backgroundColor: AppColors.background,
                      trailing: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() {
                          _selectedEmployeeIds.remove(employee.id);
                        }),
                        child: Transform.scale(
                          scale: 0.75,
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  List<HrEmployeeEntity> _selectedEmployees(ShiftManagementState state) {
    return state.employees
        .where((employee) => _selectedEmployeeIds.contains(employee.id))
        .toList();
  }

  List<HrEmployeeEntity> _visibleEmployees(ShiftManagementState state) {
    final query = _searchController.text.trim().toLowerCase();
    return _selectedEmployees(state).where((employee) {
      final departmentMatches = _departmentFilterId == null ||
          employee.departmentId == _departmentFilterId;
      final searchable = [
        employee.id,
        employee.getFullName(),
        employee.getFullNameArabic(),
      ].whereType<String>().join(' ').toLowerCase();
      return departmentMatches && (query.isEmpty || searchable.contains(query));
    }).toList();
  }

  Widget _buildActions(S localization) {
    final enabled = _selectedEmployeeIds.isNotEmpty &&
        _locationId != null &&
        _branchId != null &&
        _shiftId != null &&
        !_isSubmitting;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _button(localization.back, AppColors.disabledGrey,
            () => Navigator.of(context).pop()),
        _button(
          localization.submit,
          enabled ? AppColors.primary : AppColors.disabledGrey,
          enabled ? _submit : () {},
        ),
      ],
    );
  }

  Widget _button(String title, Color color, VoidCallback onPressed) {
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

  Future<void> _submit() async {
    final localization = S.of(context);
    if (_selectedEmployeeIds.isEmpty) {
      setState(() => _errorMessage = localization.noEmployeesSelected);
      return;
    }
    final targetShift = _findShift(
      context.read<ShiftManagementCubit>().state.shifts,
      _shiftId,
    );
    if (_locationId == null ||
        _branchId == null ||
        _shiftId == null ||
        targetShift == null ||
        targetShift.locationId != _locationId ||
        targetShift.branchId != _branchId) {
      setState(() => _errorMessage = localization.completeRequiredFields);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    var success = false;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
      confirmTitle: localization.confirm,
      confirmSubtitle: localization.confirmEditEmployeesShift,
      confirmYesText: localization.yes,
      confirmNoText: localization.no,
      onConfirm: () async {
        unawaited(showLoadingIndicator());
        success = await context
            .read<ShiftManagementCubit>()
            .updateEmployeeAssignments(
              employeeIds: _selectedEmployeeIds,
              shiftId: _shiftId!,
            );
        hideLoadingIndicator();
        return success;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/successful.json',
      successTitle: localization.success,
      successSubtitle: localization.successfullyEditedEmployeesShifts,
      onSuccessComplete: () {
        if (!mounted) return;
        final navigator = Navigator.of(context);
        navigator.pop(true);
        navigator.pop(true);
      },
    );
    if (!mounted || success) return;
    setState(() {
      _isSubmitting = false;
      _errorMessage = localization.shiftCreationFailed;
    });
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

  ShiftModel? _findShift(List<ShiftModel> shifts, String? id) {
    for (final shift in shifts) {
      if (shift.id == id) return shift;
    }
    return null;
  }

  ImageProvider? _avatarOf(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    return photo.startsWith('assets/')
        ? AssetImage(photo)
        : NetworkImage(photo);
  }
}
