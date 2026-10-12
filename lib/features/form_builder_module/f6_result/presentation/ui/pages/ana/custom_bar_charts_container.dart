// ignore_for_file: unrelated_type_equality_checks, sized_box_for_whitespace, unused_local_variable

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/form_chart_data.dart';
class CustomBarChartContainer extends StatefulWidget {
  final String title;
  final double width;
  final String imagePath;
  final List<FormChartData> chartsData;

  final bool isTransparent;
  bool hasFilter;
  ValueChanged<String?>? selectedElementState;

  CustomBarChartContainer({
    required this.title,
    required this.imagePath,
    required this.chartsData,
    this.isTransparent = false,
    this.selectedElementState,
    super.key,
    this.hasFilter = false,
    required this.width,
  });

  @override
  State<CustomBarChartContainer> createState() =>
      _CustomBarChartContainerState();
}

class _CustomBarChartContainerState extends State<CustomBarChartContainer> {
  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isLargeScreen = MediaQuery.of(context).size.width > 1200;

    // Calculate number of visible bars based on screen size
    int visibleBars = 4; // Default for small screens
    if (isTablet) {
      visibleBars = 6; // Show 6 bars on tablet
    }
    if (isLargeScreen) {
      visibleBars = widget.chartsData.length; // Show all bars on large screens
    }

    return  Container(
      decoration: BoxDecoration(
        color: widget.isTransparent && isTablet == false
            ? Theme.of(context).colorScheme.inversePrimary
            : Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(9),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: isPortrait ? 0.015.w : 0.015.h,
                  right: isPortrait ? 0.02.w : 0.02.h,
                  left: isPortrait ? 0.02.w : 0.02.h),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.bubbleColor,
                    radius: isTablet
                        ? isPortrait
                        ? 0.02.w
                        : 0.02.h
                        : 0.015.h,
                    child: Padding(
                      padding: EdgeInsets.all(isPortrait ? 0.007.w : 0.007.h),
                      child: SvgPicture.asset(
                        widget.imagePath,
                        height: isTablet ? null : 0.025.h,
                        colorFilter:
                        ColorFilter.mode(AppColors.text, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(width: isPortrait ? 0.01.w : 0.01.h),
                  Text(
                    widget.title,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: isPortrait
                            ? FontConstants.fontSize014.h
                            : FontConstants.fontSize022.h,
                        color: AppColors.text,
                        fontWeight:
                        isPortrait ? FontWeight.w400 : FontWeight.w600,
                        height: isPortrait ? 2 : 1.8),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            verticalSpace(20),
            // Using LayoutBuilder to get available width
            LayoutBuilder(builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isPortrait ? 0.02.w : 0.02.h,
                    vertical: isPortrait ? 0.02.w : 0.02.h),
                child: Container(
                  height: isTablet ? (isPortrait ? 0.36.w : 0.37.h) : 0.24.h,
                  // Use constraints.maxWidth for more responsive width
                  width: isLargeScreen
                      ? constraints.maxWidth *
                      0.95 // Use more width on large screens
                      : isTablet
                      ? (isPortrait ? 0.75.w : 0.8.w)
                      : 0.76.w,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    borderWidth: 0,
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                      // Enable zooming on large screens to see details
                      enablePinching: isLargeScreen,
                      enableDoubleTapZooming: isLargeScreen,
                    ),
                    primaryXAxis: CategoryAxis(
                      majorTickLines: const MajorTickLines(size: 0),
                      borderWidth: 0,
                      initialVisibleMinimum: 0,
                      // Show all bars on large screens
                      initialVisibleMaximum:
                      isLargeScreen ? null : visibleBars.toDouble(),
                      interval: 1,
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      labelStyle: StyleText.fontSize14Weight500,
                    ),
                    primaryYAxis: NumericAxis(
                      majorTickLines: const MajorTickLines(size: 0),
                      borderWidth: 0,
                      autoScrollingMode: AutoScrollingMode.start,
                      tickPosition: TickPosition.outside,
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      labelStyle:
                      StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                    ),
                    plotAreaBackgroundColor: AppColors.transparent,
                    series: <ColumnSeries<FormChartData, String>>[
                      ColumnSeries<FormChartData, String>(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(8)),
                        // Adjust width based on number of visible bars
                        width: isLargeScreen ? 0.2 : 0.25,
                        spacing: 0,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelAlignment: ChartDataLabelAlignment.top,
                          textStyle: StyleText.fontSize14Weight500,
                          labelIntersectAction: LabelIntersectAction.shift,
                        ),
                        dataSource: widget.chartsData,
                        xValueMapper: (FormChartData info, _) => info.text,
                        yValueMapper: (FormChartData info, _) => info.values,
                        pointColorMapper: (FormChartData info, int index) {
                          return AppColors.primary;
                        },
                      )
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                    isTransposed: false,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
