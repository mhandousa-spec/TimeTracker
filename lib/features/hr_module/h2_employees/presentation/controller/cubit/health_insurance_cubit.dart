// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_cubit.dart
// Purpose: Joins and publishes employee health-insurance rows.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../h3_add_employee/data/models/employee_insurance_details_model.dart';
import '../../../data/repository/health_insurance_repository.dart';
import '../../../domain/entity/health_insurance_employee_row.dart';
import '../../../utils/ui_controllers_models/employee_filter_model.dart';
import 'employee_details_table_cubit.dart';
import 'employee_details_table_state.dart';

part 'health_insurance_state.dart';

/// Publishes insurance records using shared employee table controls.
class HealthInsuranceCubit extends EmployeeDetailsTableCubit<
    HealthInsuranceEmployeeRow, HealthInsuranceState> {
  HealthInsuranceCubit({
    required super.dataCubit,
    HealthInsuranceRepository? repository,
  })  : _repository = repository ?? HealthInsuranceRepository(),
        super(initialState: const HealthInsuranceInitial()) {
    initializeEmployeeDetailsTable();
    _loadInsuranceDetails();
  }

  final HealthInsuranceRepository _repository;
  Map<String, EmployeeInsuranceDetailsModel> _insuranceDetails = const {};

  /// Method Name: [_loadInsuranceDetails]
  ///
  /// Purpose: Loads complete insurance histories for employee row joins.
  Future<void> _loadInsuranceDetails() async {
    final result = await _repository.getInsuranceDetails();
    result.fold(
      (failure) => publishError(failure.message),
      (insuranceDetails) {
        _insuranceDetails = insuranceDetails;
        rebuildRows();
        publishLoaded();
      },
    );
  }

  /// Method Name: [refreshInsuranceDetails]
  ///
  /// Purpose: Reloads supplemental insurance histories after a write flow.
  ///
  /// Returns: Completes after the latest values have been published.
  Future<void> refreshInsuranceDetails() => _loadInsuranceDetails();

  /// Creates an insurance row by joining the employee with its full model.
  @override
  HealthInsuranceEmployeeRow buildRow(HrEmployeeEntity employee) =>
      HealthInsuranceEmployeeRow(
        employee: employee,
        insuranceDetails: _insuranceDetails[employee.id],
      );

  /// Creates the feature's initial table state.
  @override
  HealthInsuranceState createInitialState() => const HealthInsuranceInitial();

  /// Creates the feature's loading table state.
  @override
  HealthInsuranceState createLoadingState({
    required List<HealthInsuranceEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      HealthInsuranceLoading(
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );

  /// Creates the feature's loaded table state.
  @override
  HealthInsuranceState createLoadedState({
    required List<HealthInsuranceEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      HealthInsuranceLoaded(
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );

  /// Creates the feature's error table state.
  @override
  HealthInsuranceState createErrorState({
    required String message,
    required List<HealthInsuranceEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      HealthInsuranceError(
        message: message,
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );
}
