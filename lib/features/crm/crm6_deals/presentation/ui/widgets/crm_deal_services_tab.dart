// ****************** FILE INFO ******************
// File Name: crm_deal_services_tab.dart
// Purpose: Services tab for Deal Details page matching Figma screenshot 4
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

class CrmDealServicesTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealServicesTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealServicesTab> createState() => _CrmDealServicesTabState();
}

class _CrmDealServicesTabState extends State<CrmDealServicesTab> {
  static const List<String> _categories = <String>[
    'Technical Support',
    'Consulting & Audit',
    'Implementation',
    'Training Programs',
  ];

  static const List<String> _services = <String>[
    'System Setup & Deployment',
    'Custom Data Migration',
    'Staff Training Workshops',
    '24/7 SLA Support',
  ];

  late final List<DealServiceLineItem> _items;

  @override
  void initState() {
    super.initState();
    if (widget.deal.services.isNotEmpty) {
      _items = widget.deal.services
          .map((CrmDealServiceItem s) => DealServiceLineItem(
                service: s.serviceName,
                price: s.price,
                discount: s.discount.toInt().toString(),
                tax: s.tax,
              ))
          .toList();
    } else {
      _items = <DealServiceLineItem>[
        DealServiceLineItem(
          service: null,
          price: 50.0,
          discount: '20',
          tax: 50.0,
        ),
        DealServiceLineItem(
          service: null,
          price: 50.0,
          discount: '20',
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
        // ── Section 1: Services Table ─────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Services',
            arabicName: 'الخدمات',
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < _items.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 16.sp),
                  _buildServiceRow(i, _items[i]),
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
                title: 'Subtotal (${_items.length} services)',
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

  Widget _buildServiceRow(int index, DealServiceLineItem item) {
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

        // Service
        SizedBox(
          width: 180.sp,
          child: CustomDropdown<String>(
            label: 'Service',
            hint: 'Choose',
            value: item.service,
            items: _services
                .map((String s) => DropdownItem<String>(value: s, label: s))
                .toList(),
            fillColor: AppColors.background,
            onChanged: (String? val) => setState(() => item.service = val),
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

        // Discount
        SizedBox(
          width: 120.sp,
          child: CustomTextField(
            label: 'Discount',
            initialValue: item.discount.isNotEmpty ? item.discount : '20',
            readOnly: true,
            fillColor: AppColors.background,
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
