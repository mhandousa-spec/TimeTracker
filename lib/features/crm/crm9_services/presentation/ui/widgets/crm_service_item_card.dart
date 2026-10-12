// ****************** FILE INFO ******************
// File Name: crm_service_item_card.dart
// Purpose: Grid item card widget for CRM Services matching design specifications.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmServiceItemCard extends StatelessWidget {
  final CrmServiceItemModel service;
  final VoidCallback onTap;

  const CrmServiceItemCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String displayName = isArabic
        ? (service.nameAr.isNotEmpty ? service.nameAr : service.nameEn)
        : (service.nameEn.isNotEmpty ? service.nameEn : service.nameAr);
    final String categoryName = isArabic
        ? (service.categoryNameAr.isNotEmpty
            ? service.categoryNameAr
            : service.categoryNameEn)
        : (service.categoryNameEn.isNotEmpty
            ? service.categoryNameEn
            : service.categoryNameAr);

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
            // Left Box Icon Container
            Container(
              width: 72.sp,
              height: 72.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmServices,
                width: 44.sp,
                height: 44.sp,
                color: AppColors.text,
              ),
            ),
            SizedBox(width: 14.sp),

            // Middle and Right Information
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
                      _buildStatusBadge(service.isActive),
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
                            label: '${S.current.crmCode}:',
                            value: service.code.isNotEmpty ? service.code : '-',
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
                            label: '${S.current.unitPrice}:',
                            value:
                                '${service.unitPrice.toStringAsFixed(0)} ${service.currencyEnum.localizedSymbol(isArabic)}',
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
                            label: '${S.current.crmCategory}:',
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
                            label: '${S.current.vat}:',
                            value: '${service.tax.toStringAsFixed(0)}%',
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
