// ****************** FILE INFO ******************
// File Name: crm_client_activity_card.dart
// Purpose: Compact grid card widget for CRM client activity matching Figma design.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_card_info_row.dart';

class CrmClientActivityCard extends StatelessWidget {
  final CrmClientActivityModel item;
  final VoidCallback onTap;

  const CrmClientActivityCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = item.subjectEn.isNotEmpty
        ? item.subjectEn
        : (item.subjectAr.isNotEmpty ? item.subjectAr : item.categoryName);

    final String dateStr =
        '${item.dueAt.day}/${item.dueAt.month}/${item.dueAt.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.sp),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isCompact = constraints.maxWidth < 460.sp;
          final double tileSize = isCompact ? 46.sp : 54.sp;
          final double contentSpacing = isCompact ? 8.sp : 12.sp;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8.sp : 12.sp,
              vertical: 8.sp,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildCalendarTile(size: tileSize),
                      SizedBox(width: contentSpacing),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 68.sp),
                              child: Text(
                                title,
                                style: StyleText.fontSize14Weight600
                                    .copyWith(
                                  color: AppColors.text,
                                  fontSize: isCompact ? 12.sp : 14.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 4.sp),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _buildInfoColumn(
                                    firstAsset: AppAssets.crmCategoryIcon,
                                    firstLabel: 'Category:',
                                    firstValue: item.categoryName.isNotEmpty
                                        ? item.categoryName
                                        : '-',
                                    secondAsset: AppAssets.crmPerson,
                                    secondLabel: 'Assign to:',
                                    secondValue: item.assigneeName.isNotEmpty
                                        ? item.assigneeName
                                        : '-',
                                    isCompact: isCompact,
                                  ),
                                ),
                                SizedBox(width: isCompact ? 4.sp : 12.sp),
                                Expanded(
                                  child: _buildInfoColumn(
                                    firstAsset: AppAssets.crmClientsType,
                                    firstLabel: 'Type:',
                                    firstValue: item.typeName.isNotEmpty
                                        ? item.typeName
                                        : '-',
                                    secondAsset: AppAssets.calendar,
                                    secondLabel: 'Date:',
                                    secondValue: dateStr,
                                    isCompact: isCompact,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _buildStatusBadge(isCompact: isCompact),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarTile({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      alignment: Alignment.center,
      child: CustomSvgImage(
        assetPath: AppAssets.calendar,
        width: size * 0.52,
        height: size * 0.52,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildInfoColumn({
    required String firstAsset,
    required String firstLabel,
    required String firstValue,
    required String secondAsset,
    required String secondLabel,
    required String secondValue,
    required bool isCompact,
  }) {
    final double fontSize = isCompact ? 10.sp : 11.sp;
    final double iconSize = isCompact ? 12.sp : 13.sp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CrmCardInfoItem(
          svgAsset: firstAsset,
          label: firstLabel,
          value: firstValue,
          fontSize: fontSize,
          iconSize: iconSize,
        ),
        SizedBox(height: 3.sp),
        CrmCardInfoItem(
          svgAsset: secondAsset,
          label: secondLabel,
          value: secondValue,
          fontSize: fontSize,
          iconSize: iconSize,
        ),
      ],
    );
  }

  Widget _buildStatusBadge({required bool isCompact}) {
    final Color badgeColor = _statusColor(item.status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 5.sp : 7.sp,
        vertical: 2.sp,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(3.sp),
      ),
      child: Text(
        _statusLabel(item.status),
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.white,
          fontSize: isCompact ? 8.sp : 9.sp,
          fontWeight: FontWeight.w600,
        ),
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
        return AppColors.red;
      case 'draft':
        return AppColors.darkGrey;
      default:
        return AppColors.grey;
    }
  }
}
