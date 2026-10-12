part of 'hr_module_data_cubit.dart';

// ***************************** FILE INFO ***************************** //
// File Name: hr_module_data_state.dart
// Purpose: Defines the shared HR employee and department data states.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

sealed class HrModuleDataState {
  const HrModuleDataState();
}

final class HrModuleDataInitial extends HrModuleDataState {
  const HrModuleDataInitial();
}

final class HrModuleDataLoading extends HrModuleDataState {
  const HrModuleDataLoading({
    required this.employees,
    required this.departments,
  });

  final List<HrEmployeeEntity> employees;
  final List<DepartmentModelPro> departments;
}

final class HrModuleDataLoaded extends HrModuleDataState {
  HrModuleDataLoaded({
    required List<HrEmployeeEntity> employees,
    required List<DepartmentModelPro> departments,
  })  : employees = List.unmodifiable(employees),
        departments = List.unmodifiable(departments);

  final List<HrEmployeeEntity> employees;
  final List<DepartmentModelPro> departments;
}

final class HrModuleDataError extends HrModuleDataState {
  HrModuleDataError({
    required this.message,
    required List<HrEmployeeEntity> employees,
    required List<DepartmentModelPro> departments,
  })  : employees = List.unmodifiable(employees),
        departments = List.unmodifiable(departments);

  final String message;
  final List<HrEmployeeEntity> employees;
  final List<DepartmentModelPro> departments;
}
