// ****************** FILE INFO ******************
// File Name: crm_merge_level_card.dart
// Purpose: Display card for CRM Merge Level with color indicator, range info, and status
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmMergeLevelCard extends StatelessWidget {
  final CrmMergeLevelModel level;
  final VoidCallback? onTap;

  const CrmMergeLevelCard({
    super.key,
    required this.level,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String title = isArabic
        ? (level.nameAr.isNotEmpty ? level.nameAr : level.nameEn)
        : (level.nameEn.isNotEmpty ? level.nameEn : level.nameAr);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          children: <Widget>[
            // Color indicator dot/swatch
            Container(
              width: 24.sp,
              height: 24.sp,
              decoration: BoxDecoration(
                color: level.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  width: 1.sp,
                ),
              ),
            ),
            SizedBox(width: 12.sp),

            // Title and range
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title.isNotEmpty ? title : S.current.crmMergePossibleLevel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  CardInfoRow(
                    info: CardInfo(
                      label: '${S.current.crmMergeRangeFrom}:',
                      value: '${level.rangeFrom} - ${level.rangeTo}',
                    ),
                    fontSize: 12.sp,
                    iconSize: 12.sp,
                  ),
                  if (level.audit != null) ...<Widget>[
                    SizedBox(height: 3.sp),
                    CardInfoRow(
                      info: CardInfo(
                        label: 'By:',
                        value: level.audit!.updatedBy.isEmpty
                            ? '-'
                            : level.audit!.updatedBy,
                      ),
                      fontSize: 12.sp,
                      iconSize: 12.sp,
                    ),
                  ],
                ],
              ),
            ),

            // Status chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
              decoration: BoxDecoration(
                color: level.isActive
                    ? AppColors.green.withValues(alpha: 0.12)
                    : AppColors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.sp),
              ),
              child: Text(
                level.isActive
                    ? S.current.crmStatusActive
                    : S.current.crmStatusInactive,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: level.isActive ? AppColors.green : AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
