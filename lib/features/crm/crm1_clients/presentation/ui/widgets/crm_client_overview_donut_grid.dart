// ****************** FILE INFO ******************
// File Name: crm_client_overview_donut_grid.dart
// Purpose: Donut chart grid for the CRM Client Profile Overview tab
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';

class CrmClientOverviewDonutGrid extends StatelessWidget {
  final CrmClientRecordModel record;
  final List<CrmTemplateFieldModel> fields;

  const CrmClientOverviewDonutGrid({
    super.key,
    required this.record,
    this.fields = const [],
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final int crossAxisCount = isMobile
        ? 1
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    final List<Widget> donutCards = _buildDonutCards(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount > 2 ? 2 : crossAxisCount,
        mainAxisExtent: 240.sp,
        crossAxisSpacing: 14.sp,
        mainAxisSpacing: 14.sp,
      ),
      itemCount: donutCards.length,
      itemBuilder: (BuildContext context, int index) => donutCards[index],
    );
  }

  List<Widget> _buildDonutCards(BuildContext context) {
    return [
      // 1. Deals per Stage
      DonutChartCard(
        title: FormatHelper.localizedString(
          englishName: 'Deals per Stage',
          arabicName: 'الصفقات حسب المرحلة',
        ),
        centerValue: '9K',
        centerLabel: 'Total',
        dotColor: AppColors.primary,
        dotIcon: AppAssets.crmDeal,
        sections: [
          ChartData(
            label: 'New',
            value: 15,
            color: AppColors.blue,
          ),
          ChartData(
            label: 'Discovery',
            value: 15,
            color: AppColors.primary,
          ),
          ChartData(
            label: 'Qualified',
            value: 15,
            color: AppColors.orange,
          ),
          ChartData(
            label: 'Proposal',
            value: 15,
            color: AppColors.red,
          ),
          ChartData(
            label: 'Negotiation',
            value: 40,
            color: AppColors.secondaryBlack,
          ),
        ],
      ),

      // 2. Deals (Won vs Lost)
      DonutChartCard(
        title: FormatHelper.localizedString(
          englishName: 'Deals',
          arabicName: 'الصفقات',
        ),
        centerValue: '9K',
        centerLabel: 'Total',
        dotColor: AppColors.primary,
        dotIcon: AppAssets.crmDeal,
        sections: [
          ChartData(
            label: 'Won',
            value: 70,
            color: AppColors.green,
          ),
          ChartData(
            label: 'Lost',
            value: 30,
            color: AppColors.red,
          ),
        ],
      ),

      // 3. Relationship Categories
      DonutChartCard(
        title: FormatHelper.localizedString(
          englishName: 'Relationship Categories',
          arabicName: 'فئات العلاقات',
        ),
        centerValue: '9K',
        centerLabel: 'Total',
        dotColor: AppColors.primary,
        dotIcon: AppAssets.crmRelationship,
        sections: [
          ChartData(
            label: 'Organizational',
            value: 40,
            color: AppColors.primary,
          ),
          ChartData(
            label: 'Personal',
            value: 10,
            color: AppColors.grey,
          ),
          ChartData(
            label: 'Business',
            value: 15,
            color: AppColors.secondaryBlack,
          ),
          ChartData(
            label: 'Employment',
            value: 25,
            color: AppColors.black,
          ),
          ChartData(
            label: 'Government',
            value: 10,
            color: AppColors.darkGrey,
          ),
        ],
      ),

      // 4. Activities Categories
      DonutChartCard(
        title: FormatHelper.localizedString(
          englishName: 'Activities Categories',
          arabicName: 'فئات الأنشطة',
        ),
        centerValue: '9K',
        centerLabel: 'Total',
        dotColor: AppColors.primary,
        dotIcon: AppAssets.timeSelectorIcon,
        sections: [
          ChartData(
            label: 'Communication',
            value: 40,
            color: AppColors.primary,
          ),
          ChartData(
            label: 'Relationship',
            value: 10,
            color: AppColors.grey,
          ),
          ChartData(
            label: 'Sales',
            value: 25,
            color: AppColors.secondaryBlack,
          ),
          ChartData(
            label: 'E-commerce',
            value: 25,
            color: AppColors.black,
          ),
        ],
      ),

      // 5. Deals Categories
      DonutChartCard(
        title: FormatHelper.localizedString(
          englishName: 'Deals Categories',
          arabicName: 'فئات الصفقات',
        ),
        centerValue: '9K',
        centerLabel: 'Total',
        dotColor: AppColors.primary,
        dotIcon: AppAssets.crmDeal,
        sections: [
          ChartData(
            label: 'Deal 1',
            value: 40,
            color: AppColors.primary,
          ),
          ChartData(
            label: 'Deal 2',
            value: 10,
            color: AppColors.grey,
          ),
          ChartData(
            label: 'Deal 3',
            value: 25,
            color: AppColors.secondaryBlack,
          ),
          ChartData(
            label: 'Deal 4',
            value: 25,
            color: AppColors.black,
          ),
        ],
      ),
    ];
  }
}
