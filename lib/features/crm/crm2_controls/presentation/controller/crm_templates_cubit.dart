// ****************** FILE INFO ******************
// File Name: crm_templates_cubit.dart
// Purpose: Cubit for CRM controls templates listing and draft creation
// Author: Mohand Adel
// Created At: 05/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'crm_templates_state.dart';

class CrmTemplatesCubit extends Cubit<CrmTemplatesState> {
  final CrmControlsBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmClientTypeModel>>>?
      _clientTypesSubscription;
  StreamSubscription<Either<Failure, List<CrmTemplateModel>>>?
      _templatesSubscription;

  CrmTemplatesCubit({CrmControlsBaseRepository? repository})
      : repository = repository ?? Get.find<CrmControlsBaseRepository>(),
        super(const CrmTemplatesState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final Either<Failure, void> defaults =
        await repository.ensureDefaults(userEmail: _currentUserEmail);
    if (defaults.isLeft()) {
      defaults.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (_) {},
      );
      return;
    }
    final Either<Failure, void> syncAll =
        await repository.syncDefaultsForAllTemplates(
      userEmail: _currentUserEmail,
    );
    if (syncAll.isLeft()) {
      syncAll.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (_) {},
      );
      return;
    }
    _watchClientTypes();
    _watchTemplates();
  }

  void selectClientType(String clientTypeId) {
    emit(
      state.copyWith(
        selectedClientTypeId: clientTypeId,
        filteredTemplates: _filterTemplates(
          state.templates,
          clientTypeId,
          state.selectedStatus,
          state.searchQuery,
        ),
        clearMessages: true,
      ),
    );
  }

  void selectStatus(String status) {
    emit(
      state.copyWith(
        selectedStatus: status,
        filteredTemplates: _filterTemplates(
          state.templates,
          state.selectedClientTypeId,
          status,
          state.searchQuery,
        ),
        clearMessages: true,
      ),
    );
  }

  void search(String query) {
    final String normalizedQuery = query.trim();
    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        filteredTemplates: _filterTemplates(
          state.templates,
          state.selectedClientTypeId,
          state.selectedStatus,
          normalizedQuery,
        ),
        clearMessages: true,
      ),
    );
  }

  void setToolbarFilter(String? filter) {
    emit(filter == null
        ? state.copyWith(clearToolbarFilter: true)
        : state.copyWith(selectedToolbarFilter: filter));
  }

  void setSort(String? sort) {
    emit(sort == null
        ? state.copyWith(clearSort: true)
        : state.copyWith(selectedSort: sort));
  }

  List<CrmTemplateModel> visibleTemplates() {
    final List<CrmTemplateModel> result =
        List<CrmTemplateModel>.from(state.filteredTemplates);
    switch (state.selectedSort) {
      case 'Newest':
        result.sort((a, b) => b.audit.createdAt.compareTo(a.audit.createdAt));
      case 'Active':
        result.sort((a, b) => a.status.compareTo(b.status));
    }
    return result;
  }

  Future<CrmTemplateModel?> createTemplateDraft({
    required String nameEn,
    required String nameAr,
  }) async {
    if (nameEn.trim().isEmpty || nameAr.trim().isEmpty) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Template English and Arabic names are required',
        ),
      );
      return null;
    }
    if (state.selectedClientTypeId.isEmpty) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Select client type before creating a template',
        ),
      );
      return null;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmTemplateModel> result =
        await repository.createTemplateDraft(
      clientTypeId: state.selectedClientTypeId,
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      userEmail: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(
          state.copyWith(isSaving: false, errorMessage: failure.errMessage),
        );
        return null;
      },
      (template) {
        emit(
          state.copyWith(isSaving: false, successMessage: 'created'),
        );
        return template;
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  void _watchClientTypes() {
    _clientTypesSubscription?.cancel();
    _clientTypesSubscription = repository.watchClientTypes().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (items) {
          final String selectedId = state.selectedClientTypeId.isNotEmpty
              ? state.selectedClientTypeId
              : (items.isEmpty ? '' : items.first.id);
          emit(
            state.copyWith(
              clientTypes: items,
              selectedClientTypeId: selectedId,
              filteredTemplates: _filterTemplates(
                state.templates,
                selectedId,
                state.selectedStatus,
                state.searchQuery,
              ),
              isLoading: false,
              clearMessages: true,
            ),
          );
        },
      );
    });
  }

  void _watchTemplates() {
    _templatesSubscription?.cancel();
    _templatesSubscription = repository.watchTemplates().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (templates) => emit(
          state.copyWith(
            templates: templates,
            filteredTemplates: _filterTemplates(
              templates,
              state.selectedClientTypeId,
              state.selectedStatus,
              state.searchQuery,
            ),
            isLoading: false,
            clearMessages: true,
          ),
        ),
      );
    });
  }

  List<CrmTemplateModel> _filterTemplates(
    List<CrmTemplateModel> templates,
    String clientTypeId,
    String status,
    String query,
  ) {
    final String normalizedQuery = query.trim().toLowerCase();
    return templates.where((template) {
      final bool matchesClientType =
          clientTypeId.isEmpty || template.clientTypeId == clientTypeId;
      final String templateStatus = template.status.toLowerCase();
      final String selectedStatus = status.toLowerCase();
      final bool matchesStatus = selectedStatus == 'all' ||
          templateStatus == selectedStatus ||
          (selectedStatus == 'inactive' && templateStatus == 'draft');
      final bool matchesQuery = normalizedQuery.isEmpty ||
          template.nameEn.toLowerCase().contains(normalizedQuery) ||
          template.nameAr.toLowerCase().contains(normalizedQuery);
      return matchesClientType && matchesStatus && matchesQuery;
    }).toList();
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
    await _clientTypesSubscription?.cancel();
    await _templatesSubscription?.cancel();
    return super.close();
  }
}
