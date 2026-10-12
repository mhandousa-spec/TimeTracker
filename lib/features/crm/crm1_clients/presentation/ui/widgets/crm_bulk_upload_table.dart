// ****************** FILE INFO ******************
// File Name: crm_bulk_upload_table.dart
// Purpose: Scrollable CRM bulk-upload review table with selectable rows and editable cells
// Author: Mohand Adel
// Created At: 03/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmBulkUploadColumn {
  final String key;
  final String label;
  final double width;
  final bool isArabic;
  final String fieldId;
  final String fieldTypeId;
  final String? languageCode;

  const CrmBulkUploadColumn({
    required this.key,
    required this.label,
    this.width = 250,
    this.isArabic = false,
    String? fieldId,
    this.fieldTypeId = '',
    this.languageCode,
  }) : fieldId = fieldId ?? key;
}

class CrmBulkUploadTable extends StatelessWidget {
  final List<CrmBulkUploadColumn> columns;
  final List<Map<String, TextEditingController>> rows;
  final Set<int> selectedRows;
  final Map<int, Set<String>> invalidCells;
  final ValueChanged<int> onToggleRow;
  final void Function(int rowIndex, String key) onErrorTap;

  const CrmBulkUploadTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.selectedRows,
    required this.invalidCells,
    required this.onToggleRow,
    required this.onErrorTap,
  });

  @override
  Widget build(BuildContext context) {
    final double tableWidth = columns.fold<double>(
      50.sp,
      (double width, CrmBulkUploadColumn column) =>
          width + column.width.sp + 15.sp,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: tableWidth,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TotalBadge(total: rows.length),
                SizedBox(height: 10.sp),
                _HeaderRow(columns: columns),
                SizedBox(height: 10.sp),
                ...List<Widget>.generate(rows.length, (int index) {
                  return _BulkUploadDataRow(
                    columns: columns,
                    row: rows[index],
                    rowIndex: index,
                    isSelected: selectedRows.contains(index),
                    invalidKeys: invalidCells[index] ?? <String>{},
                    onToggleRow: onToggleRow,
                    onErrorTap: onErrorTap,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TotalBadge extends StatelessWidget {
  final int total;

  const _TotalBadge({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        'Total Services: $total',
        style: StyleText.fontSize14Weight500,
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<CrmBulkUploadColumn> columns;

  const _HeaderRow({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 35.sp),
      child: Row(
        children: columns.map((CrmBulkUploadColumn column) {
          return Container(
            width: column.width.sp,
            margin: EdgeInsetsDirectional.only(end: 15.sp),
            alignment: column.isArabic
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Directionality(
              textDirection:
                  column.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                column.label,
                textAlign: column.isArabic ? TextAlign.right : TextAlign.left,
                style: StyleText.fontSize16Weight500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BulkUploadDataRow extends StatelessWidget {
  final List<CrmBulkUploadColumn> columns;
  final Map<String, TextEditingController> row;
  final int rowIndex;
  final bool isSelected;
  final Set<String> invalidKeys;
  final ValueChanged<int> onToggleRow;
  final void Function(int rowIndex, String key) onErrorTap;

  const _BulkUploadDataRow({
    required this.columns,
    required this.row,
    required this.rowIndex,
    required this.isSelected,
    required this.invalidKeys,
    required this.onToggleRow,
    required this.onErrorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onToggleRow(rowIndex),
            child: Padding(
              padding: EdgeInsetsDirectional.only(top: 8.sp, end: 15.sp),
              child: CustomCheckBox(size: 20.sp, isSelected: isSelected),
            ),
          ),
          ...columns.map((CrmBulkUploadColumn column) {
            return Padding(
              padding: EdgeInsetsDirectional.only(end: 15.sp),
              child: SizedBox(
                width: column.width.sp,
                child: _EditableCell(
                  controller: row[column.key]!,
                  column: column,
                  hasError: invalidKeys.contains(column.key),
                  onErrorTap: () => onErrorTap(rowIndex, column.key),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EditableCell extends StatelessWidget {
  final TextEditingController controller;
  final CrmBulkUploadColumn column;
  final bool hasError;
  final VoidCallback onErrorTap;

  const _EditableCell({
    required this.controller,
    required this.column,
    required this.hasError,
    required this.onErrorTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget field = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextField(
            controller: controller,
            hint: column.label,
            height: 36.sp,
            fillColor: AppColors.background,
            borderRadius: BorderRadius.circular(8.sp),
            textDirection:
                column.isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: column.isArabic ? TextAlign.right : TextAlign.left,
            errorText: hasError ? ' ' : null,
            valueStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.darkGrey,
            ),
            hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
            errorStyle: StyleText.fontSize10Weight400.copyWith(
              color: AppColors.transparent,
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(width: 8.sp),
          GestureDetector(
            onTap: onErrorTap,
            child: SizedBox(
              height: 36.sp,
              child: Center(
                child: CustomSvgImage(
                  assetPath: AppAssets.crmWarning,
                  color: AppColors.red,
                  height: 20.sp,
                  width: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (!column.isArabic) return field;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: field,
    );
  }
}
