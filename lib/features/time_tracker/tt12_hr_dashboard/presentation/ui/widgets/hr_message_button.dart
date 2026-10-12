/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_message_button.dart
/// Purpose: Declares `openTimeTrackerChat` (the one-to-one chat with a
///          colleague, from any Time Tracker screen) and `TtMessageButton`
///          (the yellow "Message" button, or its icon-only square).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Figma: HR dashboard employee card `661:43243` (135×38 yellow, "Chat Dots"
/// icon 24 + "Message"), the compact cards of `661:43247` (a 26 yellow
/// square with the icon), the employee dashboard `661:96459` and the
/// assigned-employee cards of Location details `661:39620`. The chat opens
/// through the messaging module's own entry point
/// (`MessagingInterfaceImplementation.tryOpenChatWithUser`, same as GRC /
/// User Management) and a failure says why (`showOpenChatFailure`).
/// MEDIUM haptic (core button), shrinks on tap.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/messaging_interface_implementation.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [openTimeTrackerChat]
///
/// Purpose: Open the chat with [email] (nothing for an empty e-mail).
///
/// Return type: [Future<void>]
Future<void> openTimeTrackerChat(BuildContext context, String email) async {
  if (email.trim().isEmpty) return;
  final OpenChatResult result =
      await MessagingInterfaceImplementation().tryOpenChatWithUser(context: context, userEmail: email);
  if (context.mounted) await showOpenChatFailure(context, result);
}

class TtMessageButton extends StatelessWidget {
  const TtMessageButton({super.key, required this.onTap, this.iconOnly = false});

  final VoidCallback onTap;

  /// The compact square of the small employee cards.
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final String label = S.of(context).message;
    if (iconOnly) {
      return Semantics(
        button: true,
        label: label,
        child: ShrinkOnTap(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticController.medium();
              onTap();
            },
            child: Container(
              width: 30.r,
              height: 30.r,
              padding: EdgeInsetsDirectional.all(5.r),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadiusDirectional.circular(6.r),
              ),
              child: CustomSvgImage(assetPath: AppAssets.message, color: AppColors.textButton),
            ),
          ),
        ),
      );
    }
    return ShrinkOnTap(
      child: customButtonWithSvg(
        title: label,
        function: onTap,
        color: AppColors.primary,
        colorBorder: AppColors.transparent,
        image: AppAssets.message,
        widthImage: 22.r,
        heightImage: 22.r,
        svgColor: AppColors.textButton,
        fixedWidth: 135.sp,
        fixedHeight: 38.sp,
        textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
      ),
    );
  }
}
