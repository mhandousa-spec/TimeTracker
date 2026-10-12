// ****************** FILE INFO ******************
// File Name: crm_deal_overview_assigned_card.dart
// Purpose: Assigned Employee details card with Message button for Deal Overview tab matching Figma screenshot 1
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmDealOverviewAssignedCard extends StatelessWidget {
  final String name;
  final String jobTitle;
  final String phone;
  final String department;
  final String email;
  final VoidCallback? onMessage;

  const CrmDealOverviewAssignedCard({
    super.key,
    this.name = 'Amro Handousa',
    this.jobTitle = 'Engineer',
    this.phone = '011587954555',
    this.department = 'IT',
    this.email = 'Amr@gmail.com',
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          // Avatar
          ClipOval(
            child: Container(
              width: 44.sp,
              height: 44.sp,
              color: AppColors.card,
              child: Image.network(
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CustomSvgImage(
                  assetPath: AppAssets.crmPerson,
                  width: 24.sp,
                  height: 24.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.sp),
          // Employee Info Columns
          Expanded(
            child: Wrap(
              spacing: 24.sp,
              runSpacing: 8.sp,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: StyleText.fontSize14Weight500.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.badge_outlined,
                            size: 13.sp, color: AppColors.darkGrey),
                        SizedBox(width: 4.sp),
                        Text(
                          'Job Title: $jobTitle',
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.sp),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.phone_outlined,
                            size: 13.sp, color: AppColors.darkGrey),
                        SizedBox(width: 4.sp),
                        Text(
                          'Phone: $phone',
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox.shrink(),
                    SizedBox(height: 18.sp),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.apartment_outlined,
                            size: 13.sp, color: AppColors.darkGrey),
                        SizedBox(width: 4.sp),
                        Text(
                          'Department : $department',
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.sp),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.email_outlined,
                            size: 13.sp, color: AppColors.darkGrey),
                        SizedBox(width: 4.sp),
                        Text(
                          'Email: $email',
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Message Button
                customButtonWithSvg(
                  title: 'Message',
                  image: AppAssets.message,
                  widthImage: 14.sp,
                  heightImage: 14.sp,
                  colorBorder: Colors.transparent,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize12Weight400.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  function: onMessage ?? () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
