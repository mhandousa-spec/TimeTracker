/// Module: messaging / chat / presentation/ui/widgets/buttons/menu_icon_button.dart
// By:Youssef Ashraf
// Date: 18/9/2024
// Objectives: This file is responsible for providing a widget that represents the menu icon in the menu attachment message widget.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class MenuIconButton extends StatelessWidget {
  final Function() onTap;
  final String icon;
  final String text;

  const MenuIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(
                8.r,
              ),
            ),
            child: SvgPicture.asset(
              color:
                  AppTheme.isDark ?? false ? AppColors.textButton : AppColors.black,
              icon,
              height: 32.h,
              width: 32.w,
            ),
          ),
        ),
        verticalSpace(4),
        Text(
          text,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text
          ),
        ),
      ],
    );
  }
}