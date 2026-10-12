// ****************** FILE INFO ******************
// File Name: crm_request_card.dart
// Purpose: Request card widget for Deal Requests grid view using CardInfoRow and AppAssets matching Figma design
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_request_model.dart';

class CrmRequestCard extends StatelessWidget {
  final CrmDealRequestModel request;
  final VoidCallback? onTap;

  const CrmRequestCard({
    super.key,
    required this.request,
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
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // ── Left: Document Icon Box ──────────────────────────────────────
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
                  // Top Title & Solid Status Badge
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
                      _buildStatusBadge(request.status),
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
                            value: request.quoteNo,
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
                            value: request.version,
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
                            value: request.validUntil,
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
                            value: request.totalFormatted,
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

  Widget _buildStatusBadge(CrmRequestStatus status) {
    Color bg;
    Color fg;

    switch (status) {
      case CrmRequestStatus.reject:
        bg = const Color(0xFFDC2626);
        fg = AppColors.white;
        break;
      case CrmRequestStatus.approved:
        bg = const Color(0xFF16A34A);
        fg = AppColors.white;
        break;
      case CrmRequestStatus.pending:
        bg = const Color(0xFFFF7A00);
        fg = AppColors.white;
        break;
      case CrmRequestStatus.all:
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
