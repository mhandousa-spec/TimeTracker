// ****************** FILE INFO ******************
// File Name: crm_add_deal_step2_products_services.dart
// Purpose: Step 2 (Add Products & Services with Summary) of the Add Deal wizard
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/58-default_switch_button.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class DealProductLineItem {
  String? product;
  String quantity;
  double unitPrice;
  double discount;
  double tax;

  DealProductLineItem({
    this.product,
    this.quantity = '',
    this.unitPrice = 50.0,
    this.discount = 20.0,
    this.tax = 50.0,
  });

  double get total {
    final int q = int.tryParse(quantity) ?? 1;
    final double sub = q * unitPrice;
    final double disc = sub * (discount / 100.0);
    return (sub - disc) + tax;
  }
}

class DealServiceLineItem {
  String? service;
  double price;
  String discount;
  double tax;

  DealServiceLineItem({
    this.service,
    this.price = 50.0,
    this.discount = '',
    this.tax = 50.0,
  });

  double get total {
    final double discPercent = double.tryParse(discount) ?? 0.0;
    final double disc = price * (discPercent / 100.0);
    return (price - disc) + tax;
  }
}

class CrmAddDealStep2ProductsServices extends StatefulWidget {
  final bool productsEnabled;
  final ValueChanged<bool> onProductsToggleChanged;
  final String? productCategory;
  final ValueChanged<String?> onProductCategoryChanged;

  final bool servicesEnabled;
  final ValueChanged<bool> onServicesToggleChanged;
  final String? serviceCategory;
  final ValueChanged<String?> onServiceCategoryChanged;

  final List<DealProductLineItem> productLines;
  final List<DealServiceLineItem> serviceLines;
  final VoidCallback onAddProductLine;
  final ValueChanged<int> onRemoveProductLine;
  final VoidCallback onAddServiceLine;
  final ValueChanged<int> onRemoveServiceLine;
  final bool isSubmitted;

  const CrmAddDealStep2ProductsServices({
    super.key,
    required this.productsEnabled,
    required this.onProductsToggleChanged,
    required this.productCategory,
    required this.onProductCategoryChanged,
    required this.servicesEnabled,
    required this.onServicesToggleChanged,
    required this.serviceCategory,
    required this.onServiceCategoryChanged,
    required this.productLines,
    required this.serviceLines,
    required this.onAddProductLine,
    required this.onRemoveProductLine,
    required this.onAddServiceLine,
    required this.onRemoveServiceLine,
    required this.isSubmitted,
  });

  @override
  State<CrmAddDealStep2ProductsServices> createState() =>
      _CrmAddDealStep2ProductsServicesState();
}

class _CrmAddDealStep2ProductsServicesState
    extends State<CrmAddDealStep2ProductsServices> {
  static const List<String> _productCategories = <String>[
    'Software License',
    'Hardware Equipment',
    'Add-on Modules',
    'Enterprise Cloud',
  ];

  static const List<String> _serviceCategories = <String>[
    'Technical Support',
    'Consulting & Audit',
    'Implementation',
    'Training Programs',
  ];

  static const List<String> _availableProducts = <String>[
    'ERP System License',
    'CRM Cloud Enterprise',
    'POS Terminal Hardware',
    'Barcode Scanner Pro',
  ];

  static const List<String> _availableServices = <String>[
    'System Setup & Deployment',
    'Custom Data Migration',
    'Staff Training Workshops',
    '24/7 SLA Support',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Section 1: Details (Products & Services switches + Category) ────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Details',
            arabicName: 'التفاصيل',
          ),
          child: buildResponsiveFields(
            context: context,
            left: _buildProductToggleColumn(context),
            right: _buildServiceToggleColumn(context),
          ),
        ),

        // ── Section 2: Products/lines ─────────────────────────────────────────
        if (widget.productsEnabled) ...<Widget>[
          SizedBox(height: 24.sp),
          CrmSectionCard(
            title: FormatHelper.localizedString(
              englishName: 'Products/lines',
              arabicName: 'المنتجات / البنود',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0;
                    i < widget.productLines.length;
                    i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 16.sp),
                  _buildProductLineRow(context, i, widget.productLines[i]),
                ],
                SizedBox(height: 16.sp),
                _buildAddButton(
                  title: '+ Product',
                  onTap: widget.onAddProductLine,
                ),
              ],
            ),
          ),
        ],

        // ── Section 3: Services ───────────────────────────────────────────────
        if (widget.servicesEnabled) ...<Widget>[
          SizedBox(height: 24.sp),
          CrmSectionCard(
            title: FormatHelper.localizedString(
              englishName: 'Services',
              arabicName: 'الخدمات',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0;
                    i < widget.serviceLines.length;
                    i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 16.sp),
                  _buildServiceLineRow(context, i, widget.serviceLines[i]),
                ],
                SizedBox(height: 16.sp),
                _buildAddButton(
                  title: '+ Service',
                  onTap: widget.onAddServiceLine,
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 24.sp),

        // ── Section 4: Summary ────────────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Summary',
            arabicName: 'الملخص',
          ),
          child: _buildSummaryCard(context),
        ),
      ],
    );
  }

  Widget _buildProductToggleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Products',
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            DefaultSwitchButton(
              value: widget.productsEnabled,
              onChanged: widget.onProductsToggleChanged,
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        CustomDropdown<String>(
          hint: 'Choose Category',
          value: widget.productCategory,
          items: _productCategories
              .map((String c) => DropdownItem<String>(value: c, label: c))
              .toList(),
          fillColor: AppColors.background,
          onChanged: widget.onProductCategoryChanged,
        ),
      ],
    );
  }

  Widget _buildServiceToggleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Services',
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            DefaultSwitchButton(
              value: widget.servicesEnabled,
              onChanged: widget.onServicesToggleChanged,
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        CustomDropdown<String>(
          hint: 'Choose Category',
          value: widget.serviceCategory,
          items: _serviceCategories
              .map((String c) => DropdownItem<String>(value: c, label: c))
              .toList(),
          fillColor: AppColors.background,
          onChanged: widget.onServiceCategoryChanged,
        ),
      ],
    );
  }

  Widget _buildProductLineRow(
    BuildContext context,
    int index,
    DealProductLineItem item,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Product dropdown
              SizedBox(
                width: 200.sp,
                child: CustomDropdown<String>(
                  label: 'Product',
                  hint: 'Choose',
                  value: item.product,
                  items: _availableProducts
                      .map((String p) =>
                          DropdownItem<String>(value: p, label: p))
                      .toList(),
                  fillColor: AppColors.background,
                  errorText: (widget.isSubmitted && item.product == null)
                      ? 'Field Required'
                      : null,
                  onChanged: (String? val) =>
                      setState(() => item.product = val),
                ),
              ),
              SizedBox(width: 12.sp),

              // Quantity textfield
              SizedBox(
                width: 120.sp,
                child: CustomTextField(
                  label: 'Quantity',
                  hint: 'Text Here',
                  keyboardType: TextInputType.number,
                  fillColor: AppColors.background,
                  initialValue: item.quantity,
                  errorText:
                      (widget.isSubmitted && item.quantity.trim().isEmpty)
                          ? 'Field Required'
                          : null,
                  onChanged: (String val) =>
                      setState(() => item.quantity = val),
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
                  initialValue: '${item.discount.toInt()}%',
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

              // Tax (or Total)
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

              // Remove Icon
              Padding(
                padding: EdgeInsets.only(top: 26.sp),
                child: IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppColors.red,
                    size: 22.sp,
                  ),
                  onPressed: widget.productLines.length > 1
                      ? () => widget.onRemoveProductLine(index)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceLineRow(
    BuildContext context,
    int index,
    DealServiceLineItem item,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Service dropdown
              SizedBox(
                width: 220.sp,
                child: CustomDropdown<String>(
                  label: 'Service',
                  hint: 'Choose',
                  value: item.service,
                  items: _availableServices
                      .map((String s) =>
                          DropdownItem<String>(value: s, label: s))
                      .toList(),
                  fillColor: AppColors.background,
                  errorText: (widget.isSubmitted && item.service == null)
                      ? 'Field Required'
                      : null,
                  onChanged: (String? val) =>
                      setState(() => item.service = val),
                ),
              ),
              SizedBox(width: 12.sp),

              // Price
              SizedBox(
                width: 120.sp,
                child: CustomTextField(
                  label: 'Price',
                  initialValue: '\$${item.price.toInt()}',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Discount textfield
              SizedBox(
                width: 120.sp,
                child: CustomTextField(
                  label: 'Discount',
                  hint: 'Text Here',
                  keyboardType: TextInputType.number,
                  fillColor: AppColors.background,
                  initialValue: item.discount,
                  onChanged: (String val) =>
                      setState(() => item.discount = val),
                ),
              ),
              SizedBox(width: 12.sp),

              // Tax
              SizedBox(
                width: 120.sp,
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
                width: 120.sp,
                child: CustomTextField(
                  label: 'Total',
                  initialValue: '\$${item.price.toInt()}',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Remove Icon
              Padding(
                padding: EdgeInsets.only(top: 26.sp),
                child: IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppColors.red,
                    size: 22.sp,
                  ),
                  onPressed: widget.serviceLines.length > 1
                      ? () => widget.onRemoveServiceLine(index)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          title,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSummaryRow(
          title: 'Subtotal Products (${widget.productLines.length} item)',
          value: '1400 GEP',
        ),
        SizedBox(height: 12.sp),
        _buildSummaryRow(
          title: 'Subtotal Services (${widget.serviceLines.length} services)',
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
