/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: employee_branding_mapper.dart
/// Purpose: Translate [EmployeeBrandingEntity] to and from its Firestore shape.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE3-N26. `Timestamp` conversion lives here so the domain
/// entity can be infrastructure-free.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/settings/se3_company/domain/entities/employee_branding_entity.dart';

abstract class EmployeeBrandingMapper {
  /// Firestore field keys. Were repeated as literals in `fromMap` and `toMap`
  /// (CR-SKEL-SE3-N22).
  static const String fieldEmployeeId = 'employeeId';
  static const String fieldLogo = 'logo';
  static const String fieldPrimaryColor = 'primaryColor';
  static const String fieldSecondaryColor = 'secondaryColor';
  static const String fieldFontEnglish = 'fontEnglish';
  static const String fieldFontArabic = 'fontArabic';
  static const String fieldTimestamp = 'timestamp';

  static EmployeeBrandingEntity fromMap(Map<String, dynamic> map) {
    final dynamic stamp = map[fieldTimestamp];
    return EmployeeBrandingEntity(
      employeeId: map[fieldEmployeeId] as String? ?? '',
      logo: map[fieldLogo] as String?,
      primaryColor: map[fieldPrimaryColor] as String?,
      secondaryColor: map[fieldSecondaryColor] as String?,
      fontEnglish: map[fieldFontEnglish] as String?,
      fontArabic: map[fieldFontArabic] as String?,
      updatedAt: stamp is Timestamp ? stamp.toDate() : null,
    );
  }

  static Map<String, dynamic> toMap(EmployeeBrandingEntity branding) {
    return <String, dynamic>{
      fieldEmployeeId: branding.employeeId,
      fieldLogo: branding.logo,
      fieldPrimaryColor: branding.primaryColor,
      fieldSecondaryColor: branding.secondaryColor,
      fieldFontEnglish: branding.fontEnglish,
      fieldFontArabic: branding.fontArabic,
      fieldTimestamp: branding.updatedAt == null
          ? Timestamp.now()
          : Timestamp.fromDate(branding.updatedAt!),
    };
  }
}
