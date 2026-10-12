// ****************** FILE INFO ******************
// File Name: crm_clients_list_state.dart
// Purpose: State model for the CRM clients list controller
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';

class CrmClientsListState {
  final List<CrmClientTypeModel> clientTypes;
  final List<CrmTemplateModel> templates;
  final List<CrmClientRecordModel> records;
  final String selectedClientTypeId;
  final String searchQuery;
  final String? selectedSortOption;
  final String templateFilterStatus;
  final bool sortAscending;
  final String dashboardCity;
  final String dashboardCountry;
  final String dashboardStatus;
  final String dashboardClientTypeId;
  final DateTime? dashboardStartDate;
  final DateTime? dashboardEndDate;
  final bool isLoading;
  final String? errorMessage;

  const CrmClientsListState({
    this.clientTypes = const [],
    this.templates = const [],
    this.records = const [],
    this.selectedClientTypeId = '',
    this.searchQuery = '',
    this.selectedSortOption,
    this.templateFilterStatus = '',
    this.sortAscending = true,
    this.dashboardCity = '',
    this.dashboardCountry = '',
    this.dashboardStatus = '',
    this.dashboardClientTypeId = '',
    this.dashboardStartDate,
    this.dashboardEndDate,
    this.isLoading = false,
    this.errorMessage,
  });

  CrmClientsListState copyWith({
    List<CrmClientTypeModel>? clientTypes,
    List<CrmTemplateModel>? templates,
    List<CrmClientRecordModel>? records,
    String? selectedClientTypeId,
    String? searchQuery,
    String? selectedSortOption,
    String? templateFilterStatus,
    bool clearSortOption = false,
    bool? sortAscending,
    String? dashboardCity,
    String? dashboardCountry,
    String? dashboardStatus,
    String? dashboardClientTypeId,
    DateTime? dashboardStartDate,
    DateTime? dashboardEndDate,
    bool clearDashboardDateRange = false,
    bool? isLoading,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return CrmClientsListState(
      clientTypes: clientTypes ?? this.clientTypes,
      templates: templates ?? this.templates,
      records: records ?? this.records,
      selectedClientTypeId: selectedClientTypeId ?? this.selectedClientTypeId,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSortOption: clearSortOption
          ? null
          : (selectedSortOption ?? this.selectedSortOption),
      templateFilterStatus: templateFilterStatus ?? this.templateFilterStatus,
      sortAscending: sortAscending ?? this.sortAscending,
      dashboardCity: dashboardCity ?? this.dashboardCity,
      dashboardCountry: dashboardCountry ?? this.dashboardCountry,
      dashboardStatus: dashboardStatus ?? this.dashboardStatus,
      dashboardClientTypeId:
          dashboardClientTypeId ?? this.dashboardClientTypeId,
      dashboardStartDate: clearDashboardDateRange
          ? null
          : (dashboardStartDate ?? this.dashboardStartDate),
      dashboardEndDate: clearDashboardDateRange
          ? null
          : (dashboardEndDate ?? this.dashboardEndDate),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessages ? null : errorMessage,
    );
  }
}
