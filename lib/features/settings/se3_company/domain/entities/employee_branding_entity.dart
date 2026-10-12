/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: employee_branding_entity.dart
/// Purpose: One employee's personal branding overrides — logo, colours, fonts.
/// Author: Amr Mesbah
/// Created at: 2026-01-25
/// Updated: 11/8/2026 - CR-SKEL-SE3-N03/N26/N27: renamed from
///          `employee_branding_model.dart` (a `*_model` name in
///          domain/entities/), the `cloud_firestore` import dropped — the
///          domain no longer knows what a `Timestamp` is; `DateTime` is used
///          instead and mapped at the data boundary by
///          `EmployeeBrandingMapper` — and every field is now final.
///
/// PORTED into services_app under features/settings.
/// Source: services_app features/employees/employee_branding/domain/model.dart

import 'package:flutter/foundation.dart';

@immutable
class EmployeeBrandingEntity {
  const EmployeeBrandingEntity({
    required this.employeeId,
    this.logo,
    this.primaryColor,
    this.secondaryColor,
    this.fontEnglish,
    this.fontArabic,
    this.updatedAt,
  });

  final String employeeId;
  final String? logo;

  /// Stored as an `0xAARRGGBB` string, matching the company branding fields.
  final String? primaryColor;
  final String? secondaryColor;

  final String? fontEnglish;
  final String? fontArabic;

  /// Was a Firestore `Timestamp`, which is what pulled infrastructure into the
  /// domain layer.
  final DateTime? updatedAt;

  /// Function Name: [fromCompanyBranding]
  ///
  /// Purpose: The default override for an employee — a copy of the company's
  ///          own branding.
  factory EmployeeBrandingEntity.fromCompanyBranding({
    required String employeeId,
    String? companyLogo,
    String? companyPrimaryColor,
    String? companySecondaryColor,
    String? companyFontEnglish,
    String? companyFontArabic,
    DateTime? updatedAt,
  }) {
    return EmployeeBrandingEntity(
      employeeId: employeeId,
      logo: companyLogo,
      primaryColor: companyPrimaryColor,
      secondaryColor: companySecondaryColor,
      fontEnglish: companyFontEnglish,
      fontArabic: companyFontArabic,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Whether the employee has anything of their own, as opposed to inheriting
  /// every value from the company.
  bool hasCustomBranding() =>
      logo != null ||
      primaryColor != null ||
      secondaryColor != null ||
      fontEnglish != null ||
      fontArabic != null;

  EmployeeBrandingEntity copyWith({
    String? employeeId,
    String? logo,
    String? primaryColor,
    String? secondaryColor,
    String? fontEnglish,
    String? fontArabic,
    DateTime? updatedAt,
  }) {
    return EmployeeBrandingEntity(
      employeeId: employeeId ?? this.employeeId,
      logo: logo ?? this.logo,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fontEnglish: fontEnglish ?? this.fontEnglish,
      fontArabic: fontArabic ?? this.fontArabic,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeBrandingEntity &&
          other.employeeId == employeeId &&
          other.logo == logo &&
          other.primaryColor == primaryColor &&
          other.secondaryColor == secondaryColor &&
          other.fontEnglish == fontEnglish &&
          other.fontArabic == fontArabic &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(employeeId, logo, primaryColor,
      secondaryColor, fontEnglish, fontArabic, updatedAt);

  @override
  String toString() =>
      'EmployeeBrandingEntity(employeeId: $employeeId, logo: $logo, '
      'primaryColor: $primaryColor, secondaryColor: $secondaryColor, '
      'fontEnglish: $fontEnglish, fontArabic: $fontArabic)';
}
