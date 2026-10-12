// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_dialog_action.dart
// Purpose: Renders the acknowledgement action used by bulk-upload dialogs.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

/// A fixed-size acknowledgement action for bulk-upload dialogs.
class EmployeeBulkUploadDialogAction extends StatelessWidget {
  const EmployeeBulkUploadDialogAction({
    required this.title,
    required this.onTap,
    super.key,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 135.sp,
          height: 38.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: StyleText.fontSize18Weight500.copyWith(
              color: AppColors.textButton,
            ),
          ),
        ),
      );
}
