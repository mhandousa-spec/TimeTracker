// ****************** FILE INFO ******************
// File Name: crm_template_field_card.dart
// Purpose: Field card used by the CRM template builder.
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmTemplateFieldCard extends StatelessWidget {
  const CrmTemplateFieldCard({
    required this.title,
    required this.fieldTypeLabel,
    required this.iconKey,
    required this.onTap,
    this.trailingText,
    this.showCircleIcon = false,
    super.key,
  });

  final String title;
  final String fieldTypeLabel;
  final String iconKey;
  final VoidCallback onTap;
  final String? trailingText;
  final bool showCircleIcon;

  @override
  Widget build(BuildContext context) {
    final String displayTitle = title.isEmpty ? fieldTypeLabel : title;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        height: showCircleIcon ? 56.sp : 36.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          children: [
            if (showCircleIcon)
              Container(
                width: 36.sp,
                height: 36.sp,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: CustomSvgImage(
                  assetPath: _assetForIconKey(iconKey),
                  width: 18.sp,
                  height: 18.sp,
                  color: AppColors.black,
                ),
              )
            else
              CustomSvgImage(
                assetPath: _assetForIconKey(iconKey),
                width: 18.sp,
                height: 18.sp,
                color: AppColors.secondaryBlack,
              ),
            SizedBox(width: 10.sp),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: displayTitle,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.secondaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (trailingText != null && trailingText!.isNotEmpty) ...[
              SizedBox(width: 8.sp),
              Text(
                trailingText!,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _assetForIconKey(String key) {
    final String normalizedKey = key.trim().toLowerCase();
    if (normalizedKey.contains('company')) return AppAssets.crmCompanySizeField;
    if (normalizedKey.contains('sector')) return AppAssets.crmSectorField;
    if (normalizedKey.contains('industry')) return AppAssets.crmIndustryField;
    if (normalizedKey.contains('image')) return AppAssets.crmImageField;
    if (normalizedKey.contains('email')) return AppAssets.emailIcon;
    if (normalizedKey.contains('phone')) return AppAssets.phoneIcon;
    if (normalizedKey.contains('address') ||
        normalizedKey.contains('location')) {
      return AppAssets.locationIcon;
    }
    if (normalizedKey.contains('dropdown')) return AppAssets.dropDownIcon;
    if (normalizedKey.contains('radio')) return AppAssets.crmRadioField;
    if (normalizedKey.contains('check')) return AppAssets.crmCheckBoxField;
    if (normalizedKey.contains('description')) {
      return AppAssets.crmDescriptionField;
    }
    if (normalizedKey.contains('attachment')) return AppAssets.attachmentIcon;
    if (normalizedKey.contains('website')) return AppAssets.linkIcon;
    if (normalizedKey.contains('link')) return AppAssets.crmLinkField;
    if (normalizedKey.contains('signature')) {
      return AppAssets.crmSignatureField;
    }
    if (normalizedKey.contains('time')) return AppAssets.timeSelectorIcon;
    if (normalizedKey.contains('date')) return AppAssets.calendar;
    if (normalizedKey.contains('switch')) return AppAssets.crmSwitchField;
    if (normalizedKey.contains('tag')) return AppAssets.crmTagField;
    return AppAssets.crmTextField;
  }
}
