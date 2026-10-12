// ****************** FILE INFO ******************
// File Name: crm_client_activities_table_widget.dart
// Purpose: Full-width data table for CRM client activities matching Figma design (13 columns, no action buttons).
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';

class CrmClientActivitiesTableWidget extends StatelessWidget {
  final List<CrmClientActivityModel> items;
  final ValueChanged<CrmClientActivityModel> onTap;

  const CrmClientActivitiesTableWidget({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.sp),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(),
              ...List.generate(items.length, (int index) {
                return _buildRow(items[index], index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 42.sp,
      color: const Color(0xFF2D2D2D),
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      child: Row(
        children: <Widget>[
          _headerCell('NO', width: 44.sp),
          _headerCell('Activity Category', width: 140.sp),
          _headerCell('Activity Type', width: 110.sp),
          _headerCell('Subject', width: 120.sp),
          _headerCell('الموضوع', width: 120.sp),
          _headerCell('Assign to', width: 130.sp),
          _headerCell('Due Date', width: 100.sp),
          _headerCell('Time', width: 90.sp),
          _headerCell('Tags', width: 100.sp),
          _headerCell('Deal', width: 90.sp),
          _headerCell('Status', width: 110.sp),
          _headerCell('Note', width: 140.sp),
          _headerCell('ملاحظة', width: 140.sp),
        ],
      ),
    );
  }

  Widget _headerCell(
    String label, {
    required double width,
  }) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 6.sp),
      child: Text(
        label,
        style: StyleText.fontSize16Weight400.copyWith(color: Colors.white).copyWith(
          color: AppColors.white,
          fontSize: 13.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRow(CrmClientActivityModel item, int index) {
    final bool isOdd = index.isOdd;
    final Color rowBg = isOdd ? AppColors.white : AppColors.background;
    final String dueDateStr =
        '${item.dueAt.day}/${item.dueAt.month}/${item.dueAt.year}';
    final String timeStr = DateFormat('h:mm a').format(item.dueAt);
    final String tagsStr = item.tagNames.isNotEmpty
        ? item.tagNames.join(', ')
        : (item.tagIds.isNotEmpty ? item.tagIds.join(', ') : '-');

    return InkWell(
      onTap: () => onTap(item),
      child: Container(
        height: 46.sp,
        color: rowBg,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Row(
          children: <Widget>[
            _dataCell('${index + 1}', width: 44.sp),
            _dataCell(item.categoryName, width: 140.sp),
            _dataCell(item.typeName, width: 110.sp),
            _dataCell(item.subjectEn, width: 120.sp),
            _dataCell(item.subjectAr, width: 120.sp),
            _dataCell(item.assigneeName, width: 130.sp),
            _dataCell(dueDateStr, width: 100.sp),
            _dataCell(timeStr, width: 90.sp),
            _dataCell(tagsStr, width: 100.sp),
            _dataCell(item.dealLabel ?? '-', width: 90.sp),
            _statusCell(item.status, width: 110.sp),
            _dataCell(item.noteEn, width: 140.sp),
            _dataCell(item.noteAr, width: 140.sp),
          ],
        ),
      ),
    );
  }

  Widget _dataCell(String text, {required double width}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 6.sp),
      alignment: Alignment.centerLeft,
      child: Text(
        text.trim().isNotEmpty ? text : '-',
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.text,
          fontSize: 12.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _statusCell(String status, {required double width}) {
    final Color color = _statusColor(status);
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 6.sp),
      alignment: Alignment.centerLeft,
      child: Text(
        _statusLabel(status),
        style: StyleText.fontSize12Weight400.copyWith(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'schedules':
        return 'Schedules';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'draft':
        return 'Draft';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'schedules':
        return AppColors.blue;
      case 'in_progress':
        return AppColors.orange;
      case 'completed':
        return AppColors.green;
      case 'cancelled':
        return AppColors.darkGrey;
      case 'draft':
        return AppColors.darkGrey;
      default:
        return AppColors.grey;
    }
  }
}
