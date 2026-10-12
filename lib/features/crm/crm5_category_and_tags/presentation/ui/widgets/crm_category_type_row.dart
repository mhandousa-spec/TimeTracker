// ****************** FILE INFO ******************
// File Name: crm_category_type_row.dart
// Purpose: Row widget for editing or viewing individual category types matching mobile/tablet Figma
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmCategoryTypeRow extends StatelessWidget {
  final int index;
  final TextEditingController enController;
  final TextEditingController arController;
  final String? enErrorText;
  final String? arErrorText;
  final ValueChanged<String>? onEnChanged;
  final ValueChanged<String>? onArChanged;
  final bool isReadOnly;
  final bool canDelete;
  final VoidCallback? onRemove;

  const CrmCategoryTypeRow({
    super.key,
    required this.index,
    required this.enController,
    required this.arController,
    this.enErrorText,
    this.arErrorText,
    this.onEnChanged,
    this.onArChanged,
    this.isReadOnly = false,
    this.canDelete = true,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  isArabic ? 'نوع ${index + 1}' : 'Type ${index + 1}',
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                  ),
                ),
                if (!isReadOnly && canDelete && onRemove != null)
                  GestureDetector(
                    onTap: onRemove,
                    child: CustomSvgImage(
                      assetPath: AppAssets.minusCircle,
                      width: 20.sp,
                      height: 20.sp,
                      color: AppColors.delete,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: enController,
              hint: 'Text Here',
              errorText: enErrorText,
              readOnly: isReadOnly,
              textDirection: TextDirection.ltr,
              onChanged: onEnChanged,
            ),
            SizedBox(height: 10.h),
            Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: arController,
                hint: 'اكتب هنا',
                errorText: arErrorText,
                readOnly: isReadOnly,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                onChanged: onArChanged,
              ),
            ),
          ],
        ),
      );
    }

    // Tablet / Desktop layout
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: CustomTextField(
              controller: enController,
              hint: 'Text Here',
              errorText: enErrorText,
              readOnly: isReadOnly,
              textDirection: TextDirection.ltr,
              onChanged: onEnChanged,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: arController,
                hint: 'اكتب هنا',
                errorText: arErrorText,
                readOnly: isReadOnly,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                onChanged: onArChanged,
              ),
            ),
          ),
          if (!isReadOnly && canDelete && onRemove != null) ...<Widget>[
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: onRemove,
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
    );
  }
}
