// ****************** FILE INFO ******************
// File Name: crm_card_info_row.dart
// Purpose: Dedicated reusable info item widget for CRM cards with properly sized icons and clean typography matching Figma
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmCardInfoItem extends StatelessWidget {
  final String svgAsset;
  final String label;
  final String value;
  final double iconSize;
  final double fontSize;
  final Color? iconColor;

  const CrmCardInfoItem({
    super.key,
    required this.svgAsset,
    required this.label,
    required this.value,
    this.iconSize = 16,
    this.fontSize = 12,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CustomSvgImage(
          assetPath: svgAsset,
          width: iconSize.sp,
          height: iconSize.sp,
          color: iconColor ?? AppColors.darkGrey,
        ),
        SizedBox(width: 4.sp),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: '$label ',
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.text,
                fontSize: fontSize.sp,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: value,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: fontSize.sp,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
