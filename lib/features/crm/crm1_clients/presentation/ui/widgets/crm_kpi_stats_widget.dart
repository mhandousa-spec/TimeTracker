// ****************** FILE INFO ******************
// File Name: crm_kpi_stats_widget.dart
// Purpose: KPI cards for the CRM dashboard clients summary strip
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_dashboard_view_data.dart';

import 'package:knowticed_plus/generated/l10n.dart';

class CrmKpiStatsWidget extends StatelessWidget {
  final CrmDashboardKpiData? kpiData;
  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final int prospectCount;
  final int archivedCount;

  const CrmKpiStatsWidget({
    super.key,
    this.kpiData,
    this.totalCount = 0,
    this.activeCount = 0,
    this.inactiveCount = 0,
    this.prospectCount = 0,
    this.archivedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final List<_CrmKpiCardData> cards = kpiData != null
        ? <_CrmKpiCardData>[
            _CrmKpiCardData(
              title: S.current.crmTotalClients,
              value: kpiData!.totalClients,
              assetPath: AppAssets.crmGroup,
              iconBackground: AppColors.primary,
            ),
            _CrmKpiCardData(
              title: S.current.crmPersons,
              value: kpiData!.persons,
              assetPath: AppAssets.crmPerson,
              iconBackground: AppColors.blue,
            ),
            _CrmKpiCardData(
              title: S.current.crmCompanies,
              value: kpiData!.companies,
              assetPath: AppAssets.crmCompanies,
              iconBackground: AppColors.green,
            ),
            _CrmKpiCardData(
              title: S.current.crmGovernment,
              value: kpiData!.governments,
              assetPath: AppAssets.crmGovernment,
              iconBackground: AppColors.primary,
            ),
          ]
        : <_CrmKpiCardData>[
            _CrmKpiCardData(
              title: S.current.crmTotalClients,
              value: totalCount,
              assetPath: AppAssets.crmGroup,
              iconBackground: AppColors.primary,
            ),
            _CrmKpiCardData(
              title: S.current.crmPersons,
              value: activeCount,
              assetPath: AppAssets.crmPerson,
              iconBackground: AppColors.blue,
            ),
            _CrmKpiCardData(
              title: S.current.crmCompanies,
              value: inactiveCount,
              assetPath: AppAssets.crmCompanies,
              iconBackground: AppColors.green,
            ),
            _CrmKpiCardData(
              title: S.current.crmGovernment,
              value: prospectCount,
              assetPath: AppAssets.crmGovernment,
              iconBackground: AppColors.primary,
            ),
            _CrmKpiCardData(
              title: 'Archived',
              value: archivedCount,
              assetPath: AppAssets.crmPerson,
              iconBackground: AppColors.grey,
            ),
          ];

    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final int crossAxisCount = isMobile
        ? 2
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            crossAxisCount > cards.length ? cards.length : crossAxisCount,
        mainAxisExtent: isMobile ? 52.sp : 56.sp,
        crossAxisSpacing: isMobile ? 10.sp : 12.sp,
        mainAxisSpacing: isMobile ? 10.sp : 12.sp,
      ),
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) {
        return _CrmKpiCard(
          card: cards[index],
          isMobile: isMobile,
        );
      },
    );
  }
}

class _CrmKpiCardData {
  final String title;
  final int value;
  final String assetPath;
  final Color iconBackground;

  const _CrmKpiCardData({
    required this.title,
    required this.value,
    required this.assetPath,
    required this.iconBackground,
  });
}

class _CrmKpiCard extends StatelessWidget {
  final _CrmKpiCardData card;
  final bool isMobile;

  const _CrmKpiCard({
    required this.card,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final double iconContainerSize = isMobile ? 26.sp : 35.sp;
    final double iconSize = isMobile ? 14.sp : 20.sp;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.sp : 10.sp,
        vertical: isMobile ? 6.sp : 10.sp,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: card.iconBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CustomSvgImage(
              assetPath: card.assetPath,
              width: iconSize,
              height: iconSize,
              color: card.iconBackground == AppColors.primary
                  ? AppColors.black
                  : AppColors.white,
            ),
          ),
          SizedBox(width: isMobile ? 8.sp : 10.sp),
          Expanded(
            child: Text(
              card.title,
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
          Text(
            card.value.toString(),
            style: isMobile
                ? StyleText.fontSize14Weight600
                : StyleText.fontSize16Weight600,
          ),
        ],
      ),
    );
  }
}
