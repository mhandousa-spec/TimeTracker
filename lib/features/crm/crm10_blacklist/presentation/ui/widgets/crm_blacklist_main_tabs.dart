// ****************** FILE INFO ******************
// File Name: crm_blacklist_main_tabs.dart
// Purpose: Top tabs switcher for CRM Blacklisted page (Blocked vs Requests).
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmBlacklistMainTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const CrmBlacklistMainTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderCard),
      ),
      padding: EdgeInsets.all(4.sp),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTabPill(
            title: FormatHelper.localizedString(
              englishName: 'Blocked',
              arabicName: 'المحظورين',
            ),
            isSelected: selectedIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          SizedBox(width: 6.sp),
          _buildTabPill(
            title: FormatHelper.localizedString(
              englishName: 'Requests',
              arabicName: 'الطلبات',
            ),
            isSelected: selectedIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          title,
          style: StyleText.fontSize14Weight600.copyWith(
            color: isSelected ? AppColors.black : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }
}
