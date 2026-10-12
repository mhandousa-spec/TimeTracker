// ***************************** FILE INFO ***************************** //
// File Name: shift_employee_table_row.dart
// Purpose: Holds the resolved employee, branch, and shift values for the table.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../data/models/branch_model.dart';
import '../data/models/shift_model.dart';

/// Represents one assigned employee row after shift-management filtering.
class ShiftEmployeeTableRow {
  const ShiftEmployeeTableRow({
    required this.employee,
    required this.branch,
    required this.shift,
  });

  final HrEmployeeEntity employee;
  final BranchModel branch;
  final ShiftModel shift;
}
