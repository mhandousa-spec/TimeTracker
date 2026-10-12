/// Module: todo / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: todo_notification_service.dart
/// Purpose: Declares `TodoNotificationService` — every notification the
///          To-Do module sends, as intent-named methods.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - Every send carries the to-do's id (`Request_Id` on
///          the notification) so the inbox's View opens that to-do.
///
/// Same pattern as `KnowledgeHubNotificationService`: nothing here is a raw
/// string — the event comes from `TodoNotificationEvent`, the landing page
/// from `TodoNotificationPage`, the placeholder from `TemplateVariable`.
/// Everything goes through `AppNotificationSender.sendEvent`, so the module
/// gets the admin-edited template, the enabled/disabled switch, both language
/// renderings and the FCM push for free.
///
/// To-dos are PERSONAL (owner decision 7/10/2026): every method sends to the
/// to-do's owner only, and the owner is also the sender — these are
/// system-raised reminders about the user's own list.
///
/// `AppNotificationSender.sendEvent` resolves to `false` on failure rather
/// than throwing, so no try/catch is needed here. Injectable (get_it) instead
/// of static, so the sweeper can be handed a fake in tests.

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/todo_module/todo_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/todo_module/todo_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class TodoNotificationService {
  /// Same sender the account-status alerts use, so the inbox draws these as
  /// system notifications.
  static const String _systemSender = 'system@company.com';

  const TodoNotificationService();

  /// Function Name: [remindBeforeStart]
  ///
  /// Purpose: "Task Reminder" — one configured reminder ("N units before the
  /// start time") has come due.
  ///
  /// Parameters:
  ///   [String] ownerEmail: the to-do's owner (sender and receiver).
  ///   [String] todoName: substituted into `{{toDoName}}`.
  ///   [bool] isArabic: the sender's active language.
  ///   [String] todoId: the to-do's id, stored as the notification's
  ///   `Request_Id` so View opens its details ('' → the module list).
  ///
  /// Return type: [Future<bool>] — true when the notification was stored.
  Future<bool> remindBeforeStart({
    required String ownerEmail,
    required String todoName,
    required bool isArabic,
    String todoId = '',
  }) =>
      send(
        event: TodoNotificationEvent.toDoReminder,
        ownerEmail: ownerEmail,
        todoName: todoName,
        isArabic: isArabic,
        todoId: todoId,
      );

  /// Function Name: [notifyNowDue]
  ///
  /// Purpose: "Task Due — Action Required" — a scheduled to-do's start time
  /// has been reached.
  ///
  /// Parameters:
  ///   [String] ownerEmail
  ///   [String] todoName
  ///   [bool] isArabic
  ///
  /// Return type: [Future<bool>]
  Future<bool> notifyNowDue({
    required String ownerEmail,
    required String todoName,
    required bool isArabic,
    String todoId = '',
  }) =>
      send(
        event: TodoNotificationEvent.taskNowDue,
        ownerEmail: ownerEmail,
        todoName: todoName,
        isArabic: isArabic,
        todoId: todoId,
      );

  /// Function Name: [remindDayBeforeEnd]
  ///
  /// Purpose: "Upcoming Task — Advance Reminder" — the day before the to-do's
  /// END date.
  ///
  /// Parameters:
  ///   [String] ownerEmail
  ///   [String] todoName
  ///   [bool] isArabic
  ///
  /// Return type: [Future<bool>]
  Future<bool> remindDayBeforeEnd({
    required String ownerEmail,
    required String todoName,
    required bool isArabic,
    String todoId = '',
  }) =>
      send(
        event: TodoNotificationEvent.scheduledReminderDayBefore,
        ownerEmail: ownerEmail,
        todoName: todoName,
        isArabic: isArabic,
        todoId: todoId,
      );

  /// Function Name: [notifyOverdue]
  ///
  /// Purpose: "Task Overdue — Immediate Action Required" — the end time has
  /// passed and the to-do is not done.
  ///
  /// Parameters:
  ///   [String] ownerEmail
  ///   [String] todoName
  ///   [bool] isArabic
  ///
  /// Return type: [Future<bool>]
  Future<bool> notifyOverdue({
    required String ownerEmail,
    required String todoName,
    required bool isArabic,
    String todoId = '',
  }) =>
      send(
        event: TodoNotificationEvent.taskOverdue,
        ownerEmail: ownerEmail,
        todoName: todoName,
        isArabic: isArabic,
        todoId: todoId,
      );

  /// Function Name: [send]
  ///
  /// Purpose: The one place a To-Do event is dispatched. Public so the
  /// sweeper can dispatch by event without a switch; screens should call the
  /// intent-named methods above.
  ///
  /// A to-do has a single name (no EN/AR pair), so the same value fills both
  /// renderings.
  ///
  /// Parameters:
  ///   [TodoNotificationEvent] event
  ///   [String] ownerEmail
  ///   [String] todoName
  ///   [bool] isArabic
  ///   [String] todoId: stored as `Request_Id`; View on the inbox card opens
  ///   this to-do's details. Optional so a caller without one still sends.
  ///
  /// Return type: [Future<bool>] — false for an empty owner or a failed send.
  Future<bool> send({
    required TodoNotificationEvent event,
    required String ownerEmail,
    required String todoName,
    required bool isArabic,
    String todoId = '',
  }) async {
    final String owner = ownerEmail.trim().toLowerCase();
    if (owner.isEmpty) return false;
    final Map<TemplateVariable, String> variables = <TemplateVariable, String>{
      TemplateVariable.toDoName: todoName.trim(),
    };
    return AppNotificationSender.sendEvent(
      event: event,
      pageKey: TodoNotificationPage.todoList.key,
      // System-sent (owner, 7/10/2026): reminders come from the system, like
      // the account-status alerts — not "from yourself" with your own avatar.
      senderEmail: _systemSender,
      receiverEmail: owner,
      isArabic: isArabic,
      variables: variables,
      variablesAr: variables,
      requestId: todoId.trim(),
    );
  }
}
