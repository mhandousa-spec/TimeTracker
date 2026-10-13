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
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

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

  /// ADDED 13/10/2026 (Time Tracker owner) — the value axis shows whole
  /// numbers only (counts of days / people: no "0.5"). False = unchanged.
  final bool wholeNumbers;

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
    this.wholeNumbers = false,
  });

  double get _rawMax {
    double m = 0;
    for (final g in groups) {
      for (final v in g.values) {
        if (v > m) m = v;
      }
    }
    return m;
  }

  /// Whole-number gap between axis labels (1, 2, 5, 10, 20, 50 …), so four
  /// steps cover the tallest bar ([wholeNumbers] only).
  double get _wholeStep {
    final double target = _rawMax / 4;
    double step = 1;
    while (step < target) {
      final double next2 = step * 2, next5 = step * 5, next10 = step * 10;
      if (next2 >= target) return next2;
      if (next5 >= target) return next5;
      step = next10;
    }
    return step;
  }

  double get _maxY {
    if (maxY != null) return maxY!;
    if (wholeNumbers) return _wholeStep * 4 + _wholeStep * 0.4;
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
    // 13/10/2026 (owner R1): same rule as `BarChartCard` — on a phone the
    // trailing control gets its own row so the full title fits.
    final bool trailingOnOwnRow = ContextExtension(context).isPhone &&
        trailing != null &&
        (height == null || expandChild);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return ChartCard(
      title: title,
      trailing: trailingOnOwnRow ? null : trailing,
      width: width,
      height: height,
      padding: padding,
      expandChild: expandChild,
      dotColor: dotColor,
      dotIcon: dotIcon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailingOnOwnRow) ...[
            Align(alignment: AlignmentDirectional.centerEnd, child: trailing!),
            SizedBox(height: 8.h),
          ],
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
              // 13/10/2026 (owner N3): when the groups scroll, the value axis
              // stays FIXED beside them ([axisOnly]: numbers only).
              Widget chartOf({required double width, required bool showAxis, bool axisOnly = false}) => SizedBox(
                width: width,
                height: chartHeight.h,
                child: BarChart(
              BarChartData(
                maxY: _maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: !axisOnly,
                  horizontalInterval: wholeNumbers ? _wholeStep : null,
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
                      showTitles: showAxis,
                      reservedSize: 34.w,
                      interval: wholeNumbers ? _wholeStep : null,
                      getTitlesWidget: (v, meta) {
                        if (v >= meta.max) return const SizedBox.shrink();
                        if (wholeNumbers && v != v.roundToDouble()) return const SizedBox.shrink();
                        return Text(_localizeDigits(meta.formattedValue, isRtl),
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
                        if (axisOnly || i < 0 || i >= groups.length) {
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
                  for (int i = 0; i < (axisOnly ? 0 : groups.length); i++)
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
              if (!scrollable) return chartOf(width: available, showAxis: true);
              return Row(
                children: [
                  chartOf(width: 40.w, showAxis: true, axisOnly: true),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: chartOf(width: needed, showAxis: false),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Western → Arabic-Indic digits for the value axis in Arabic (as 26).
String _localizeDigits(String value, bool arabic) {
  if (!arabic) return value;
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var out = value;
  for (var i = 0; i < western.length; i++) {
    out = out.replaceAll(western[i], eastern[i]);
  }
  return out;
}
