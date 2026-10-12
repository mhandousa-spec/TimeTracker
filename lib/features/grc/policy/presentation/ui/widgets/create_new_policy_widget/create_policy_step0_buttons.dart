/// Module: GRC Policy Management
/// Description: Bottom action buttons for step 0 (Policy Info) of the
///              Create Policy page — Discard and Next.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-16
/// Dependencies: Flutter SDK, AppColors, StyleText, customButton
/// Revision History: 2026-07-16 - Extracted from create_new_policy.dart
library;

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
/// ************************* FILE INFO *************************** ///
/// File Name: create_policy_step0_buttons.dart
/// Purpose: Contains CreatePolicyStep0Buttons, the Discard/Next button row
///          shown on step 0 of CreateNewPolicyPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 16/7/2026

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [CreatePolicyStep0Buttons]
///
/// purpose: Discard/Next button row for step 0. All validation, dialogs,
///          and step transitions are handled by the parent page via the
///          callbacks; this widget only renders the row.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 16/7/2026
class CreatePolicyStep0Buttons extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onNext;

  /// Whether Next is actionable. False greys the button out and makes the
  /// tap a no-op -- step 0 only lets the user move on once every required
  /// field, date, dropdown and document is filled in (and, when resuming a
  /// saved Draft, once something has actually changed). Defaults to true so
  /// any other call site keeps its old behaviour.
  final bool nextEnabled;

  const CreatePolicyStep0Buttons({
    super.key,
    required this.onDiscard,
    required this.onNext,
    this.nextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: S.of(context).discard,
          function: onDiscard,
          height: 38.h,
          width: 150.w,
          color: AppColors.darkGrey,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        customButton(
          title: S.of(context).next,
          function: nextEnabled ? onNext : () {},
          height: 38.h,
          width: 150.w,
          color: nextEnabled ? AppColors.primary : AppColors.colorGrey,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}
