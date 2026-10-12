/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_button_with_svg.dart
/// Purpose: Widget used by the feature's screens.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

Widget customButtonWithSvg({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width, // optional & ignored: sizing is enforced by ButtonSizing
  double? height, // optional & ignored: sizing is enforced by ButtonSizing

  /// ADDED 19/8/2026. Deliberately NOT `width` — dozens of call sites already
  /// pass a stale `width:` that the app-wide ButtonSizing rule is meant to
  /// override, and honouring those would resize buttons across the whole app.
  /// `fixedWidth` is the opt-in escape hatch for a call site that is pinned to
  /// a Figma spec instead: pass it and this button uses that width, leave it
  /// null and nothing changes.
  double? fixedWidth,

  /// Height twin of [fixedWidth], and ignored the same way `height:` is.
  /// ADDED 19/8/2026 for the Form Builder's "+ Row" button, which Figma
  /// (MESBAH / node 7444-41969) draws 30 tall against the app-wide 38.
  double? fixedHeight,

  /// Radius twin of [fixedWidth]. The Form Builder's small "+ Row" / "Break
  /// Page" pair use a tighter corner than the app-wide 8.
  double? fixedRadius,
  double space = 8,
  double? radius, // optional & ignored: sizing is enforced by ButtonSizing
  required Color color,
  required String image,
  required double widthImage,
  required double heightImage,
  required Color colorBorder,
  Color? svgColor,
  EdgeInsets? padding, // ignored: sizing is enforced by ButtonSizing
}) {
  return Builder(
    builder: (context) {
      final bool iconOnly = title.trim().isEmpty && image.isNotEmpty;

      // Icon-only buttons are always 38.sp × 38.sp (or `fixedWidth` when the
      // call site pins one).
      // Text buttons: 38.sp (mobile) / 135.sp (tablet) / `fixedWidth`, or null
      // when the content doesn't fit (then wrap with 12.sp horizontal padding).
      final double? buttonWidth = iconOnly
          ? (fixedWidth ?? ButtonSizing.iconButtonSize)
          : ButtonSizing.width(
              context,
              title: title,
              textStyle: textStyle,
              extraContentWidth: image.isNotEmpty ? widthImage + space : 0,
              fixedWidth: fixedWidth,
            );

      Widget content;
      if (iconOnly) {
        content = Center(
          child: CustomSvgImage(
            assetPath: image,
            height: heightImage,
            width: widthImage,
            color: svgColor ?? AppColors.textButton,
            fit: BoxFit.scaleDown,
          ),
        );
      } else {
        final Widget inner = image.isNotEmpty
            ? Row(
                mainAxisSize:
                    buttonWidth == null ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomSvgImage(
                    assetPath: image,
                    height: heightImage,
                    width: widthImage,
                    color: svgColor,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(width: space),
                  Text(title, style: textStyle),
                ],
              )
            : Center(
                widthFactor: buttonWidth == null ? 1 : null,
                child: Text(title, style: textStyle),
              );

        content = buttonWidth == null
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ButtonSizing.horizontalPadding,
                ),
                child: inner,
              )
            : inner;
      }

      return GestureDetector(
        onTap: () {
          HapticController.medium(); // action button
          function();
        },
        child: Container(
          width: buttonWidth,
          height: fixedHeight ?? ButtonSizing.height,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: colorBorder),
            borderRadius:
                BorderRadius.circular(fixedRadius ?? 8.r),
          ),
          child: content,
        ),
      );
    },
  );
}

/*
// ── Usage ─────────────────────────────────────────────────────────────────────
// Sizing is enforced app-wide by ButtonSizing:
// width 38.sp (mobile) / 135.sp (tablet), height 38.sp, radius 8.r.
// Icon-only buttons (empty title) are always 38.sp × 38.sp.
// If the content doesn't fit, the button wraps it with 12.sp horizontal padding.

// Icon + text
customButtonWithSvg(
  title: 'Export',
  function: () {},
  textStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.textButton),
  color: AppColors.primary,
  image: 'assets/icons_assets/main_icons_assets/export_arrow.svg',
  widthImage: 20,
  heightImage: 20,
  colorBorder: AppColors.transparent,
  svgColor: AppColors.textButton,
)

// Icon only (empty title) → 38.sp × 38.sp
customButtonWithSvg(
  title: '',
  function: () {},
  textStyle: StyleText.fontSize14Weight400,
  color: AppColors.primary,
  image: 'assets/icons_assets/main_icons_assets/plus.svg',
  widthImage: 20,
  heightImage: 20,
  colorBorder: AppColors.transparent,
)
*/
