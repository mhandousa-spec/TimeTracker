/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/create_knowledge_action_buttons.dart
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_action_buttons.dart
/// Purpose: Action buttons (save / submit) for the create-knowledge form.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

Widget createKnowledgeActionButtons(
  BuildContext context, {
  required void Function() functionToHandleSubmitting,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final lightMode = Theme.of(context).brightness == Brightness.light;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      customButton(
        height: 38.h,
        width: isMobile ? 150.w : 185.w,
        title: S.of(context).discard,
        textStyle: StyleText.fontSize16Weight500.copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
        function: () => Navigator.of(context).pop(),
        color: AppColors.darkerGrey,
      ),
      const Spacer(),
      customButton(
        height: 38.h,
        width: isMobile ? 150.w : 185.w,
        textStyle: StyleText.fontSize14Weight500.copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
        title: S.of(context).submit_for_approval,
        function: functionToHandleSubmitting,
      ),
    ],
  );
}
