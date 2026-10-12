/// Module: knowledge_hub / presentation / s5_submission_details / widgets/build_submission_date.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_submission_date.dart
/// Purpose: Build submission date — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildSubmissionDate(
  BuildContext context, {
  required String submissionDate,
}) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        "${S.of(context).submissionDate}: ",
        style: StyleText.fontSize10Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
      ),
      Text(
        submissionDate,
        style: StyleText.fontSize10Weight400.copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
      ),
    ],
  );
}
