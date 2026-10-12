// ****************** FILE INFO ******************
// File Name: crm_deal_contract_card.dart
// Purpose: Document card widget for Deal Contracts displaying PDF icon, title, size, uploader, and date matching Figma screenshot
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_contract_model.dart';

class CrmDealContractCard extends StatelessWidget {
  final CrmDealContractModel contract;
  final VoidCallback? onTap;

  const CrmDealContractCard({
    super.key,
    required this.contract,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String uploadedByLabel = FormatHelper.localizedString(
      englishName: 'Uploaded By: ',
      arabicName: 'بواسطة: ',
    );
    final String uploadedOnLabel = FormatHelper.localizedString(
      englishName: 'Uploaded On: ',
      arabicName: 'بتاريخ: ',
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 1. PDF File Icon (40x40)
            SizedBox(
              width: 40.sp,
              height: 40.sp,
              child: Center(
                child: CustomSvgImage(
                  assetPath: AppAssets.pdf,
                  width: 36.sp,
                  height: 36.sp,
                ),
              ),
            ),
            SizedBox(width: 10.sp),

            // 2. Center Info: Name, Size, Uploaded By
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    contract.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.text,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    contract.formattedSize,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: uploadedByLabel,
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 10.sp,
                          ),
                        ),
                        TextSpan(
                          text: contract.uploadedByEmployee,
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.text,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.sp),

            // 3. Right: Upload Date
            RichText(
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: uploadedOnLabel,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 10.sp,
                    ),
                  ),
                  TextSpan(
                    text: contract.formattedUploadDate,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.text,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
