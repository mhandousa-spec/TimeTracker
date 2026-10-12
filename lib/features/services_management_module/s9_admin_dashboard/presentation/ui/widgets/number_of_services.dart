// ******************* FILE INFO *******************
// File Name: number_of_services.dart
// Description: Reusable chart card widget for number of services
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah
// Last Update: 2026-02-22

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/DashBoard_widget.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';


import 'package:knowticed_plus/core/theme/app_theme.dart';

class ServicesChartCard extends StatefulWidget {
  final Map<int, num> monthCounts;
  final Map<int, num> monthHours;
  final bool isLoading;
  final VoidCallback onToggleToServiceCount;
  final VoidCallback onToggleToTotalHours;

  const ServicesChartCard({
    Key? key,
    required this.monthCounts,
    required this.monthHours,
    required this.isLoading,
    required this.onToggleToServiceCount,
    required this.onToggleToTotalHours,
  }) : super(key: key);

  @override
  State<ServicesChartCard> createState() => _ServicesChartCardState();
}

class _ServicesChartCardState extends State<ServicesChartCard> {
  bool showServiceCount = true;

  List<double> _buildValues(Map<int, num> data) {
    final result = List.generate(12, (i) => (data[i] ?? 0).toDouble());
    return result;
  }

  List<String> _buildLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return List.generate(
      12,
          (i) => DateFormat.MMM(locale).format(DateTime(2025, i + 1)),
    );
  }

  @override
  void didUpdateWidget(covariant ServicesChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final activeData = showServiceCount ? widget.monthCounts : widget.monthHours;
    final values = _buildValues(activeData);
    final labels = _buildLabels(context);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: lightMode ? AppColors.white : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  SizedBox(width: 6.w),
                  Text(
                    S.of(context).numberOfServices,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                ],
              ),
              _buildAnimatedToggle(context, lightMode),
            ],
          ),

          SizedBox(height: 15.sp),

          // ── Chart ─────────────────────────────────────────
          widget.isLoading
              ? SizedBox(
            height: 200.h,
            child: Center(child: CircleProgressMaster()),
          )
              : CustomVerticalBarChartWidget(
            key: ValueKey('${showServiceCount}_${values.toString()}'),
            title: '',
            iconAsset: null,
            labels: labels,
            values: values,
            lightMode: lightMode,
            barColor: AppColors.primary,
            backgroundColor: AppColors.transparent,
            showAllMonths: true,
            showGrid: true,
            groupsSpace: 8,
            barWidth: 20,
            height: 300,
          ),
        ],
      ),
    );
  }

  // ── Animated Toggle ──────────────────────────────────────
  Widget _buildAnimatedToggle(BuildContext context, bool lightMode) {
    return GestureDetector(
      onTap: () {
        if (showServiceCount) {
          setState(() => showServiceCount = false);
          widget.onToggleToTotalHours();
        } else {
          setState(() => showServiceCount = true);
          widget.onToggleToServiceCount();
        }
      },
      child: Container(
        width: 240.sp,
        height: 30.sp,
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.background
              : AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          children: [
            // Sliding background indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: showServiceCount
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: 116.sp,
                height: 30.sp,
                margin: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),

            // Text labels
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: showServiceCount
                            ? AppColors.textButton
                            : (lightMode ? AppColors.black : AppColors.white),
                      ),
                      child: Text(S.of(context).NoOfService),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: !showServiceCount
                            ? AppColors.textButton
                            : (lightMode ? AppColors.black : AppColors.white),
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
