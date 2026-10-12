/// Module: knowledge_hub / presentation / s5_submission_details / widgets/build_submitted_document_data_row.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_submitted_document_data_row.dart
/// Purpose: Build submitted document data row — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


Widget buildInfoRow({
  required String label,
  required String value,
  required String iconPath,
  required bool lightMode,
}) {
  return Row(
    children: [
      CustomSvgImage(assetPath: iconPath,fit: BoxFit.fill,width: 16.w,height: 16.h,),
      SizedBox(width: 5.w),
      Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(
          overflow: TextOverflow.ellipsis,
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
      ),
      Text(
        FormatHelper.capitalize(value),
        style: StyleText.fontSize14Weight400.copyWith(
          color: lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
      ),
    ],
  );
}

Widget buildSubmittedDocumentDescription(
  BuildContext context, {
  required String documentDescription,
  required bool isMobile,
  required bool lightMode,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/doc_des.svg',
            fit: BoxFit.fill,
            width: 16.w,
            height: 16.h,
          ),
          SizedBox(width: 5.w),
          //submission details screen
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${S.of(context).document_description}: ",
                style: StyleText.fontSize12Weight400.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
              Text(
                  FormatHelper.capitalize(documentDescription),
                  maxLines: null,
                  style: StyleText.fontSize12Weight400.copyWith(color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white)
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 4.h),

    ],
  );
}
