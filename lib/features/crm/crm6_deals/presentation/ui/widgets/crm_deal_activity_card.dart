// ****************** FILE INFO ******************
// File Name: crm_deal_activity_card.dart
// Purpose: Compact grid card widget for Deal Activity matching Figma screenshot 1
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_activity_model.dart';

class CrmDealActivityCard extends StatelessWidget {
  final CrmDealActivityModel activity;
  final VoidCallback? onTap;

  const CrmDealActivityCard({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // ── Left: Calendar / Date Tile ──────────────────────────────────
            Container(
              width: 50.sp,
              height: 50.sp,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.calendar,
                width: 24.sp,
                height: 24.sp,
                color: AppColors.black,
              ),
            ),

            SizedBox(width: 12.sp),

            // ── Center & Right: Content ────────────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Top Title & Solid Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        activity.categoryName.isNotEmpty
                            ? activity.categoryName
                            : 'IT',
                        style: StyleText.fontSize14Weight500.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          fontSize: 14.sp,
                        ),
                      ),
                      _buildStatusBadge(activity.status),
                    ],
                  ),

                  SizedBox(height: 6.sp),

                  // Metadata Row 1: Type & Assign to
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmCategoryIcon,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Type:',
                            value: activity.activityType.isNotEmpty
                                ? activity.activityType
                                : 'Call',
                          ),
                          fontSize: 11.sp,
                          iconSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmPerson,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Assign to:',
                            value: activity.assigneeName.isNotEmpty
                                ? activity.assigneeName
                                : 'Aya Ali',
                          ),
                          fontSize: 11.sp,
                          iconSize: 12.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.sp),

                  // Metadata Row 2: Date & Time
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.calendar,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Date:',
                            value: activity.dueDate,
                          ),
                          fontSize: 11.sp,
                          iconSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: Icon(
                              Icons.access_time_rounded,
                              size: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Time:',
                            value: activity.time,
                          ),
                          fontSize: 11.sp,
                          iconSize: 12.sp,
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
    );
  }

  Widget _buildStatusBadge(CrmDealActivityStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status.badgeLabel,
        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
