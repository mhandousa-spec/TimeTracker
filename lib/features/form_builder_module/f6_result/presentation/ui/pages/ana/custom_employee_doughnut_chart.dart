// ignore_for_file: unrelated_type_equality_checks, sized_box_for_whitespace, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:knowticed_plus/core/custom/76-date_time_in_arabic.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/color_generator.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/form_chart_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/ana/custom_bar_charts_container.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/ana/custom_chart_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/ana/custom_chart_values.dart';

import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class CustomEmployeeDoughnutChart extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<FormChartData> chartsData;
  final List<String>? mins;
  final bool show;
  final bool isTransparent;

  const CustomEmployeeDoughnutChart({
    required this.title,
    required this.imagePath,
    required this.chartsData,
    this.mins,
    this.show = true,
    this.isTransparent = false,
    super.key,
  });

  @override
  State<CustomEmployeeDoughnutChart> createState() =>
      _CustomEmployeeDoughnutChartState();
}

class _CustomEmployeeDoughnutChartState
    extends State<CustomEmployeeDoughnutChart> {
  int calculateSum(List<String>? values) {
    int sum = 0;
    if (values != null) {
      for (int i = 0; i < values.length; i++) {
        sum += int.parse(values[i]);
      }
    }
    return sum;
  }

  late List<Color> chartColors;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chartColors = ColorGenerator.generateColors(widget.chartsData.length);
  }

  @override
  Widget build(BuildContext context) {
    int totalSum = calculateSum(
        widget.chartsData.map((e) => e.values.toInt().toString()).toList());
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Container(
      decoration: BoxDecoration(
        color: widget.isTransparent && isTablet == false
            ? Theme.of(context).colorScheme.inversePrimary
            : Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: isTablet
                    ? isPortrait
                        ? 0.015.w
                        : 0.015.h
                    : 0.015.h,
                right: isTablet
                    ? isPortrait
                        ? 0.015.h
                        : 0.02.h
                    : 0.02.h,
                left: isTablet
                    ? isPortrait
                        ? 0.015.h
                        : 0.02.h
                    : 0.02.h),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 13,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                  ),
                ),
                SizedBox(
                    width: isTablet
                        ? isPortrait
                            ? 0.01.w
                            : 0.01.h
                        : 0.008.h),
                Text(
                  widget.title,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? isPortrait
                              ? FontConstants.fontSize014.h
                              : FontConstants.fontSize022.h
                          : FontConstants.fontSize020.h,
                      color: AppColors.text,
                      fontWeight: isTablet
                          ? isPortrait
                              ? FontWeight.w400
                              : FontWeight.w600
                          : FontWeight.w400,
                      height: isTablet
                          ? isPortrait
                              ? 2
                              : 1.8
                          : 1.8),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: !isTablet ? 0.015.h : 0,
              right: isTablet
                  ? isPortrait
                      ? Get.locale.toString().contains('en')
                          ? 0
                          : 0.015.h
                      : 0.015.w
                  : 0,
              left: isTablet
                  ? isPortrait
                      ? Get.locale.toString().contains('en')
                          ? 0.015.h
                          : 0
                      : 0.015.w
                  : 0,
            ),
            child: Row(
              mainAxisAlignment: isTablet
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.spaceAround,
              crossAxisAlignment: isTablet
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  height: isTablet
                      ? isPortrait
                          ? 0.18.w
                          : 0.18.h
                      : 0.36.w,
                  width: isTablet
                      ? isPortrait
                          ? 0.2.w
                          : 0.36.h
                      : 0.37.w,
                  child: SizedBox(
                    height: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < widget.chartsData.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: isPortrait ? 0.015.w : 0.015.h),
                              child: CustomChartDataRow(
                                isPerformanceScreen:
                                    (isPortrait ? false : true),
                                isSmallContainer: isTablet ? true : false,
                                dataColor: chartColors[i],
                                textData: widget.chartsData[i].text,
                                valueData: widget.chartsData[i].values,
                                isHorizontal: false,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                    height: isPortrait ? 0.24.w : 0.24.h,
                    width: isTablet
                        ? isPortrait
                            ? 0.15.h
                            : 0.15.w
                        : 0.37.w,
                    child: SfCircularChart(
                      annotations: <CircularChartAnnotation>[
                        CircularChartAnnotation(
                          widget: Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  totalSum.formatNumber(),
                                  style:
                                      AppFontStyle.cairoRegularStyle.copyWith(
                                    fontSize: isPortrait
                                        ? FontConstants.fontSize018.h
                                        : FontConstants.fontSize026.w,
                                    color: AppColors.text,
                                    fontWeight: isPortrait
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: isPortrait ? 0.01.w : 0.01.h),
                                  child: Text(
                                    S.of(context).total,
                                    style:
                                        AppFontStyle.cairoRegularStyle.copyWith(
                                      fontSize: isPortrait
                                          ? FontConstants.fontSize012.h
                                          : FontConstants.fontSize014.w,
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                      series: <CircularSeries>[
                        DoughnutSeries<FormChartData, String>(
                          dataSource: widget.chartsData,
                          xValueMapper: (FormChartData info, _) => info.text,
                          yValueMapper: (FormChartData info, _) => info.values,
                          pointColorMapper: (FormChartData info, int index) {
                            if (index >= 0 && index < chartColors.length) {
                              return chartColors[index];
                            }
                            return AppColors.grey;
                          },
                          dataLabelSettings: DataLabelSettings(
                            labelAlignment: ChartDataLabelAlignment.middle,
                            isVisible: true,
                            builder:
                                (data, point, series, pointIndex, seriesIndex) {
                              FormChartData dataChart = data as FormChartData;
                              return Text(
                                '${(dataChart.values / totalSum * 100).round()}%',
                                style: StyleText.fontSize12Weight600.copyWith(color: AppColors.lightGrey)
                                    .copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold),
                              );
                            },
                            labelPosition: ChartDataLabelPosition.inside,
                          ),
                          radius: isTablet
                              ? isPortrait
                                  ? '90%'
                                  : '120%'
                              : '160%',
                          innerRadius: isPortrait ? '60%' : '50%',
                          explodeOffset: '7%',
                          explode: true,
                          explodeAll: true,
                        )
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
