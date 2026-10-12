// ******************* FILE INFO *******************
// File Name: provider_selection_data
// Description: Provider selection data.
// Module: services_management_module / presentation/s2_create_single_services/data
// *************************************************

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

/// Immutable data model for provider selection screen
class ProviderSelectionData {
  final ServicesHistoryModel? editingModel;
  final String? docId;
  final ServicesHistoryModel? editProvider;
  final Set<String> selectedEmployeeEmails;
  final String? originalProviderEmail;
  final bool isEditMode;
  final bool hasRestoredSelection;
  final bool isInitialized;
  final bool isLoading;

  const ProviderSelectionData({
    this.editingModel,
    this.docId,
    this.editProvider,
    this.selectedEmployeeEmails = const {},
    this.originalProviderEmail,
    this.isEditMode = false,
    this.hasRestoredSelection = false,
    this.isInitialized = false,
    this.isLoading = true,
  });

  ProviderSelectionData copyWith({
    ServicesHistoryModel? editingModel,
    String? docId,
    ServicesHistoryModel? editProvider,
    Set<String>? selectedEmployeeEmails,
    String? originalProviderEmail,
    bool? isEditMode,
    bool? hasRestoredSelection,
    bool? isInitialized,
    bool? isLoading,
  }) {
    return ProviderSelectionData(
      editingModel: editingModel ?? this.editingModel,
      docId: docId ?? this.docId,
      editProvider: editProvider ?? this.editProvider,
      selectedEmployeeEmails: selectedEmployeeEmails ?? this.selectedEmployeeEmails,
      originalProviderEmail: originalProviderEmail ?? this.originalProviderEmail,
      isEditMode: isEditMode ?? this.isEditMode,
      hasRestoredSelection: hasRestoredSelection ?? this.hasRestoredSelection,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Helper class for employee mapping
class EmployeeMappingData {
  final String id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? gender;
  final String? title;
  final String? titleInArabic;
  final String? firstNameInArabic;
  final String? middleNameInArabic;
  final String? lastNameInArabic;
  final String? photo;
  final String? departmentId;
  final String? language;
  final String? maritalStatus;
  final String? homePhone;
  final String? drivingLicenseId;
  final String? country;
  final String? city;
  final String? postalCode;
  final String? province;
  final String? role;
  final String? status;
  final String? supervisor;
  final String? workLocation;
  final dynamic mobilePhone;

  EmployeeMappingData({
    required this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.gender,
    this.title,
    this.titleInArabic,
    this.firstNameInArabic,
    this.middleNameInArabic,
    this.lastNameInArabic,
    this.photo,
    this.departmentId,
    this.language,
    this.maritalStatus,
    this.homePhone,
    this.drivingLicenseId,
    this.country,
    this.city,
    this.postalCode,
    this.province,
    this.role,
    this.status,
    this.supervisor,
    this.workLocation,
    this.mobilePhone,
  });

  EmployeeEntityModell toEmployeeEntityModell() {
    return EmployeeEntityModell(
      id: id,
      state: "pending",
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      email: email,
      gender: gender,
      title: title,
      titleInArabic: titleInArabic,
      photo: photo,
      departmentId: departmentId,
      language: language,
      maritalStatus: maritalStatus,
      middleNameInArabic: middleNameInArabic,
      lastNameInArabic: lastNameInArabic,
      firstNameInArabic: firstNameInArabic,
      homePhone: homePhone,
      drivingLicenseId: drivingLicenseId,
      country: country,
      city: city,
      postalCode: postalCode,
      province: province,
      role: role,
      status: status,
      supervisor: supervisor,
      workLocation: workLocation,
      mobilePhone: mobilePhone != null
          ? ServicesMobilePhoneEntity.fromMobilePhoneEntity(mobilePhone)
          : null,
    );
  }
}
