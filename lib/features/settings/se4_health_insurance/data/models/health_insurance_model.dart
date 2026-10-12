/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_insurance_model.dart
/// Purpose: The stored health-insurance document.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - Added the standard header (Docs).

// PORTED into services_app under features/settings.
// Source: services_app features/employees/data/models/health_insurance_model/health_insurance_model.dart
// Imports rewired to the equivalents that already exist in services_app.

import 'package:knowticed_plus/core/helper/main_helper/single_value_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';

/// **************************** FILE INFO **************************** ///
/// Purpose: Model for employee insurance data
/// Author: Amr Mesbah
/// created At: 20/11/2024

class HealthInsuranceModel {
  String? employeeId;
  SingleValueModel<String> insuranceProviderName;
  SingleValueModel<String> postalCode;
  MobilePhone insuranceProviderContact;
  SingleValueModel<String> insurancePolicyNumber;

  HealthInsuranceModel(
      {required this.employeeId,
      required this.insuranceProviderName,
      required this.insuranceProviderContact,
      required this.insurancePolicyNumber,
      required this.postalCode});

  static const String employeeIdKey = 'Employee_Id';
  static const String insuranceProviderNameKey = 'Insurance_Provider_Name';
  static const String insuranceProviderContactKey =
      'Insurance_Provider_Contact';
  static const String insurancePolicyNumberKey = 'Insurance_Policy_Number';
  static const String postalCodeKey = 'Postal_Code';

  Map<String, dynamic> toMap() {
    return {
      employeeIdKey: employeeId,
      insuranceProviderNameKey: insuranceProviderName.toMap(),
      insuranceProviderContactKey: insuranceProviderContact.toMap(),
      insurancePolicyNumberKey: insurancePolicyNumber.toMap(),
      postalCodeKey: postalCode.toMap()
    };
  }

  factory HealthInsuranceModel.fromMap(Map<String, dynamic> map) {
    return HealthInsuranceModel(
      postalCode: SingleValueModel<String>.fromMap(
          map[postalCodeKey] as Map<String, dynamic>),
      employeeId: map[employeeIdKey] as String,
      insuranceProviderName: SingleValueModel<String>.fromMap(
          map[insuranceProviderNameKey] as Map<String, dynamic>),
      // services_app's MobilePhone.fromMap takes a non-nullable map (unlike
      // services_app's, which accepts null and returns an all-null instance).
      // An empty map produces the same all-null result.
      insuranceProviderContact: MobilePhone.fromMap(
          (map[insuranceProviderContactKey] as Map<String, dynamic>?) ??
              <String, dynamic>{}),
      insurancePolicyNumber: SingleValueModel<String>.fromMap(
          map[insurancePolicyNumberKey] as Map<String, dynamic>),
    );
  }
}
