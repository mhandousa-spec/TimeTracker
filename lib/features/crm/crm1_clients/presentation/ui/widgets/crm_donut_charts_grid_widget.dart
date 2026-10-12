// ****************** FILE INFO ******************
// File Name: crm_donut_charts_grid_widget.dart
// Purpose: Donut chart grid for the CRM clients dashboard
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_chart_card.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_dashboard_view_data.dart';

class CrmDonutChartsGridWidget extends StatelessWidget {
  final List<CrmDashboardDonutChartData> cards;

  const CrmDonutChartsGridWidget({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    final List<CrmDashboardDonutChartData> visibleCards = cards
        .where((CrmDashboardDonutChartData card) => card.slices.isNotEmpty)
        .toList();

    if (visibleCards.isEmpty) {
      return const SizedBox.shrink();
    }

    final int crossAxisCount =
        CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount > 2 ? 2 : crossAxisCount,
        mainAxisExtent: 230.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: visibleCards.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildCard(visibleCards[index]);
      },
    );
  }

  Widget _buildCard(CrmDashboardDonutChartData card) {
    final List<ChartData> sections = _chartSections(card);
    final int total = card.slices.fold<int>(
      0,
      (int sum, CrmDashboardSlice slice) => sum + slice.value.toInt(),
    );

    return DonutChartCard(
      title: card.title,
      centerValue: total.toString(),
      centerLabel: 'Total',
      dotColor: AppColors.primary,
      dotIcon: _iconForTitle(card.title),
      sections: sections,
    );
  }

  List<ChartData> _chartSections(CrmDashboardDonutChartData card) {
    final List<Color> palette = <Color>[
      AppColors.primary,
      AppColors.secondaryBlack,
      AppColors.darkGrey,
      AppColors.black,
      AppColors.grey,
    ];
    return List<ChartData>.generate(card.slices.length, (int index) {
      final CrmDashboardSlice slice = card.slices[index];
      return ChartData(
        label: slice.label,
        value: slice.value,
        color: palette[index % palette.length],
      );
    });
  }

  String _iconForTitle(String title) {
    switch (title) {
      case 'Sector':
        return AppAssets.crmSectorField;
      case 'Industry':
      case 'Industry Distribution':
        return AppAssets.crmIndustryField;
      case 'Preferred Language':
        return AppAssets.crmTextField;
      case 'Preferred Contact Channel':
        return AppAssets.phone;
      case 'Country':
        return AppAssets.addressIcon;
      case 'Commercial Title':
        return AppAssets.crmDescriptionField;
      case 'Owner Status':
        return AppAssets.crmStatus;
      case 'Cities':
        return AppAssets.addressIcon;
      case 'Tags':
        return AppAssets.crmTagField;
      case 'Purchasing Value Ranges':
        return AppAssets.crmRelationship;
      case 'Company Size':
        return AppAssets.crmCompanySizeField;
      case 'Deal Categories':
      case 'Deals':
      case 'Deals by Stage':
        return AppAssets.crmDeal;
      case 'Teams':
        return AppAssets.crmGroup;
      case 'Clients Value':
        return AppAssets.crmClients;
      case 'Relationship Categories':
        return AppAssets.crmRelationship;
      case 'Activities Categories':
        return AppAssets.crmServices;
      case 'Departments':
        return AppAssets.department;
      case 'Clients Type':
        return AppAssets.crmClientsType;
      default:
        return AppAssets.crmClients;
    }
  }
}
