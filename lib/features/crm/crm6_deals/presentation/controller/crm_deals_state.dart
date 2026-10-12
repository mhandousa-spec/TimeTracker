// ****************** FILE INFO ******************
// File Name: crm_deals_state.dart
// Purpose: State model for CRM Deals Controls flow (Categories & Stages)
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';

class CrmDealsState {
  final int currentTab; // 0: Categories, 1: Stages
  final List<CrmDealCategoryModel> categories;
  final List<CrmDealCategoryModel> filteredCategories;
  final List<CrmDealStageModel> stages;
  final List<CrmDealStageModel> filteredStages;
  final String searchQuery;
  final String selectedStatus; // 'All', 'Active', 'Inactive'
  final String? selectedSort;
  final bool isEditMode;
  final bool isLoading;
  final bool isSaving;
  final bool isFormOpen;
  final String? errorMessage;
  final String? successMessage;

  const CrmDealsState({
    this.currentTab = 0,
    this.categories = const <CrmDealCategoryModel>[],
    this.filteredCategories = const <CrmDealCategoryModel>[],
    this.stages = const <CrmDealStageModel>[],
    this.filteredStages = const <CrmDealStageModel>[],
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedSort,
    this.isEditMode = false,
    this.isLoading = false,
    this.isSaving = false,
    this.isFormOpen = false,
    this.errorMessage,
    this.successMessage,
  });

  int get totalCategoriesCount => categories.length;
  int get activeCategoriesCount => categories.where((c) => c.isActive).length;
  int get inactiveCategoriesCount =>
      categories.where((c) => c.isInactive).length;

  int get totalStagesCount => stages.length;
  int get activeStagesCount => stages.where((s) => s.isActive).length;
  int get inactiveStagesCount => stages.where((s) => s.isInactive).length;

  int get currentTotalCount =>
      currentTab == 0 ? totalCategoriesCount : totalStagesCount;
  int get currentActiveCount =>
      currentTab == 0 ? activeCategoriesCount : activeStagesCount;
  int get currentInactiveCount =>
      currentTab == 0 ? inactiveCategoriesCount : inactiveStagesCount;

  String? get selectedStatusFilterValue =>
      selectedStatus.toLowerCase() == 'all' ? null : selectedStatus;

  CrmDealsState copyWith({
    int? currentTab,
    List<CrmDealCategoryModel>? categories,
    List<CrmDealCategoryModel>? filteredCategories,
    List<CrmDealStageModel>? stages,
    List<CrmDealStageModel>? filteredStages,
    String? searchQuery,
    String? selectedStatus,
    String? selectedSort,
    bool clearSelectedSort = false,
    bool? isEditMode,
    bool? isLoading,
    bool? isSaving,
    bool? isFormOpen,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmDealsState(
      currentTab: currentTab ?? this.currentTab,
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      stages: stages ?? this.stages,
      filteredStages: filteredStages ?? this.filteredStages,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSort:
          clearSelectedSort ? null : selectedSort ?? this.selectedSort,
      isEditMode: isEditMode ?? this.isEditMode,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isFormOpen: isFormOpen ?? this.isFormOpen,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
    );
  }
}
