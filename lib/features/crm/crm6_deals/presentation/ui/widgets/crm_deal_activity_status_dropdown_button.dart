// ****************** FILE INFO ******************
// File Name: crm_deal_activity_status_dropdown_button.dart
// Purpose: Status dropdown button for Deal Activity View mode with popup menu matching Image 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_activity_model.dart';

class CrmDealActivityStatusDropdownButton extends StatelessWidget {
  final CrmDealActivityStatus currentStatus;
  final ValueChanged<String> onStatusSelected;

  const CrmDealActivityStatusDropdownButton({
    super.key,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 42.sp),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      color: AppColors.white,
      elevation: 4,
      onSelected: onStatusSelected,
      itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'cancel',
          height: 36.sp,
          child: Text(
            'Cancel',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'completed',
          height: 36.sp,
          child: Text(
            'Completed',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
          ),
        ),
      ],
      child: Container(
        height: 38.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        decoration: BoxDecoration(
          color: currentStatus.color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              currentStatus.labelEn,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 6.sp),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.white,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}
