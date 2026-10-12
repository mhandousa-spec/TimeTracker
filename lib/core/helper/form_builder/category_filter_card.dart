import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
/// Ibrahim Ismail
// Date: 13/1/2025
///Represents the category filter card as part of category filter row in home page
class TabletCategoryFilterCard extends StatelessWidget {
  final String name;
  final bool selected;
  final int count;
  const TabletCategoryFilterCard({
    super.key,
    required this.name,
    required this.selected,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = ContextExtension(context).isPhone;
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        height: isPhone ? 35.sp : 45.sp,
        width: isPhone ? 35.sp : 45.sp,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            FormDateTimeHelper.formatInt(count),
            style: isPhone
                ? (selected
                ? StyleText.fontSize14Weight500.copyWith(
                color: AppColors.textButton) // ✅ Removed fontWeight.w600
                : StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText)) // ✅ Removed fontWeight.w600
                : (selected
                ? StyleText.fontSize20Weight500.copyWith(
                color: AppColors.textButton) // ✅ Removed fontWeight.w600
                : StyleText.fontSize20Weight500.copyWith(color: AppColors.secondaryText)), // ✅ Removed fontWeight.w600
          ),
        ),
      ),
      horizontalSpace(15),
      Text(name,
          overflow: TextOverflow.ellipsis,
          style: selected
              ? StyleText.fontSize16Weight500 // ✅ Removed .copyWith(fontWeight: FontWeight.w600)
              : StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryText).copyWith(
            color: AppColors.text
          )), // ✅ Removed .copyWith(fontWeight: FontWeight.w600)
    ]);
  }
}