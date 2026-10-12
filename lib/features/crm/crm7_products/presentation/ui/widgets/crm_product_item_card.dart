// ****************** FILE INFO ******************
// File Name: crm_product_item_card.dart
// Purpose: Grid item card widget for CRM Products matching Figma designs.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmProductItemCard extends StatelessWidget {
  final CrmProductItemModel product;
  final VoidCallback onTap;

  const CrmProductItemCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String displayName = isArabic
        ? (product.nameAr.isNotEmpty ? product.nameAr : product.nameEn)
        : (product.nameEn.isNotEmpty ? product.nameEn : product.nameAr);
    final String categoryName = isArabic
        ? (product.categoryNameAr.isNotEmpty
            ? product.categoryNameAr
            : product.categoryNameEn)
        : (product.categoryNameEn.isNotEmpty
            ? product.categoryNameEn
            : product.categoryNameAr);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Left Box Icon Container matching Figma
            Container(
              width: 72.sp,
              height: 72.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmProducts,
                width: 44.sp,
                height: 44.sp,
                color: AppColors.text,
              ),
            ),
            SizedBox(width: 14.sp),

            // Middle and Right Information matching Figma
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Top Title & Status Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          displayName,
                          style:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      _buildStatusBadge(product.isActive),
                    ],
                  ),
                  SizedBox(height: 6.sp),

                  // Detail Row 1: Code and Price
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmHash,
                              width: 14.sp,
                              height: 14.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Code:',
                            value: product.code.isNotEmpty ? product.code : '-',
                          ),
                          fontSize: 12.sp,
                          iconSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmPrice,
                              width: 14.sp,
                              height: 14.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Price:',
                            value:
                                '${product.unitPrice.toStringAsFixed(0)} ${product.currencyEnum.localizedSymbol(isArabic)}',
                          ),
                          fontSize: 12.sp,
                          iconSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.sp),

                  // Detail Row 2: Category and Tax
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmCategoryIcon,
                              width: 14.sp,
                              height: 14.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Category:',
                            value: categoryName.isNotEmpty ? categoryName : '-',
                          ),
                          fontSize: 12.sp,
                          iconSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmTax,
                              width: 14.sp,
                              height: 14.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Tax:',
                            value: '${product.tax.toStringAsFixed(0)}%',
                          ),
                          fontSize: 12.sp,
                          iconSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.orange,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        isActive ? S.current.crmActive : S.current.crmInactive,
        style: StyleText.fontSize10Weight600.copyWith(color: Colors.white),
      ),
    );
  }
}
