// ******************* FILE INFO *******************
// File Name: build_number_services.dart
// Description: Reusable widget for displaying number of services chart
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Refactored from dashBoard_admin.dart
// ✅ UPDATED: Now uses CustomVerticalBarChartWidget

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/DashBoard_widget.dart';


import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class NumberOfServicesCardDashBoard extends StatelessWidget {
  final Map<int, double> monthCounts;
  final Map<int, num> monthHours;
  final bool isLoading;
  final bool showServiceCount;
  final VoidCallback onToggleServiceCount;
  final VoidCallback onToggleToHours;

  const NumberOfServicesCardDashBoard({
    Key? key,
    required this.monthCounts,
    required this.monthHours,
    required this.isLoading,
    required this.showServiceCount,
    required this.onToggleServiceCount,
    required this.onToggleToHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;
    final locale = Localizations.localeOf(context).languageCode;

    // Pick active dataset
    final Map<int, num> activeData =
    showServiceCount ? monthCounts : monthHours;

    // Build labels + values for all 12 months
    final List<String> labels = List.generate(12, (i) {
      return DateFormat.MMM(locale).format(DateTime(2025, i + 1));
    });
    final List<double> values = List.generate(12, (i) {
      return (activeData[i] ?? 0).toDouble();
    });

    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SizedBox(
          height: 300.h,
          child: Center(child: CircleProgressMaster()),
        ),
      );
    }

    return CustomVerticalBarChartWidget(
      title: S.of(context).numberOfServices,
      iconAsset: "assets/icons_assets/services_assets/headset_support.svg",
      labels: labels,
      values: values,
      lightMode: lightMode,
      height: isMobile ? 350 : 400,
      showAllMonths: false,
      barAlignment: BarChartAlignment.spaceAround,
      headerWidget: _buildAnimatedToggle(context, lightMode, isMobile),
    );
  }

  /// ✅ ANIMATED TOGGLE BUTTON
  Widget _buildAnimatedToggle(
      BuildContext context, bool lightMode, bool isMobile) {
    return GestureDetector(
      onTap: () {
        if (showServiceCount) {
          onToggleToHours();
        } else {
          onToggleServiceCount();
        }
      },
      child: Container(
        width: isMobile ? 200.sp : 240.sp,
        height: 30.sp,
        decoration: BoxDecoration(
          color: lightMode ? AppColors.background : AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Stack(
          children: [
            // ✅ Sliding background indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: showServiceCount
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: isMobile ? 96.sp : 116.sp,
                height: 30.sp,
                margin: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),

            // ✅ Text labels
            Row(
              children: [
                // No. of Service Text
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(

                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      // Same styling as the Dashboard page toggle
                      // (DynamicNumberOfServicesChart). Colours were inverted,
                      // which hid the unselected label (bug report p23).
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: showServiceCount
                            ? AppColors.textButton
                            : AppColors.text,
                      ),
                      child: Text(S.of(context).NoOfService),
                    ),
                  ),
                ),

                // Total Hours Text
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: !showServiceCount
                            ? AppColors.textButton
                            : AppColors.text,
                      ),
                      child: Text(S.of(context).TotalHours),
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
