/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: personal_info_card.dart
/// Purpose: Declares `PersonalInfoCard`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Figma node 6550:9620 — personal information card (295x220) with
// Approve / Reject outlined action buttons.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';

/// Approval card: header icon + title + request date, info rows
/// (requester with avatar, job title, department) and Reject/Approve buttons.
///
/// ```dart
/// PersonalInfoCard(
///   title: 'Personal Information',
///   requestDateLabel: 'Request Date:',
///   requestDate: '15 Oct 2024',
///   requestedByName: 'Ahmed Wael',
///   requestedByAvatar: NetworkImage(url),
///   jobTitle: 'Marketing Manager',
///   department: 'UI/UX Design',
///   onReject: () {},
///   onApprove: () {},
/// )
/// ```
class PersonalInfoCard extends StatelessWidget {
  final String title;
  final Widget? headerIcon;
  final String? requestDateLabel;
  final String? requestDate;
  final String requestedByLabel;
  final String requestedByName;
  final ImageProvider? requestedByAvatar;
  final String jobTitleLabel;
  final String jobTitle;
  final String departmentLabel;
  final String department;
  final String rejectText;
  final String approveText;
  final String rejectSvg;
  final String approveSvg;
  final VoidCallback? onReject;
  final VoidCallback? onApprove;
  final double? width;

  const PersonalInfoCard({
    super.key,
    required this.title,
    this.headerIcon,
    this.requestDateLabel,
    this.requestDate,
    this.requestedByLabel = 'Requested by:',
    required this.requestedByName,
    this.requestedByAvatar,
    this.jobTitleLabel = 'Job Title:',
    required this.jobTitle,
    this.departmentLabel = 'Department:',
    required this.department,
    this.rejectText = 'Reject',
    this.approveText = 'Approve',
    this.rejectSvg = 'assets/icons_assets/home_assets/rejected_stamp_red.svg',
    this.approveSvg = 'assets/icons_assets/main_icons_assets/approval_badge_check.svg',
    this.onReject,
    this.onApprove,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 295.w,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: icon box + title + request date.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50.sp,
                    height: 50.sp,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: SizedBox(

                        width: 30.r,
                        height: 30.r,
                        child: FittedBox(

                          child: headerIcon ??
                              CardSvg.icon(CardSvg.personalInfo,color: AppColors.secondaryText),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      title,
                      style: CardStyles.title(14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                ],
              ),
              SizedBox(height: 10.h),
              // Requested by row (with small avatar).
              Row(
                children: [
                  CardSvg.icon(CardSvg.serviceProvider,
                      size: 16, color: AppColors.secondaryText),
                  SizedBox(width: 4.w),
                  Text(requestedByLabel, style: CardStyles.label(13)),
                  SizedBox(width: 6.w),
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.barrierColor,
                    foregroundImage: requestedByAvatar,
                    child: ClipOval(
                      child: CardSvg.icon(CardSvg.male, size: 32),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      requestedByName,
                      style: CardStyles.value(13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CardInfoRow(
                info: CardInfo(
                  label: jobTitleLabel,
                  value: jobTitle,
                  icon: CardSvg.icon(CardSvg.jobTitle,
                      color: AppColors.secondaryBlack),
                ),
                fontSize: 13,
              ),
              SizedBox(height: 10.h),
              CardInfoRow(
                info: CardInfo(
                  label: departmentLabel,
                  value: department,
                  icon: CardSvg.icon(CardSvg.department,
                      color: AppColors.secondaryBlack),
                ),
                fontSize: 13,
              ),
              SizedBox(height: 14.h),
              // Reject / Approve outlined buttons.
              Row(
                children: [
                  Expanded(
                    child: customButtonWithSvg(
                      title: rejectText,
                      function: onReject ?? () {},
                      textStyle:
                          CardStyles.title(16).copyWith(color: AppColors.red),
                      height: 36,
                      space: 8.w,
                      radius: 8.r,
                      color: AppColors.transparent,
                      image: rejectSvg,
                      widthImage: 24.r,
                      heightImage: 24.r,
                      colorBorder: AppColors.red,
                      // svgColor: AppColors.red,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: customButtonWithSvg(
                      title: approveText,
                      function: onApprove ?? () {},
                      textStyle:
                          CardStyles.title(16).copyWith(color: AppColors.green),
                      height: 36,
                      space: 8.w,
                      radius: 8.r,
                      color: AppColors.transparent,
                      image: approveSvg,
                      widthImage: 24.r,
                      heightImage: 24.r,
                      colorBorder: AppColors.green,
                      // svgColor: AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (requestDate != null)
            Text.rich(
              TextSpan(
                text: '${requestDateLabel ?? ''} ',
                style: CardStyles.label(11),
                children: [
                  TextSpan(
                    text: requestDate,
                    style: CardStyles.value(11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
