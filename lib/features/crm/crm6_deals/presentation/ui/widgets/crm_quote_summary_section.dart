// ****************** FILE INFO ******************
// File Name: crm_quote_summary_section.dart
// Purpose: Reusable Summary section card for Quote Details displaying Subtotal, Taxes, Discount, and Total
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmQuoteSummarySection extends StatelessWidget {
  final String subtotalLabel;
  final String subtotalValue;
  final String taxesValue;
  final String discountPercentage;
  final String discountValue;
  final String totalValue;

  const CrmQuoteSummarySection({
    super.key,
    this.subtotalLabel = 'Subtotal (2 item)',
    this.subtotalValue = '1400 GEP',
    this.taxesValue = '100 EGP',
    this.discountPercentage = '20%',
    this.discountValue = '-200 EGP',
    this.totalValue = '1,000 EGP',
  });

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Summary',
        arabicName: 'الملخص',
      ),
      showHideToggle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Subtotal Row
          _buildSummaryRow(
            label: subtotalLabel,
            value: subtotalValue,
            labelStyle: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.black,
            ),
            valueStyle: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),

          SizedBox(height: 12.sp),

          // 2. Taxes Row
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Taxes',
              arabicName: 'الضرائب',
            ),
            value: taxesValue,
            labelStyle: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.black,
            ),
            valueStyle: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),

          SizedBox(height: 12.sp),

          // 3. Discount Row (Orange Accent)
          _buildSummaryRow(
            label: 'Discount ($discountPercentage)',
            value: discountValue,
            labelStyle: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.black,
            ),
            valueStyle: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF7A00),
            ),
          ),

          SizedBox(height: 16.sp),

          // 4. Divider Line
          Divider(
            color: const Color(0xFFE5E7EB),
            thickness: 1.sp,
            height: 1.sp,
          ),

          SizedBox(height: 16.sp),

          // 5. Total Row
          _buildSummaryRow(
            label: FormatHelper.localizedString(
              englishName: 'Total',
              arabicName: 'الإجمالي',
            ),
            value: totalValue,
            labelStyle: StyleText.fontSize16Weight500.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontSize: 16.sp,
            ),
            valueStyle: StyleText.fontSize16Weight500.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
