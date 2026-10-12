// ****************** FILE INFO ******************
// File Name: crm_category_and_tags_state.dart
// Purpose: State model for CRM Activity Categories & Tags flow
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';

class CrmCategoryAndTagsState {
  final int currentTab; // 0: Categories, 1: Tags
  final List<CrmCategoryModel> categories;
  final List<CrmCategoryModel> filteredCategories;
  final List<CrmTagModel> tags;
  final List<CrmTagModel> filteredTags;
  final String searchQuery;
  final String selectedStatus;
  final String? selectedSort;
  final bool isTagEditMode;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CrmCategoryAndTagsState({
    this.currentTab = 0,
    this.categories = const <CrmCategoryModel>[],
    this.filteredCategories = const <CrmCategoryModel>[],
    this.tags = const <CrmTagModel>[],
    this.filteredTags = const <CrmTagModel>[],
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedSort,
    this.isTagEditMode = false,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  CrmCategoryAndTagsState copyWith({
    int? currentTab,
    List<CrmCategoryModel>? categories,
    List<CrmCategoryModel>? filteredCategories,
    List<CrmTagModel>? tags,
    List<CrmTagModel>? filteredTags,
    String? searchQuery,
    String? selectedStatus,
    String? selectedSort,
    bool clearSelectedSort = false,
    bool? isTagEditMode,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmCategoryAndTagsState(
      currentTab: currentTab ?? this.currentTab,
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      tags: tags ?? this.tags,
      filteredTags: filteredTags ?? this.filteredTags,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSort:
          clearSelectedSort ? null : selectedSort ?? this.selectedSort,
      isTagEditMode: isTagEditMode ?? this.isTagEditMode,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}
