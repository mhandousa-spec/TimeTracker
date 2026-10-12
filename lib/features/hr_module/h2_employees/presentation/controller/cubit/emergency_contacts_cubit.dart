// ***************************** FILE INFO ***************************** //
// File Name: emergency_contacts_cubit.dart
// Purpose: Joins and publishes employee emergency-contact rows.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../h3_add_employee/data/models/employee_emergency_details_model.dart';
import '../../../data/repository/emergency_contacts_repository.dart';
import '../../../domain/entity/emergency_contact_employee_row.dart';
import '../../../utils/ui_controllers_models/employee_filter_model.dart';
import 'employee_details_table_cubit.dart';
import 'employee_details_table_state.dart';

part 'emergency_contacts_state.dart';

/// Publishes emergency-contact records using shared employee table controls.
class EmergencyContactsCubit extends EmployeeDetailsTableCubit<
    EmergencyContactEmployeeRow, EmergencyContactsState> {
  EmergencyContactsCubit({
    required super.dataCubit,
    EmergencyContactsRepository? repository,
  })  : _repository = repository ?? EmergencyContactsRepository(),
        super(initialState: const EmergencyContactsInitial()) {
    initializeEmployeeDetailsTable();
    _loadEmergencyDetails();
  }

  final EmergencyContactsRepository _repository;
  Map<String, EmployeeEmergencyDetailsModel> _details = const {};

  /// Method Name: [refreshEmergencyDetails]
  ///
  /// Purpose: Reloads supplemental emergency data after a bulk update.
  Future<void> refreshEmergencyDetails() => _loadEmergencyDetails();

  /// Method Name: [_loadEmergencyDetails]
  ///
  /// Purpose: Loads complete emergency histories for employee row joins.
  Future<void> _loadEmergencyDetails() async {
    final result = await _repository.getEmergencyDetails();
    result.fold(
      (failure) => publishError(failure.message),
      (details) {
        _details = details;
        rebuildRows();
        publishLoaded();
      },
    );
  }

  /// Creates an emergency row by joining the employee with contact histories.
  @override
  EmergencyContactEmployeeRow buildRow(HrEmployeeEntity employee) =>
      EmergencyContactEmployeeRow(
        employee: employee,
        details: _details[employee.id],
      );

  /// Creates the feature's initial table state.
  @override
  EmergencyContactsState createInitialState() =>
      const EmergencyContactsInitial();

  /// Creates the feature's loading table state.
  @override
  EmergencyContactsState createLoadingState({
    required List<EmergencyContactEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      EmergencyContactsLoading(
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );

  /// Creates the feature's loaded table state.
  @override
  EmergencyContactsState createLoadedState({
    required List<EmergencyContactEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      EmergencyContactsLoaded(
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );

  /// Creates the feature's error table state.
  @override
  EmergencyContactsState createErrorState({
    required String message,
    required List<EmergencyContactEmployeeRow> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  }) =>
      EmergencyContactsError(
        message: message,
        rows: rows,
        searchQuery: searchQuery,
        filters: filters,
      );
}
