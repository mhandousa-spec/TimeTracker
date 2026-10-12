// ****************** FILE INFO ******************
// File Name: crm_blacklist_state.dart
// Purpose: State management for CRM Blacklisted clients and requests.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm10_blacklist/data/models/crm_blacklist_item_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';

class CrmBlacklistState {
  final bool isLoading;
  final int selectedMainTab; // 0: Blocked, 1: Requests
  final String requestStatusFilter; // 'all', 'pending', 'approved', 'rejected'
  final String selectedClientType; // 'All', 'Person', 'Government', 'Company'
  final bool isGridView;
  final String searchQuery;
  final String sortOption;
  final List<CrmBlacklistItemModel> items;
  final List<CrmClientTypeModel> clientTypes;
  final String? errorMessage;
  final String? successMessage;

  const CrmBlacklistState({
    this.isLoading = false,
    this.selectedMainTab = 0,
    this.requestStatusFilter = 'all',
    this.selectedClientType = 'All',
    this.isGridView = false,
    this.searchQuery = '',
    this.sortOption = 'newest',
    this.items = const [],
    this.clientTypes = const [],
    this.errorMessage,
    this.successMessage,
  });

  CrmBlacklistState copyWith({
    bool? isLoading,
    int? selectedMainTab,
    String? requestStatusFilter,
    String? selectedClientType,
    bool? isGridView,
    String? searchQuery,
    String? sortOption,
    List<CrmBlacklistItemModel>? items,
    List<CrmClientTypeModel>? clientTypes,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return CrmBlacklistState(
      isLoading: isLoading ?? this.isLoading,
      selectedMainTab: selectedMainTab ?? this.selectedMainTab,
      requestStatusFilter: requestStatusFilter ?? this.requestStatusFilter,
      selectedClientType: selectedClientType ?? this.selectedClientType,
      isGridView: isGridView ?? this.isGridView,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      items: items ?? this.items,
      clientTypes: clientTypes ?? this.clientTypes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
