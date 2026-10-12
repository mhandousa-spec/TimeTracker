// ****************** FILE INFO ******************
// File Name: crm_relationship_state.dart
// Purpose: State model for CRM relationship categories UI and Firebase flow
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';

class CrmRelationshipState {
  final List<CrmRelationshipCategoryModel> items;
  final List<CrmRelationshipCategoryModel> filteredItems;
  final String searchQuery;
  final String selectedStatus;
  final String? selectedSort;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CrmRelationshipState({
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

  CrmRelationshipState copyWith({
    List<CrmRelationshipCategoryModel>? items,
    List<CrmRelationshipCategoryModel>? filteredItems,
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
    return CrmRelationshipState(
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
