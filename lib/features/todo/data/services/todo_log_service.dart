/// Module: todo / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: todo_log_service.dart
/// Purpose: Declares `TodoLogService` — writes To-Do actions to System Logs.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Actions agreed with the owner 7/10/2026 (the spec doc has no To-Do
/// section): Create · Update · Delete · Restore · Mark Done · Reopen ·
/// Change Priority · Set Recurrence. Same pattern as `RoleLogService`, but
/// injectable so cubits receive it through get_it instead of a static call.
///
/// `SystemLogsController.systemLogsAction` is documented fire-and-forget and
/// never throws, so no try/catch is needed here.

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

class TodoLogService {
  const TodoLogService();

  static const String actionCreate = 'create to do';
  static const String actionUpdate = 'update to do';
  static const String actionDelete = 'delete to do';
  static const String actionRestore = 'restore to do';
  static const String actionMarkDone = 'mark to do done';
  static const String actionReopen = 'reopen to do';
  static const String actionChangePriority = 'change to do priority';
  static const String actionSetRecurrence = 'set to do recurrence';

  /// Function Name: [log]
  ///
  /// Purpose: Record one To-Do activity under `Modules.todo`.
  ///
  /// Parameters:
  ///   [String] action: one of the `action…` constants above.
  ///
  /// Return type: [void] — fire-and-forget.
  void log(String action) {
    AppControllers.systemLogs.systemLogsAction(action, module: Modules.todo);
  }
}
