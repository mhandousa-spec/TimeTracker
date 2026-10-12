// ****************** FILE INFO ******************
// File Name: crm_client_types_state.dart
// Purpose: State model for CRM client types controller
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';

class CrmClientTypesState {
  final List<CrmClientTypeModel> items;
  final List<CrmClientTypeModel> filteredItems;
  final CrmClientTypeModel? selectedType;
  final String searchQuery;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CrmClientTypesState({
    this.items = const [],
    this.filteredItems = const [],
    this.selectedType,
    this.searchQuery = '',
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  CrmClientTypesState copyWith({
    List<CrmClientTypeModel>? items,
    List<CrmClientTypeModel>? filteredItems,
    CrmClientTypeModel? selectedType,
    bool clearSelectedType = false,
    String? searchQuery,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmClientTypesState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedType:
          clearSelectedType ? null : selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}
