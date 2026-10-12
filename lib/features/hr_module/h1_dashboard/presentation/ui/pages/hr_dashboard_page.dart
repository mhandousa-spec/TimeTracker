// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_page.dart
// Purpose: Renders the HR dashboard and its loading and error states.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../generated/l10n.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../widgets/hr_dashboard_actions_widget.dart';
import '../widgets/hr_dashboard_age_experience_widget.dart';
import '../widgets/hr_dashboard_demographics_widget.dart';
import '../widgets/hr_dashboard_distribution_charts_widget.dart';
import '../widgets/hr_dashboard_overall_widget.dart';
import '../widgets/hr_dashboard_position_analytics_widget.dart';

class HRDashboardPage extends StatelessWidget {
  const HRDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hrModuleDataState = context.watch<HrModuleDataCubit>().state;
    final isLoadingWithoutData = hrModuleDataState is HrModuleDataInitial ||
        hrModuleDataState is HrModuleDataLoading &&
            hrModuleDataState.employees.isEmpty &&
            hrModuleDataState.departments.isEmpty;
    final isErrorWithoutData = hrModuleDataState is HrModuleDataError &&
        hrModuleDataState.employees.isEmpty &&
        hrModuleDataState.departments.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [S.of(context).humanResources],
              ),
              Expanded(
                child: BlocBuilder<HrDashboardCubit, HrDashboardState>(
                  builder: (context, state) {
                    if (isLoadingWithoutData || state is HrDashboardLoading) {
                      return const CircleProgressMaster();
                    }
                    if (isErrorWithoutData || state is HrDashboardError) {
                      return Center(
                        child: Text(
                          hrModuleDataState is HrModuleDataError
                              ? hrModuleDataState.message
                              : S.of(context).errorLoadingDashboard,
                        ),
                      );
                    }
                    if (state is! HrDashboardLoaded) {
                      return const SizedBox.shrink();
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          HRDashboardActionsWidget(),
                          SizedBox(height: 16),
                          HRDashboardOverallWidget(),
                          SizedBox(height: 16),
                          HRDashboardAgeExperienceWidget(),
                          SizedBox(height: 16),
                          HRDashboardDemographicsWidget(),
                          SizedBox(height: 16),
                          HRDashboardDistributionChartsWidget(),
                          SizedBox(height: 16),
                          HRDashboardPositionAnalyticsWidget(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
