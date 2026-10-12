// ****************** FILE INFO ******************
// File Name: crm_client_deals_cubit.dart
// Purpose: Cubit managing CRM Client Deals UI state, searching, sorting, filtering, and view toggles
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/data_source/crm_client_deals_mock_data.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'crm_client_deals_state.dart';

class CrmClientDealsCubit extends Cubit<CrmClientDealsState> {
  final String? clientId;

  CrmClientDealsCubit({this.clientId}) : super(const CrmClientDealsState());

  /// Function Name: init
  ///
  /// Purpose: Initializes the mock deals data and calculates summary stats.
  void init() {
    emit(state.copyWith(isLoading: true));
    final List<CrmClientDealModel> rawDeals =
        CrmClientDealsMockData.generateMockDeals();
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: rawDeals,
      query: state.searchQuery,
      sort: state.sortOption,
      stage: state.selectedStage,
      category: state.selectedCategory,
      valFrom: state.expectedValueFrom,
      valTo: state.expectedValueTo,
      start: state.startDate,
      close: state.closeDate,
      employee: state.assignedEmployee,
    );

    emit(
      state.copyWith(
        isLoading: false,
        deals: rawDeals,
        filteredDeals: filtered,
        totalDeals: 50,
        wonDeals: 50,
        lostDeals: 50,
        totalValue: '\$50k',
        revenue: '\$50k',
      ),
    );
  }

  /// Function Name: setSearchQuery
  ///
  /// Purpose: Filters deals by text search query.
  void setSearchQuery(String query) {
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: state.deals,
      query: query,
      sort: state.sortOption,
      stage: state.selectedStage,
      category: state.selectedCategory,
      valFrom: state.expectedValueFrom,
      valTo: state.expectedValueTo,
      start: state.startDate,
      close: state.closeDate,
      employee: state.assignedEmployee,
    );

    emit(state.copyWith(searchQuery: query, filteredDeals: filtered));
  }

  /// Function Name: setSortOption
  ///
  /// Purpose: Sorts deals by 'newest' or 'oldest'.
  void setSortOption(String sort) {
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: state.deals,
      query: state.searchQuery,
      sort: sort,
      stage: state.selectedStage,
      category: state.selectedCategory,
      valFrom: state.expectedValueFrom,
      valTo: state.expectedValueTo,
      start: state.startDate,
      close: state.closeDate,
      employee: state.assignedEmployee,
    );

    emit(state.copyWith(sortOption: sort, filteredDeals: filtered));
  }

  /// Function Name: setViewMode
  ///
  /// Purpose: Toggles between Grid (Kanban Board) and Table view.
  void setViewMode({required bool isGridView}) {
    emit(state.copyWith(isGridView: isGridView));
  }

  /// Function Name: applyFilter
  ///
  /// Purpose: Applies dialog filter parameters to deals list.
  void applyFilter({
    String? stage,
    String? category,
    double? expectedValueFrom,
    double? expectedValueTo,
    DateTime? startDate,
    DateTime? closeDate,
    String? assignedEmployee,
  }) {
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: state.deals,
      query: state.searchQuery,
      sort: state.sortOption,
      stage: stage,
      category: category,
      valFrom: expectedValueFrom,
      valTo: expectedValueTo,
      start: startDate,
      close: closeDate,
      employee: assignedEmployee,
    );

    emit(
      state.copyWith(
        selectedStage: stage,
        selectedCategory: category,
        expectedValueFrom: expectedValueFrom,
        expectedValueTo: expectedValueTo,
        startDate: startDate,
        closeDate: closeDate,
        assignedEmployee: assignedEmployee,
        filteredDeals: filtered,
      ),
    );
  }

  /// Function Name: resetFilter
  ///
  /// Purpose: Resets all active filters.
  void resetFilter() {
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: state.deals,
      query: state.searchQuery,
      sort: state.sortOption,
    );

    emit(state.copyWith(clearFilters: true, filteredDeals: filtered));
  }

  List<CrmClientDealModel> _filterAndSort({
    required List<CrmClientDealModel> deals,
    required String query,
    required String sort,
    String? stage,
    String? category,
    double? valFrom,
    double? valTo,
    DateTime? start,
    DateTime? close,
    String? employee,
  }) {
    List<CrmClientDealModel> list = List<CrmClientDealModel>.from(deals);

    // 1. Search Query
    if (query.trim().isNotEmpty) {
      final String q = query.trim().toLowerCase();
      list = list.where((d) {
        return d.dealNameEn.toLowerCase().contains(q) ||
            d.dealNameAr.toLowerCase().contains(q) ||
            d.category.toLowerCase().contains(q) ||
            d.assignedEmployee.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Stage Filter
    if (stage != null && stage.isNotEmpty && stage.toLowerCase() != 'all') {
      list = list
          .where((d) => d.stage.toLowerCase() == stage.toLowerCase())
          .toList();
    }

    // 3. Category Filter
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      list = list
          .where((d) => d.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    // 4. Value From
    if (valFrom != null) {
      list = list.where((d) => d.expectedValue >= valFrom).toList();
    }

    // 5. Value To
    if (valTo != null) {
      list = list.where((d) => d.expectedValue <= valTo).toList();
    }

    // 6. Assigned Employee
    if (employee != null &&
        employee.isNotEmpty &&
        employee.toLowerCase() != 'all') {
      list = list
          .where(
              (d) => d.assignedEmployee.toLowerCase() == employee.toLowerCase())
          .toList();
    }

    // 7. Sort
    if (sort == 'oldest') {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }
}
