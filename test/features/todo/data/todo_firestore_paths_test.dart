/// Module: test / todo / data
///
///*************************** FILE INFO ****************************///
/// File Name: todo_firestore_paths_test.dart
/// Purpose: Unit tests for `TodoFirestorePaths` — the per-email folder
///          (`Modules/todo/{email}`): lower-cased + trimmed
///          email key, and refusal of an empty / path-breaking email.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/domain/constants/todo_firestore_paths.dart';

void main() {
  group('todosOf / notificationLogOf', () {
    test('builds the per-email paths with a trimmed, lower-cased email', () {
      expect(
        TodoFirestorePaths.todosOf('  Moataz@Bayanatz.COM '),
        'Modules/todo/moataz@bayanatz.com',
      );
      expect(
        TodoFirestorePaths.notificationLogOf('Moataz@Bayanatz.com'),
        'Modules/todo_notification_log/moataz@bayanatz.com',
      );
    });

    test('rejects an empty or blank email (never an unscoped path)', () {
      expect(() => TodoFirestorePaths.todosOf(''), throwsStateError);
      expect(() => TodoFirestorePaths.todosOf('   '), throwsStateError);
      expect(() => TodoFirestorePaths.notificationLogOf(''), throwsStateError);
    });

    test('rejects an email that would split the path', () {
      expect(() => TodoFirestorePaths.todosOf('a/b@c.com'), throwsStateError);
    });
  });
}
