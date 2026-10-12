/// Module: roles / r5_system_logs / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: system_logs_state.dart
/// Purpose: Declares `SystemLogsState`, `SystemLogsInitial`, `SystemLogsUpdated` (+3 more).
/// Author: Knowticed Plus team
/// Created At: 12/8/2026

part of './system_logs_controller.dart';

@immutable
sealed class SystemLogsState {}

final class SystemLogsInitial extends SystemLogsState {}

/// Emitted whenever the logs list, filters or sort order change.
///
/// Replaces the GetX `update()` calls, which were all undifferentiated
/// "rebuild everything" notifications. A fresh instance is created on every
/// emit so Cubit's equality check does not deduplicate consecutive changes
/// (e.g. two filter updates in a row).
final class SystemLogsUpdated extends SystemLogsState {}

/// Emitted when [SystemLogsController.filterLogs] is called with no filter set.
///
/// The cubit used to pop a `CustomDialogManager.showMessage` itself, via
/// `Get.context!` — §16 forbids a cubit from driving dialogs, and the null-bang
/// on a global context is a crash waiting to happen. The page listens for this
/// and shows the warning.
final class SystemLogsNoFilterSelected extends SystemLogsState {}

/// Emitted while a CSV export is in flight.
///
/// Replaces the cubit's own `showLoadingIndicator()` call.
final class SystemLogsExporting extends SystemLogsState {}

/// Emitted after a CSV export finishes.
///
/// Replaces the cubit's `hideLoadingIndicator()` + `Navigator.pop(Get.context!)`
/// + `CustomDialogManager.showMessage(...)` sequence. [error] is null on
/// success; the page pops the dialog and reports the outcome.
final class SystemLogsExportFinished extends SystemLogsState {
  final String? error;
  SystemLogsExportFinished({this.error});

  bool get succeeded => error == null;
}
