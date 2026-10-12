/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: filter_bar_item.dart
/// Purpose: Declares `FilterBarItem`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart' hide ContextExtension;

class FilterBarItem extends StatelessWidget {
  FilterBarItem(
      {required this.isSelected,
      required this.title,
      required this.numberOfItems,
      required this.onTap,
      this.color,
      super.key});
  bool isSelected;
  String title;
  int numberOfItems;
  Function()? onTap;
  Color? color;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        spacing: 16.sp,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 45.sp : 35.sp,
            height: isTablet ? 45.sp : 35.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (isSelected ? AppColors.primary : AppColors.field),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              ContextExtension(context).isArabic
                  ? ArabicDigits(numberOfItems.toString()).toArabicNumbers()
                  : numberOfItems.toString(),
              textAlign: TextAlign.center,
              style: StyleText.fontSize20Weight500.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText),
            ),
          ),
          Text(title,
              style: (isSelected
                      ? StyleText.fontSize16Weight500
                      : StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack))
                  .copyWith(color: color))
        ],
      ),
    );
  }
}
