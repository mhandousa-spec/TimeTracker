/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_pie_chart_card.dart
/// Purpose: Declares `PieChartCard`.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026 - Added with the Figma "Chart & Graph" tab pass.

// Figma: "Pie Chart" — a solid pie (no center hole, unlike DonutChartCard 27)
// with the legend wrapped underneath as dot + label pairs.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/91-custom_chart_extras.dart';

/// Solid pie chart card.
///
/// `DonutChartCard` (27) is the ring version with a center total; use this one
/// when the Figma frame shows a filled pie.
///
/// ```dart
/// PieChartCard(
///   title: 'Pie Chart',
///   sections: const [
///     ChartData(label: 'Approved', value: 60),
///     ChartData(label: 'Rejected', value: 25),
///     ChartData(label: 'Pending', value: 15),
///   ],
/// )
/// ```
class PieChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> sections;
  final Widget? trailing;

  /// Anything placed under the legend — usually a [ChartViewDetails] link.
  final Widget? footer;

  final double chartSize;
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

  /// Show the legend under the pie.
  final bool showLegend;

  /// Draw each slice's share as a label on the slice.
  final bool showPercentages;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  const PieChartCard({
    super.key,
    required this.title,
    required this.sections,
    this.trailing,
    this.footer,
    this.chartSize = 130,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.showLegend = true,
    this.showPercentages = false,
    this.dotColor,
    this.dotIcon,
  });

  @override
  Widget build(BuildContext context) {
    final double total =
        sections.fold<double>(0, (double sum, ChartData s) => sum + s.value);

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
          Center(
            child: SizedBox(
              width: chartSize.r,
              height: chartSize.r,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  // A solid pie is a ring with no hole.
                  centerSpaceRadius: 0,
                  sections: <PieChartSectionData>[
                    for (int i = 0; i < sections.length; i++)
                      PieChartSectionData(
                        value: sections[i].value,
                        color: resolveSeriesColor(sections, i),
                        radius: chartSize.r / 2,
                        showTitle: showPercentages && total > 0,
                        title: total > 0
                            ? '${(sections[i].value / total * 100).round()}%'
                            : '',
                        titleStyle: CardStyles.title(10)
                            .copyWith(color: AppColors.white),
                        titlePositionPercentageOffset: 0.6,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (showLegend) ...<Widget>[
            SizedBox(height: 12.h),
            ChartLegendInline(
              items: <ChartData>[
                for (int i = 0; i < sections.length; i++)
                  ChartData(
                    label: sections[i].label,
                    value: sections[i].value,
                    color: resolveSeriesColor(sections, i),
                  ),
              ],
            ),
          ],
          if (footer != null) ...<Widget>[
            SizedBox(height: 6.h),
            footer!,
          ],
        ],
      ),
    );
  }
}
