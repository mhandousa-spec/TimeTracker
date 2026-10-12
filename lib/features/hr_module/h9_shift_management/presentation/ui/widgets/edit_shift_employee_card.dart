// ***************************** FILE INFO ***************************** //
// File Name: edit_shift_employee_card.dart
// Purpose: Renders an employee card used by the shift-edit selection flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/16-custom_card_styles.dart';
import '../../../../../../core/custom/23-custom_check_box.dart';
import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Employee card with selection, focus border, and edit affordance.
class EditShiftEmployeeCard extends StatelessWidget {
  const EditShiftEmployeeCard({
    required this.name,
    required this.subtitle1,
    required this.subtitle2,
    required this.avatar,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
    super.key,
  });

  final String name;
  final String? subtitle1;
  final String? subtitle2;
  final ImageProvider? avatar;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: CardStyles.radius(6),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.barrierColor,
              foregroundImage: avatar,
              child: ClipOval(
                child: CardSvg.icon(CardSvg.male, size: 40),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      style: CardStyles.title(14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (subtitle1 != null)
                    Text(subtitle1!,
                        style: CardStyles.label(12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  if (subtitle2 != null)
                    Text(subtitle2!,
                        style: CardStyles.label(12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomCheckBox(isSelected: isSelected, size: 22.sp),
                if (onEdit != null) ...[
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(4.r),
                    child: Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: CustomSvgImage(
                        assetPath: AppAssets.edit,
                        width: 17.sp,
                        height: 17.sp,
                        color: AppColors.textButton,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
