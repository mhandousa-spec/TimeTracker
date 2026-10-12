// ****************** FILE INFO ******************
// File Name: crm_terms_state.dart
// Purpose: State model for CRM Terms UI and Firebase flow
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';

class CrmTermsState {
  final List<CrmTermModel> items;
  final List<CrmTermModel> filteredItems;
  final String searchQuery;
  final String selectedStatus;
  final String? selectedSort;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CrmTermsState({
    this.items = const [],
    this.filteredItems = const [],
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedSort,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  CrmTermsState copyWith({
    List<CrmTermModel>? items,
    List<CrmTermModel>? filteredItems,
    String? searchQuery,
    String? selectedStatus,
    String? selectedSort,
    bool clearSelectedSort = false,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmTermsState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSort:
          clearSelectedSort ? null : selectedSort ?? this.selectedSort,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}
