/// Module: knowledge_hub / presentation / s8_dashboard / widgets/uploaded_documents_chart.dart
/// ************************* FILE INFO *************************** ///
/// File Name: uploaded_documents_chart.dart
/// Purpose: Uploaded documents chart — Dashboard (S8) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class UploadedDocumentsChart extends StatefulWidget {
  final bool lightMode;
  final Map<String, int> publishedData;
  final Map<String, int> removedData;

  const UploadedDocumentsChart({
    super.key,
    required this.lightMode,
    required this.publishedData,
    required this.removedData,
  });

  @override
  State<UploadedDocumentsChart> createState() => _UploadedDocumentsChartState();
}

class _UploadedDocumentsChartState extends State<UploadedDocumentsChart> {
  bool isPublishedView = true; // true = Published, false = Removed

  @override
  Widget build(BuildContext context) {
    // Get current data based on selected view
    final currentData = isPublishedView
        ? widget.publishedData
        : widget.removedData;

    // Always show ALL 12 months in order (not just the months that happen to
    // have data). A month with no data renders as a 0-height bar.
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    // Arabic month labels shown under the bars when the locale is Arabic. The
    // English keys above are still used to look up the data map.
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final values =
        months.map((m) => (currentData[m] ?? 0).toDouble()).toList();

    // Calculate max value across both datasets for consistent Y-axis
    final allPublished = widget.publishedData.values;
    final allRemoved = widget.removedData.values;
    final allValues = [...allPublished, ...allRemoved];
    final maxValue = allValues.isNotEmpty
        ? allValues.reduce((a, b) => a > b ? a : b).toDouble()
        : 10.0;

    return BarChartCard(
             trailing: CustomSegmentedTabs(
               tabs: [S.of(context)!.published, S.of(context)!.removed],
               selectedIndex: isPublishedView ? 0 : 1,
               onTabSelected: (i) => setState(() => isPublishedView = i == 0),
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
             key: ValueKey(isPublishedView),
             title: S.of(context)!.uploadedDocuments,
             dotIcon: 'assets/icons_assets/knowledge_hub_assets/upload_doc.svg',
             dotColor: AppColors.primary,
             // CHANGED 12/9/2026 — FOUR MONTHS ON A PHONE, TWELVE ELSEWHERE.
             //
             // Twelve bars in a phone-width card leaves each month a few points
             // of width: the labels run into each other, and the card either
             // squeezes them or turns into a sideways scroller that nobody
             // discovers. The four most recent months are the ones a dashboard
             // glance is about anyway; a tablet or desktop card has the width
             // for the full year and keeps it.
             bars: List.generate(
               _visibleMonthCount(context, months.length),
               (i) {
                 // Index into the TAIL of the year, so the newest month stays on
                 // the right exactly as it does in the twelve-month version.
                 final int index = months.length -
                     _visibleMonthCount(context, months.length) +
                     i;
                 return ChartData(
                   label: isArabic ? arabicMonths[index] : months[index],
                   value: values[index],
                 );
               },
             ),
             maxY: maxValue + 2,
             chartHeight: 300,
             barWidth: 20.sp,
             barColor: AppColors.primary,
           );
  }

}

/// How many of the trailing months to plot: four on a phone, all of them on a
/// tablet or desktop. See the note at the `bars:` call site.
int _visibleMonthCount(BuildContext context, int total) {
  const int phoneMonths = 4;
  if (!ContextExtension(context).isPhone) return total;
  return total < phoneMonths ? total : phoneMonths;
}

/// Helper function to create UploadedDocumentsChart widget
Widget uploadedDocumentsChart(
    bool lightMode, {
      required Map<String, int> publishedData,
      required Map<String, int> removedData,
    }) {
  return UploadedDocumentsChart(
    lightMode: lightMode,
    publishedData: publishedData,
    removedData: removedData,
  );
}
