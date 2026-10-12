// ****************** FILE INFO ******************
// File Name: crm_deals_empty_state.dart
// Purpose: Reusable empty state view for Deals categories and stages
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmDealsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const CrmDealsEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomSvgImage(
              assetPath: AppAssets.crmRelationshipEmpty,
              width: 140.sp,
              height: 140.sp,
            ),
            SizedBox(height: 16.sp),
            Text(
              title,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.sp),
            Text(
              subtitle,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
