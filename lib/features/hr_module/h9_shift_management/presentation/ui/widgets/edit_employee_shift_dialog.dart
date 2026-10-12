// ***************************** FILE INFO ***************************** //
// File Name: edit_employee_shift_dialog.dart
// Purpose: Edits one employee's existing shift assignment.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/location_model.dart';
import '../../../data/models/shift_model.dart';
import 'edit_employee_details_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays the employee information and editable shift target fields.
class EditEmployeeShiftDialog extends StatefulWidget {
  const EditEmployeeShiftDialog({
    required this.employee,
    required this.departmentName,
    required this.locations,
    required this.branches,
    required this.shifts,
    required this.currentShift,
    required this.onSave,
    super.key,
  });

  final HrEmployeeEntity employee;
  final String departmentName;
  final List<LocationModel> locations;
  final List<BranchModel> branches;
  final List<ShiftModel> shifts;
  final ShiftModel currentShift;
  final Future<bool> Function(String shiftId) onSave;

  @override
  State<EditEmployeeShiftDialog> createState() =>
      _EditEmployeeShiftDialogState();
}

class _EditEmployeeShiftDialogState extends State<EditEmployeeShiftDialog> {
  late String? _locationId;
  late String? _branchId;
  late String? _shiftId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _locationId = widget.currentShift.locationId;
    _branchId = widget.currentShift.branchId;
    _shiftId = widget.currentShift.id;
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final branches = widget.branches
        .where((branch) => branch.locationId == _locationId)
        .toList();
    final shifts = widget.shifts
        .where((shift) =>
            shift.locationId == _locationId && shift.branchId == _branchId)
        .toList();
    final canSave = _locationId != null &&
        _branchId != null &&
        _shiftId != null &&
        _shiftId != widget.currentShift.id &&
        !_isSaving;

    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 900.w, maxHeight: 780.h),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitle(localization),
              SizedBox(height: 18.h),
              _buildEmployeeInformation(),
              SizedBox(height: 18.h),
              DynamicHeightGrid(
                widgets: [
                  _locationDropdown(localization),
                  _branchDropdown(localization, branches),
                  _shiftDropdown(localization, shifts),
                ],
                crossAxisCount: 2,
                horizontalSpacing: 14.w,
                verticalSpacing: 14.h,
              ),
              SizedBox(height: 22.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dialogButton(
                    localization.discard,
                    AppColors.disabledGrey,
                    () => Navigator.of(context).pop(),
                  ),
                  _dialogButton(
                    localization.confirm,
                    canSave ? AppColors.primary : AppColors.disabledGrey,
                    canSave ? _save : () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Method Name: _buildTitle
  ///
  /// Purpose: Renders the localized dialog heading.
  ///
  /// Parameters:
  /// - [localization]: Provides the heading text.
  ///
  /// Returns: The dialog title row.
  Widget _buildTitle(S localization) {
    return Row(
      children: [
        Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.groups_outlined,
            size: 24.r,
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          localization.editingEmployeeDetails,
          style: StyleText.fontSize20Weight500,
        ),
      ],
    );
  }

  /// Method Name: _buildEmployeeInformation
  ///
  /// Purpose: Shows the employee identity information without allowing edits.
  ///
  /// Returns: The employee information card.
  Widget _buildEmployeeInformation() {
    return EditEmployeeDetailsHeader(
      employee: widget.employee,
      departmentName: widget.departmentName,
    );
  }

  Widget _locationDropdown(S localization) {
    return CustomDropdown<String>(
      label: localization.location,
      hint: localization.location,
      value: _locationId,
      items: widget.locations
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

  Widget _dialogButton(String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 220.w,
      child: customButton(
        title: title,
        function: onPressed,
        color: color,
        borderColor: AppColors.transparent,
        textStyle: StyleText.fontSize15Weight400.copyWith(
          color: AppColors.textButton,
        ),
      ),
    );
  }

  Future<void> _save() async {
    final shiftId = _shiftId;
    if (shiftId == null) return;
    setState(() => _isSaving = true);
    final saved = await widget.onSave(shiftId);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _isSaving = false);
  }
}
