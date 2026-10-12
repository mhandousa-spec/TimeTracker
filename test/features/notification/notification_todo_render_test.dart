/// Module: notification / test
///
///*************************** FILE INFO ****************************///
/// File Name: notification_todo_render_test.dart
/// Purpose: Pins what the inbox needs to render a To-Do notification: the
///          stored document parses tolerantly, `todo` resolves to the To-Do
///          drawer module (icon + tap target), an unknown module falls back
///          instead of throwing, and the four To-Do events are in the
///          catalog that drives the Notification Control tab.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - `Request_Id` round-trip and View → the to-do itself
///          (`NotificationRouting.todoIdFor`).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
import 'package:knowticed_plus/features/notification/domain/enums/todo_module/todo_events.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_card.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

/// The exact shape `AppNotificationSender` wrote to
/// `Demo/DM-003/Notifications` for a To-Do overdue alert (7/10/2026).
Map<String, dynamic> _todoDoc() => <String, dynamic>{
      'title': 'Task Overdue — Immediate Action Required',
      'title_ar': 'المهمة متأخرة — مطلوب إجراء فوري',
      'body': 'Submit report has exceeded its scheduled completion date.',
      'body_ar': 'تجاوزت المهمة Submit report تاريخ الإنجاز المجدول.',
      'Name_of_module': 'todo',
      'name_of_page': 'TodoList',
      'Sender_Email': 'bayanatz@knowticed.com',
      'Reciver_Email': 'bayanatz@knowticed.com',
      'Pin': false,
      'isRead': true,
      'isClean': false,
      'timestamp': 1791386013886,
    };

void main() {
  group('NotificationModelSystem.fromMap — To-Do document', () {
    test('parses every field and localises by the reader', () {
      final NotificationModelSystem n =
          NotificationModelSystem.fromMap(_todoDoc(), id: 'x');
      expect(n.nameOfModule, AppModule.todo.key);
      expect(n.nameOfPage, 'TodoList');
      expect(n.timestamp, 1791386013886);
      expect(n.titleFor(false), 'Task Overdue — Immediate Action Required');
      expect(n.titleFor(true), 'المهمة متأخرة — مطلوب إجراء فوري');
      expect(n.displayBodyFor(true), startsWith('تجاوزت'));
    });

    test('tolerates a Timestamp / double time and wrong-typed fields', () {
      final DateTime t = DateTime.utc(2026, 10, 7, 15);
      final NotificationModelSystem a = NotificationModelSystem.fromMap(
        <String, dynamic>{..._todoDoc(), 'timestamp': Timestamp.fromDate(t)},
      );
      expect(a.timestamp, t.millisecondsSinceEpoch);

      final NotificationModelSystem b = NotificationModelSystem.fromMap(
        <String, dynamic>{
          ..._todoDoc(),
          'timestamp': 1791386013886.0,
          'Pin': null,
          'title_ar': null,
          'Sender_Email': null,
        },
      );
      expect(b.timestamp, 1791386013886);
      expect(b.isPinned, isFalse);
      expect(b.titleFor(true), 'Task Overdue — Immediate Action Required');
      expect(b.senderEmail, '');
    });

    test('an empty map still builds a card-safe model', () {
      final NotificationModelSystem n =
          NotificationModelSystem.fromMap(<String, dynamic>{});
      expect(n.title, '');
      expect(n.nameOfModule, '');
      expect(n.timestamp, greaterThan(0));
    });
  });

  group('module resolution', () {
    test('todo opens the To-Do module and draws its icon', () {
      expect(NotificationRouting.moduleForStoredKey('todo'), Modules.todo);
      expect(
        NotificationCard.moduleIconPath('todo'),
        Modules.todo.iconPath,
      );
    });

    test('an unknown module falls back instead of throwing', () {
      expect(NotificationRouting.moduleForStoredKey('no_such_module'), isNull);
      expect(NotificationRouting.moduleForStoredKey(''), isNull);
      expect(
        NotificationCard.moduleIconPath('no_such_module'),
        isNotEmpty,
      );
    });
  });

  group('Request_Id — View opens the to-do', () {
    test('round-trips through toMap / fromMap, and is omitted when empty', () {
      final NotificationModelSystem withId = NotificationModelSystem.fromMap(
        <String, dynamic>{..._todoDoc(), 'Request_Id': 'todo-42'},
      );
      expect(withId.requestId, 'todo-42');
      expect(withId.toMap()['Request_Id'], 'todo-42');

      final NotificationModelSystem legacy =
          NotificationModelSystem.fromMap(_todoDoc());
      expect(legacy.requestId, '');
      expect(legacy.toMap().containsKey('Request_Id'), isFalse);
    });

    test('todoIdFor: only a To-Do notification with an id opens a record', () {
      final NotificationModelSystem withId = NotificationModelSystem.fromMap(
        <String, dynamic>{..._todoDoc(), 'Request_Id': ' todo-42 '},
      );
      expect(NotificationRouting.todoIdFor(withId, Modules.todo), 'todo-42');
      // Old notification → the module's list.
      expect(
        NotificationRouting.todoIdFor(
            NotificationModelSystem.fromMap(_todoDoc()), Modules.todo),
        isNull,
      );
      // Another module never opens a to-do, whatever it stores.
      expect(NotificationRouting.todoIdFor(withId, Modules.services), isNull);
    });
  });

  group('Notification Control catalog', () {
    test('the To-Do tab carries its four events', () {
      expect(NotificationCatalog.modules, contains(AppModule.todo));
      expect(
        NotificationCatalog.eventsOf(AppModule.todo),
        TodoNotificationEvent.values,
      );
      expect(TodoNotificationEvent.values.map((e) => e.templateId), <String>[
        'todo_to_do_reminder',
        'todo_task_overdue',
        'todo_task_now_due',
        'todo_scheduled_reminder_day_before',
      ]);
    });
  });
}
