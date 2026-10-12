// ******************* FILE INFO *******************
// File Name: DashBoard_widget.dart
// Description: Admin dashboard (mobile) chart widgets — CustomVerticalBarChartWidget
//              and CustomHorizontalBarChartWidget. (Unused graphic-package demo
//              screens removed; file reduced from 2813 → ~1100 LOC.)
// Module: services_management_module / presentation / s11_admin_dashboard_mobile / ui / widgets
// *************************************************

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphic/graphic.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


// ============================================
// 1. VERTICAL BAR CHART WIDGET
// ============================================

// ✅ Change from StatelessWidget to StatefulWidget
part 'DashBoard_widget_part2.dart';
part 'DashBoard_widget_part3.dart';

class CustomVerticalBarChartWidget extends StatefulWidget {
  final String title;
  final String? iconAsset;
  final List<String> labels;
  final List<double> values;
  final Widget? headerWidget;
  final double? maxY;
  final double? height;
  final double? width;
  final double? barWidth;
  final Color? barColor;
  final Color? iconBackgroundColor;
  final Color? backgroundColor;
  final BarChartAlignment barAlignment;
  final double groupsSpace;
  final bool showGrid;
  final bool lightMode;
  final bool showAllMonths;

  // ── Optional second series ──────────────────────────────────────────────
  // ✅ NEW (bug report p9): lets this widget back the Monthly Comparison chart,
  // which plots Canceled *and* Rejected. Leave these null and the widget
  // behaves exactly as before — single series, and the legend row below is not
  // built at all, so it costs zero height.

  /// Second data series, plotted beside [values] in each slot.
  /// Must be the same length as [values]. Null or empty = single-series mode.
  final List<double>? secondaryValues;

  /// Bar colour for [secondaryValues]. Defaults to AppColors.red.
  final Color? secondaryBarColor;

  /// Legend caption for [values]. Only rendered when a second series is given.
  final String? legendLabel;

  /// Legend caption for [secondaryValues].
  final String? secondaryLegendLabel;

  /// True when a usable second series was supplied.
  bool get hasSecondarySeries =>
      secondaryValues != null && secondaryValues!.isNotEmpty;

  const CustomVerticalBarChartWidget({
    Key? key,
    required this.title,
    required this.labels,
    required this.values,
    this.iconAsset,
    this.headerWidget,
    this.maxY,
    this.height,
    this.width,
    this.barWidth,
    this.barColor,
    this.iconBackgroundColor,
    this.backgroundColor,
    this.barAlignment = BarChartAlignment.spaceAround,
    this.groupsSpace = 30,
    this.showGrid = true,
    this.showAllMonths = false,
    required this.lightMode,
    this.secondaryValues,
    this.secondaryBarColor,
    this.legendLabel,
    this.secondaryLegendLabel,
  }) : super(key: key);

  @override
  State<CustomVerticalBarChartWidget> createState() =>
      _CustomVerticalBarChartWidgetState();
}
