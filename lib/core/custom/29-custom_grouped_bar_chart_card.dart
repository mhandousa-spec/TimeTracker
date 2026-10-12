/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: grouped_bar_chart_card.dart
/// Purpose: Declares `GroupedBarData`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Figma: "Asset Condition & Lifecycle" — grouped vertical bars with
// an inline legend (Excellent / Good / Fair / Poor / Unusable).
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

/// One group of bars (e.g. "iPhone 18" with one value per series).
class GroupedBarData {
  final String label;
  final List<double> values;

  const GroupedBarData({required this.label, required this.values});
}

/// Grouped bar chart card.
///
/// ```dart
/// GroupedBarChartCard(
///   title: 'Asset Condition & Lifecycle',
///   series: [
///     ChartData(label: 'Excellent', value: 0, color: AppColors.green),
///     ChartData(label: 'Good', value: 0, color: AppColors.primary),
///     ChartData(label: 'Poor', value: 0, color: AppColors.red),
///   ],
///   groups: [
///     GroupedBarData(label: 'iPhone 18', values: [410, 300, 120]),
///     GroupedBarData(label: 'iPhone 16', values: [380, 250, 90]),
///   ],
/// )
/// ```
class GroupedBarChartCard extends StatelessWidget {
  final String title;

  /// Series definitions: label + color per bar within a group.
  final List<ChartData> series;
  final List<GroupedBarData> groups;
  final Widget? trailing;
  final double? maxY;
  final double chartHeight;
  final double barWidth;
  final double? width;

  /// Fixed card height. Null keeps the card hugging its content; the Adding
  /// Widget picker passes Figma's 200 so a row of charts lines up.
  final double? height;

  /// Card padding. Null uses [ChartCard]'s default of 16; the Figma chart
  /// frames use 10.
  final EdgeInsetsGeometry? padding;

  /// Forwarded to [ChartCard.expandChild]: with a fixed [height], let the
  /// plot absorb the leftover space rather than leaving a gap underneath.
  final bool expandChild;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  const GroupedBarChartCard({
    super.key,
    required this.title,
    required this.series,
    required this.groups,
    this.trailing,
    this.maxY,
    this.chartHeight = 200,
    this.barWidth = 8,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.dotColor,
    this.dotIcon,
  });

  double get _maxY {
    if (maxY != null) return maxY!;
    double m = 0;
    for (final g in groups) {
      for (final v in g.values) {
        if (v > m) m = v;
      }
    }
    return m == 0 ? 100 : m * 1.2;
  }

  /// Widest group label measured at the label text style.
  double get _maxLabelWidth {
    double maxW = 0;
    final style = CardStyles.label(9);
    for (final g in groups) {
      final tp = TextPainter(
        text: TextSpan(text: g.label, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > maxW) maxW = tp.width;
    }
    return maxW;
  }

  /// Width a single group of bars occupies (bars + spacing between them).
  double get _groupWidth {
    int maxBars = 0;
    for (final g in groups) {
      if (g.values.length > maxBars) maxBars = g.values.length;
    }
    if (maxBars == 0) return 0;
    return maxBars * barWidth.w + (maxBars - 1) * 3.w;
  }

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: title,
      trailing: trailing,
      width: width,
      height: height,
      padding: padding,
      expandChild: expandChild,
      dotColor: dotColor,
      dotIcon: dotIcon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartLegendInline(items: series),
          SizedBox(height: 10.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.maxWidth;
              // Each group needs room for its bars/label plus a 10.w gap;
              // otherwise the chart scrolls horizontally.
              final slot = math.max(_groupWidth, _maxLabelWidth) + 10.w;
              final needed = slot * groups.length;
              final scrollable = needed > available;
              final chart = SizedBox(
                width: scrollable ? needed : available,
                height: chartHeight.h,
                child: BarChart(
              BarChartData(
                maxY: _maxY,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.border.withOpacity(.4),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34.w,
                      getTitlesWidget: (v, meta) {
                        if (v >= meta.max) return const SizedBox.shrink();
                        return Text(meta.formattedValue,
                            style: CardStyles.label(9));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26.h,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= groups.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            groups[i].label,
                            style: CardStyles.label(9),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(enabled: false),
                barGroups: [
                  for (int i = 0; i < groups.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 3.w,
                      barRods: [
                        for (int s = 0;
                            s < groups[i].values.length;
                            s++)
                          BarChartRodData(
                            toY: groups[i].values[s],
                            color: s < series.length
                                ? (series[s].color ?? AppColors.primary)
                                : AppColors.primary,
                            width: barWidth.w,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                      ],
                    ),
                ],
              ),
                ),
              );
              if (!scrollable) return chart;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: chart,
              );
            },
          ),
        ],
      ),
    );
  }
}
