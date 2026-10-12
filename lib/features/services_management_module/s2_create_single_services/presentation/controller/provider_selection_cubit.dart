// ******************* FILE INFO *******************
// File Name: provider_selection_cubit
// Description: Provider selection cubit.
// Module: services_management_module / presentation/s2_create_single_services/controller
// *************************************************

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/helper/employee_services_permissions.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/shared.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/services_prefs_employee.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/firebase_draft_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/data/provider_selection_data.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_state.dart';

part 'provider_selection_cubit_helpers.dart';

part 'provider_selection_cubit_ext.dart';

class ProviderSelectionCubit extends Cubit<ProviderSelectionState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final MainCoreEmployeeController employeeController;
  final MainCoreDepartmentCubit departmentController;
  final ServicesManagerCubit servicesManagerCubit;

  ProviderSelectionCubit({
    required this.employeeController,
    required this.departmentController,
    required this.servicesManagerCubit,
  }) : super(const ProviderSelectionInitial());

  // ==================== INITIALIZATION ====================

  Future<void> initialize({
    ServicesHistoryModel? editingModel,
    String? docId,
    ServicesHistoryModel? editProvider,
  }) async {
    emit(const ProviderSelectionLoading());

    final isEditMode = editProvider != null;
    String? originalProviderEmail;

    if (isEditMode && editProvider != null) {
      final providers = editProvider.currentProviderServices;
      if (providers.isNotEmpty) {
        originalProviderEmail = providers.first.email;
      }
    }

    final initialData = ProviderSelectionData(
      editingModel: editingModel,
      docId: docId,
      editProvider: editProvider,
      isEditMode: isEditMode,
      originalProviderEmail: originalProviderEmail,
    );

    emit(ProviderSelectionLoaded(
      data: initialData,
      allEmployees: [],
      filteredEmployees: [],
    ));

    // Post-frame initialization
    await _clearAllPreviousData();
    await _initializeCorrectSelection(editingModel, editProvider, isEditMode);
    await _loadEmployeesFromMainCore();
  }

  // ==================== DATA LOADING ====================

  /// Bug report p1 (25/9/2026): only employees whose ROLE has the
  /// "Requested Services" switches on can work a request, so only they are
  /// offered as providers.
  Future<List<EmployeeEntityPro>?> _onlyProviders(
      List<EmployeeEntityPro>? employees) async {
    if (employees == null || employees.isEmpty) return employees;
    await EmployeeServicesPermissions.preload(employees);
    return employees.where(EmployeeServicesPermissions.canBeProvider).toList();
  }

  Future<void> _loadEmployeesFromMainCore() async {

    try {
      final employees = await _onlyProviders(employeeController.allEmployeesEntities);

      if (employees != null && employees.isNotEmpty) {
        final currentState = state as ProviderSelectionLoaded;

        emit(currentState.copyWith(
          data: currentState.data.copyWith(isLoading: false),
          allEmployees: employees,
        ));

        _applySearchFilter('');
      } else {

        final fetchedEmployees =
            await _onlyProviders(await employeeController.getAllNewEmployees());

        if (fetchedEmployees != null && fetchedEmployees.isNotEmpty) {
          final currentState = state as ProviderSelectionLoaded;

          emit(currentState.copyWith(
            data: currentState.data.copyWith(isLoading: false),
            allEmployees: fetchedEmployees,
          ));

          _applySearchFilter('');
        } else {
          final currentState = state as ProviderSelectionLoaded;
          emit(currentState.copyWith(
            data: currentState.data.copyWith(isLoading: false),
          ));
        }
      }
    } catch (e, stackTrace) {

      final currentState = state as ProviderSelectionLoaded;
      emit(currentState.copyWith(
        data: currentState.data.copyWith(isLoading: false),
      ));
    }

  }

  // ==================== SELECTION MANAGEMENT ====================

  Future<void> _clearAllPreviousData() async {
    try {
      await SharedPrefsEmployeeHelper.clearSelectedEmployees();

      final currentState = state as ProviderSelectionLoaded;
      final data = currentState.data;

      if (data.isEditMode) {
        if (servicesManagerCubit.docService != null) {
          servicesManagerCubit.docService = servicesManagerCubit.docService!.copyWith(
            providerServices: [],
          );
        }
      } else if (servicesManagerCubit.docService != null) {
        if (data.editingModel?.id != null &&
            servicesManagerCubit.docService?.id != data.editingModel?.id) {
          servicesManagerCubit.docService = null;
        }
      }

    } catch (e) {
    }
  }

  Future<void> _initializeCorrectSelection(
      ServicesHistoryModel? editingModel,
      ServicesHistoryModel? editProvider,
      bool isEditMode,
      ) async {

    final currentState = state as ProviderSelectionLoaded;

    if (currentState.data.hasRestoredSelection) {
      return;
    }

    try {
      Set<String> selectedEmails = {};

      if (isEditMode) {

        await SharedPrefsEmployeeHelper.clearSelectedEmployees();

        if (servicesManagerCubit.docService != null) {
          servicesManagerCubit.docService = servicesManagerCubit.docService!.copyWith(
            providerServices: [],
          );
        }

      } else if (editingModel != null) {
        final correctProviders = editingModel.currentProviderServices;

        final validEmails = <String>{};
        for (final provider in correctProviders) {
          if (provider.email != null && provider.email!.isNotEmpty) {
            validEmails.add(normalizeEmail(provider.email!));
          }
        }

        selectedEmails = validEmails;

      } else {
        final cubitModel = servicesManagerCubit.docService;

        if (cubitModel != null) {
          final cubitProviders = cubitModel.currentProviderServices;

          final validEmails = <String>{};
          for (final provider in cubitProviders) {
            if (provider.email != null && provider.email!.isNotEmpty) {
              validEmails.add(normalizeEmail(provider.email!));
            }
          }

          selectedEmails = validEmails;

        } else {
          final savedEmployees = await SharedPrefsEmployeeHelper.getSelectedEmployees();

          final validEmails = <String>{};
          for (final employee in savedEmployees) {
            if (employee.email != null && employee.email!.isNotEmpty) {
              validEmails.add(normalizeEmail(employee.email!));
            }
          }

          selectedEmails = validEmails;
        }
      }

      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          selectedEmployeeEmails: selectedEmails,
          hasRestoredSelection: true,
        ),
      ));

    } catch (e) {
      emit(currentState.copyWith(
        data: currentState.data.copyWith(
          selectedEmployeeEmails: <String>{},
          hasRestoredSelection: true,
        ),
      ));
    }
  }

  // ==================== SEARCH & FILTER ====================

  void updateSearch(String query) {
    _applySearchFilter(query);
  }

  void _applySearchFilter(String query) {
    final currentState = state as ProviderSelectionLoaded;
    final data = currentState.data;
    final allEmployees = currentState.allEmployees;

    final q = query.trim().toLowerCase();

    var availableEmployees = List<EmployeeEntityPro>.from(allEmployees);

    if (data.isEditMode && data.originalProviderEmail != null) {
      final normalizedOriginal = normalizeEmail(data.originalProviderEmail);
      availableEmployees = availableEmployees
          .where((e) => normalizeEmail(e.email) != normalizedOriginal)
          .toList();
    }

    final selected = availableEmployees
        .where((e) => data.selectedEmployeeEmails.contains(normalizeEmail(e.email)))
        .toList();

    if (q.isEmpty) {
      final rest = availableEmployees
          .where((e) => !data.selectedEmployeeEmails.contains(normalizeEmail(e.email)))
          .toList();

      emit(currentState.copyWith(
        filteredEmployees: [...selected, ...rest],
        searchQuery: query,
      ));
      return;
    }

    final matches = availableEmployees.where((employee) {
      final firstName = (employee.firstName ?? '').trim().toLowerCase();
      final lastName = (employee.lastName ?? '').trim().toLowerCase();
      final fullName = '$firstName $lastName';
      final firstNameAr = (employee.firstNameInArabic ?? '').trim().toLowerCase();
      final lastNameAr = (employee.middleNameInArabic ?? '').trim().toLowerCase();
      final fullNameAr = '$firstNameAr $lastNameAr';

      return firstName.startsWith(q) ||
          lastName.startsWith(q) ||
          fullName.startsWith(q) ||
          firstNameAr.startsWith(q) ||
          lastNameAr.startsWith(q) ||
          fullNameAr.startsWith(q);
    }).where((e) => !data.selectedEmployeeEmails.contains(normalizeEmail(e.email))).toList();

    emit(currentState.copyWith(
      filteredEmployees: [...selected, ...matches],
      searchQuery: query,
    ));
  }

  // ==================== PROVIDER SELECTION ====================

  void toggleProviderSelection(String email) {
    final currentState = state as ProviderSelectionLoaded;
    final data = currentState.data;
    final normalizedEmail = normalizeEmail(email);

    Set<String> newSelection = Set<String>.from(data.selectedEmployeeEmails);

    if (data.isEditMode) {
      // Single select for edit mode
      newSelection.clear();
      newSelection.add(normalizedEmail);
    } else {
      // Multi select for create mode
      if (newSelection.contains(normalizedEmail)) {
        newSelection.remove(normalizedEmail);
      } else {
        newSelection.add(normalizedEmail);
      }
    }

    emit(currentState.copyWith(
      data: data.copyWith(selectedEmployeeEmails: newSelection),
    ));

    _applySearchFilter(currentState.searchQuery);
    _saveSelectionToPrefsAndCubit();
  }

  Future<void> _saveSelectionToPrefsAndCubit() async {
    final currentState = state as ProviderSelectionLoaded;
    final data = currentState.data;

    if (data.selectedEmployeeEmails.isEmpty) {
      await SharedPrefsEmployeeHelper.clearSelectedEmployees();

      // ✅ FIX (bug report p2): an empty selection has to be pushed into the
      // model too.
      //
      // This used to clear prefs and return, leaving whatever providers were
      // already on the in-memory model untouched. Saving a draft with nothing
      // selected then persisted the previously-selected provider, which is why
      // a draft saved without picking anyone came back with a provider already
      // ticked when it was reopened.
      if (data.editingModel != null) {
        servicesManagerCubit.docService = data.editingModel!.copyWith(
          providerServices: const [],
        );
      } else {
        final current = servicesManagerCubit.docService;
        if (current != null) {
          servicesManagerCubit.docService = current.copyWith(
            providerServices: const [],
          );
        }
      }
      return;
    }

    try {
      final chosen = currentState.allEmployees
          .where((e) => data.selectedEmployeeEmails.contains(normalizeEmail(e.email)))
          .map((e) => _mapToEmployeeEntityModell(e))
          .toList();

      await SharedPrefsEmployeeHelper.saveSelectedEmployees(chosen);

      if (data.editingModel != null) {
        servicesManagerCubit.docService = data.editingModel!.copyWith(
          providerServices: chosen,
        );
      } else {
        final current = servicesManagerCubit.docService;
        if (current != null) {
          servicesManagerCubit.docService = current.copyWith(
            providerServices: chosen,
          );
        } else {
          servicesManagerCubit.docService = ServicesHistoryModel.createNew(
            id: '',
            state: "draft",
            status: "draft",
            providerServices: chosen,
            selectDepartment: [],
            approvalCycle: [],
            emailRequester: employeeController.employeeEntity?.email ?? '',
            serviceNameEnglish: '',
            serviceNameArabic: '',
            serviceDescriptionEnglish: '',
            serviceDescriptionArabic: '',
            durationOfServices: '',
            selectedDurationUnit: '',
          );
        }
      }

    } catch (e) {
      rethrow;
    }
  }

  void validateSelectionAfterLoad() {
    final currentState = state as ProviderSelectionLoaded;
    final data = currentState.data;

    if (!data.hasRestoredSelection || currentState.allEmployees.isEmpty) return;

    final validEmails = currentState.allEmployees
        .map((e) => normalizeEmail(e.email))
        .where((e) => e.isNotEmpty)
        .toSet();

    final currentSelection = Set<String>.from(data.selectedEmployeeEmails);

    final validSelection = currentSelection
        .where((email) => validEmails.contains(normalizeEmail(email)))
        .toSet();

    if (validSelection.length != currentSelection.length) {

      emit(currentState.copyWith(
        data: data.copyWith(selectedEmployeeEmails: validSelection),
      ));
    }

  }

  Future<void> handleSaveForLaterToFirebase() async {
    // ✅ Guard
    if (state is! ProviderSelectionLoaded) return;
    final currentState = state as ProviderSelectionLoaded;

    emit(ProviderSelectionSaving(
      data: currentState.data,
      allEmployees: currentState.allEmployees,
    ));

    try {
      // ✅ FIX: Use saved reference instead of casting state again
      final completeModel = await _getCompleteServiceModel(
        data: currentState.data,
        allEmployees: currentState.allEmployees,
      );

      final draftId = await servicesManagerCubit.saveDraftToFirebase(
        model: completeModel,
        currentPage: FirebaseDraftRepository.pageSelectProvider,
      );

      emit(ProviderSelectionSavedToFirebase(draftId: draftId));
      // No need to restore here — this navigates away

    } catch (error) {
      // ✅ Restore loaded state on error
      emit(currentState);
      emit(ProviderSelectionError('Failed to save draft: $error'));
      emit(currentState); // Restore after error state
    }
  }

// ==================== MODEL BUILDING ====================

// ✅ UPDATED: Accept data as parameters instead of casting state
  Future<ServicesHistoryModel> _getCompleteServiceModel({
    required ProviderSelectionData data,
    required List<EmployeeEntityPro> allEmployees,
  }) async {
    final requesterEmail = employeeController.employeeEntity?.email ?? '';

    if (data.editingModel != null) {

      final selectedEmployees = allEmployees
          .where((e) => data.selectedEmployeeEmails.contains(normalizeEmail(e.email)))
          .map((e) => _mapToEmployeeEntityModell(e))
          .toList();

      return data.editingModel!.copyWith(
        providerServices: selectedEmployees,
      );
    }

    final cubitModel = servicesManagerCubit.docService;

    if (cubitModel != null) {

      final selectedEmployees = allEmployees
          .where((e) => data.selectedEmployeeEmails.contains(normalizeEmail(e.email)))
          .map((e) => _mapToEmployeeEntityModell(e))
          .toList();

      return cubitModel.copyWith(
        providerServices: selectedEmployees,
      );
    }

    // For NEW services from SharedPrefs
    final nameEn = await SharedPrefsHelper.getString('service_name_en') ?? '';
    final nameAr = await SharedPrefsHelper.getString('service_name_ar') ?? '';
    final descEn = await SharedPrefsHelper.getString('service_description_en') ?? '';
    final descAr = await SharedPrefsHelper.getString('service_description_ar') ?? '';
    final durationVal = await SharedPrefsHelper.getString('duration_value') ?? '';
    final durationUnit = await SharedPrefsHelper.getString('duration_unit') ?? 'minutes';
    final imageUrl = await SharedPrefsHelper.getString('service_image_url') ?? '';

    final selectedEmployees = allEmployees
        .where((e) => data.selectedEmployeeEmails.contains(normalizeEmail(e.email)))
        .map((e) => _mapToEmployeeEntityModell(e))
        .toList();

    final departments = await SharedPrefsDepartmentsHelper.getDepartments();
    final approvalCycle = await SharedPrefsApprovalHelper.getApprovalCycle();

    return ServicesHistoryModel.createNew(
      id: '',
      state: "draft",
      status: "draft",
      serviceNameEnglish: nameEn,
      serviceNameArabic: nameAr,
      serviceDescriptionEnglish: descEn,
      serviceDescriptionArabic: descAr,
      durationOfServices: durationVal,
      selectedDurationUnit: durationUnit,
      imageUrl: imageUrl,
      providerServices: selectedEmployees,
      selectDepartment: departments,
      approvalCycle: approvalCycle,
      emailRequester: requesterEmail,
    );
  }

  // ==================== NAVIGATION & ACTIONS ====================

  Future<void> handleBackNavigation() async {
    // ✅ Guard: only proceed if in loaded state
    if (state is! ProviderSelectionLoaded) return;
    final currentState = state as ProviderSelectionLoaded;

    if (currentState.data.selectedEmployeeEmails.isNotEmpty) {
      await _saveSelectionToPrefsAndCubit();
    }

    await SharedPrefsHelper.setBool('is_returning_from_next_screen', true);

    // ✅ FIX: Emit nav state first, then immediately restore loaded state
    emit(const ProviderSelectionNavigateBack());
    emit(currentState); // ← This is the KEY fix — restores state for when user returns
  }

  Future<void> handleNextNavigation() async {
    // ✅ Guard: protect against wrong state
    if (state is! ProviderSelectionLoaded) return;
    final currentState = state as ProviderSelectionLoaded;
    final data = currentState.data;

    if (data.selectedEmployeeEmails.isEmpty) {
      emit(const ProviderSelectionShowWarning('pleaseSelectOneProviderAtLeast'));
      emit(currentState); // ✅ Restore after warning
      return;
    }

    try {

      await _saveSelectionToPrefsAndCubit();

      ServicesHistoryModel completeModel;

      if (data.docId != null && data.docId!.isNotEmpty) {

        final requesterEmail = employeeController.employeeEntity?.email ?? '';

        // 002: read the createServices doc via the repository.
        final docData = await servicesManagerCubit.repository
            .getCreateServiceDoc(data.docId!);

        if (docData != null) {
          completeModel = ServicesHistoryModel.fromJson(docData, data.docId);
        } else {
          // 002: fall back to the requester's services via the repository.
          final requesterServices = await servicesManagerCubit.repository
              .getServicesByRequesterEmail(requesterEmail);

          ServicesHistoryModel? foundModel;
          for (final m in requesterServices) {
            if (m.currentId == data.docId) {
              foundModel = m;
              break;
            }
          }

          if (foundModel != null) {
            completeModel = foundModel;
          } else {
            if (data.editingModel == null) {
              throw Exception("Document not found and no editing model available");
            }
            completeModel = data.editingModel!;
          }
        }
      } else {
        if (servicesManagerCubit.docService == null) {
          throw Exception("No service model available");
        }
        completeModel = servicesManagerCubit.docService!;
      }

      final selectedEmployees = currentState.allEmployees
          .where((e) => data.selectedEmployeeEmails.contains(normalizeEmail(e.email)))
          .map((e) => _mapToEmployeeEntityModell(e))
          .toList();

      final updatedModel = completeModel.copyWith(providerServices: selectedEmployees);
      servicesManagerCubit.docService = updatedModel;

      if (data.editProvider != null) {
        await _updateProviderInFirebase(data, selectedEmployees);
        // ✅ Restore state after edit provider firebase update
        emit(currentState);
        return;
      }

      // ✅ FIX: Emit nav state then restore loaded state
      emit(ProviderSelectionNavigateToDetails(
        completeModel: updatedModel,
        docId: data.docId,
      ));
      emit(currentState); // ← Restore so screen works if user presses back from next page

    } catch (e, stackTrace) {
      // ✅ Restore state on error
      emit(currentState);
      emit(ProviderSelectionError('An error occurred: ${e.toString()}'));
      // ✅ Restore again after error so screen isn't stuck
      emit(currentState.copyWith(
        data: currentState.data,
      ));
    }
  }

  Future<void> _updateProviderInFirebase(
      ProviderSelectionData data,
      List<EmployeeEntityModell> selectedEmployees,
      ) async {

    try {
      final requestId = data.editProvider!.currentId;

      // ✅ Encode provider list as JSON string (matches model's providerServices format)
      final providerJson = jsonEncode(
        selectedEmployees.map((e) => e.toJson()).toList(),
      );

      // 002: update the request doc via the repository, not Firestore directly.
      await servicesManagerCubit.repository.updateAssignedProvider(
        docId: requestId,
        providerEmail: selectedEmployees.first.email ?? '',
        providerJson: providerJson,
      );

      servicesManagerCubit.getAllServices();
      servicesManagerCubit.getMyRequestServices();

      emit(const ProviderSelectionProviderUpdated());

    } catch (e, stackTrace) {
      emit(ProviderSelectionError('Failed to update provider: ${e.toString()}'));
    }
  }

}
