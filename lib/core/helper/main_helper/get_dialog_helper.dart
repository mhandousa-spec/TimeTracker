/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: get_dialog_helper.dart
/// Purpose: Declares `GetDialogHelper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

// Youssef Ashraf
abstract class GetDialogHelper {
  static Future generalDialog({
    required Widget child,
    required BuildContext context,
    bool? barrierDismissible,
  }) {
    return showGeneralDialog(
        barrierLabel: "",
        barrierDismissible: barrierDismissible ?? false,
        context: context,
        transitionDuration: const Duration(
          milliseconds: 400,
        ),
        pageBuilder: (_, __, ___) {
          return Dialog(
            clipBehavior: Clip.none,
            insetPadding: EdgeInsets.zero,
            backgroundColor: AppColors.dialog,
            elevation: 0,
            shadowColor: Colors.transparent,
            child: child,
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          );
        });
  }
}
