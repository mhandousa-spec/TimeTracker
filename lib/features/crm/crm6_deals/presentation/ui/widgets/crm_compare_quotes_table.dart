// ****************** FILE INFO ******************
// File Name: crm_compare_quotes_table.dart
// Purpose: Comparison Table displaying quote fields side-by-side matching Figma screenshot
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';

class CrmCompareQuotesTable extends StatelessWidget {
  final List<CrmQuoteModel> quotes;

  const CrmCompareQuotesTable({
    super.key,
    required this.quotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp),
        child: Column(
          children: <Widget>[
            // Table Header Row
            Container(
              height: 48.sp,
              padding: EdgeInsets.symmetric(horizontal: 20.sp),
              color: AppColors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Fields',
                      style: StyleText.fontSize14Weight600.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...quotes.map(
                    (CrmQuoteModel q) => Expanded(
                      flex: 3,
                      child: Text(
                        'V${q.version}',
                        style: StyleText.fontSize14Weight600.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1)),

            // Table Data Rows
            _buildRow(
              title: 'Total',
              values: quotes.map((q) => q.totalFormatted).toList(),
              isEven: false,
            ),
            _buildRow(
              title: 'Discount',
              values: quotes.map((q) => '20%').toList(),
              isEven: true,
            ),
            _buildRow(
              title: 'Products',
              values: quotes.map((q) => q.qty.toString()).toList(),
              isEven: false,
            ),
            _buildRow(
              title: 'Services',
              values: quotes.map((q) => '2').toList(),
              isEven: true,
            ),
            _buildRow(
              title: 'Valid Until',
              values: quotes.map((q) => q.validUntil).toList(),
              isEven: false,
            ),
            _buildStatusRow(
              title: 'Status',
              quotes: quotes,
              isEven: true,
            ),
            _buildRow(
              title: 'Grand Total',
              values: quotes.map((q) => q.totalFormatted).toList(),
              isEven: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String title,
    required List<String> values,
    required bool isEven,
  }) {
    return Container(
      height: 48.sp,
      padding: EdgeInsets.symmetric(horizontal: 20.sp),
      color: isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
          ...values.map(
            (String v) => Expanded(
              flex: 3,
              child: Text(
                v,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String title,
    required List<CrmQuoteModel> quotes,
    required bool isEven,
  }) {
    return Container(
      height: 48.sp,
      padding: EdgeInsets.symmetric(horizontal: 20.sp),
      color: isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
          ...quotes.map(
            (CrmQuoteModel q) => Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusPill(q.clientStatus),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(CrmQuoteStatus status) {
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
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Text(
        status.labelEn,
        style: StyleText.fontSize12Weight400.copyWith(
          color: fg,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
