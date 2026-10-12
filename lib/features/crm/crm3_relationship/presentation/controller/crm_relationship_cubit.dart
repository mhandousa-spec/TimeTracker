// ****************** FILE INFO ******************
// File Name: crm_relationship_cubit.dart
// Purpose: Cubit for CRM relationship Firebase integration and UI logic
// Author: Mohand Adel
// Created At: 12/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_type_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/domain/interfaces/crm_relationship_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'crm_relationship_state.dart';

class CrmRelationshipCubit extends Cubit<CrmRelationshipState> {
  final CrmRelationshipBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmRelationshipCategoryModel>>>?
      _subscription;

  CrmRelationshipCubit({
    CrmRelationshipBaseRepository? repository,
  })  : repository = repository ?? Get.find<CrmRelationshipBaseRepository>(),
        super(const CrmRelationshipState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await _subscription?.cancel();
    _subscription = repository.watchRelationshipCategories().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.errMessage,
          ),
        ),
        (items) => emit(
          state.copyWith(
            items: items,
            filteredItems: _filterAndSort(
              items: items,
              query: state.searchQuery,
              selectedStatus: state.selectedStatus,
              selectedSort: state.selectedSort,
            ),
            isLoading: false,
            clearMessages: true,
          ),
        ),
      );
    });
  }

  void search(String query) {
    final String normalizedQuery = query.trim();
    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        filteredItems: _filterAndSort(
          items: state.items,
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
        filteredItems: _filterAndSort(
          items: state.items,
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
        filteredItems: _filterAndSort(
          items: state.items,
          query: state.searchQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: sort,
        ),
        clearMessages: true,
      ),
    );
  }

  Future<bool> createCategory({
    required String nameEn,
    required String nameAr,
    required String status,
    required List<Map<String, String>> types,
  }) async {
    final List<Map<String, String>> normalizedTypes = _normalizeTypes(types);
    final String? validationError = _validateInputs(
      nameEn: nameEn,
      nameAr: nameAr,
      types: normalizedTypes,
    );
    if (validationError != null) {
      emit(
        state.copyWith(
          errorMessage: validationError,
          isSaving: false,
        ),
      );
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmRelationshipCategoryModel> result =
        await repository.createRelationshipCategory(
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
    required CrmRelationshipCategoryModel currentCategory,
    required String nameEn,
    required String nameAr,
    required String status,
    required List<Map<String, String>> types,
  }) async {
    final List<Map<String, String>> normalizedTypes = _normalizeTypes(types);
    final String? validationError = _validateInputs(
      nameEn: nameEn,
      nameAr: nameAr,
      types: normalizedTypes,
    );
    if (validationError != null) {
      emit(
        state.copyWith(
          errorMessage: validationError,
          isSaving: false,
        ),
      );
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final CrmRelationshipCategoryModel updatedCategory =
        currentCategory.copyWith(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      isActive: status.trim().toLowerCase() == 'active',
      isDeleted: false,
      types: normalizedTypes
          .map(
            (type) => CrmRelationshipTypeModel(
              id: (type[CrmFirestoreKeys.ID_KEY] ?? '').trim(),
              nameEn: (type[CrmFirestoreKeys.NAME_EN_KEY] ?? '').trim(),
              nameAr: (type[CrmFirestoreKeys.NAME_AR_KEY] ?? '').trim(),
            ),
          )
          .toList(),
    );

    final Either<Failure, void> result =
        await repository.updateRelationshipCategory(
      category: updatedCategory,
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

  Future<bool> removeCategory({
    required CrmRelationshipCategoryModel category,
  }) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result =
        await repository.removeRelationshipCategory(
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
            successMessage: 'removed',
          ),
        );
        return true;
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  List<CrmRelationshipCategoryModel> _filterAndSort({
    required List<CrmRelationshipCategoryModel> items,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) {
    final String normalizedQuery = query.toLowerCase().trim();
    final List<CrmRelationshipCategoryModel> filtered = items.where((item) {
      final String status = item.status.toLowerCase();
      if (selectedStatus == 'Active' && status != 'active') return false;
      if (selectedStatus == 'Inactive' && status != 'inactive') return false;
      if (normalizedQuery.isEmpty) return true;
      return item.nameEn.toLowerCase().contains(normalizedQuery) ||
          item.nameAr.toLowerCase().contains(normalizedQuery);
    }).toList();

    if (selectedSort == 'Name') {
      filtered.sort(
        (a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()),
      );
    } else if (selectedSort == 'Newest') {
      filtered.sort(
        (a, b) => (b.audit?.updatedAt ?? DateTime(1970))
            .compareTo(a.audit?.updatedAt ?? DateTime(1970)),
      );
    } else if (selectedSort == 'Types') {
      filtered.sort((a, b) => b.types.length.compareTo(a.types.length));
    } else if (selectedSort == 'Last Updated') {
      filtered.sort(
        (a, b) => (b.audit?.updatedAt ?? DateTime(1970))
            .compareTo(a.audit?.updatedAt ?? DateTime(1970)),
      );
    }

    return filtered;
  }

  List<Map<String, String>> _normalizeTypes(List<Map<String, String>> types) {
    return types
        .map(
          (type) => <String, String>{
            CrmFirestoreKeys.ID_KEY: (type[CrmFirestoreKeys.ID_KEY] ?? '')
                    .trim()
                    .isNotEmpty
                ? type[CrmFirestoreKeys.ID_KEY]!.trim()
                : 'relationship_type_${DateTime.now().microsecondsSinceEpoch}'
                    '_${types.indexOf(type)}',
            CrmFirestoreKeys.NAME_EN_KEY:
                (type[CrmFirestoreKeys.NAME_EN_KEY] ?? '').trim(),
            CrmFirestoreKeys.NAME_AR_KEY:
                (type[CrmFirestoreKeys.NAME_AR_KEY] ?? '').trim(),
          },
        )
        .where(
          (type) =>
              type[CrmFirestoreKeys.NAME_EN_KEY]!.isNotEmpty ||
              type[CrmFirestoreKeys.NAME_AR_KEY]!.isNotEmpty,
        )
        .toList();
  }

  String? _validateInputs({
    required String nameEn,
    required String nameAr,
    required List<Map<String, String>> types,
  }) {
    if (nameEn.trim().isEmpty && nameAr.trim().isEmpty) {
      return S.current.crmPleaseEnterRelationshipName;
    }
    if (types.isEmpty) {
      return S.current.crmPleaseAddAtLeastOneType;
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
    final String? fallbackEmail = Constant.emailUser;
    if (fallbackEmail != null && fallbackEmail.trim().isNotEmpty) {
      return fallbackEmail.trim().toLowerCase();
    }
    return 'system';
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
