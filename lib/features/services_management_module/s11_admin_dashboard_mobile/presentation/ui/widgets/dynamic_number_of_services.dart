// ******************* FILE INFO *******************
// File Name: dynamic_number_of_services
// Description: Dynamic number of services.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fl_chart/fl_chart.dart';
// Import your existing widgets
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/DashBoard_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';


/// Dynamic Number of Services Chart Widget
/// Supports both vertical and horizontal orientations
/// Toggles between "Total Hours" and "No. of Service"
class DynamicNumberOfServicesChart extends StatefulWidget {
  final Map<int, double> monthCounts;
  final Map<int, double> monthHours;
  final bool isLoading;
  final Function buildBarGroups;
  final VoidCallback onFetchServiceCounts;
  final VoidCallback onFetchDurationHours;
  final String numberOfServicesText;
  final String noOfServiceText;
  final String totalHoursText;
  final Widget loadingWidget;
  final Color primaryColor;
  final Color buttonTextColor;
  final bool lightMode;
  final ChartOrientation orientation;
  final bool isHours; // ✅ NEW: Driven by cubit state instead of local state

  const DynamicNumberOfServicesChart({
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
    required this.loadingWidget,
    required this.primaryColor,
    required this.buttonTextColor,
    required this.lightMode,
    this.orientation = ChartOrientation.vertical,
    this.isHours = false, // ✅ Default to service counts
  }) : super(key: key);

  @override
  State<DynamicNumberOfServicesChart> createState() =>
      _DynamicNumberOfServicesChartState();
}

class _DynamicNumberOfServicesChartState
    extends State<DynamicNumberOfServicesChart> {
  // ✅ REMOVED: bool _isHours = false; — now using widget.isHours from cubit state

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

    // ✅ CHANGED: Use widget.isHours instead of local _isHours
    final data = widget.isHours ? widget.monthHours : widget.monthCounts;
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
        color: widget.lightMode ? AppColors.white : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Padding(
            padding: EdgeInsets.only(top: 15.sp, right: 10.sp, left: 10.sp),
            child: isMobile ? Column(
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
                          color: AppColors.textButton,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      widget.numberOfServicesText,
                      style: StyleText.fontSize14Weight400.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.text
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildToggleButton(),
                  ],
                ),
              ],
            ): Row(
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
                      widget.numberOfServicesText,
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
    return CustomVerticalBarChartWidget(
      title: widget.numberOfServicesText,
      iconAsset: "assets/icons_assets/services_assets/headset_support.svg",
      labels: _monthLabels,
      height: 300,
      values: values,
      showGrid: true,
      barWidth: 20,
      lightMode: widget.lightMode,
      backgroundColor: widget.lightMode ? AppColors.white : AppColors.chatBackground,
      headerWidget: _buildToggleButton(),
    );
  }

  /// Toggle Button Widget
  Widget _buildToggleButton() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ CHANGED: Use widget.isHours instead of local _isHours
    final indicatorAlignment = isArabic
        ? (widget.isHours ? Alignment.centerLeft : Alignment.centerRight)
        : (widget.isHours ? Alignment.centerRight : Alignment.centerLeft);

    return GestureDetector(
      onTap: () {
        // ✅ CHANGED: No more local setState — just call the cubit callbacks
        if (!widget.isHours) {
          widget.onFetchDurationHours();
        } else {
          widget.onFetchServiceCounts();
        }
      },
      child: Container(
        width: 240.sp,
        height: 30.sp,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: indicatorAlignment,
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
            // ✅ CHANGED: Use widget.isHours instead of local _isHours
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: !widget.isHours ? AppColors.textButton : AppColors.text,
                      ),
                      child: Text(widget.noOfServiceText),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: widget.isHours ? AppColors.textButton : AppColors.text,
                      ),
                      child: Text(widget.totalHoursText),
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
