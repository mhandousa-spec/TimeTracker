// ***************************** FILE INFO ***************************** //
// File Name: add_employee_state.dart
// Purpose: Defines immutable state for the add-employee flow controller.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'dart:io';

import '../../utils/add_employee_step.dart';
import '../../utils/employee_creation_failure.dart';

/// Describes the lifecycle state of the add-employee flow.
sealed class AddEmployeeFlowStatus {
  const AddEmployeeFlowStatus();

  static const initial = AddEmployeeFlowInitial();
  static const editing = AddEmployeeFlowEditing();
  static const reset = AddEmployeeFlowReset();
  static const submitting = AddEmployeeFlowSubmitting();
  static const success = AddEmployeeFlowSuccess();
  static const failure = AddEmployeeFlowFailure();
}

/// Indicates that the add-employee flow has just been created.
final class AddEmployeeFlowInitial extends AddEmployeeFlowStatus {
  const AddEmployeeFlowInitial();
}

/// Indicates that the add-employee flow contains user changes.
final class AddEmployeeFlowEditing extends AddEmployeeFlowStatus {
  const AddEmployeeFlowEditing();
}

/// Indicates that the add-employee flow has been reset.
final class AddEmployeeFlowReset extends AddEmployeeFlowStatus {
  const AddEmployeeFlowReset();
}

/// Indicates that employee files and records are being created.
final class AddEmployeeFlowSubmitting extends AddEmployeeFlowStatus {
  const AddEmployeeFlowSubmitting();
}

/// Indicates that employee creation and shared-data refresh succeeded.
final class AddEmployeeFlowSuccess extends AddEmployeeFlowStatus {
  const AddEmployeeFlowSuccess();
}

/// Indicates that employee creation or refresh failed.
final class AddEmployeeFlowFailure extends AddEmployeeFlowStatus {
  const AddEmployeeFlowFailure();
}

/// Immutable state published by [AddEmployeeCubit].
class AddEmployeeState {
  const AddEmployeeState({
    required this.currentStep,
    required this.status,
    required this.selectedLanguages,
    required this.profileImage,
    required this.failure,
    required this.createdEmployeeId,
    required this.isDirty,
  });

  factory AddEmployeeState.initial() {
    return const AddEmployeeState(
      currentStep: AddEmployeeStep.personalInformation,
      status: AddEmployeeFlowStatus.initial,
      selectedLanguages: [],
      profileImage: null,
      failure: null,
      createdEmployeeId: null,
      isDirty: false,
    );
  }

  final AddEmployeeStep currentStep;
  final AddEmployeeFlowStatus status;
  final List<String> selectedLanguages;
  final File? profileImage;
  final EmployeeCreationFailure? failure;
  final String? createdEmployeeId;
  final bool isDirty;

  /// Method Name: [copyWith]
  ///
  /// Purpose: Creates a state with only the supplied values changed.
  ///
  /// Parameters:
  /// - [currentStep]: Optional replacement active step.
  /// - [status]: Optional replacement flow status.
  /// - [selectedLanguages]: Optional replacement selected languages.
  /// - [profileImage]: Optional replacement profile image.
  /// - [clearProfileImage]: Whether to clear the current profile image.
  ///
  /// Returns: A new immutable flow state.
  AddEmployeeState copyWith({
    AddEmployeeStep? currentStep,
    AddEmployeeFlowStatus? status,
    List<String>? selectedLanguages,
    File? profileImage,
    bool clearProfileImage = false,
    EmployeeCreationFailure? failure,
    bool clearFailure = false,
    String? createdEmployeeId,
    bool clearCreatedEmployeeId = false,
    bool? isDirty,
  }) {
    return AddEmployeeState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      profileImage:
          clearProfileImage ? null : profileImage ?? this.profileImage,
      failure: clearFailure ? null : failure ?? this.failure,
      createdEmployeeId: clearCreatedEmployeeId
          ? null
          : createdEmployeeId ?? this.createdEmployeeId,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
