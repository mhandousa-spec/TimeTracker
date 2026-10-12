// ****************** FILE INFO ******************
// File Name: crm_team_member_detail_card.dart
// Purpose: Detailed employee card with contact information and Message action button.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';

class CrmTeamMemberDetailCard extends StatelessWidget {
  final CrmTeamMemberModel member;
  final VoidCallback? onMessageTap;

  const CrmTeamMemberDetailCard({
    super.key,
    required this.member,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: AppColors.card, width: 1.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 1. Avatar
          CircleAvatar(
            radius: 22.sp,
            backgroundColor: AppColors.card,
            backgroundImage: member.avatarUrl != null &&
                    member.avatarUrl!.isNotEmpty
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 24.sp,
                    color: AppColors.darkGrey,
                  )
                : null,
          ),
          SizedBox(width: 12.sp),

          // 2. Info & Attributes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  member.name,
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.sp),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CardInfoRow(
                        fontSize: 11.sp,
                        iconSize: 13.sp,
                        info: CardInfo(
                          icon: Icon(
                            Icons.work_outline,
                            size: 13.sp,
                            color: AppColors.darkGrey,
                          ),
                          label:
                              '${FormatHelper.localizedString(englishName: 'Job Title', arabicName: 'المسمى الوظيفي')}: ',
                          value: member.role,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Expanded(
                      child: CardInfoRow(
                        fontSize: 11.sp,
                        iconSize: 13.sp,
                        info: CardInfo(
                          icon: Icon(
                            Icons.business_outlined,
                            size: 13.sp,
                            color: AppColors.darkGrey,
                          ),
                          label:
                              '${FormatHelper.localizedString(englishName: 'Department', arabicName: 'القسم')}: ',
                          value: member.department,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.sp),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CardInfoRow(
                        fontSize: 11.sp,
                        iconSize: 13.sp,
                        info: CardInfo(
                          icon: Icon(
                            Icons.phone_outlined,
                            size: 13.sp,
                            color: AppColors.darkGrey,
                          ),
                          label:
                              '${FormatHelper.localizedString(englishName: 'Phone', arabicName: 'الهاتف')}: ',
                          value: member.phone.isNotEmpty ? member.phone : '—',
                        ),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Expanded(
                      child: CardInfoRow(
                        fontSize: 11.sp,
                        iconSize: 13.sp,
                        info: CardInfo(
                          icon: Icon(
                            Icons.email_outlined,
                            size: 13.sp,
                            color: AppColors.darkGrey,
                          ),
                          label:
                              '${FormatHelper.localizedString(englishName: 'Email', arabicName: 'البريد')}: ',
                          value: member.email.isNotEmpty ? member.email : '—',
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
          SizedBox(width: 10.sp),

          // 3. Message Button
          InkWell(
            onTap: onMessageTap ?? () {},
            borderRadius: BorderRadius.circular(6.sp),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6.sp),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14.sp,
                    color: AppColors.text,
                  ),
                  SizedBox(width: 6.sp),
                  Text(
                    FormatHelper.localizedString(
                      englishName: 'Message',
                      arabicName: 'رسالة',
                    ),
                    style: StyleText.fontSize12Weight400.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
