// ****************** FILE INFO ******************
// File Name: crm_product_items_table.dart
// Purpose: Horizontal scrollable data table for CRM Products matching Figma designs.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmProductItemsTable extends StatelessWidget {
  final List<CrmProductItemModel> products;
  final ValueChanged<CrmProductItemModel> onItemTap;

  const CrmProductItemsTable({
    super.key,
    required this.products,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.sp),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeaderRow(),
              ...List<Widget>.generate(
                products.length,
                (int index) => _buildDataRow(
                  index: index,
                  product: products[index],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      height: 42.sp,
      color: const Color(0xFF2D2D2D),
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      child: Row(
        children: <Widget>[
          _buildHeaderCell('NO', 50.sp),
          _buildHeaderCell('Code', 100.sp),
          _buildHeaderCell('Categories', 120.sp),
          _buildHeaderCell('Product Name', 140.sp),
          _buildHeaderCell('اسم المنتج', 140.sp),
          _buildHeaderCell('Status', 90.sp),
          _buildHeaderCell('Unit Price', 100.sp),
          _buildHeaderCell('Currency', 80.sp),
          _buildHeaderCell('Discount Rule', 120.sp),
          _buildHeaderCell('Tax', 80.sp),
          _buildHeaderCell('Last Update', 120.sp),
          _buildHeaderCell('Adding date', 120.sp),
          _buildHeaderCell('Note', 150.sp),
          _buildHeaderCell('ملاحظة', 150.sp),
          SizedBox(width: 50.sp),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, double width) {
    return SizedBox(
      width: width,
      child: Text(
        title,
        style: StyleText.fontSize14Weight600.copyWith(
          color: AppColors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataRow({
    required int index,
    required CrmProductItemModel product,
  }) {
    final bool isEven = index % 2 == 0;
    final Color rowBg = isEven ? const Color(0xFFF1F1F1) : AppColors.white;
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final String addingDate = product.audit?.createdAt != null
        ? formatter.format(product.audit!.createdAt)
        : '-';
    final String lastUpdate = product.audit?.updatedAt != null
        ? formatter.format(product.audit!.updatedAt)
        : addingDate;

    return GestureDetector(
      onTap: () => onItemTap(product),
      child: Container(
        height: 45.sp,
        color: rowBg,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Row(
          children: <Widget>[
            _buildDataCell((index + 1).toString(), 50.sp),
            _buildDataCell(
                product.code.isNotEmpty ? product.code : '-', 100.sp),
            _buildDataCell(
                product.categoryNameEn.isNotEmpty
                    ? product.categoryNameEn
                    : '-',
                120.sp),
            _buildDataCell(
                product.nameEn.isNotEmpty ? product.nameEn : '-', 140.sp),
            _buildDataCell(
                product.nameAr.isNotEmpty ? product.nameAr : '-', 140.sp),
            SizedBox(
              width: 90.sp,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
                  decoration: BoxDecoration(
                    color:
                        product.isActive ? AppColors.green : AppColors.orange,
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: Text(
                    product.isActive
                        ? S.current.crmActive
                        : S.current.crmInactive,
                    style: StyleText.fontSize10Weight600.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            _buildDataCell(product.unitPrice.toStringAsFixed(0), 100.sp),
            _buildDataCell(product.currency, 80.sp),
            _buildDataCell(
                product.discountRule.isNotEmpty ? product.discountRule : '-',
                120.sp),
            _buildDataCell('${product.tax.toStringAsFixed(0)}%', 80.sp),
            _buildDataCell(lastUpdate, 120.sp),
            _buildDataCell(addingDate, 120.sp),
            _buildDataCell(
                product.noteEn.isNotEmpty ? product.noteEn : '-', 150.sp),
            _buildDataCell(
                product.noteAr.isNotEmpty ? product.noteAr : '-', 150.sp),
            SizedBox(
              width: 50.sp,
              child: Center(
                child: CustomSvgImage(
                  assetPath: AppAssets.crmArrowRight,
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.text,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
