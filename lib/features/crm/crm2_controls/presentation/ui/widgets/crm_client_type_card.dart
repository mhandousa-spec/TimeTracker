// ****************** FILE INFO ******************
// File Name: crm_client_type_card.dart
// Purpose: Extracted card widget displaying an individual Client Type card
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';

class CrmClientTypeCard extends StatelessWidget {
  final CrmClientTypeModel item;

  const CrmClientTypeCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.iconUrl.isNotEmpty)
              ClipOval(
                child: Image.network(
                  item.iconUrl,
                  width: 22.sp,
                  height: 22.sp,
                  fit: BoxFit.cover,
                ),
              )
            else
              CustomSvgImage(
                assetPath: item.svgAsset,
                width: 22.sp,
                height: 22.sp,
                color: AppColors.black,
              ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
