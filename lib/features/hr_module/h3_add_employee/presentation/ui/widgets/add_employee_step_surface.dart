// ***************************** FILE INFO ***************************** //
// File Name: add_employee_step_surface.dart
// Purpose: Provides the shared colored surface for add-employee flow steps.
// Author: Mohamed Elrashidy
// Created At: 2026-08-29
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';

/// Wraps an add-employee step in the standard field-colored surface.
class AddEmployeeStepSurface extends StatelessWidget {
  const AddEmployeeStepSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: child,
    );
  }
}
