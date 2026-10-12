// ****************** FILE INFO ******************
// File Name: crm_client_activities_tab.dart
// Purpose: Activities tab — status filter, search/sort/grid-table toolbar,
//          navigates to CrmClientAddActivityPage for add / view / edit / reschedule.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_activities_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_activities_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_client_add_activity_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_activities_table_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_activity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmClientActivitiesTab extends StatefulWidget {
  final String clientId;
  const CrmClientActivitiesTab({super.key, required this.clientId});

  @override
  State<CrmClientActivitiesTab> createState() => _CrmClientActivitiesTabState();
}

class _CrmClientActivitiesTabState extends State<CrmClientActivitiesTab> {
  late final CrmClientActivitiesCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _cubit = CrmClientActivitiesCubit(clientId: widget.clientId)..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CrmClientActivitiesCubit, CrmClientActivitiesState>(
        builder: (BuildContext context, CrmClientActivitiesState state) {
          if (state.isLoading && state.activities.isEmpty) {
            return Container(
              width: double.infinity,
              height: 200.sp,
              alignment: Alignment.center,
              child: const CircleProgressMaster(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildStatusBar(state),
              SizedBox(height: 16.sp),
              _buildSearchSortBar(state),
              SizedBox(height: 16.sp),
              _buildViewToggleRow(),
              SizedBox(height: 12.sp),
              _buildContent(state),
            ],
          );
        },
      ),
    );
  }

  // ── Status Filter Bar ─────────────────────────────────────────────────────

  Widget _buildStatusBar(CrmClientActivitiesState state) {
    return StatusChipFilter(
      selectedKey: state.status,
      onSelected: _cubit.setStatus,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.card,
      items: <StatusChipItem>[
        StatusChipItem(
          key: 'all',
          label: 'All',
          count: _cubit.count('all'),
        ),
        StatusChipItem(
          key: 'scheduled',
          label: 'Scheduled',
          count: _cubit.count('scheduled'),
          labelColor: AppColors.blue,
        ),
        StatusChipItem(
          key: 'in_progress',
          label: 'In Progress',
          count: _cubit.count('in_progress'),
          labelColor: AppColors.orange,
        ),
        StatusChipItem(
          key: 'completed',
          label: 'Completed',
          count: _cubit.count('completed'),
          labelColor: AppColors.green,
        ),
        StatusChipItem(
          key: 'cancelled',
          label: 'Cancelled',
          count: _cubit.count('cancelled'),
          labelColor: AppColors.red,
        ),
      ],
    );
  }

  // ── Search / Sort Bar ─────────────────────────────────────────────────────

  Widget _buildSearchSortBar(CrmClientActivitiesState state) {
    return CustomSearchFilterSortBar<String, String>(
      searchController: _searchController,
      onSearchChanged: _cubit.setQuery,
      searchHint: 'Search',
      showSort: true,
      sortItems: const <String>['newest', 'oldest'],
      selectedSort: state.sort,
      sortTitle: 'Sort',
      sortLabelBuilder: _sortLabel,
      onSortChanged: _cubit.setSort,
      mobileBreakpoint: 0,
      trailingChildren: <Widget>[_buildAddButton()],
    );
  }

  Widget _buildAddButton() {
    return customButtonWithSvg(
      title: 'Add',
      function: () => _openPage(context, mode: 'add'),
      textStyle: StyleText.fontSize14Weight600.copyWith(
        color: AppColors.black,
      ),
      color: AppColors.primary,
      colorBorder: AppColors.transparent,
      image: AppAssets.add,
      widthImage: 20.sp,
      heightImage: 20.sp,
      svgColor: AppColors.black,
    );
  }

  String _sortLabel(String option) {
    switch (option) {
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      default:
        return option;
    }
  }

  // ── Grid / Table Toggle ───────────────────────────────────────────────────

  Widget _buildViewToggleRow() {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 10.sp,
        children: <Widget>[
          customGridButton(
            function: () => setState(() => _isGridView = true),
            isSelected: _isGridView,
            color: AppColors.card,
            selectedColor: AppColors.primary,
            svgColor: AppColors.black,
            selectedSvgColor: AppColors.black,
          ),
          customTableButton(
            function: () => setState(() => _isGridView = false),
            isSelected: !_isGridView,
            color: AppColors.card,
            selectedColor: AppColors.primary,
            svgColor: AppColors.black,
            selectedSvgColor: AppColors.black,
          ),
        ],
      ),
    );
  }

  // ── Content (Grid or Table) ───────────────────────────────────────────────

  Widget _buildContent(CrmClientActivitiesState state) {
    final List<CrmClientActivityModel> items = _cubit.visibleActivities;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView ? _buildGrid(items) : _buildTable(items);
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.sp, horizontal: 16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 16.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'No Activities Found',
              arabicName: 'لا توجد أنشطة مسجلة',
            ),
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'Click "Add" to create a new activity.',
              arabicName: 'اضغط على "إضافة" لإنشاء نشاط جديد.',
            ),
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<CrmClientActivityModel> items) {
    final double pageWidth = MediaQuery.sizeOf(context).width;
    final int crossAxisCount = pageWidth >= 500.sp
        ? 2
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 80.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemBuilder: (BuildContext ctx, int i) {
        return CrmClientActivityCard(
          item: items[i],
          onTap: () => _openPage(context, mode: 'view', item: items[i]),
        );
      },
    );
  }

  Widget _buildTable(List<CrmClientActivityModel> items) {
    return CrmClientActivitiesTableWidget(
      items: items,
      onTap: (CrmClientActivityModel item) =>
          _openPage(context, mode: 'view', item: item),
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _openPage(
    BuildContext context, {
    required String mode,
    CrmClientActivityModel? item,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmClientAddActivityPage(
          clientId: widget.clientId,
          cubit: _cubit,
          existingActivity: item,
          mode: mode,
        ),
      ),
    );
  }
}
