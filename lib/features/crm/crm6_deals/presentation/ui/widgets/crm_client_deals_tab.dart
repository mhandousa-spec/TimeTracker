// ****************** FILE INFO ******************
// File Name: crm_client_deals_tab.dart
// Purpose: Deals tab content for Client Profile — embedding KPI Summary Bar, Toolbar, Filter, Sort, Kanban & Table views
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deals_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deals_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_add_deal_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_deal_details_page.dart';
import 'crm_deals_kanban_board_view.dart';
import 'crm_deals_kpi_summary_bar.dart';
import 'crm_deals_table_view.dart';
import 'crm_deals_toolbar.dart';

class CrmClientDealsTab extends StatefulWidget {
  final String clientId;

  const CrmClientDealsTab({
    super.key,
    required this.clientId,
  });

  @override
  State<CrmClientDealsTab> createState() => _CrmClientDealsTabState();
}

class _CrmClientDealsTabState extends State<CrmClientDealsTab> {
  late final CrmClientDealsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = CrmClientDealsCubit(clientId: widget.clientId)..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrmClientDealsCubit>.value(
      value: _cubit,
      child: BlocBuilder<CrmClientDealsCubit, CrmClientDealsState>(
        builder: (BuildContext context, CrmClientDealsState state) {
          if (state.isLoading && state.deals.isEmpty) {
            return Container(
              width: double.infinity,
              height: 240.sp,
              alignment: Alignment.center,
              child: const CircleProgressMaster(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. KPI Summary Bar (5 Stat Cards)
              CrmDealsKpiSummaryBar(
                totalDeals: state.totalDeals,
                wonDeals: state.wonDeals,
                lostDeals: state.lostDeals,
                totalValue: state.totalValue,
                revenue: state.revenue,
              ),
              SizedBox(height: 16.sp),

              // 2. Toolbar: Search, Filter Dialog, Sort Dropdown, + Add, Saved View, Export, Grid/Table
              CrmDealsToolbar(
                searchController: _searchController,
                onSearchChanged: _cubit.setSearchQuery,
                currentSort: state.sortOption,
                onSortChanged: _cubit.setSortOption,
                isGridView: state.isGridView,
                onViewModeChanged: (bool isGrid) =>
                    _cubit.setViewMode(isGridView: isGrid),
                activeStage: state.selectedStage,
                activeCategory: state.selectedCategory,
                activeValueFrom: state.expectedValueFrom,
                activeValueTo: state.expectedValueTo,
                activeStartDate: state.startDate,
                activeCloseDate: state.closeDate,
                activeEmployee: state.assignedEmployee,
                onApplyFilter: ({
                  String? stage,
                  String? category,
                  double? expectedValueFrom,
                  double? expectedValueTo,
                  DateTime? startDate,
                  DateTime? closeDate,
                  String? assignedEmployee,
                }) {
                  _cubit.applyFilter(
                    stage: stage,
                    category: category,
                    expectedValueFrom: expectedValueFrom,
                    expectedValueTo: expectedValueTo,
                    startDate: startDate,
                    closeDate: closeDate,
                    assignedEmployee: assignedEmployee,
                  );
                },
                onAddDeal: () => _showAddDealNotice(context),
                onExport: () => _showExportNotice(context),
                onAddView: () => _showAddViewNotice(context),
              ),
              SizedBox(height: 16.sp),

              // 3. View Content: Kanban Board vs. Table View
              if (state.isGridView)
                CrmDealsKanbanBoardView(
                  deals: state.filteredDeals,
                  onAddDealToStage: (String stage) =>
                      _showAddDealNotice(context, stage: stage),
                  onDealTap: (CrmClientDealModel deal) =>
                      _showDealDetails(context, deal),
                )
              else
                CrmDealsTableView(
                  deals: state.filteredDeals,
                  onDealTap: (CrmClientDealModel deal) =>
                      _showDealDetails(context, deal),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showAddDealNotice(BuildContext context, {String? stage}) {
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (_) => CrmAddDealPage(clientId: widget.clientId),
      ),
    );
  }

  void _showExportNotice(BuildContext context) {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Export Deals',
        arabicName: 'تصدير الصفقات',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Exporting deals list as Excel/PDF.',
        arabicName: 'جاري تصدير قائمة الصفقات كملف Excel/PDF.',
      ),
    );
  }

  void _showAddViewNotice(BuildContext context) {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Add Custom View',
        arabicName: 'إضافة عرض مخصص',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Custom table view builder will be connected in Phase 2.',
        arabicName: 'سيتم ربط منشئ العروض المخصصة في المرحلة الثانية.',
      ),
    );
  }

  void _showDealDetails(BuildContext context, CrmClientDealModel deal) {
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (_) => CrmDealDetailsPage(deal: deal),
      ),
    );
  }
}
