// ****************** FILE INFO ******************
// File Name: crm_deal_timeline_item_card.dart
// Purpose: Timeline event row item card with vertical spine, metadata, type/assignee/tag pills and action button matching Figma screenshot
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_timeline_item_model.dart';

class CrmDealTimelineItemCard extends StatelessWidget {
  final CrmDealTimelineItemModel item;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const CrmDealTimelineItemCard({
    super.key,
    required this.item,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 750;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Date & Time Column
          _buildDateTimeColumn(),
          SizedBox(width: 6.sp),

          // 2. Timeline Indicator Spine (Dot + Vertical connecting lines)
          _buildTimelineIndicator(),
          SizedBox(width: 14.sp),

          // 3. Details, Pills & Action Button
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22.sp),
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
    final String formattedDate = DateFormat('d MMM').format(item.date);

    return SizedBox(
      width: 52.sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: 2.sp),
          Text(
            formattedDate,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.sp),
          Text(
            item.time,
            style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
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
        children: <Widget>[
          // Top connector line
          Container(
            width: 2.sp,
            height: 4.sp,
            color: isFirst ? Colors.transparent : const Color(0xFFE2E8F0),
          ),

          // Yellow Ring Circle Node
          Container(
            width: 12.sp,
            height: 12.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(
                color: AppColors.primary,
                width: 2.5.sp,
              ),
            ),
          ),

          // Bottom connector line
          Expanded(
            child: Container(
              width: 2.sp,
              color: isLast ? Colors.transparent : const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 1. Details Block: Title, Subtitle, No & Duration
        Expanded(
          flex: 4,
          child: _buildDetailsBlock(),
        ),
        SizedBox(width: 12.sp),

        // 2. Activity Type Pill (e.g. Call, Meeting)
        _buildActivityTypePill(),
        SizedBox(width: 12.sp),

        // 3. Assigned User Pill (e.g. Sara Ahmed)
        if (item.assignedUserName != null &&
            item.assignedUserName!.isNotEmpty) ...<Widget>[
          _buildAssignedUserPill(),
          SizedBox(width: 12.sp),
        ],

        // 4. Tag Pill (e.g. Deal, Follow Up)
        if (item.tag != null && item.tag!.isNotEmpty) ...<Widget>[
          _buildTagPill(item.tag!),
          SizedBox(width: 12.sp),
        ],

        const Spacer(),

        // 5. Yellow Chevron Action Button
        _buildActionButton(),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _buildDetailsBlock()),
            SizedBox(width: 8.sp),
            _buildActionButton(),
          ],
        ),
        SizedBox(height: 10.sp),
        Wrap(
          spacing: 8.sp,
          runSpacing: 6.sp,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _buildActivityTypePill(),
            if (item.assignedUserName != null &&
                item.assignedUserName!.isNotEmpty)
              _buildAssignedUserPill(),
            if (item.tag != null && item.tag!.isNotEmpty)
              _buildTagPill(item.tag!),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.title,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        if (item.subtitle != null && item.subtitle!.isNotEmpty) ...<Widget>[
          SizedBox(height: 2.sp),
          Text(
            item.subtitle!,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ],
        if (item.itemNumber != null || item.duration != null) ...<Widget>[
          SizedBox(height: 4.sp),
          Row(
            children: <Widget>[
              if (item.itemNumber != null) ...<Widget>[
                Text(
                  '# No: ${item.itemNumber}',
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(width: 12.sp),
              ],
              if (item.duration != null) ...<Widget>[
                Icon(
                  Icons.access_time_rounded,
                  size: 11.sp,
                  color: AppColors.darkGrey,
                ),
                SizedBox(width: 4.sp),
                Text(
                  'Duration: ${item.duration}',
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
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
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        item.activityType,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildAssignedUserPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 18.sp,
            height: 18.sp,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomSvgImage(
              assetPath:
                  item.assignedUserAvatar ?? AppAssets.defaultEmployeeAvatar,
              width: 18.sp,
              height: 18.sp,
            ),
          ),
          SizedBox(width: 6.sp),
          Text(
            item.assignedUserName!,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagPill(String tagText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.local_offer_outlined,
            size: 13.sp,
            color: const Color(0xFFD97706),
          ),
          SizedBox(width: 4.sp),
          Text(
            tagText,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 32.sp,
        height: 32.sp,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13.sp,
          color: AppColors.black,
        ),
      ),
    );
  }
}
