// ****************** FILE INFO ******************
// File Name: crm_deal_activity_read_only_employee_card.dart
// Purpose: Read-only assigned employee summary card for Activity View mode matching Screenshot 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';

class CrmDealActivityReadOnlyEmployeeCard extends StatelessWidget {
  final CrmTeamMemberModel? employee;

  const CrmDealActivityReadOnlyEmployeeCard({
    super.key,
    this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final String name = employee?.name ?? 'Amro Handousa';
    final String role = employee?.role ?? 'Engineer';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Employee Avatar
          Container(
            width: 46.sp,
            height: 46.sp,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomSvgImage(
              assetPath: AppAssets.defaultEmployeeAvatar,
              width: 46.sp,
              height: 46.sp,
            ),
          ),
          SizedBox(width: 14.sp),

          // 2x2 Details Grid
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 6.sp),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CardInfoRow(
                        info: CardInfo(
                          label: 'Job Title:',
                          value: role,
                        ),
                        fontSize: 11.sp,
                      ),
                    ),
                    Expanded(
                      child: CardInfoRow(
                        info: const CardInfo(
                          label: 'Department:',
                          value: 'IT',
                        ),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.sp),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CardInfoRow(
                        info: const CardInfo(
                          label: 'Phone:',
                          value: '011587964555',
                        ),
                        fontSize: 11.sp,
                      ),
                    ),
                    Expanded(
                      child: CardInfoRow(
                        info: const CardInfo(
                          label: 'Email:',
                          value: 'Amr@gmail.com',
                        ),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.sp),

          // Yellow Message Button
          customButtonWithSvg(
            title: FormatHelper.localizedString(
              englishName: 'Message',
              arabicName: 'مراسلة',
            ),
            image: AppAssets.chat,
            widthImage: 14.sp,
            heightImage: 14.sp,
            colorBorder: Colors.transparent,
            color: AppColors.primary,
            textStyle: StyleText.fontSize12Weight500.copyWith(
              fontWeight: FontWeight.bold,
            ),
            function: () {
              CrmControlDialogs.showSuccessDialog(
                context: context,
                title: 'Message Employee',
                subtitle: 'Opening chat with $name...',
              );
            },
          ),
        ],
      ),
    );
  }
}
