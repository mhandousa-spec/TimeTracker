/// Module: roles / r4_active_directory / presentation / controller
///
part of './active_directory_controller.dart';

/// ************************* FILE INFO ******************** ///
/// FILE NAME: active_directory_state.dart
/// PURPOSE: state classes for [ActiveDirectoryController] (flutter_bloc Cubit).
/// AUTHOR: Mohamed Elrashidy
/// REFACTORED AT: migrated from GetX to Cubit
@immutable
abstract class ActiveDirectoryState {
  const ActiveDirectoryState();
}

/// Initial state emitted when the cubit is created.
class ActiveDirectoryInitial extends ActiveDirectoryState {
  const ActiveDirectoryInitial();
}

/// Generic "data changed, rebuild" state. A new instance is emitted on every
/// mutation so [BlocBuilder] rebuilds (mirrors the old GetX `update()` call).
///
/// NOTE: GetX's targeted `update([id])` / `GetBuilder(id:)` granularity is not
/// preserved — every emit rebuilds all listening [BlocBuilder]s.
class ActiveDirectoryUpdated extends ActiveDirectoryState {
  ActiveDirectoryUpdated();
}
