// ****************** FILE INFO ******************
// File Name: crm_terms_cubit.dart
// Purpose: Cubit for CRM Terms Firebase integration and UI logic
// Author: Mohand Adel
// Created At: 16/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_clause_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/domain/interfaces/crm_terms_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'crm_terms_state.dart';

class CrmTermsCubit extends Cubit<CrmTermsState> {
  final CrmTermsBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmTermModel>>>? _subscription;

  CrmTermsCubit({
    CrmTermsBaseRepository? repository,
  })  : repository = repository ?? Get.find<CrmTermsBaseRepository>(),
        super(const CrmTermsState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await _subscription?.cancel();
    _subscription = repository.watchTerms().listen((result) {
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

  Future<bool> createTerm({
    required String nameEn,
    required String nameAr,
    required String status,
    required List<CrmTermClauseModel> clauses,
  }) async {
    final List<CrmTermClauseModel> normalizedClauses =
        _normalizeClauses(clauses);
    final String? validationError = _validateInputs(
      nameEn: nameEn,
      nameAr: nameAr,
      clauses: normalizedClauses,
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
    final Either<Failure, CrmTermModel> result = await repository.createTerm(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      userEmail: _currentUserEmail,
      clauses: normalizedClauses,
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

  Future<bool> updateTerm({
    required CrmTermModel currentTerm,
    required String nameEn,
    required String nameAr,
    required String status,
    required List<CrmTermClauseModel> clauses,
  }) async {
    final List<CrmTermClauseModel> normalizedClauses =
        _normalizeClauses(clauses);
    final String? validationError = _validateInputs(
      nameEn: nameEn,
      nameAr: nameAr,
      clauses: normalizedClauses,
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
    final CrmTermModel updatedTerm = currentTerm.copyWith(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      status: status.trim().toLowerCase(),
      isActive: status.trim().toLowerCase() == 'active',
      isDeleted: false,
      clauses: normalizedClauses,
    );

    final Either<Failure, void> result = await repository.updateTerm(
      term: updatedTerm,
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

  Future<bool> deleteTerm(CrmTermModel term) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.removeTerm(
      term: term,
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

  Future<bool> toggleStatus(CrmTermModel term) async {
    final bool newActive = !term.isActive;
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.toggleTermStatus(
      termId: term.id,
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

  List<CrmTermModel> _filterAndSort({
    required List<CrmTermModel> items,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) {
    List<CrmTermModel> result = List<CrmTermModel>.from(items);

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      result = result.where((term) {
        final bool nameEnMatch = term.nameEn.toLowerCase().contains(q);
        final bool nameArMatch = term.nameAr.toLowerCase().contains(q);
        final bool clausesMatch = term.clauses.any((c) =>
            c.textEn.toLowerCase().contains(q) ||
            c.textAr.toLowerCase().contains(q));
        return nameEnMatch || nameArMatch || clausesMatch;
      }).toList();
    }

    final String status = selectedStatus.toLowerCase();
    if (status == 'active') {
      result = result.where((term) => term.isActive).toList();
    } else if (status == 'inactive') {
      result = result.where((term) => !term.isActive).toList();
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

  List<CrmTermClauseModel> _normalizeClauses(
      List<CrmTermClauseModel> rawClauses) {
    final List<CrmTermClauseModel> clauses = [];
    int order = 0;
    for (final c in rawClauses) {
      final String en = c.textEn.trim();
      final String ar = c.textAr.trim();
      if (en.isNotEmpty || ar.isNotEmpty) {
        clauses.add(
          CrmTermClauseModel(
            id: c.id.isNotEmpty
                ? c.id
                : DateTime.now().microsecondsSinceEpoch.toString(),
            textEn: en.isNotEmpty ? en : ar,
            textAr: ar.isNotEmpty ? ar : en,
            order: order++,
          ),
        );
      }
    }
    return clauses;
  }

  String? _validateInputs({
    required String nameEn,
    required String nameAr,
    required List<CrmTermClauseModel> clauses,
  }) {
    if (nameEn.trim().isEmpty && nameAr.trim().isEmpty) {
      return S.current.crmPleaseEnterTermName;
    }
    if (clauses.isEmpty) {
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
    return 'system';
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
