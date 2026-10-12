/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_base_line_chart_card.dart
/// Purpose: Declares `BaseLineChartCard`.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026 - Added with the Figma "Chart & Graph" tab pass.

// Figma: "Base Line Chart" — each column shows a light grey capacity track
// with the actual value drawn over it, and a single dashed baseline runs
// across the plot at the reference value. The header carries a count badge.
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/91-custom_chart_extras.dart';

/// Base line chart card: value bars over capacity tracks, plus a baseline.
///
/// ```dart
/// BaseLineChartCard(
///   title: 'Base Line Chart',
///   trailing: const ChartCountBadge(text: '200'),
///   baseline: 120,
///   bars: const [
///     ChartData(label: 'Win', value: 180),
///     ChartData(label: 'Mac', value: 90),
///   ],
/// )
/// ```
class BaseLineChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> bars;
  final Widget? trailing;

  /// Anything placed under the plot — usually a [ChartViewDetails] link.
  final Widget? footer;

  /// Y value the dashed reference line sits at. Defaults to the mean of
  /// [bars], which is what "base line" means on the Figma card.
  final double? baseline;

  /// Max Y axis value; defaults to the tallest bar rounded up.
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

  /// Bar color when a [ChartData.color] is null.
  final Color? barColor;

  /// Color of the capacity track drawn behind each bar.
  final Color? trackColor;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  const BaseLineChartCard({
    super.key,
    required this.title,
    required this.bars,
    this.trailing,
    this.footer,
    this.baseline,
    this.maxY,
    this.chartHeight = 200,
    this.barWidth = 14,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.barColor,
    this.trackColor,
    this.dotColor,
    this.dotIcon,
  });

  double get _maxY {
    if (maxY != null) return maxY!;
    double m = 0;
    for (final ChartData b in bars) {
      if (b.value > m) m = b.value;
    }
    return m == 0 ? 100 : m * 1.25;
  }

  /// The reference line's Y value: [baseline] when given, otherwise the mean
  /// of the plotted values.
  double get _baseline {
    if (baseline != null) return baseline!;
    if (bars.isEmpty) return 0;
    final double sum =
        bars.fold<double>(0, (double total, ChartData b) => total + b.value);
    return sum / bars.length;
  }

  /// Widest bar label measured at the label text style.
  double get _maxLabelWidth {
    double maxW = 0;
    final TextStyle style = CardStyles.label(9);
    for (final ChartData b in bars) {
      final TextPainter tp = TextPainter(
        text: TextSpan(text: b.label, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > maxW) maxW = tp.width;
    }
    return maxW;
  }

  @override
  Widget build(BuildContext context) {
    final Color fill = barColor ?? AppColors.primary;
    final Color track = trackColor ?? AppColors.background;
    final double base = _baseline;

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
                    // Only one gridline is drawn: the baseline itself. The
                    // capacity tracks already give the plot its structure, so
                    // a full grid would read as noise.
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: base > 0 ? base : null,
                      checkToShowHorizontalLine: (double v) =>
                          (v - base).abs() < 0.001,
                      getDrawingHorizontalLine: (double v) => FlLine(
                        color: AppColors.totalBlack.withOpacity(.35),
                        strokeWidth: 1,
                        dashArray: <int>[2, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
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
                              toY: bars[i].value,
                              color: bars[i].color ?? fill,
                              width: barWidth.w,
                              borderRadius: BorderRadius.circular(4.r),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: _maxY,
                                color: track,
                              ),
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
          if (footer != null) ...<Widget>[
            SizedBox(height: 6.h),
            footer!,
          ],
        ],
      ),
    );
  }
}
