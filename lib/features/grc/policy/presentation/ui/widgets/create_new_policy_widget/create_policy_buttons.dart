/// The Back + Save-For-Later button column shared by every step of the
/// Create Policy flow, plus a caller-supplied trailing action button.
/// Replaces CreatePolicyStep1Buttons and CreatePolicyStep2Buttons, which
/// were the same widget with a different trailing button hardcoded in.
library;

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CreatePolicyBackSaveButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSaveForLater;
  final Widget trailingButton;

  /// Whether to draw "Save For Later" -- the Draft_Policy switch. Defaults to
  /// true so the widget is unchanged for any caller that has not gated itself.
  final bool showSaveForLater;

  const CreatePolicyBackSaveButtons({
    super.key,
    required this.onBack,
    required this.onSaveForLater,
    required this.trailingButton,
    this.showSaveForLater = true,
  });

  @override
  Widget build(BuildContext context) {
    final saveForLater = customButton(
      title: S.of(context).saveForLater,
      function: onSaveForLater,
      height: 38.sp,
      width: 150.sp,
      color: AppColors.darkGrey,
      textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
    );

    // iPhone (375) draws a single action row -- Save For Later on the
    // leading edge, the step's primary action on the trailing edge -- and
    // no Back button, because the phone app bar already shows a back arrow
    // (CreateNewPolicyPage's PopScope turns it into "go back one step").
    //
    // iPad (768) and desktop (1024) keep the stacked Back + Save For Later
    // column. The design drops Back at those sizes too and leaves going
    // back to the breadcrumb, but the breadcrumb is not tappable yet, so
    // removing the button here would strand the user on steps 1 and 2.
    if (screenSizeOf(context) == ScreenSize.mobile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Without Save For Later the phone row is just the primary action,
          // which MainAxisAlignment.spaceBetween pushes to the trailing edge
          // -- where the design puts it.
          if (showSaveForLater) ...[
            Flexible(child: saveForLater),
            SizedBox(width: 10.w),
          ],
          Flexible(child: trailingButton),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            customButton(
              title: S.of(context).back,
              function: onBack,
              height: 38.sp,
              width: 150.sp,
              color: AppColors.darkGrey,
              textStyle:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
            ),
            if (showSaveForLater) ...[
              SizedBox(height: 10.h),
              saveForLater,
            ],
          ],
        ),
        trailingButton,
      ],
    );
  }
}
