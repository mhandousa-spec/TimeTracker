// ****************** FILE INFO ******************
// File Name: crm_clients_dashboard_page.dart
// Purpose: CRM clients dashboard page aligned to the Figma dashboard tab
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_header_filters_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_kpi_stats_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_donut_charts_grid_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_bar_charts_section_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_horizontal_charts_section_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_sections_grid_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_dashboard_view_data.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_state.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';

import 'package:knowticed_plus/generated/l10n.dart';

class CrmClientsDashboardPage extends StatefulWidget {
  const CrmClientsDashboardPage({super.key});

  @override
  State<CrmClientsDashboardPage> createState() =>
      _CrmClientsDashboardPageState();
}

class _CrmClientsDashboardPageState extends State<CrmClientsDashboardPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        child: BlocListener<CrmClientsListCubit, CrmClientsListState>(
          listener: (BuildContext context, CrmClientsListState state) {
            final String? message = state.errorMessage;
            if (message != null && message.isNotEmpty) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.red,
                  ),
                );
              context.read<CrmClientsListCubit>().clearMessages();
            }
          },
          child: BlocBuilder<CrmClientsListCubit, CrmClientsListState>(
            builder: (BuildContext context, CrmClientsListState state) {
              if (state.isLoading && state.records.isEmpty) {
                return const CircleProgressMaster();
              }

              final CrmClientsDashboardViewData viewData =
                  CrmClientsDashboardViewDataBuilder.fromState(state);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CrmHeaderFiltersWidget(
                      selectedTab: _selectedTab,
                      cityOptions: viewData.filterOptions.cities,
                      countryOptions: viewData.filterOptions.countries,
                      statusOptions: viewData.filterOptions.statuses,
                      clientTypeOptions: viewData.filterOptions.clientTypes,
                      selectedCity: state.dashboardCity,
                      selectedCountry: state.dashboardCountry,
                      selectedStatus: state.dashboardStatus,
                      selectedClientTypeId: state.dashboardClientTypeId,
                      calendarStartDate: state.dashboardStartDate,
                      calendarEndDate: state.dashboardEndDate,
                      onTabChanged: (int index) {
                        setState(() => _selectedTab = index);
                      },
                      onCityChanged: (String? value) {
                        context
                            .read<CrmClientsListCubit>()
                            .setDashboardCityFilter(value);
                      },
                      onCountryChanged: (String? value) {
                        context
                            .read<CrmClientsListCubit>()
                            .setDashboardCountryFilter(value);
                      },
                      onStatusChanged: (String? value) {
                        context
                            .read<CrmClientsListCubit>()
                            .setDashboardStatusFilter(value);
                      },
                      onClientTypeChanged: (String? value) {
                        context
                            .read<CrmClientsListCubit>()
                            .setDashboardClientTypeFilter(value);
                      },
                      onCalendarChanged: (DateTime? start, DateTime? end) {
                        context
                            .read<CrmClientsListCubit>()
                            .setDashboardDateRange(start, end);
                      },
                    ),
                    SizedBox(height: 16.sp),
                    if (_selectedTab == 0) ...<Widget>[
                      CrmKpiStatsWidget(kpiData: viewData.kpi),
                      SizedBox(height: 16.sp),
                      CrmDonutChartsGridWidget(cards: viewData.donutCharts),
                      SizedBox(height: 16.sp),
                      CrmBarChartsSectionWidget(
                        clientStatusChart: viewData.clientStatusChart,
                      ),
                      SizedBox(height: 16.sp),
                      CrmHorizontalChartsSectionWidget(
                        charts: viewData.horizontalCharts,
                      ),
                    ] else ...<Widget>[
                      CrmSectionsGridWidget(
                        onSectionTap: (String sectionTitle) {
                          if (sectionTitle == S.current.crmSectionClients ||
                              sectionTitle == 'Clients') {
                            CrmNavigationHelper.navigateToClientsList(context);
                          }
                        },
                      ),
                    ],
                    SizedBox(height: 32.sp),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
