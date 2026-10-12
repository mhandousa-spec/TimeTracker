// ****************** FILE INFO ******************
// File Name: crm_client_deals_state.dart
// Purpose: State definition for CRM Client Deals feature (table, kanban, filter, sort)
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';

class CrmClientDealsState {
  final bool isLoading;
  final List<CrmClientDealModel> deals;
  final List<CrmClientDealModel> filteredDeals;
  final String searchQuery;
  final String sortOption; // 'newest' | 'oldest'
  final bool isGridView; // false = Table View, true = Kanban Board View

  // Filter Criteria
  final String? selectedStage;
  final String? selectedCategory;
  final double? expectedValueFrom;
  final double? expectedValueTo;
  final DateTime? startDate;
  final DateTime? closeDate;
  final String? assignedEmployee;

  // KPI summary stats
  final int totalDeals;
  final int wonDeals;
  final int lostDeals;
  final String totalValue;
  final String revenue;

  const CrmClientDealsState({
    this.isLoading = false,
    this.deals = const <CrmClientDealModel>[],
    this.filteredDeals = const <CrmClientDealModel>[],
    this.searchQuery = '',
    this.sortOption = 'newest',
    this.isGridView = false,
    this.selectedStage,
    this.selectedCategory,
    this.expectedValueFrom,
    this.expectedValueTo,
    this.startDate,
    this.closeDate,
    this.assignedEmployee,
    this.totalDeals = 50,
    this.wonDeals = 50,
    this.lostDeals = 50,
    this.totalValue = '\$50k',
    this.revenue = '\$50k',
  });

  CrmClientDealsState copyWith({
    bool? isLoading,
    List<CrmClientDealModel>? deals,
    List<CrmClientDealModel>? filteredDeals,
    String? searchQuery,
    String? sortOption,
    bool? isGridView,
    String? selectedStage,
    String? selectedCategory,
    double? expectedValueFrom,
    double? expectedValueTo,
    DateTime? startDate,
    DateTime? closeDate,
    String? assignedEmployee,
    int? totalDeals,
    int? wonDeals,
    int? lostDeals,
    String? totalValue,
    String? revenue,
    bool clearFilters = false,
  }) {
    return CrmClientDealsState(
      isLoading: isLoading ?? this.isLoading,
      deals: deals ?? this.deals,
      filteredDeals: filteredDeals ?? this.filteredDeals,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      isGridView: isGridView ?? this.isGridView,
      selectedStage:
          clearFilters ? null : (selectedStage ?? this.selectedStage),
      selectedCategory:
          clearFilters ? null : (selectedCategory ?? this.selectedCategory),
      expectedValueFrom:
          clearFilters ? null : (expectedValueFrom ?? this.expectedValueFrom),
      expectedValueTo:
          clearFilters ? null : (expectedValueTo ?? this.expectedValueTo),
      startDate: clearFilters ? null : (startDate ?? this.startDate),
      closeDate: clearFilters ? null : (closeDate ?? this.closeDate),
      assignedEmployee:
          clearFilters ? null : (assignedEmployee ?? this.assignedEmployee),
      totalDeals: totalDeals ?? this.totalDeals,
      wonDeals: wonDeals ?? this.wonDeals,
      lostDeals: lostDeals ?? this.lostDeals,
      totalValue: totalValue ?? this.totalValue,
      revenue: revenue ?? this.revenue,
    );
  }
}
