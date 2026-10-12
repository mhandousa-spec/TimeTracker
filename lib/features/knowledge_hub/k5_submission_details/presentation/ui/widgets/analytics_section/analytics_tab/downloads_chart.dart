/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/analytics_tab/downloads_chart.dart
/// ************************* FILE INFO *************************** ///
/// File Name: downloads_chart.dart
/// Purpose: Downloads chart — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

class DownloadsChart extends StatefulWidget {
  final bool lightMode;
  final Map<String, int> downloadsData;
  final Map<String, int> viewsData;

  const DownloadsChart({
    Key? key,
    required this.lightMode,
    required this.downloadsData,
    required this.viewsData,
  }) : super(key: key);

  @override
  State<DownloadsChart> createState() => _DownloadsChartState();
}

class _DownloadsChartState extends State<DownloadsChart> {
  bool isDownloadsView = true; // true = Downloads, false = Views

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Get current data based on selected view
    final currentData = isDownloadsView
        ? widget.downloadsData
        : widget.viewsData;

    final months = currentData.keys.toList();
    final values = currentData.values.map((v) => v.toDouble()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r)
          ),
          // CHANGED 12/9/2026 — NO FIXED HEIGHT ON A PHONE.
          //
          // This box used to be 300.h, which happened to match the card's
          // content almost exactly. Once [BarChartCard] moved the
          // Views/Downloads control onto its own row (so the title stops being
          // ellipsised), the content no longer matched the box: too tall and it
          // overflowed, too short and the surplus showed as a band of empty
          // card under the month labels — a fixed height cannot be right for
          // both states of the toggle on every phone size anyway.
          //
          // Null lets the card be exactly as tall as it needs to be. Nothing
          // here needs a fixed height: the analytics tab is a scrolling column,
          // so the card just takes its own height and the page scrolls.
          //
          // CHANGED 22/9/2026 — AND NOT ON DESKTOP EITHER. The 12/9 change
          // only freed the phone, so desktop kept the 300.h and kept the exact
          // symptom described above: the content comes out around 270 and the
          // remaining ~30 painted as a band of empty card under the month
          // labels ("big padding in desktop from bottom"). [ChartCard] does
          // not stretch its child to a fixed height unless `expandChild` is
          // set, so the surplus had nowhere to go but the bottom. The
          // reasoning above was never phone-specific — it applies here too.
          height: null,
          child: BarChartCard(
                   trailing: Container(
                   decoration: BoxDecoration(
                   color: widget.lightMode
                   ? KnowledgeHubColors.chartGreyLight
                   : KnowledgeHubColors.chartGreyDark,
                   borderRadius: BorderRadius.circular(6.r),
                   ),
                   child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                   GestureDetector(
                   onTap: () {
                   setState(() {
                   isDownloadsView = false;
                   });
                   },
                   child: Padding(
                   padding:  EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
                   child: Container(
                   padding: EdgeInsets.symmetric(
                   horizontal: 12.w,
                   vertical: 6.h,
                   ),
                   decoration: BoxDecoration(
                   color: !isDownloadsView
                   ? AppColors.primary
                   : AppColors.transparent,
                   borderRadius: BorderRadius.circular(6.r),
                   ),
                   child: Text(
                   S.of(context).views,
                   style: StyleText.fontSize14Weight500.copyWith(
                   color: !isDownloadsView
                   ? AppColors.textButton
                   : AppColors.secondaryText
                   ),
                   ),
                   ),
                   ),
                   ),
                   GestureDetector(
                   onTap: () {
                   setState(() {
                   isDownloadsView = true;
                   });
                   },
                   child: Padding(
                   padding:  EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),                      child: Container(
                   padding: EdgeInsets.symmetric(
                   horizontal: 12.w,
                   vertical: 6.h,
                   ),
                   decoration: BoxDecoration(
                   color: isDownloadsView
                   ? AppColors.primary
                   : AppColors.transparent,
                   borderRadius: BorderRadius.circular(6.r),
                   ),
                   child: Text(
                   S.of(context).downloads,
                   style: StyleText.fontSize14Weight500.copyWith(
                   color: isDownloadsView
                   ? AppColors.textButton
                   : AppColors.secondaryText
                   ),
                   ),
                   ),
                   ),
                   ),
                   ],
                   ),
                   ),
                   key: ValueKey(isDownloadsView),
                   title: isDownloadsView
                ? S.of(context).numberOfDownloads
                : S.of(context).numberOfViews,
                   dotIcon: "assets/icons_assets/knowledge_hub_assets/svg_download_icon.svg",
                   dotColor: AppColors.primary,
                   bars: List.generate(
                     months.length,
                     (i) => ChartData(
                       label: months[i],
                       value: values[i],
                     ),
                   ),
                   barWidth: 40,
                   barColor: AppColors.primary,
                 ),
        ),
      ],
    );
  }
}

// Updated helper function
Widget buildDownloadsChart(
    bool lightMode, {
      required Map<String, int> downloadsData,
      required Map<String, int> viewsData,
    }) {
  return DownloadsChart(
    lightMode: lightMode,
    downloadsData: downloadsData,
    viewsData: viewsData,
  );
}
