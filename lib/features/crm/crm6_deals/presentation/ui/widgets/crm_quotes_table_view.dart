// ****************** FILE INFO ******************
// File Name: crm_quotes_table_view.dart
// Purpose: Quotes table view built with custom Table and TableRow matching CrmClientsTableWidget design system without checkboxes
// Author: Mohand Adel
// Created At: 29/08/2026

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';

class CrmQuotesTableView extends StatelessWidget {
  final List<CrmQuoteModel> quotes;
  final ValueChanged<CrmQuoteModel>? onQuoteTapped;

  const CrmQuotesTableView({
    super.key,
    required this.quotes,
    this.onQuoteTapped,
  });

  bool get _isArabic => Get.locale.toString().contains('ar');

  TextStyle get _headerStyle => StyleText.fontSize14Weight600.copyWith(
        color: AppColors.white,
        fontSize: 13.sp,
      );

  TextStyle _cellStyle(BuildContext context,
          {Color? color, bool isBold = false}) =>
      StyleText.fontSize14Weight400.copyWith(
        fontSize: 13.sp,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color ??
            (Theme.of(context).brightness == Brightness.light
                ? AppColors.text
                : AppColors.white),
      );

  static final Map<int, TableColumnWidth> _columnWidths =
      <int, TableColumnWidth>{
    0: FixedColumnWidth(50.sp), // NO
    1: FixedColumnWidth(100.sp), // Quote No
    2: FixedColumnWidth(80.sp), // Version
    3: FixedColumnWidth(130.sp), // Client's Status
    4: FixedColumnWidth(150.sp), // Approved
    5: FixedColumnWidth(140.sp), // Products Category
    6: FixedColumnWidth(140.sp), // Products
    7: FixedColumnWidth(60.sp), // Qty
    8: FixedColumnWidth(90.sp), // Discount
    9: FixedColumnWidth(90.sp), // Tax
    10: FixedColumnWidth(100.sp), // Total
    11: FixedColumnWidth(140.sp), // Services Category
    12: FixedColumnWidth(140.sp), // Services
    13: FixedColumnWidth(90.sp), // Discount
    14: FixedColumnWidth(90.sp), // Tax
    15: FixedColumnWidth(100.sp), // Total
    16: FixedColumnWidth(120.sp), // Created Date
    17: FixedColumnWidth(120.sp), // Valid Until
    18: FixedColumnWidth(130.sp), // Payment Terms
    19: FixedColumnWidth(130.sp), // Delivery Terms
    20: FixedColumnWidth(160.sp), // Note
    21: FixedColumnWidth(160.sp), // ملاحظة
  };

  static const List<String> _headers = <String>[
    'NO',
    'Quote No',
    'Version',
    "Client’s Status",
    'Approved',
    'Products Category',
    'Products',
    'Qty',
    'Discount',
    'Tax',
    'Total',
    'Services Category',
    'Services',
    'Discount',
    'Tax',
    'Total',
    'Created Date',
    'Valid Until',
    'Payment Terms',
    'Delivery Terms',
    'Note',
    'ملاحظة',
  ];

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return Container(
        height: 200.sp,
        alignment: Alignment.center,
        child: Text(
          'No quotes found.',
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
      );
    }

    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool isRtl = _isArabic;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            border: TableBorder.all(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: _columnWidths,
            children: <TableRow>[
              // ── Header Row ──────────────────────────────────────────────────
              TableRow(
                decoration: BoxDecoration(
                  color: isLight ? AppColors.black : AppColors.dividerGrey,
                ),
                children: _headers.map((String title) {
                  return Padding(
                    padding: EdgeInsets.all(10.sp),
                    child: Text(
                      title,
                      style: _headerStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  );
                }).toList(),
              ),

              // ── Data Rows ───────────────────────────────────────────────────
              ...List<TableRow>.generate(quotes.length, (int index) {
                final CrmQuoteModel quote = quotes[index];
                final bool isEven = index.isEven;
                final Color rowColor = isLight
                    ? (isEven ? AppColors.evenRowColor : AppColors.oddRowColor)
                    : (isEven ? AppColors.darkDashboardTable : AppColors.black);

                final List<Widget> cells = <Widget>[
                  // 1. NO
                  _buildCell(context, '${index + 1}', quote),
                  // 2. Quote No
                  _buildCell(context, quote.quoteNo, quote),
                  // 3. Version
                  _buildCell(context, 'V${quote.version}', quote),
                  // 4. Client's Status
                  _buildColoredCell(
                    context,
                    quote.clientStatus.labelEn,
                    quote.clientStatus.color,
                    quote,
                    isBold: true,
                  ),
                  // 5. Approved
                  _buildColoredCell(
                    context,
                    quote.approvalStatus,
                    quote.approvalStatusColor,
                    quote,
                    isBold: true,
                  ),
                  // 6. Products Category
                  _buildCell(context, quote.productsCategory, quote),
                  // 7. Products
                  _buildCell(context, quote.products, quote),
                  // 8. Qty
                  _buildCell(context, '${quote.qty}', quote),
                  // 9. Discount
                  _buildCell(context, quote.productDiscount, quote),
                  // 10. Tax
                  _buildCell(context, quote.productTax, quote),
                  // 11. Total
                  _buildCell(context, quote.productTotal, quote),
                  // 12. Services Category
                  _buildCell(context, quote.servicesCategory, quote),
                  // 13. Services
                  _buildCell(context, quote.services, quote),
                  // 14. Discount
                  _buildCell(context, quote.serviceDiscount, quote),
                  // 15. Tax
                  _buildCell(context, quote.serviceTax, quote),
                  // 16. Total
                  _buildCell(context, quote.serviceTotal, quote),
                  // 17. Created Date
                  _buildCell(context, quote.createdDate, quote),
                  // 18. Valid Until
                  _buildCell(context, quote.validUntil, quote),
                  // 19. Payment Terms
                  _buildCell(context, quote.paymentTerms, quote),
                  // 20. Delivery Terms
                  _buildCell(context, quote.deliveryTerms, quote),
                  // 21. Note
                  _buildCell(context, quote.noteEn, quote),
                  // 22. ملاحظة
                  _buildCell(context, quote.noteAr, quote),
                ];

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: cells,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    String text,
    CrmQuoteModel quote, {
    Color? color,
    bool isBold = false,
  }) {
    return InkWell(
      onTap: () => onQuoteTapped?.call(quote),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Text(
          text.trim().isEmpty ? '-' : text,
          style: _cellStyle(context, color: color, isBold: isBold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildColoredCell(
    BuildContext context,
    String text,
    Color color,
    CrmQuoteModel quote, {
    bool isBold = false,
  }) {
    return InkWell(
      onTap: () => onQuoteTapped?.call(quote),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Text(
          text.trim().isEmpty ? '-' : text,
          style: _cellStyle(context, color: color, isBold: isBold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
