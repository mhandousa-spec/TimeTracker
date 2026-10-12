// ****************** FILE INFO ******************
// File Name: crm_add_deal_step4_review.dart
// Purpose: Step 4 (Review & Confirm) of the Add Deal wizard matching Figma screenshot 4
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_step2_products_services.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmAddDealStep4Review extends StatelessWidget {
  final String dealNameEn;
  final String dealNameAr;
  final String category;
  final String expectedValue;
  final String currency;
  final String likelihood;
  final DateTime? startDate;
  final DateTime? closeDate;
  final CrmTeamMemberModel? employee;
  final List<DealProductLineItem> productLines;
  final List<DealServiceLineItem> serviceLines;

  const CrmAddDealStep4Review({
    super.key,
    required this.dealNameEn,
    required this.dealNameAr,
    required this.category,
    required this.expectedValue,
    required this.currency,
    required this.likelihood,
    required this.startDate,
    required this.closeDate,
    required this.employee,
    required this.productLines,
    required this.serviceLines,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '7/7/2026';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Deal Info Section Card ─────────────────────────────────────────
        CrmSectionCard(
          titleWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildYellowIconBadge(AppAssets.crmRecord),
              SizedBox(width: 8.sp),
              Text(
                'Deal Info',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          showHideToggle: false,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int crossAxisCount = constraints.maxWidth > 900
                  ? 4
                  : (constraints.maxWidth > 600 ? 3 : 2);

              final List<CardInfo> infoItems = <CardInfo>[
                CardInfo(
                  icon: Icon(Icons.grid_view,
                      size: 14.sp, color: AppColors.darkGrey),
                  label: 'Category:',
                  value: category.isNotEmpty ? category : 'xx',
                ),
                CardInfo(
                  icon: Icon(Icons.label_outline,
                      size: 14.sp, color: AppColors.darkGrey),
                  label: 'Name :',
                  value: dealNameEn.isNotEmpty ? dealNameEn : 'New',
                ),
                CardInfo(
                  icon: Icon(Icons.attach_money,
                      size: 14.sp, color: AppColors.darkGrey),
                  label: 'Expected Value:',
                  value: expectedValue.isNotEmpty ? '\$$expectedValue' : '\$15',
                ),
                CardInfo(
                  icon: Icon(Icons.person_outline,
                      size: 14.sp, color: AppColors.darkGrey),
                  label: 'Assign to:',
                  value: employee?.name ?? 'Mai Ahmed',
                ),
                CardInfo(
                  icon: Icon(Icons.percent,
                      size: 14.sp, color: AppColors.darkGrey),
                  label: 'Likelihood:',
                  value: likelihood.isNotEmpty ? likelihood : '30%',
                ),
                CardInfo(
                  icon: Icon(Icons.calendar_today_outlined,
                      size: 14.sp, color: AppColors.darkGrey),
                  label: 'Start Date:',
                  value: _formatDate(startDate),
                ),
                CardInfo(
                  icon: Icon(Icons.calendar_today_outlined,
                      size: 14.sp, color: AppColors.darkGrey),
                  label: 'End Date:',
                  value: _formatDate(closeDate),
                ),
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 36.sp,
                  crossAxisSpacing: 12.sp,
                  mainAxisSpacing: 8.sp,
                ),
                itemCount: infoItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return CardInfoRow(
                    info: infoItems[index],
                    fontSize: 13.sp,
                    iconSize: 14.sp,
                  );
                },
              );
            },
          ),
        ),

        SizedBox(height: 24.sp),

        // ── 2. Products Section Card ──────────────────────────────────────────
        CrmSectionCard(
          titleWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildYellowIconBadge(AppAssets.crmRecord),
              SizedBox(width: 8.sp),
              Text(
                'Products',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          showHideToggle: false,
          child: _buildProductsTable(context),
        ),

        SizedBox(height: 24.sp),

        // ── 3. Services Section Card ──────────────────────────────────────────
        CrmSectionCard(
          titleWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildYellowIconBadge(AppAssets.crmRecord),
              SizedBox(width: 8.sp),
              Text(
                'Services',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          showHideToggle: false,
          child: _buildServicesTable(context),
        ),
      ],
    );
  }

  Widget _buildYellowIconBadge(String assetPath) {
    return Container(
      width: 26.sp,
      height: 26.sp,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomSvgImage(
        assetPath: assetPath,
        width: 14.sp,
        height: 14.sp,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildProductsTable(BuildContext context) {
    final List<Map<String, String>> rows = <Map<String, String>>[
      <String, String>{
        'product': 'Product X',
        'category': 'Category z',
        'qty': '5',
        'unitPrice': '\$100',
        'discount': '25%',
        'tax': '\$700',
        'total': '\$7000',
      },
      <String, String>{
        'product': 'Product X',
        'category': 'Category x',
        'qty': '5',
        'unitPrice': '\$100',
        'discount': '25%',
        'tax': '\$700',
        'total': '\$7000',
      },
      <String, String>{
        'product': 'Product X',
        'category': 'Category x',
        'qty': '5',
        'unitPrice': '\$100',
        'discount': '25%',
        'tax': '\$700',
        'total': '\$7000',
      },
      <String, String>{
        'product': 'Product X',
        'category': 'Category x',
        'qty': '5',
        'unitPrice': '\$100',
        'discount': '25%',
        'tax': '\$700',
        'total': '\$7000',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: <int, TableColumnWidth>{
          0: FixedColumnWidth(160.sp),
          1: FixedColumnWidth(160.sp),
          2: FixedColumnWidth(100.sp),
          3: FixedColumnWidth(120.sp),
          4: FixedColumnWidth(120.sp),
          5: FixedColumnWidth(120.sp),
          6: FixedColumnWidth(120.sp),
        },
        children: <TableRow>[
          // Header
          TableRow(
            children: <Widget>[
              _tableHeaderCell('Product'),
              _tableHeaderCell('Category'),
              _tableHeaderCell('Quantity'),
              _tableHeaderCell('Unit Price'),
              _tableHeaderCell('Discount'),
              _tableHeaderCell('Tax'),
              _tableHeaderCell('Total'),
            ],
          ),
          // Rows
          for (final Map<String, String> r in rows)
            TableRow(
              children: <Widget>[
                _tableDataCell(r['product']!),
                _tableDataCell(r['category']!),
                _tableDataCell(r['qty']!),
                _tableDataCell(r['unitPrice']!),
                _tableDataCell(r['discount']!),
                _tableDataCell(r['tax']!),
                _tableDataCell(r['total']!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildServicesTable(BuildContext context) {
    final List<Map<String, String>> rows = <Map<String, String>>[
      <String, String>{
        'service': 'Service X',
        'category': 'Category z',
        'price': '\$100',
        'discount': '25%',
        'tax': '\$700',
        'total': '\$7000',
      },
      <String, String>{
        'service': 'Service X',
        'category': 'Category z',
        'price': '\$100',
        'discount': '25%',
        'tax': '\$700',
        'total': '\$7000',
      },
      <String, String>{
        'service': 'Service X',
        'category': 'Category z',
        'price': '\$100',
        'discount': '25%',
        'tax': '\$700',
        'total': '\$7000',
      },
      <String, String>{
        'service': 'Service X',
        'category': 'Category z',
        'price': '\$100',
        'discount': '25%',
        'tax': '\$700',
        'total': '\$7000',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: <int, TableColumnWidth>{
          0: FixedColumnWidth(180.sp),
          1: FixedColumnWidth(180.sp),
          2: FixedColumnWidth(120.sp),
          3: FixedColumnWidth(120.sp),
          4: FixedColumnWidth(120.sp),
          5: FixedColumnWidth(120.sp),
        },
        children: <TableRow>[
          // Header
          TableRow(
            children: <Widget>[
              _tableHeaderCell('Services'),
              _tableHeaderCell('Category'),
              _tableHeaderCell('Price'),
              _tableHeaderCell('Discount'),
              _tableHeaderCell('Tax'),
              _tableHeaderCell('Total'),
            ],
          ),
          // Rows
          for (final Map<String, String> r in rows)
            TableRow(
              children: <Widget>[
                _tableDataCell(r['service']!),
                _tableDataCell(r['category']!),
                _tableDataCell(r['price']!),
                _tableDataCell(r['discount']!),
                _tableDataCell(r['tax']!),
                _tableDataCell(r['total']!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 12.sp),
      child: Text(
        title,
        style: StyleText.fontSize14Weight500.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.text,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  Widget _tableDataCell(String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 12.sp),
      child: Text(
        value,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.darkGrey,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
