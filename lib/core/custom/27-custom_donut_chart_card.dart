/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: donut_chart_card.dart
/// Purpose: Declares `DonutChartCard`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - (Time Tracker UI fix round 1) `legendMaxLines`
///          (default 1 = unchanged) forwarded to the side legend rows.
/// Updated: 13/10/2026 - opt-in `ringAtEnd` (ring at the card's end edge).

// Figma: donut charts — "Demands", "Order Fulfillment Status".
// fl_chart PieChart with center total + legend with amounts.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Rewrite the ASCII digits in [value] as Arabic-Indic numerals (٠١٢…) when
/// [arabic] is true, so the ring percentages and legend amounts read in Arabic
/// figures under an RTL/Arabic locale. Non-digit characters (like `%`) are kept.
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

/// Donut chart card: ring chart, center total, legend rows with amounts.
///
/// ```dart
/// DonutChartCard(
///   title: 'Demands',
///   centerValue: '9K',
///   centerLabel: 'Total Product',
///   sections: [
///     ChartData(label: 'Assets', value: 513, color: AppColors.primary),
///     ChartData(label: 'Consumables', value: 513, color: AppColors.text),
///   ],
/// )
/// ```
class DonutChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> sections;
  final String? centerValue;
  final String? centerLabel;
  final Widget? trailing;
  final double chartSize;
  final double ringWidth;
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

  /// Show the legend (name + amount) next to the chart.
  final bool showLegend;

  /// Stack the legend UNDER the ring instead of beside it, as a compact
  /// dot + name row. Needed by the narrow one-column donut on the Figma
  /// Chart & Graph tab, where a side-by-side legend has no room. Defaults to
  /// false so every existing caller keeps the original side layout.
  final bool legendBelow;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  /// Show the percentage label on each ring segment (Figma: "40%", "25%").
  final bool showPercentages;

  /// Font size of the on-segment percentage label. Kept small so even a
  /// four-character label ("100%") stays inside the ring thickness.
  final double percentageFontSize;

  /// ADDED 29/9/2026 (form bug report p.5). In a very WIDE card (the Form
  /// Builder Results page) the side legend stretched across the whole row,
  /// so each amount sat at the far end, right beside the ring and a long way
  /// from its label. When true the legend takes only half of the free width,
  /// keeping every amount close to the name it belongs to. Off by default —
  /// the narrow dashboard cards keep their original layout.
  final bool compactLegend;

  /// ADDED 9/10/2026 (Time Tracker UI fix round 1): lines each side-legend
  /// name may use. Defaults to 1 (single line + "…", every existing caller);
  /// the Time Tracker dashboard passes 2 so "Work Locations" / long location
  /// names read in full in the narrow iPad-portrait cards.
  final int? legendMaxLines;

  /// ADDED 13/10/2026 (Time Tracker owner review): beside a side legend,
  /// the ring sits at the card's END edge (only the card padding after it)
  /// with a 16 gap to the legend, so the legend names get the room. False
  /// keeps the historical 30 + 30 spacing.
  final bool ringAtEnd;

  const DonutChartCard({
    super.key,
    required this.title,
    required this.sections,
    this.centerValue,
    this.centerLabel,
    this.trailing,
    this.chartSize = 130,
    this.ringWidth = 26,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.showLegend = true,
    this.legendBelow = false,
    this.dotColor,
    this.dotIcon,
    this.showPercentages = true,
    this.percentageFontSize = 7,
    this.compactLegend = false,
    this.legendMaxLines = 1,
    this.ringAtEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double total =
        sections.fold<double>(0, (sum, s) => sum + s.value);

    final chart = SizedBox(
      width: chartSize.r,
      height: chartSize.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: (chartSize.r / 2) - ringWidth.r,
              sections: total > 0
                  ? [
                      for (final s in sections)
                        PieChartSectionData(
                          value: s.value,
                          color: s.color,
                          radius: ringWidth.r,
                          // Figma: white percentage label on each segment.
                          // Hidden on slivers too thin for the text to fit.
                          showTitle: showPercentages && (s.value / total) >= 0.03,
                          title: _localizeDigits(
                              '${(s.value / total * 100).round()}%', isRtl),
                          // Small, tight line box so the label fits ringWidth.
                          titleStyle: StyleText.fontSize10Weight500.copyWith(
                            color: AppColors.white,
                            height: 1,
                            fontWeight: FontWeight.w500,
                          ),
                          titlePositionPercentageOffset: 0.5,
                        ),
                    ]
                  : [
                      // Empty state (no data yet): a single full, un-labelled
                      // grey ring, so the chart reads as an empty donut instead
                      // of fl_chart's degenerate zero-value slices (which paint
                      // as stray crossing lines).
                      PieChartSectionData(
                        value: 1,
                        color: AppColors.secondaryText.withOpacity(0.15),
                        radius: ringWidth.r,
                        showTitle: false,
                      ),
                    ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (centerValue != null)
                Text(centerValue!, style: CardStyles.title(18)),
              if (centerLabel != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    centerLabel!,
                    style: CardStyles.label(9),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    // ADDED 12/9/2026 — THE LEGEND KEEPS ITS SHAPE WHEN THERE IS NO DATA.
    //
    // With no sections the legend column rendered NOTHING, so the card showed
    // an empty grey ring beside a blank half — the Department card on
    // Submission Details before any document has been viewed. The ring already
    // has a deliberate empty state (the flat grey ring above); the legend
    // needed one too, so it reads "Department 0" the way the card next to it
    // reads "Views 0 / Downloads 0" rather than looking like a rendering
    // failure.
    final List<ChartData> legendSections = sections.isNotEmpty
        ? sections
        : <ChartData>[
            ChartData(
              label: title,
              value: 0,
              color: AppColors.secondaryText.withOpacity(0.3),
            ),
          ];

    // CHANGED 12/9/2026 — on a phone the ring sits the same distance from the
    // right edge as the legend does from the left. The row used to add 30.w
    // AFTER the chart on top of [ChartCard]'s own 16 padding, so the right
    // margin was ~46 against the legend's 16 and the whole card read as
    // pushed left. The gap BETWEEN the legend and the ring is untouched — that
    // one is separating two things, not padding an edge.
    final bool symmetricEdges = ContextExtension(context).isPhone;

    return ChartCard(
      title: title,
      trailing: trailing,
      width: width,
      height: height,
      padding: padding,
      expandChild: expandChild,
      dotColor: dotColor,
      dotIcon: dotIcon,
      child: !showLegend
          ? Center(child: chart)
          : legendBelow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: chart),
                    SizedBox(height: 10.h),
                    ChartLegendInline(
                      items: [
                        for (final s in legendSections)
                          ChartData(
                            label: s.label,
                            value: s.value,
                            color: s.color ?? AppColors.grey,
                          ),
                      ],
                    ),
                  ],
                )
              : Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final s in legendSections)
                        ChartLegendRow(
                          name: s.label,
                          amount: _localizeDigits(
                              s.value.toInt().toString(), isRtl),
                          color: s.color ?? AppColors.grey,
                          maxLines: legendMaxLines,
                        ),
                    ],
                  ),
                ),
                // [compactLegend]: an equal empty share after the legend, so
                // the amounts stay beside their labels in a wide card.
                if (compactLegend) const Expanded(child: SizedBox.shrink()),
                // Gap between the legend text and the donut. The matching space
                // on the far side is the card's own padding on a phone — see
                // [symmetricEdges].
                SizedBox(width: ringAtEnd ? 16.w : 30.w),
                chart,
                if (!symmetricEdges && !ringAtEnd) SizedBox(width: 30.w),
              ],
            ),
    );
  }
}
