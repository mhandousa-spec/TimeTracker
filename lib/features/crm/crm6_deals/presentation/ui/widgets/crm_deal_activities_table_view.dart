// ****************** FILE INFO ******************
// File Name: crm_deal_activities_table_view.dart
// Purpose: Table view component for Deal Activities matching CrmClientsTableWidget design with even/odd row colors and zero checkboxes
// Author: Mohand Adel
// Created At: 29/08/2026

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_activity_model.dart';

class CrmDealActivitiesTableView extends StatelessWidget {
  final List<CrmDealActivityModel> activities;
  final void Function(CrmDealActivityModel activity)? onActivityTap;

  const CrmDealActivitiesTableView({
    super.key,
    required this.activities,
    this.onActivityTap,
  });

  bool get _isArabic => Get.locale.toString().contains('ar');

  TextStyle get _headerStyle => StyleText.fontSize14Weight600.copyWith(
        color: AppColors.white,
        fontSize: 13.sp,
      );

  TextStyle _cellStyle(BuildContext context,
          {Color? color, bool isBold = false}) =>
      StyleText.fontSize14Weight400.copyWith(
        fontSize: 13.sp,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color ??
            (Theme.of(context).brightness == Brightness.light
                ? AppColors.text
                : AppColors.white),
      );

  static final Map<int, TableColumnWidth> _columnWidths =
      <int, TableColumnWidth>{
    0: FixedColumnWidth(50.sp), // NO
    1: FixedColumnWidth(140.sp), // Activity Type
    2: FixedColumnWidth(130.sp), // Subject
    3: FixedColumnWidth(130.sp), // الموضوع
    4: FixedColumnWidth(130.sp), // Assign to
    5: FixedColumnWidth(120.sp), // Due Date
    6: FixedColumnWidth(110.sp), // Time
    7: FixedColumnWidth(100.sp), // Tags
    8: FixedColumnWidth(120.sp), // Status
    9: FixedColumnWidth(160.sp), // Note
    10: FixedColumnWidth(160.sp), // ملاحظة
  };

  static const List<String> _headers = <String>[
    'NO',
    'Activity Type',
    'Subject',
    'الموضوع',
    'Assign to',
    'Due Date',
    'Time',
    'Tags',
    'Status',
    'Note',
    'ملاحظة',
  ];

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        height: 200.sp,
        alignment: Alignment.center,
        child: Text(
          'No activities found.',
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
      );
    }

    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool isRtl = _isArabic;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            border: TableBorder.all(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: _columnWidths,
            children: <TableRow>[
              // ── Header Row ──────────────────────────────────────────────────
              TableRow(
                decoration: BoxDecoration(
                  color: isLight ? AppColors.black : AppColors.dividerGrey,
                ),
                children: _headers.map((String title) {
                  return Padding(
                    padding: EdgeInsets.all(10.sp),
                    child: Text(
                      title,
                      style: _headerStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  );
                }).toList(),
              ),

              // ── Data Rows ───────────────────────────────────────────────────
              ...List<TableRow>.generate(activities.length, (int index) {
                final CrmDealActivityModel item = activities[index];
                final bool isEven = index.isEven;
                final Color rowColor = isLight
                    ? (isEven ? AppColors.evenRowColor : AppColors.oddRowColor)
                    : (isEven ? AppColors.darkDashboardTable : AppColors.black);

                final List<Widget> cells = <Widget>[
                  // 1. NO
                  _buildCell(context, '${item.no}', item),
                  // 2. Activity Type
                  _buildCell(context, item.activityType, item),
                  // 3. Subject
                  _buildCell(context, item.subjectEn, item),
                  // 4. الموضوع
                  _buildCell(context, item.subjectAr, item),
                  // 5. Assign to
                  _buildCell(context, item.assigneeName, item),
                  // 6. Due Date
                  _buildCell(context, item.dueDate, item),
                  // 7. Time
                  _buildCell(context, item.time, item),
                  // 8. Tags
                  _buildCell(context, item.tags, item),
                  // 9. Status (Colored text)
                  _buildColoredCell(
                    context,
                    item.status.labelEn,
                    item.status.color,
                    item,
                    isBold: true,
                  ),
                  // 10. Note
                  _buildCell(context, item.noteEn, item),
                  // 11. ملاحظة
                  _buildCell(context, item.noteAr, item),
                ];

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: cells,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    String text,
    CrmDealActivityModel item, {
    Color? color,
    bool isBold = false,
  }) {
    return InkWell(
      onTap: () => onActivityTap?.call(item),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Text(
          text.trim().isEmpty ? '-' : text,
          style: _cellStyle(context, color: color, isBold: isBold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildColoredCell(
    BuildContext context,
    String text,
    Color color,
    CrmDealActivityModel item, {
    bool isBold = false,
  }) {
    return InkWell(
      onTap: () => onActivityTap?.call(item),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Text(
          text.trim().isEmpty ? '-' : text,
          style: _cellStyle(context, color: color, isBold: isBold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
