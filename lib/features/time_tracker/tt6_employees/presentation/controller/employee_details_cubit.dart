/// Module: time_tracker / tt6_employees / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details_cubit.dart
/// Purpose: Declares `EmployeeDetailsCubit` (+ `EmployeeDetailsState`) —
///          loads one employee's location history for the Employee Details
///          page (newest first).
/// Author: Knowticed Plus team
/// Created at: 13/10/2026 (owner review T8)

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_assignment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';

enum EmployeeDetailsStatus { loading, loaded, failure }

class EmployeeDetailsState {
  const EmployeeDetailsState({
    this.status = EmployeeDetailsStatus.loading,
    this.history = const <AssignmentHistoryEntry>[],
  });

  final EmployeeDetailsStatus status;

  /// Newest first.
  final List<AssignmentHistoryEntry> history;
}

class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  EmployeeDetailsCubit({required LocationAssignmentBaseRepository assignments})
      : _assignments = assignments,
        super(const EmployeeDetailsState());

  final LocationAssignmentBaseRepository _assignments;

  /// Function Name: [load]
  ///
  /// Purpose: Read [employeeEmail]'s location history.
  ///
  /// Return type: [Future<void>]
  Future<void> load(String employeeEmail) async {
    emit(const EmployeeDetailsState());
    try {
      final List<AssignmentHistoryEntry> history = await _assignments.historyOf(employeeEmail);
      if (isClosed) return;
      emit(EmployeeDetailsState(status: EmployeeDetailsStatus.loaded, history: history));
    } catch (_) {
      if (isClosed) return;
      emit(const EmployeeDetailsState(status: EmployeeDetailsStatus.failure));
    }
  }
}
