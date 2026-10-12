import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get/get.dart'; // Keep for .tr and dialogs
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/base_repository/share_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/notification_controller_cubit_main_core.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_state.dart';

class ShareCubit extends Cubit<ShareState> {
  final ShareBaseRepository shareRepository;

  ShareCubit({required this.shareRepository}) : super(ShareInitial()) {
    _initialize();
  }

  void _initialize() {
    emit(ShareLoaded(
      persons: [],
      filteredPersons: [],
      isEditPermission: false,
      previousSelectedPersons: [],
      filteredPreviousSelectedPersons: [],
      newSelectedPersons: [],
      filteredNewSelectedPersons: [],
      searchController: TextEditingController(),
      department: "All", // ✅ Initialize with "All"

    ));
  }

  /// Get all persons entities
  void getPersonsEntities() {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    final persons = <PersonEntity>[];

    Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.forEach((element) {
      persons.add(PersonEntity.fromEmployeeEntity(element));
    });

    emit(currentState.copyWith(persons: persons));
  }

  /// Toggle person selection
  void togglePersonSelection(int index, bool isPreviousSelected) {
    if (state is! ShareLoaded) return;
    if (isPreviousSelected) return;

    final currentState = state as ShareLoaded;
    final filteredPersons = List<PersonEntity>.from(currentState.filteredPersons);
    final newSelectedPersons = List<PersonEntity>.from(currentState.newSelectedPersons);

    filteredPersons[index].isSelected = !filteredPersons[index].isSelected;

    if (filteredPersons[index].isSelected) {
      newSelectedPersons.add(filteredPersons[index]);
    } else {
      newSelectedPersons.remove(filteredPersons[index]);
    }

    emit(currentState.copyWith(
      filteredPersons: filteredPersons,
      newSelectedPersons: newSelectedPersons,
    ));
  }

  /// Select form and load privacy settings
  Future<void> selectForm(FormEntity form) async {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    currentState.searchController.clear();

    // Reset state for new form
    emit(currentState.copyWith(
      isEditPermission: false,
      previousSelectedPersons: [],
      persons: [],
      clearTimeBegin: true,
      clearTimeEnd: true,
      clearDepartment: true,
      selectedForm: form,
    ));

    getPersonsEntities();
    await getFormPrivacy();
    search();
  }

  /// Get form privacy settings
  Future<void> getFormPrivacy() async {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    if (currentState.selectedForm == null) return;

    Either<Failure, dynamic> result =
    await shareRepository.getFormPrivacy(currentState.selectedForm!.id);

    if (result.isLeft()) {
      return;
    }

    final formPrivacyModel = result.getOrElse(() => null) as FormPrivacyModel?;
    if (formPrivacyModel == null) {
      emit(currentState.copyWith(formPrivacyModel: formPrivacyModel));
      return;
    }

    // Update persons with previous selections
    final persons = List<PersonEntity>.from(currentState.persons);
    final previousSelectedPersons = <PersonEntity>[];

    for (int i = 0; i < persons.length; i++) {
      if (formPrivacyModel.usersModel!.emails!.contains(persons[i].id)) {
        persons[i].isSelected = true;
        previousSelectedPersons.add(persons[i]);
      }
    }

    // Remove previously selected persons from main list
    for (var person in previousSelectedPersons) {
      persons.remove(person);
    }

    emit(currentState.copyWith(
      formPrivacyModel: formPrivacyModel,
      persons: persons,
      previousSelectedPersons: previousSelectedPersons,
    ));
  }

  /// Search persons
  void search() {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    final value = currentState.searchController.text;

    applyDepartmentFilter();

    if (state is! ShareLoaded) return;
    final updatedState = state as ShareLoaded;

    final filteredPersons = List<PersonEntity>.from(updatedState.filteredPersons)
      ..removeWhere((element) =>
      !element.name.toLowerCase().contains(value.toLowerCase()));

    final filteredPreviousSelectedPersons =
    List<PersonEntity>.from(updatedState.filteredPreviousSelectedPersons)
      ..removeWhere((element) =>
      !element.name.toLowerCase().contains(value.toLowerCase()));

    emit(updatedState.copyWith(
      filteredPersons: filteredPersons,
      filteredPreviousSelectedPersons: filteredPreviousSelectedPersons,
    ));
  }

  /// Apply department filter
  void applyDepartmentFilter() {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    List<PersonEntity> filteredPersons = [];
    List<PersonEntity> filteredPreviousSelectedPersons = [];

    if (currentState.department == null ||
        currentState.department!.toLowerCase() == "all") {
      // ✅ Show all persons when no filter or "All" is selected
      filteredPersons = List.from(currentState.persons);
      filteredPreviousSelectedPersons =
          List.from(currentState.previousSelectedPersons);
    } else {
      // ✅ Filter by department using case-insensitive comparison
      filteredPersons = currentState.persons
          .where((element) =>
      element.departmentName.toLowerCase() ==
          currentState.department!.toLowerCase())
          .toList();

      filteredPreviousSelectedPersons = currentState.previousSelectedPersons
          .where((element) =>
      element.departmentName.toLowerCase() ==
          currentState.department!.toLowerCase())
          .toList();
    }

    emit(currentState.copyWith(
      filteredPersons: filteredPersons,
      filteredPreviousSelectedPersons: filteredPreviousSelectedPersons,
    ));
  }

  /// Update department filter
  void updateDepartment(String? department) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    emit(currentState.copyWith(
      department: department,
      clearDepartment: department == null,
    ));
    applyDepartmentFilter();
  }

  /// Search new selected persons
  void newSelectedSearch(String query) {
    if (state is! ShareLoaded) {
      
      return;
    }

    final currentState = state as ShareLoaded;

    

    if (query.isEmpty) {
      // When search is empty, show ALL newSelectedPersons

      final newFiltered = List<PersonEntity>.from(currentState.newSelectedPersons);

      emit(currentState.copyWith(
        filteredNewSelectedPersons: newFiltered,
      ));

      // Verify after emit
      if (state is ShareLoaded) {
        final afterState = state as ShareLoaded;
        
        if (afterState.filteredNewSelectedPersons.isNotEmpty) {
          
        }
      }
    } else {
      // Filter based on search query
      final filtered = currentState.newSelectedPersons.where((person) {
        return person.name.toLowerCase().contains(query.toLowerCase()) ||
            person.departmentName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      emit(currentState.copyWith(
        filteredNewSelectedPersons: filtered,
      ));
    }
  }

  /// Update edit permission
  void updateEditPermission(bool value) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    emit(currentState.copyWith(isEditPermission: value));
  }

  /// Update time begin
  void updateTimeBegin(DateTime? time) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    emit(currentState.copyWith(
      timeBegin: time,
      clearTimeBegin: time == null,
    ));
  }

  /// Update time end
  void updateTimeEnd(DateTime? time) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    emit(currentState.copyWith(
      timeEnd: time,
      clearTimeEnd: time == null,
    ));
  }

  /// Grant access to selected persons
  /// Grant access to selected persons
  /// Grant access to selected persons
  Future<void> grantAccess() async {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;

    // Safety net only — ShareAccessDialog validates these and shows the
    // message under the field before it ever calls grantAccess. No snackbar
    // here: messages go through the app's dialogs, never Get.snackbar.
    if (currentState.newSelectedPersons.isEmpty ||
        currentState.timeBegin == null ||
        currentState.timeEnd == null) {
      return;
    }

    if (currentState.formPrivacyModel == null) {
      
      return;
    }

    if (currentState.selectedForm == null) {
      
      return;
    }

    // All validation passed, proceed with granting access
    Either<Failure, dynamic> result = await shareRepository.grantAccess(
      formPrivacyModel: currentState.formPrivacyModel!,
      formId: currentState.selectedForm!.id,
      persons: currentState.newSelectedPersons,
      timeBegin: currentState.timeBegin!,
      timeEnd: currentState.timeEnd!,
      isEditPermission: currentState.isEditPermission,
    );

    if (result.isRight()) {
      Get.back(); // Close the screen/dialog after success
      await AppDialogs.grantFormAccessSuccessfully(Get.context!);

      NotificationControllerCubit().sendNotification(
        title: "A New Form ${currentState.selectedForm!.formHeadModel.title} Has Been Sent to You",
        arabicTitle: "تم إرسال نموذج جديد إليك ${currentState.selectedForm!.formHeadModel.arTitle}",
        body: "You've received a new form ${currentState.selectedForm!.formHeadModel.title} that requires your attention.",
        arabicBody: "لقد تلقيت نموذجًا جديدًا ${currentState.selectedForm!.formHeadModel.arTitle} يتطلب انتباهك.",
        type: "formBuilder",
        emails: currentState.newSelectedPersons.map((e) => e.id).toList(),
      );
    } else {
      // Handle error
      final failure = result.fold((l) => l, (r) => null);
      
      final ctx = Get.context;
      if (ctx != null) {
        CustomDialogManager.showMessage(
          context: ctx,
          lottiePath: AppAssets.lottieWarning,
          title: 'Error',
          subtitle:
              'Failed to grant access: ${failure?.errMessage ?? "Unknown error"}',
        );
      }
    }
  }

  /// Clear selected persons
  void clearSelectedPersons() {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    final newSelectedPersons = List<PersonEntity>.from(currentState.newSelectedPersons);

    for (var person in newSelectedPersons) {
      person.isSelected = false;
    }

    emit(currentState.copyWith(
      newSelectedPersons: [],
      filteredNewSelectedPersons: [],
    ));
  }

  /// Select a person programmatically (used by group selection)
  /// Select a person programmatically (used by group selection)
  /// Select a person programmatically (used by group selection)
  void selectPerson(PersonEntity person) {

    if (state is! ShareLoaded) {

      return;
    }

    final currentState = state as ShareLoaded;

    

    // Check if already selected
    final alreadyInNew = currentState.newSelectedPersons.any((p) => p.id == person.id);
    final alreadyInPrevious = currentState.previousSelectedPersons.any((p) => p.id == person.id);

    

    if (alreadyInNew) {

      return;
    }

    if (alreadyInPrevious) {

      return;
    }

    person.isSelected = true;
    final newSelectedPersons = List<PersonEntity>.from(currentState.newSelectedPersons)
      ..add(person);
    final filteredNewSelectedPersons =
    List<PersonEntity>.from(currentState.filteredNewSelectedPersons)..add(person);

    

    emit(currentState.copyWith(
      newSelectedPersons: newSelectedPersons,
      filteredNewSelectedPersons: filteredNewSelectedPersons,
    ));

    
  }

  @override
  Future<void> close() {
    if (state is ShareLoaded) {
      final currentState = state as ShareLoaded;
      currentState.searchController.dispose();
    }
    return super.close();
  }
}