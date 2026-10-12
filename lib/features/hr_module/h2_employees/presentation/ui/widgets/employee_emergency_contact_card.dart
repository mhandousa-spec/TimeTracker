// ***************************** FILE INFO ***************************** //
// File Name: employee_emergency_contact_card.dart
// Purpose: Displays one read-only employee emergency contact.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/16-custom_card_styles.dart';
import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import 'employee_details_field.dart';

/// Renders the available information for one employee emergency contact.
class EmployeeEmergencyContactCard extends StatelessWidget {
  const EmployeeEmergencyContactCard({
    required this.name,
    required this.relationship,
    required this.email,
    required this.phone,
    required this.country,
    required this.province,
    required this.city,
    required this.street,
    required this.language,
    super.key,
  });

  final String? name;
  final String? relationship;
  final String? email;
  final String? phone;
  final String? country;
  final String? province;
  final String? city;
  final String? street;
  final String? language;

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmployeeDetailsField(
              iconAsset: HRAssets.employeeName,
              label: localizations.name,
              value: name),
          SizedBox(height: 10.h),
          EmployeeDetailsField(
              iconAsset: HRAssets.employeeManager,
              label: localizations.relationship,
              value: relationship),
          SizedBox(height: 10.h),
          EmployeeDetailsField(
              iconAsset: HRAssets.employeeEmail,
              label: localizations.email,
              value: email),
          SizedBox(height: 10.h),
          EmployeeDetailsField(
              iconAsset: HRAssets.employeePhone,
              label: localizations.phoneNumber,
              value: phone),
          SizedBox(height: 10.h),
          EmployeeDetailsField(
              iconAsset: HRAssets.employeeCountry,
              label: localizations.country,
              value: country),
          SizedBox(height: 10.h),
          EmployeeDetailsField(
              iconAsset: HRAssets.employeeProvince,
              label: localizations.province,
              value: province),
          SizedBox(height: 10.h),
          EmployeeDetailsField(
              iconAsset: HRAssets.employeeCity,
              label: localizations.city,
              value: city),
          SizedBox(height: 10.h),
          EmployeeDetailsField(
              iconAsset: HRAssets.employeeStreet,
              label: localizations.street,
              value: street),
          SizedBox(height: 10.h),
          EmployeeDetailsField(
              iconAsset: HRAssets.employeeLanguage,
              label: localizations.language,
              value: language),
        ],
      ),
    );
  }
}
