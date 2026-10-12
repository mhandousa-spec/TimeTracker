// ****************** FILE INFO ******************
// File Name: crm_deal_category_card.dart
// Purpose: Extracted grid item card for CRM Deal Categories matching Figma design
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';

class CrmDealCategoryCard extends StatelessWidget {
  final CrmDealCategoryModel category;
  final bool isEditMode;
  final String displayTitle;
  final String statusLabel;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteTap;

  const CrmDealCategoryCard({
    super.key,
    required this.category,
    required this.displayTitle,
    required this.statusLabel,
    this.isEditMode = false,
    this.onTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.sp),
      child: Container(
        height: 44.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Row(
          children: <Widget>[
            CustomSvgImage(
              assetPath: AppAssets.crmSections,
              width: 20.sp,
              height: 20.sp,
              color: AppColors.black,
            ),
            SizedBox(width: 8.sp),
            Expanded(
              child: Text(
                displayTitle,
                style: StyleText.fontSize14Weight400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isEditMode) ...[
              SizedBox(width: 8.sp),
              GestureDetector(
                onTap: onDeleteTap,
                behavior: HitTestBehavior.opaque,
                child: CustomSvgImage(
                  assetPath: AppAssets.minusCircle,
                  width: 20.sp,
                  height: 20.sp,
                ),
              ),
            ] else ...[
              SizedBox(width: 8.sp),
              _buildStatusBadge(category.isActive, statusLabel),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.orange,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        label,
        style: StyleText.fontSize10Weight600.copyWith(color: Colors.white),
      ),
    );
  }
}
