import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get/get.dart'; // Keep for .tr and dialogs
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_state.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/usecases/get_user_groups_use_case.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class FormsGroupCubit extends Cubit<FormsGroupState> {
  final GroupBaseRepository groupRepository;

  FormsGroupCubit({required this.groupRepository})
      : super(FormsGroupInitial()) {
    _initialize();
  }

  void _initialize() {
    emit(FormsGroupLoaded(
      groups: [],
      filteredGroups: [],
      persons: [],
      filteredPersons: [],
      selectedPersons: [],
      filteredSelectedPersons: [],
      searchController: TextEditingController(),
      department: S.current.all,
      descriptionController: TextEditingController(),
      groupNameController: TextEditingController(),
      createFormKey: GlobalKey<FormState>(),
    ));
  }

  /// Get filter list of departments
  List<String> getDepartments() {
    return [
      S.current.all.toLowerCase(),
      ...Get.find<MainCoreDepartmentCubit>().departmentModels.map((e) =>
      (Get.locale?.languageCode == 'en')
          ? FormatHelper.capitalize(e.departmentName!)
          : e.departmentNameInArabic!)
    ];
  }

  /// Reset controller variables
  void resetGroupController() {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    currentState.searchController.clear();
    currentState.descriptionController.clear();
    currentState.groupNameController.clear();

    emit(FormsGroupLoaded(
      groups: currentState.groups,
      filteredGroups: currentState.filteredGroups,
      persons: [],
      filteredPersons: [],
      selectedPersons: [],
      filteredSelectedPersons: [],
      searchController: currentState.searchController,
      department: S.current.all.toLowerCase(),
      selectedGroup: null,
      descriptionController: currentState.descriptionController,
      groupNameController: currentState.groupNameController,
      groupImage: null,
      createFormKey: currentState.createFormKey,
    ));
  }

  /// Get all persons entities
  void getPersonsEntities() {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    final persons = <PersonEntity>[];

    Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.forEach((element) {
      persons.add(PersonEntity.fromEmployeeEntity(element));
    });

    emit(currentState.copyWith(
      persons: persons,
      filteredPersons: List.from(persons),
    ));
  }

  /// Filter persons by department and search by text
  void search() {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    final value = currentState.searchController.text;

    applyDepartmentFilter();

    if (state is! FormsGroupLoaded) return;
    final updatedState = state as FormsGroupLoaded;

    final filteredPersons = List<PersonEntity>.from(updatedState.filteredPersons)
      ..removeWhere((element) =>
      !element.name.toLowerCase().contains(value.toLowerCase()));

    final filteredSelectedPersons =
    List<PersonEntity>.from(updatedState.filteredSelectedPersons)
      ..removeWhere((element) =>
      !element.name.toLowerCase().contains(value.toLowerCase()));

    emit(updatedState.copyWith(
      filteredPersons: filteredPersons,
      filteredSelectedPersons: filteredSelectedPersons,
    ));
  }

  /// Apply department filter
  void applyDepartmentFilter() {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    List<PersonEntity> filteredPersons = [];
    List<PersonEntity> filteredSelectedPersons = [];

    if (currentState.department.toLowerCase() == S.current.all.toLowerCase()) {
      filteredPersons = List.from(currentState.persons);
      filteredSelectedPersons = List.from(currentState.selectedPersons);
    } else {
      filteredPersons = currentState.persons
          .where((element) =>
      element.departmentName == currentState.department.toLowerCase())
          .toList();

      filteredSelectedPersons = currentState.selectedPersons
          .where((element) =>
      element.departmentName == currentState.department.toLowerCase())
          .toList();
    }

    emit(currentState.copyWith(
      filteredPersons: filteredPersons,
      filteredSelectedPersons: filteredSelectedPersons,
    ));
  }

  /// Update department filter
  void updateDepartment(String department) {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    emit(currentState.copyWith(department: department));
    applyDepartmentFilter();
  }

  /// Initialize create group screen
  void initCreateGroup() {
    resetGroupController();
    getPersonsEntities();
  }

  /// Toggle person selection
  void togglePersonSelection(int index) {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    final filteredPersons = List<PersonEntity>.from(currentState.filteredPersons);
    final selectedPersons = List<PersonEntity>.from(currentState.selectedPersons);
    final filteredSelectedPersons =
    List<PersonEntity>.from(currentState.filteredSelectedPersons);

    filteredPersons[index].isSelected = !filteredPersons[index].isSelected;

    if (filteredPersons[index].isSelected) {
      selectedPersons.add(filteredPersons[index]);
      filteredSelectedPersons.add(filteredPersons[index]);
    } else {
      selectedPersons.remove(filteredPersons[index]);
      filteredSelectedPersons.remove(filteredPersons[index]);
    }

    emit(currentState.copyWith(
      filteredPersons: filteredPersons,
      selectedPersons: selectedPersons,
      filteredSelectedPersons: filteredSelectedPersons,
    ));
  }

  /// Create new form group
  Future<Either<Failure, dynamic>> createGroup() async {
    if (state is! FormsGroupLoaded) {
      // Fixed: Use FeatureFailure with errMessage parameter
      return Left(FeatureFailure("Invalid state"));
    }

    final currentState = state as FormsGroupLoaded;

    showLoadingIndicator();
    Either<Failure, dynamic> result = await groupRepository.createGroup(
      groupName: currentState.groupNameController.text.trim(),
      description: currentState.descriptionController.text.trim(),
      selectedPersons: currentState.selectedPersons,
      image: currentState.groupImage?.path,
      currentUserId:
      Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
    );
    hideLoadingIndicator();

    if (result.isRight()) {
      await AppDialogs.groupCreatedSuccessfully(Get.context!);
      await getGroups();
    }
    return result;
  }

  /// Pick group image
  Future<void> pickGroupImage() async {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    final groupImage = await MediaPickerService().pickImageFile();

    emit(currentState.copyWith(groupImage: groupImage));
  }

  /// Get all groups
  /// Get all groups
  Future<void> getGroups() async {
    
    emit(FormsGroupLoading());

    // Get ALL available persons from MainCoreEmployeeController
    List<PersonEntity> availablePersons = [];

    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      if (employeeController.allEmployeesEntities != null) {
        availablePersons = employeeController.allEmployeesEntities!
            .map<PersonEntity>((e) => PersonEntity.fromEmployeeEntity(e)) // Add type parameter
            .toList();
        
      }
    } catch (e) {
      
    }

    List<PersonEntity> previousSelectedPersons = [];
    try {
      final shareCubit = Get.find<ShareCubit>();
      if (shareCubit.state is ShareLoaded) {
        final shareState = shareCubit.state as ShareLoaded;
        previousSelectedPersons = shareState.previousSelectedPersons;
        
      }
    } catch (e) {
      
    }

    Either<Failure, dynamic> result =
    await GetUserGroupsUseCase(groupRepository: groupRepository).execute(
      currentUserId:
      Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
      availablePersons: availablePersons,
      previousSelectedPersons: previousSelectedPersons,
    );

    if (result.isRight()) {
      final groups = result.getOrElse(() => <GroupEntity>[]);

      // Debug: Print member counts
      for (var group in groups) {
        
      }

      if (state is FormsGroupLoaded) {
        final currentState = state as FormsGroupLoaded;
        emit(currentState.copyWith(
          groups: groups,
          filteredGroups: List.from(groups),
        ));
      } else {
        // If we're coming from Loading state, create a new Loaded state
        emit(FormsGroupLoaded(
          groups: groups,
          filteredGroups: List.from(groups),
          persons: [],
          filteredPersons: [],
          selectedPersons: [],
          filteredSelectedPersons: [],
          searchController: TextEditingController(),
          department: S.current.all,
          descriptionController: TextEditingController(),
          groupNameController: TextEditingController(),
          createFormKey: GlobalKey<FormState>(),
        ));
      }
    } else {
      emit(FormsGroupError("Failed to load groups"));
    }
  }

  /// Select/deselect group
  // ── Group list search + sort (form bug report #36) ─────────────────────
  static const String sortNameAsc = 'Name (A-Z)';
  static const String sortNameDesc = 'Name (Z-A)';
  static const String sortMembers = 'Most Members';
  static const List<String> groupSortOptions = [
    sortNameAsc,
    sortNameDesc,
    sortMembers,
  ];

  static String groupSortLabel(String option) {
    final bool ar = Intl.getCurrentLocale().startsWith('ar');
    switch (option) {
      case sortNameAsc:
        return ar ? 'الاسم (أ-ي)' : option;
      case sortNameDesc:
        return ar ? 'الاسم (ي-أ)' : option;
      case sortMembers:
        return ar ? 'الأكثر أعضاءً' : option;
    }
    return option;
  }

  String groupQuery = '';
  String? groupSort;

  void searchGroups(String query) {
    groupQuery = query.trim().toLowerCase();
    _applyGroupView();
  }

  void sortGroups(String? option) {
    groupSort = option;
    _applyGroupView();
  }

  /// Rebuilds `filteredGroups` from `groups` using the current query + sort.
  void _applyGroupView() {
    if (state is! FormsGroupLoaded) return;
    final currentState = state as FormsGroupLoaded;
    final List<GroupEntity> view = currentState.groups
        .where((g) =>
            groupQuery.isEmpty ||
            g.groupName.toLowerCase().contains(groupQuery) ||
            g.groupDescription.toLowerCase().contains(groupQuery))
        .toList();
    switch (groupSort) {
      case sortNameAsc:
        view.sort((a, b) =>
            a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase()));
        break;
      case sortNameDesc:
        view.sort((a, b) =>
            b.groupName.toLowerCase().compareTo(a.groupName.toLowerCase()));
        break;
      case sortMembers:
        view.sort((a, b) => b.members.length.compareTo(a.members.length));
        break;
    }
    emit(currentState.copyWith(filteredGroups: view));
  }

  void selectGroup(GroupEntity group) {

    if (state is! FormsGroupLoaded) {
      
      return;
    }

    final currentState = state as FormsGroupLoaded;

    // Calculate new value once
    final newIsSelected = !group.isSelected;

    // Create new lists with updated entities
    final groups = currentState.groups.map((g) {
      if (g.groupId == group.groupId) {
        return g.copyWith(isSelected: newIsSelected);
      }
      return g;
    }).toList();

    final filteredGroups = currentState.filteredGroups.map((g) {
      if (g.groupId == group.groupId) {
        return g.copyWith(isSelected: newIsSelected);
      }
      return g;
    }).toList();

    emit(currentState.copyWith(
      groups: groups,
      filteredGroups: filteredGroups,
    ));

  }

  /// Select group members (for share cubit integration)
  /// This method works with ShareCubit to select all members of selected groups
  /// Select group members (for share cubit integration)
  /// Select group members (for share cubit integration)
  void selectGroupMembers(ShareCubit shareCubit) {

    if (state is! FormsGroupLoaded) {
      
      return;
    }

    final currentState = state as FormsGroupLoaded;

    shareCubit.clearSelectedPersons();

    int totalMembersSelected = 0;
    int selectedGroupsCount = 0;

    for (int i = 0; i < currentState.groups.length; i++) {
      final group = currentState.groups[i];

      

      if (group.isSelected) {
        selectedGroupsCount++;

        for (int j = 0; j < group.members.length; j++) {
          final person = group.members[j];
          
          shareCubit.selectPerson(person);
          totalMembersSelected++;
        }
      } else {
        
      }
    }

    

    
  }

  /// Check if group name exists
  bool isGroupNameExist(String groupName) {
    if (state is! FormsGroupLoaded) return false;

    final currentState = state as FormsGroupLoaded;
    for (GroupEntity group in currentState.groups) {
      if (groupName.toLowerCase() == group.groupName.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  /// Initialize group details screen
  void initGroupDetails(GroupEntity group) {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    currentState.searchController.clear();
    currentState.descriptionController.text = group.groupDescription;
    currentState.groupNameController.text = group.groupName;

    emit(currentState.copyWith(
      selectedGroup: group,
      persons: List.from(group.members),
      filteredPersons: List.from(group.members),
      clearGroupImage: true,
    ));
  }

  /// Delete group
  Future<void> deleteGroup() async {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    if (currentState.selectedGroup == null) return;

    await groupRepository.deleteGroup(
      userId: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
      groupId: currentState.selectedGroup!.groupId,
    );
    await getGroups();
  }

  /// Remove person from group
  void dropPerson(PersonEntity person) {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    final filteredPersons = List<PersonEntity>.from(currentState.filteredPersons)
      ..remove(person);
    final persons = List<PersonEntity>.from(currentState.persons)..remove(person);

    emit(currentState.copyWith(
      filteredPersons: filteredPersons,
      persons: persons,
    ));
  }

  /// Edit group
  Future<void> editGroup() async {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    if (currentState.selectedGroup == null) return;

    List<String> removedPersons = [];
    for (PersonEntity person in currentState.selectedGroup!.members) {
      if (!currentState.persons.contains(person)) {
        removedPersons.add(person.id);
      }
    }

    Either<Failure, dynamic> result = await groupRepository.editGroup(
      groupImage: currentState.groupImage?.path,
      groupName: currentState.groupNameController.text.trim(),
      description: currentState.descriptionController.text.trim(),
      groupId: currentState.selectedGroup!.groupId,
      removedPersons: removedPersons,
      currentUserId:
      Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
    );

    if (result.isRight()) {
      await AppDialogs.editingGroupSuccessfully(Get.context!);
      await getGroups();
    }
  }

  @override
  Future<void> close() {
    if (state is FormsGroupLoaded) {
      final currentState = state as FormsGroupLoaded;
      currentState.searchController.dispose();
      currentState.descriptionController.dispose();
      currentState.groupNameController.dispose();
    }
    return super.close();
  }
}