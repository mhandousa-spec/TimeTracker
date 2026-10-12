// ***************************** FILE INFO ***************************** //
// File Name: add_shift_dialog.dart
// Purpose: Provides the Add Shift form dialog.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/2-custom_textfield.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../data/models/shift_model.dart';
import '../../../domain/entity/shift_entity.dart';
import '../../../presentation/controller/shift_management_cubit.dart';
import '../../../utils/shift_validator.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Dialog for creating a recurring shift.
class AddShiftDialog extends StatefulWidget {
  const AddShiftDialog({
    this.initialLocationId,
    this.initialBranchId,
    super.key,
  });

  final String? initialLocationId;
  final String? initialBranchId;

  @override
  State<AddShiftDialog> createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<AddShiftDialog> {
  String? _locationId;
  String? _branchId;
  int? _startMinutes;
  int? _endMinutes;
  bool _isSubmitting = false;
  String? _validationMessage;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationId = widget.initialLocationId;
    _branchId = widget.initialBranchId;
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final state = context.watch<ShiftManagementCubit>().state;
    final locations = state.locations;
    final branches = state.branches
        .where((branch) => branch.locationId == _locationId)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 760.w),
        child: Padding(
          padding: EdgeInsets.all(18.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(localization),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                      child: _buildLocationDropdown(localization, locations)),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildBranchDropdown(localization, branches)),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                      child: _buildTimeField(
                          localization.startTime, _startMinutes, true)),
                  SizedBox(width: 16.w),
                  Expanded(
                      child: _buildTimeField(
                          localization.endTime, _endMinutes, false)),
                ],
              ),
              if (_validationMessage != null) ...[
                SizedBox(height: 10.h),
                Text(_validationMessage!,
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red)),
              ],
              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    label: localization.discard,
                    color: AppColors.disabledGrey,
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                  _buildActionButton(
                    label: localization.create,
                    color: AppColors.primary,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(S localization) {
    return Row(
      children: [
        Container(
          width: 34.sp,
          height: 34.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: CustomSvgImage(
            assetPath: HRAssets.hrShiftSchedule,
            width: 18.sp,
            height: 18.sp,
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 10.w),
        Text(localization.addShift,
            style: StyleText.fontSize16Weight600),
      ],
    );
  }

  Widget _buildLocationDropdown(S localization, List locations) {
    return CustomDropdown<String>(
      label: localization.location,
      hint: localization.location,
      value: _locationId,
      items: locations
          .map<DropdownItem<String>>(
            (location) =>
                DropdownItem(value: location.id, label: location.name),
          )
          .toList(),
      onChanged: (value) => setState(() {
        _locationId = value;
        _branchId = null;
      }),
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(6.r),
    );
  }

  Widget _buildBranchDropdown(S localization, List branches) {
    return CustomDropdown<String>(
      label: localization.branch,
      hint: localization.branch,
      value: _branchId,
      enabled: branches.isNotEmpty,
      items: branches
          .map<DropdownItem<String>>(
            (branch) => DropdownItem(value: branch.id, label: branch.name),
          )
          .toList(),
      onChanged: (value) => setState(() => _branchId = value),
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(6.r),
      emptyWidget: Text(localization.noResults),
    );
  }

  Widget _buildTimeField(String label, int? minutes, bool isStart) {
    final controller = isStart ? _startTimeController : _endTimeController;
    return CustomTextField(
      controller: controller,
      label: label,
      hint: '00:00',
      readOnly: true,
      suffixIcon: const Icon(Icons.access_time_outlined),
      fillColor: AppColors.background,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: minutes == null
              ? TimeOfDay.now()
              : ShiftEntity.fromMinutes(minutes),
        );
        if (!mounted || picked == null) return;
        final selectedMinutes = ShiftEntity.toMinutes(picked);
        setState(() {
          if (isStart) {
            _startMinutes = selectedMinutes;
            _startTimeController.text =
                ShiftEntity.formatMinutes(selectedMinutes);
          } else {
            _endMinutes = selectedMinutes;
            _endTimeController.text =
                ShiftEntity.formatMinutes(selectedMinutes);
          }
        });
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 155.w,
      child: customButton(
        title: label,
        function: onPressed ?? () {},
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
    if (_locationId == null) {
      setState(() => _validationMessage = localization.shiftLocationRequired);
      return;
    }
    if (_branchId == null) {
      setState(() => _validationMessage = localization.shiftBranchRequired);
      return;
    }
    if (_startMinutes == null || _endMinutes == null) {
      setState(() => _validationMessage = localization.shiftTimesRequired);
      return;
    }

    final shift = ShiftModel(
      id: 'shift_${DateTime.now().microsecondsSinceEpoch}',
      locationIds: [_locationId!],
      branchIds: [_branchId!],
      startMinutesHistory: [_startMinutes!],
      endMinutesHistory: [_endMinutes!],
      timestamps: const [],
      editors: const [],
    );
    final existingShifts = context.read<ShiftManagementCubit>().state.shifts;
    if (ShiftValidator.hasDuplicateWorkingHours(
      shift: shift,
      existingShifts: existingShifts,
    )) {
      setState(
          () => _validationMessage = localization.shiftDuplicateWorkingHours);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationMessage = null;
    });
    unawaited(showLoadingIndicator());
    final created =
        await context.read<ShiftManagementCubit>().createShift(shift);
    hideLoadingIndicator();
    if (!mounted) return;
    if (created) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSubmitting = false;
      _validationMessage = localization.shiftCreationFailed;
    });
  }
}
