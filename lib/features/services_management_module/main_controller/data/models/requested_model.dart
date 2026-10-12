// ******************* FILE INFO *******************
// File Name: requested_model
// Description: DTO representing a requested service and its requester metadata.
// Module: services_management_module / data / models
// *************************************************

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';

class RequestedServices {
  // ---- Firestore field keys ----
  static const String kId = 'id';
  static const String kStatus = 'status';
  static const String kServiceRequester = 'serviceRequester';
  static const String kServiceProvider = 'serviceProvider';
  static const String kDuration = 'duration';
  static const String kSelectedDurationUnit = 'selectedDurationUnit';
  static const String kServiceName = 'serviceName';
  static const String kState = 'state';
  static const String kRequestDate = 'requestDate';
  static const String kDepartment = 'department';
  static const String kFirstNameRequester = 'firstNameRequester';
  static const String kLastNameRequester = 'lastNameRequester';
  static const String kFirstNameRequesterArabic = 'firstNameRequesterArabic';
  static const String kLastNameRequesterArabic = 'lastNameRequesterArabic';
  static const String kJobTitleRequester = 'jobTitleRequester';
  static const String kJobTitleRequesterArabic = 'jobTitleRequesterArabic';
  static const String kDepartmentRequester = 'departmentRequester';
  static const String kDepartmentRequesterArabic = 'departmentRequesterArabic';

  final String? id;

  final String? status;
  final String? serviceRequester;
  final List<EmployeeEntityModell>? serviceProvider;
  final String? serviceName;
  final String? duration;
  final String? selectedDurationUnit;
  final String? requestDate;
  final String? state;
  final List? department;

  final String? firstNameRequester;
  final String? lastNameRequester;
  final String? firstNameRequesterArabic;
  final String? lastNameRequesterArabic;
  final String? jobTitleRequester;
  final String? jobTitleRequesterArabic;
  final String? departmentRequester;
  final String? departmentRequesterArabic;

  RequestedServices({
    this.id,
    this.status,
    this.serviceRequester,
    this.serviceProvider,
    this.serviceName,
    this.state,
    this.duration,
    this.selectedDurationUnit,
    this.requestDate,
    this.department,
    this.firstNameRequester,
    this.lastNameRequester,
    this.firstNameRequesterArabic,
    this.lastNameRequesterArabic,
    this.jobTitleRequester,
    this.jobTitleRequesterArabic,
    this.departmentRequester,
    this.departmentRequesterArabic,
  });

  factory RequestedServices.fromJson(Map<String, dynamic> json) {
    return RequestedServices(
      id: json[kId],
      status: json[kStatus],
      serviceRequester: json[kServiceRequester],
      serviceProvider: (json[kServiceProvider] as List<dynamic>?)
          ?.map((item) => EmployeeEntityModell.fromJson(item as Map<String, dynamic>))
          .toList(),
      duration: json[kDuration],
      selectedDurationUnit: json[kSelectedDurationUnit],
      serviceName: json[kServiceName],
      state: json[kState],
      requestDate: json[kRequestDate],
      department: json[kDepartment],
      firstNameRequester: json[kFirstNameRequester],
      lastNameRequester: json[kLastNameRequester],
      firstNameRequesterArabic: json[kFirstNameRequesterArabic],
      lastNameRequesterArabic: json[kLastNameRequesterArabic],
      jobTitleRequester: json[kJobTitleRequester],
      jobTitleRequesterArabic: json[kJobTitleRequesterArabic],
      departmentRequester: json[kDepartmentRequester],
      departmentRequesterArabic: json[kDepartmentRequesterArabic],
    );
  }

  // Canonical map serialization (§10) — delegates to toJson()/fromJson().
  Map<String, dynamic> toMap() => toJson();

  factory RequestedServices.fromMap(Map<String, dynamic> map) =>
      RequestedServices.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      kId: id,
      kStatus: status,
      kServiceRequester: serviceRequester,
      kServiceProvider: serviceProvider?.map((e) => e.toJson()).toList(),
      kDuration: duration,
      kSelectedDurationUnit: selectedDurationUnit,
      kServiceName: serviceName,
      kState: state,
      kRequestDate: requestDate,
      kDepartment: department,
      kFirstNameRequester: firstNameRequester,
      kLastNameRequester: lastNameRequester,
      kFirstNameRequesterArabic: firstNameRequesterArabic,
      kLastNameRequesterArabic: lastNameRequesterArabic,
      kJobTitleRequester: jobTitleRequester,
      kJobTitleRequesterArabic: jobTitleRequesterArabic,
      kDepartmentRequester: departmentRequester,
      kDepartmentRequesterArabic: departmentRequesterArabic,
    };
  }

  RequestedServices copyWith({
    String? id,
    String? status,
    String? serviceRequester,
    List<EmployeeEntityModell>? serviceProvider,
    String? serviceName,
    String? duration,
    String? selectedDurationUnit,
    String? requestDate,
    String? state,
    List? department,
    String? firstNameRequester,
    String? lastNameRequester,
    String? firstNameRequesterArabic,
    String? lastNameRequesterArabic,
    String? jobTitleRequester,
    String? jobTitleRequesterArabic,
    String? departmentRequester,
    String? departmentRequesterArabic,
  }) {
    return RequestedServices(
      id: id ?? this.id,
      status: status ?? this.status,
      serviceRequester: serviceRequester ?? this.serviceRequester,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      serviceName: serviceName ?? this.serviceName,
      duration: duration ?? this.duration,
      selectedDurationUnit: selectedDurationUnit ?? this.selectedDurationUnit,
      requestDate: requestDate ?? this.requestDate,
      state: state ?? this.state,
      department: department ?? this.department,
      firstNameRequester: firstNameRequester ?? this.firstNameRequester,
      lastNameRequester: lastNameRequester ?? this.lastNameRequester,
      firstNameRequesterArabic:
          firstNameRequesterArabic ?? this.firstNameRequesterArabic,
      lastNameRequesterArabic:
          lastNameRequesterArabic ?? this.lastNameRequesterArabic,
      jobTitleRequester: jobTitleRequester ?? this.jobTitleRequester,
      jobTitleRequesterArabic:
          jobTitleRequesterArabic ?? this.jobTitleRequesterArabic,
      departmentRequester: departmentRequester ?? this.departmentRequester,
      departmentRequesterArabic:
          departmentRequesterArabic ?? this.departmentRequesterArabic,
    );
  }
}
