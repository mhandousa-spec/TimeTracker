/// Module: services_management_module
/// Description: Requested Services / Employees tab switcher for DashBoard
///              Master (s11).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: AppColors, StyleText, DashboardMasterState, S (l10n)
/// Revision History: Replaced raw TextStyle(fontSize: 18.sp,
///                    fontWeight: FontWeight.w600) with
///                    StyleText.fontSize18Weight600 (audit fix
///                    item 4b).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/dashboard_master_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class MasterTabBar extends StatelessWidget {
  final DashboardMasterState state;
  final VoidCallback onToggle;

  const MasterTabBar({
    super.key,
    required this.state,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 5.w),
        // ── Tab 1: Requested Services ──
        _buildTab(
          context,
          label: S.of(context).RequestedServices,
          isActive: state.showRequestedServices,
          onTap: () {
            if (!state.showRequestedServices) onToggle();
          },
        ),
        SizedBox(width: 20.w),
        // ── Tab 2: Employees ──
        _buildTab(
          context,
          label: S.of(context).Employees,
          isActive: !state.showRequestedServices,
          onTap: () {
            if (state.showRequestedServices) onToggle();
          },
        ),
      ],
    );
  }

  Widget _buildTab(
      BuildContext context, {
        required String label,
        required bool isActive,
        required VoidCallback onTap,
      }) {
    final style = StyleText.fontSize18Weight600;
    final tp = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      locale: Localizations.localeOf(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: style.copyWith(
              color: isActive
                  ? AppColors.secondaryPrimary
                  : AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 4.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.h,
            width: isActive ? tp.width : 0,
            color: isActive
                ? AppColors.secondaryPrimary
                : AppColors.transparent,
          ),
        ],
      ),
    );
  }
}
