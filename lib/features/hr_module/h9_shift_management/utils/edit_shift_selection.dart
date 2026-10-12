// ***************************** FILE INFO ***************************** //
// File Name: edit_shift_selection.dart
// Purpose: Carries temporary employee edit selections between flow pages.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import '../presentation/controller/shift_management_cubit.dart';

/// Holds the temporary values selected on the first edit-flow page.
class EditShiftSelection {
  const EditShiftSelection({
    required this.cubit,
    required this.employeeIds,
    required this.locationId,
    required this.branchId,
    required this.shiftId,
  });

  final ShiftManagementCubit cubit;
  final Set<String> employeeIds;
  final String locationId;
  final String? branchId;
  final String? shiftId;
}
