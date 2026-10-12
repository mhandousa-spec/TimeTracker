// ****************** FILE INFO ******************
// File Name: crm_teams_page.dart
// Purpose: Main CRM Teams listing page supporting Grid/Table views, tabs, search, filter, and export.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/controller/crm_teams_cubit.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/controller/crm_teams_state.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_team_status_tabs.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_teams_grid_view.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_teams_table_view.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_export_documents_dialog.dart';
import 'package:knowticed_plus/features/crm/crm_di.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTeamsPage extends StatefulWidget {
  const CrmTeamsPage({super.key});

  @override
  State<CrmTeamsPage> createState() => _CrmTeamsPageState();
}

class _CrmTeamsPageState extends State<CrmTeamsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    registerCrmDependencies();
    _searchController = TextEditingController();
    context.read<CrmTeamsCubit>().init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onAddTap() {
    CrmNavigationHelper.navigateToAddTeam(
      context,
      existingTeams: context.read<CrmTeamsCubit>().state.teams,
    );
  }

  void _onTeamTap(CrmTeamModel team) {
    CrmNavigationHelper.navigateToTeamDetails(context, team: team);
  }

  void _showExportDialog() {
    showExportDocumentsDialog(
      context: context,
      defaultFileName: 'crm_teams_${DateTime.now().millisecondsSinceEpoch}',
      onSubmit: (String fileName) {
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: FormatHelper.localizedString(
            englishName: 'Exported Successfully',
            arabicName: 'تم التصدير بنجاح',
          ),
          subtitle: FormatHelper.localizedString(
            englishName: 'Exported teams list as "$fileName"',
            arabicName: 'تم تصدير قائمة الفرق باسم "$fileName"',
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Team',
          arabicName: 'الفريق',
        ),
        onFirstTap: () => Navigator.pop(context),
        child: BlocConsumer<CrmTeamsCubit, CrmTeamsState>(
          listener: (BuildContext context, CrmTeamsState state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              CrmControlDialogs.showErrorDialog(
                context: context,
                title: FormatHelper.localizedString(
                  englishName: 'Error',
                  arabicName: 'خطأ',
                ),
                subtitle: state.errorMessage!,
              );
              context.read<CrmTeamsCubit>().clearMessages();
            }
          },
          builder: (BuildContext context, CrmTeamsState state) {
            final CrmTeamsCubit cubit = context.read<CrmTeamsCubit>();
            final List<CrmTeamModel> visibleTeams = cubit.visibleTeams;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Status Filter Tabs (200 All, 20 Active, 20 Inactive)
                  CrmTeamStatusTabs(
                    totalCount: cubit.totalAllCount,
                    activeCount: cubit.totalActiveCount,
                    inactiveCount: cubit.totalInactiveCount,
                    selectedIndex: state.selectedTab,
                    onTabSelected: cubit.setSelectedTab,
                  ),
                  SizedBox(height: 16.sp),

                  // 2. Search & Toolbar Row
                  _buildSearchToolbar(state, cubit),
                  SizedBox(height: 12.sp),

                  // 3. Secondary Actions Toolbar: Export (Left) & Grid/Table Toggle (Right)
                  _buildSecondaryToolbar(state, cubit),
                  SizedBox(height: 16.sp),

                  // 4. Body Content (Loading / Empty / Grid / Table)
                  if (state.isLoading && state.teams.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.sp),
                        child: const CircleProgressMaster(),
                      ),
                    )
                  else if (visibleTeams.isEmpty)
                    _buildEmptyState()
                  else if (state.isGridView)
                    CrmTeamsGridView(
                      teams: visibleTeams,
                      onTeamTap: _onTeamTap,
                    )
                  else
                    CrmTeamsTableView(
                      teams: visibleTeams,
                      onTeamTap: _onTeamTap,
                    ),
                  SizedBox(height: 24.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchToolbar(CrmTeamsState state, CrmTeamsCubit cubit) {
    return CustomSearchFilterSortBar<String, String>(
      searchController: _searchController,
      onSearchChanged: cubit.setSearchQuery,
      searchHint: FormatHelper.localizedString(
        englishName: 'Search',
        arabicName: 'بحث',
      ),
      showFilter: true,
      filterTitle: FormatHelper.localizedString(
        englishName: 'Filter',
        arabicName: 'تصفية',
      ),
      filterItems: const <String>[
        'All',
        'Sales',
        'Marketing',
        'Support',
        'Operations',
        'Consulting',
        'Development',
      ],
      selectedFilter: state.filterType,
      filterLabelBuilder: (String item) => item,
      onFilterChanged: (String? val) =>
          cubit.setFilterType(val == 'All' ? null : val),
      showSort: true,
      sortTitle: FormatHelper.localizedString(
        englishName: 'Sort',
        arabicName: 'ترتيب',
      ),
      sortItems: const <String>[
        'name_asc',
        'name_desc',
        'date_asc',
        'date_desc',
      ],
      selectedSort: state.sortOption,
      sortLabelBuilder: (String item) {
        switch (item) {
          case 'name_asc':
            return 'Name (A-Z)';
          case 'name_desc':
            return 'Name (Z-A)';
          case 'date_asc':
            return 'Oldest First';
          case 'date_desc':
          default:
            return 'Newest First';
        }
      },
      onSortChanged: cubit.setSortOption,
      trailingChildren: <Widget>[
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Add',
            arabicName: 'إضافة',
          ),
          image: AppAssets.crmPlusBold,
          widthImage: 14.sp,
          heightImage: 14.sp,
          color: AppColors.primary,
          colorBorder: AppColors.primary,
          svgColor: AppColors.blackButton,
          textStyle: StyleText.fontSize14Weight500,
          function: _onAddTap,
        ),
      ],
    );
  }

  Widget _buildSecondaryToolbar(CrmTeamsState state, CrmTeamsCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        // Export Button
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Export',
            arabicName: 'تصدير',
          ),
          image: AppAssets.export,
          widthImage: 14.sp,
          heightImage: 14.sp,
          color: AppColors.primary,
          colorBorder: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500,
          function: _showExportDialog,
        ),
        SizedBox(width: 8.sp),


        // Grid View Toggle
        customGridButton(
          isSelected: state.isGridView,
          function: () => cubit.setViewMode(true),
          color: AppColors.card,
        ),
        SizedBox(width: 8.sp),

        // Table View Toggle
        customTableButton(
          isSelected: !state.isGridView,
          function: () => cubit.setViewMode(false),
          color: AppColors.card,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: _onAddTap,
      borderRadius: BorderRadius.circular(8.sp),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomSvgImage(
                assetPath: AppAssets.crmTeamsEmpty,
                width: 320.sp,
                height: 260.sp,
              ),
              SizedBox(height: 16.sp),
              Text(
                S.current.crmPressToAdd,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

