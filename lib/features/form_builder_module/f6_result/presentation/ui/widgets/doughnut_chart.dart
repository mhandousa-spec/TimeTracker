
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/form_chart_data.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/color_generator.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/ana/custom_chart_data.dart';

import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

// doughnut chart
class DoughnutChart extends StatelessWidget {
  DoughnutChart({required this.data, required this.total, super.key});
  int total;
  List<FormChartData> data;
  late List<Color> chartColors;

  // ✅ Safe color accessor method
  Color _getColor(int index) {
    if (index >= 0 && index < chartColors.length) {
      return chartColors[index];
    }
    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    chartColors = ColorGenerator.generateColors(data.length);

    // ✅ Ensure we have enough colors
    if (chartColors.length < data.length) {
      
      // Fill with default colors if needed
      while (chartColors.length < data.length) {
        chartColors.add(AppColors.grey);
      }
    }

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Row(
      children: [
        SizedBox(
          height: 200.h,
          child: SingleChildScrollView(
            child: Column(
              spacing: 10.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < data.length; i++)
                  CustomChartDataRow(
                    isPerformanceScreen: (isPortrait ? false : true),
                    isSmallContainer: isTablet ? true : false,
                    dataColor: _getColor(i), // ✅ Safe access
                    textData: data[i].text,
                    valueData: data[i].values,
                    isHorizontal: false,
                  ),
              ],
            ),
          ),
        ),
        Spacer(),
        Container(
          height: 200.h,
          width: 160.w,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(total.formatNumber(),
                          style: StyleText.fontSize14Weight500
                              .copyWith(fontWeight: FontWeight.w700)),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          S.of(context).total,
                          style: StyleText.fontSize12Weight400,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
            series: <CircularSeries>[
              DoughnutSeries<FormChartData, String>(
                dataSource: data,
                xValueMapper: (FormChartData info, _) => info.text,
                yValueMapper: (FormChartData info, _) => info.values,
                pointColorMapper: (FormChartData info, int index) {
                  // ✅ Safe access here too
                  return _getColor(index);
                },
                dataLabelSettings: DataLabelSettings(
                  connectorLineSettings: ConnectorLineSettings(
                    length: '10%', // Shorter connector lines
                    width: 1,
                    color: AppColors.grey.withOpacity(0.5),
                  ),
                  // Reduce margin around labels
                  margin: EdgeInsets.zero,
                  // Use opacity to avoid obscuring chart

                  labelAlignment: ChartDataLabelAlignment.middle,
                  isVisible: true,
                  builder: (data, point, series, pointIndex, seriesIndex) {
                    FormChartData dataChart = data as FormChartData;
                    return Text(
                      '${(dataChart.values / total * 100).round()}%',
                      style: StyleText.fontSize12Weight600.copyWith(color: AppColors.lightGrey).copyWith(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    );
                  },
                  labelPosition: ChartDataLabelPosition.inside,
                ),
                radius: isPortrait ? '70%' : '90%',
                innerRadius: isPortrait ? '60%' : '50%',
                explodeOffset: '7%',
                explode: true,
                explodeAll: true,
              )
            ],
          ),
        ),
        horizontalSpace(isTablet
            ? isPortrait
            ? 20
            : 10
            : 0)
      ],
    );
  }
}