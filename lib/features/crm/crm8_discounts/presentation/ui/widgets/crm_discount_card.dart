// ****************** FILE INFO ******************
// File Name: crm_discount_card.dart
// Purpose: Card widget representing a single CRM Discount Rule in the grid matching Figma designs
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_card_info_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDiscountCard extends StatelessWidget {
  final CrmDiscountModel item;
  final VoidCallback? onTap;

  const CrmDiscountCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Left Box Icon Container (72x72) matching Figma
            Container(
              width: 72.sp,
              height: 72.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmDiscount,
                width: 48.sp,
                height: 48.sp,
                fit: BoxFit.contain,
                color: AppColors.text,
              ),
            ),
            SizedBox(width: 14.sp),

            // Content Column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Top Row: Rule Name + Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.localizedName(isArabic),
                          style:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      _buildStatusBadge(item.isActive),
                    ],
                  ),
                  SizedBox(height: 8.sp),

                  // Bottom Metadata Row: Type, Value, Teams using CrmCardInfoItem
                  Row(
                    children: <Widget>[
                      // Type
                      Expanded(
                        child: CrmCardInfoItem(
                          svgAsset: AppAssets.crmServices,
                          label: '${S.current.crmType}:',
                          value: item.displayType,
                          iconSize: 16,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8.sp),

                      // Value
                      Expanded(
                        child: CrmCardInfoItem(
                          svgAsset: AppAssets.crmTax,
                          label: '${S.current.crmValue}:',
                          value: item.formattedDiscountValue,
                          iconSize: 16,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8.sp),

                      // Teams
                      Expanded(
                        child: CrmCardInfoItem(
                          svgAsset: AppAssets.crmGroup,
                          label: '${S.current.crmTeams}:',
                          value: item.displayTeam,
                          iconSize: 16,
                          fontSize: 12,
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
        color: isActive ? AppColors.green : AppColors.darkGrey,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        isActive ? S.current.crmStatusActive : S.current.crmStatusInactive,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.background),
      ),
    );
  }
}
