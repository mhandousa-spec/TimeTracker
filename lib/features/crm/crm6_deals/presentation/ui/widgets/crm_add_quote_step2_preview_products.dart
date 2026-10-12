// ****************** FILE INFO ******************
// File Name: crm_add_quote_step2_preview_products.dart
// Purpose: Step 2 Preview Products and Services form for Add Quote wizard matching Figma screenshot 3
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class QuoteProductPreviewItem {
  final String category;
  final String product;
  final String quantity;
  final String unitPrice;
  final String discount;
  final String tax;
  final String total;

  const QuoteProductPreviewItem({
    required this.category,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.tax,
    required this.total,
  });
}

class QuoteServicePreviewItem {
  final String category;
  final String service;
  final String price;
  final String discount;
  final String tax;
  final String total;

  const QuoteServicePreviewItem({
    required this.category,
    required this.service,
    required this.price,
    required this.discount,
    required this.tax,
    required this.total,
  });
}

class CrmAddQuoteStep2PreviewProducts extends StatelessWidget {
  final List<QuoteProductPreviewItem> products;
  final List<QuoteServicePreviewItem> services;
  final String subtotalProducts;
  final String subtotalServices;
  final String taxes;
  final String discount;
  final String grandTotal;

  const CrmAddQuoteStep2PreviewProducts({
    super.key,
    this.products = const <QuoteProductPreviewItem>[
      QuoteProductPreviewItem(
        category: 'Category x',
        product: 'Product x',
        quantity: '7',
        unitPrice: '\$50',
        discount: '20%',
        tax: '\$50',
        total: '\$50',
      ),
      QuoteProductPreviewItem(
        category: 'Category x',
        product: 'Product x',
        quantity: '7',
        unitPrice: '\$50',
        discount: '20%',
        tax: '\$50',
        total: '\$50',
      ),
    ],
    this.services = const <QuoteServicePreviewItem>[
      QuoteServicePreviewItem(
        category: 'Category x',
        service: 'Service x',
        price: '\$50',
        discount: '20%',
        tax: '\$50',
        total: '\$50',
      ),
      QuoteServicePreviewItem(
        category: 'Category x',
        service: 'Service x',
        price: '\$50',
        discount: '20%',
        tax: '\$50',
        total: '\$50',
      ),
    ],
    this.subtotalProducts = '1400 GEP',
    this.subtotalServices = '1400 GEP',
    this.taxes = '100 EGP',
    this.discount = '-200 EGP',
    this.grandTotal = '1,000 EGP',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Products/lines Section ─────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Products/lines',
            arabicName: 'المنتجات والبنود',
          ),
          showHideToggle: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPermissionWarningBanner(
                context,
                FormatHelper.localizedString(
                  englishName: "You don't have permission to edit product",
                  arabicName: 'ليس لديك صلاحية لتعديل المنتج',
                ),
              ),
              SizedBox(height: 16.sp),
              _buildProductsTable(context),
            ],
          ),
        ),

        SizedBox(height: 16.sp),

        // ── 2. Services Section ───────────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Services',
            arabicName: 'الخدمات',
          ),
          showHideToggle: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPermissionWarningBanner(
                context,
                FormatHelper.localizedString(
                  englishName: "You don't have permission to edit service",
                  arabicName: 'ليس لديك صلاحية لتعديل الخدمة',
                ),
              ),
              SizedBox(height: 16.sp),
              _buildServicesTable(context),
            ],
          ),
        ),

        SizedBox(height: 16.sp),

        // ── 3. Summary Section ────────────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Summary',
            arabicName: 'الملخص',
          ),
          showHideToggle: true,
          child: _buildSummaryCard(context),
        ),
      ],
    );
  }

  Widget _buildPermissionWarningBanner(BuildContext context, String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(6.sp),
        border: Border.all(color: const Color(0xFFFEF08A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.lock_outline_rounded,
            size: 16.sp,
            color: const Color(0xFF854D0E),
          ),
          SizedBox(width: 8.sp),
          Text(
            message,
            style: StyleText.fontSize12Weight400.copyWith(
              color: const Color(0xFF854D0E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 650.w),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(2.0),
            1: FlexColumnWidth(2.0),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.4),
            4: FlexColumnWidth(1.4),
            5: FlexColumnWidth(1.4),
            6: FlexColumnWidth(1.4),
          },
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Category', arabicName: 'الفئة')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Product', arabicName: 'المنتج')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Quantity', arabicName: 'الكمية')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Unit Price', arabicName: 'سعر الوحدة')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Discount', arabicName: 'الخصم')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Tax', arabicName: 'الضريبة')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Total', arabicName: 'الإجمالي')),
              ],
            ),
            for (final QuoteProductPreviewItem item in products)
              TableRow(
                children: <Widget>[
                  _buildTableCell(item.category),
                  _buildTableCell(item.product),
                  _buildTableCell(item.quantity),
                  _buildTableCell(item.unitPrice),
                  _buildTableCell(item.discount),
                  _buildTableCell(item.tax),
                  _buildTableCell(item.total),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 650.w),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(2.0),
            1: FlexColumnWidth(2.0),
            2: FlexColumnWidth(1.4),
            3: FlexColumnWidth(1.4),
            4: FlexColumnWidth(1.4),
            5: FlexColumnWidth(1.4),
          },
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Category', arabicName: 'الفئة')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Service', arabicName: 'الخدمة')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Price', arabicName: 'السعر')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Discount', arabicName: 'الخصم')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Tax', arabicName: 'الضريبة')),
                _buildTableHeader(FormatHelper.localizedString(
                    englishName: 'Total', arabicName: 'الإجمالي')),
              ],
            ),
            for (final QuoteServicePreviewItem item in services)
              TableRow(
                children: <Widget>[
                  _buildTableCell(item.category),
                  _buildTableCell(item.service),
                  _buildTableCell(item.price),
                  _buildTableCell(item.discount),
                  _buildTableCell(item.tax),
                  _buildTableCell(item.total),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp, right: 8.sp),
      child: Text(
        title,
        style: StyleText.fontSize12Weight400.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildTableCell(String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp, right: 8.sp),
      child: CustomTextField(
        initialValue: value,
        readOnly: true,
        fillColor: AppColors.background,
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Subtotal Products (${products.length} item)',
            arabicName: 'إجمالي المنتجات (${products.length} عناصر)',
          ),
          value: subtotalProducts,
        ),
        SizedBox(height: 8.sp),
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Subtotal Services (${services.length} services)',
            arabicName: 'إجمالي الخدمات (${services.length} خدمات)',
          ),
          value: subtotalServices,
        ),
        SizedBox(height: 8.sp),
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Taxes',
            arabicName: 'الضرائب',
          ),
          value: taxes,
        ),
        SizedBox(height: 8.sp),
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Discount (20%)',
            arabicName: 'الخصم (20%)',
          ),
          value: discount,
          valueColor: const Color(0xFFFF7A00),
        ),
        SizedBox(height: 12.sp),
        const Divider(color: Color(0xFFE5E7EB)),
        SizedBox(height: 8.sp),
        _buildSummaryRow(
          label: FormatHelper.localizedString(
            englishName: 'Total',
            arabicName: 'الإجمالي النهائي',
          ),
          value: grandTotal,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.black : const Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ??
                (isBold ? AppColors.black : const Color(0xFF111827)),
          ),
        ),
      ],
    );
  }
}
