// ****************** FILE INFO ******************
// File Name: crm_related_entity_card.dart
// Purpose: Selectable entity grid card for relationship assignment (matching Figma 302:169503)
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmRelatedEntityCard extends StatelessWidget {
  final EmployeeEntityPro employee;
  final bool isSelected;
  final VoidCallback onTap;

  const CrmRelatedEntityCard({
    super.key,
    required this.employee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String fullName =
        '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim();
    final String displayName =
        fullName.isNotEmpty ? fullName : (employee.email ?? 'Employee');
    final String jobTitle =
        (employee.title ?? employee.role ?? 'Management').trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 6.sp),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 1.5.sp : 1.sp,
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            SizedBox(width: 8.sp),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.text,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    jobTitle,
                    style: StyleText.fontSize12Weight600.copyWith(color: AppColors.darkGrey).copyWith(
                      color: AppColors.darkGrey,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final String? photoUrl = employee.photo;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: 32.sp,
          height: 32.sp,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
        ),
      );
    }
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 32.sp,
      height: 32.sp,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomSvgImage(
        assetPath: AppAssets.crmPerson,
        width: 18.sp,
        height: 18.sp,
      ),
    );
  }
}
