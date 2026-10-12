/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: circle_progress_master.dart
/// Purpose: Declares `CircleProgressMaster` and the app's modal loading
///          overlay — the ONE home for "something is in progress".
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 10/9/2026 - Absorbed `83-loading.dart`, which is deleted.
///
/// WHY THERE IS ONLY ONE OF THESE NOW
/// `83-loading.dart` held a second spinner widget, `CircleProgress`, and the
/// two `showLoadingIndicator` / `hideLoadingIndicator` helpers. The two widgets
/// were the same control drawn differently — `CircleProgress` in
/// `secondaryPrimary` at whatever size its parent happened to give it,
/// `CircleProgressMaster` in `lightPrimary` at a fixed fraction of the screen —
/// so which spinner a screen showed came down to which file its author had
/// imported. Every `CircleProgress` is a `CircleProgressMaster` now.
///
/// The two overlay helpers moved here UNCHANGED. They are not built on
/// `CircleProgressMaster`: the modal draws a deliberately larger 70pt ring, and
/// rebuilding it on the inline widget would have silently shrunk every loading
/// dialog in the app.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

// date:April/30/2024
// by:MohamedFouad
// lastUpdate:April/30/2024
// This class is used to create a circular progress indicator with a light primary color.
// It is used to indicate that an operation is in progress.
class CircleProgressMaster extends StatelessWidget {
  const CircleProgressMaster({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Center(
      child: SizedBox(
        width: isTablet
            ? orientation
                ? .045.h
                : .06.h
            : .045.h,
        height: isTablet
            ? orientation
                ? .045.h
                : .06.h
            : .045.h,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPrimary),
          backgroundColor: AppColors.white.withOpacity(0.6),
          strokeWidth: 2.0,
        ),
      ),
    );
  }
}

/// Full-screen modal loading overlay.
///
/// Canonical home for the app's loading indicator: every feature calls these
/// two instead of rolling its own overlay.
///
/// MOVED 10/9/2026 from `83-loading.dart`, byte for byte — see the file header.
Future showLoadingIndicator() {
  double size = 70;
  return Get.dialog(
    Scaffold(
      backgroundColor: AppColors.transparent,
      body: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPrimary),
            backgroundColor: AppColors.white.withOpacity(0.6),
            strokeWidth: 2.0,
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: AppColors.totalBlack.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 700),
  );
}

hideLoadingIndicator() {
  Get.back();
}
