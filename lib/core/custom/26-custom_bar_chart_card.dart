/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: bar_chart_card.dart
/// Purpose: Declares `BarChartCard`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Figma: vertical bar charts — "Stocks Overview", "Product Consumption",
// "Products Allocated". Built with fl_chart.
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Rewrite the ASCII digits in [value] as Arabic-Indic numerals (٠١٢…) when
/// [arabic] is true, leaving everything else untouched. Used so the Y-axis
/// labels and value tooltips read in Arabic figures under an RTL/Arabic locale.
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

/// Vertical bar chart card with value labels above the bars.
///
/// ```dart
/// BarChartCard(
///   title: 'Products Allocated',
///   trailing: ChartTabPill(text: 'Consumables'),
///   bars: const [
///     ChartData(label: 'Marketing', value: 320),
///     ChartData(label: 'HR', value: 410),
///   ],
/// )
/// ```
class BarChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> bars;
  final Widget? trailing;

  /// Anything drawn between the header and the plot — the Figma charts put
  /// their `1 Days Ago | 7 days | 30 days` range row here.
  final Widget? header;

  /// Anything drawn under the plot — usually a "View details" link.
  final Widget? footer;

  /// Max Y axis value; defaults to highest bar rounded up.
  final double? maxY;
  final double chartHeight;
  final double barWidth;

  /// Default bar color when a [ChartData.color] is null.
  final Color? barColor;
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

  const BarChartCard({
    super.key,
    required this.title,
    required this.bars,
    this.trailing,
    this.header,
    this.footer,
    this.maxY,
    this.chartHeight = 200,
    this.barWidth = 14,
    this.barColor,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.dotColor,
    this.dotIcon,
  });

  /// Highest bar value.
  double get _rawMax {
    double m = 0;
    for (final b in bars) {
      if (b.value > m) m = b.value;
    }
    return m;
  }

  /// Round [rough] UP to a "nice" whole-number step (1, 2, 5 × 10ⁿ), so the
  /// Y axis never shows fractional ticks like 0.5 / 1.5.
  double _niceStep(double rough) {
    if (rough <= 1) return 1;
    final exp = (math.log(rough) / math.ln10).floor();
    final pow10 = math.pow(10, exp).toDouble();
    final frac = rough / pow10; // 1..10
    final double niceFrac = frac <= 1
        ? 1
        : frac <= 2
            ? 2
            : frac <= 5
                ? 5
                : 10;
    return niceFrac * pow10;
  }

  /// Whole-number gap between Y-axis gridlines/labels.
  ///
  /// Derived from the DATA (the tallest bar), NOT the caller's [maxY]: the axis
  /// always shows exactly five equally-spaced whole-number labels
  /// (0, s, 2s, 3s, 4s). So no-data → 0,1,2,3,4, and there are never fractional
  /// or unevenly-spaced ticks (like the old 0,5,10,12). [maxY] is intentionally
  /// ignored for the scale.
  double get _step {
    final s = _niceStep(_rawMax / 4);
    return s < 1 ? 1 : s;
  }

  /// Top of the LABEL LADDER: exactly four steps above zero, so the axis is
  /// always five equal whole-number labels and the tallest bar always fits
  /// (step ≥ rawMax/4 ⇒ 4·step ≥ rawMax).
  double get _axisTop => _step * 4;

  /// Top of the PLOT — the label ladder plus a sliver of headroom.
  ///
  /// FIXED 22/9/2026 — "bar and top bar number is in very top and this is
  /// false".
  ///
  /// The value above each bar is drawn as an fl_chart tooltip, which is placed
  /// ABOVE the rod's top. When the tallest bar lands exactly on the ceiling
  /// there is nowhere for it to go, so it rendered at the very top edge of the
  /// card — running into the Views/Downloads control sitting above the plot.
  ///
  /// That is not a rare case, it is the COMMON one: `_step` is
  /// `niceStep(rawMax / 4)`, so any nice max (4, 8, 20, 40 …) gives
  /// `4·step == rawMax` exactly and the bar touches the top. The chart in the
  /// report is the plainest example — one bar of 4, step 1, ceiling 4.
  ///
  /// The ladder is untouched: labels and gridlines still run 0…4·step at whole
  /// numbers. Only the plot ceiling moves, by a fraction of one step, which is
  /// the space the number needs. A tick at 5·step would fall outside this and
  /// is dropped by the guard in the Y-axis builder.
  double get _maxY => _axisTop + _step * 0.4;

  /// Widest bar label measured at the label text style.
  double get _maxLabelWidth {
    double maxW = 0;
    final style = CardStyles.label(9);
    for (final b in bars) {
      final tp = TextPainter(
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
    final defaultColor = barColor ?? AppColors.primary;

    // CHANGED 12/9/2026 — ON PHONES THE TRAILING CONTROL GETS ITS OWN ROW.
    //
    // [trailing] is the chart's filter — the Views/Downloads or
    // Published/Removed segmented control. [ChartCard] puts it on the title
    // row, which works at tablet and desktop width but not on a phone: the
    // title is `Expanded` with `TextOverflow.ellipsis`, so the control eats
    // most of the row and "Number of Downloads" renders as "Number of Dow…" —
    // the chart no longer says what it is showing, which is precisely what the
    // filter is switching between.
    //
    // So on a phone it moves under the header, aligned to the trailing edge
    // (right in LTR, left in Arabic), and the title gets the full width.
    // Tablet and desktop are untouched.
    //
    // Guarded by [height] / [expandChild]: a card pinned to a fixed height that
    // does NOT let the plot absorb slack has no room to give the extra row, and
    // would answer a clipped title with a striped overflow. Those keep the
    // single-row header (the home dashboard's compact cards are the only ones
    // in that shape today).
    final bool trailingOnOwnRow = ContextExtension(context).isPhone &&
        trailing != null &&
        (height == null || expandChild);


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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingOnOwnRow) ...[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: trailing!,
            ),
            SizedBox(height: 8.h),
          ],
          if (header != null) ...[header!, SizedBox(height: 8.h)],
          LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;
          // Each bar needs room for its label plus a 10.w gap; if that
          // doesn't fit, the chart scrolls horizontally instead of
          // overlapping the labels.
          final slot = math.max(barWidth.w, _maxLabelWidth) + 10.w;
          final needed = slot * bars.length;
          final scrollable = needed > available;

          // In RTL (Arabic) the value axis belongs on the RIGHT, not the left.
          final bool isRtl = Directionality.of(context) == TextDirection.rtl;
          final AxisTitles yAxisTitles = AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34.w,
              // Match the gridline spacing so labels sit on lines only,
              // and render whole numbers (no decimals).
              interval: _step,
              getTitlesWidget: (v, meta) {
                // Guard against a stray tick just past the top.
                if (v > meta.max + 0.0001) return const SizedBox.shrink();
                // FIXED 28/9/2026 (GRC bug report p32/p33): fl_chart always
                // adds a title at meta.max too. With the 0.4-step headroom
                // above the ladder that is 4.4 → rounded to a second "4",
                // drawn half-cut at the top edge of the plot. Only draw labels
                // that sit on a gridline.
                final double ticks = v / _step;
                if ((ticks - ticks.round()).abs() > 0.001) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _localizeDigits(v.round().toString(), isRtl),
                  style: CardStyles.label(9),
                );
              },
            ),
          );
          const AxisTitles hiddenAxis =
              AxisTitles(sideTitles: SideTitles(showTitles: false));

          // 13/10/2026 (owner N3): when the bars scroll, the value axis stays
          // FIXED beside them — [axisOnly] draws just the numbers (no bars,
          // no gridlines) and the scrolling chart hides its own axis.
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
              drawVerticalLine: false,
              // Whole-number spacing → no 0.5 / 1.5 gridlines.
              horizontalInterval: _step,
              getDrawingHorizontalLine: (v) => FlLine(
                color: AppColors.border.withOpacity(.4),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              // Value axis on the right in RTL (Arabic), on the left in LTR.
              leftTitles: showAxis && !isRtl ? yAxisTitles : hiddenAxis,
              rightTitles: showAxis && isRtl ? yAxisTitles : hiddenAxis,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26.h,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (axisOnly || i < 0 || i >= bars.length) return const SizedBox();
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
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.transparent,
                tooltipMargin: 2,
                tooltipPadding: EdgeInsets.zero,
                getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                  _localizeDigits(rod.toY.toInt().toString(), isRtl),
                  CardStyles.value(10),
                ),
              ),
            ),
            barGroups: [
              for (int i = 0; i < (axisOnly ? 0 : bars.length); i++)
                BarChartGroupData(
                  x: i,
                  // A zero bar shows no number: the "0"s floated over an empty
                  // baseline with no bar under them.
                  showingTooltipIndicators:
                      bars[i].value > 0 ? const [0] : const <int>[],
                  barRods: [
                    BarChartRodData(
                      toY: bars[i].value,
                      color: bars[i].color ?? defaultColor,
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
          final double axisWidth = 40.w;
          return Row(
            children: [
              chartOf(width: axisWidth, showAxis: true, axisOnly: true),
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
          if (footer != null) ...[SizedBox(height: 6.h), footer!],
        ],
      ),
    );
  }
}
