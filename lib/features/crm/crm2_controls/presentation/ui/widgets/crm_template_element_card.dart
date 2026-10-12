// ****************** FILE INFO ******************
// File Name: crm_template_element_card.dart
// Purpose: Shared card for CRM template fields and sections.
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_demo_data.dart';

class CrmTemplateElementCard extends StatelessWidget {
  const CrmTemplateElementCard({
    required this.element,
    this.onTap,
    super.key,
  });

  final CrmTemplateElementData element;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          children: [
            CustomSvgImage(
              assetPath: element.assetPath,
              width: 22.sp,
              height: 22.sp,
              color: AppColors.secondaryBlack,
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: element.title,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.secondaryBlack,
                      ),
                    ),
                    TextSpan(
                      text: ' | ${element.subtitle}',
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (element.badgeCount != null) ...[
              SizedBox(width: 8.sp),
              Text(
                '${element.badgeCount}',
                style: StyleText.fontSize16Weight600.copyWith(
                  color: AppColors.secondaryBlack,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
