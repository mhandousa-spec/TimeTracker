// ****************** FILE INFO ******************
// File Name: crm_duplicate_card.dart
// Purpose: Extracted card widget representing a duplicate or merged client record matching Figma design
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:intl/intl.dart';

class CrmDuplicateCard extends StatelessWidget {
  final CrmDuplicatePairModel pair;
  final VoidCallback onReviewMerge;
  final VoidCallback? onIgnore;
  final bool isMergedView;

  const CrmDuplicateCard({
    super.key,
    required this.pair,
    required this.onReviewMerge,
    this.onIgnore,
    this.isMergedView = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color matchColor = _getMatchColor(pair.mergeLevelColorHex);
    final String matchLabel = pair.mergeLevelName;
    final String formattedDate = DateFormat('d/M/yyyy').format(pair.detectedAt);
    final String formattedTime = DateFormat('h:mm a').format(pair.detectedAt);

    return InkWell(
      onTap: onReviewMerge,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: <Widget>[
            // 1. Left Icon Container
            Container(
              width: 42.sp,
              height: 42.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmRecord,
                width: 22.sp,
                height: 22.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 12.sp),

            // 2. Client Name & Record Count Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pair.record1.name,
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    '${pair.record1.activeDealsCount > 0 ? 3 : 2} Record',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.sp),

            // 3. Right: Date & Time (Merge tab) OR Match Score & Label (Duplicate tab)
            if (isMergedView)
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
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  // Percentage bordered box
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: matchColor,
                        width: 1.sp,
                      ),
                    ),
                    child: Text(
                      '${pair.matchScore}%',
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        color: matchColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.sp),

                  // Match Status Label (Very Likely / Possible / Unlikely)
                  Text(
                    matchLabel,
                    style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                      color: matchColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(String colorHex) {
    final String normalized = colorHex.replaceAll('#', '').trim();
    if (normalized.length != 6 && normalized.length != 8) {
      return AppColors.darkGrey;
    }
    return Color(int.parse(
      normalized.length == 6 ? 'FF$normalized' : normalized,
      radix: 16,
    ));
  }
}
