// ****************** FILE INFO ******************
// File Name: crm_client_relationship_card.dart
// Purpose: Relationship card widget for displaying client relationship records in the relationship tab
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_card_info_row.dart';

class CrmClientRelationshipCard extends StatelessWidget {
  final CrmClientRelationshipModel relationship;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CrmClientRelationshipCard({
    super.key,
    required this.relationship,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String startDateStr = relationship.startDate != null
        ? '${relationship.startDate!.day}/${relationship.startDate!.month}/${relationship.startDate!.year}'
        : '-';
    final String entityType = relationship.relatedEntityType.isNotEmpty
        ? relationship.relatedEntityType
        : 'Person';
    final String entityTypeDisplay = entityType.toLowerCase() == 'employee'
        ? 'Person'
        : '${entityType[0].toUpperCase()}${entityType.substring(1)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isCompact = constraints.maxWidth < 520.sp;
          final double avatarSize = isCompact ? 52.sp : 74.sp;
          final double contentSpacing = isCompact ? 10.sp : 24.sp;

          return Container(
            padding: EdgeInsets.all(isCompact ? 12.sp : 18.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildAvatar(size: avatarSize),
                      SizedBox(width: contentSpacing),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: isCompact ? 0 : 66.sp),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                relationship.relatedEntityName,
                                style: StyleText.fontSize16Weight600
                                    .copyWith(
                                  color: AppColors.text,
                                  fontSize: isCompact ? 13.sp : 16.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isCompact ? 7.sp : 12.sp),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: _buildInfoColumn(
                                      firstAsset: AppAssets.crmClientsType,
                                      firstLabel: 'Type:',
                                      firstValue: entityTypeDisplay,
                                      secondAsset: AppAssets.crmRelationship,
                                      secondLabel: 'Relationship:',
                                      secondValue:
                                          relationship.typeNameEn.isNotEmpty
                                              ? relationship.typeNameEn
                                              : relationship.typeNameAr,
                                      isCompact: isCompact,
                                    ),
                                  ),
                                  SizedBox(width: isCompact ? 6.sp : 28.sp),
                                  Expanded(
                                    child: _buildInfoColumn(
                                      firstAsset: AppAssets.crmCategoryIcon,
                                      firstLabel: 'Category:',
                                      firstValue:
                                          relationship.categoryNameEn.isNotEmpty
                                              ? relationship.categoryNameEn
                                              : relationship.categoryNameAr,
                                      secondAsset: AppAssets.calendar,
                                      secondLabel: 'Since:',
                                      secondValue: startDateStr,
                                      isCompact: isCompact,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _buildStatusBadge(isCompact: isCompact),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn({
    required String firstAsset,
    required String firstLabel,
    required String firstValue,
    required String secondAsset,
    required String secondLabel,
    required String secondValue,
    required bool isCompact,
  }) {
    final double fontSize = isCompact ? 11 : 12;
    final double iconSize = isCompact ? 14 : 16;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CrmCardInfoItem(
          svgAsset: firstAsset,
          label: firstLabel,
          value: firstValue,
          fontSize: fontSize,
          iconSize: iconSize,
        ),
        SizedBox(height: isCompact ? 5.sp : 10.sp),
        CrmCardInfoItem(
          svgAsset: secondAsset,
          label: secondLabel,
          value: secondValue,
          fontSize: fontSize,
          iconSize: iconSize,
        ),
      ],
    );
  }

  Widget _buildAvatar({required double size}) {
    if (relationship.relatedEntityAvatar != null &&
        relationship.relatedEntityAvatar!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50.sp),
        child: Image.network(
          relationship.relatedEntityAvatar!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(size: size),
        ),
      );
    }
    return _buildFallbackAvatar(size: size);
  }

  Widget _buildFallbackAvatar({double size = 74}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomSvgImage(
        assetPath: AppAssets.crmPerson,
        width: size * 0.38,
        height: size * 0.38,
      ),
    );
  }

  Widget _buildStatusBadge({required bool isCompact}) {
    final bool isActive = relationship.isActive;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 5.sp : 8.sp,
        vertical: isCompact ? 2.sp : 3.sp,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.orange,
        borderRadius: BorderRadius.circular(3.sp),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.white,
          fontSize: isCompact ? 7.sp : 9.sp,
        ),
      ),
    );
  }
}
