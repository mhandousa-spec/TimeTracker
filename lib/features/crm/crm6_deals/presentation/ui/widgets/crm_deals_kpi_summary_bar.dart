// ****************** FILE INFO ******************
// File Name: crm_deals_kpi_summary_bar.dart
// Purpose: 5 responsive KPI stat cards for Deals summary matching Figma screenshots 1 & 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmDealsKpiSummaryBar extends StatelessWidget {
  final int totalDeals;
  final int wonDeals;
  final int lostDeals;
  final String totalValue;
  final String revenue;

  const CrmDealsKpiSummaryBar({
    super.key,
    required this.totalDeals,
    required this.wonDeals,
    required this.lostDeals,
    required this.totalValue,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNarrow = MediaQuery.of(context).size.width < 900;

    final List<Widget> cards = <Widget>[
      _buildStatCard(
        labelEn: 'Total Deals',
        labelAr: 'إجمالي الصفقات',
        value: '$totalDeals',
        iconAsset: AppAssets.crmDeal,
        iconBgColor: AppColors.primary,
        iconColor: AppColors.text,
      ),
      _buildStatCard(
        labelEn: 'Won Deals',
        labelAr: 'الصفقات الرابحة',
        value: '$wonDeals',
        iconAsset: AppAssets.crmDeal,
        iconBgColor: AppColors.green,
        iconColor: AppColors.white,
      ),
      _buildStatCard(
        labelEn: 'Lost Deals',
        labelAr: 'الصفقات الخاسرة',
        value: '$lostDeals',
        iconAsset: AppAssets.crmDeal,
        iconBgColor: AppColors.red,
        iconColor: AppColors.white,
      ),
      _buildStatCard(
        labelEn: 'Total Value',
        labelAr: 'القيمة الإجمالية',
        value: totalValue,
        iconAsset: AppAssets.crmPrice,
        iconBgColor: AppColors.primary,
        iconColor: AppColors.text,
      ),
      _buildStatCard(
        labelEn: 'Revenue',
        labelAr: 'الإيرادات',
        value: revenue,
        iconAsset: AppAssets.crmPrice,
        iconBgColor: AppColors.primary,
        iconColor: AppColors.text,
      ),
    ];

    if (isNarrow) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: cards
              .map(
                (w) => Container(
                  width: 170.sp,
                  margin: EdgeInsets.only(right: 12.sp),
                  child: w,
                ),
              )
              .toList(),
        ),
      );
    }

    return Row(
      children: cards
          .map(
            (w) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.sp),
                child: w,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStatCard({
    required String labelEn,
    required String labelAr,
    required String value,
    required String iconAsset,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      height: 64.sp,
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 32.sp,
            height: 32.sp,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CustomSvgImage(
              assetPath: iconAsset,
              width: 16.sp,
              height: 16.sp,
              color: iconColor,
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Text(
              FormatHelper.localizedString(
                englishName: labelEn,
                arabicName: labelAr,
              ),
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 6.sp),
          Text(
            value,
            style: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
