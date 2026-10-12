// ****************** FILE INFO ******************
// File Name: crm_employee_selection_card.dart
// Purpose: Selectable employee card for Team Manager/Members picker matching Figma design.
//          Shows circular avatar, full name, and role. Selected state = yellow/primary border.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';

class CrmEmployeeSelectionCard extends StatelessWidget {
  final CrmTeamMemberModel employee;
  final bool isSelected;
  final VoidCallback onTap;

  const CrmEmployeeSelectionCard({
    super.key,
    required this.employee,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.yellow : AppColors.borderCard,
            width: isSelected ? 2.sp : 1.sp,
          ),
        ),
        child: Row(
          children: <Widget>[
            _buildAvatar(),
            SizedBox(width: 10.sp),
            _buildNameRole(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final bool hasPhoto =
        employee.avatarUrl != null && employee.avatarUrl!.isNotEmpty;
    return ClipOval(
      child: Container(
        width: 38.sp,
        height: 38.sp,
        color: AppColors.background,
        child: hasPhoto
            ? Image.network(
                employee.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderIcon(),
              )
            : _placeholderIcon(),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Icon(
      Icons.person,
      size: 22.sp,
      color: AppColors.darkGrey,
    );
  }

  Widget _buildNameRole() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            employee.name,
            style: StyleText.fontSize14Weight500.copyWith(
              fontSize: 13.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.sp),
          Text(
            employee.role,
            style: StyleText.fontSize12Weight400.copyWith(
              fontSize: 11.sp,
              color: AppColors.darkGrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
