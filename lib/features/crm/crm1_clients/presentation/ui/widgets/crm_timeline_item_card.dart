// ****************** FILE INFO ******************
// File Name: crm_timeline_item_card.dart
// Purpose: Extracted timeline event row item with vertical connecting line and tags
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_timeline_item_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmTimelineItemCard extends StatelessWidget {
  final CrmTimelineItemModel item;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const CrmTimelineItemCard({
    super.key,
    required this.item,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date & Time column
          _buildDateTimeColumn(),
          SizedBox(width: 6.sp),

          // 2. Timeline Indicator (Dot + Vertical connecting lines)
          _buildTimelineIndicator(),
          SizedBox(width: 12.sp),

          // 3. Details & Tags layout
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.sp),
              child: isMobile
                  ? _buildMobileContent(context)
                  : _buildDesktopContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeColumn() {
    final String formattedDate = DateFormat('dd MMM').format(item.date);

    return SizedBox(
      width: 48.sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 2.sp),
          Text(
            formattedDate,
            style: StyleText.fontSize12Weight500.copyWith(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.sp),
          Text(
            item.time,
            style: StyleText.fontSize12Weight400.copyWith(
              fontSize: 10.sp,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return SizedBox(
      width: 18.sp,
      child: Column(
        children: [
          // Top connector line
          Container(
            width: 2.sp,
            height: 4.sp,
            color: isFirst ? AppColors.transparent : AppColors.border,
          ),

          // Ring Circle Dot
          Container(
            width: 12.sp,
            height: 12.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(
                color: AppColors.primary,
                width: 2.sp,
              ),
            ),
          ),

          // Bottom connector line
          Expanded(
            child: Container(
              width: 2.sp,
              color: isLast ? AppColors.transparent : AppColors.border,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    final String? primaryTag = item.tags.isNotEmpty
        ? item.tags.first
        : (item.tag != null && item.tag!.isNotEmpty ? item.tag : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Title, Subtitle, & Metadata (Fills remaining space, identical across all rows)
        Expanded(
          child: _buildDetailsBlock(),
        ),
        SizedBox(width: 16.sp),

        // 2. Activity Type Column (Aligned start-to-start)
        SizedBox(
          width: 95.sp,
          child: _buildActivityTypePill(),
        ),
        SizedBox(width: 12.sp),

        // 3. Assigned Employee Column (Aligned start-to-start)
        SizedBox(
          width: 135.sp,
          child:
              item.assignedUserName != null && item.assignedUserName!.isNotEmpty
                  ? _buildAssignedUserPill()
                  : const SizedBox.shrink(),
        ),
        SizedBox(width: 12.sp),

        // 4. Tag Column (Aligned start-to-start; empty space reserved if no tag)
        SizedBox(
          width: 90.sp,
          child: primaryTag != null && primaryTag.isNotEmpty
              ? _buildStageTagPill(primaryTag)
              : const SizedBox.shrink(),
        ),
        SizedBox(width: 12.sp),

        // 5. Action Chevron Button (Far right aligned)
        _buildActionButton(),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    final List<String> effectiveTags = item.tags.isNotEmpty
        ? item.tags
        : (item.tag != null && item.tag!.isNotEmpty
            ? <String>[item.tag!]
            : <String>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDetailsBlock()),
            SizedBox(width: 8.sp),
            _buildActionButton(),
          ],
        ),
        SizedBox(height: 8.sp),
        Wrap(
          spacing: 8.sp,
          runSpacing: 6.sp,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildActivityTypePill(),
            if (item.assignedUserName != null &&
                item.assignedUserName!.isNotEmpty)
              _buildAssignedUserPill(),
            for (final String t in effectiveTags) _buildStageTagPill(t),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
          SizedBox(height: 2.sp),
          Text(
            item.subtitle!,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ],
        if (item.itemNumber != null || item.duration != null) ...[
          SizedBox(height: 6.sp),
          Row(
            children: [
              if (item.itemNumber != null) ...[
                Text(
                  'No: ${item.itemNumber}',
                  style: StyleText.fontSize12Weight400.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(width: 16.sp),
              ],
              if (item.duration != null) ...[
                CustomSvgImage(
                  assetPath: AppAssets.timeSelectorIcon,
                  width: 12.sp,
                  height: 12.sp,
                  color: AppColors.darkGrey,
                ),
                SizedBox(width: 4.sp),
                Text(
                  'Duration: ${item.duration}',
                  style: StyleText.fontSize12Weight400.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActivityTypePill() {
    return Container(
      width: double.infinity,
      height: 29.sp,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.sp),
      ),
      child: Text(
        item.activityType,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAssignedUserPill() {
    final (String displayName, String? avatarUrl) =
        _resolveUser(item.assignedUserName, item.assignedUserAvatar);
    final String initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      width: double.infinity,
      height: 29.sp,
      padding: EdgeInsets.symmetric(horizontal: 6.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserAvatar(avatarUrl, initial),
          SizedBox(width: 6.sp),
          Expanded(
            child: Text(
              displayName,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
                fontSize: 11.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String? avatarUrl, String initial) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 18.sp,
          height: 18.sp,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackInitialAvatar(initial),
        ),
      );
    }
    return _buildFallbackInitialAvatar(initial);
  }

  Widget _buildFallbackInitialAvatar(String initial) {
    return Container(
      width: 18.sp,
      height: 18.sp,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
          color: AppColors.black,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static (String displayName, String? avatarUrl) _resolveUser(
    String? identifier,
    String? explicitAvatar,
  ) {
    if (explicitAvatar != null && explicitAvatar.isNotEmpty) {
      return (identifier ?? 'User', explicitAvatar);
    }
    if (identifier == null || identifier.isEmpty) {
      return ('User', null);
    }
    try {
      final List<EmployeeEntityPro>? employees =
          AppControllers.employee.allEmployeesEntities;
      if (employees != null && employees.isNotEmpty) {
        final String key = identifier.trim().toLowerCase();
        for (final EmployeeEntityPro emp in employees) {
          final String empEmail = (emp.email ?? '').trim().toLowerCase();
          final String empId = (emp.id ?? '').trim().toLowerCase();
          final String firstName = (emp.firstName ?? '').trim().toLowerCase();

          if (empId == key ||
              empEmail == key ||
              (empEmail.isNotEmpty &&
                  (empEmail.startsWith(key) || key.startsWith(empEmail))) ||
              (firstName.isNotEmpty && key.contains(firstName))) {
            final String fullName =
                '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim();
            final String name =
                fullName.isNotEmpty ? fullName : (emp.firstName ?? identifier);
            return (name, emp.photo);
          }
        }
      }
    } catch (_) {}

    // Fallback: Clean up email string to displayable name if email format
    String fallbackName = identifier;
    if (fallbackName.contains('@')) {
      fallbackName = fallbackName.split('@').first;
    }
    fallbackName =
        fallbackName.replaceAll('_', ' ').replaceAll('.', ' ').trim();
    if (fallbackName.isNotEmpty) {
      fallbackName = fallbackName
          .split(' ')
          .map((w) =>
              w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' ');
    }
    return (fallbackName.isNotEmpty ? fallbackName : identifier, null);
  }

  Widget _buildStageTagPill(String tagText) {
    return Container(
      height: 29.sp,
      padding: EdgeInsets.symmetric(horizontal: 8.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSvgImage(
            assetPath: AppAssets.crmTagField,
            width: 14.sp,
            height: 14.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 6.sp),
          Text(
            tagText,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () {
          HapticController.medium();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(4.sp),
        child: Container(
          width: 32.sp,
          height: 29.sp,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.sp),
          ),
          child: Icon(
            Icons.chevron_right,
            color: AppColors.black,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}
