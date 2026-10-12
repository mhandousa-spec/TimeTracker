// ****************** FILE INFO ******************
// File Name: crm_client_blacklist_banner.dart
// Purpose: Displays blacklist restriction and request metadata in a client profile
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CrmClientBlacklistBanner extends StatelessWidget {
  final CrmClientRecordModel record;

  const CrmClientBlacklistBanner({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final String date = record.blacklistRequestedAt == null
        ? '-'
        : DateFormat('d/M/yyyy').format(record.blacklistRequestedAt!);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.red, width: 1.sp),
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CustomSvgImage(
                  assetPath: AppAssets.crmBlacklist,
                  width: 34.sp,
                  height: 34.sp,
                  color: AppColors.red),
              SizedBox(width: 12.sp),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    Text('Client is Blacklisted',
                        style: StyleText.fontSize18Weight600
                            .copyWith(color: AppColors.red)),
                    Text(
                        'This Client is restricted from creating new deals, quotes or any sales activities',
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.secondaryText)),
                  ])),
            ],
          ),
          SizedBox(height: 14.sp),
          Wrap(spacing: 28.sp, runSpacing: 10.sp, children: <Widget>[
            _item('Status:', 'Pending Approval'),
            _item('Request Date:', date),
            _item(
                'Request By:',
                record.blacklistRequestedBy.isEmpty
                    ? '-'
                    : record.blacklistRequestedBy),
            _item('Reason:',
                record.blacklistReason.isEmpty ? '-' : record.blacklistReason),
          ]),
        ],
      ),
    );
  }

  Widget _item(String label, String value) => Text.rich(TextSpan(
          text: '$label ',
          style: StyleText.fontSize14Weight500,
          children: <TextSpan>[
            TextSpan(
                text: value,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.secondaryText))
          ]));
}
