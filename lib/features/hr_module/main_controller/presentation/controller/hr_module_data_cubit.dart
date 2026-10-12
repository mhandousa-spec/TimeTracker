// ***************************** FILE INFO ***************************** //
// File Name: hr_module_data_cubit.dart
// Purpose: Publishes shared HR employee and department source data.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/helper/role/main_core_employee_controller.dart';
import '../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../../../roles/r4_active_directory/domain/entities/employee_entity.dart';
import '../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../domain/entity/hr_employee_entity.dart';

part 'hr_module_data_state.dart';

/// HR module source of truth for the employee and department data it consumes.
class HrModuleDataCubit extends Cubit<HrModuleDataState> {
  HrModuleDataCubit({
    required MainCoreEmployeeController employeeController,
    required MainCoreDepartmentCubit departmentCubit,
  })  : _employeeController = employeeController,
        _departmentCubit = departmentCubit,
        super(const HrModuleDataInitial());

  final MainCoreEmployeeController _employeeController;
  final MainCoreDepartmentCubit _departmentCubit;

  /// Publishes the available cached data and fetches only missing sources.
  Future<void> load() async {
    await _loadData();
  }

  /// Refreshes the employee source after an HR employee write succeeds.
  Future<void> refreshEmployees() async {
    await _loadData(refreshEmployees: true);
  }

  /// Refreshes the department source after an HR department write succeeds.
  Future<void> refreshDepartments() async {
    await _loadData(refreshDepartments: true);
  }

  /// Refreshes both sources after an HR workflow changes both data sets.
  Future<void> refreshData() async {
    await _loadData(
      refreshEmployees: true,
      refreshDepartments: true,
    );
  }

  /// Method Name: [_loadData]
  ///
  /// Purpose: Loads or refreshes the requested shared HR source data.
  ///
  /// Parameters:
  /// - [refreshEmployees]: Whether to force an employee source refresh.
  /// - [refreshDepartments]: Whether to force a department source refresh.
  ///
  /// Returns: Emits loading followed by loaded or error state.
  Future<void> _loadData({
    bool refreshEmployees = false,
    bool refreshDepartments = false,
  }) async {
    var employees = _currentEmployees();
    var departments = _currentDepartments();

    emit(HrModuleDataLoading(
      employees: employees,
      departments: departments,
    ));

    try {
      final operations = <Future<void>>[];
      if (refreshEmployees || employees.isEmpty) {
        operations.add(_employeeController.refreshEmployeeData());
      }
      if (refreshDepartments || departments.isEmpty) {
        operations.add(_departmentCubit.getAllDepartments());
      }
      await Future.wait(operations);

      employees = _currentEmployees();
      departments = _currentDepartments();
      emit(HrModuleDataLoaded(
        employees: employees,
        departments: departments,
      ));
    } catch (error) {
      emit(HrModuleDataError(
        message: error.toString(),
        employees: employees,
        departments: departments,
      ));
    }
  }

  /// Method Name: [_currentEmployees]
  ///
  /// Purpose: Copies the latest employee list from the host controller.
  ///
  /// Returns: A mutable snapshot for state construction.
  List<HrEmployeeEntity> _currentEmployees() {
    return List<EmployeeEntityPro>.from(
      _employeeController.allEmployeesEntities ?? const [],
    ).map(HrEmployeeEntity.fromEmployee).toList();
  }

  /// Method Name: [_currentDepartments]
  ///
  /// Purpose: Copies the latest department list from the host cubit.
  ///
  /// Returns: A mutable snapshot for state construction.
  List<DepartmentModelPro> _currentDepartments() {
    return List<DepartmentModelPro>.from(_departmentCubit.departmentModels);
  }
}
