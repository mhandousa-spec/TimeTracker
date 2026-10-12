// ****************** FILE INFO ******************
// File Name: crm_deal_kanban_card.dart
// Purpose: Individual deal card in Pipeline Kanban stage column matching Figma screenshot 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';

class CrmDealKanbanCard extends StatelessWidget {
  final CrmClientDealModel deal;
  final VoidCallback? onTap;

  const CrmDealKanbanCard({
    super.key,
    required this.deal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Category & Trend Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  deal.category,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      deal.isPositiveTrend
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 14.sp,
                      color: deal.isPositiveTrend
                          ? AppColors.green
                          : AppColors.darkGrey,
                    ),
                    SizedBox(width: 4.sp),
                    Text(
                      deal.likelihood,
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        color: deal.isPositiveTrend
                            ? AppColors.green
                            : AppColors.darkGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 6.sp),

            // 2. Deal Title / Summary
            Text(
              deal.dealNameEn,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.darkGrey,
                fontSize: 11.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.sp),

            // 3. Progress & Amount Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'Progress  ',
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        color: AppColors.darkGrey,
                        fontSize: 10.sp,
                      ),
                    ),
                    Text(
                      '${deal.progress.toInt()}%',
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CustomSvgImage(
                      assetPath: AppAssets.crmPrice,
                      width: 12.sp,
                      height: 12.sp,
                      color: AppColors.darkGrey,
                    ),
                    SizedBox(width: 4.sp),
                    Text(
                      '\$${deal.amount.toInt()}',
                      style: StyleText.fontSize12Weight400.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.sp),

            // Divider line
            Container(
              height: 1.sp,
              color: AppColors.background,
              margin: EdgeInsets.only(bottom: 8.sp),
            ),

            // 4. Assignee & Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Assignee (Avatar + Name + Department)
                Row(
                  children: <Widget>[
                    Container(
                      width: 24.sp,
                      height: 24.sp,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: CustomSvgImage(
                        assetPath: AppAssets.crmPerson,
                        width: 12.sp,
                        height: 12.sp,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: 6.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          deal.assignedEmployee,
                          style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack)
                              .copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                        Text(
                          deal.department,
                          style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack)
                              .copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 8.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Date Range
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11.sp,
                      color: AppColors.darkGrey,
                    ),
                    SizedBox(width: 3.sp),
                    Text(
                      deal.startDate,
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        color: AppColors.darkGrey,
                        fontSize: 9.sp,
                      ),
                    ),
                    Text(
                      ' → ',
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        color: AppColors.darkGrey,
                        fontSize: 9.sp,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11.sp,
                      color: AppColors.darkGrey,
                    ),
                    SizedBox(width: 3.sp),
                    Text(
                      deal.closeDate,
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                        color: AppColors.darkGrey,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
