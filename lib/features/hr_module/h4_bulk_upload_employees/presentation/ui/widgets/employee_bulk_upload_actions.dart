// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_actions.dart
// Purpose: Matches the supplied discard, activate, and dialog presentation.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../../../../core/theme/app_colors.dart';

import '../../../../../../../generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Reference-styled final action row for employee bulk upload.
class EmployeeBulkUploadActions extends StatelessWidget {
  const EmployeeBulkUploadActions({
    required this.canSubmit,
    required this.submitting,
    required this.employeeCount,
    required this.newDepartmentCount,
    required this.onDiscard,
    required this.onSubmit,
    super.key,
  });

  final bool canSubmit;
  final bool submitting;
  final int employeeCount;
  final int newDepartmentCount;
  final VoidCallback onDiscard;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Row(
      children: [
        _ActionButton(
          title: localization.discard,
          color: lightMode ? AppColors.grey : AppColors.mediumGrey,
          textColor: lightMode ? AppColors.black : AppColors.white,
          enabled: !submitting,
          onTap: onDiscard,
        ),
        const Spacer(),
        _ActionButton(
          title: localization.activate,
          color: canSubmit && !submitting
              ? AppColors.primary
              : lightMode
                  ? AppColors.grey
                  : AppColors.mediumGrey,
          textColor: canSubmit && !submitting
              ? AppColors.textButton
              : lightMode
                  ? AppColors.black
                  : AppColors.white,
          enabled: !submitting,
          onTap: () => canSubmit ? _confirm(context) : _showErrors(context),
        ),
      ],
    );
  }

  void _showErrors(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.all(20.sp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
              width: 90.sp,
              height: 90.sp,
            ),
            SizedBox(height: 20.sp),
            Text(
              S.of(dialogContext).mustCorrectErrors,
              style: StyleText.fontSize18Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final localization = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.all(20.sp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
              width: 90.sp,
              height: 90.sp,
            ),
            SizedBox(height: 15.sp),
            Text(
              localization.employeeBulkConfirmTitle,
              style: StyleText.fontSize20Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.sp),
            Text(
              '${localization.employeeBulkTotalEmployees}: $employeeCount\n'
              '${localization.department}: $newDepartmentCount\n'
              '${localization.employeeBulkExistingUnaffected}\n'
              '${localization.employeeBulkConfirmMessage}',
              style: StyleText.fontSize18Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DialogButton(
                  title: localization.no,
                  color: lightMode ? AppColors.grey : AppColors.mediumGrey,
                  textColor: lightMode ? AppColors.black : AppColors.white,
                  onTap: () => Navigator.pop(dialogContext, false),
                ),
                SizedBox(width: 28.sp),
                _DialogButton(
                  title: localization.yes,
                  color: AppColors.primary,
                  textColor: AppColors.textButton,
                  onTap: () => Navigator.pop(dialogContext, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) await onSubmit();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.color,
    required this.textColor,
    required this.onTap,
    required this.enabled,
  });

  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 150.sp,
          height: 38.sp,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: StyleText.fontSize16Weight500.copyWith(
              color: textColor,
            ),
          ),
        ),
      );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.title,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 135.sp,
          height: 38.sp,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: StyleText.fontSize18Weight500.copyWith(
              color: textColor,
            ),
          ),
        ),
      );
}
