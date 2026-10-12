// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_position_analytics_widget.dart
// Purpose: Renders enum-backed workforce and position analytics charts.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/16-custom_card_styles.dart';
import '../../../../../../core/custom/24-custom_chart_card.dart';
import '../../../../../../core/custom/26-custom_bar_chart_card.dart';
import '../../../../../../core/custom/27-custom_donut_chart_card.dart';
import '../../../../../../core/custom/38-custom_responsive.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../h3_add_employee/utils/add_employee_form_options.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_position_analytics_data.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_distribution_item.dart';

class HRDashboardPositionAnalyticsWidget extends StatelessWidget {
  const HRDashboardPositionAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();

    final localization = S.of(context);
    final analytics = state.positionAnalytics;
    final unavailable = state.positionDataAvailable == false;

    return ResponsiveHelper(
      mobileWidget: _buildMobile(
        analytics: analytics,
        localization: localization,
        unavailable: unavailable,
      ),
      tabletWidget: _buildTablet(
        analytics: analytics,
        localization: localization,
        unavailable: unavailable,
      ),
    );
  }

  /// Method Name: [_buildMobile]
  ///
  /// Purpose: Stacks position analytics cards on narrow screens.
  ///
  /// Parameters:
  /// - [analytics]: Prepared dashboard position analytics.
  /// - [localization]: Active application localization.
  /// - [unavailable]: Whether position data failed to load.
  ///
  /// Returns: A vertically arranged responsive chart layout.
  Widget _buildMobile({
    required HrDashboardPositionAnalyticsData analytics,
    required S localization,
    required bool unavailable,
  }) {
    return Column(
      children: [
        _workforceChart(analytics, localization, unavailable),
        SizedBox(height: 16.h),
        _workArrangementChart(analytics, localization, unavailable),
        SizedBox(height: 16.h),
        _jobTypeChart(analytics, localization, unavailable),
        SizedBox(height: 16.h),
        _jobGradeChart(analytics, localization, unavailable),
      ],
    );
  }

  /// Method Name: [_buildTablet]
  ///
  /// Purpose: Uses two columns for the compact desktop/tablet dashboard.
  ///
  /// Parameters:
  /// - [analytics]: Prepared dashboard position analytics.
  /// - [localization]: Active application localization.
  /// - [unavailable]: Whether position data failed to load.
  ///
  /// Returns: A responsive two-column chart layout.
  Widget _buildTablet({
    required HrDashboardPositionAnalyticsData analytics,
    required S localization,
    required bool unavailable,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _workforceChart(analytics, localization, unavailable),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _workArrangementChart(
                analytics,
                localization,
                unavailable,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
                child: _jobTypeChart(analytics, localization, unavailable)),
            SizedBox(width: 16.w),
            Expanded(
              child: Container(),
            )
          ],
        ),
        SizedBox(height: 16.h),
        _jobGradeChart(analytics, localization, unavailable),
      ],
    );
  }

  /// Method Name: [_workforceChart]
  ///
  /// Purpose: Builds the derived workforce classification donut chart.
  ///
  /// Parameters:
  /// - [analytics]: Prepared dashboard position analytics.
  /// - [localization]: Active application localization.
  /// - [unavailable]: Whether position data failed to load.
  ///
  /// Returns: Workforce chart card.
  Widget _workforceChart(
    HrDashboardPositionAnalyticsData analytics,
    S localization,
    bool unavailable,
  ) {
    return _donutChart(
      title: localization.workforce,
      icon: HRAssets.dashboardWorkforce,
      items: analytics.workforceDistribution,
      localization: localization,
      unavailable: unavailable,
    );
  }

  /// Method Name: [_workArrangementChart]
  ///
  /// Purpose: Builds the work-arrangement enum distribution chart.
  ///
  /// Parameters:
  /// - [analytics]: Prepared dashboard position analytics.
  /// - [localization]: Active application localization.
  /// - [unavailable]: Whether position data failed to load.
  ///
  /// Returns: Work-arrangement chart card.
  Widget _workArrangementChart(
    HrDashboardPositionAnalyticsData analytics,
    S localization,
    bool unavailable,
  ) {
    return _donutChart(
      title: localization.status,
      icon: HRAssets.dashboardWorkArrangement,
      items: analytics.workArrangementDistribution,
      localization: localization,
      unavailable: unavailable,
    );
  }

  /// Method Name: [_jobTypeChart]
  ///
  /// Purpose: Builds the complete job-type enum distribution chart.
  ///
  /// Parameters:
  /// - [analytics]: Prepared dashboard position analytics.
  /// - [localization]: Active application localization.
  /// - [unavailable]: Whether position data failed to load.
  ///
  /// Returns: Job-type chart card.
  Widget _jobTypeChart(
    HrDashboardPositionAnalyticsData analytics,
    S localization,
    bool unavailable,
  ) {
    return _donutChart(
      title: localization.jobType,
      icon: HRAssets.dashboardJobType,
      items: analytics.jobTypeDistribution,
      localization: localization,
      unavailable: unavailable,
    );
  }

  /// Method Name: [_jobGradeChart]
  ///
  /// Purpose: Builds the complete job-grade enum distribution chart.
  ///
  /// Parameters:
  /// - [analytics]: Prepared dashboard position analytics.
  /// - [localization]: Active application localization.
  /// - [unavailable]: Whether position data failed to load.
  ///
  /// Returns: Job-grade bar chart card.
  Widget _jobGradeChart(
    HrDashboardPositionAnalyticsData analytics,
    S localization,
    bool unavailable,
  ) {
    if (unavailable) {
      return _unavailableCard(
        title: localization.jobGrade,
        icon: HRAssets.dashboardJobGrade,
        localization: localization,
      );
    }
    return BarChartCard(
      title: localization.jobGrade,
      dotIcon: HRAssets.dashboardJobGrade,
      bars: _chartData(
        analytics.jobGradeDistribution,
        localization,
      ),
    );
  }

  /// Method Name: [_donutChart]
  ///
  /// Purpose: Converts prepared distribution data into a donut chart.
  ///
  /// Parameters:
  /// - [title]: Localized chart title.
  /// - [icon]: Header SVG asset.
  /// - [items]: Prepared distribution values.
  /// - [localization]: Active application localization.
  /// - [unavailable]: Whether position data failed to load.
  ///
  /// Returns: Donut chart or an unavailable state card.
  Widget _donutChart({
    required String title,
    required String icon,
    required List<HrDashboardDistributionItem> items,
    required S localization,
    required bool unavailable,
  }) {
    if (unavailable) {
      return _unavailableCard(
        title: title,
        icon: icon,
        localization: localization,
      );
    }
    return DonutChartCard(
      title: title,
      dotIcon: icon,
      centerValue: _total(items).toString(),
      centerLabel: localization.total,
      sections: _chartData(items, localization),
    );
  }

  /// Method Name: [_unavailableCard]
  ///
  /// Purpose: Shows a localized state when position data cannot be read.
  ///
  /// Parameters:
  /// - [title]: Localized chart title.
  /// - [icon]: Header SVG asset.
  /// - [localization]: Active application localization.
  ///
  /// Returns: A chart shell with the unavailable message.
  Widget _unavailableCard({
    required String title,
    required String icon,
    required S localization,
  }) {
    return ChartCard(
      title: title,
      dotIcon: icon,
      child: SizedBox(
        height: 120.h,
        child: Center(
          child: Text(
            localization.notAvailable,
            style: CardStyles.label(12).copyWith(color: AppColors.greyDark),
          ),
        ),
      ),
    );
  }

  /// Method Name: [_chartData]
  ///
  /// Purpose: Resolves enum-backed category keys to localized chart labels.
  ///
  /// Parameters:
  /// - [items]: Prepared category counts.
  /// - [localization]: Active application localization.
  ///
  /// Returns: Chart data ready for shared chart components.
  List<ChartData> _chartData(
    List<HrDashboardDistributionItem> items,
    S localization,
  ) {
    final colors = [
      AppColors.primary,
      AppColors.greyDark,
      AppColors.grey,
      AppColors.text,
    ];
    return [
      for (var index = 0; index < items.length; index++)
        ChartData(
          label: _labelFor(items[index].category, localization),
          value: items[index].count.toDouble(),
          color: colors[index % colors.length],
        ),
    ];
  }

  /// Method Name: [_labelFor]
  ///
  /// Purpose: Resolves known enum labels and formats unknown legacy values.
  ///
  /// Parameters:
  /// - [category]: Enum key or preserved legacy value.
  /// - [localization]: Active application localization.
  ///
  /// Returns: A localized chart label.
  String _labelFor(String category, S localization) {
    if (category == HrDashboardPositionAnalyticsData.employeeCategoryKey) {
      return localization.employee;
    }
    final title = _findOptionTitle(
          category,
          JobTypeOption.values,
          (option) => option.title,
        ) ??
        _findOptionTitle(
          category,
          WorkArrangementOption.values,
          (option) => option.title,
        ) ??
        _findOptionTitle(
          category,
          EmployeeGradeOption.values,
          (option) => option.title,
        );
    return FormatHelper.capitalize(title ?? category);
  }

  String? _findOptionTitle<T extends Enum>(
    String value,
    List<T> options,
    String Function(T) title,
  ) {
    for (final option in options) {
      if (option.name == value) return title(option);
    }
    return null;
  }

  /// Method Name: [_total]
  ///
  /// Purpose: Calculates the total represented by distribution items.
  ///
  /// Parameters:
  /// - [items]: Prepared distribution values.
  ///
  /// Returns: Sum of all category counts.
  int _total(List<HrDashboardDistributionItem> items) =>
      items.fold(0, (sum, item) => sum + item.count);
}
