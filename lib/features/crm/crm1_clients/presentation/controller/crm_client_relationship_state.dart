// ****************** FILE INFO ******************
// File Name: crm_client_relationship_state.dart
// Purpose: State class for client relationships management and form
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_type_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmClientRelationshipState {
  final bool isLoading;
  final bool isSaving;
  final List<CrmClientRelationshipModel> relationships;
  final List<CrmClientRelationshipModel> visibleRelationships;
  final String relationshipSearchQuery;
  final String relationshipStatusFilter;
  final String? relationshipCategoryFilter;
  final String? relationshipSort;
  final List<String> relationshipCategoryFilters;
  final int relationshipTotalCount;
  final int relationshipActiveCount;
  final int relationshipInactiveCount;
  final List<CrmRelationshipCategoryModel> categories;
  final CrmRelationshipCategoryModel? selectedCategory;
  final CrmRelationshipTypeModel? selectedType;
  final List<EmployeeEntityPro> allManagementEmployees;
  final List<EmployeeEntityPro> filteredEmployees;
  final EmployeeEntityPro? selectedEmployee;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String noteEn;
  final String noteAr;
  final String? errorMessage;
  final String? successMessage;

  const CrmClientRelationshipState({
    this.isLoading = false,
    this.isSaving = false,
    this.relationships = const [],
    this.visibleRelationships = const [],
    this.relationshipSearchQuery = '',
    this.relationshipStatusFilter = 'all',
    this.relationshipCategoryFilter,
    this.relationshipSort,
    this.relationshipCategoryFilters = const [],
    this.relationshipTotalCount = 0,
    this.relationshipActiveCount = 0,
    this.relationshipInactiveCount = 0,
    this.categories = const [],
    this.selectedCategory,
    this.selectedType,
    this.allManagementEmployees = const [],
    this.filteredEmployees = const [],
    this.selectedEmployee,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.noteEn = '',
    this.noteAr = '',
    this.errorMessage,
    this.successMessage,
  });

  CrmClientRelationshipState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<CrmClientRelationshipModel>? relationships,
    List<CrmClientRelationshipModel>? visibleRelationships,
    String? relationshipSearchQuery,
    String? relationshipStatusFilter,
    String? relationshipCategoryFilter,
    bool clearRelationshipCategoryFilter = false,
    String? relationshipSort,
    bool clearRelationshipSort = false,
    List<String>? relationshipCategoryFilters,
    int? relationshipTotalCount,
    int? relationshipActiveCount,
    int? relationshipInactiveCount,
    List<CrmRelationshipCategoryModel>? categories,
    CrmRelationshipCategoryModel? selectedCategory,
    bool clearCategory = false,
    CrmRelationshipTypeModel? selectedType,
    bool clearType = false,
    List<EmployeeEntityPro>? allManagementEmployees,
    List<EmployeeEntityPro>? filteredEmployees,
    EmployeeEntityPro? selectedEmployee,
    bool clearSelectedEmployee = false,
    String? searchQuery,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? noteEn,
    String? noteAr,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmClientRelationshipState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      relationships: relationships ?? this.relationships,
      visibleRelationships: visibleRelationships ?? this.visibleRelationships,
      relationshipSearchQuery:
          relationshipSearchQuery ?? this.relationshipSearchQuery,
      relationshipStatusFilter:
          relationshipStatusFilter ?? this.relationshipStatusFilter,
      relationshipCategoryFilter: clearRelationshipCategoryFilter
          ? null
          : (relationshipCategoryFilter ?? this.relationshipCategoryFilter),
      relationshipSort: clearRelationshipSort
          ? null
          : (relationshipSort ?? this.relationshipSort),
      relationshipCategoryFilters:
          relationshipCategoryFilters ?? this.relationshipCategoryFilters,
      relationshipTotalCount:
          relationshipTotalCount ?? this.relationshipTotalCount,
      relationshipActiveCount:
          relationshipActiveCount ?? this.relationshipActiveCount,
      relationshipInactiveCount:
          relationshipInactiveCount ?? this.relationshipInactiveCount,
      categories: categories ?? this.categories,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      allManagementEmployees:
          allManagementEmployees ?? this.allManagementEmployees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      selectedEmployee: clearSelectedEmployee
          ? null
          : (selectedEmployee ?? this.selectedEmployee),
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      noteEn: noteEn ?? this.noteEn,
      noteAr: noteAr ?? this.noteAr,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
