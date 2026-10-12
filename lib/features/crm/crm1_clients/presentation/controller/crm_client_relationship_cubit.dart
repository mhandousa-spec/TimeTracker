// ****************** FILE INFO ******************
// File Name: crm_client_relationship_cubit.dart
// Purpose: Cubit managing client relationships, form state, and filtered management employee selection
// Author: Mohand Adel
// Created At: 26/08/2026

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/repository/crm_client_relationship_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/crm_employee_filter_helper.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_type_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmClientRelationshipCubit extends Cubit<CrmClientRelationshipState> {
  final CrmClientRelationshipRepository _repository;
  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _relationshipsSubscription;
  CrmClientRelationshipModel? _pendingExistingRelationship;

  CrmClientRelationshipCubit({
    String? clientId,
    CrmClientRelationshipRepository? repository,
  })  : _repository = repository ?? CrmClientRelationshipRepository(),
        super(const CrmClientRelationshipState()) {
    init(clientId: clientId);
  }

  void init({String? clientId}) {
    emit(state.copyWith(isLoading: true));
    _loadEmployees();
    _subscribeCategories();
    if (clientId != null && clientId.isNotEmpty) {
      _subscribeRelationships(clientId);
    }
  }

  void _loadEmployees() {
    try {
      final List<EmployeeEntityPro> rawEmployees =
          AppControllers.employee.allEmployeesEntities ?? [];
      final List<EmployeeEntityPro> managementEmployees =
          CrmEmployeeFilterHelper.filterManagementEmployees(rawEmployees);

      emit(state.copyWith(
        allManagementEmployees: managementEmployees,
        filteredEmployees: managementEmployees,
      ));
    } catch (_) {}
  }

  void _subscribeCategories() {
    _categoriesSubscription?.cancel();
    _categoriesSubscription =
        _repository.watchCategories().listen((categories) {
      final List<CrmRelationshipCategoryModel> activeCategories =
          categories.where((c) => !c.isDeleted).toList();

      CrmRelationshipCategoryModel? selectedCat = state.selectedCategory;
      CrmRelationshipTypeModel? selectedType = state.selectedType;

      final CrmClientRelationshipModel? pendingRelationship =
          _pendingExistingRelationship;
      if (pendingRelationship != null || selectedCat != null) {
        final String targetCatId =
            pendingRelationship?.categoryId ?? selectedCat!.id;
        final String? targetTypeId =
            pendingRelationship?.typeId ?? selectedType?.id;
        selectedCat = null;
        selectedType = null;

        for (final c in activeCategories) {
          if (c.id == targetCatId) {
            selectedCat = c;
            break;
          }
        }
        if (selectedCat != null && targetTypeId != null) {
          for (final t in selectedCat.types) {
            if (t.id == targetTypeId) {
              selectedType = t;
              break;
            }
          }
        }
      }

      emit(state.copyWith(
        categories: activeCategories,
        selectedCategory: selectedCat,
        selectedType: selectedType,
        isLoading: false,
      ));
      if (pendingRelationship != null && selectedCat != null) {
        _pendingExistingRelationship = null;
      }
    }, onError: (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
    });
  }

  void _subscribeRelationships(String clientId) {
    _relationshipsSubscription?.cancel();
    _relationshipsSubscription =
        _repository.watchClientRelationships(clientId).listen((list) {
      final CrmClientRelationshipState nextState = state.copyWith(
        relationships: list,
        relationshipCategoryFilters: _relationshipCategories(list),
        relationshipTotalCount: list.length,
        relationshipActiveCount: _statusCount(list, 'active'),
        relationshipInactiveCount: _statusCount(list, 'inactive'),
        isLoading: false,
      );
      emit(nextState.copyWith(
        visibleRelationships: _visibleRelationships(nextState),
      ));
    }, onError: (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
    });
  }

  /// Updates the relationship list search query and reapplies all list filters.
  void searchRelationships(String query) {
    final CrmClientRelationshipState nextState = state.copyWith(
      relationshipSearchQuery: query,
    );
    emit(nextState.copyWith(
      visibleRelationships: _visibleRelationships(nextState),
    ));
  }

  /// Selects a status chip and reapplies the relationship list filters.
  void setRelationshipStatusFilter(String status) {
    final CrmClientRelationshipState nextState = state.copyWith(
      relationshipStatusFilter: status,
    );
    emit(nextState.copyWith(
      visibleRelationships: _visibleRelationships(nextState),
    ));
  }

  /// Selects a category filter and reapplies the relationship list filters.
  void setRelationshipCategoryFilter(String? category) {
    final CrmClientRelationshipState nextState = state.copyWith(
      relationshipCategoryFilter: category,
      clearRelationshipCategoryFilter: category == null,
    );
    emit(nextState.copyWith(
      visibleRelationships: _visibleRelationships(nextState),
    ));
  }

  /// Selects a sort option and reapplies the relationship list filters.
  void setRelationshipSort(String? sort) {
    final CrmClientRelationshipState nextState = state.copyWith(
      relationshipSort: sort,
      clearRelationshipSort: sort == null,
    );
    emit(nextState.copyWith(
      visibleRelationships: _visibleRelationships(nextState),
    ));
  }

  List<CrmClientRelationshipModel> _visibleRelationships(
    CrmClientRelationshipState source,
  ) {
    final String query = source.relationshipSearchQuery.trim().toLowerCase();
    final String status = source.relationshipStatusFilter.toLowerCase();
    final String? category = source.relationshipCategoryFilter;
    final List<CrmClientRelationshipModel> result =
        source.relationships.where((CrmClientRelationshipModel relationship) {
      final bool matchesQuery = query.isEmpty ||
          relationship.relatedEntityName.toLowerCase().contains(query) ||
          relationship.categoryNameEn.toLowerCase().contains(query) ||
          relationship.categoryNameAr.toLowerCase().contains(query) ||
          relationship.typeNameEn.toLowerCase().contains(query) ||
          relationship.typeNameAr.toLowerCase().contains(query) ||
          (relationship.relatedEntityRole?.toLowerCase().contains(query) ??
              false);
      final bool matchesStatus =
          status == 'all' || relationship.status.toLowerCase() == status;
      final bool matchesCategory = category == null ||
          (relationship.categoryNameEn.isNotEmpty
                  ? relationship.categoryNameEn
                  : relationship.categoryNameAr) ==
              category;
      return matchesQuery && matchesStatus && matchesCategory;
    }).toList();

    switch (source.relationshipSort) {
      case 'newest':
        result.sort((a, b) => (b.startDate ?? DateTime(2000))
            .compareTo(a.startDate ?? DateTime(2000)));
        break;
      case 'oldest':
        result.sort((a, b) => (a.startDate ?? DateTime(2000))
            .compareTo(b.startDate ?? DateTime(2000)));
        break;
      case 'name':
        result
            .sort((a, b) => a.relatedEntityName.compareTo(b.relatedEntityName));
        break;
    }
    return result;
  }

  List<String> _relationshipCategories(
    List<CrmClientRelationshipModel> relationships,
  ) {
    return relationships
        .map((CrmClientRelationshipModel relationship) =>
            relationship.categoryNameEn.isNotEmpty
                ? relationship.categoryNameEn
                : relationship.categoryNameAr)
        .where((String category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  int _statusCount(
    List<CrmClientRelationshipModel> relationships,
    String status,
  ) {
    return relationships
        .where((CrmClientRelationshipModel relationship) =>
            relationship.status.toLowerCase() == status)
        .length;
  }

  void searchEmployees(String query) {
    final String cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredEmployees: state.allManagementEmployees,
      ));
      return;
    }

    final List<EmployeeEntityPro> filtered =
        state.allManagementEmployees.where((emp) {
      final String fullName =
          '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.toLowerCase();
      final String fullNameAr =
          '${emp.firstNameInArabic ?? ''} ${emp.lastNameInArabic ?? ''}'
              .toLowerCase();
      final String title = (emp.title ?? '').toLowerCase();
      final String titleAr = (emp.titleInArabic ?? '').toLowerCase();
      final String email = (emp.email ?? '').toLowerCase();

      return fullName.contains(cleanQuery) ||
          fullNameAr.contains(cleanQuery) ||
          title.contains(cleanQuery) ||
          titleAr.contains(cleanQuery) ||
          email.contains(cleanQuery);
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredEmployees: filtered,
    ));
  }

  void sortEmployees(String? sort) {
    if (sort == null || sort.isEmpty) return;
    final List<EmployeeEntityPro> sorted = List.from(state.filteredEmployees);
    switch (sort) {
      case 'name_asc':
        sorted.sort((a, b) => ('${a.firstName ?? ''} ${a.lastName ?? ''}')
            .compareTo('${b.firstName ?? ''} ${b.lastName ?? ''}'));
        break;
      case 'name_desc':
        sorted.sort((a, b) => ('${b.firstName ?? ''} ${b.lastName ?? ''}')
            .compareTo('${a.firstName ?? ''} ${a.lastName ?? ''}'));
        break;
      case 'title_asc':
        sorted.sort((a, b) =>
            (a.title ?? a.role ?? '').compareTo(b.title ?? b.role ?? ''));
        break;
      case 'title_desc':
        sorted.sort((a, b) =>
            (b.title ?? b.role ?? '').compareTo(a.title ?? a.role ?? ''));
        break;
    }
    emit(state.copyWith(filteredEmployees: sorted));
  }

  void selectCategory(CrmRelationshipCategoryModel? category) {
    emit(state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
      clearType: true,
    ));
  }

  void selectType(CrmRelationshipTypeModel? type) {
    emit(state.copyWith(
      selectedType: type,
      clearType: type == null,
    ));
  }

  void selectEmployee(EmployeeEntityPro employee) {
    emit(state.copyWith(selectedEmployee: employee));
  }

  void setStartDate(DateTime date) {
    emit(state.copyWith(startDate: date));
  }

  void setEndDate(DateTime date) {
    emit(state.copyWith(endDate: date));
  }

  void setNoteEn(String note) {
    emit(state.copyWith(noteEn: note));
  }

  void setNoteAr(String note) {
    emit(state.copyWith(noteAr: note));
  }

  void populateFromExisting(CrmClientRelationshipModel model) {
    _pendingExistingRelationship = model;
    _populateExistingRelationship(model);
    if (_categoryById(model.categoryId, state.categories) != null) {
      _pendingExistingRelationship = null;
    }
  }

  void _populateExistingRelationship(CrmClientRelationshipModel model) {
    final CrmRelationshipCategoryModel? matchedCategory =
        _categoryById(model.categoryId, state.categories);
    final CrmRelationshipTypeModel? matchedType = _typeById(
      model.typeId,
      matchedCategory,
    );
    final EmployeeEntityPro? matchedEmployee = _employeeById(
      model.relatedEntityId,
      state.allManagementEmployees,
    );

    emit(state.copyWith(
      selectedCategory: matchedCategory,
      clearCategory: matchedCategory == null,
      selectedType: matchedType,
      clearType: matchedType == null,
      selectedEmployee: matchedEmployee,
      clearSelectedEmployee: matchedEmployee == null,
      startDate: model.startDate,
      clearStartDate: model.startDate == null,
      endDate: model.endDate,
      clearEndDate: model.endDate == null,
      noteEn: model.noteEn ?? '',
      noteAr: model.noteAr ?? '',
    ));
  }

  CrmRelationshipCategoryModel? _categoryById(
    String categoryId,
    List<CrmRelationshipCategoryModel> categories,
  ) {
    for (final CrmRelationshipCategoryModel category in categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  CrmRelationshipTypeModel? _typeById(
    String typeId,
    CrmRelationshipCategoryModel? category,
  ) {
    if (category == null) return null;
    for (final CrmRelationshipTypeModel type in category.types) {
      if (type.id == typeId) return type;
    }
    return null;
  }

  EmployeeEntityPro? _employeeById(
    String employeeId,
    List<EmployeeEntityPro> employees,
  ) {
    for (final EmployeeEntityPro employee in employees) {
      if (employee.id == employeeId) return employee;
    }
    return null;
  }

  Future<bool> saveRelationship({
    required String clientId,
    CrmClientRelationshipModel? existingModel,
  }) async {
    if (state.selectedCategory == null ||
        state.selectedType == null ||
        state.selectedEmployee == null ||
        state.startDate == null) {
      emit(state.copyWith(
        errorMessage: 'Please fill in all required fields.',
      ));
      return false;
    }

    emit(state.copyWith(isSaving: true));

    final EmployeeEntityPro employee = state.selectedEmployee!;
    final String currentUserId = _currentUserEmail;
    final now = DateTime.now();

    final CrmAuditModel audit = existingModel?.audit != null
        ? existingModel!.audit!.copyWith(
            updatedBy: currentUserId,
            updatedAt: now,
          )
        : CrmAuditModel.now(userEmail: currentUserId);

    final String fullName =
        '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim();
    final String resolvedName =
        fullName.isNotEmpty ? fullName : (employee.email ?? 'Employee');
    final String fullNameAr =
        '${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}'
            .trim();
    final String? resolvedNameAr = fullNameAr.isNotEmpty ? fullNameAr : null;

    final CrmClientRelationshipModel relationship = CrmClientRelationshipModel(
      id: existingModel?.id ?? '',
      clientId: clientId,
      categoryId: state.selectedCategory!.id,
      categoryNameEn: state.selectedCategory!.nameEn,
      categoryNameAr: state.selectedCategory!.nameAr,
      typeId: state.selectedType!.id,
      typeNameEn: state.selectedType!.nameEn,
      typeNameAr: state.selectedType!.nameAr,
      relatedEntityId: employee.id ?? '',
      relatedEntityName: resolvedName,
      relatedEntityNameAr: resolvedNameAr,
      relatedEntityType: 'employee',
      relatedEntityRole: employee.title ?? employee.role,
      relatedEntityAvatar: employee.photo,
      relatedEntityPhone: employee.mobilePhone?.number,
      relatedEntityEmail: employee.email,
      startDate: state.startDate,
      endDate: state.endDate,
      noteEn: state.noteEn,
      noteAr: state.noteAr,
      status: existingModel?.status ?? 'active',
      audit: audit,
    );

    final result = existingModel == null
        ? await _repository.createRelationship(
            clientId: clientId,
            relationship: relationship,
            audit: audit,
          )
        : await _repository.updateRelationship(
            clientId: clientId,
            relationship: relationship,
            audit: audit,
          );

    return result.fold(
      (error) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: error.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isSaving: false,
          successMessage: existingModel == null
              ? 'Relationship created successfully'
              : 'Relationship updated successfully',
        ));
        return true;
      },
    );
  }

  Future<bool> deleteRelationship({
    required String clientId,
    required String relationshipId,
  }) async {
    emit(state.copyWith(isSaving: true));
    final currentUserId = _currentUserEmail;
    final audit = CrmAuditModel.now(userEmail: currentUserId);

    final result = await _repository.deleteRelationship(
      clientId: clientId,
      relationshipId: relationshipId,
      audit: audit,
    );

    return result.fold(
      (error) {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: error.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isSaving: false,
          successMessage: 'Relationship deleted successfully',
        ));
        return true;
      },
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

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    _relationshipsSubscription?.cancel();
    return super.close();
  }
}
