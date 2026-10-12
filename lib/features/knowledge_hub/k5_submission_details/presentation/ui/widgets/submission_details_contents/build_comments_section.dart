/// Module: knowledge_hub / presentation / s5_submission_details / widgets/submission_details_contents/build_comments_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_comments_section.dart
/// Purpose: Build comments section — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../comments_section/build_comments_section_on_submitted_file.dart';


Widget buildCommentsSection(
  BuildContext context, {
  required bool lightMode,
  required bool showFullComments,
  required String knowledgeId,
  required void Function()? functionToShowFullComments,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min, // ✅ Important: Use min instead of max
    children: [
      _buildCommentsHeader(
        context,
        lightMode: lightMode,
        showFullComments: showFullComments,
        functionToShowFullComments: functionToShowFullComments,
      ),
      SizedBox(height: 15.h),
      // ✅ Wrap in Flexible instead of Expanded
      Flexible(
        child: buildCommentsSectionOnSubmittedFile(
          context,
          showFullComments: showFullComments,
          knowledgeId: knowledgeId,
          lightMode: lightMode,
        ),
      ),
    ],
  );
}

Widget _buildCommentsHeader(
  BuildContext context, {
  required bool lightMode,
  required void Function()? functionToShowFullComments,
  required bool showFullComments,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        S.of(context).inquiries_and_comments,
        style: StyleText.fontSize18Weight500.copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
      ),
      GestureDetector(
        onTap: functionToShowFullComments,
        child: Column(
          children: [
            Text(
              showFullComments ? S.of(context).collapse : S.of(context).expand,
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.lightBlue,
              ),
            ),
            Container(
              height: 1,
              color: AppColors.lightBlue,
              width: _getTextWidth(
                showFullComments
                    ? S.of(context).collapse
                    : S.of(context).expand,
                StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.lightBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

double _getTextWidth(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.width;
}
