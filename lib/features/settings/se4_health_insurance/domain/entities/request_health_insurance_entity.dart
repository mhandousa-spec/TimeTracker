/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: request_health_insurance_entity.dart
/// Purpose: The health-insurance values a change request carries.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N18/N19: the `cloud_firestore`-backed data
///          model import is gone — `fromModel` moved to
///          `data/models/health_insurance_mapper.dart`, so the domain no longer
///          depends on the data layer — and every field is final.
///
/// PORTED into services_app under features/settings.
/// Source: services_app features/employees/domain/entities/…

import 'package:flutter/foundation.dart';

@immutable
class HealthInsuranceEntity {
  const HealthInsuranceEntity({
    required this.employeeId,
    this.providerName,
    this.policyNumber,
    this.providerNumber,
    this.providerCountryCode,
    this.providerCountryApp,
    this.postalCode,
  });

  final String employeeId;
  final String? providerName;
  final String? policyNumber;
  final String? providerNumber;
  final String? providerCountryCode;
  final String? providerCountryApp;
  final String? postalCode;

  /// Aliases the widgets already use.
  String? get insuranceName => providerName;
  String? get policyNum => policyNumber;

  HealthInsuranceEntity copyWith({
    String? employeeId,
    String? providerName,
    String? policyNumber,
    String? providerNumber,
    String? providerCountryCode,
    String? providerCountryApp,
    String? postalCode,
  }) {
    return HealthInsuranceEntity(
      employeeId: employeeId ?? this.employeeId,
      providerName: providerName ?? this.providerName,
      policyNumber: policyNumber ?? this.policyNumber,
      providerNumber: providerNumber ?? this.providerNumber,
      providerCountryCode: providerCountryCode ?? this.providerCountryCode,
      providerCountryApp: providerCountryApp ?? this.providerCountryApp,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthInsuranceEntity &&
          other.employeeId == employeeId &&
          other.providerName == providerName &&
          other.policyNumber == policyNumber &&
          other.providerNumber == providerNumber &&
          other.providerCountryCode == providerCountryCode &&
          other.providerCountryApp == providerCountryApp &&
          other.postalCode == postalCode;

  @override
  int get hashCode => Object.hash(employeeId, providerName, policyNumber,
      providerNumber, providerCountryCode, providerCountryApp, postalCode);
}
