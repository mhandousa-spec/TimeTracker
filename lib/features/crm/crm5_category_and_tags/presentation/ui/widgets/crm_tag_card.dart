// ****************** FILE INFO ******************
// File Name: crm_tag_card.dart
// Purpose: Extracted grid item card for CRM Activity Tags
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';

class CrmTagCard extends StatelessWidget {
  final CrmTagModel tag;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteTap;

  const CrmTagCard({
    super.key,
    required this.tag,
    this.isEditMode = false,
    this.onTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String title = isArabic ? tag.nameAr : tag.nameEn;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 44.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: <Widget>[
            CustomSvgImage(
              assetPath: AppAssets.crmTagField,
              width: 22.sp,
              height: 22.sp,
              color: AppColors.black,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title.isNotEmpty ? title : 'Tag',
                style: StyleText.fontSize14Weight400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isEditMode) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onDeleteTap,
                child: CustomSvgImage(
                  assetPath: AppAssets.minusCircle,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.delete,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
