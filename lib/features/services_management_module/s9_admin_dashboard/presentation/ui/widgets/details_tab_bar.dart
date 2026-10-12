// ******************* FILE INFO *******************
// File Name: details_tab_bar.dart
// Description: Requested Services / Employees tab switcher for Dashboard Details
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


class DetailsTabBar extends StatelessWidget {
  final bool showRequestedServices;
  final ValueChanged<bool> onTabChanged;

  const DetailsTabBar({
    super.key,
    required this.showRequestedServices,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 5.w),
        _TabItem(
          label: S.of(context).RequestedServices,
          isActive: showRequestedServices,
          activeColor: AppColors.secondaryPrimary,
          onTap: () => onTabChanged(true),
        ),
        SizedBox(width: 20.w),
        _TabItem(
          label: S.of(context).Employees,
          isActive: !showRequestedServices,
          activeColor: AppColors.secondaryPrimary,
          onTap: () => onTabChanged(false),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Builder(
        builder: (context) {
          final style = StyleText.fontSize18Weight500;
          final tp = TextPainter(
            text: TextSpan(text: label, style: style),
            textDirection: Directionality.of(context),
            locale: Localizations.localeOf(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout(minWidth: 0, maxWidth: double.infinity);
          final width = tp.width;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: style.copyWith(
                  color: isActive ? activeColor : AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 4.h),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2.h,
                width: isActive ? width : 0,
                color: isActive ? activeColor : AppColors.transparent,
              ),
            ],
          );
        },
      ),
    );
  }
}