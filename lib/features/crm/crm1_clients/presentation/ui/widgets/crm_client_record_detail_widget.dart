// ****************** FILE INFO ******************
// File Name: crm_client_record_detail_widget.dart
// Purpose: Read-only detail view for a single CRM client record
// Author: Mohand Adel
// Created At: 24/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_record_read_only_renderer.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmClientRecordDetailWidget extends StatelessWidget {
  final CrmClientRecordModel record;
  final CrmTemplateModel? template;
  final CrmClientTypeModel? clientType;
  final String fallbackTemplateName;

  const CrmClientRecordDetailWidget({
    super.key,
    required this.record,
    this.template,
    this.clientType,
    required this.fallbackTemplateName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecordHeader(context),
          SizedBox(height: 16.sp),
          if (template != null)
            CrmRecordReadOnlyRenderer(
              template: template!,
              record: record,
            )
          else
            _buildRawValues(),
          SizedBox(height: 24.sp),
        ],
      ),
    );
  }

  Widget _buildRecordHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56.sp,
          height: 56.sp,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          alignment: Alignment.center,
          child: CustomSvgImage(
            assetPath: clientType?.svgAsset ?? AppAssets.crmPerson,
            width: 32.sp,
            height: 32.sp,
            color: AppColors.black,
          ),
        ),
        SizedBox(width: 12.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.primaryDisplayValue ?? fallbackTemplateName,
                style: StyleText.fontSize20Weight600,
              ),
              if (record.secondaryDisplayValue != null)
                Text(
                  record.secondaryDisplayValue!,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
                    color: AppColors.secondaryBlack,
                  ),
                ),
            ],
          ),
        ),
        Text(
          '${S.current.crmClientsCount(1)} · v${record.templateVersion}',
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey),
        ),
      ],
    );
  }

  Widget _buildRawValues() {
    final List<Widget> tiles = record.values.entries.map((entry) {
      return CrmReadOnlyValueTile(label: entry.key, value: entry.value);
    }).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tiles.isEmpty
            ? [
                Text(
                  S.current.noData,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey),
                ),
              ]
            : tiles,
      ),
    );
  }
}
