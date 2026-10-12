/// Module: knowledge_hub / presentation / s8_dashboard / widgets/approvals_downloads_chart.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_downloads_chart.dart
/// Purpose: Approvals downloads chart — Dashboard (S8) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';

class ApprovalsDownloadsChart extends StatefulWidget {
  final bool lightMode;
  final Map<String, int> downloadsData;
  final Map<String, int> viewsData;

  const ApprovalsDownloadsChart({
    super.key,
    required this.lightMode,
    required this.downloadsData,
    required this.viewsData,
  });

  @override
  State<ApprovalsDownloadsChart> createState() =>
      _ApprovalsDownloadsChartState();
}

class _ApprovalsDownloadsChartState extends State<ApprovalsDownloadsChart> {
  bool isDownloadsView = true; // true = Downloads, false = Views

  @override
  Widget build(BuildContext context) {
    // Get current data based on selected view
    final currentData = isDownloadsView
        ? widget.downloadsData
        : widget.viewsData;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final months = currentData.keys.toList();
    final values = currentData.values.map((e) => e.toDouble()).toList();

    // Calculate max value across both datasets for consistent Y-axis
    final allDownloads = widget.downloadsData.values;
    final allViews = widget.viewsData.values;
    final allValues = [...allDownloads, ...allViews];
    final maxValue = allValues.isNotEmpty
        ? allValues.reduce((a, b) => a > b ? a : b).toDouble()
        : 10.0;

    return BarChartCard(
             trailing: CustomSegmentedTabs(
               tabs: [S.of(context)!.views, S.of(context)!.download],
               selectedIndex: isDownloadsView ? 1 : 0,
               onTabSelected: (i) => setState(() => isDownloadsView = i == 1),
               containerColor: widget.lightMode
                   ? Colors.grey.shade200
                   : Colors.grey.shade800,
               selectedColor: AppColors.primary,
               unselectedColor: AppColors.transparent,
               selectedTextColor: AppColors.textButton,
               unselectedTextColor: widget.lightMode
                   ? Colors.grey.shade700
                   : Colors.grey.shade400,
               textStyle: StyleText.fontSize12Weight500,
               spacing: 4.sp,
               tabHorizontalPadding: 8.w,
               tabVerticalPadding: 6.h,
             ),
             key: ValueKey(isDownloadsView),
             title: isDownloadsView
          ? S.of(context)!.numberOfDownloads
          : S.of(context)!.numberOfViews,
             dotIcon: isDownloadsView
          ? 'assets/icons_assets/knowledge_hub_assets/svg_download_icon.svg'
          : 'assets/icons_assets/knowledge_hub_assets/view_icon.svg',
             dotColor: AppColors.primary,
             bars: List.generate(
               months.length,
               (i) => ChartData(
                 label: isArabic ? _arabicMonthLabel(months[i]) : months[i],
                 value: values[i],
               ),
             ),
             maxY: maxValue + 2,
             chartHeight: 300,
             barWidth: 20.sp,
             barColor: AppColors.primary,
           );
  }

}

/// Map an English month key (e.g. 'Jan', or a full 'January') to its Arabic
/// name for display under the bars. Anything unrecognised is returned as-is so
/// non-month keys still render.
String _arabicMonthLabel(String key) {
  const map = {
    'jan': 'يناير', 'feb': 'فبراير', 'mar': 'مارس', 'apr': 'أبريل',
    'may': 'مايو', 'jun': 'يونيو', 'jul': 'يوليو', 'aug': 'أغسطس',
    'sep': 'سبتمبر', 'oct': 'أكتوبر', 'nov': 'نوفمبر', 'dec': 'ديسمبر',
  };
  final k = key.trim().toLowerCase();
  final short = k.length >= 3 ? k.substring(0, 3) : k;
  return map[short] ?? key;
}

/// Helper function to create ApprovalsDownloadsChart widget
Widget approvalsDownloadsChart(
    bool lightMode, {
      required Map<String, int> downloadsData,
      required Map<String, int> viewsData,
    }) {
  return ApprovalsDownloadsChart(
    lightMode: lightMode,
    downloadsData: downloadsData,
    viewsData: viewsData,
  );
}
