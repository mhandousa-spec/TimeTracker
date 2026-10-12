// ***************************** FILE INFO ***************************** //
// File Name: emergency_contact_employee_row.dart
// Purpose: Defines one joined employee emergency-contact table row.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import '../../../h3_add_employee/data/models/employee_emergency_details_model.dart';
import 'employee_details_row.dart';

/// Joins legacy employee data with supplemental emergency-contact values.
class EmergencyContactEmployeeRow extends EmployeeDetailsRow {
  const EmergencyContactEmployeeRow({
    required super.employee,
    this.details,
  });

  final EmployeeEmergencyDetailsModel? details;

  /// Method Name: [firstValues]
  ///
  /// Purpose: Returns visible first-contact values in table-column order.
  ///
  /// Returns: The display-ready first-contact values.
  List<String> get firstValues => [
        employee.firstContactFirstName ?? '',
        '',
        employee.firstContactLastName ?? '',
        latestHistoryValue(details?.firstContactFirstNameArabic),
        '',
        latestHistoryValue(details?.firstContactLastNameArabic),
        employee.firstContactRelationship ?? '',
        employee.firstContactEmail ?? '',
        _phone(
          details?.firstContactCountryCode,
          employee.firstContactPhone,
        ),
        employee.firstContactCountry ?? '',
        employee.firstContactProvince ?? '',
        employee.firstContactCity ?? '',
        employee.firstContactStreet ?? '',
        employee.firstContactLanguage ?? '',
      ];

  /// Method Name: [secondValues]
  ///
  /// Purpose: Returns visible second-contact values in table-column order.
  ///
  /// Returns: The display-ready second-contact values.
  List<String> get secondValues => [
        employee.secondContactFirstName ?? '',
        '',
        employee.secondContactLastName ?? '',
        latestHistoryValue(details?.secondContactFirstNameArabic),
        '',
        latestHistoryValue(details?.secondContactLastNameArabic),
        employee.secondContactRelationship ?? '',
        employee.secondContactEmail ?? '',
        _phone(
          details?.secondContactCountryCode,
          employee.secondContactPhone,
        ),
        employee.secondContactCountry ?? '',
        employee.secondContactProvince ?? '',
        employee.secondContactCity ?? '',
        employee.secondContactStreet ?? '',
        employee.secondContactLanguage ?? '',
      ];

  /// Method Name: [detailSearchValues]
  ///
  /// Purpose: Exposes emergency-contact values for shared row search.
  ///
  /// Returns: Searchable first- and second-contact values.
  @override
  List<String> get detailSearchValues => [
        ...firstValues,
        ...secondValues,
      ];

  String _phone(List<String>? codes, String? number) {
    final countryCode = latestHistoryValue(codes);
    final nationalNumber = number?.trim() ?? '';
    return [countryCode, nationalNumber]
        .where((value) => value.isNotEmpty)
        .join(' ');
  }
}
