// ******************* FILE INFO *******************
// File Name: number_of_services
// Description: Number of services.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

class NumberOfServicesCard extends StatefulWidget {
  final Map<int, num> monthCounts;
  final Map<int, num> monthHours;
  final bool isLoading;
  final BarChartGroupData Function(int, double) buildBarGroups;
  final VoidCallback onFetchServiceCounts;
  final VoidCallback onFetchDurationHours;
  final Widget? loadingWidget;
  final String numberOfServicesText;
  final String noOfServiceText;
  final String totalHoursText;
  final Color? primaryColor;
  final Color? buttonTextColor;
  final Color? backgroundColor;
  final Color? textColor;

  const NumberOfServicesCard({
    Key? key,
    required this.monthCounts,
    required this.monthHours,
    required this.isLoading,
    required this.buildBarGroups,
    required this.onFetchServiceCounts,
    required this.onFetchDurationHours,
    required this.numberOfServicesText,
    required this.noOfServiceText,
    required this.totalHoursText,
    this.loadingWidget,
    this.primaryColor,
    this.buttonTextColor,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  State<NumberOfServicesCard> createState() => _NumberOfServicesCardState();
}

class _NumberOfServicesCardState extends State<NumberOfServicesCard> {
  bool showServiceCount = true;

  double _niceCeil(double value) {
    if (value <= 0) return 1;
    final exp = (math.log(value) / math.ln10).floor();
    final f = value / math.pow(10, exp);
    double nf;
    if (f <= 1) {
      nf = 1;
    } else if (f <= 2) {
      nf = 2;
    } else if (f <= 5) {
      nf = 5;
    } else {
      nf = 10;
    }
    return nf * math.pow(10, exp);
  }

  double _niceStep(double roughStep) {
    if (roughStep <= 0) return 1;
    final exp = (math.log(roughStep) / math.ln10).floor();
    final f = roughStep / math.pow(10, exp);
    double nf;
    if (f <= 1) {
      nf = 1;
    } else if (f <= 2) {
      nf = 2;
    } else if (f <= 5) {
      nf = 5;
    } else {
      nf = 10;
    }
    return nf * math.pow(10, exp);
  }

  String _fmt(num v) {
    final d = v.toDouble();
    final i = d.roundToDouble();
    return (d - i).abs() < 1e-6 ? i.toInt().toString() : d.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == ui.TextDirection.rtl;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    // Pick active dataset (counts vs hours)
    final Map<int, num> activeData = showServiceCount ? widget.monthCounts : widget.monthHours;

    // Dynamic Y range from active data
    final values = activeData.values.whereType<num>().map((e) => e.toDouble()).toList();
    final dataMax = values.isEmpty ? 0.0 : values.reduce(math.max);

    const tickCount = 5;
    const yMin = 0.0;
    final paddedMax = dataMax * 1.2;
    double yMax = _niceCeil(paddedMax);
    if (yMax <= 0) yMax = 1;

    final roughStep = (yMax - yMin) / (tickCount - 1);
    final yStep = _niceStep(roughStep);

    yMax = yStep * (tickCount - 1);
    if (yMax < dataMax) {
      final neededSteps = ((dataMax - yMin) / yStep).ceil();
      yMax = yStep * math.max(neededSteps, (tickCount - 1));
    }

    final leftLabels = List<double>.generate(
      tickCount,
          (i) => yMin + i * yStep,
    );

    final barW = 40.sp;
    final gap = 180.sp;
    final n = 12; // Always 12 months
    final double chartWidth = (barW * n) + (gap * (n - 1)) + 40.sp;

    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    final buttonTextColor = widget.buttonTextColor ?? AppColors.white;
    final bgColor = widget.backgroundColor ?? (lightMode ? AppColors.white : AppColors.darkGrey!);
    final txtColor = widget.textColor ?? (lightMode ? AppColors.black.withOpacity(0.87) : AppColors.white.withOpacity(0.70));

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 26.sp,
                height: 26.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons_assets/services_assets/headset_support.svg",
                    fit: BoxFit.scaleDown,
                    width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
              ),
              SizedBox(width: 6.sp),
              Text(
                widget.numberOfServicesText,
                style: StyleText.fontSize14Weight400.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: txtColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.sp),

          // Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 201.sp,
                height: 36.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: lightMode ? AppColors.lightGrey : AppColors.darkGrey,
                ),
                padding: EdgeInsets.all(4.sp),
                child: Row(
                  children: [
                    // No. of Service
                    GestureDetector(
                      onTap: () {
                        if (!showServiceCount) {
                          setState(() => showServiceCount = true);
                          widget.onFetchServiceCounts();
                        }
                      },
                      child: Container(
                        width: 100.sp,
                        height: 28.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: showServiceCount ? primaryColor : AppColors.transparent,
                        ),
                        child: Text(
                          widget.noOfServiceText,
                          style: StyleText.fontSize14Weight400.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: showServiceCount ? buttonTextColor : txtColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.sp),
                    // Total Hours
                    GestureDetector(
                      onTap: () {
                        if (showServiceCount) {
                          setState(() => showServiceCount = false);
                          widget.onFetchDurationHours();
                        }
                      },
                      child: Container(
                        width: 85.sp,
                        height: 28.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: !showServiceCount ? primaryColor : AppColors.transparent,
                        ),
                        child: Text(
                          widget.totalHoursText,
                          style: StyleText.fontSize14Weight400.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: !showServiceCount ? buttonTextColor : txtColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5.sp),

          // Chart
          SizedBox(
            height: 170.sp,
            child: widget.isLoading
                ? Center(child: widget.loadingWidget ?? const CircularProgressIndicator())
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Y labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: leftLabels
                      .map(
                        (v) => SizedBox(
                      height: 25.sp,
                      child: Text(
                        _fmt(v),
                        style: StyleText.fontSize14Weight400.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: lightMode ? AppColors.mediumGrey : AppColors.grey,
                        ),
                      ),
                    ),
                  )
                      .toList()
                      .reversed
                      .toList(),
                ),
                SizedBox(width: 20.sp),

                // Scrollable bars
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 850.sp,
                      child: BarChart(
                        BarChartData(
                          groupsSpace: 20.sp,
                          maxY: yMax,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 25.sp,
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  final locale = Localizations.localeOf(context).languageCode;
                                  final x = value.toInt();
                                  if (x < 0 || x > 11) return const SizedBox();

                                  final monthIdx = isRTL ? (11 - x) : x;

                                  return Transform.translate(
                                    offset: Offset(0, 5.sp),
                                    child: Text(
                                      DateFormat.MMM(locale).format(DateTime(2025, monthIdx + 1)),
                                      textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                      style: StyleText.fontSize14Weight400.copyWith(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: txtColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipPadding: EdgeInsets.zero,
                              tooltipMargin: 8,
                              getTooltipColor: (_) => AppColors.transparent,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                if (rod.toY <= 0) return null;
                                return BarTooltipItem(
                                  _fmt(rod.toY),
                                  StyleText.fontSize14Weight400.copyWith(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: txtColor,
                                  ),
                                );
                              },
                            ),
                          ),
                          barGroups: List.generate(12, (i) {
                            final v = (activeData[i] ?? 0).toDouble();
                            return widget.buildBarGroups(i, v);
                          }),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Usage Example:
/*
NumberOfServicesCard(
  monthCounts: monthCounts,
  monthHours: monthHours,
  isLoading: isLoading,
  buildBarGroups: buildBarGroups,
  onFetchServiceCounts: fetchMonthlyServiceCounts,
  onFetchDurationHours: fetchMonthlyDurationInHours,
  numberOfServicesText: S.of(context).numberOfServices,
  noOfServiceText: S.of(context).NoOfService,
  totalHoursText: S.of(context).TotalHours,
  loadingWidget: CircleProgressMaster(), // Optional
  primaryColor: AppColors.primary, // Optional
  buttonTextColor: AppColors.textButton, // Optional
)
*/