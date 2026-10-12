// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_age_experience_widget.dart
// Purpose: Arranges age and experience dashboard summaries responsively.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/38-custom_responsive.dart';
import '../../../../../../generated/l10n.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';
import 'hr_dashboard_range_summary_widget.dart';

/// Places the age and experience summary cards in a responsive layout.
class HRDashboardAgeExperienceWidget extends StatelessWidget {
  const HRDashboardAgeExperienceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();

    final localization = S.of(context);
    final age = HRDashboardRangeSummaryWidget(
      title: localization.age,
      svgImage: HRAssets.dashboardAge,
      summary: state.ageSummary,
      emptyMessage: localization.noAgeDataAvailable,
    );
    final experience = HRDashboardRangeSummaryWidget(
      title: localization.experienceInOrganization,
      svgImage: HRAssets.dashboardExperience,
      summary: state.experienceSummary,
      emptyMessage: state.positionDataAvailable == false
          ? localization.experienceDataUnavailable
          : localization.noExperienceDataAvailable,
    );

    return ResponsiveHelper(
      mobileWidget: Column(
        children: [
          age,
          SizedBox(height: 16.h),
          experience,
        ],
      ),
      tabletWidget: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: age),
          SizedBox(width: 16.w),
          Expanded(child: experience),
        ],
      ),
    );
  }
}
