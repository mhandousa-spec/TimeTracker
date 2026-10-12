// ****************** FILE INFO ******************
// File Name: crm_template_section_card.dart
// Purpose: Section card used by the CRM template builder.
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmTemplateSectionCard extends StatelessWidget {
  const CrmTemplateSectionCard({
    required this.title,
    required this.fieldCount,
    required this.onTap,
    super.key,
  });

  final String title;
  final int fieldCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        height: 36.sp,
        padding: EdgeInsets.symmetric(horizontal: 14.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          children: [
            CustomSvgImage(
              assetPath: AppAssets.crmSections,
              width: 20.sp,
              height: 20.sp,
              color: AppColors.secondaryBlack,
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '  |  ',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    TextSpan(
                      text: '$fieldCount Fields',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
