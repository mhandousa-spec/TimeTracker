// ****************** FILE INFO ******************
// File Name: crm_activity_tab_bar.dart
// Purpose: Dual-tab toggle switcher for Activity Categories & Tags
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmActivityTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const CrmActivityTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.sp,
      padding: EdgeInsets.all(4.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabItem(
            title: S.current.crmCategories,
            isSelected: selectedIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          SizedBox(width: 8.w),
          _buildTabItem(
            title: S.current.crmTags,
            isSelected: selectedIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.sp,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: isSelected
              ? StyleText.fontSize14Weight500
              : StyleText.fontSize14Weight600.copyWith(color: AppColors.darkGrey),
        ),
      ),
    );
  }
}
