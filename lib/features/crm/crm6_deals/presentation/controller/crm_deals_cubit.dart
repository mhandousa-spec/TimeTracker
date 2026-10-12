// ****************** FILE INFO ******************
// File Name: crm_deals_cubit.dart
// Purpose: Cubit for CRM Deals (Categories & Stages) Firestore integration and UI state
// Author: Mohand Adel
// Created At: 22/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_stage_checklist_item_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_deals_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'crm_deals_filter_helper.dart';
import 'crm_deals_state.dart';

class CrmDealsCubit extends Cubit<CrmDealsState> {
  final CrmDealsBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmDealCategoryModel>>>?
      _categoriesSubscription;
  StreamSubscription<Either<Failure, List<CrmDealStageModel>>>?
      _stagesSubscription;

  CrmDealsCubit({
    CrmDealsBaseRepository? repository,
  })  : repository = repository ?? Get.find<CrmDealsBaseRepository>(),
        super(const CrmDealsState());

  /// Function Name: init
  ///
  /// Purpose: Initializes real-time Firestore listeners for categories & stages.
  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await _categoriesSubscription?.cancel();
    await _stagesSubscription?.cancel();

    _categoriesSubscription = repository.watchCategories().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.errMessage,
          ),
        ),
        (categories) {
          emit(
            state.copyWith(
              categories: categories,
              filteredCategories: _filterAndSortCategories(
                categories: categories,
                query: state.searchQuery,
                selectedStatus: state.selectedStatus,
                selectedSort: state.selectedSort,
              ),
              isLoading: false,
            ),
          );
        },
      );
    });

    _stagesSubscription = repository.watchStages().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.errMessage,
          ),
        ),
        (stages) {
          emit(
            state.copyWith(
              stages: stages,
              filteredStages: _filterAndSortStages(
                stages: stages,
                query: state.searchQuery,
                selectedStatus: state.selectedStatus,
                selectedSort: state.selectedSort,
              ),
              isLoading: false,
            ),
          );
        },
      );
    });
  }

  /// Function Name: setTab
  ///
  /// Purpose: Switches between Categories tab (0) and Stages tab (1).
  void setTab(int index) {
    emit(
      state.copyWith(
        currentTab: index,
        clearMessages: true,
      ),
    );
  }

  /// Function Name: toggleEditMode
  ///
  /// Purpose: Toggles the card deletion mode.
  void toggleEditMode() {
    emit(
      state.copyWith(
        isEditMode: !state.isEditMode,
        clearMessages: true,
      ),
    );
  }

  void setFormOpen(bool isOpen) {
    emit(state.copyWith(isFormOpen: isOpen));
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  /// Function Name: search
  ///
  /// Purpose: Filters categories and stages by name query.
  void search(String query) {
    final String normalizedQuery = query.trim();
    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        filteredCategories: _filterAndSortCategories(
          categories: state.categories,
          query: normalizedQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: state.selectedSort,
        ),
        filteredStages: _filterAndSortStages(
          stages: state.stages,
          query: normalizedQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: state.selectedSort,
        ),
        clearMessages: true,
      ),
    );
  }

  /// Function Name: setStatusFilter
  ///
  /// Purpose: Sets the KPI status filter ('All', 'Active', 'Inactive').
  void setStatusFilter(String status) {
    emit(
      state.copyWith(
        selectedStatus: status,
        filteredCategories: _filterAndSortCategories(
          categories: state.categories,
          query: state.searchQuery,
          selectedStatus: status,
          selectedSort: state.selectedSort,
        ),
        filteredStages: _filterAndSortStages(
          stages: state.stages,
          query: state.searchQuery,
          selectedStatus: status,
          selectedSort: state.selectedSort,
        ),
        clearMessages: true,
      ),
    );
  }

  /// Function Name: setSort
  ///
  /// Purpose: Sets the current sort option (name asc/desc, date asc/desc).
  void setSort(String? sort) {
    emit(
      state.copyWith(
        selectedSort: sort,
        filteredCategories: _filterAndSortCategories(
          categories: state.categories,
          query: state.searchQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: sort,
        ),
        filteredStages: _filterAndSortStages(
          stages: state.stages,
          query: state.searchQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: sort,
        ),
        clearMessages: true,
      ),
    );
  }

  /// Function Name: createCategory
  ///
  /// Purpose: Creates a new Deal Category document.
  Future<bool> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
  }) async {
    final String? validationError = _validateCategoryInputs(
      nameEn: nameEn,
      nameAr: nameAr,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmDealCategoryModel> result =
        await repository.createCategory(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      userEmail: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: S.current.crmCategorySavedSuccess,
          ),
        );
        return true;
      },
    );
  }

  /// Function Name: updateCategory
  ///
  /// Purpose: Updates an existing Deal Category document.
  Future<bool> updateCategory({
    required CrmDealCategoryModel currentCategory,
    required String nameEn,
    required String nameAr,
    required String status,
  }) async {
    final String? validationError = _validateCategoryInputs(
      nameEn: nameEn,
      nameAr: nameAr,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final CrmDealCategoryModel updated = currentCategory.copyWith(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
    );

    final Either<Failure, void> result = await repository.updateCategory(
      category: updated,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: S.current.crmCategorySavedSuccess,
          ),
        );
        return true;
      },
    );
  }

  /// Function Name: deleteCategory
  ///
  /// Purpose: Soft-deletes a Deal Category document.
  Future<bool> deleteCategory(CrmDealCategoryModel category) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.removeCategory(
      category: category,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: S.current.crmCategoryDeletedSuccess,
          ),
        );
        return true;
      },
    );
  }

  /// Function Name: toggleCategoryStatus
  ///
  /// Purpose: Toggles Deal Category active/inactive status.
  Future<bool> toggleCategoryStatus(CrmDealCategoryModel category) async {
    final bool newActive = !category.isActive;
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.toggleCategoryStatus(
      categoryId: category.id,
      isActive: newActive,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: S.current.crmCategorySavedSuccess,
          ),
        );
        return true;
      },
    );
  }

  void setCategoryStatus(CrmDealCategoryModel category, String status) {
    final bool requestedActive = status.trim().toLowerCase() == 'active';
    if (requestedActive != category.isActive) {
      toggleCategoryStatus(category);
    }
  }

  /// Function Name: createStage
  ///
  /// Purpose: Creates a new Deal Stage document.
  Future<bool> createStage({
    required String nameEn,
    required String nameAr,
    required String status,
    int probability = 0,
    String color = '',
    int? order,
    List<CrmStageChecklistItemModel> checklistItems =
        const <CrmStageChecklistItemModel>[],
  }) async {
    final String? validationError = _validateStageInputs(
      nameEn: nameEn,
      nameAr: nameAr,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmDealStageModel> result =
        await repository.createStage(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      userEmail: _currentUserEmail,
      probability: probability,
      color: color,
      order: order,
      checklistItems: checklistItems,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: S.current.crmStageSavedSuccess,
          ),
        );
        return true;
      },
    );
  }

  /// Function Name: updateStage
  ///
  /// Purpose: Updates an existing Deal Stage document.
  Future<bool> updateStage({
    required CrmDealStageModel currentStage,
    required String nameEn,
    required String nameAr,
    required String status,
    int probability = 0,
    String color = '',
    int? order,
    List<CrmStageChecklistItemModel>? checklistItems,
  }) async {
    final String? validationError = _validateStageInputs(
      nameEn: nameEn,
      nameAr: nameAr,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final CrmDealStageModel updated = currentStage.copyWith(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      probability: probability,
      color: color,
      order: order ?? currentStage.order,
      checklistItems: checklistItems ?? currentStage.checklistItems,
    );

    final Either<Failure, void> result = await repository.updateStage(
      stage: updated,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: S.current.crmStageUpdatedSuccess,
          ),
        );
        return true;
      },
    );
  }

  /// Function Name: deleteStage
  ///
  /// Purpose: Soft-deletes a Deal Stage document.
  Future<bool> deleteStage(CrmDealStageModel stage) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.removeStage(
      stage: stage,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: S.current.crmStageDeletedSuccess,
          ),
        );
        return true;
      },
    );
  }

  /// Function Name: toggleStageStatus
  ///
  /// Purpose: Toggles Deal Stage active/inactive status.
  Future<bool> toggleStageStatus(CrmDealStageModel stage) async {
    final bool newActive = !stage.isActive;
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.toggleStageStatus(
      stageId: stage.id,
      isActive: newActive,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSaving: false,
            successMessage: S.current.crmStageUpdatedSuccess,
          ),
        );
        return true;
      },
    );
  }

  void setStageStatus(CrmDealStageModel stage, String status) {
    final bool requestedActive = status.trim().toLowerCase() == 'active';
    if (requestedActive != stage.isActive) {
      toggleStageStatus(stage);
    }
  }

  List<CrmDealCategoryModel> _filterAndSortCategories({
    required List<CrmDealCategoryModel> categories,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) =>
      CrmDealsFilterHelper.filterAndSortCategories(
        categories: categories,
        query: query,
        selectedStatus: selectedStatus,
        selectedSort: selectedSort,
      );

  List<CrmDealStageModel> _filterAndSortStages({
    required List<CrmDealStageModel> stages,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) =>
      CrmDealsFilterHelper.filterAndSortStages(
        stages: stages,
        query: query,
        selectedStatus: selectedStatus,
        selectedSort: selectedSort,
      );

  String? _validateCategoryInputs({
    required String nameEn,
    required String nameAr,
  }) {
    if (nameEn.trim().isEmpty) {
      return S.current.crmPleaseEnterCategoryNameEn;
    }
    if (nameAr.trim().isEmpty) {
      return S.current.crmPleaseEnterCategoryNameAr;
    }
    return null;
  }

  String? _validateStageInputs({
    required String nameEn,
    required String nameAr,
  }) {
    if (nameEn.trim().isEmpty) {
      return S.current.crmPleaseEnterStageNameEn;
    }
    if (nameAr.trim().isEmpty) {
      return S.current.crmPleaseEnterStageNameAr;
    }
    return null;
  }

  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    return 'system';
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    _stagesSubscription?.cancel();
    return super.close();
  }
}
