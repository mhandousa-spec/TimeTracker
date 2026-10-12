// ****************** FILE INFO ******************
// File Name: crm_product_category_card.dart
// Purpose: Responsive extracted card for a CRM product category.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';

class CrmProductCategoryCard extends StatelessWidget {
  final CrmProductCategoryModel category;
  final VoidCallback onTap;
  const CrmProductCategoryCard(
      {super.key, required this.category, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 38.sp,
                  height: 38.sp,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: CustomSvgImage(
                    assetPath: AppAssets.crmProducts,
                    width: 22.sp,
                    height: 22.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: isArabic ? 0 : 56.sp,
                      left: isArabic ? 56.sp : 0,
                    ),
                    child: Text(
                      category.localizedName(isArabic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
                decoration: BoxDecoration(
                  color: category.isActive ? AppColors.green : AppColors.orange,
                  borderRadius: BorderRadius.circular(4.sp),
                ),
                child: Text(
                  category.isActive ? 'Active' : 'Inactive',
                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
