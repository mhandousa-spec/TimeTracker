
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/form_chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ColumnChart extends StatefulWidget {
  ColumnChart({required this.data, super.key});
  List<FormChartData> data;

  @override
  State<ColumnChart> createState() => _ColumnChartState();
}

class _ColumnChartState extends State<ColumnChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      child: SfCartesianChart(
          backgroundColor: AppColors.transparent,
          primaryXAxis: CategoryAxis(
            labelStyle: StyleText.fontSize10Weight400,
            axisLine: AxisLine(width: 0),
          ),
          primaryYAxis: NumericAxis(
            majorGridLines: MajorGridLines(
              width: 1, // Line thickness
              color: AppColors.grey.withOpacity(0.5), // Line color
              dashArray: <double>[5, 5], // Dash pattern (5px dash, 5px gap)
            ),
            majorTickLines: MajorTickLines(size: 0, width: 0),
            axisLine: AxisLine(width: 0),
          ),
          series: <CartesianSeries<FormChartData, String>>[
            ColumnSeries<FormChartData, String>(
                borderRadius: BorderRadius.circular(10.r),
                width: ContextExtension(context).isPhone ? 0.2 : 0.05,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.top,
                  textStyle: StyleText.fontSize12Weight400,
                  labelIntersectAction: LabelIntersectAction.shift,
                ),
                dataSource: widget.data,
                xValueMapper: (FormChartData data, _) => data.text,
                yValueMapper: (FormChartData data, _) => data.values,
                name: 'Gold',
                color: AppColors.primary)
          ]),
    );
  }
}
