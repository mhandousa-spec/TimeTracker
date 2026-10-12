// ****************** FILE INFO ******************
// File Name: crm_category_and_tags_cubit.dart
// Purpose: Cubit for CRM Activity Categories & Tags Firebase integration and UI logic
// Author: Mohand Adel
// Created At: 17/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/domain/interfaces/crm_category_and_tags_base_repository.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'crm_category_and_tags_state.dart';

class CrmCategoryAndTagsCubit extends Cubit<CrmCategoryAndTagsState> {
  final CrmCategoryAndTagsBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmCategoryModel>>>?
      _categoriesSubscription;
  StreamSubscription<Either<Failure, List<CrmTagModel>>>? _tagsSubscription;

  CrmCategoryAndTagsCubit({
    CrmCategoryAndTagsBaseRepository? repository,
  })  : repository = repository ?? Get.find<CrmCategoryAndTagsBaseRepository>(),
        super(const CrmCategoryAndTagsState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await _categoriesSubscription?.cancel();
    await _tagsSubscription?.cancel();

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
              clearMessages: true,
            ),
          );
        },
      );
    });

    _tagsSubscription = repository.watchTags().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.errMessage,
          ),
        ),
        (tags) {
          emit(
            state.copyWith(
              tags: tags,
              filteredTags: _filterAndSortTags(
                tags: tags,
                query: state.searchQuery,
                selectedStatus: state.selectedStatus,
                selectedSort: state.selectedSort,
              ),
              isLoading: false,
              clearMessages: true,
            ),
          );
        },
      );
    });
  }

  void setTab(int index) {
    emit(
      state.copyWith(
        currentTab: index,
        clearMessages: true,
      ),
    );
  }

  void toggleTagEditMode() {
    emit(
      state.copyWith(
        isTagEditMode: !state.isTagEditMode,
        clearMessages: true,
      ),
    );
  }

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
        filteredTags: _filterAndSortTags(
          tags: state.tags,
          query: normalizedQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: state.selectedSort,
        ),
        clearMessages: true,
      ),
    );
  }

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
        filteredTags: _filterAndSortTags(
          tags: state.tags,
          query: state.searchQuery,
          selectedStatus: status,
          selectedSort: state.selectedSort,
        ),
        clearMessages: true,
      ),
    );
  }

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
        filteredTags: _filterAndSortTags(
          tags: state.tags,
          query: state.searchQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: sort,
        ),
        clearMessages: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Category CRUD
  // ---------------------------------------------------------------------------

  Future<bool> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required List<CrmCategoryTypeModel> types,
  }) async {
    final List<CrmCategoryTypeModel> normalizedTypes = _normalizeTypes(types);
    final String? validationError = _validateCategoryInputs(
      nameEn: nameEn,
      nameAr: nameAr,
      types: normalizedTypes,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmCategoryModel> result =
        await repository.createCategory(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      userEmail: _currentUserEmail,
      types: normalizedTypes,
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
            successMessage: 'created',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> updateCategory({
    required CrmCategoryModel currentCategory,
    required String nameEn,
    required String nameAr,
    required String status,
    required List<CrmCategoryTypeModel> types,
  }) async {
    final List<CrmCategoryTypeModel> normalizedTypes = _normalizeTypes(types);
    final String? validationError = _validateCategoryInputs(
      nameEn: nameEn,
      nameAr: nameAr,
      types: normalizedTypes,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final CrmCategoryModel updated = currentCategory.copyWith(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      isActive: status.trim().toLowerCase() == 'active',
      isDeleted: false,
      types: normalizedTypes,
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
            successMessage: 'updated',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> deleteCategory(CrmCategoryModel category) async {
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
            successMessage: 'deleted',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> toggleCategoryStatus(CrmCategoryModel category) async {
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
            successMessage: newActive ? 'activated' : 'deactivated',
          ),
        );
        return true;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tag CRUD
  // ---------------------------------------------------------------------------

  Future<bool> createTag({
    required String nameEn,
    required String nameAr,
    required String status,
  }) async {
    final String? validationError = _validateTagInputs(
      nameEn: nameEn,
      nameAr: nameAr,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmTagModel> result = await repository.createTag(
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
            successMessage: 'created',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> updateTag({
    required CrmTagModel currentTag,
    required String nameEn,
    required String nameAr,
    required String status,
  }) async {
    final String? validationError = _validateTagInputs(
      nameEn: nameEn,
      nameAr: nameAr,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final CrmTagModel updated = currentTag.copyWith(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      isActive: status.trim().toLowerCase() == 'active',
      isDeleted: false,
    );

    final Either<Failure, void> result = await repository.updateTag(
      tag: updated,
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
            successMessage: 'updated',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> deleteTag(CrmTagModel tag) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.removeTag(
      tag: tag,
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
            successMessage: 'deleted',
          ),
        );
        return true;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Filters & Sorting
  // ---------------------------------------------------------------------------

  List<CrmCategoryModel> _filterAndSortCategories({
    required List<CrmCategoryModel> categories,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) {
    List<CrmCategoryModel> result = List<CrmCategoryModel>.from(categories);

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      result = result.where((cat) {
        final bool nameEnMatch = cat.nameEn.toLowerCase().contains(q);
        final bool nameArMatch = cat.nameAr.toLowerCase().contains(q);
        final bool typesMatch = cat.types.any((t) =>
            t.nameEn.toLowerCase().contains(q) ||
            t.nameAr.toLowerCase().contains(q));
        return nameEnMatch || nameArMatch || typesMatch;
      }).toList();
    }

    final String status = selectedStatus.toLowerCase();
    if (status == 'active') {
      result = result.where((cat) => cat.isActive).toList();
    } else if (status == 'inactive') {
      result = result.where((cat) => !cat.isActive).toList();
    }

    if (selectedSort != null && selectedSort.isNotEmpty) {
      result.sort((a, b) {
        switch (selectedSort) {
          case 'name_asc':
            return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
          case 'name_desc':
            return b.nameEn.toLowerCase().compareTo(a.nameEn.toLowerCase());
          case 'date_asc':
            final DateTime aDate = a.audit?.updatedAt ?? DateTime(2000);
            final DateTime bDate = b.audit?.updatedAt ?? DateTime(2000);
            return aDate.compareTo(bDate);
          case 'date_desc':
            final DateTime aDate = a.audit?.updatedAt ?? DateTime(2000);
            final DateTime bDate = b.audit?.updatedAt ?? DateTime(2000);
            return bDate.compareTo(aDate);
          default:
            return a.order.compareTo(b.order);
        }
      });
    }

    return result;
  }

  List<CrmTagModel> _filterAndSortTags({
    required List<CrmTagModel> tags,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) {
    List<CrmTagModel> result = List<CrmTagModel>.from(tags);

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      result = result.where((tag) {
        final bool nameEnMatch = tag.nameEn.toLowerCase().contains(q);
        final bool nameArMatch = tag.nameAr.toLowerCase().contains(q);
        return nameEnMatch || nameArMatch;
      }).toList();
    }

    final String status = selectedStatus.toLowerCase();
    if (status == 'active') {
      result = result.where((tag) => tag.isActive).toList();
    } else if (status == 'inactive') {
      result = result.where((tag) => !tag.isActive).toList();
    }

    if (selectedSort != null && selectedSort.isNotEmpty) {
      result.sort((a, b) {
        switch (selectedSort) {
          case 'name_asc':
            return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
          case 'name_desc':
            return b.nameEn.toLowerCase().compareTo(a.nameEn.toLowerCase());
          case 'date_asc':
            final DateTime aDate = a.audit?.updatedAt ?? DateTime(2000);
            final DateTime bDate = b.audit?.updatedAt ?? DateTime(2000);
            return aDate.compareTo(bDate);
          case 'date_desc':
            final DateTime aDate = a.audit?.updatedAt ?? DateTime(2000);
            final DateTime bDate = b.audit?.updatedAt ?? DateTime(2000);
            return bDate.compareTo(aDate);
          default:
            return a.order.compareTo(b.order);
        }
      });
    }

    return result;
  }

  List<CrmCategoryTypeModel> _normalizeTypes(
      List<CrmCategoryTypeModel> rawTypes) {
    final List<CrmCategoryTypeModel> types = <CrmCategoryTypeModel>[];
    for (final t in rawTypes) {
      final String en = t.nameEn.trim();
      final String ar = t.nameAr.trim();
      if (en.isNotEmpty || ar.isNotEmpty) {
        types.add(
          CrmCategoryTypeModel(
            id: t.id.isNotEmpty
                ? t.id
                : DateTime.now().microsecondsSinceEpoch.toString(),
            nameEn: en.isNotEmpty ? en : ar,
            nameAr: ar.isNotEmpty ? ar : en,
          ),
        );
      }
    }
    return types;
  }

  String? _validateCategoryInputs({
    required String nameEn,
    required String nameAr,
    required List<CrmCategoryTypeModel> types,
  }) {
    if (nameEn.trim().isEmpty) {
      return S.current.crmPleaseEnterCategoryNameEn;
    }
    if (nameAr.trim().isEmpty) {
      return S.current.crmPleaseEnterCategoryNameAr;
    }
    if (types.isEmpty) {
      return S.current.crmPleaseAddAtLeastOneType;
    }
    return null;
  }

  String? _validateTagInputs({
    required String nameEn,
    required String nameAr,
  }) {
    if (nameEn.trim().isEmpty) {
      return S.current.crmPleaseEnterTagNameEn;
    }
    if (nameAr.trim().isEmpty) {
      return S.current.crmPleaseEnterTagNameAr;
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
    _tagsSubscription?.cancel();
    return super.close();
  }
}
