// ****************** FILE INFO ******************
// File Name: crm_service_items_table.dart
// Purpose: Horizontal scrollable data table for CRM Services with localized columns.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmServiceItemsTable extends StatelessWidget {
  final List<CrmServiceItemModel> services;
  final ValueChanged<CrmServiceItemModel> onItemTap;

  const CrmServiceItemsTable({
    super.key,
    required this.services,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
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
                services.length,
                (int index) => _buildDataRow(
                  index: index,
                  service: services[index],
                  isArabic: isArabic,
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
          _buildHeaderCell(S.current.crmNo, 50.sp),
          _buildHeaderCell(S.current.crmCode, 100.sp),
          _buildHeaderCell(S.current.crmCategory, 140.sp),
          _buildHeaderCell(S.current.serviceName, 180.sp),
          _buildHeaderCell(S.current.crmStatus, 100.sp),
          _buildHeaderCell(S.current.unitPrice, 110.sp),
          _buildHeaderCell(S.current.currency, 90.sp),
          _buildHeaderCell(S.current.crmRule, 130.sp),
          _buildHeaderCell('${S.current.vat} (%)', 90.sp),
          _buildHeaderCell(S.current.lastUpdate, 130.sp),
          _buildHeaderCell(S.current.crmNote, 180.sp),
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
    required CrmServiceItemModel service,
    required bool isArabic,
  }) {
    final bool isEven = index % 2 == 0;
    final DateTime? updatedAt = service.audit?.updatedAt;
    final DateTime? createdAt = service.audit?.createdAt;
    final String lastUpdated = updatedAt != null
        ? DateFormat('dd/MM/yyyy').format(updatedAt)
        : (createdAt != null
            ? DateFormat('dd/MM/yyyy').format(createdAt)
            : '-');

    return InkWell(
      onTap: () => onItemTap(service),
      child: Container(
        height: 44.sp,
        color: isEven ? AppColors.white : AppColors.background,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Row(
          children: <Widget>[
            _buildDataCell('${index + 1}', 50.sp),
            _buildDataCell(service.code, 100.sp),
            _buildDataCell(service.localizedCategoryName(isArabic), 140.sp),
            _buildDataCell(service.localizedName(isArabic), 180.sp),
            SizedBox(
              width: 100.sp,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.sp, vertical: 3.sp),
                  decoration: BoxDecoration(
                    color: service.isActive
                        ? AppColors.green.withValues(alpha: 0.15)
                        : AppColors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: Text(
                    service.isActive
                        ? S.current.crmActive
                        : S.current.crmInactive,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color:
                          service.isActive ? AppColors.green : AppColors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            _buildDataCell(
              service.unitPrice > 0
                  ? service.unitPrice.toStringAsFixed(0)
                  : '-',
              110.sp,
            ),
            _buildDataCell(service.currency, 90.sp),
            _buildDataCell(
              service.discountRule.isNotEmpty ? service.discountRule : '-',
              130.sp,
            ),
            _buildDataCell(
              service.tax > 0 ? '${service.tax.toStringAsFixed(0)}%' : '-',
              90.sp,
            ),
            _buildDataCell(lastUpdated, 130.sp),
            _buildDataCell(
              service.localizedNote(isArabic).isNotEmpty
                  ? service.localizedNote(isArabic)
                  : '-',
              180.sp,
            ),
            SizedBox(
              width: 50.sp,
              child: Align(
                alignment: Alignment.centerRight,
                child: CustomSvgImage(
                  assetPath: AppAssets.crmArrowRight,
                  width: 14.sp,
                  height: 14.sp,
                  color: AppColors.grey,
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
