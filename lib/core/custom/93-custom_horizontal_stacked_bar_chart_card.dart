/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_horizontal_stacked_bar_chart_card.dart
/// Purpose: Declares `HorizontalStackedBarChartCard`.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026 - Added with the Figma "Chart & Graph" tab pass.

// Figma: "Horizontal Stacked Bar Chart" — one full-width track per row split
// into colored segments, the row label above-left and the row total
// above-right, with an inline legend (Label 1 .. Label 4) under the rows.
//
// Hand-drawn with Containers rather than fl_chart, matching
// HorizontalBarChartCard (28) so both horizontal charts share a look.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/91-custom_chart_extras.dart';

/// Horizontal stacked bar chart card.
///
/// ```dart
/// HorizontalStackedBarChartCard(
///   title: 'Horizontal Stacked Bar Chart',
///   series: const [
///     ChartData(label: 'Label 1', value: 0),
///     ChartData(label: 'Label 2', value: 0),
///   ],
///   bars: const [
///     StackedChartData(label: 'Bar Label 1', values: [40000, 25000, 14342]),
///     StackedChartData(label: 'Bar Label 2', values: [38000, 27000, 14342]),
///   ],
/// )
/// ```
class HorizontalStackedBarChartCard extends StatelessWidget {
  final String title;

  /// Series definitions: one entry per segment, drawn start-to-end.
  final List<ChartData> series;

  /// One row per entry; `values` are read in the same order as [series].
  final List<StackedChartData> bars;

  final Widget? trailing;

  /// Anything placed under the legend — usually a [ChartViewDetails] link.
  final Widget? footer;

  /// Widest row total; defaults to the largest row so the longest bar fills
  /// the track. Pass a value to compare several cards on one scale.
  final double? maxX;
  final double barHeight;

  /// Vertical padding above and below each row. Figma's rows sit 30 apart;
  /// the default 7 is the roomier dashboard spacing.
  final double rowSpacing;

  /// Font size of the row label and its total.
  final double labelFontSize;
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

  /// Show each row's total to the right of its label.
  final bool showTotals;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  const HorizontalStackedBarChartCard({
    super.key,
    required this.title,
    required this.series,
    required this.bars,
    this.trailing,
    this.footer,
    this.maxX,
    this.barHeight = 14,
    this.rowSpacing = 7,
    this.labelFontSize = 12,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.showTotals = true,
    this.dotColor,
    this.dotIcon,
  });

  double get _maxX {
    if (maxX != null && maxX! > 0) return maxX!;
    double m = 0;
    for (final StackedChartData bar in bars) {
      if (bar.total > m) m = bar.total;
    }
    return m == 0 ? 100 : m;
  }

  /// Function Name: [_formatTotal]
  ///
  /// Purpose: Render a row total the way Figma shows it — grouped thousands
  ///          (`79,342`) rather than a raw double.
  ///
  /// Parameters:
  /// - [value]: The row total.
  ///
  /// Returns: [String] the formatted total.
  String _formatTotal(double value) {
    final String digits = value.round().abs().toString();
    final StringBuffer out = StringBuffer(value < 0 ? '-' : '');
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }

  @override
  Widget build(BuildContext context) {
    final double max = _maxX;

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
          for (final StackedChartData bar in bars)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rowSpacing.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          bar.label,
                          style: CardStyles.value(labelFontSize),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showTotals) ...<Widget>[
                        SizedBox(width: 8.w),
                        Text(
                          _formatTotal(bar.total),
                          style: CardStyles.value(labelFontSize),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Empty track, then the segments laid over it. The row is
                  // clipped so the segment corners follow the track's radius.
                  Stack(
                    children: <Widget>[
                      Container(
                        height: barHeight.h,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (bar.total / max).clamp(0.0, 1.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: SizedBox(
                            height: barHeight.h,
                            child: Row(
                              children: <Widget>[
                                for (int i = 0; i < bar.values.length; i++)
                                  if (bar.values[i] > 0)
                                    Expanded(
                                      // Flex must be an int, so the segment
                                      // weights are scaled up before rounding
                                      // — otherwise sub-unit segments vanish.
                                      flex: (bar.values[i] * 1000).round(),
                                      child: ColoredBox(
                                        color: resolveSeriesColor(series, i),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
