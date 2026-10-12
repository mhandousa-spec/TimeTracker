// ****************** FILE INFO ******************
// File Name: crm_deal_quotes_tab.dart
// Purpose: Quotes tab content for Deal Details page with status badges, CustomSearchFilterSortBar, grid/table switcher, and compare mode
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_view_mode_toggle_bar.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_quotes_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_quotes_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_compare_quotes_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_quote_details_page.dart';
import 'crm_compare_limit_dialog.dart';
import 'crm_quote_card.dart';
import 'crm_quotes_filter_badges_bar.dart';
import 'crm_quotes_table_view.dart';

class CrmDealQuotesTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealQuotesTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealQuotesTab> createState() => _CrmDealQuotesTabState();
}

class _CrmDealQuotesTabState extends State<CrmDealQuotesTab> {
  late final CrmQuotesCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _sortOptions = <String>[
    'Recent',
    'Oldest',
    'Amount: High-Low',
    'Amount: Low-High',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = CrmQuotesCubit()..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrmQuotesCubit>.value(
      value: _cubit,
      child: BlocBuilder<CrmQuotesCubit, CrmQuotesState>(
        builder: (BuildContext context, CrmQuotesState state) {
          if (state.isLoading && state.allQuotes.isEmpty) {
            return Container(
              height: 240.sp,
              alignment: Alignment.center,
              child: const CircleProgressMaster(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── 1. Status Filter Badges Bar ─────────────────────────────────
              CrmQuotesFilterBadgesBar(
                selectedStatus: state.selectedStatus,
                onStatusSelected: _cubit.filterByStatus,
                allCount: state.allCount,
                pendingCount: state.pendingCount,
                approvedCount: state.approvedCount,
                adjustmentCount: state.adjustmentCount,
                rejectCount: state.rejectCount,
                expiredCount: state.expiredCount,
              ),

              SizedBox(height: 16.sp),

              // ── 2. Search, Filter, Sort, and + Add Bar via CustomSearchFilterSortBar
              CustomSearchFilterSortBar<String, String>(
                searchController: _searchController,
                onSearchChanged: _cubit.setSearchQuery,
                searchHint: 'Search',
                showFilter: true,
                onFilterTap: () {
                  CrmControlDialogs.showSuccessDialog(
                    context: context,
                    title: 'Filter Quotes',
                    subtitle: 'Quotes filter dialog will open here.',
                  );
                },
                showSort: true,
                sortItems: _sortOptions,
                selectedSort: 'Recent',
                sortLabelBuilder: (String item) => item,
                onSortChanged: (String? sort) {},
                fillColor: AppColors.white,
                trailingChildren: <Widget>[
                  customButtonWithSvg(
                    title: FormatHelper.localizedString(
                      englishName: 'Add',
                      arabicName: 'إضافة',
                    ),
                    image: AppAssets.add,
                    widthImage: 14.sp,
                    heightImage: 14.sp,
                    colorBorder: Colors.transparent,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    function: () {
                      CrmNavigationHelper.navigateToCreateQuote(
                        context,
                        deal: widget.deal,
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 14.sp),

              // ── 3. Requests, Compare, Export, and Grid/Table Switcher ────────
              _buildSecondaryActionBar(context, state),

              SizedBox(height: 16.sp),

              // ── 4. Main Quotes Content (Grid / Table) ───────────────────────
              if (state.isGridView)
                _buildQuotesGrid(context, state)
              else
                CrmQuotesTableView(
                  quotes: state.filteredQuotes,
                  onQuoteTapped: (CrmQuoteModel q) =>
                      _showQuoteDetailsDialog(context, q),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSecondaryActionBar(
    BuildContext context,
    CrmQuotesState state,
  ) {
    return CrmViewModeToggleBar(
      isGridView: state.isGridView,
      onViewModeChanged: (bool isGrid) =>
          _cubit.setViewMode(isGridView: isGrid),
      unselectedColor: AppColors.white,
      showSwitchers: true,
      showExport: true,
      onExport: () {
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: 'Export Quotes',
          subtitle: 'Exporting quotes as Excel/PDF.',
        );
      },
      leadingChildren: <Widget>[
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Requests',
            arabicName: 'الطلبات',
          ),
          image: AppAssets.edit,
          widthImage: 14.sp,
          heightImage: 14.sp,
          colorBorder: Colors.transparent,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
          function: () {
            CrmNavigationHelper.navigateToRequests(
              context,
              dealTitle: widget.deal.dealNameEn.isNotEmpty
                  ? widget.deal.dealNameEn
                  : 'ERP System Deal',
            );
          },
        ),
      ],
      trailingActions: state.isCompareMode
          ? <Widget>[
              customButtonWithSvg(
                title: state.selectedQuoteIds.isNotEmpty
                    ? 'Compare (${state.selectedQuoteIds.length})'
                    : 'Compare',
                image: AppAssets.crmCompare,
                widthImage: 14.sp,
                heightImage: 14.sp,
                colorBorder: Colors.transparent,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                function: () => _handleCompareTap(context, state),
              ),
            ]
          : const <Widget>[],
    );
  }

  void _handleCompareTap(BuildContext context, CrmQuotesState state) {
    if (!state.isCompareMode) {
      _cubit.toggleCompareMode();
      return;
    }

    if (state.selectedQuoteIds.length < 2) {
      CrmControlDialogs.showSuccessDialog(
        context: context,
        title: 'Compare Quotes',
        subtitle: 'Please select at least 2 quotes to compare.',
      );
      return;
    }

    if (state.selectedQuoteIds.length > 3) {
      showCrmCompareLimitDialog(context);
      return;
    }

    final List<CrmQuoteModel> selectedQuotes = state.allQuotes
        .where((CrmQuoteModel q) => state.selectedQuoteIds.contains(q.id))
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmCompareQuotesPage(
          deal: widget.deal,
          quotes: selectedQuotes,
        ),
      ),
    );
  }

  Widget _buildQuotesGrid(
    BuildContext context,
    CrmQuotesState state,
  ) {
    if (state.filteredQuotes.isEmpty) {
      return Container(
        height: 200.sp,
        alignment: Alignment.center,
        child: Text(
          'No quotes found.',
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 98.sp,
            crossAxisSpacing: 12.sp,
            mainAxisSpacing: 12.sp,
          ),
          itemCount: state.filteredQuotes.length,
          itemBuilder: (BuildContext context, int index) {
            final CrmQuoteModel quote = state.filteredQuotes[index];
            final bool isSelected = state.selectedQuoteIds.contains(quote.id);

            return CrmQuoteCard(
              quote: quote,
              isCompareMode: state.isCompareMode,
              isSelected: isSelected,
              onTap: () {
                if (state.isCompareMode) {
                  final bool success = _cubit.toggleQuoteSelection(quote.id);
                  if (!success) {
                    showCrmCompareLimitDialog(context);
                  }
                } else {
                  _showQuoteDetailsDialog(context, quote);
                }
              },
            );
          },
        );
      },
    );
  }

  void _showQuoteDetailsDialog(BuildContext context, CrmQuoteModel quote) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmQuoteDetailsPage(
          deal: widget.deal,
          quote: quote,
        ),
      ),
    );
  }
}
