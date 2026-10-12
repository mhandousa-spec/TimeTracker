// ****************** FILE INFO ******************
// File Name: crm_services_state.dart
// Purpose: Immutable UI state for CRM service categories and service items management.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';

class CrmServicesState {
  final List<CrmServiceCategoryModel> categories;
  final List<CrmServiceCategoryModel> filteredCategories;
  final List<CrmServiceItemModel> services;
  final List<CrmServiceItemModel> filteredServices;
  final List<CrmClientTypeModel> clientTypes;
  final List<CrmTagModel> tags;
  final List<CrmDiscountModel> discounts;
  final String query;
  final String status;
  final String? selectedSort;
  final int currentTab;
  final bool isGridView;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const CrmServicesState({
    this.categories = const <CrmServiceCategoryModel>[],
    this.filteredCategories = const <CrmServiceCategoryModel>[],
    this.services = const <CrmServiceItemModel>[],
    this.filteredServices = const <CrmServiceItemModel>[],
    this.clientTypes = const <CrmClientTypeModel>[],
    this.tags = const <CrmTagModel>[],
    this.discounts = const <CrmDiscountModel>[],
    this.query = '',
    this.status = 'All',
    this.selectedSort,
    this.currentTab = 0,
    this.isGridView = false,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  CrmServicesState copyWith({
    List<CrmServiceCategoryModel>? categories,
    List<CrmServiceCategoryModel>? filteredCategories,
    List<CrmServiceItemModel>? services,
    List<CrmServiceItemModel>? filteredServices,
    List<CrmClientTypeModel>? clientTypes,
    List<CrmTagModel>? tags,
    List<CrmDiscountModel>? discounts,
    String? query,
    String? status,
    String? selectedSort,
    int? currentTab,
    bool? isGridView,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmServicesState(
        categories: categories ?? this.categories,
        filteredCategories: filteredCategories ?? this.filteredCategories,
        services: services ?? this.services,
        filteredServices: filteredServices ?? this.filteredServices,
        clientTypes: clientTypes ?? this.clientTypes,
        tags: tags ?? this.tags,
        discounts: discounts ?? this.discounts,
        query: query ?? this.query,
        status: status ?? this.status,
        selectedSort: selectedSort ?? this.selectedSort,
        currentTab: currentTab ?? this.currentTab,
        isGridView: isGridView ?? this.isGridView,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
