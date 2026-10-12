/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_chart_cards_extra.dart
/// Purpose: All eleven cards on the Adding Widget "Chart & Graph" tab.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
///
/// Source of truth: Figma file BuJXLizpGcK5eHVBqQomXc, page "ROLE MANAGEMENT",
/// Settings > Home Layout > Adding Widget, iPad Horizontal View, node
/// 5356:111536.
///
/// GEOMETRY — read this before changing a width or a height.
///
/// The Figma frame is 1024 wide with an 80 sidebar; the chart column runs
/// x=110 to x=795, so the usable width is 685 with a 15 gutter. Every card is
/// exactly 200 tall and its width is one of 125 / 265 / 405 / 545. The five
/// rows each add up to 685 exactly:
///
///   1. Horizontal bar chart 265 + Base Line Chart 405
///   2. Table chart 405 + Bar chart 265
///   3. Stacked 265 + Grouped 265 + Pie 125
///   4. Horizontal Stacked 405 + Radial 265
///   5. Bar Chart 545 + Donut 125
///
/// The picker lays these out in a Wrap, so the row breaks fall out of the
/// widths plus the declaration order in `HomeComponents` — which is why that
/// enum lists the charts in the reading order above. Reordering the enum or
/// changing a width WILL change the rows.
///
/// Every card is a zero-field `const` widget so `HomeComponents.widget()` can
/// construct it directly.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/28-custom_horizontal_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/29-custom_grouped_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/91-custom_chart_extras.dart';
import 'package:knowticed_plus/core/custom/92-custom_stacked_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/93-custom_horizontal_stacked_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/94-custom_base_line_chart_card.dart';
import 'package:knowticed_plus/core/custom/95-custom_pie_chart_card.dart';
import 'package:knowticed_plus/core/custom/96-custom_radial_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/97-custom_table_chart_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// One grid column — Pie Chart and Donut Chart.
const double kHomeChartNarrowWidth = 125;

/// Two grid columns.
const double kHomeChartWidth = 265;

/// Three grid columns.
const double kHomeChartWideWidth = 405;

/// Four grid columns — the wide Bar Chart.
const double kHomeChartFullWidth = 545;

/// Every chart card in the Figma frame is exactly this tall.
const double kHomeChartHeight = 200;

/// Figma's chart cards use 10 padding, not the 16 [ChartCard] defaults to.
EdgeInsets get _cardPadding => EdgeInsets.all(10.r);

/// The `1 Days Ago | 7 days | 30 days` row the Figma cards carry.
///
/// The picker only previews a card, so the range is fixed at the first entry
/// and taps are ignored; wiring it to a real query belongs with the data.
class _RangeRow extends StatelessWidget {
  const _RangeRow();

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return ChartRangeTabs(
      ranges: <String>['1 ${l.daysAgo}', '7 ${l.days}', '30 ${l.days}'],
    );
  }
}

/// Locks a chart card to its Figma cell: exact width, exact 200 height.
class _ChartCell extends StatelessWidget {
  final double width;
  final Widget child;

  const _ChartCell({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      height: kHomeChartHeight.h,
      child: child,
    );
  }
}

// ── Row 1 ────────────────────────────────────────────────────────────────────

/// Figma "Horizontal bar chart" (265). Replaces the old Services Offered card,
/// which carried a services-specific title the design does not use.
class HomeHorizontalBarChart extends StatelessWidget {
  const HomeHorizontalBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartWidth,
      child: HorizontalBarChartCard(
        title: l.horizontalBarChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        header: const _RangeRow(),
        footer: ChartViewDetails(text: l.viewDetails),
        // Figma's rows sit 28 apart with no x-axis underneath them.
        showAxis: false,
        rowSpacing: 0,
        labelFontSize: 10,
        barHeight: 8,
        bars: <ChartData>[
          ChartData(label: '${l.barLabel} 1', value: 79342),
          ChartData(label: '${l.barLabel} 2', value: 68453),
          ChartData(label: '${l.barLabel} 3', value: 60125),
          ChartData(label: '${l.barLabel} 4', value: 32612),
        ],
      ),
    );
  }
}

/// Figma "Base Line Chart" (405): value bars over capacity tracks with a
/// dashed reference line and a count badge in the header.
class HomeBaseLineChart extends StatelessWidget {
  const HomeBaseLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartWideWidth,
      child: BaseLineChartCard(
        title: l.baseLineChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        expandChild: true,
        trailing: const ChartCountBadge(text: '200'),
        baseline: 120,
        chartHeight: 130,
        barWidth: 10,
        bars: const <ChartData>[
          ChartData(label: 'Win', value: 180),
          ChartData(label: 'Mac', value: 150),
          ChartData(label: 'Web', value: 95),
          ChartData(label: 'iOS', value: 200),
          ChartData(label: 'And', value: 130),
          ChartData(label: 'Win', value: 175),
        ],
      ),
    );
  }
}

// ── Row 2 ────────────────────────────────────────────────────────────────────

/// Figma "Table chart" (405): the one Chart & Graph entry that is a table.
///
/// The range row sits in the header line rather than on its own row — at 200
/// tall there is only room for one of the two, and Figma's four data rows are
/// the part that carries the information.
class HomeTableChart extends StatelessWidget {
  const HomeTableChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    // Status tint follows the app's status colors so the column reads at a
    // glance rather than as four identical grey words.
    final List<TableChartCell> statuses = <TableChartCell>[
      TableChartCell(text: l.pending, textColor: AppColors.statusPending),
      TableChartCell(text: l.approved, textColor: AppColors.statusApproved),
      TableChartCell(text: l.canceled, textColor: AppColors.red),
      TableChartCell(text: l.rejected, textColor: AppColors.red),
    ];

    return _ChartCell(
      width: kHomeChartWideWidth,
      child: TableChartCard(
        title: l.tableChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        trailing: const _RangeRow(),
        rowSpacing: 1,
        columns: <String>[
          l.service,
          l.serviceRequester,
          l.serviceProvider,
          l.status,
        ],
        columnFlex: const <int>[3, 4, 4, 3],
        rows: <TableChartRowData>[
          for (final TableChartCell status in statuses)
            TableChartRowData(
              cells: <TableChartCell>[
                TableChartCell(text: l.serviceName),
                TableChartCell(
                  text: 'Ahmed Abd el Rahman',
                  subtitle: l.department,
                ),
                TableChartCell(
                  text: 'Ahmed Abd el Rahman',
                  subtitle: l.department,
                ),
                status,
              ],
            ),
        ],
      ),
    );
  }
}

/// Figma "Bar chart" (265). Replaces the old Number Of Services card, which
/// carried a services-specific title the design does not use.
class HomeBarChart extends StatelessWidget {
  const HomeBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartWidth,
      child: BarChartCard(
        title: l.barChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        expandChild: true,
        footer: ChartViewDetails(text: l.viewDetails),
        chartHeight: 118,
        barWidth: 12,
        bars: const <ChartData>[
          ChartData(label: 'Win', value: 18000),
          ChartData(label: 'Mac', value: 27000),
          ChartData(label: 'Web', value: 22000),
          ChartData(label: 'iOS', value: 15000),
          ChartData(label: 'And', value: 19000),
          ChartData(label: 'Win', value: 14000),
        ],
      ),
    );
  }
}

// ── Row 3 ────────────────────────────────────────────────────────────────────

/// Figma "Stacked Bar Chart" (265).
class HomeStackedBarChart extends StatelessWidget {
  const HomeStackedBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartWidth,
      child: StackedBarChartCard(
        title: l.stackedBarChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        chartHeight: 96,
        barWidth: 16,
        footer: ChartViewDetails(text: l.viewDetails),
        series: <ChartData>[
          ChartData(label: l.approved, value: 0, color: AppColors.primary),
          ChartData(label: l.rejected, value: 0, color: AppColors.grey),
          ChartData(label: l.pending, value: 0, color: AppColors.lightGrey),
        ],
        bars: const <StackedChartData>[
          StackedChartData(label: 'Win', values: <double>[12000, 8000, 4000]),
          StackedChartData(label: 'Mac', values: <double>[9000, 7000, 5000]),
          StackedChartData(label: 'Web', values: <double>[11000, 6000, 3000]),
        ],
      ),
    );
  }
}

/// Figma "Grouped Bar Chart" (265) — built on the grouped card that already
/// existed in core (29); only the picker entry was missing.
class HomeGroupedBarChart extends StatelessWidget {
  const HomeGroupedBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartWidth,
      child: GroupedBarChartCard(
        title: l.groupedBarChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        chartHeight: 112,
        barWidth: 6,
        series: <ChartData>[
          ChartData(label: '${l.label} 1', value: 0, color: AppColors.primary),
          ChartData(label: '${l.label} 2', value: 0, color: AppColors.grey),
          ChartData(
              label: '${l.label} 3', value: 0, color: AppColors.lightGrey),
          ChartData(
              label: '${l.label} 4', value: 0, color: AppColors.totalBlack),
        ],
        groups: const <GroupedBarData>[
          GroupedBarData(
              label: 'Prod', values: <double>[24000, 18000, 12000, 8000]),
          GroupedBarData(
              label: 'Mai', values: <double>[21000, 16000, 11000, 7000]),
          GroupedBarData(
              label: 'Dev', values: <double>[26000, 19000, 13000, 9000]),
        ],
      ),
    );
  }
}

/// Figma "Pie Chart" (125) — the solid pie, distinct from the donut in row 5.
class HomePieChart extends StatelessWidget {
  const HomePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartNarrowWidth,
      child: PieChartCard(
        title: l.pieChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        // One grid column leaves ~105 of usable width inside the padding.
        chartSize: 80,
        sections: <ChartData>[
          ChartData(label: l.approved, value: 60, color: AppColors.primary),
          ChartData(label: l.rejected, value: 25, color: AppColors.grey),
          ChartData(label: l.pending, value: 15, color: AppColors.lightGrey),
        ],
      ),
    );
  }
}

// ── Row 4 ────────────────────────────────────────────────────────────────────

/// Figma "Horizontal Stacked Bar Chart" (405).
class HomeHorizontalStackedBarChart extends StatelessWidget {
  const HomeHorizontalStackedBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartWideWidth,
      child: HorizontalStackedBarChartCard(
        title: l.horizontalStackedBarChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        trailing: ChartViewDetails(text: l.viewDetails),
        // Figma's rows sit 30 apart.
        rowSpacing: 1,
        labelFontSize: 10,
        barHeight: 8,
        series: <ChartData>[
          ChartData(label: '${l.label} 1', value: 0, color: AppColors.primary),
          ChartData(
              label: '${l.label} 2',
              value: 0,
              color: AppColors.secondaryPrimary),
          ChartData(label: '${l.label} 3', value: 0, color: AppColors.grey),
          ChartData(
              label: '${l.label} 4', value: 0, color: AppColors.lightGrey),
        ],
        bars: <StackedChartData>[
          for (int i = 1; i <= 4; i++)
            StackedChartData(
              label: '${l.barLabel} $i',
              values: const <double>[34000, 21000, 15000, 9342],
            ),
        ],
      ),
    );
  }
}

/// Figma "Radial Bar Chart" (265): concentric arcs with the legend on the left.
class HomeRadialBarChart extends StatelessWidget {
  const HomeRadialBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartWidth,
      child: RadialBarChartCard(
        title: l.radialBarChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        chartSize: 120,
        ringWidth: 7,
        ringGap: 4,
        bars: <ChartData>[
          ChartData(label: 'Line 1 ${l.label}', value: 95),
          ChartData(label: 'Line 2 ${l.label}', value: 78),
          ChartData(label: 'Line 3 ${l.label}', value: 64),
          ChartData(label: 'Line 4 ${l.label}', value: 47),
          ChartData(label: 'Line 5 ${l.label}', value: 30),
        ],
      ),
    );
  }
}

// ── Row 5 ────────────────────────────────────────────────────────────────────

/// Figma "Bar Chart" (545): the wide bar card with a "View details" link.
class HomeBarChartTrend extends StatelessWidget {
  const HomeBarChartTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartFullWidth,
      child: BarChartCard(
        title: l.barChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        expandChild: true,
        header: const _RangeRow(),
        trailing: ChartViewDetails(text: l.viewDetails),
        chartHeight: 108,
        barWidth: 18,
        bars: const <ChartData>[
          ChartData(label: 'Windows', value: 18000),
          ChartData(label: 'Mac', value: 27000),
          ChartData(label: 'Web', value: 22000),
          ChartData(label: 'iOS', value: 15000),
          ChartData(label: 'Android pho', value: 19000),
          ChartData(label: 'Windows ph', value: 14000),
        ],
      ),
    );
  }
}

/// Figma "Donut Chart" (125) — built on the donut card that already existed in
/// core (27); only the picker entry was missing.
class HomeDonutChart extends StatelessWidget {
  const HomeDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _ChartCell(
      width: kHomeChartNarrowWidth,
      child: DonutChartCard(
        title: l.donutChart,
        padding: _cardPadding,
        height: kHomeChartHeight.h,
        // One grid column: the ring shrinks and the legend stacks underneath,
        // which is also how Figma draws this card.
        chartSize: 78,
        ringWidth: 12,
        showLegend: true,
        legendBelow: true,
        showPercentages: false,
        sections: <ChartData>[
          ChartData(label: l.approved, value: 60, color: AppColors.primary),
          ChartData(label: l.rejected, value: 25, color: AppColors.grey),
          ChartData(label: l.pending, value: 15, color: AppColors.lightGrey),
        ],
      ),
    );
  }
}
