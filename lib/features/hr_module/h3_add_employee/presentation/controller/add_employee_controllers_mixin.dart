// ***************************** FILE INFO ***************************** //
// File Name: add_employee_controllers_mixin.dart
// Purpose: Owns shared controllers and form resources for add-employee steps.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../utils/add_employee_step.dart';

/// Provides the shared controller resources used by every add-employee page.
mixin AddEmployeeControllersMixin {
  final PageController pageController = PageController();

  int currentStepIndex = AddEmployeeStep.personalInformation.index;

  final List<GlobalKey<FormState>> stepFormKeys = List.generate(
    AddEmployeeStep.values.length,
    (_) => GlobalKey<FormState>(),
  );

  final employeeIdController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final firstNameArabicController = TextEditingController();
  final middleNameArabicController = TextEditingController();
  final lastNameArabicController = TextEditingController();
  final nationalIdController = TextEditingController();
  final nationalIdExpirationDateController = TextEditingController();
  final nationalityController = TextEditingController();
  final passportController = TextEditingController();
  final passportExpirationDateController = TextEditingController();
  final emailController = TextEditingController();
  final businessEmailController = TextEditingController();
  final mobileCountryCodeController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final homeCountryCodeController = TextEditingController();
  final homeNumberController = TextEditingController();
  final officeCountryCodeController = TextEditingController();
  final officeNumberController = TextEditingController();
  final extensionController = TextEditingController();
  final birthDayController = TextEditingController();
  final genderController = TextEditingController();
  final countryController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final postalCodeController = TextEditingController();
  final streetController = TextEditingController();
  final maritalStatusController = TextEditingController();
  final languageController = TextEditingController();
  final departmentIdController = TextEditingController();
  final supervisorController = TextEditingController();
  final roleController = TextEditingController();
  final titleController = TextEditingController();
  final titleArabicController = TextEditingController();
  final workLocationController = TextEditingController();
  final drivingLicenseIdController = TextEditingController();
  final carPlatesController = TextEditingController();
  final jobTypeController = TextEditingController();
  final workArrangementController = TextEditingController();
  final remoteStatusController = TextEditingController();
  final employeeGradeController = TextEditingController();
  final startDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final daysOffController = TextEditingController();
  final salaryController = TextEditingController();
  final currencyController = TextEditingController();
  final institutionNameController = TextEditingController();
  final degreeController = TextEditingController();
  final fieldOfStudyController = TextEditingController();
  final certificationStartDateController = TextEditingController();
  final certificationEndDateController = TextEditingController();
  final gradeOrScoreController = TextEditingController();
  final certificateIdController = TextEditingController();
  final issuingAuthorityController = TextEditingController();
  final certificationNotesController = TextEditingController();
  final insuranceNameController = TextEditingController();
  final insurancePolicyNumberController = TextEditingController();
  final insuranceProviderContactController = TextEditingController();
  final firstEmergencyFirstNameController = TextEditingController();
  final firstEmergencyLastNameController = TextEditingController();
  final firstEmergencyFirstNameArabicController = TextEditingController();
  final firstEmergencyLastNameArabicController = TextEditingController();
  final firstEmergencyRelationshipController = TextEditingController();
  final firstEmergencyEmailController = TextEditingController();
  final firstEmergencyCountryCodeController = TextEditingController();
  final firstEmergencyMobileController = TextEditingController();
  final firstEmergencyCountryController = TextEditingController();
  final firstEmergencyProvinceController = TextEditingController();
  final firstEmergencyCityController = TextEditingController();
  final firstEmergencyStreetController = TextEditingController();
  final firstEmergencyLanguageController = TextEditingController();
  final secondEmergencyFirstNameController = TextEditingController();
  final secondEmergencyLastNameController = TextEditingController();
  final secondEmergencyFirstNameArabicController = TextEditingController();
  final secondEmergencyLastNameArabicController = TextEditingController();
  final secondEmergencyRelationshipController = TextEditingController();
  final secondEmergencyEmailController = TextEditingController();
  final secondEmergencyCountryCodeController = TextEditingController();
  final secondEmergencyMobileController = TextEditingController();
  final secondEmergencyCountryController = TextEditingController();
  final secondEmergencyProvinceController = TextEditingController();
  final secondEmergencyCityController = TextEditingController();
  final secondEmergencyStreetController = TextEditingController();
  final secondEmergencyLanguageController = TextEditingController();

  File? profileImage;
  File? passportDocument;
  File? nationalIdFrontDocument;
  File? nationalIdBackDocument;
  File? drivingLicenseDocument;
  PlatformFile? certificationDocument;
  List<String> selectedLanguages = <String>[];

  /// Method Name: [disposeAddEmployeeControllers]
  ///
  /// Purpose: Releases all resources owned by the add-employee flow.
  ///
  /// Returns: No value; all owned controllers are disposed.
  void disposeAddEmployeeControllers() {
    pageController.dispose();
    for (final controller in _textControllers) {
      controller.dispose();
    }
  }

  /// Method Name: [clearAddEmployeeControllers]
  ///
  /// Purpose: Clears input values while keeping the flow resources reusable.
  ///
  /// Returns: No value; all text fields are emptied.
  void clearAddEmployeeControllers() {
    for (final controller in _textControllers) {
      controller.clear();
    }
    profileImage = null;
    passportDocument = null;
    nationalIdFrontDocument = null;
    nationalIdBackDocument = null;
    drivingLicenseDocument = null;
    certificationDocument = null;
    selectedLanguages = <String>[];
  }

  List<TextEditingController> get _textControllers => [
        employeeIdController,
        firstNameController,
        middleNameController,
        lastNameController,
        firstNameArabicController,
        middleNameArabicController,
        lastNameArabicController,
        nationalIdController,
        nationalIdExpirationDateController,
        nationalityController,
        passportController,
        passportExpirationDateController,
        emailController,
        businessEmailController,
        mobileCountryCodeController,
        mobileNumberController,
        homeCountryCodeController,
        homeNumberController,
        officeCountryCodeController,
        officeNumberController,
        extensionController,
        birthDayController,
        genderController,
        countryController,
        provinceController,
        cityController,
        postalCodeController,
        streetController,
        maritalStatusController,
        languageController,
        departmentIdController,
        supervisorController,
        roleController,
        titleController,
        titleArabicController,
        workLocationController,
        drivingLicenseIdController,
        carPlatesController,
        jobTypeController,
        workArrangementController,
        remoteStatusController,
        employeeGradeController,
        startDateController,
        startTimeController,
        endTimeController,
        daysOffController,
        salaryController,
        currencyController,
        institutionNameController,
        degreeController,
        fieldOfStudyController,
        certificationStartDateController,
        certificationEndDateController,
        gradeOrScoreController,
        certificateIdController,
        issuingAuthorityController,
        certificationNotesController,
        insuranceNameController,
        insurancePolicyNumberController,
        insuranceProviderContactController,
        firstEmergencyFirstNameController,
        firstEmergencyLastNameController,
        firstEmergencyFirstNameArabicController,
        firstEmergencyLastNameArabicController,
        firstEmergencyRelationshipController,
        firstEmergencyEmailController,
        firstEmergencyCountryCodeController,
        firstEmergencyMobileController,
        firstEmergencyCountryController,
        firstEmergencyProvinceController,
        firstEmergencyCityController,
        firstEmergencyStreetController,
        firstEmergencyLanguageController,
        secondEmergencyFirstNameController,
        secondEmergencyLastNameController,
        secondEmergencyFirstNameArabicController,
        secondEmergencyLastNameArabicController,
        secondEmergencyRelationshipController,
        secondEmergencyEmailController,
        secondEmergencyCountryCodeController,
        secondEmergencyMobileController,
        secondEmergencyCountryController,
        secondEmergencyProvinceController,
        secondEmergencyCityController,
        secondEmergencyStreetController,
        secondEmergencyLanguageController,
      ];
}
