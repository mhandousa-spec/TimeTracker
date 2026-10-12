// ***************************** FILE INFO ***************************** //
// File Name: salary_table_value_resolver.dart
// Purpose: Resolves stored salary enum values for localized table display.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import '../../h3_add_employee/utils/add_employee_currency_option.dart';
import '../../h3_add_employee/utils/add_employee_days_off_option.dart';
import '../../h3_add_employee/utils/add_employee_job_type_option.dart';
import 'hr_table_display_value.dart';

/// Resolves Salary table values with the labels used by Add Employee.
abstract final class SalaryTableValueResolver {
  /// Method Name: [jobType]
  ///
  /// Purpose: Localizes the stored job-type option name.
  static String jobType(String value) => _titleFor(
        value,
        JobTypeOption.values,
        (option) => option.title,
      );

  /// Method Name: [daysOff]
  ///
  /// Purpose: Localizes the stored days-off option name.
  static String daysOff(String value) => _titleFor(
        value,
        DaysOffOption.values,
        (option) => option.title,
      );

  /// Method Name: [currency]
  ///
  /// Purpose: Localizes the stored currency option name.
  static String currency(String value) {
    for (final option in CurrencyOption.values) {
      if (option.name == value) return option.title;
    }
    return HrTableDisplayValue.format(value);
  }

  static String _titleFor<T extends Enum>(
    String value,
    List<T> options,
    String Function(T) title,
  ) {
    for (final option in options) {
      if (option.name == value) return title(option);
    }
    return HrTableDisplayValue.format(value);
  }
}
