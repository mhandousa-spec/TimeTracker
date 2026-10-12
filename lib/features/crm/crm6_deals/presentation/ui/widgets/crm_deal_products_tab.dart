// ****************** FILE INFO ******************
// File Name: crm_deal_products_tab.dart
// Purpose: Products tab for Deal Details page matching Figma screenshot 3
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step2_products_services.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmDealProductsTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealProductsTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealProductsTab> createState() => _CrmDealProductsTabState();
}

class _CrmDealProductsTabState extends State<CrmDealProductsTab> {
  static const List<String> _categories = <String>[
    'Software License',
    'Hardware Equipment',
    'Add-on Modules',
    'Enterprise Cloud',
  ];

  static const List<String> _products = <String>[
    'ERP System License',
    'CRM Cloud Enterprise',
    'POS Terminal Hardware',
    'Barcode Scanner Pro',
  ];

  late final List<DealProductLineItem> _items;

  @override
  void initState() {
    super.initState();
    if (widget.deal.products.isNotEmpty) {
      _items = widget.deal.products
          .map((CrmDealProductItem p) => DealProductLineItem(
                product: p.productName,
                quantity: p.qty.toString(),
                unitPrice: p.price,
                discount: p.discount,
                tax: p.tax,
              ))
          .toList();
    } else {
      _items = <DealProductLineItem>[
        DealProductLineItem(
          product: null,
          quantity: '',
          unitPrice: 50.0,
          discount: 20.0,
          tax: 50.0,
        ),
        DealProductLineItem(
          product: null,
          quantity: '',
          unitPrice: 50.0,
          discount: 20.0,
          tax: 50.0,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Section 1: Products Table ─────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Products',
            arabicName: 'المنتجات',
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < _items.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 16.sp),
                  _buildProductRow(i, _items[i]),
                ],
              ],
            ),
          ),
        ),

        SizedBox(height: 24.sp),

        // ── Section 2: Summary Card ───────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Summary',
            arabicName: 'الملخص',
          ),
          child: Column(
            children: <Widget>[
              _buildSummaryRow(
                title: 'Subtotal (${_items.length} item)',
                value: '1400 GEP',
              ),
              SizedBox(height: 12.sp),
              _buildSummaryRow(
                title: 'Taxes',
                value: '100 EGP',
              ),
              SizedBox(height: 12.sp),
              _buildSummaryRow(
                title: 'Discount (20%)',
                value: '-200 EGP',
                valueColor: const Color(0xFFFF7A00),
              ),
              SizedBox(height: 16.sp),
              const Divider(color: Color(0xFFE5E7EB)),
              SizedBox(height: 12.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.fullBlack).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '1,000 EGP',
                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.fullBlack).copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductRow(int index, DealProductLineItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Category
        SizedBox(
          width: 180.sp,
          child: CustomDropdown<String>(
            label: 'Category',
            hint: 'Choose',
            items: _categories
                .map((String c) => DropdownItem<String>(value: c, label: c))
                .toList(),
            fillColor: AppColors.background,
            onChanged: (String? val) {},
          ),
        ),
        SizedBox(width: 12.sp),

        // Product
        SizedBox(
          width: 180.sp,
          child: CustomDropdown<String>(
            label: 'Product',
            hint: 'Choose',
            value: item.product,
            items: _products
                .map((String p) => DropdownItem<String>(value: p, label: p))
                .toList(),
            fillColor: AppColors.background,
            onChanged: (String? val) => setState(() => item.product = val),
          ),
        ),
        SizedBox(width: 12.sp),

        // Quantity
        SizedBox(
          width: 120.sp,
          child: CustomTextField(
            label: 'Quantity',
            hint: 'Text Here',
            keyboardType: TextInputType.number,
            fillColor: AppColors.background,
            initialValue: item.quantity,
            onChanged: (String val) => setState(() => item.quantity = val),
          ),
        ),
        SizedBox(width: 12.sp),

        // Unit Price
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Unit Price',
            initialValue: '\$${item.unitPrice.toInt()}',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Discount
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Discount',
            initialValue: '${item.discount.toInt()}',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Tax
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Tax',
            initialValue: '\$${item.tax.toInt()}',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(width: 12.sp),

        // Total
        SizedBox(
          width: 100.sp,
          child: CustomTextField(
            label: 'Total',
            initialValue: '\$${item.unitPrice.toInt()}',
            readOnly: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        Text(
          value,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }
}
