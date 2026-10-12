// ****************** FILE INFO ******************
// File Name: crm_client_dashboard_tab.dart
// Purpose: Dashboard tab content for the CRM client profile with KPIs and charts
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_overview_bar_charts.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_overview_donut_grid.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_overview_kpis.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';

class CrmClientDashboardTab extends StatefulWidget {
  final CrmClientRecordModel record;
  final CrmTemplateModel? template;
  final CrmClientTypeModel? clientType;
  final List<CrmTemplateFieldModel> fields;

  const CrmClientDashboardTab({
    super.key,
    required this.record,
    this.template,
    this.clientType,
    this.fields = const [],
  });

  @override
  State<CrmClientDashboardTab> createState() => _CrmClientDashboardTabState();
}

class _CrmClientDashboardTabState extends State<CrmClientDashboardTab> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Calendar Action Row (aligned to trailing end)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildCalendarButton(context),
          ],
        ),
        SizedBox(height: 12.sp),

        // 1. Mini KPI summary strip (Total Deals, Total Revenue, Relationship, Activities)
        const CrmClientOverviewKpis(),
        SizedBox(height: 16.sp),

        // 2. Donut Charts 2-Column Grid
        CrmClientOverviewDonutGrid(
          record: widget.record,
          fields: widget.fields,
        ),
        SizedBox(height: 16.sp),

        // 3. Bar Charts & Progress Sections
        const CrmClientOverviewBarCharts(),
        SizedBox(height: 32.sp),
      ],
    );
  }

  Widget _buildCalendarButton(BuildContext context) {
    final String label = _selectedDate != null
        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
        : FormatHelper.localizedString(
            englishName: 'Calendar',
            arabicName: 'التقويم',
          );

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(6.sp),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6.sp),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 6.sp),
            CustomSvgImage(
              assetPath: AppAssets.calendar,
              width: 14.sp,
              height: 14.sp,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
