/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_chart_extras.dart
/// Purpose: Shared helpers for the Adding Widget "Chart & Graph" cards —
///          `ChartViewDetails`, `ChartRangeTabs`, `ChartCountBadge`,
///          `StackedChartData` and the axis number formatter.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026 - Added with the Figma "Chart & Graph" tab pass
///          (Settings > Home Layout > Adding Widget, iPad Horizontal View).

// These pieces repeat across the Figma chart cards but are not chart-type
// specific, so they live here instead of being duplicated in 92..97.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';

/// One bar made of stacked segments, one value per series.
///
/// Used by `StackedBarChartCard` (92) and `HorizontalStackedBarChartCard`
/// (93). The series definitions (label + color) are passed separately so
/// several bars share one legend, exactly like `GroupedBarData` (29) does for
/// grouped bars.
class StackedChartData {
  final String label;
  final List<double> values;

  const StackedChartData({required this.label, required this.values});

  double get total => values.fold<double>(0, (double sum, double v) => sum + v);
}

/// Function Name: [formatAxisValue]
///
/// Purpose: Format an axis tick the way the Figma charts show it — `00`,
///          `15k`, `30k` rather than `0`, `15000`, `30000`.
///
/// Parameters:
/// - [value]: The raw axis value.
///
/// Returns: [String] the label to draw on the axis.
String formatAxisValue(double value) {
  if (value == 0) return '00';
  if (value.abs() >= 1000000) {
    final double m = value / 1000000;
    return '${m == m.roundToDouble() ? m.toInt() : m.toStringAsFixed(1)}m';
  }
  if (value.abs() >= 1000) {
    final double k = value / 1000;
    return '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
  }
  return value.toInt().toString();
}

/// The "View details" link shown at the bottom of most Figma chart cards.
class ChartViewDetails extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final AlignmentGeometry alignment;

  const ChartViewDetails({
    super.key,
    required this.text,
    this.onTap,
    this.alignment = AlignmentDirectional.centerStart,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Text(
            text,
            style: CardStyles.label(10).copyWith(
              color: AppColors.secondaryText,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

/// The `1 Days Ago | 7 days | 30 days` range row from the Figma chart headers.
///
/// Purely presentational: the caller owns [selectedIndex] and reacts to
/// [onSelected], so the card stays stateless.
class ChartRangeTabs extends StatelessWidget {
  final List<String> ranges;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const ChartRangeTabs({
    super.key,
    required this.ranges,
    this.selectedIndex = 0,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 4.h,
      children: <Widget>[
        for (int i = 0; i < ranges.length; i++)
          InkWell(
            onTap: onSelected == null ? null : () => onSelected!(i),
            child: Text(
              ranges[i],
              style: i == selectedIndex
                  ? CardStyles.title(10).copyWith(color: AppColors.primary)
                  : CardStyles.label(10),
            ),
          ),
      ],
    );
  }
}

/// The small dark count badge in the "Base Line Chart" header (Figma: `200`).
class ChartCountBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const ChartCountBadge({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color ?? AppColors.greyBack,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(text, style: CardStyles.title(11)),
    );
  }
}

/// Function Name: [defaultChartSeriesColors]
///
/// Purpose: The Figma palette used when a chart's series do not carry their
///          own colors — yellow first, then the neutral greys and the status
///          colors, so every new chart card looks like the rest of the app.
///
/// Returns: [List<Color>] colors to cycle through, longest-lived first.
List<Color> defaultChartSeriesColors() => <Color>[
      AppColors.primary,
      AppColors.grey,
      AppColors.totalBlack,
      AppColors.lightGrey,
      AppColors.green,
      AppColors.red,
    ];

/// Function Name: [resolveSeriesColor]
///
/// Purpose: Pick the color for series [index], preferring an explicit
///          [ChartData.color] and falling back to [defaultChartSeriesColors].
///
/// Parameters:
/// - [series]: The chart's series definitions.
/// - [index]: Which series to resolve.
///
/// Returns: [Color] the color to paint that series with.
Color resolveSeriesColor(List<ChartData> series, int index) {
  if (index < series.length && series[index].color != null) {
    return series[index].color!;
  }
  final List<Color> palette = defaultChartSeriesColors();
  return palette[index % palette.length];
}
