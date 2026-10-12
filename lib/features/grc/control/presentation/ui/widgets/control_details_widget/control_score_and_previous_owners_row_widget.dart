/// Module: GRC Policy Management
/// Description: Score badge + "Previous Control Owners" button row for the
///              Control Details page, extracted from ControlDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter, CustomButton
/// Revision History: 2026-07-21 - Initial creation (inline in
///                                control_details_page.dart)
///                   2026-07-28 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_score_and_previous_owners_row_widget.dart
/// Purpose: Contains ControlScoreAndPreviousOwnersRowWidget, the Score
///          badge paired with the "Previous Control Owners" button.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [ControlScoreAndPreviousOwnersRowWidget]
///
/// purpose: renders the Control's Score badge next to the "Previous
///          Control Owners" button.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/7/2026
class ControlScoreAndPreviousOwnersRowWidget extends StatelessWidget {
  final int score;
  final VoidCallback onPreviousOwnersTap;

  /// Whether to draw the "Previous Control Owners" button -- the
  /// Previous_Control_Owners switch. Defaults to true so the widget is
  /// unchanged for any caller that has not gated itself.
  final bool showPreviousOwners;

  const ControlScoreAndPreviousOwnersRowWidget({
    super.key,
    required this.score,
    required this.onPreviousOwnersTap,
    this.showPreviousOwners = true,
  });

  @override
  Widget build(BuildContext context) {
    // 768 / 1024 sit the score badge and the button at opposite ends of one
    // row. At 375 "Previous Control Owners" is a long label, so the pair is
    // laid out in a Wrap: still one line when it fits, and the button drops
    // to its own trailing-aligned line when it does not, instead of
    // overflowing.
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    final Widget scoreBadge = Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text.rich(
            TextSpan(
              text: '${S.of(context).score}: ',
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
              children: [
                TextSpan(
                  text: '$score',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: AppColors.green),
                ),
              ],
            ),
          ),
        );

    // With the button gone the score badge is the whole row -- returned bare
    // so spaceBetween has nothing to push it against and it stays leading.
    if (!showPreviousOwners) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: scoreBadge,
      );
    }

    final Widget previousOwnersButton = customButton(
      title: S.of(context).previousControlOwners,
      function: onPreviousOwnersTap,
      height: 38.h,
      color: AppColors.primary,
      width: 200.sp,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
    );

    if (isMobile) {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [scoreBadge, previousOwnersButton],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [scoreBadge, previousOwnersButton],
    );
  }
}
