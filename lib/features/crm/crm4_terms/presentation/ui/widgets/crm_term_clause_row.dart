// ****************** FILE INFO ******************
// File Name: crm_term_clause_row.dart
// Purpose: Responsive bilingual term clause row matching CRM Terms mobile/tablet design
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmTermClauseRow extends StatelessWidget {
  final int index;
  final TextEditingController controllerEn;
  final TextEditingController controllerAr;
  final VoidCallback? onDelete;
  final bool isReadOnly;
  final bool canDelete;

  const CrmTermClauseRow({
    super.key,
    required this.index,
    required this.controllerEn,
    required this.controllerAr,
    this.onDelete,
    this.isReadOnly = false,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title with remove button on the far right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  isArabic ? 'شرط ${index + 1}' : 'Term ${index + 1}',
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                if (!isReadOnly && canDelete && onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: CustomSvgImage(
                      assetPath: AppAssets.minusCircle,
                      width: 22.sp,
                      height: 22.sp,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.sp),

            // English Text Field
            CustomTextField(
              controller: controllerEn,
              hint: 'Text Here',
              readOnly: isReadOnly,
              textDirection: TextDirection.ltr,
            ),
            SizedBox(height: 10.sp),

            // Arabic Text Field (RTL)
            Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: controllerAr,
                hint: 'اكتب هنا',
                readOnly: isReadOnly,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    // Tablet / Desktop Layout: 2-column row with delete icon on the right
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: CustomTextField(
              controller: controllerEn,
              hint: 'Text Here',
              readOnly: isReadOnly,
              textDirection: TextDirection.ltr,
            ),
          ),
          SizedBox(width: 15.sp),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: controllerAr,
                hint: 'اكتب هنا',
                readOnly: isReadOnly,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          if (!isReadOnly && canDelete && onDelete != null) ...<Widget>[
            SizedBox(width: 12.sp),
            GestureDetector(
              onTap: onDelete,
              child: CustomSvgImage(
                assetPath: AppAssets.minusCircle,
                width: 22.sp,
                height: 22.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
