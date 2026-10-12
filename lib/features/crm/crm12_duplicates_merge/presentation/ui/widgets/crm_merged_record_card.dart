// ****************** FILE INFO ******************
// File Name: crm_merged_record_card.dart
// Purpose: Displays a compact persisted merge-history record in the Merge tab
// Author: Mohand Adel
// Created At: 28/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CrmMergedRecordCard extends StatelessWidget {
  final CrmMergeHistoryModel history;
  final VoidCallback onTap;

  const CrmMergedRecordCard({
    super.key,
    required this.history,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('d/M/yyyy').format(history.mergedAt);
    final String formattedTime = DateFormat('h:mm a').format(history.mergedAt);
    final int recordCount = 1 +
        (history.mergedClientIds.isEmpty ? 1 : history.mergedClientIds.length);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42.sp,
              height: 42.sp,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: CustomSvgImage(
                assetPath: AppAssets.crmRecord,
                width: 22.sp,
                height: 22.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    history.masterClientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    '$recordCount Record',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.sp),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  formattedDate,
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: 2.sp),
                Text(
                  formattedTime,
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
