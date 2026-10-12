/// Module: knowledge_hub_module / core/column_bar_widget.dart
/// ************************* FILE INFO *************************** ///
/// File Name: column_bar_widget.dart
/// Purpose: Column bar widget — knowledge_hub_module core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:math' as math;
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServicesOfferedWidget extends StatelessWidget {
  final Map<int, dynamic> monthCountss;
  final List<String> serviceNames;
  final List<String> serviceNamesArabic;
  final bool isLoadingServicesName;
  final BarChartGroupData Function(int, double) buildBarGroups;
  final Widget? loadingWidget;

  const ServicesOfferedWidget({
    Key? key,
    required this.monthCountss,
    required this.serviceNames,
    required this.serviceNamesArabic,
    required this.isLoadingServicesName,
    required this.buildBarGroups,
    this.loadingWidget,
  }) : super(key: key);

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

  String _fmtLabel(double v) {
    final iv = v.round();
    return (v - iv).abs() < 1e-6 ? iv.toString() : v.toStringAsFixed(1);
  }

  Iterable<double> _allValues() sync* {
    Iterable<double> _yieldAll(dynamic value) sync* {
      if (value is num) {
        yield value.toDouble();
      } else if (value is Iterable) {
        for (final e in value) {
          yield* _yieldAll(e);
        }
      } else if (value is Map) {
        for (final e in value.values) {
          yield* _yieldAll(e);
        }
      }
    }

    for (final v in monthCountss.values) {
      yield* _yieldAll(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Handle empty data by showing empty chart instead of message
    final hasData = monthCountss.isNotEmpty && serviceNames.isNotEmpty;

    // If no data, use placeholder values to show empty chart
    final displayMonthCounts = hasData ? monthCountss : {0: 0.0};
    final displayServiceNames = hasData ? serviceNames : [''];
    final displayServiceNamesArabic = hasData ? serviceNamesArabic : [''];

    final values = _allValues().toList();
    final dataMax = (values.isEmpty ? 0.0 : values.reduce(math.max));
    const yMin = 0.0;

    final paddedMax = (dataMax <= 0 ? 1.0 : dataMax * 1.2);

    const tickCount = 5;
    final roughStep = (paddedMax - yMin) / (tickCount - 1);
    final yStep = _niceStep(roughStep);

    final neededSteps = ((dataMax - yMin) / yStep).ceil();
    double yMax = yStep * math.max(neededSteps, (tickCount - 1));

    final leftLabels = List<double>.generate(
      tickCount,
      (i) => yMin + i * (yMax / (tickCount - 1)),
    );

    // ✅ FIX: Ensure positive width calculations
    final barW = 50.w;
    final gap = 70.w;
    final n = displayMonthCounts.length;

    // ✅ FIX: Add minimum width constraint
    final calculatedWidth = (barW * n) + (gap * (n - 1)) + 65.sp;
    final chartWidth = math.max(
      calculatedWidth,
      200.sp,
    ); // Minimum 200.sp width

    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SizedBox(
      height: 180.sp,
      child: isLoadingServicesName
          ? Center(child: loadingWidget ?? const CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // ✅ FIX: Use LayoutBuilder to get available width
                final availableWidth = constraints.maxWidth;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed Y-Axis Labels
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: leftLabels
                          .map(
                            (v) => SizedBox(
                              height: 30.sp,
                              child: Text(
                                _fmtLabel(v),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: lightMode
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          )
                          .toList()
                          .reversed
                          .toList(),
                    ),
                    SizedBox(width: 20.sp),

                    // ✅ FIX: Constrain the scrollable area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 10),
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: math.max(
                              chartWidth,
                              availableWidth - 60.sp,
                            ),
                            maxWidth: double.infinity,
                          ),
                          child: SizedBox(
                            width: chartWidth,
                            height: 200.h,
                            child: BarChart(
                              BarChartData(
                                groupsSpace: 30.sp,
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
                                      reservedSize: 20.sp,
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (value, _) {
                                        final index = value.toInt();

                                        if (index >= 0 &&
                                            index <
                                                displayServiceNames.length) {
                                          final arabicName =
                                              index <
                                                  displayServiceNamesArabic
                                                      .length
                                              ? displayServiceNamesArabic[index]
                                              : '';
                                          final englishName =
                                              index < displayServiceNames.length
                                              ? displayServiceNames[index]
                                              : '';

                                          // ✅ Don't show empty labels
                                          if (englishName.isEmpty &&
                                              arabicName.isEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          final serviceName = isArabic
                                              ? (arabicName.isNotEmpty
                                                    ? arabicName
                                                    : englishName)
                                              : englishName;

                                          return Transform.translate(
                                            offset: Offset(0, 5.sp),
                                            child: SizedBox(
                                              width: 100.w,
                                              child: Text(
                                                serviceName,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: lightMode
                                                      ? AppColors.colorBlack.withOpacity(0.87)
                                                      : AppColors.colorWhite.withOpacity(0.70),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipPadding: EdgeInsets.zero,
                                    tooltipMargin: 5,
                                    getTooltipColor: (group) =>
                                        AppColors.transparent,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                          if (rod.toY <= 0) return null;
                                          return BarTooltipItem(
                                            _fmtLabel(rod.toY),
                                            TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: lightMode
                                                  ? AppColors.colorBlack.withOpacity(0.87)
                                                  : AppColors.colorWhite.withOpacity(0.70),
                                            ),
                                          );
                                        },
                                  ),
                                ),
                                barGroups: displayMonthCounts.entries
                                    .map(
                                      (entry) => buildBarGroups(
                                        entry.key,
                                        (entry.value is num)
                                            ? (entry.value as num).toDouble()
                                            : 0.0,
                                      ),
                                    )
                                    .toList(),
                                gridData: FlGridData(show: false),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
