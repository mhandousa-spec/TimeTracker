// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_table.dart
// Purpose: Displays the reference-styled editable employee workbook table.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';

import '../../../../../../../generated/l10n.dart';
import '../../../data/models/employee_bulk_upload_cell_error.dart';
import '../../../data/models/employee_bulk_upload_row.dart';
import '../../../utils/constants/employee_bulk_upload_headers.dart';
import 'employee_bulk_upload_cell.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Employee spreadsheet table matching the supplied bulk-upload reference.
class EmployeeBulkUploadTable extends StatefulWidget {
  const EmployeeBulkUploadTable({
    required this.rows,
    required this.errors,
    required this.selectedRows,
    required this.focusedError,
    required this.onToggleRow,
    required this.onChanged,
    super.key,
  });

  final List<EmployeeBulkUploadRow> rows;
  final List<EmployeeBulkUploadCellError> errors;
  final Set<int> selectedRows;
  final EmployeeBulkUploadCellError? focusedError;
  final ValueChanged<int> onToggleRow;
  final void Function(int rowIndex, String header, String value) onChanged;

  @override
  State<EmployeeBulkUploadTable> createState() =>
      _EmployeeBulkUploadTableState();
}

class _EmployeeBulkUploadTableState extends State<EmployeeBulkUploadTable> {
  final ScrollController _vertical = ScrollController();
  final ScrollController _horizontal = ScrollController();

  @override
  void didUpdateWidget(covariant EmployeeBulkUploadTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final error = widget.focusedError;
    if (error == null || error == oldWidget.focusedError) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_vertical.hasClients) {
        _vertical.animateTo(
          (error.rowIndex * 76.sp).clamp(0, _vertical.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      final column = EmployeeBulkUploadHeaders.values.indexOf(error.header);
      if (column >= 0 && _horizontal.hasClients) {
        _horizontal.animateTo(
          (column * 262.sp).clamp(0, _horizontal.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.only(bottom: 10.sp),
        child: SingleChildScrollView(
          controller: _horizontal,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: (EmployeeBulkUploadHeaders.values.length * 265.sp) + 90.sp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 10.sp,
                        top: 10.sp,
                        right: 10.sp,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Center(
                          child: Text(
                            '${S.of(context).employeeBulkTotalEmployees}: ${widget.rows.length}',
                            style:
                                StyleText.fontSize14Weight500.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.sp),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.sp),
                    child: SizedBox(
                      child: SingleChildScrollView(
                        controller: _vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _headerRow(context),
                            ...List.generate(widget.rows.length, _dataRow),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 33.sp),
      child: Row(
        children: EmployeeBulkUploadHeaders.values.map((header) {
          final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(header);
          return Container(
            width: 250.sp,
            margin: EdgeInsets.only(right: 12.sp),
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              header,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dataRow(int rowIndex) {
    final row = widget.rows[rowIndex];
    final selected = widget.selectedRows.contains(rowIndex);
    return Padding(
      padding: EdgeInsets.only(
        top: 10.sp,
        bottom: 10.sp,
        right: 12.sp,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onToggleRow(rowIndex),
            child: Container(
              width: 24.sp,
              height: 24.sp,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.secondaryPrimary
                    : AppColors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: selected
                    ? null
                    : Border.all(color: AppColors.grey, width: 1.5.sp),
              ),
              child: Icon(
                Icons.check,
                size: 20.sp,
                color: selected ? AppColors.textButton : AppColors.transparent,
              ),
            ),
          ),
          SizedBox(width: 10.sp),
          for (final header in EmployeeBulkUploadHeaders.values)
            Padding(
              padding: EdgeInsets.only(right: 12.sp),
              child: EmployeeBulkUploadCell(
                key: ValueKey('$rowIndex|$header'),
                header: header,
                value: row.value(header),
                error: _errorFor(rowIndex, header),
                focused: widget.focusedError?.rowIndex == rowIndex &&
                    widget.focusedError?.header == header,
                onChanged: (value) => widget.onChanged(rowIndex, header, value),
              ),
            ),
        ],
      ),
    );
  }

  String? _errorFor(int rowIndex, String header) {
    for (final error in widget.errors) {
      if (error.rowIndex == rowIndex && error.header == header) {
        return error.message;
      }
    }
    return null;
  }
}
