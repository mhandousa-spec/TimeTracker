/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/build_comments_header.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_comments_header.dart
/// Purpose: Contains the address of comments section for file info.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildCommentsHeader(
  BuildContext context, {
  required void Function()? onTap,
  required bool showFullComments,
}) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        S.of(context).inquiries_and_comments,
        style: StyleText.fontSize18Weight500.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
      ),
      GestureDetector(
        onTap: onTap,
        // onTap: () => setState(() => showFullComments = !showFullComments),
        child: Text(
          showFullComments ? S.of(context).collapse : S.of(context).expand,
          style: StyleText.fontSize12Weight500.copyWith(
            color: lightMode
                ? AppColors.secondaryText
                : AppColors.grey,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ],
  );
}
