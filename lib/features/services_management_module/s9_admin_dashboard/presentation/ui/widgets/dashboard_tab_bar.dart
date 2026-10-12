// ******************* FILE INFO *******************
// File Name: dashboard_tab_bar.dart
// Description: Requests / Statistics tab switcher
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/helper_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


class DashboardTabBar extends StatelessWidget {
  final bool showRequests;
  final VoidCallback onRequestsTap;
  final VoidCallback onStatisticsTap;

  const DashboardTabBar({
    super.key,
    required this.showRequests,
    required this.onRequestsTap,
    required this.onStatisticsTap,
  });

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Row(
      children: [
        _TabItem(
          label: S.of(context).requests,
          isActive: showRequests,
          onTap: onRequestsTap,
          lightMode: lightMode,
        ),
        SizedBox(width: 38.w),
        _TabItem(
          label: S.of(context).Statistics,
          isActive: !showRequests,
          onTap: onStatisticsTap,
          lightMode: lightMode,
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool lightMode;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.lightMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: StyleText.fontSize20Weight600.copyWith(
              color: isActive
                  ? AppColors.secondaryPrimary
                  : (lightMode
                  ? AppColors.secondaryText
                  : AppColors.grey),
            ),
          ),
          SizedBox(height: 4.sp),
          Container(
            height: 2.sp,
            width: getTextWidth(label, StyleText.fontSize20Weight600),
            color: isActive
                ? AppColors.secondaryPrimary
                : AppColors.transparent,
          ),
        ],
      ),
    );
  }
}
