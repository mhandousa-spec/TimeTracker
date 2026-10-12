// ***************************** FILE INFO ***************************** //
// File Name: employee_details_cubit.dart
// Purpose: Loads and retries supplemental employee detail data.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

import '../../../data/repository/employee_details_repository.dart';
import 'employee_details_state.dart';

/// Presentation controller for one read-only employee profile.
class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  EmployeeDetailsCubit({
    required HrEmployeeEntity employee,
    EmployeeDetailsRepository? repository,
  })  : _repository = repository ?? EmployeeDetailsRepository(),
        super(EmployeeDetailsInitial(employee));

  final EmployeeDetailsRepository _repository;

  /// Method Name: [load]
  ///
  /// Purpose: Loads the selected employee's optional HR detail records.
  ///
  /// Returns: Emits loading followed by a loaded or error state.
  Future<void> load() async {
    emit(EmployeeDetailsLoading(state.employee));
    final result = await _repository.getEmployeeDetails(state.employee);
    result.fold(
      (failure) => emit(
        EmployeeDetailsError(
            employee: state.employee, message: failure.message),
      ),
      (data) => emit(EmployeeDetailsLoaded(data)),
    );
  }

  /// Method Name: [retry]
  ///
  /// Purpose: Retries a failed employee detail request.
  ///
  /// Returns: Starts a new detail request.
  Future<void> retry() => load();
}
