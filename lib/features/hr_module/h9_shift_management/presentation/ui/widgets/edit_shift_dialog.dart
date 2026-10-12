// ***************************** FILE INFO ***************************** //
// File Name: edit_shift_dialog.dart
// Purpose: Edits the start and end times of an existing HR shift.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

/// Dialog that changes only the time values of an existing shift.
class EditShiftDialog extends StatefulWidget {
  const EditShiftDialog({required this.shift, super.key});

  final ShiftModel shift;

  @override
  State<EditShiftDialog> createState() => _EditShiftDialogState();
}

class _EditShiftDialogState extends State<EditShiftDialog> {
  late int _startMinutes;
  late int _endMinutes;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _hasChanges =>
      _startMinutes != widget.shift.startMinutes ||
      _endMinutes != widget.shift.endMinutes;

  @override
  void initState() {
    super.initState();
    _startMinutes = widget.shift.startMinutes;
    _endMinutes = widget.shift.endMinutes;
    _startController = TextEditingController(
      text: ShiftEntity.formatMinutes(_startMinutes),
    );
    _endController = TextEditingController(
      text: ShiftEntity.formatMinutes(_endMinutes),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
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
                      child: _buildTimeField(localization.startTime, true)),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildTimeField(localization.endTime, false)),
                ],
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 10.h),
                Text(_errorMessage!,
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
                    label: localization.apply,
                    color: _hasChanges
                        ? AppColors.primary
                        : AppColors.disabledGrey,
                    onPressed: _isSubmitting || !_hasChanges ? null : _submit,
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
        Text(
          '${localization.edit} ${localization.shifts}',
          style: StyleText.fontSize16Weight600,
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, bool isStart) {
    final controller = isStart ? _startController : _endController;
    final minutes = isStart ? _startMinutes : _endMinutes;
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
          initialTime: ShiftEntity.fromMinutes(minutes),
        );
        if (!mounted || picked == null) return;
        final selectedMinutes = ShiftEntity.toMinutes(picked);
        setState(() {
          if (isStart) {
            _startMinutes = selectedMinutes;
            _startController.text = ShiftEntity.formatMinutes(selectedMinutes);
          } else {
            _endMinutes = selectedMinutes;
            _endController.text = ShiftEntity.formatMinutes(selectedMinutes);
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
    final draft = ShiftModel(
      id: widget.shift.id,
      locationIds: [widget.shift.locationId],
      branchIds: [widget.shift.branchId],
      startMinutesHistory: [_startMinutes],
      endMinutesHistory: [_endMinutes],
      timestamps: const [],
      editors: const [],
    );
    final existingShifts = context.read<ShiftManagementCubit>().state.shifts;
    if (ShiftValidator.hasDuplicateWorkingHours(
      shift: draft,
      existingShifts: existingShifts,
      excludedShiftId: widget.shift.id,
    )) {
      setState(() => _errorMessage = localization.shiftDuplicateWorkingHours);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    unawaited(showLoadingIndicator());
    final updated = await context.read<ShiftManagementCubit>().updateShiftTimes(
          shiftId: widget.shift.id,
          startMinutes: _startMinutes,
          endMinutes: _endMinutes,
        );
    hideLoadingIndicator();
    if (!mounted) return;
    if (updated) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorMessage = localization.shiftCreationFailed;
    });
  }
}
