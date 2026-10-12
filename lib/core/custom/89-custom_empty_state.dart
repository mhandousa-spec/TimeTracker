/// Module: core / custom
///
///*************************** FILE INFO ****************************///
/// File Name: 89-custom_empty_state.dart
/// Purpose: Declares `CustomEmptyState`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The app's ONE empty state: the `lottie_empty` animation, no words.
///
/// WHY NO TEXT
/// -----------
/// Every list, table and filter result used to write its own sentence — "No
/// employees found", "Nobody has access yet", "No tables match", "No databases
/// yet". Four screens, four wordings, four translations, and all of them
/// saying the same thing the empty space already said. The animation carries
/// it, so the sentences went with it on 16/8/2026.
///
/// This deliberately takes NO label parameter. An optional one would grow
/// back into the same pile of near-identical strings within a week, and a
/// caller that genuinely needs to explain something — a FAILED read, which is
/// not the same as an empty one — should say so in its own widget rather than
/// dressing an error up as emptiness.
///
/// EMPTY IS NOT AN ERROR
/// ---------------------
/// Do not reach for this when a read FAILED. "There is nothing here" and "we
/// could not find out what is here" are different facts, and the screens that
/// tell them apart (the Database Builder list, the access table) keep their
/// own error branch with its retry. Showing this animation over a denied read
/// is the one message a user cannot argue with and cannot fix.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';

class CustomEmptyState extends StatelessWidget {
  const CustomEmptyState({super.key, this.size, this.verticalPadding});

  /// Width and height of the animation. Defaults to 160 — big enough to read
  /// as a deliberate state rather than a loading glitch, small enough to sit
  /// inside a card without pushing the buttons under it off screen.
  final double? size;

  /// Space above and below. Defaults to 24, which matches the 40 the text
  /// empty states used once the animation's own transparent margin is counted.
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    final double dimension = (size ?? 250).r;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: (verticalPadding ?? 24).h),
      child: Center(
        child: Lottie.asset(
          AppAssets.lottieEmpty,
          width: dimension,
          height: dimension,
          // Loops. A one-shot animation that has finished looks like a static
          // illustration that failed to load, and this is often the first
          // thing on an otherwise blank screen.
          repeat: true,
        ),
      ),
    );
  }
}
