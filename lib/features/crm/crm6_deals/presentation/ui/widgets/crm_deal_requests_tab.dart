// ****************** FILE INFO ******************
// File Name: crm_deal_requests_tab.dart
// Purpose: Requests tab content for Deal Details page with status badges, search/sort/filter bar, Export, Grid/Table view switchers matching Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_request_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_request_details_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_request_card.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_requests_filter_badges_bar.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_requests_table_view.dart';

class CrmDealRequestsTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealRequestsTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealRequestsTab> createState() => _CrmDealRequestsTabState();
}

class _CrmDealRequestsTabState extends State<CrmDealRequestsTab> {
  final TextEditingController _searchController = TextEditingController();
  CrmRequestStatus _selectedStatusFilter = CrmRequestStatus.all;
  bool _isGridView = false;

  final List<CrmDealRequestModel> _allRequests = <CrmDealRequestModel>[
    const CrmDealRequestModel(
      id: '1',
      no: 1,
      quoteNo: '15256',
      version: 'V1',
      status: CrmRequestStatus.approved,
      validUntil: '7/12/2026',
      totalFormatted: '\$500',
    ),
    const CrmDealRequestModel(
      id: '2',
      no: 1,
      quoteNo: '15256',
      version: 'V1',
      status: CrmRequestStatus.pending,
      validUntil: '7/12/2026',
      totalFormatted: '\$500',
    ),
    const CrmDealRequestModel(
      id: '3',
      no: 1,
      quoteNo: '15256',
      version: 'V1',
      status: CrmRequestStatus.pending,
      validUntil: '7/12/2026',
      totalFormatted: '\$500',
    ),
    const CrmDealRequestModel(
      id: '4',
      no: 1,
      quoteNo: '15256',
      version: 'V1',
      status: CrmRequestStatus.approved,
      validUntil: '7/12/2026',
      totalFormatted: '\$500',
    ),
    const CrmDealRequestModel(
      id: '5',
      no: 1,
      quoteNo: '15256',
      version: 'V1',
      status: CrmRequestStatus.approved,
      validUntil: '7/12/2026',
      totalFormatted: '\$500',
    ),
    const CrmDealRequestModel(
      id: '6',
      no: 1,
      quoteNo: '15256',
      version: 'V1',
      status: CrmRequestStatus.reject,
      validUntil: '7/12/2026',
      totalFormatted: '\$500',
    ),
    const CrmDealRequestModel(
      id: '7',
      no: 1,
      quoteNo: '15256',
      version: 'V1',
      status: CrmRequestStatus.reject,
      validUntil: '7/12/2026',
      totalFormatted: '\$500',
    ),
  ];

  static const List<String> _sortOptions = <String>[
    'Recent',
    'Oldest',
    'Quote No',
    'Status',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CrmDealRequestModel> get _filteredRequests {
    return _allRequests.where((CrmDealRequestModel req) {
      if (_selectedStatusFilter != CrmRequestStatus.all &&
          req.status != _selectedStatusFilter) {
        return false;
      }
      if (_searchController.text.trim().isNotEmpty) {
        final String q = _searchController.text.trim().toLowerCase();
        final bool matchesQuote = req.quoteNo.toLowerCase().contains(q);
        final bool matchesStatus = req.status.labelEn.toLowerCase().contains(q);
        if (!matchesQuote && !matchesStatus) return false;
      }
      return true;
    }).toList();
  }

  void _navigateToDetails(CrmDealRequestModel req) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmRequestDetailsPage(
          dealTitle: widget.deal.dealNameEn.isNotEmpty
              ? widget.deal.dealNameEn
              : 'ERP System Deal',
          request: req,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CrmDealRequestModel> displayList = _filteredRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. KPI Filter Badges Bar via StatusChipFilter ──────────────────────
        CrmRequestsFilterBadgesBar(
          selectedStatus: _selectedStatusFilter,
          onStatusSelected: (CrmRequestStatus status) =>
              setState(() => _selectedStatusFilter = status),
          allCount: 200,
          pendingCount: 20,
          approvedCount: 20,
          rejectCount: 20,
        ),

        SizedBox(height: 18.sp),

        // ── 2. Search, Filter & Sort Bar ──────────────────────────────────────
        CustomSearchFilterSortBar<String, String>(
          searchController: _searchController,
          onSearchChanged: (_) => setState(() {}),
          searchHint: 'Search',
          showFilter: true,
          onFilterTap: () {
            CrmControlDialogs.showSuccessDialog(
              context: context,
              title: 'Filter Requests',
              subtitle: 'Filter options dialog.',
            );
          },
          showSort: true,
          sortItems: _sortOptions,
          selectedSort: 'Recent',
          sortLabelBuilder: (String item) => item,
          onSortChanged: (String? sort) {},
          fillColor: AppColors.white,
        ),

        SizedBox(height: 14.sp),

        // ── 3. Secondary Toolbar (Export + Grid/Table Toggle) ─────────────────
        _buildViewToggleBar(),

        SizedBox(height: 16.sp),

        // ── 4. Main Content: Grid View or Table View ──────────────────────────
        if (displayList.isEmpty)
          Container(
            height: 200.sp,
            alignment: Alignment.center,
            child: Text(
              FormatHelper.localizedString(
                englishName: 'No requests found.',
                arabicName: 'لا توجد طلبات.',
              ),
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          )
        else if (_isGridView)
          _buildGridView(displayList)
        else
          CrmRequestsTableView(
            requests: displayList,
            onRequestTap: _navigateToDetails,
          ),
      ],
    );
  }

  Widget _buildViewToggleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Export',
            arabicName: 'تصدير',
          ),
          image: AppAssets.export,
          widthImage: 14.sp,
          heightImage: 14.sp,
          colorBorder: Colors.transparent,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
          function: () {
            CrmControlDialogs.showSuccessDialog(
              context: context,
              title: 'Export Requests',
              subtitle: 'Exporting requests to Excel sheet.',
            );
          },
        ),
        SizedBox(width: 12.sp),
        customGridButton(
          isSelected: _isGridView,
          color: AppColors.white,
          function: () => setState(() => _isGridView = true),
        ),
        SizedBox(width: 8.sp),
        customTableButton(
          isSelected: !_isGridView,
          color: AppColors.white,
          function: () => setState(() => _isGridView = false),
        ),
      ],
    );
  }

  Widget _buildGridView(List<CrmDealRequestModel> list) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 94.sp,
            crossAxisSpacing: 12.sp,
            mainAxisSpacing: 12.sp,
          ),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final CrmDealRequestModel item = list[index];
            return CrmRequestCard(
              request: item,
              onTap: () => _navigateToDetails(item),
            );
          },
        );
      },
    );
  }
}
