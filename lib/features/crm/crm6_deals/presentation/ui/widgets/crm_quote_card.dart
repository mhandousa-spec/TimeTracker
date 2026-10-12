// ****************** FILE INFO ******************
// File Name: crm_quote_card.dart
// Purpose: Quote card widget for Deal Quotes grid view using CardInfoRow and AppAssets matching Figma design
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';

class CrmQuoteCard extends StatelessWidget {
  final CrmQuoteModel quote;
  final bool isCompareMode;
  final bool isSelected;
  final VoidCallback? onTap;

  const CrmQuoteCard({
    super.key,
    required this.quote,
    this.isCompareMode = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 1.5.sp : 1.sp,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // ── Left: Quote Thumbnail Container ───────────────────────────
            Container(
              width: 50.sp,
              height: 50.sp,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmQuote,
                width: 24.sp,
                height: 24.sp,
                color: AppColors.black,
              ),
            ),

            SizedBox(width: 12.sp),

            // ── Center & Right: Content ────────────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Header: Quote Title + Solid Status Badge / Compare Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Quote',
                        style: StyleText.fontSize14Weight500.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          fontSize: 14.sp,
                        ),
                      ),
                      if (isCompareMode)
                        if (isSelected)
                          CustomCheckBox(
                            isSelected: true,
                            size: 18.sp,
                          )
                        else
                          const SizedBox.shrink()
                      else
                        _buildStatusBadge(quote.clientStatus),
                    ],
                  ),

                  SizedBox(height: 6.sp),

                  // Metadata Row 1: # Number & Version
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmHash,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Number:',
                            value: quote.quoteNo,
                          ),
                          fontSize: 11.sp,
                          iconSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmVersion,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'V:',
                            value: quote.version,
                          ),
                          fontSize: 11.sp,
                          iconSize: 12.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.sp),

                  // Metadata Row 2: Valid Until & Total
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.calendar,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Valid Until:',
                            value: quote.validUntil,
                          ),
                          fontSize: 11.sp,
                          iconSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmPrice,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Total:',
                            value: quote.totalFormatted,
                          ),
                          fontSize: 11.sp,
                          iconSize: 12.sp,
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

  Widget _buildStatusBadge(CrmQuoteStatus status) {
    Color bg;
    Color fg;

    switch (status) {
      case CrmQuoteStatus.adjustment:
        bg = const Color(0xFF2563EB);
        fg = AppColors.white;
        break;
      case CrmQuoteStatus.pending:
        bg = const Color(0xFFFF7A00);
        fg = AppColors.white;
        break;
      case CrmQuoteStatus.expired:
        bg = const Color(0xFF6B7280);
        fg = AppColors.white;
        break;
      case CrmQuoteStatus.reject:
        bg = const Color(0xFFDC2626);
        fg = AppColors.white;
        break;
      case CrmQuoteStatus.approved:
        bg = const Color(0xFF16A34A);
        fg = AppColors.white;
        break;
      case CrmQuoteStatus.all:
        bg = AppColors.primary;
        fg = AppColors.black;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 3.sp),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status.labelEn,
        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
