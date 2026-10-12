// ****************** FILE INFO ******************
// File Name: crm_deals_sort_dropdown.dart
// Purpose: Sort dropdown popup overlay menu (Oldest, Newest) matching Figma screenshot 5
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmDealsSortDropdown extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSelectSort;

  const CrmDealsSortDropdown({
    super.key,
    required this.currentSort,
    required this.onSelectSort,
  });

  static void show({
    required BuildContext context,
    required GlobalKey anchorKey,
    required String currentSort,
    required ValueChanged<String> onSelectSort,
  }) {
    final RenderBox? renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 6.sp,
        offset.dx + 160.sp,
        offset.dy + size.height + 140.sp,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: AppColors.white,
      elevation: 4,
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'oldest',
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
            decoration: BoxDecoration(
              color: currentSort == 'oldest'
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              FormatHelper.localizedString(
                englishName: 'Oldest',
                arabicName: 'الأقدم',
              ),
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight:
                    currentSort == 'oldest' ? FontWeight.bold : FontWeight.w500,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'newest',
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 12.sp),
            decoration: BoxDecoration(
              color: currentSort == 'newest'
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              FormatHelper.localizedString(
                englishName: 'Newest',
                arabicName: 'الأحدث',
              ),
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight:
                    currentSort == 'newest' ? FontWeight.bold : FontWeight.w500,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ).then((String? selected) {
      if (selected != null) {
        onSelectSort(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
