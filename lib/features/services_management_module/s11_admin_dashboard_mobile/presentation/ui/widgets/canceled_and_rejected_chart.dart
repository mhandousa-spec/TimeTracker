// ******************* FILE INFO *******************
// File Name: canceled_and_rejected_chart
// Description: Canceled and rejected chart.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// Import your existing widgets
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/DashBoard_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Dynamic Rejected/Canceled Services Chart Widget
/// Supports both vertical and horizontal orientations
/// Toggles between "Rejected" and "Canceled"
class DynamicRejectedCanceledChart extends StatefulWidget {
  final Map<int, double> monthRejected;
  final Map<int, double> monthCanceled;
  final bool isLoading;
  final Function buildBarGroups;
  final VoidCallback onFetchRejectedCounts;
  final VoidCallback onFetchCanceledCounts;
  final String titleText;
  final String rejectedText;
  final String canceledText;
  final Widget loadingWidget;
  final Color primaryColor;
  final Color buttonTextColor;
  final bool lightMode;
  final ChartOrientation orientation;

  const DynamicRejectedCanceledChart({
    Key? key,
    required this.monthRejected,
    required this.monthCanceled,
    required this.isLoading,
    required this.buildBarGroups,
    required this.onFetchRejectedCounts,
    required this.onFetchCanceledCounts,
    required this.titleText,
    required this.rejectedText,
    required this.canceledText,
    required this.loadingWidget,
    required this.primaryColor,
    required this.buttonTextColor,
    required this.lightMode,
    this.orientation = ChartOrientation.vertical,
  }) : super(key: key);

  @override
  State<DynamicRejectedCanceledChart> createState() =>
      _DynamicRejectedCanceledChartState();
}

class _DynamicRejectedCanceledChartState
    extends State<DynamicRejectedCanceledChart> {
  bool _isCanceled = false; // false = rejected, true = canceled

  final List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: widget.lightMode ? AppColors.white : AppColors.header,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(child: widget.loadingWidget),
      );
    }

    // Prepare data based on toggle state
    final data = _isCanceled ? widget.monthCanceled : widget.monthRejected;
    final values = List.generate(12, (i) => data[i] ?? 0.0);

    // Render based on orientation
    if (widget.orientation == ChartOrientation.horizontal) {
      return _buildHorizontalChart(values);
    } else {
      return _buildVerticalChart(values);
    }
  }

  /// Build Vertical Chart (Original Style)
  Widget _buildVerticalChart(List<double> values) {
    var isMobile = ContextExtension(context).isPhone;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Padding(
            padding: EdgeInsets.only(top: 15.sp, right: 10.sp, left: 10.sp),
            child: isMobile ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26.sp,
                      height: 26.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryColor,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons_assets/services_assets/headset_support.svg",
                          fit: BoxFit.scaleDown,
                          width: 16.sp,
                          height: 16.sp,
                          color: widget.buttonTextColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      widget.titleText,
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: widget.lightMode ? AppColors.black : AppColors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildToggleButton(),
                  ],
                ),
              ],
            ):  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26.sp,
                      height: 26.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.primaryColor,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons_assets/services_assets/headset_support.svg",
                          fit: BoxFit.scaleDown,
                          width: 16.sp,
                          height: 16.sp,
                          color: widget.buttonTextColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      widget.titleText,
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: widget.lightMode ? AppColors.black : AppColors.white,
                      ),
                    ),
                  ],
                ),
                _buildToggleButton(),
              ],
            ),
          ),
          // Vertical Bar Chart
          CustomVerticalBarChartWidget(
            title: '',
            labels: _monthLabels,
            values: values,
            barWidth: 20,
            lightMode: widget.lightMode,
            height: 300,
          ),
        ],
      ),
    );
  }

  /// Build Horizontal Chart (New Style)
  Widget _buildHorizontalChart(List<double> values) {
    return CustomHorizontalBarChartWidget(
      title: widget.titleText,
      iconAsset: "assets/icons_assets/services_assets/headset_support.svg",
      labels: _monthLabels,
      values: values,
      barHeight: 15,
      lightMode: widget.lightMode,
      backgroundColor: widget.lightMode ? AppColors.white : AppColors.chatBackground,
      headerWidget: _buildToggleButton(),
    );
  }

  /// Toggle Button Widget
  Widget _buildToggleButton() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final indicatorAlignment = isArabic
        ? (_isCanceled ? Alignment.centerLeft : Alignment.centerRight)
        : (_isCanceled ? Alignment.centerRight : Alignment.centerLeft);

    return GestureDetector(
      onTap: () {
        setState(() {
          _isCanceled = !_isCanceled;
        });

        if (_isCanceled) {
          widget.onFetchCanceledCounts();
        } else {
          widget.onFetchRejectedCounts();
        }
      },
      child: Container(
        width: 240.sp,
        height: 30.sp,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: indicatorAlignment, // ✅ Fixed
              child: Container(
                width: 116.sp,
                height: 30.sp,
                margin: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),

            Row(
              children: [
                // Rejected Text
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: !_isCanceled
                            ? AppColors.textButton
                            : AppColors.text,

                      ),
                      child: Text(widget.rejectedText),
                    ),
                  ),
                ),

                //       color: _isCanceled
                //                             ? AppColors.textButton
                //                             : AppColors.text,
                // Canceled Text
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight500.copyWith(
                            color: _isCanceled
                            ? AppColors.textButton
                                : AppColors.text,

                      ),
                      child: Text(widget.canceledText),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
