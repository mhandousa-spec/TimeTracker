/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/build_publish_date.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_publish_date.dart
/// Purpose: Displays the publish date badge
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';



Widget buildPublishDate(BuildContext context, {required String publishDate}) {
  final lightMode = Theme.of(context).brightness == Brightness.light;

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today,
          size: 14.sp,
          color: AppColors.colorWhite,
        ),
        SizedBox(width: 6.w),
        Text(
          '${S.of(context).publish_date}: $publishDate',
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.colorWhite,
          ),
        ),
      ],
    ),
  );
}