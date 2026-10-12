// ****************** FILE INFO ******************
// File Name: crm_control_card.dart
// Purpose: Extracted card widget for displaying individual control menu items in grid view
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_control_item_model.dart';

class CrmControlCard extends StatelessWidget {
  final CrmControlItemModel item;

  const CrmControlCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: isMobile
            ? EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp)
            : EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  /// Mobile layout: small top row with yellow box + title, description underneath
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top Row: Yellow Icon Box + Title
        Row(
          children: [
            Container(
              width: 24.sp,
              height: 24.sp,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6.sp),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: item.svgAsset,
                width: 14.sp,
                height: 14.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 8.sp),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize14Weight600.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.sp),

        // Description
        Text(
          item.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize10Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  /// Desktop/Tablet layout: horizontal split with large yellow icon box on left
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Yellow Accent Rounded Container for Icon
        Container(
          width: 42.sp,
          height: 42.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          alignment: Alignment.center,
          child: CustomSvgImage(
            assetPath: item.svgAsset,
            width: 22.sp,
            height: 22.sp,
            color: AppColors.black,
          ),
        ),
        SizedBox(width: 12.sp),

        // Title & Description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize16Weight600.copyWith(
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 4.sp),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
