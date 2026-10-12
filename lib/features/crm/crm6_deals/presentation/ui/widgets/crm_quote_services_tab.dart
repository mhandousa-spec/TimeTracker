// ****************** FILE INFO ******************
// File Name: crm_quote_services_tab.dart
// Purpose: Services tab content for Quote Details page supporting view mode and edit mode matching Figma screenshots 4 & 5
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_summary_section.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class QuoteServiceLineItemModel {
  String category;
  String service;
  String price;
  String discount;
  String tax;
  String total;

  QuoteServiceLineItemModel({
    this.category = 'Category x',
    this.service = 'Service x',
    this.price = '\$50',
    this.discount = '20%',
    this.tax = '\$50',
    this.total = '\$50',
  });
}

class CrmQuoteServicesTab extends StatefulWidget {
  final bool isEditMode;
  final VoidCallback? onEditTap;
  final VoidCallback? onDiscardTap;
  final VoidCallback? onSaveTap;

  const CrmQuoteServicesTab({
    super.key,
    this.isEditMode = false,
    this.onEditTap,
    this.onDiscardTap,
    this.onSaveTap,
  });

  @override
  State<CrmQuoteServicesTab> createState() => _CrmQuoteServicesTabState();
}

class _CrmQuoteServicesTabState extends State<CrmQuoteServicesTab> {
  final List<QuoteServiceLineItemModel> _items = <QuoteServiceLineItemModel>[
    QuoteServiceLineItemModel(),
    QuoteServiceLineItemModel(),
  ];

  static const List<String> _categories = <String>[
    'Category x',
    'Category y',
    'Category z',
  ];

  static const List<String> _services = <String>[
    'Service x',
    'Service y',
    'Service z',
  ];

  void _addService() {
    setState(() {
      _items.add(QuoteServiceLineItemModel());
    });
  }

  @override
  Widget build(BuildContext context) {
    final String sectionTitle =
        widget.isEditMode ? 'Services' : 'Products/lines';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Services Section Card ─────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: sectionTitle,
            arabicName: widget.isEditMode ? 'الخدمات' : 'المنتجات / البنود',
          ),
          showHideToggle: true,
          trailing: (!widget.isEditMode && widget.onEditTap != null)
              ? _buildEditButton(context)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Table Rows
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int i = 0; i < _items.length; i++) ...<Widget>[
                      if (i > 0) SizedBox(height: 12.sp),
                      _buildServiceRow(context, i, _items[i]),
                    ],
                  ],
                ),
              ),

              // + Service Button (only in edit mode)
              if (widget.isEditMode) ...<Widget>[
                SizedBox(height: 16.sp),
                _buildAddServiceButton(context),
              ],
            ],
          ),
        ),

        SizedBox(height: 24.sp),

        // ── 2. Summary Section Card ──────────────────────────────────────────
        CrmQuoteSummarySection(
          subtotalLabel: 'Subtotal (${_items.length} Services)',
          subtotalValue: '1400 GEP',
          taxesValue: '100 EGP',
          discountPercentage: '20%',
          discountValue: '-200 EGP',
          totalValue: '1,000 EGP',
        ),

        // ── 3. Bottom Discard / Save Action Bar (in edit mode) ───────────────
        if (widget.isEditMode) ...<Widget>[
          SizedBox(height: 32.sp),
          _buildEditBottomBar(context),
        ],
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return customButtonWithSvg(
      title: FormatHelper.localizedString(
        englishName: 'Edit',
        arabicName: 'تعديل',
      ),
      image: AppAssets.edit,
      widthImage: 14.sp,
      heightImage: 14.sp,
      colorBorder: Colors.transparent,
      color: AppColors.primary,
      textStyle: StyleText.fontSize14Weight500.copyWith(
        fontWeight: FontWeight.bold,
      ),
      function: widget.onEditTap!,
    );
  }

  Widget _buildServiceRow(
    BuildContext context,
    int index,
    QuoteServiceLineItemModel item,
  ) {
    if (!widget.isEditMode) {
      // ── View Mode: Read-only grey textfields ──
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCell(
            label: 'Category',
            width: 160.sp,
            child: CustomTextField(
              initialValue: item.category,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Product',
            width: 160.sp,
            child: CustomTextField(
              initialValue: item.service,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Quantity',
            width: 90.sp,
            child: CustomTextField(
              initialValue: '7',
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Unit Price',
            width: 90.sp,
            child: CustomTextField(
              initialValue: item.price,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Discount',
            width: 90.sp,
            child: CustomTextField(
              initialValue: item.discount,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Tax',
            width: 90.sp,
            child: CustomTextField(
              initialValue: item.tax,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Total',
            width: 90.sp,
            child: CustomTextField(
              initialValue: item.total,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
        ],
      );
    }

    // ── Edit Mode: Category, Service Dropdowns & Editable Textfields ──
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Category Dropdown
        _buildCell(
          label: 'Category',
          width: 160.sp,
          child: CustomDropdown<String>(
            hint: 'Choose',
            value: item.category,
            items: _categories
                .map((String c) => DropdownItem<String>(value: c, label: c))
                .toList(),
            fillColor: AppColors.background,
            onChanged: (String? val) {
              if (val != null) setState(() => item.category = val);
            },
          ),
        ),
        SizedBox(width: 12.sp),

        // Service Dropdown
        _buildCell(
          label: 'Service',
          width: 160.sp,
          child: CustomDropdown<String>(
            hint: 'Choose',
            value: item.service,
            items: _services
                .map((String s) => DropdownItem<String>(value: s, label: s))
                .toList(),
            fillColor: AppColors.background,
            onChanged: (String? val) {
              if (val != null) setState(() => item.service = val);
            },
          ),
        ),
        SizedBox(width: 12.sp),

        // Price
        _buildCell(
          label: 'Price',
          width: 110.sp,
          child: CustomTextField(
            initialValue: item.price,
            fillColor: AppColors.background,
            onChanged: (String val) => item.price = val,
          ),
        ),
        SizedBox(width: 12.sp),

        // Discount
        _buildCell(
          label: 'Discount',
          width: 110.sp,
          child: CustomTextField(
            initialValue: item.discount,
            fillColor: AppColors.background,
            onChanged: (String val) => item.discount = val,
          ),
        ),
        SizedBox(width: 12.sp),

        // Tax
        _buildCell(
          label: 'Tax',
          width: 110.sp,
          child: CustomTextField(
            initialValue: item.tax,
            fillColor: AppColors.background,
            onChanged: (String val) => item.tax = val,
          ),
        ),
        SizedBox(width: 12.sp),

        // Total
        _buildCell(
          label: 'Total',
          width: 110.sp,
          child: CustomTextField(
            initialValue: item.total,
            fillColor: AppColors.background,
            onChanged: (String val) => item.total = val,
          ),
        ),
      ],
    );
  }

  Widget _buildCell({
    required String label,
    required double width,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.sp),
          child,
        ],
      ),
    );
  }

  Widget _buildAddServiceButton(BuildContext context) {
    return InkWell(
      onTap: _addService,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Dark container
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.add, color: AppColors.white, size: 16.sp),
            SizedBox(width: 6.sp),
            Text(
              FormatHelper.localizedString(
                englishName: 'Service',
                arabicName: 'خدمة',
              ),
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditBottomBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Discard',
            arabicName: 'تراجع',
          ),
          color: const Color(0xFFE5E7EB),
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          function: widget.onDiscardTap ?? () {},
        ),
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Save',
            arabicName: 'حفظ',
          ),
          color: AppColors.primary,
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          function: widget.onSaveTap ?? () {},
        ),
      ],
    );
  }
}
