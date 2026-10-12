// ***************************** FILE INFO ***************************** //
// File Name: add_employee_cubit.dart
// Purpose: Coordinates navigation and shared state for add-employee pages.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/helper/main_helper/phone_number.dart';
import '../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../data/repository/employee_repository.dart';
import '../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../utils/add_employee_step.dart';
import '../../utils/add_employee_document_type.dart';
import '../../utils/employee_creation_failure.dart';
import '../../utils/employee_update_payload.dart';
import '../../utils/employee_update_failure.dart';
import '../../../h2_employees/domain/entity/employee_details_view_data.dart';
import 'add_employee_controllers_mixin.dart';
import 'add_employee_state.dart';

/// Coordinates the shared resources and step navigation for add employees.
class AddEmployeeCubit extends Cubit<AddEmployeeState>
    with AddEmployeeControllersMixin {
  AddEmployeeCubit({
    EmployeeRepository? repository,
    HrModuleDataCubit? hrModuleDataCubit,
  })  : _repository = repository,
        _hrModuleDataCubit = hrModuleDataCubit,
        super(AddEmployeeState.initial());

  final EmployeeRepository? _repository;
  final HrModuleDataCubit? _hrModuleDataCubit;

  /// Whether this controller is serving an existing employee edit flow.
  bool isEditMode = false;

  final Map<AddEmployeeStep, Map<String, dynamic>> _editBaseline = {};

  /// Method Name: [goToStep]
  ///
  /// Purpose: Selects a valid flow step and synchronizes the page controller.
  ///
  /// Parameters:
  /// - [step]: The requested add-employee step.
  /// - [animate]: Whether attached pages should animate to the step.
  ///
  /// Returns: A future completed after any requested page transition.
  Future<void> goToStep(
    AddEmployeeStep step, {
    bool animate = true,
  }) async {
    currentStepIndex = step.index;
    emit(state.copyWith(
      currentStep: step,
      status: AddEmployeeFlowStatus.editing,
      isDirty: isEditMode ? hasChangesForStep(step) : state.isDirty,
    ));

    if (!pageController.hasClients) return;
    if (animate) {
      await pageController.animateToPage(
        step.index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      pageController.jumpToPage(step.index);
    }
  }

  /// Method Name: [goToIndex]
  ///
  /// Purpose: Resolves an index safely before selecting its flow step.
  ///
  /// Parameters:
  /// - [index]: The requested zero-based step index.
  /// - [animate]: Whether attached pages should animate to the step.
  ///
  /// Returns: A future completed after any requested page transition.
  Future<void> goToIndex(int index, {bool animate = true}) {
    return goToStep(
      AddEmployeeStep.fromIndex(index),
      animate: animate,
    );
  }

  /// Method Name: [goToNextStep]
  ///
  /// Purpose: Advances to the next step when one is available.
  ///
  /// Returns: A future completed after the optional page transition.
  Future<void> goToNextStep() {
    final nextIndex = currentStepIndex + 1;
    if (nextIndex >= AddEmployeeStep.values.length) return Future.value();
    return goToIndex(nextIndex);
  }

  /// Method Name: [goToPreviousStep]
  ///
  /// Purpose: Returns to the previous step when one is available.
  ///
  /// Returns: A future completed after the optional page transition.
  Future<void> goToPreviousStep() {
    final previousIndex = currentStepIndex - 1;
    if (previousIndex < 0) return Future.value();
    return goToIndex(previousIndex);
  }

  /// Method Name: [validateCurrentStep]
  ///
  /// Purpose: Validates the form registered for the active step.
  ///
  /// Returns: Whether the current step is valid or has no mounted form yet.
  bool validateCurrentStep() {
    return stepFormKeys[currentStepIndex].currentState?.validate() ?? true;
  }

  /// Method Name: [canAdvanceCurrentStep]
  ///
  /// Purpose: Determines whether the active step has every required value
  /// needed to activate its Next action.
  ///
  /// Returns: Whether the current step can be advanced for completion checks.
  bool get canAdvanceCurrentStep {
    switch (AddEmployeeStep.fromIndex(currentStepIndex)) {
      case AddEmployeeStep.personalInformation:
        return _controllersHaveValues([
          firstNameController,
          middleNameController,
          lastNameController,
          firstNameArabicController,
          middleNameArabicController,
          lastNameArabicController,
          genderController,
        ]);
      case AddEmployeeStep.contactDetails:
        return _controllersHaveValues([
          mobileNumberController,
          emailController,
          businessEmailController,
        ]);
      case AddEmployeeStep.addressDetails:
        return _controllersHaveValues([
          countryController,
          provinceController,
          cityController,
          streetController,
          postalCodeController,
        ]);
      case AddEmployeeStep.identificationDetails:
        return _controllersHaveValues([
              nationalIdController,
              nationalIdExpirationDateController,
            ]) &&
            nationalIdFrontDocument != null &&
            nationalIdBackDocument != null;
      case AddEmployeeStep.positionDetails:
        return _controllersHaveValues([
          employeeIdController,
          titleController,
          departmentIdController,
          jobTypeController,
          workArrangementController,
          remoteStatusController,
          workLocationController,
          employeeGradeController,
          startDateController,
          startTimeController,
          endTimeController,
          daysOffController,
          salaryController,
          currencyController,
        ]);
      case AddEmployeeStep.certificationDetails:
      case AddEmployeeStep.insuranceDetails:
      case AddEmployeeStep.emergencyDetails:
        return true;
    }
  }

  /// Method Name: [validateAllSteps]
  ///
  /// Purpose: Revalidates every mounted form before persistence begins.
  ///
  /// Returns: Whether every employee step remains valid.
  bool validateAllSteps() => findFirstInvalidStep() == null;

  /// Method Name: [findFirstInvalidStep]
  ///
  /// Purpose: Finds the earliest mounted form that fails validation.
  ///
  /// Returns: The invalid zero-based step index, or null when all steps pass.
  int? findFirstInvalidStep() {
    for (var index = 0; index < stepFormKeys.length; index++) {
      final form = stepFormKeys[index].currentState;
      if (form != null && !form.validate()) return index;
    }
    return null;
  }

  /// Method Name: [submitEmployee]
  ///
  /// Purpose: Creates the employee and refreshes shared employee data.
  ///
  /// Returns: Completes after validation, persistence, and optional refresh.
  Future<void> submitEmployee() async {
    if (state.status is AddEmployeeFlowSubmitting) return;

    final invalidStep = findFirstInvalidStep();
    if (invalidStep != null) {
      await goToIndex(invalidStep, animate: false);
      return;
    }

    emit(state.copyWith(
      status: AddEmployeeFlowStatus.submitting,
      clearFailure: true,
      clearCreatedEmployeeId: true,
      isDirty: false,
    ));
    final repository = _repository ?? EmployeeRepository();
    final result = await repository.createEmployee(
      buildEmployeeEntity(),
      selectedLanguages: selectedLanguages,
      profileImagePath: profileImage?.path,
      passportDocumentPath: passportDocument?.path,
      nationalIdFrontDocumentPath: nationalIdFrontDocument?.path,
      nationalIdBackDocumentPath: nationalIdBackDocument?.path,
      drivingLicenseDocumentPath: drivingLicenseDocument?.path,
      certificationDocumentPath: certificationDocument?.path,
    );
    await result.fold(
      (failure) async => emit(state.copyWith(
        status: AddEmployeeFlowStatus.failure,
        failure: failure,
      )),
      (employeeId) async => _refreshCreatedEmployee(employeeId),
    );
  }

  /// Method Name: [buildEmployeeEntity]
  ///
  /// Purpose: Detaches current form values from mutable UI controllers.
  ///
  /// Returns: The normalized entity ready for repository persistence mapping.
  HrEmployeeEntity buildEmployeeEntity() {
    String value(TextEditingController controller) => controller.text.trim();
    return HrEmployeeEntity(
      id: value(employeeIdController),
      firstName: value(firstNameController),
      middleName: value(middleNameController),
      lastName: value(lastNameController),
      firstNameInArabic: value(firstNameArabicController),
      middleNameInArabic: value(middleNameArabicController),
      lastNameInArabic: value(lastNameArabicController),
      nationalId: value(nationalIdController),
      nationalIdExpirationDate: value(nationalIdExpirationDateController),
      nationality: value(nationalityController),
      passport: value(passportController),
      passportExpirationDate: value(passportExpirationDateController),
      email: value(businessEmailController),
      personalEmail: value(emailController),
      mobilePhone: _phone(
          value(mobileNumberController), value(mobileCountryCodeController)),
      homePhoneNumber:
          _phone(value(homeNumberController), value(homeCountryCodeController)),
      officePhoneNumber: _phone(
          value(officeNumberController), value(officeCountryCodeController)),
      extension: value(extensionController),
      birthDay: value(birthDayController),
      gender: value(genderController),
      country: value(countryController),
      province: value(provinceController),
      city: value(cityController),
      postalCode: value(postalCodeController),
      street: value(streetController),
      maritalStatus: value(maritalStatusController),
      language: selectedLanguages.join(', '),
      departmentId: value(departmentIdController),
      title: value(titleController),
      workLocation: value(workLocationController),
      drivingLicenseId: value(drivingLicenseIdController),
      carPlates: value(carPlatesController)
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      jobType: value(jobTypeController),
      workArrangement: value(workArrangementController),
      remoteStatus: value(remoteStatusController),
      employeeGrade: value(employeeGradeController),
      startDate: value(startDateController),
      startTime: value(startTimeController),
      endTime: value(endTimeController),
      daysOff: value(daysOffController),
      salary: value(salaryController),
      currency: value(currencyController),
      institutionName: value(institutionNameController),
      degree: value(degreeController),
      fieldOfStudy: value(fieldOfStudyController),
      certificationStartDate: value(certificationStartDateController),
      certificationEndDate: value(certificationEndDateController),
      gradeOrScore: value(gradeOrScoreController),
      certificateId: value(certificateIdController),
      issuingAuthority: value(issuingAuthorityController),
      certificationNotes: value(certificationNotesController),
      insuranceName: value(insuranceNameController),
      insurancePolicyNumber: value(insurancePolicyNumberController),
      insuranceProviderContact: value(insuranceProviderContactController),
      firstContactFirstName: value(firstEmergencyFirstNameController),
      firstContactLastName: value(firstEmergencyLastNameController),
      firstContactFirstNameArabic:
          value(firstEmergencyFirstNameArabicController),
      firstContactLastNameArabic: value(firstEmergencyLastNameArabicController),
      firstContactRelationship: value(firstEmergencyRelationshipController),
      firstContactEmail: value(firstEmergencyEmailController),
      firstContactPhone: value(firstEmergencyMobileController),
      firstContactLanguage: value(firstEmergencyLanguageController),
      firstContactCountry: value(firstEmergencyCountryController),
      firstContactProvince: value(firstEmergencyProvinceController),
      firstContactCity: value(firstEmergencyCityController),
      firstContactStreet: value(firstEmergencyStreetController),
      secondContactFirstName: value(secondEmergencyFirstNameController),
      secondContactLastName: value(secondEmergencyLastNameController),
      secondContactFirstNameArabic:
          value(secondEmergencyFirstNameArabicController),
      secondContactLastNameArabic:
          value(secondEmergencyLastNameArabicController),
      secondContactRelationship: value(secondEmergencyRelationshipController),
      secondContactEmail: value(secondEmergencyEmailController),
      secondContactPhone: value(secondEmergencyMobileController),
      secondContactLanguage: value(secondEmergencyLanguageController),
      secondContactCountry: value(secondEmergencyCountryController),
      secondContactProvince: value(secondEmergencyProvinceController),
      secondContactCity: value(secondEmergencyCityController),
      secondContactStreet: value(secondEmergencyStreetController),
    );
  }

  PhoneNumber? _phone(String number, String countryCode) =>
      number.isEmpty && countryCode.isEmpty
          ? null
          : PhoneNumber(
              countryISOCode: '', number: number, countryCode: countryCode);

  /// Method Name: [initializeForEdit]
  ///
  /// Purpose: Hydrates the shared add-employee controls for an existing employee.
  ///
  /// Parameters:
  /// - [data]: Employee profile and supplemental details loaded by HR.
  ///
  /// Returns: Emits an editable state containing the existing values.
  void initializeForEdit(EmployeeDetailsViewData data) {
    isEditMode = true;
    final employee = data.employee;
    void set(TextEditingController controller, String? value) {
      controller.text = value?.trim() ?? '';
    }

    set(employeeIdController, employee.id);
    set(firstNameController, employee.firstName);
    set(middleNameController, employee.middleName);
    set(lastNameController, employee.lastName);
    set(firstNameArabicController, employee.firstNameInArabic);
    set(middleNameArabicController, employee.middleNameInArabic);
    set(lastNameArabicController, employee.lastNameInArabic);
    set(nationalIdController, employee.nationalId);
    set(nationalIdExpirationDateController, employee.nationalIdExpirationDate);
    set(nationalityController, employee.nationality);
    set(passportController, employee.passport);
    set(passportExpirationDateController, employee.passportExpirationDate);
    set(emailController, employee.personalEmail);
    set(businessEmailController, employee.email);
    set(mobileNumberController, employee.mobilePhone?.number);
    set(mobileCountryCodeController, employee.mobilePhone?.countryCode);
    set(homeNumberController, employee.homePhone);
    set(homeCountryCodeController,
        _latest(data.contactDetails?.homeCountryCode));
    set(officeNumberController, employee.officePhone);
    set(officeCountryCodeController,
        _latest(data.contactDetails?.officeCountryCode));
    set(extensionController, employee.extension);
    set(birthDayController, employee.birthDay);
    set(genderController, employee.gender);
    set(countryController, employee.country);
    set(provinceController, employee.province);
    set(cityController, employee.city);
    set(postalCodeController, employee.postalCode);
    set(streetController, employee.street);
    set(maritalStatusController, employee.maritalStatus);
    set(departmentIdController, employee.departmentId);
    set(supervisorController, employee.supervisor);
    set(roleController, employee.role);
    set(titleController, employee.title);
    set(titleArabicController, employee.titleInArabic);
    set(workLocationController, employee.workLocation);
    set(drivingLicenseIdController, employee.drivingLicenseId);
    set(carPlatesController, employee.carPlates?.join(', '));
    set(jobTypeController, employee.jobType);
    set(workArrangementController, employee.workArrangement);
    set(remoteStatusController, employee.remoteStatus);
    set(employeeGradeController, employee.employeeGrade);
    set(startDateController, employee.startDate);
    set(startTimeController, employee.startTime);
    set(endTimeController, employee.endTime);
    set(daysOffController, employee.daysOff);
    set(salaryController, employee.salary);
    set(currencyController, employee.currency);
    set(
        institutionNameController,
        employee.institutionName ??
            _latest(data.certificationDetails?.institutionName));
    set(degreeController,
        employee.degree ?? _latest(data.certificationDetails?.degree));
    set(
        fieldOfStudyController,
        employee.fieldOfStudy ??
            _latest(data.certificationDetails?.fieldOfStudy));
    set(
        certificationStartDateController,
        employee.certificationStartDate ??
            _latest(data.certificationDetails?.startDate));
    set(
        certificationEndDateController,
        employee.certificationEndDate ??
            _latest(data.certificationDetails?.endDate));
    set(
        gradeOrScoreController,
        employee.gradeOrScore ??
            _latest(data.certificationDetails?.gradeOrScore));
    set(
        certificateIdController,
        employee.certificateId ??
            _latest(data.certificationDetails?.certificateId));
    set(
        issuingAuthorityController,
        employee.issuingAuthority ??
            _latest(data.certificationDetails?.issuingAuthority));
    set(
        certificationNotesController,
        employee.certificationNotes ??
            _latest(data.certificationDetails?.notes));
    set(insuranceNameController, employee.insuranceName);
    set(insurancePolicyNumberController, employee.insurancePolicyNumber);
    set(
        insuranceProviderContactController,
        employee.insuranceProviderContact ??
            _latest(data.insuranceDetails?.providerContact));
    _hydrateEmergency(employee);
    selectedLanguages = (employee.language ?? '')
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    _editBaseline
      ..clear()
      ..addEntries(AddEmployeeStep.values.map(
        (step) => MapEntry(step, _currentEditSnapshot(step)),
      ));
    emit(state.copyWith(
      selectedLanguages: selectedLanguages,
      status: AddEmployeeFlowStatus.editing,
      isDirty: false,
    ));
  }

  /// Method Name: [_hydrateEmergency]
  ///
  /// Purpose: Copies emergency-contact values into the shared form controls.
  void _hydrateEmergency(HrEmployeeEntity employee) {
    void set(TextEditingController controller, String? value) =>
        controller.text = value?.trim() ?? '';
    set(firstEmergencyFirstNameController, employee.firstContactFirstName);
    set(firstEmergencyLastNameController, employee.firstContactLastName);
    set(firstEmergencyFirstNameArabicController,
        employee.firstContactFirstNameArabic);
    set(firstEmergencyLastNameArabicController,
        employee.firstContactLastNameArabic);
    set(firstEmergencyRelationshipController,
        employee.firstContactRelationship);
    set(firstEmergencyEmailController, employee.firstContactEmail);
    set(firstEmergencyMobileController, employee.firstContactPhone);
    set(firstEmergencyLanguageController, employee.firstContactLanguage);
    set(firstEmergencyCountryController, employee.firstContactCountry);
    set(firstEmergencyProvinceController, employee.firstContactProvince);
    set(firstEmergencyCityController, employee.firstContactCity);
    set(firstEmergencyStreetController, employee.firstContactStreet);
    set(secondEmergencyFirstNameController, employee.secondContactFirstName);
    set(secondEmergencyLastNameController, employee.secondContactLastName);
    set(secondEmergencyFirstNameArabicController,
        employee.secondContactFirstNameArabic);
    set(secondEmergencyLastNameArabicController,
        employee.secondContactLastNameArabic);
    set(secondEmergencyRelationshipController,
        employee.secondContactRelationship);
    set(secondEmergencyEmailController, employee.secondContactEmail);
    set(secondEmergencyMobileController, employee.secondContactPhone);
    set(secondEmergencyLanguageController, employee.secondContactLanguage);
    set(secondEmergencyCountryController, employee.secondContactCountry);
    set(secondEmergencyProvinceController, employee.secondContactProvince);
    set(secondEmergencyCityController, employee.secondContactCity);
    set(secondEmergencyStreetController, employee.secondContactStreet);
  }

  /// Method Name: [buildUpdatePayload]
  ///
  /// Purpose: Converts the selected form section into a typed update payload.
  ///
  /// Parameters:
  /// - [section]: Section currently being edited.
  ///
  /// Returns: Normalized values for the repository update boundary.
  EmployeeUpdatePayload buildUpdatePayload(AddEmployeeStep section) {
    String value(TextEditingController controller) => controller.text.trim();
    final values = <String, dynamic>{};
    void add(String key, TextEditingController controller) =>
        values[key] = value(controller);
    void addAll(Map<String, TextEditingController> fields) =>
        fields.forEach(add);
    switch (section) {
      case AddEmployeeStep.personalInformation:
        addAll({
          'First_Name': firstNameController,
          'Middle_Name': middleNameController,
          'Last_Name': lastNameController,
          'First_Name_In_Arabic': firstNameArabicController,
          'Middle_Name_In_Arabic': middleNameArabicController,
          'Last_Name_In_Arabic': lastNameArabicController,
          'Gender': genderController,
          'Birth_Day': birthDayController,
          'Marital_Status': maritalStatusController,
          'Nationality': nationalityController,
          'Language': languageController
        });
        values['Language'] = selectedLanguages.join(', ');
      case AddEmployeeStep.contactDetails:
        addAll({
          'Email': businessEmailController,
          'Personal_Email': emailController,
          'Home_Phone': homeNumberController,
          'Office_Phone': officeNumberController,
          'Extension': extensionController,
          'Home_Country_Code': homeCountryCodeController,
          'Office_Country_Code': officeCountryCodeController
        });
        values['Mobile_Phone'] = {
          'number': value(mobileNumberController),
          'countryCode': value(mobileCountryCodeController)
        };
      case AddEmployeeStep.addressDetails:
        addAll({
          'Country': countryController,
          'Province': provinceController,
          'City': cityController,
          'Postal_Code': postalCodeController,
          'Street': streetController
        });
      case AddEmployeeStep.identificationDetails:
        addAll({
          'National_Id': nationalIdController,
          'National_Id_Expiration_Date': nationalIdExpirationDateController,
          'Passport': passportController,
          'Passport_Expiration_Date': passportExpirationDateController,
          'Driving_License_Id': drivingLicenseIdController,
          'Car_Plates': carPlatesController
        });
      case AddEmployeeStep.positionDetails:
        addAll({
          'Department_Id': departmentIdController,
          'Supervisor': supervisorController,
          'Role': roleController,
          'Title': titleController,
          'Title_In_Arabic': titleArabicController,
          'Work_Location': workLocationController,
          'Job_Type': jobTypeController,
          'Work_Arrangement': workArrangementController,
          'Remote_Status': remoteStatusController,
          'Employee_Grade': employeeGradeController,
          'Start_Date': startDateController,
          'Start_Time': startTimeController,
          'End_Time': endTimeController,
          'Days_Off': daysOffController,
          'Salary': salaryController,
          'Currency': currencyController
        });
      case AddEmployeeStep.certificationDetails:
        addAll({
          'Institution_Name': institutionNameController,
          'Degree': degreeController,
          'Field_Of_Study': fieldOfStudyController,
          'Certification_Start_Date': certificationStartDateController,
          'Certification_End_Date': certificationEndDateController,
          'Grade_Or_Score': gradeOrScoreController,
          'Certificate_Id': certificateIdController,
          'Issuing_Authority': issuingAuthorityController,
          'Certification_Notes': certificationNotesController
        });
      case AddEmployeeStep.insuranceDetails:
        addAll({
          'Insurance_Name': insuranceNameController,
          'Insurance_Policy_Number': insurancePolicyNumberController,
          'Provider_Contact': insuranceProviderContactController
        });
      case AddEmployeeStep.emergencyDetails:
        addAll({
          'First_Contact_First_Name': firstEmergencyFirstNameController,
          'First_Contact_Last_Name': firstEmergencyLastNameController,
          'First_Contact_First_Name_Arabic':
              firstEmergencyFirstNameArabicController,
          'First_Contact_Last_Name_Arabic':
              firstEmergencyLastNameArabicController,
          'First_Contact_Relationship': firstEmergencyRelationshipController,
          'First_Contact_Email': firstEmergencyEmailController,
          'First_Contact_Phone': firstEmergencyMobileController,
          'First_Contact_Language': firstEmergencyLanguageController,
          'First_Contact_Country': firstEmergencyCountryController,
          'First_Contact_Province': firstEmergencyProvinceController,
          'First_Contact_City': firstEmergencyCityController,
          'First_Contact_Street': firstEmergencyStreetController,
          'Second_Contact_First_Name': secondEmergencyFirstNameController,
          'Second_Contact_Last_Name': secondEmergencyLastNameController,
          'Second_Contact_First_Name_Arabic':
              secondEmergencyFirstNameArabicController,
          'Second_Contact_Last_Name_Arabic':
              secondEmergencyLastNameArabicController,
          'Second_Contact_Relationship': secondEmergencyRelationshipController,
          'Second_Contact_Email': secondEmergencyEmailController,
          'Second_Contact_Phone': secondEmergencyMobileController,
          'Second_Contact_Language': secondEmergencyLanguageController,
          'Second_Contact_Country': secondEmergencyCountryController,
          'Second_Contact_Province': secondEmergencyProvinceController,
          'Second_Contact_City': secondEmergencyCityController,
          'Second_Contact_Street': secondEmergencyStreetController
        });
    }
    return EmployeeUpdatePayload(
        employeeId: value(employeeIdController),
        section: section,
        values: values,
        profileImage: profileImage,
        passportDocument: passportDocument,
        nationalIdFrontDocument: nationalIdFrontDocument,
        nationalIdBackDocument: nationalIdBackDocument,
        drivingLicenseDocument: drivingLicenseDocument,
        certificationDocument: certificationDocument);
  }

  /// Method Name: [saveEmployeeUpdate]
  ///
  /// Purpose: Validates and persists the selected editable employee section.
  ///
  /// Parameters:
  /// - [section]: Section currently displayed by the edit page.
  ///
  /// Returns: A failure when validation or persistence fails, otherwise null.
  Future<EmployeeUpdateFailure?> saveEmployeeUpdate(
    AddEmployeeStep section,
  ) async {
    if (!validateCurrentStep()) {
      return const EmployeeUpdateValidationFailure();
    }
    emit(state.copyWith(status: AddEmployeeFlowStatus.submitting));
    final result = await (_repository ?? EmployeeRepository()).updateEmployee(
      buildUpdatePayload(section),
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(status: AddEmployeeFlowStatus.failure));
        return failure;
      },
      (_) {
        _editBaseline[section] = _currentEditSnapshot(section);
        emit(state.copyWith(
          status: AddEmployeeFlowStatus.success,
          isDirty: false,
        ));
        return null;
      },
    );
  }

  String? _latest(List<String>? values) {
    if (values == null) return null;
    for (final value in values.reversed) {
      if (value.trim().isNotEmpty) return value;
    }
    return null;
  }

  /// Method Name: [getStepProgress]
  ///
  /// Purpose: Calculates the completed visible-item ratio for one flow step.
  ///
  /// Parameters:
  /// - [step]: Step whose completed item ratio should be calculated.
  ///
  /// Returns: A progress ratio between zero and one.
  double getStepProgress(AddEmployeeStep step) {
    final items = _stepCompletionItems(step);
    if (items.isEmpty) return 0;

    final completedItems = items.where((item) => item).length;
    return (completedItems / items.length).clamp(0.0, 1.0);
  }

  /// Method Name: [getStepItemCount]
  ///
  /// Purpose: Exposes the number of visible progress items for a step.
  ///
  /// Parameters:
  /// - [step]: Step whose item count should be returned.
  ///
  /// Returns: The number of visible items represented by the stepper.
  int getStepItemCount(AddEmployeeStep step) {
    return _stepCompletionItems(step).length;
  }

  /// Method Name: [refreshProgress]
  ///
  /// Purpose: Rebuilds the flow so controller-backed progress is recalculated.
  ///
  /// Returns: Emits the current editing state.
  void refreshProgress() {
    _emitEditingState();
  }

  /// Method Name: [_emitEditingState]
  ///
  /// Purpose: Publishes a user edit and tracks dirtiness only in edit mode.
  void _emitEditingState() {
    final step = AddEmployeeStep.fromIndex(currentStepIndex);
    emit(state.copyWith(
      status: AddEmployeeFlowStatus.editing,
      isDirty: isEditMode ? hasChangesForStep(step) : state.isDirty,
    ));
  }

  /// Method Name: [hasChangesForStep]
  ///
  /// Purpose: Compares the current normalized section values with the edit baseline.
  ///
  /// Parameters:
  /// - [section]: Section whose current values should be checked.
  ///
  /// Returns: Whether the selected section contains a real user change.
  bool hasChangesForStep(AddEmployeeStep section) {
    if (!isEditMode) return false;
    final baseline = _editBaseline[section];
    if (baseline == null) return false;
    return !_mapsEqual(baseline, _currentEditSnapshot(section));
  }

  Map<String, dynamic> _currentEditSnapshot(AddEmployeeStep section) {
    final payload = buildUpdatePayload(section);
    return _normalizeMap({
      ...payload.values,
      'profileImage': payload.profileImage?.path,
      'passportDocument': payload.passportDocument?.path,
      'nationalIdFrontDocument': payload.nationalIdFrontDocument?.path,
      'nationalIdBackDocument': payload.nationalIdBackDocument?.path,
      'drivingLicenseDocument': payload.drivingLicenseDocument?.path,
      'certificationDocument': payload.certificationDocument?.path,
    });
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> values) {
    return values
        .map((key, value) => MapEntry(key, _normalizeValue(key, value)));
  }

  dynamic _normalizeValue(String key, dynamic value) {
    if (value is Map) {
      return _normalizeMap(Map<String, dynamic>.from(value));
    }
    if (value is List) {
      return value.map((item) => _normalizeValue('', item)).toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (key == 'Car_Plates' || key == 'Language') {
        return trimmed
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      return trimmed;
    }
    return value;
  }

  bool _mapsEqual(Map<String, dynamic> left, Map<String, dynamic> right) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      if (!_valuesEqual(entry.value, right[entry.key])) return false;
    }
    return true;
  }

  bool _valuesEqual(dynamic left, dynamic right) {
    if (left is Map<String, dynamic> && right is Map<String, dynamic>) {
      return _mapsEqual(left, right);
    }
    if (left is List && right is List) {
      if (left.length != right.length) return false;
      for (var index = 0; index < left.length; index++) {
        if (!_valuesEqual(left[index], right[index])) return false;
      }
      return true;
    }
    return left == right;
  }

  List<bool> _stepCompletionItems(AddEmployeeStep step) {
    switch (step) {
      case AddEmployeeStep.personalInformation:
        return [
          _hasValue(firstNameController),
          _hasValue(middleNameController),
          _hasValue(lastNameController),
          _hasValue(firstNameArabicController),
          _hasValue(middleNameArabicController),
          _hasValue(lastNameArabicController),
          _hasValue(genderController),
          _hasValue(birthDayController),
          _hasValue(maritalStatusController),
          _hasValue(nationalityController),
          selectedLanguages.isNotEmpty,
          profileImage != null,
        ];
      case AddEmployeeStep.contactDetails:
        return [
          _hasValue(mobileNumberController),
          _hasValue(homeNumberController),
          _hasValue(emailController),
          _hasValue(officeNumberController),
          _hasValue(extensionController),
          _hasValue(businessEmailController),
        ];
      case AddEmployeeStep.addressDetails:
        return [
          _hasValue(countryController),
          _hasValue(provinceController),
          _hasValue(cityController),
          _hasValue(streetController),
          _hasValue(postalCodeController),
        ];
      case AddEmployeeStep.identificationDetails:
        return [
          _hasValue(nationalIdController),
          _hasValue(nationalIdExpirationDateController),
          _hasValue(passportController),
          _hasValue(passportExpirationDateController),
          _hasValue(drivingLicenseIdController),
          _hasValue(carPlatesController),
          passportDocument != null,
          nationalIdFrontDocument != null,
          nationalIdBackDocument != null,
          drivingLicenseDocument != null,
        ];
      case AddEmployeeStep.positionDetails:
        return [
          _hasValue(employeeIdController),
          _hasValue(titleController),
          _hasValue(departmentIdController),
          _hasValue(jobTypeController),
          _hasValue(workArrangementController),
          _hasValue(remoteStatusController),
          _hasValue(workLocationController),
          _hasValue(employeeGradeController),
          _hasValue(startDateController),
          _hasValue(startTimeController),
          _hasValue(endTimeController),
          _hasValue(daysOffController),
          _hasValue(salaryController),
          _hasValue(currencyController),
        ];
      case AddEmployeeStep.certificationDetails:
        return [
          _hasValue(institutionNameController),
          _hasValue(degreeController),
          _hasValue(fieldOfStudyController),
          _hasValue(certificationStartDateController),
          _hasValue(certificationEndDateController),
          _hasValue(gradeOrScoreController),
          _hasValue(certificateIdController),
          _hasValue(issuingAuthorityController),
          certificationDocument != null,
          _hasValue(certificationNotesController),
        ];
      case AddEmployeeStep.insuranceDetails:
        return [
          _hasValue(insuranceNameController),
          _hasValue(insurancePolicyNumberController),
          _hasValue(insuranceProviderContactController),
        ];
      case AddEmployeeStep.emergencyDetails:
        return [
          _hasValue(firstEmergencyFirstNameController),
          _hasValue(firstEmergencyLastNameController),
          _hasValue(firstEmergencyFirstNameArabicController),
          _hasValue(firstEmergencyLastNameArabicController),
          _hasValue(firstEmergencyRelationshipController),
          _hasValue(firstEmergencyEmailController),
          _hasValue(firstEmergencyMobileController),
          _hasValue(firstEmergencyCountryController),
          _hasValue(firstEmergencyProvinceController),
          _hasValue(firstEmergencyCityController),
          _hasValue(firstEmergencyStreetController),
          _hasValue(firstEmergencyLanguageController),
          _hasValue(secondEmergencyFirstNameController),
          _hasValue(secondEmergencyLastNameController),
          _hasValue(secondEmergencyFirstNameArabicController),
          _hasValue(secondEmergencyLastNameArabicController),
          _hasValue(secondEmergencyRelationshipController),
          _hasValue(secondEmergencyEmailController),
          _hasValue(secondEmergencyMobileController),
          _hasValue(secondEmergencyCountryController),
          _hasValue(secondEmergencyProvinceController),
          _hasValue(secondEmergencyCityController),
          _hasValue(secondEmergencyStreetController),
          _hasValue(secondEmergencyLanguageController),
        ];
    }
  }

  bool _hasValue(TextEditingController controller) {
    return controller.text.trim().isNotEmpty;
  }

  /// Method Name: [_controllersHaveValues]
  ///
  /// Purpose: Checks that each required controller has a non-blank value.
  ///
  /// Parameters:
  /// - [controllers]: Controllers that must all contain a value.
  ///
  /// Returns: Whether every controller contains a trimmed value.
  bool _controllersHaveValues(Iterable<TextEditingController> controllers) {
    return controllers.every(_hasValue);
  }

  /// Method Name: [updateValue]
  ///
  /// Purpose: Stores a selection or date in its controller and rebuilds the flow.
  ///
  /// Parameters:
  /// - [controller]: Controller that owns the selected field value.
  /// - [value]: New stable value selected by the user.
  ///
  /// Returns: Emits the editing state.
  void updateValue(TextEditingController controller, String value) {
    controller.text = value;
    _emitEditingState();
  }

  /// Method Name: [updatePhoneNumber]
  ///
  /// Purpose: Stores a phone's national number and selected dial code separately.
  ///
  /// Parameters:
  /// - [numberController]: Controller for the national phone number.
  /// - [countryCodeController]: Controller for the international dial code.
  /// - [phoneNumber]: Value emitted by the international phone field.
  ///
  /// Returns: Emits the editing state after both values are updated.
  void updatePhoneNumber({
    required TextEditingController numberController,
    required TextEditingController countryCodeController,
    required PhoneNumber phoneNumber,
  }) {
    if (numberController.text != phoneNumber.number) {
      numberController.text = phoneNumber.number;
    }
    if (countryCodeController.text != phoneNumber.countryCode) {
      countryCodeController.text = phoneNumber.countryCode;
    }
    _emitEditingState();
  }

  /// Method Name: [updateImageDocument]
  ///
  /// Purpose: Stores a local image document and rebuilds the active form.
  ///
  /// Parameters:
  /// - [type]: Identifies the document slot to update.
  /// - [file]: Newly selected image, or null when removed.
  ///
  /// Returns: Emits the editing state.
  void updateImageDocument(AddEmployeeDocumentType type, File? file) {
    switch (type) {
      case AddEmployeeDocumentType.passport:
        passportDocument = file;
        break;
      case AddEmployeeDocumentType.nationalIdFront:
        nationalIdFrontDocument = file;
        break;
      case AddEmployeeDocumentType.nationalIdBack:
        nationalIdBackDocument = file;
        break;
      case AddEmployeeDocumentType.drivingLicense:
        drivingLicenseDocument = file;
        break;
      case AddEmployeeDocumentType.certification:
        return;
    }
    _emitEditingState();
  }

  /// Method Name: [updateDocument]
  ///
  /// Purpose: Stores a certification attachment selected by the shared dialog.
  ///
  /// Parameters:
  /// - [type]: Document slot being updated.
  /// - [file]: Selected platform attachment, or null when removed.
  ///
  /// Returns: Emits the updated editing state for certification attachments.
  void updateDocument(AddEmployeeDocumentType type, PlatformFile? file) {
    if (type != AddEmployeeDocumentType.certification) return;
    certificationDocument = file;
    _emitEditingState();
  }

  /// Method Name: [updateGender]
  ///
  /// Purpose: Stores the selected gender in the shared form controller.
  ///
  /// Parameters:
  /// - [value]: Selected gender value.
  ///
  /// Returns: Emits the updated add-employee state.
  void updateGender(String value) {
    genderController.text = value;
    _emitEditingState();
  }

  /// Method Name: [updateMaritalStatus]
  ///
  /// Purpose: Stores the selected marital status in the shared form controller.
  ///
  /// Parameters:
  /// - [value]: Selected marital-status value.
  ///
  /// Returns: Emits the updated add-employee state.
  void updateMaritalStatus(String value) {
    maritalStatusController.text = value;
    _emitEditingState();
  }

  /// Method Name: [updateNationality]
  ///
  /// Purpose: Stores the selected nationality in the shared form controller.
  ///
  /// Parameters:
  /// - [value]: Stable selected nationality value.
  ///
  /// Returns: Emits the updated add-employee state.
  void updateNationality(String value) {
    nationalityController.text = value;
    _emitEditingState();
  }

  /// Method Name: [updateBirthday]
  ///
  /// Purpose: Stores the selected birthday in the shared form controller.
  ///
  /// Parameters:
  /// - [value]: Selected birthday value in the employee date format.
  ///
  /// Returns: Emits the updated add-employee state.
  void updateBirthday(String value) {
    birthDayController.text = value;
    _emitEditingState();
  }

  /// Method Name: [updateNationalIdExpirationDate]
  ///
  /// Purpose: Stores the selected national ID expiration date.
  ///
  /// Parameters:
  /// - [value]: Selected expiration date in the employee date format.
  ///
  /// Returns: Emits the updated add-employee state.
  void updateNationalIdExpirationDate(String value) {
    nationalIdExpirationDateController.text = value;
    _emitEditingState();
  }

  /// Method Name: [updatePassportExpirationDate]
  ///
  /// Purpose: Stores the selected passport expiration date.
  ///
  /// Parameters:
  /// - [value]: Selected expiration date in the employee date format.
  ///
  /// Returns: Emits the updated add-employee state.
  void updatePassportExpirationDate(String value) {
    passportExpirationDateController.text = value;
    _emitEditingState();
  }

  /// Method Name: [updateLanguages]
  ///
  /// Purpose: Stores the selected language values for the employee form.
  ///
  /// Parameters:
  /// - [values]: Selected stable language values.
  ///
  /// Returns: Emits the updated add-employee state.
  void updateLanguages(List<String> values) {
    selectedLanguages = List<String>.from(values);
    languageController.text = selectedLanguages.join(', ');
    emit(
      state.copyWith(
        selectedLanguages: List<String>.unmodifiable(selectedLanguages),
        status: AddEmployeeFlowStatus.editing,
        isDirty: isEditMode
            ? hasChangesForStep(AddEmployeeStep.fromIndex(currentStepIndex))
            : state.isDirty,
      ),
    );
  }

  /// Method Name: [updateProfileImage]
  ///
  /// Purpose: Stores the selected employee profile image in the flow state.
  ///
  /// Parameters:
  /// - [image]: Picked profile image file.
  ///
  /// Returns: Emits the updated add-employee state.
  void updateProfileImage(File image) {
    profileImage = image;
    emit(
      state.copyWith(
        profileImage: image,
        status: AddEmployeeFlowStatus.editing,
        isDirty: isEditMode
            ? hasChangesForStep(AddEmployeeStep.fromIndex(currentStepIndex))
            : state.isDirty,
      ),
    );
  }

  /// Method Name: [clearProfileImage]
  ///
  /// Purpose: Removes the optional employee profile image from the flow.
  ///
  /// Returns: Emits an editing state without a selected profile image.
  void clearProfileImage() {
    profileImage = null;
    emit(
      state.copyWith(
        clearProfileImage: true,
        status: AddEmployeeFlowStatus.editing,
        isDirty: isEditMode
            ? hasChangesForStep(AddEmployeeStep.fromIndex(currentStepIndex))
            : state.isDirty,
      ),
    );
  }

  /// Method Name: [_refreshCreatedEmployee]
  ///
  /// Purpose: Refreshes shared employee data before publishing success.
  ///
  /// Parameters:
  /// - [employeeId]: Newly persisted employee identifier to verify.
  ///
  /// Returns: Completes after emitting success or a typed refresh failure.
  Future<void> _refreshCreatedEmployee(String employeeId) async {
    final dataCubit = _hrModuleDataCubit;
    if (dataCubit == null) {
      emit(state.copyWith(
        status: AddEmployeeFlowStatus.success,
        createdEmployeeId: employeeId,
      ));
      return;
    }

    await dataCubit.refreshEmployees();
    final dataState = dataCubit.state;
    final employees = switch (dataState) {
      HrModuleDataLoaded() => dataState.employees,
      HrModuleDataError() => dataState.employees,
      HrModuleDataLoading() => dataState.employees,
      HrModuleDataInitial() => const [],
    };
    final refreshed = employees.any((employee) => employee.id == employeeId);
    if (!refreshed) {
      emit(state.copyWith(
        status: AddEmployeeFlowStatus.failure,
        failure: const EmployeeRefreshFailure(
          'Employee was created but was not found after refresh',
        ),
        createdEmployeeId: employeeId,
      ));
      return;
    }

    emit(state.copyWith(
      status: AddEmployeeFlowStatus.success,
      createdEmployeeId: employeeId,
      clearFailure: true,
    ));
  }

  /// Method Name: [resetFlow]
  ///
  /// Purpose: Clears all inputs and returns the flow to its first step.
  ///
  /// Returns: A future completed after the optional page reset.
  Future<void> resetFlow() async {
    isEditMode = false;
    _editBaseline.clear();
    clearAddEmployeeControllers();
    currentStepIndex = AddEmployeeStep.personalInformation.index;
    emit(state.copyWith(
      currentStep: AddEmployeeStep.personalInformation,
      status: AddEmployeeFlowStatus.reset,
      selectedLanguages: const [],
      clearProfileImage: true,
      clearFailure: true,
      clearCreatedEmployeeId: true,
    ));

    if (pageController.hasClients) {
      pageController.jumpToPage(currentStepIndex);
    }
  }

  @override
  Future<void> close() {
    disposeAddEmployeeControllers();
    return super.close();
  }
}
