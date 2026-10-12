/// Module: todo / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: todo_reminder_sweeper.dart
/// Purpose: Declares `TodoReminderSweeper` — the client-side sweep that
///          raises the four time-driven To-Do notifications (Task Reminder,
///          Task Due, Advance Reminder, Task Overdue).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// ─── WHY THIS EXISTS ─────────────────────────────────────────────────────
///
/// All four To-Do notifications are consequences of TIME, not of a tap, and
/// the app has no server-side scheduler. So, like
/// `KnowledgeHubNotificationScheduler`, the sweep runs on the client: the
/// To-Do list cubit runs it after its first snapshot and then at most every
/// 15 minutes while the module is open. A notification is therefore raised
/// the first time the OWNER has the To-Do module open on or after its due
/// time — not at the exact minute. A Cloud Function is the real fix and would
/// replace this file.
///
/// ─── RULES ───────────────────────────────────────────────────────────────
///
/// Only scheduled to-dos (`isScheduled` with a `startAt`) that are neither
/// done nor deleted, and only the signed-in owner's own to-dos (personal
/// module). For each OCCURRENCE start `s` (the start itself, or — for a
/// recurring to-do — every day `TodoFrequency.occursOn` accepts, at the start
/// time of day) with occurrence end `e = s + (endAt - startAt)`:
///
///   • to_do_reminder                 due `s - offset` for every reminder,
///                                    stale once `s` has passed;
///   • task_now_due                   due `s`, stale once `e` has passed;
///   • scheduled_reminder_day_before  due `e - 1 day`, stale once `e` passed;
///   • task_overdue                   due `endAt` (the to-do's own end, once —
///                                    not per occurrence), while not done.
///
/// An event is sent when its due time is in `(now - 7 days, now]` — never in
/// the future, and missed ones still go out once if the module was not open
/// at the time. Overdue is exempt from the 7-day limit because it describes
/// a state that is still true now. Events due before the to-do was created
/// are skipped (except overdue), so creating a to-do whose start is already
/// past does not fire its old reminders.
///
/// ─── HOW IT AVOIDS SENDING TWICE ─────────────────────────────────────────
///
/// Before sending, a marker `<todoId>__<eventKey>__<dueMillis>` is created in
/// the owner's `Modules/todo_notification_log/{email}` inside a
/// transaction; only the call that created it sends. Changing a to-do's
/// dates changes `dueMillis`, so the owner is told about the NEW time. If the
/// log cannot be reached the event is NOT sent and the next sweep retries.
///
/// Never throws for Firestore or send failures: the repository and
/// `AppNotificationSender` both resolve to a value instead. Callers should
/// still fire-and-forget it from a guarded context.

import 'package:knowticed_plus/features/notification/domain/enums/todo_module/todo_events.dart';
import 'package:knowticed_plus/features/todo/data/repository/todo_notification_log_repository.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_notification_service.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';

/// One notification the sweep has decided is due.
class TodoDueEvent {
  const TodoDueEvent({
    required this.todo,
    required this.event,
    required this.dueAt,
  });

  final TodoEntity todo;
  final TodoNotificationEvent event;
  final DateTime dueAt;
}

/// What one sweep did — returned so a caller (or a test) can assert on it.
class TodoSweepReport {
  const TodoSweepReport({
    this.due = 0,
    this.sent = 0,
    this.alreadySent = 0,
    this.failed = 0,
    this.skippedBusy = false,
  });

  /// Events that were due in the window.
  final int due;

  /// Notifications actually stored.
  final int sent;

  /// Due, but marked in the log by an earlier sweep (any device).
  final int alreadySent;

  /// Log unreachable, or the send itself failed.
  final int failed;

  /// Another sweep was still running, so this one did nothing.
  final bool skippedBusy;

  @override
  String toString() => 'TodoSweepReport(due: $due, sent: $sent, '
      'alreadySent: $alreadySent, failed: $failed, busy: $skippedBusy)';
}

class TodoReminderSweeper {
  TodoReminderSweeper({
    required TodoNotificationLogRepository logRepository,
    required TodoNotificationService notificationService,
  })  : _log = logRepository,
        _notifications = notificationService;

  final TodoNotificationLogRepository _log;
  final TodoNotificationService _notifications;

  /// How far back a missed event is still sent.
  static const Duration lookBack = Duration(days: 7);

  /// Upper bound on the days scanned per recurring to-do (a reminder can be
  /// many weeks before the start, which widens the scan).
  static const int maxScanDays = 400;

  bool _running = false;

  /// Function Name: [sweep]
  ///
  /// Purpose: Work out which events are due for [todos] at [now], claim each
  /// in the notification log, and send the ones this call claimed.
  ///
  /// Parameters:
  ///   [List<TodoEntity>] todos: the owner's live to-dos.
  ///   [String] ownerEmail: the signed-in user; other owners are ignored.
  ///   [DateTime] now: the clock to evaluate against.
  ///   [bool] isArabic: the user's language when the sweep runs.
  ///
  /// Return type: [Future<TodoSweepReport>]
  Future<TodoSweepReport> sweep({
    required List<TodoEntity> todos,
    required String ownerEmail,
    required DateTime now,
    required bool isArabic,
  }) {
    if (_running) {
      return Future<TodoSweepReport>.value(
        const TodoSweepReport(skippedBusy: true),
      );
    }
    _running = true;
    return _send(
      dueEvents(todos: todos, ownerEmail: ownerEmail, now: now),
      isArabic: isArabic,
    ).whenComplete(() => _running = false);
  }

  Future<TodoSweepReport> _send(
    List<TodoDueEvent> events, {
    required bool isArabic,
  }) async {
    int sent = 0;
    int alreadySent = 0;
    int failed = 0;
    for (final TodoDueEvent due in events) {
      final TodoClaimResult claim = await _log.claim(
        todoId: due.todo.id,
        eventKey: due.event.key,
        dueMillis: due.dueAt.millisecondsSinceEpoch,
        ownerEmail: due.todo.ownerEmail,
      );
      switch (claim) {
        case TodoClaimResult.alreadySent:
          alreadySent++;
        case TodoClaimResult.failed:
          failed++;
        case TodoClaimResult.claimed:
          final bool ok = await _notifications.send(
            event: due.event,
            ownerEmail: due.todo.ownerEmail,
            todoName: due.todo.name,
            isArabic: isArabic,
            // View on the inbox card opens this to-do (7/10/2026).
            todoId: due.todo.id,
          );
          if (ok) {
            sent++;
          } else {
            failed++;
          }
      }
    }
    return TodoSweepReport(
      due: events.length,
      sent: sent,
      alreadySent: alreadySent,
      failed: failed,
    );
  }

  /// Function Name: [dueEvents]
  ///
  /// Purpose: The pure half of the sweep — every event due at [now], oldest
  /// first, with no I/O. See the file header for the rules.
  ///
  /// Parameters:
  ///   [List<TodoEntity>] todos
  ///   [String] ownerEmail
  ///   [DateTime] now
  ///
  /// Return type: [List<TodoDueEvent>]
  List<TodoDueEvent> dueEvents({
    required List<TodoEntity> todos,
    required String ownerEmail,
    required DateTime now,
  }) {
    final String owner = ownerEmail.trim().toLowerCase();
    final List<TodoDueEvent> result = <TodoDueEvent>[];
    for (final TodoEntity todo in todos) {
      if (!_isEligible(todo, owner)) continue;
      result.addAll(_dueFor(todo, now));
    }
    result.sort((TodoDueEvent a, TodoDueEvent b) => a.dueAt.compareTo(b.dueAt));
    return result;
  }

  bool _isEligible(TodoEntity todo, String owner) =>
      owner.isNotEmpty &&
      todo.id.isNotEmpty &&
      todo.ownerEmail.trim().toLowerCase() == owner &&
      !todo.isDone &&
      !todo.isDeleted &&
      todo.isScheduled &&
      todo.startAt != null;

  List<TodoDueEvent> _dueFor(TodoEntity todo, DateTime now) {
    final DateTime start = todo.startAt!;
    final DateTime? end = todo.endAt;
    final Duration? span =
        (end != null && end.isAfter(start)) ? end.difference(start) : null;
    final Set<Duration> offsets = todo.reminders
        .map((TodoReminder r) => r.offset)
        .where((Duration d) => d > Duration.zero)
        .toSet();

    final Map<String, TodoDueEvent> found = <String, TodoDueEvent>{};
    void add(TodoNotificationEvent event, DateTime dueAt) {
      if (!_inWindow(todo, event, dueAt, now)) return;
      found['${event.key}__${dueAt.millisecondsSinceEpoch}'] =
          TodoDueEvent(todo: todo, event: event, dueAt: dueAt);
    }

    for (final DateTime s
        in _occurrenceStarts(todo, start, span, offsets, now)) {
      final DateTime? e = span == null ? null : s.add(span);
      if (s.isAfter(now)) {
        for (final Duration offset in offsets) {
          add(TodoNotificationEvent.toDoReminder, s.subtract(offset));
        }
      }
      if (e == null || e.isAfter(now)) {
        add(TodoNotificationEvent.taskNowDue, s);
      }
      if (e != null && e.isAfter(now)) {
        add(
          TodoNotificationEvent.scheduledReminderDayBefore,
          e.subtract(const Duration(days: 1)),
        );
      }
    }

    if (end != null && todo.isOverdue(now)) {
      add(TodoNotificationEvent.taskOverdue, end);
    }
    return found.values.toList();
  }

  /// Due now or earlier, inside the look-back (overdue exempt), and not
  /// before the to-do existed (overdue exempt).
  bool _inWindow(
    TodoEntity todo,
    TodoNotificationEvent event,
    DateTime dueAt,
    DateTime now,
  ) {
    if (dueAt.isAfter(now)) return false;
    if (event == TodoNotificationEvent.taskOverdue) return true;
    if (!dueAt.isAfter(now.subtract(lookBack))) return false;
    final DateTime? created = todo.createdAt;
    return created == null || !dueAt.isBefore(created);
  }

  /// The occurrence start times whose events could fall in the window: just
  /// [start] for a one-off to-do; for a recurring one, every day from
  /// `now - lookBack - span` to `now + largest reminder offset` that the
  /// recurrence lands on, at the start's time of day.
  List<DateTime> _occurrenceStarts(
    TodoEntity todo,
    DateTime start,
    Duration? span,
    Set<Duration> offsets,
    DateTime now,
  ) {
    if (!todo.hasFrequency) return <DateTime>[start];

    final Duration maxOffset = offsets.isEmpty
        ? Duration.zero
        : offsets.reduce((Duration a, Duration b) => a > b ? a : b);
    final DateTime anchor = todo.recurrenceAnchor ?? start;
    final DateTime anchorDay = _dayOf(anchor);
    DateTime day =
        _dayOf(now.subtract(lookBack).subtract(span ?? Duration.zero));
    if (day.isBefore(anchorDay)) day = anchorDay;
    final DateTime lastDay = _dayOf(now.add(maxOffset));

    final List<DateTime> starts = <DateTime>[];
    for (int i = 0; i < maxScanDays && !day.isAfter(lastDay); i++) {
      if (todo.frequency.occursOn(anchor: anchor, day: day)) {
        starts.add(
          DateTime(day.year, day.month, day.day, start.hour, start.minute),
        );
      }
      // Calendar-day step (not +24h), so a DST change cannot skip a day.
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return starts;
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
