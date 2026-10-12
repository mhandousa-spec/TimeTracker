// ***************************** FILE INFO ***************************** //
// File Name: employee_details_table_state.dart
// Purpose: Defines shared state data exposed by employee detail tables.
// Author: Mohamed Elrashidy
// Created At: 2026-08-14
// ********************************************************************* //

import '../../../domain/entity/employee_details_row.dart';
import '../../../utils/ui_controllers_models/employee_filter_model.dart';

/// Shared immutable data contract for supplemental employee table states.
abstract class EmployeeDetailsTableState<R extends EmployeeDetailsRow> {
  const EmployeeDetailsTableState({
    required this.rows,
    required this.searchQuery,
    required this.filters,
  });

  final List<R> rows;
  final String searchQuery;
  final EmployeeFilterModel filters;
}
