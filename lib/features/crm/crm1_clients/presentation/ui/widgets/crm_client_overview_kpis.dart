// ****************** FILE INFO ******************
// File Name: crm_client_overview_kpis.dart
// Purpose: Mini KPI summary cards strip for the CRM Client Profile Overview tab
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmClientOverviewKpis extends StatelessWidget {
  final int totalDeals;
  final String totalRevenue;
  final int relationshipCount;
  final int activitiesToday;

  const CrmClientOverviewKpis({
    super.key,
    this.totalDeals = 30,
    this.totalRevenue = '\$50',
    this.relationshipCount = 30,
    this.activitiesToday = 50,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final int crossAxisCount = isMobile ? 2 : 4;

    final List<_KpiItemData> items = [
      _KpiItemData(
        title: FormatHelper.localizedString(
          englishName: 'Total Deals',
          arabicName: 'إجمالي الصفقات',
        ),
        value: totalDeals.toString(),
        iconPath: AppAssets.crmDeal,
        iconBackground: AppColors.primary,
        iconColor: AppColors.black,
      ),
      _KpiItemData(
        title: FormatHelper.localizedString(
          englishName: 'Total Revenue',
          arabicName: 'إجمالي الإيرادات',
        ),
        value: totalRevenue,
        iconPath: AppAssets.crmPrice,
        iconBackground: AppColors.green,
        iconColor: AppColors.white,
      ),
      _KpiItemData(
        title: FormatHelper.localizedString(
          englishName: 'Relationship',
          arabicName: 'العلاقات',
        ),
        value: relationshipCount.toString(),
        iconPath: AppAssets.crmRelationship,
        iconBackground: AppColors.orange,
        iconColor: AppColors.white,
      ),
      _KpiItemData(
        title: FormatHelper.localizedString(
          englishName: 'Activities Today',
          arabicName: 'أنشطة اليوم',
        ),
        value: activitiesToday.toString(),
        iconPath: AppAssets.calendar,
        iconBackground: AppColors.blue,
        iconColor: AppColors.white,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: isMobile ? 54.sp : 56.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildKpiCard(items[index], isMobile);
      },
    );
  }

  Widget _buildKpiCard(_KpiItemData item, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.sp,
        vertical: 8.sp,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Row(
        children: [
          // Circular Icon Badge
          Container(
            width: isMobile ? 28.sp : 35.sp,
            height: isMobile ? 28.sp : 35.sp,
            decoration: BoxDecoration(
              color: item.iconBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CustomSvgImage(
              assetPath: item.iconPath,
              width: isMobile ? 15.sp : 18.sp,
              height: isMobile ? 15.sp : 18.sp,
              color: item.iconColor,
            ),
          ),
          SizedBox(width: 8.sp),

          // Title
          Expanded(
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isMobile
                  ? StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                    )
                  : StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.darkGrey,
                    ),
            ),
          ),
          SizedBox(width: 6.sp),

          // Value
          Text(
            item.value,
            style: isMobile
                ? StyleText.fontSize14Weight600
                : StyleText.fontSize16Weight600,
          ),
        ],
      ),
    );
  }
}

class _KpiItemData {
  final String title;
  final String value;
  final String iconPath;
  final Color iconBackground;
  final Color iconColor;

  const _KpiItemData({
    required this.title,
    required this.value,
    required this.iconPath,
    required this.iconBackground,
    required this.iconColor,
  });
}
