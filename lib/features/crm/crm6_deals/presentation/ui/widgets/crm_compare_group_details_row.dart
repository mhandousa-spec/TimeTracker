// ****************** FILE INFO ******************
// File Name: crm_compare_group_details_row.dart
// Purpose: Group Details summary cards row for Quote Compare page (Version cards, Confidence score, and Records count)
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';

class CrmCompareGroupDetailsRow extends StatelessWidget {
  final List<CrmQuoteModel> quotes;

  const CrmCompareGroupDetailsRow({
    super.key,
    required this.quotes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Group Details',
          style: StyleText.fontSize16Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.sp),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth > 900;
            final double cardWidth = isWide
                ? (constraints.maxWidth - (12.sp * 3)) / 4
                : (constraints.maxWidth - 12.sp) / 2;

            return Wrap(
              spacing: 12.sp,
              runSpacing: 12.sp,
              children: <Widget>[
                // 1. Version cards for each compared quote
                ...quotes.map(
                  (CrmQuoteModel q) => SizedBox(
                    width: cardWidth,
                    child: _buildVersionCard(q),
                  ),
                ),

                // 2. Confidence Score card
                SizedBox(
                  width: cardWidth,
                  child: _buildConfidenceScoreCard(),
                ),

                // 3. Records count card
                SizedBox(
                  width: cardWidth,
                  child: _buildRecordsCard(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildVersionCard(CrmQuoteModel quote) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36.sp,
            height: 36.sp,
            decoration: const BoxDecoration(
              color: Color(0xFF6B7280),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: CustomSvgImage(
              assetPath: AppAssets.crmQuote,
              width: 18.sp,
              height: 18.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'V${quote.version}',
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.sp),
                Text(
                  'Created on ${quote.validUntil}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceScoreCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.speed_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Text(
              'Confidence Score',
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(4.sp),
              border: Border.all(
                color: const Color(0xFFFF7A00),
                width: 1.sp,
              ),
            ),
            child: Text(
              '70%',
              style: StyleText.fontSize12Weight400.copyWith(
                color: const Color(0xFFFF7A00),
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.folder_open_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Text(
              'Records',
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          Text(
            '${quotes.length} Records',
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
