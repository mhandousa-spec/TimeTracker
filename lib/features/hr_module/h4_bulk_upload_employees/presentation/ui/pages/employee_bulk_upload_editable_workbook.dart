// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_editable_workbook.dart
// Purpose: Renders the editable employee workbook region.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';

import '../../../data/models/employee_bulk_upload_cell_error.dart';
import '../../../data/models/employee_bulk_upload_row.dart';
import '../widgets/employee_bulk_upload_actions.dart';
import '../widgets/employee_bulk_upload_table.dart';
import '../widgets/employee_bulk_upload_toolbar.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Editable workbook presentation for parsed employee rows.
class EmployeeBulkUploadEditableWorkbook extends StatelessWidget {
  const EmployeeBulkUploadEditableWorkbook({
    required this.fileName,
    required this.errorCount,
    required this.focusedErrorIndex,
    required this.hasSelection,
    required this.canDuplicate,
    required this.selectedRows,
    required this.focusedError,
    required this.rows,
    required this.errors,
    required this.canSubmit,
    required this.submitting,
    required this.employeeCount,
    required this.newDepartmentCount,
    required this.onPreviousError,
    required this.onNextError,
    required this.onAdd,
    required this.onDuplicate,
    required this.onRemove,
    required this.onToggleRow,
    required this.onChanged,
    required this.onDiscard,
    required this.onSubmit,
    super.key,
  });

  final String fileName;
  final int errorCount;
  final int focusedErrorIndex;
  final bool hasSelection;
  final bool canDuplicate;
  final Set<int> selectedRows;
  final EmployeeBulkUploadCellError? focusedError;
  final List<EmployeeBulkUploadRow> rows;
  final List<EmployeeBulkUploadCellError> errors;
  final bool canSubmit;
  final bool submitting;
  final int employeeCount;
  final int newDepartmentCount;
  final VoidCallback onPreviousError;
  final VoidCallback onNextError;
  final VoidCallback onAdd;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;
  final ValueChanged<int> onToggleRow;
  final void Function(int row, String header, String value) onChanged;
  final VoidCallback onDiscard;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final currentErrorNumber = errorCount == 0
        ? 0
        : focusedErrorIndex < 0
            ? 1
            : focusedErrorIndex + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          fileName,
          style: StyleText.fontSize23Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 23.sp),
        EmployeeBulkUploadToolbar(
          errorCount: errorCount,
          currentErrorNumber: currentErrorNumber,
          hasSelection: hasSelection,
          canDuplicate: canDuplicate,
          onPreviousError: onPreviousError,
          onNextError: onNextError,
          onAdd: onAdd,
          onDuplicate: onDuplicate,
          onRemove: onRemove,
        ),
        SizedBox(height: 10.sp),
        EmployeeBulkUploadTable(
          rows: rows,
          errors: errors,
          selectedRows: selectedRows,
          focusedError: focusedError,
          onToggleRow: onToggleRow,
          onChanged: onChanged,
        ),
        SizedBox(height: 20.sp),
        EmployeeBulkUploadActions(
          canSubmit: canSubmit,
          submitting: submitting,
          employeeCount: employeeCount,
          newDepartmentCount: newDepartmentCount,
          onDiscard: onDiscard,
          onSubmit: onSubmit,
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
