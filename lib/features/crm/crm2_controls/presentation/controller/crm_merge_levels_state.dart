// ****************** FILE INFO ******************
// File Name: crm_merge_levels_state.dart
// Purpose: State model for CRM merge levels controller
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';

class CrmMergeLevelsState {
  final List<CrmMergeLevelModel> items;
  final List<CrmMergeLevelModel> filteredItems;
  final CrmMergeLevelModel? selectedLevel;
  final CrmMergeSettingsModel settings;
  final String searchQuery;
  final String selectedStatus;
  final String? selectedSort;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CrmMergeLevelsState({
    this.items = const <CrmMergeLevelModel>[],
    this.filteredItems = const <CrmMergeLevelModel>[],
    this.selectedLevel,
    this.settings = const CrmMergeSettingsModel(),
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedSort,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  CrmMergeLevelsState copyWith({
    List<CrmMergeLevelModel>? items,
    List<CrmMergeLevelModel>? filteredItems,
    CrmMergeLevelModel? selectedLevel,
    CrmMergeSettingsModel? settings,
    bool clearSelectedLevel = false,
    String? searchQuery,
    String? selectedStatus,
    String? selectedSort,
    bool clearSort = false,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmMergeLevelsState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedLevel:
          clearSelectedLevel ? null : selectedLevel ?? this.selectedLevel,
      settings: settings ?? this.settings,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSort: clearSort ? null : selectedSort ?? this.selectedSort,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}
