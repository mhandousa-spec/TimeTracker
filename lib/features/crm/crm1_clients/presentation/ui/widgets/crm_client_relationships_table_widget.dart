// ****************** FILE INFO ******************
// File Name: crm_client_relationships_table_widget.dart
// Purpose: Horizontal data table for client relationships matching Figma design (302:169127)
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';

class CrmClientRelationshipsTableWidget extends StatelessWidget {
  final List<CrmClientRelationshipModel> relationships;
  final ValueChanged<CrmClientRelationshipModel> onTap;
  final ValueChanged<CrmClientRelationshipModel> onEdit;
  final ValueChanged<CrmClientRelationshipModel> onDelete;

  const CrmClientRelationshipsTableWidget({
    super.key,
    required this.relationships,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTableHeader(),
              ...List.generate(relationships.length, (index) {
                final CrmClientRelationshipModel item = relationships[index];
                return _buildTableRow(
                  item: item,
                  index: index,
                  isOdd: index.isOdd,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 42.sp,
      color: const Color(0xFF2D2D2D),
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      child: Row(
        children: [
          _buildHeaderCell('NO', width: 44.sp, alignment: Alignment.centerLeft),
          _buildHeaderCell('Related Entity',
              width: 140.sp, alignment: Alignment.centerLeft),
          _buildHeaderCell('كيان ذو صلة',
              width: 140.sp, alignment: Alignment.centerRight),
          _buildHeaderCell('Photo', width: 60.sp, alignment: Alignment.center),
          _buildHeaderCell('Clients Type',
              width: 110.sp, alignment: Alignment.center),
          _buildHeaderCell('Relationship Category',
              width: 160.sp, alignment: Alignment.center),
          _buildHeaderCell('Relationship Type',
              width: 150.sp, alignment: Alignment.center),
          _buildHeaderCell('Status', width: 90.sp, alignment: Alignment.center),
          _buildHeaderCell('Since', width: 100.sp, alignment: Alignment.center),
          _buildHeaderCell('To', width: 100.sp, alignment: Alignment.center),
          _buildHeaderCell('Note',
              width: 130.sp, alignment: Alignment.centerLeft),
          _buildHeaderCell('ملاحظة',
              width: 130.sp, alignment: Alignment.centerRight),
          _buildHeaderCell('', width: 90.sp, alignment: Alignment.center),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String label, {
    required double width,
    required Alignment alignment,
  }) {
    return Container(
      width: width,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 4.sp),
      child: Text(
        label,
        style: StyleText.fontSize16Weight400.copyWith(color: Colors.white).copyWith(
          color: AppColors.white,
          fontSize: 13.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableRow({
    required CrmClientRelationshipModel item,
    required int index,
    required bool isOdd,
  }) {
    final String sinceStr = item.startDate != null
        ? '${item.startDate!.day}/${item.startDate!.month}/${item.startDate!.year}'
        : '-';
    final String toStr = item.endDate != null
        ? '${item.endDate!.day}/${item.endDate!.month}/${item.endDate!.year}'
        : '-';

    final String clientType =
        item.relatedEntityType.isNotEmpty ? item.relatedEntityType : 'Person';
    final String clientTypeDisplay = clientType.toLowerCase() == 'employee' ||
            clientType.toLowerCase() == 'person'
        ? 'Person'
        : clientType[0].toUpperCase() + clientType.substring(1);

    final Color clientTypeColor = _getClientTypeColor(clientTypeDisplay);
    final bool isActive = item.isActive;

    return InkWell(
      onTap: () => onTap(item),
      child: Container(
        height: 46.sp,
        color: isOdd ? const Color(0xFFF1F1F1) : AppColors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Row(
          children: [
            // NO
            _buildDataCell(
              '${index + 1}',
              width: 44.sp,
              alignment: Alignment.centerLeft,
            ),
            // Related Entity (EN)
            _buildDataCell(
              item.relatedEntityName,
              width: 140.sp,
              alignment: Alignment.centerLeft,
            ),
            // Related Entity (AR)
            _buildDataCell(
              item.relatedEntityNameAr ?? item.relatedEntityName,
              width: 140.sp,
              alignment: Alignment.centerRight,
            ),
            // Photo
            Container(
              width: 60.sp,
              alignment: Alignment.center,
              child: _buildAvatar(item),
            ),
            // Clients Type (colored)
            Container(
              width: 110.sp,
              alignment: Alignment.center,
              child: Text(
                clientTypeDisplay,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: clientTypeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Relationship Category
            _buildDataCell(
              item.categoryNameEn.isNotEmpty
                  ? item.categoryNameEn
                  : item.categoryNameAr,
              width: 160.sp,
              alignment: Alignment.center,
            ),
            // Relationship Type
            _buildDataCell(
              item.typeNameEn.isNotEmpty ? item.typeNameEn : item.typeNameAr,
              width: 150.sp,
              alignment: Alignment.center,
            ),
            // Status (colored)
            Container(
              width: 90.sp,
              alignment: Alignment.center,
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: isActive
                      ? const Color(0xFF4BB609)
                      : const Color(0xFFFF814A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Since
            _buildDataCell(
              sinceStr,
              width: 100.sp,
              alignment: Alignment.center,
            ),
            // To
            _buildDataCell(
              toStr,
              width: 100.sp,
              alignment: Alignment.center,
            ),
            // Note (EN)
            _buildDataCell(
              item.noteEn?.isNotEmpty == true ? item.noteEn! : '-',
              width: 130.sp,
              alignment: Alignment.centerLeft,
            ),
            // Note (AR)
            _buildDataCell(
              item.noteAr?.isNotEmpty == true ? item.noteAr! : '-',
              width: 130.sp,
              alignment: Alignment.centerRight,
            ),
            // Actions
            Container(
              width: 90.sp,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomEditIcon(
                    onTap: () => onEdit(item),
                  ),
                  SizedBox(width: 6.sp),
                  CustomDeleteIcon(
                    onTap: () => onDelete(item),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    required Alignment alignment,
  }) {
    return Container(
      width: width,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 4.sp),
      child: Text(
        text,
        style: StyleText.fontSize12Weight400.copyWith(
          color: const Color(0xFF2D2D2D),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAvatar(CrmClientRelationshipModel item) {
    if (item.relatedEntityAvatar != null &&
        item.relatedEntityAvatar!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          item.relatedEntityAvatar!,
          width: 26.sp,
          height: 26.sp,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
        ),
      );
    }
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 26.sp,
      height: 26.sp,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomSvgImage(
        assetPath: AppAssets.crmPerson,
        width: 14.sp,
        height: 14.sp,
      ),
    );
  }

  Color _getClientTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'person':
      case 'employee':
        return const Color(0xFF287BF6);
      case 'government':
        return const Color(0xFFDCA000);
      case 'company':
        return const Color(0xFF4BB609);
      default:
        return const Color(0xFF287BF6);
    }
  }
}
