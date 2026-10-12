/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_stacked_bar_chart_card.dart
/// Purpose: Declares `StackedBarChartCard`.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026 - Added with the Figma "Chart & Graph" tab pass.

// Figma: "Stacked Bar Chart" — vertical bars where each bar is split into
// segments (Approved / Rejected / Pending), a dashed horizontal grid, a
// `00 / 15k / 30k` y-axis and an inline legend under the plot.
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/91-custom_chart_extras.dart';

/// Stacked vertical bar chart card.
///
/// ```dart
/// StackedBarChartCard(
///   title: 'Stacked Bar Chart',
///   series: const [
///     ChartData(label: 'Approved', value: 0),
///     ChartData(label: 'Rejected', value: 0),
///   ],
///   bars: const [
///     StackedChartData(label: 'Win', values: [12000, 8000]),
///     StackedChartData(label: 'Mac', values: [9000, 6000]),
///   ],
///   footer: ChartViewDetails(text: 'View details'),
/// )
/// ```
class StackedBarChartCard extends StatelessWidget {
  final String title;

  /// Series definitions: one entry per stacked segment, bottom segment first.
  final List<ChartData> series;

  /// One entry per bar; `values` are read in the same order as [series].
  final List<StackedChartData> bars;

  final Widget? trailing;

  /// Anything placed under the plot — usually a [ChartViewDetails] link.
  final Widget? footer;

  /// Max Y axis value; defaults to the tallest stack rounded up.
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

  const StackedBarChartCard({
    super.key,
    required this.title,
    required this.series,
    required this.bars,
    this.trailing,
    this.footer,
    this.maxY,
    this.chartHeight = 200,
    this.barWidth = 18,
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
    for (final StackedChartData bar in bars) {
      if (bar.total > m) m = bar.total;
    }
    return m == 0 ? 100 : m * 1.2;
  }

  /// Widest bar label measured at the label text style, so bars never sit
  /// closer together than their labels can be drawn.
  double get _maxLabelWidth {
    double maxW = 0;
    final TextStyle style = CardStyles.label(9);
    for (final StackedChartData bar in bars) {
      final TextPainter tp = TextPainter(
        text: TextSpan(text: bar.label, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > maxW) maxW = tp.width;
    }
    return maxW;
  }

  /// Function Name: [_stackItems]
  ///
  /// Purpose: Turn one bar's values into fl_chart stack segments, each one
  ///          starting where the previous ended.
  ///
  /// Parameters:
  /// - [values]: The segment values for a single bar, bottom segment first.
  ///
  /// Returns: [List<BarChartRodStackItem>] segments in draw order.
  List<BarChartRodStackItem> _stackItems(List<double> values) {
    final List<BarChartRodStackItem> items = <BarChartRodStackItem>[];
    double from = 0;
    for (int i = 0; i < values.length; i++) {
      final double to = from + values[i];
      items.add(
        BarChartRodStackItem(from, to, resolveSeriesColor(series, i)),
      );
      from = to;
    }
    return items;
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
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double available = constraints.maxWidth;
              // Each bar needs room for its label plus a 10.w gap; if that
              // does not fit the plot scrolls horizontally rather than
              // overlapping the labels — same rule as BarChartCard (26).
              final double slot = math.max(barWidth.w, _maxLabelWidth) + 10.w;
              final double needed = slot * bars.length;
              final bool scrollable = needed > available;

              final Widget chart = SizedBox(
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
                      getDrawingHorizontalLine: (double v) => FlLine(
                        color: AppColors.border.withOpacity(.4),
                        strokeWidth: 1,
                        dashArray: <int>[4, 4],
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
                          getTitlesWidget: (double v, TitleMeta meta) {
                            if (v >= meta.max) return const SizedBox.shrink();
                            return Text(formatAxisValue(v),
                                style: CardStyles.label(9));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26.h,
                          getTitlesWidget: (double v, TitleMeta meta) {
                            final int i = v.toInt();
                            if (i < 0 || i >= bars.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                bars[i].label,
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
                    barGroups: <BarChartGroupData>[
                      for (int i = 0; i < bars.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: <BarChartRodData>[
                            BarChartRodData(
                              toY: bars[i].total,
                              width: barWidth.w,
                              borderRadius: BorderRadius.circular(4.r),
                              // The rod itself is transparent; the visible
                              // colors come from the stack items.
                              color: AppColors.transparent,
                              rodStackItems: _stackItems(bars[i].values),
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
          SizedBox(height: 10.h),
          ChartLegendInline(
            items: <ChartData>[
              for (int i = 0; i < series.length; i++)
                ChartData(
                  label: series[i].label,
                  value: series[i].value,
                  color: resolveSeriesColor(series, i),
                ),
            ],
          ),
          if (footer != null) ...<Widget>[
            SizedBox(height: 6.h),
            footer!,
          ],
        ],
      ),
    );
  }
}
