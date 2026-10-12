// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_summary.dart
// Purpose: Summarizes the selected workbook and atomic-upload readiness.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../generated/l10n.dart';

/// Compact employee workbook status summary.
class EmployeeBulkUploadSummary extends StatelessWidget {
  const EmployeeBulkUploadSummary({
    required this.fileName,
    required this.employeeCount,
    required this.errorCount,
    required this.newDepartmentCount,
    super.key,
  });

  final String fileName;
  final int employeeCount;
  final int errorCount;
  final int newDepartmentCount;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Wrap(
        spacing: 24.w,
        runSpacing: 10.h,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.description_outlined),
            SizedBox(width: 8.w),
            Text(fileName),
          ]),
          Text('${localization.employeeBulkTotalEmployees}: $employeeCount'),
          Text('${localization.employeeBulkTotalErrors}: $errorCount'),
          Text('${localization.department}: $newDepartmentCount'),
          SizedBox(
            width: 420.w,
            child: Text(localization.employeeBulkAtomicNotice,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
