/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_button_with_icon.dart
/// Purpose: Widget used by the feature's screens.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';

Widget customButtonWithIcon({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width, // optional & ignored: sizing is enforced by ButtonSizing
  double? height, // optional & ignored: sizing is enforced by ButtonSizing
  double space = 8,
  double? radius, // optional & ignored: sizing is enforced by ButtonSizing
  required Color color,
  required IconData icon,
  required Color iconColor,
  required double iconSize,
}) {
  return Builder(
    builder: (context) {
      // 38.sp (mobile) / 135.sp (tablet), or null when the content
      // doesn't fit (then wrap with 12.sp horizontal padding).
      final double? buttonWidth = ButtonSizing.width(
        context,
        title: title,
        textStyle: textStyle,
        extraContentWidth: iconSize + space,
      );

      final Widget row = Row(
        mainAxisSize:
            buttonWidth == null ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          SizedBox(width: space),
          Text(title, style: textStyle),
        ],
      );

      return GestureDetector(
        onTap: () {
          HapticController.medium(); // action button
          function();
        },
        child: Container(
          width: buttonWidth,
          height: ButtonSizing.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(ButtonSizing.radius),
          ),
          child: buttonWidth == null
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ButtonSizing.horizontalPadding,
                  ),
                  child: row,
                )
              : row,
        ),
      );
    },
  );
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────
// Sizing is enforced app-wide by ButtonSizing:
// width 38.sp (mobile) / 135.sp (tablet), height 38.sp, radius 8.r.
// If the content doesn't fit, the button wraps it with 12.sp horizontal padding.
customButtonWithIcon(
  title: 'Add',
  function: () {},
  textStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.white),
  color: AppColors.primary,
  icon: Icons.add,
  iconColor: AppColors.white,
  iconSize: 20,
)
*/
