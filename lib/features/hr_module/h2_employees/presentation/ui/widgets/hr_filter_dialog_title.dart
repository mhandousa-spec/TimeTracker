// ***************************** FILE INFO ***************************** //
// File Name: hr_filter_dialog_title.dart
// Purpose: Displays the shared title row for HR employee filter dialogs.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/41-custom_button_sizing.dart';
import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';

/// Renders the localized icon-and-title heading shared by filter dialogs.
class HrFilterDialogTitle extends StatelessWidget {
  const HrFilterDialogTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ButtonSizing.iconButtonSize,
          height: ButtonSizing.iconButtonSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: CustomSvgImage(
            assetPath: 'assets/icons_assets/hr_assets/hr_filter_tuning.svg',
            width: 20.sp,
            height: 20.sp,
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          S.of(context).filter,
          style: StyleText.fontSize20Weight500.copyWith(
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
