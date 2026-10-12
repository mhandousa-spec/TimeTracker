/// Module: roles / r4_active_directory / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: wrong_employee_state.dart
/// Purpose: Declares `WrongEmployeeState`, `WrongEmployeeInitial`, `WrongEmployeeLoading` (+2 more).
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of './wrong_employee_cubit.dart';

@immutable
sealed class WrongEmployeeState {}

final class WrongEmployeeInitial extends WrongEmployeeState {}

final class WrongEmployeeLoading extends WrongEmployeeState {}

/// Emitted after the wrong-employee list is (re)loaded or a record is written.
///
/// A fresh instance is created on every emit so Cubit's equality check does not
/// deduplicate consecutive refreshes.
final class WrongEmployeeUpdated extends WrongEmployeeState {}

class WrongEmployeeError extends WrongEmployeeState {
  final String message;
  WrongEmployeeError(this.message);
}
