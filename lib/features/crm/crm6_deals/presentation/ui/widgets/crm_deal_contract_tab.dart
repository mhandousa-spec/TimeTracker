// ****************** FILE INFO ******************
// File Name: crm_deal_contract_tab.dart
// Purpose: Contract tab view in Deal Details with Search, Filter dialog, Sort menu, and 3-column contract cards grid matching Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_contract_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_create_contract_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_contract_filter_dialog.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_contract_card.dart';

class CrmDealContractTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealContractTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealContractTab> createState() => _CrmDealContractTabState();
}

class _CrmDealContractTabState extends State<CrmDealContractTab> {
  final TextEditingController _searchController = TextEditingController();
  CrmContractFilterState _filterState = const CrmContractFilterState();
  String _selectedSort = 'Newest'; // 'Newest' or 'Oldest'

  final List<CrmDealContractModel> _contracts = <CrmDealContractModel>[
    CrmDealContractModel(
      id: '1',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract1.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 1.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark1.pdf',
    ),
    CrmDealContractModel(
      id: '2',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract2.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 1.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark2.pdf',
    ),
    CrmDealContractModel(
      id: '3',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract3.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 1.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark3.pdf',
    ),
    CrmDealContractModel(
      id: '4',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract4.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 2.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark4.pdf',
    ),
    CrmDealContractModel(
      id: '5',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract5.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 2.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark5.pdf',
    ),
    CrmDealContractModel(
      id: '6',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract6.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 2.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark6.pdf',
    ),
    CrmDealContractModel(
      id: '7',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract7.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 3.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark7.pdf',
    ),
    CrmDealContractModel(
      id: '8',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract8.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 3.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark8.pdf',
    ),
    CrmDealContractModel(
      id: '9',
      dealId: 'deal_1',
      title: 'Watermark.png',
      fileName: 'Watermark.png',
      fileUrl: 'https://example.com/contract9.pdf',
      sizeBytes: 62 * 1024,
      extension: 'pdf',
      version: 'Version 3.0',
      uploadedByEmployee: 'Aya Ahmed',
      uploadedAt: DateTime(2024, 12, 28),
      storagePath: 'contracts/deal_1/watermark9.pdf',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CrmDealContractModel> get _visibleContracts {
    final List<CrmDealContractModel> filtered =
        _contracts.where((CrmDealContractModel c) {
      if (c.isDeleted) return false;

      // Version filter
      if (_filterState.version != null && _filterState.version != 'Versions') {
        if (c.version != _filterState.version) return false;
      }

      // Employee filter
      if (_filterState.employee != null &&
          _filterState.employee != 'By Employee') {
        if (c.uploadedByEmployee != _filterState.employee) return false;
      }

      // Date from filter
      if (_filterState.dateFrom != null) {
        if (c.uploadedAt.isBefore(_filterState.dateFrom!)) return false;
      }

      // Date to filter
      if (_filterState.dateTo != null) {
        if (c.uploadedAt.isAfter(_filterState.dateTo!)) return false;
      }

      // Search Query
      if (_searchController.text.trim().isNotEmpty) {
        final String query = _searchController.text.trim().toLowerCase();
        final bool matchesTitle = c.title.toLowerCase().contains(query);
        final bool matchesFileName = c.fileName.toLowerCase().contains(query);
        final bool matchesEmployee =
            c.uploadedByEmployee.toLowerCase().contains(query);
        if (!matchesTitle && !matchesFileName && !matchesEmployee) return false;
      }

      return true;
    }).toList();

    if (_selectedSort == 'Oldest') {
      filtered.sort((a, b) => a.uploadedAt.compareTo(b.uploadedAt));
    } else {
      filtered.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    }

    return filtered;
  }

  Future<void> _openFilterDialog() async {
    final CrmContractFilterState? result = await CrmContractFilterDialog.show(
      context: context,
      initialState: _filterState,
    );
    if (result != null) {
      setState(() => _filterState = result);
    }
  }

  void _onContractTap(CrmDealContractModel contract) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CrmCreateContractPage(
          deal: widget.deal,
          quote: CrmQuoteModel.getEmptyModel(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CrmDealContractModel> visibleContracts = _visibleContracts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Top Search, Filter, and Sort Bar ──────────────────────────────
        _buildToolbar(),

        SizedBox(height: 16.sp),

        // ── 2. 3-Column Contracts Grid or Empty State ────────────────────────
        if (visibleContracts.isEmpty)
          _buildEmptyState()
        else
          _buildContractsGrid(visibleContracts),
      ],
    );
  }

  Widget _buildToolbar() {
    return CustomSearchFilterSortBar<String, String>(
      searchController: _searchController,
      onSearchChanged: (String val) => setState(() {}),
      searchHint: FormatHelper.localizedString(
        englishName: 'Search',
        arabicName: 'بحث',
      ),
      showFilter: true,
      onFilterTap: _openFilterDialog,
      isFilterActive: _filterState.isActive,
      filterTitle: FormatHelper.localizedString(
        englishName: 'Filter',
        arabicName: 'تصفية',
      ),
      showSort: true,
      sortItems: const <String>['Newest', 'Oldest'],
      selectedSort: _selectedSort,
      sortTitle: FormatHelper.localizedString(
        englishName: 'Sort',
        arabicName: 'ترتيب',
      ),
      sortLabelBuilder: (String s) => s,
      onSortChanged: (String? val) {
        if (val != null) setState(() => _selectedSort = val);
      },
    );
  }

  Widget _buildContractsGrid(List<CrmDealContractModel> contracts) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount =
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount >= 3 ? crossAxisCount : 3,
            mainAxisExtent: 76.sp,
            crossAxisSpacing: 10.sp,
            mainAxisSpacing: 10.sp,
          ),
          itemCount: contracts.length,
          itemBuilder: (BuildContext context, int index) {
            final CrmDealContractModel contract = contracts[index];
            return CrmDealContractCard(
              contract: contract,
              onTap: () => _onContractTap(contract),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.sp, horizontal: 16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomSvgImage(
            assetPath: AppAssets.crmTemplateEmpty,
            width: 100.sp,
            height: 100.sp,
          ),
          SizedBox(height: 16.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'No contracts found for this filter',
              arabicName: 'لا توجد عقود مطابقة لهذا الفلتر',
            ),
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
