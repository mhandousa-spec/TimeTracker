/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: chart_widget_layout.dart
/// Purpose: Declares `HomeChartDescriptor`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/28-custom_horizontal_bar_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Which module a chart belongs to, so the Adding Widget page can filter the
/// Chart & Graph tab with the same module chips it uses for widgets.
class HomeChartDescriptor {
  final String id;
  final Modules module;

  const HomeChartDescriptor({required this.id, required this.module});
}

/// Every chart this page can offer. Add new charts here and they are picked up
/// by the filter automatically.
const List<HomeChartDescriptor> kHomeCharts = <HomeChartDescriptor>[
  HomeChartDescriptor(id: 'services_offered', module: Modules.services),
  HomeChartDescriptor(id: 'number_of_services', module: Modules.services),
];

/// Number of charts each module owns — the count shown in the filter chips
/// while the Chart & Graph tab is active.
Map<Modules, int> homeChartCountsByModule() {
  final counts = <Modules, int>{};
  for (final chart in kHomeCharts) {
    counts[chart.module] = (counts[chart.module] ?? 0) + 1;
  }
  return counts;
}

class HomeLayoutChartWidget extends StatefulWidget {
  final VoidCallback? onChartSettingsChanged;

  /// Null shows every chart. Otherwise only charts belonging to this module.
  final Modules? moduleFilter;

  const HomeLayoutChartWidget({
    super.key,
    this.onChartSettingsChanged,
    this.moduleFilter,
  });

  @override
  State<HomeLayoutChartWidget> createState() => _HomeLayoutChartWidgetState();
}

class _HomeLayoutChartWidgetState extends State<HomeLayoutChartWidget> {

  EmployeeEntityPro get employeeFunctionHelper {
    final controller = Get.find<MainCoreEmployeeController>();
    if (controller.employeeEntity == null) {
      throw Exception('EmployeeEntity is not initialized yet');
    }
    return controller.employeeEntity!;
  }

  // ── Convert labels to Arabic if needed ────────────────
  List<String> _formatLabels(List<String> labels, bool isArabic) {
    if (!isArabic) return labels;
    const english = ['0','1','2','3','4','5','6','7','8','9',
      'S','s','A','a','B','b','C','c','D','d'];
    const arabic  = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩',
      'س','س','أ','أ','ب','ب','ج','ج','د','د'];
    return labels.map((label) {
      String result = label;
      for (int i = 0; i < english.length; i++) {
        result = result.replaceAll(english[i], arabic[i]);
      }
      return result;
    }).toList();
  }


  /// Default orientation per chart id.
  ///
  /// Replaces the removed ChartRegistry + per-user ChartSettingsFirebaseService:
  /// charts now render with a fixed default using the core cards
  /// (BarChartCard / HorizontalBarChartCard).
  ChartOrientation _getChartOrientation(String chartId) {
    switch (chartId) {
      case 'services_offered':
        return ChartOrientation.horizontal;
      case 'number_of_services':
      default:
        return ChartOrientation.vertical;
    }
  }



  Widget _buildChart({
    required String chartId,
    required List<String> labels,
    required List<double> values,
    required String title,
    required bool isArabic,
  }) {
    const double chartWidth = 265;
    const double chartHeight = 200;

    final orientation = _getChartOrientation(chartId);
    // ── Format labels for Arabic display ──────────────
    final formattedLabels = _formatLabels(labels, isArabic);

    final bars = <ChartData>[
      for (int i = 0; i < formattedLabels.length; i++)
        ChartData(label: formattedLabels[i], value: values[i]),
    ];

    return orientation == ChartOrientation.horizontal
        ? HorizontalBarChartCard(
            title: title,
            bars: bars,
            width: chartWidth.w,
            barHeight: 10,
          )
        : BarChartCard(
            title: title,
            bars: bars,
            width: chartWidth.w,
            chartHeight: chartHeight.h,
            barWidth: 20,
          );
  }

  /// Demo data + title per chart id, kept next to [kHomeCharts] so adding a
  /// chart is a two-line change.
  Widget? _chartById(String id, bool isArabic, S l) {
    switch (id) {
      case 'services_offered':
        return _buildChart(
          chartId: 'services_offered',
          labels: const ['S1', 'S2', 'S3', 'S4'], // converted internally
          values: const [10, 20, 30, 40], // always doubles ✅
          title: l.servicesOffered,
          isArabic: isArabic,
        );
      case 'number_of_services':
        return _buildChart(
          chartId: 'number_of_services',
          labels: const ['S1', 'S2', 'S3', 'S4'], // converted internally
          values: const [100, 120, 104, 125], // always doubles ✅
          title: l.numberOfServices,
          isArabic: isArabic,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic  = Localizations.localeOf(context).languageCode == 'ar';
    final l         = S.of(context);

    final visible = widget.moduleFilter == null
        ? kHomeCharts
        : kHomeCharts
            .where((chart) => chart.module == widget.moduleFilter)
            .toList();

    if (visible.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.sp),
        child: Center(
          child: Text(
            l.noDataAvailable,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20.sp,
          runSpacing: 20.sp,
          children: [
            for (final chart in visible)
              if (_chartById(chart.id, isArabic, l) != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [_chartById(chart.id, isArabic, l)!],
                ),
          ],
        ),
      ],
    );
  }
}