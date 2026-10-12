/// Module: roles / r4_active_directory / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: main_core_department_state.dart
/// Purpose: Declares `MainCoreDepartmentState`, `MainCoreDepartmentInitial`, `MainCoreDepartmentLoading` (+2 more).
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of './main_core_department_cubit.dart';

sealed class MainCoreDepartmentState {
  const MainCoreDepartmentState();
}

final class MainCoreDepartmentInitial extends MainCoreDepartmentState {
  const MainCoreDepartmentInitial();
}

final class MainCoreDepartmentLoading extends MainCoreDepartmentState {
  const MainCoreDepartmentLoading();
}

final class MainCoreDepartmentLoaded extends MainCoreDepartmentState {
  final List<DepartmentModelPro> departments;
  final List<String> englishNames;
  final List<String> arabicNames;
  final List<String> departmentIds;

  const MainCoreDepartmentLoaded({
    required this.departments,
    required this.englishNames,
    required this.arabicNames,
    required this.departmentIds,
  });
}

final class MainCoreDepartmentError extends MainCoreDepartmentState {
  final String message;

  const MainCoreDepartmentError(this.message);
}
