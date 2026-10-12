// ****************** FILE INFO ******************
// File Name: crm_relationship_map_node_card.dart
// Purpose: Compact entity node card for Relationship Map hierarchy tree matching Figma design
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';

class CrmRelationshipMapNodeCard extends StatelessWidget {
  final CrmClientRelationshipModel relationship;
  final VoidCallback? onTap;

  const CrmRelationshipMapNodeCard({
    super.key,
    required this.relationship,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = relationship.relatedEntityName.isNotEmpty
        ? relationship.relatedEntityName
        : (relationship.relatedEntityNameAr ?? 'Unknown');

    final String role = relationship.relatedEntityRole?.isNotEmpty == true
        ? relationship.relatedEntityRole!
        : (relationship.typeNameEn.isNotEmpty
            ? relationship.typeNameEn
            : relationship.categoryNameEn);

    final bool isActive = relationship.isActive;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.sp),
      child: Container(
        width: 190.sp,
        height: 68.sp,
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
            width: 1.sp,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildAvatar(initial),
            SizedBox(width: 10.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    name,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.text,
                      fontSize: 13.sp,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    role,
                    style: StyleText.fontSize12Weight600.copyWith(color: AppColors.darkGrey).copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 10.sp,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.sp),
                  _buildStatusPill(isActive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String initial) {
    if (relationship.relatedEntityAvatar != null &&
        relationship.relatedEntityAvatar!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          relationship.relatedEntityAvatar!,
          width: 38.sp,
          height: 38.sp,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(initial),
        ),
      );
    }
    return _fallbackAvatar(initial);
  }

  Widget _fallbackAvatar(String initial) {
    return Container(
      width: 38.sp,
      height: 38.sp,
      decoration: const BoxDecoration(
        color: Color(0xFF6C757D),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: StyleText.fontSize16Weight400.copyWith(color: Colors.white).copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 1.5.sp),
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.orange,
        borderRadius: BorderRadius.circular(3.sp),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}
