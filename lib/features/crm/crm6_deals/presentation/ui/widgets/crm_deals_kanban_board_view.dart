// ****************** FILE INFO ******************
// File Name: crm_deals_kanban_board_view.dart
// Purpose: Horizontally scrollable Pipeline Kanban Board with 7 stage columns matching Figma screenshot 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'crm_deal_kanban_card.dart';

class CrmDealsKanbanBoardView extends StatelessWidget {
  final List<CrmClientDealModel> deals;
  final ValueChanged<String>? onAddDealToStage;
  final ValueChanged<CrmClientDealModel>? onDealTap;

  const CrmDealsKanbanBoardView({
    super.key,
    required this.deals,
    this.onAddDealToStage,
    this.onDealTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stages = <Map<String, dynamic>>[
      {
        'key': 'new',
        'titleEn': 'New',
        'titleAr': 'جديد',
        'bgColor': const Color(0xFFF0F5FF),
        'badgeColor': AppColors.blue,
        'amount': '\$120,000',
        'prob': '25%',
      },
      {
        'key': 'discovery',
        'titleEn': 'Discovery',
        'titleAr': 'اكتشاف',
        'bgColor': const Color(0xFFFFFBEA),
        'badgeColor': const Color(0xFFEAB308),
        'amount': '\$120,000',
        'prob': '25%',
      },
      {
        'key': 'qualified',
        'titleEn': 'Qualified',
        'titleAr': 'مؤهل',
        'bgColor': const Color(0xFFFFF4EC),
        'badgeColor': const Color(0xFFF97316),
        'amount': '\$120,000',
        'prob': '25%',
      },
      {
        'key': 'proposal',
        'titleEn': 'Proposal',
        'titleAr': 'تقديم العرض',
        'bgColor': const Color(0xFFF7F0FF),
        'badgeColor': const Color(0xFF8B5CF6),
        'amount': '\$120,000',
        'prob': '25%',
      },
      {
        'key': 'negotiation',
        'titleEn': 'Negotiation',
        'titleAr': 'تفاوض',
        'bgColor': const Color(0xFFFFF0F5),
        'badgeColor': const Color(0xFFEC4899),
        'amount': '\$120,000',
        'prob': '25%',
      },
      {
        'key': 'closedLost',
        'titleEn': 'Closed Lost',
        'titleAr': 'مغلق خاسر',
        'bgColor': const Color(0xFFFFF0F0),
        'badgeColor': AppColors.red,
        'amount': '\$120,000',
        'prob': '0%',
      },
      {
        'key': 'closedWon',
        'titleEn': 'Closed Won',
        'titleAr': 'مغلق فائز',
        'bgColor': const Color(0xFFF0FFF4),
        'badgeColor': AppColors.green,
        'amount': '\$120,000',
        'prob': '100%',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: stages.map((s) => _buildStageColumn(context, s)).toList(),
      ),
    );
  }

  Widget _buildStageColumn(
      BuildContext context, Map<String, dynamic> stageInfo) {
    final String stageKey = stageInfo['key'] as String;
    final String title = FormatHelper.localizedString(
      englishName: stageInfo['titleEn'] as String,
      arabicName: stageInfo['titleAr'] as String,
    );
    final Color bgColor = stageInfo['bgColor'] as Color;
    final Color badgeColor = stageInfo['badgeColor'] as Color;
    final String amount = stageInfo['amount'] as String;
    final String prob = stageInfo['prob'] as String;

    final List<CrmClientDealModel> stageDeals = deals
        .where((d) => d.stage.toLowerCase() == stageKey.toLowerCase())
        .toList();

    return Container(
      width: 270.sp,
      margin: EdgeInsets.only(right: 14.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row 1: Stage Title + Badge count
          Row(
            children: <Widget>[
              Text(
                title,
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.sp),
              Container(
                width: 22.sp,
                height: 22.sp,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${stageDeals.isNotEmpty ? stageDeals.length * 12 : 24}',
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.sp),

          // Header Row 2: Amount + Probability
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                amount,
                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                prob,
                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),

          // Cards List
          if (stageDeals.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.sp),
              child: Center(
                child: Text(
                  FormatHelper.localizedString(
                    englishName: 'No deals in this stage',
                    arabicName: 'لا توجد صفقات في هذه المرحلة',
                  ),
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            )
          else
            ...stageDeals.map((d) => CrmDealKanbanCard(
                  deal: d,
                  onTap: () => onDealTap?.call(d),
                )),

          SizedBox(height: 8.sp),

          // + Add Deal Button Container
          InkWell(
            onTap: () => onAddDealToStage?.call(stageKey),
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    size: 16.sp,
                    color: AppColors.text,
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    FormatHelper.localizedString(
                      englishName: 'Add Deal',
                      arabicName: 'إضافة صفقة',
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
