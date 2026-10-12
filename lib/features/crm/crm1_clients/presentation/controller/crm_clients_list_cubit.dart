// ****************** FILE INFO ******************
// File Name: crm_clients_list_cubit.dart
// Purpose: Cubit for the CRM clients list/dashboard watching client types,
//          templates, and client records
// Author: Mohand Adel
// Created At: 08/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'crm_clients_list_state.dart';

class CrmClientsListCubit extends Cubit<CrmClientsListState> {
  final CrmControlsBaseRepository controlsRepository;
  final CrmClientsBaseRepository clientsRepository;

  StreamSubscription<Either<Failure, List<CrmClientTypeModel>>>?
      _clientTypesSubscription;
  StreamSubscription<Either<Failure, List<CrmTemplateModel>>>?
      _templatesSubscription;
  StreamSubscription<Either<Failure, List<CrmClientRecordModel>>>?
      _recordsSubscription;

  CrmClientsListCubit({
    CrmControlsBaseRepository? controlsRepository,
    CrmClientsBaseRepository? clientsRepository,
  })  : controlsRepository =
            controlsRepository ?? Get.find<CrmControlsBaseRepository>(),
        clientsRepository =
            clientsRepository ?? Get.find<CrmClientsBaseRepository>(),
        super(const CrmClientsListState());

  /// Ensures control defaults and starts watching client types, templates,
  /// and client records. [preferredClientTypeId] optionally preselects a tab.
  Future<void> init({String? preferredClientTypeId}) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final Either<Failure, void> defaults =
        await controlsRepository.ensureDefaults(userEmail: _currentUserEmail);
    if (defaults.isLeft()) {
      defaults.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (_) {},
      );
      return;
    }
    _preferredClientTypeId = preferredClientTypeId;
    _watchClientTypes();
    _watchTemplates();
    _watchClientRecords();
  }

  void selectClientType(String clientTypeId) {
    emit(state.copyWith(selectedClientTypeId: clientTypeId));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim().toLowerCase()));
  }

  void toggleSort() {
    emit(state.copyWith(sortAscending: !state.sortAscending));
  }

  void setSortOption(String? option) {
    if (option == null) {
      emit(state.copyWith(clearSortOption: true));
    } else {
      emit(state.copyWith(selectedSortOption: option));
    }
  }

  void setTemplateFilterStatus(String? status) {
    emit(state.copyWith(templateFilterStatus: status?.trim() ?? ''));
  }

  List<CrmTemplateModel> visibleTemplates() {
    final String query = state.searchQuery.trim().toLowerCase();
    final List<CrmTemplateModel> result = state.templates.where((template) {
      final bool matchesType = state.selectedClientTypeId.isEmpty ||
          template.clientTypeId == state.selectedClientTypeId;
      final bool matchesStatus = template.status.toLowerCase() != 'deleted' &&
          (state.templateFilterStatus.isEmpty ||
              template.status.toLowerCase() ==
                  state.templateFilterStatus.toLowerCase());
      final bool matchesQuery = query.isEmpty ||
          template.nameEn.toLowerCase().contains(query) ||
          template.nameAr.toLowerCase().contains(query);
      return matchesType && matchesStatus && matchesQuery;
    }).toList();
    switch (state.selectedSortOption) {
      case 'name_desc':
        result.sort((a, b) => b.nameEn.compareTo(a.nameEn));
      case 'date_asc':
        result.sort((a, b) => a.audit.createdAt.compareTo(b.audit.createdAt));
      case 'date_desc':
        result.sort((a, b) => b.audit.createdAt.compareTo(a.audit.createdAt));
      case 'name_asc':
      default:
        result.sort((a, b) => a.nameEn.compareTo(b.nameEn));
    }
    return result;
  }

  void setDashboardCityFilter(String? city) {
    emit(state.copyWith(dashboardCity: city?.trim() ?? ''));
  }

  void setDashboardCountryFilter(String? country) {
    emit(state.copyWith(dashboardCountry: country?.trim() ?? ''));
  }

  void setDashboardStatusFilter(String? status) {
    emit(state.copyWith(dashboardStatus: status?.trim() ?? ''));
  }

  void setDashboardClientTypeFilter(String? clientTypeId) {
    emit(state.copyWith(dashboardClientTypeId: clientTypeId?.trim() ?? ''));
  }

  void setDashboardDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) {
      emit(state.copyWith(clearDashboardDateRange: true));
      return;
    }
    emit(
      state.copyWith(
        dashboardStartDate: startDate,
        dashboardEndDate: endDate,
      ),
    );
  }

  /// Records filtered to the currently selected client type tab.
  List<CrmClientRecordModel> recordsForSelectedType() {
    final String selectedId = state.selectedClientTypeId;
    if (selectedId.isEmpty) return const [];
    return state.records
        .where((record) => record.clientTypeId == selectedId)
        .toList();
  }

  /// First active (published) template for a client type, falling back to any
  /// template of that type. Used by the template details page.
  CrmTemplateModel? activeTemplateFor(String clientTypeId) {
    final List<CrmTemplateModel> forType = state.templates
        .where((template) => template.clientTypeId == clientTypeId)
        .toList();
    for (final CrmTemplateModel template in forType) {
      final String status = template.status.toLowerCase();
      if (status == 'active' || status == 'published') return template;
    }
    return forType.isEmpty ? null : forType.first;
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  /// Updates the status (e.g. 'active', 'inactive') of a client record.
  Future<bool> updateClientStatus({
    required String recordId,
    required String status,
  }) async {
    final result = await clientsRepository.updateClientStatus(
      recordId: recordId,
      status: status,
      userEmail: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> updateClientBlacklist({
    required String recordId,
    required String reason,
    required bool isRemovalRequest,
  }) async {
    final result = await clientsRepository.updateClientBlacklist(
      recordId: recordId,
      reason: reason,
      isRemovalRequest: isRemovalRequest,
      userEmail: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        return false;
      },
      (_) => true,
    );
  }

  /// Soft deletes a client record.
  Future<bool> softDeleteClientRecord(String recordId) async {
    final result = await clientsRepository.softDeleteClientRecord(
      recordId: recordId,
      userEmail: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        return false;
      },
      (_) => true,
    );
  }

  String? _preferredClientTypeId;

  void _watchClientTypes() {
    _clientTypesSubscription?.cancel();
    _clientTypesSubscription = controlsRepository.watchClientTypes().listen(
          (result) => result.fold(
            (failure) => emit(
              state.copyWith(
                  isLoading: false, errorMessage: failure.errMessage),
            ),
            (items) {
              final String selectedId = state.selectedClientTypeId.isNotEmpty
                  ? state.selectedClientTypeId
                  : (_preferredClientTypeId ?? '').isNotEmpty
                      ? _preferredClientTypeId!
                      : (items.isEmpty ? '' : items.first.id);
              emit(
                state.copyWith(
                  clientTypes: items,
                  selectedClientTypeId: selectedId,
                  isLoading: false,
                  clearMessages: true,
                ),
              );
            },
          ),
        );
  }

  void _watchTemplates() {
    _templatesSubscription?.cancel();
    _templatesSubscription = controlsRepository.watchTemplates().listen(
          (result) => result.fold(
            (failure) => emit(
              state.copyWith(
                  isLoading: false, errorMessage: failure.errMessage),
            ),
            (templates) => emit(
              state.copyWith(
                templates: templates,
                isLoading: false,
                clearMessages: true,
              ),
            ),
          ),
        );
  }

  void _watchClientRecords() {
    _recordsSubscription?.cancel();
    _recordsSubscription = clientsRepository.watchClientRecords().listen(
          (result) => result.fold(
            (failure) => emit(
              state.copyWith(
                  isLoading: false, errorMessage: failure.errMessage),
            ),
            (records) => emit(
              state.copyWith(
                records: records,
                isLoading: false,
                clearMessages: true,
              ),
            ),
          ),
        );
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
    await _recordsSubscription?.cancel();
    return super.close();
  }
}
