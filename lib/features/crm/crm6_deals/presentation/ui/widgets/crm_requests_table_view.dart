// ****************** FILE INFO ******************
// File Name: crm_requests_table_view.dart
// Purpose: Table view component for Deal Requests matching CrmClientsTableWidget design system without checkboxes
// Author: Mohand Adel
// Created At: 29/08/2026

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_request_model.dart';

class CrmRequestsTableView extends StatelessWidget {
  final List<CrmDealRequestModel> requests;
  final void Function(CrmDealRequestModel request)? onRequestTap;

  const CrmRequestsTableView({
    super.key,
    required this.requests,
    this.onRequestTap,
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
    3: FixedColumnWidth(150.sp), // Approved
    4: FixedColumnWidth(140.sp), // Products Category
    5: FixedColumnWidth(140.sp), // Products
    6: FixedColumnWidth(60.sp), // Qty
    7: FixedColumnWidth(90.sp), // Discount
    8: FixedColumnWidth(90.sp), // Tax
    9: FixedColumnWidth(100.sp), // Total
    10: FixedColumnWidth(140.sp), // Services Category
    11: FixedColumnWidth(140.sp), // Services
    12: FixedColumnWidth(90.sp), // Discount
    13: FixedColumnWidth(90.sp), // Tax
    14: FixedColumnWidth(100.sp), // Total
    15: FixedColumnWidth(120.sp), // Created Date
    16: FixedColumnWidth(120.sp), // Valid Until
    17: FixedColumnWidth(130.sp), // Payment Terms
    18: FixedColumnWidth(130.sp), // Delivery Terms
    19: FixedColumnWidth(160.sp), // Note
    20: FixedColumnWidth(160.sp), // ملاحظة
  };

  static const List<String> _headers = <String>[
    'NO',
    'Quote No',
    'Version',
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
    if (requests.isEmpty) {
      return Container(
        height: 200.sp,
        alignment: Alignment.center,
        child: Text(
          'No requests found.',
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
              ...List<TableRow>.generate(requests.length, (int index) {
                final CrmDealRequestModel req = requests[index];
                final bool isEven = index.isEven;
                final Color rowColor = isLight
                    ? (isEven ? AppColors.evenRowColor : AppColors.oddRowColor)
                    : (isEven ? AppColors.darkDashboardTable : AppColors.black);

                final List<Widget> cells = <Widget>[
                  // 1. NO
                  _buildCell(context, '${req.no}', req),
                  // 2. Quote No
                  _buildCell(context, req.quoteNo, req),
                  // 3. Version
                  _buildCell(context, req.version, req),
                  // 4. Approved
                  _buildColoredCell(
                    context,
                    req.status.tableStatusLabel,
                    req.status.color,
                    req,
                    isBold: true,
                  ),
                  // 5. Products Category
                  _buildCell(context, req.productsCategory, req),
                  // 6. Products
                  _buildCell(context, req.products, req),
                  // 7. Qty
                  _buildCell(context, req.quantity, req),
                  // 8. Discount
                  _buildCell(context, req.productDiscount, req),
                  // 9. Tax
                  _buildCell(context, req.productTax, req),
                  // 10. Total
                  _buildCell(context, req.productTotal, req),
                  // 11. Services Category
                  _buildCell(context, req.servicesCategory, req),
                  // 12. Services
                  _buildCell(context, req.services, req),
                  // 13. Discount
                  _buildCell(context, req.serviceDiscount, req),
                  // 14. Tax
                  _buildCell(context, req.serviceTax, req),
                  // 15. Total
                  _buildCell(context, req.serviceTotal, req),
                  // 16. Created Date
                  _buildCell(context, req.createdDate, req),
                  // 17. Valid Until
                  _buildCell(context, req.validUntil, req),
                  // 18. Payment Terms
                  _buildCell(context, req.paymentTerms, req),
                  // 19. Delivery Terms
                  _buildCell(context, req.deliveryTerms, req),
                  // 20. Note
                  _buildCell(context, req.note, req),
                  // 21. ملاحظة
                  _buildCell(context, req.noteAr, req),
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
    CrmDealRequestModel req, {
    Color? color,
    bool isBold = false,
  }) {
    return InkWell(
      onTap: () => onRequestTap?.call(req),
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
    CrmDealRequestModel req, {
    bool isBold = false,
  }) {
    return InkWell(
      onTap: () => onRequestTap?.call(req),
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
