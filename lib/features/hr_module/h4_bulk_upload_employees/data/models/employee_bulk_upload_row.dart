// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_row.dart
// Purpose: Stores one immutable employee spreadsheet row and normalized phones.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import '../../utils/constants/employee_bulk_upload_headers.dart';

/// Normalized national number and international dial code.
class EmployeeBulkPhoneValue {
  const EmployeeBulkPhoneValue({
    this.number = '',
    this.countryCode = '',
    this.countryApp = '',
  });

  final String number;
  final String countryCode;
  final String countryApp;
}

/// Immutable editable employee row parsed from the spreadsheet.
class EmployeeBulkUploadRow {
  EmployeeBulkUploadRow({
    required this.excelRowNumber,
    required Map<String, String> values,
    this.mobilePhone = const EmployeeBulkPhoneValue(),
    this.homePhone = const EmployeeBulkPhoneValue(),
    this.officePhone = const EmployeeBulkPhoneValue(),
  }) : values = Map.unmodifiable(Map<String, String>.from(values));

  final int excelRowNumber;
  final Map<String, String> values;
  final EmployeeBulkPhoneValue mobilePhone;
  final EmployeeBulkPhoneValue homePhone;
  final EmployeeBulkPhoneValue officePhone;

  String value(String header) => values[header]?.trim() ?? '';

  EmployeeBulkUploadRow copyWith({
    int? excelRowNumber,
    Map<String, String>? values,
    EmployeeBulkPhoneValue? mobilePhone,
    EmployeeBulkPhoneValue? homePhone,
    EmployeeBulkPhoneValue? officePhone,
  }) {
    return EmployeeBulkUploadRow(
      excelRowNumber: excelRowNumber ?? this.excelRowNumber,
      values: values ?? this.values,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      homePhone: homePhone ?? this.homePhone,
      officePhone: officePhone ?? this.officePhone,
    );
  }

  EmployeeBulkUploadRow updateValue(String header, String value) {
    final updated = Map<String, String>.from(values)..[header] = value;
    return copyWith(values: updated);
  }

  EmployeeBulkUploadRow renumber(int rowIndex) {
    final updated = Map<String, String>.from(values)
      ..[EmployeeBulkUploadHeaders.number] = (rowIndex + 1).toString();
    return copyWith(excelRowNumber: rowIndex + 2, values: updated);
  }

  factory EmployeeBulkUploadRow.empty(int index) {
    return EmployeeBulkUploadRow(
      excelRowNumber: index + 2,
      values: {
        for (final header in EmployeeBulkUploadHeaders.values) header: '',
        EmployeeBulkUploadHeaders.number: (index + 1).toString(),
      },
    );
  }
}
