/// Module: test / todo / _support
///
///*************************** FILE INFO ****************************///
/// File Name: todo_test_fakes.dart
/// Purpose: Shared test doubles for the To-Do module: an in-memory
///          repository (records every write, can be told to throw), a
///          switchable permission service, a recording log service and a
///          recording reminder sweeper — no Firebase, no GetX controllers.
///          Also [initTestStorage], which lets widget tests tap controls that
///          fire `HapticController` (it reads GetStorage).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_reminder_sweeper.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';

/// In-memory [TodoBaseRepository].
class FakeTodoRepository implements TodoBaseRepository {
  final StreamController<List<TodoEntity>> controller =
      StreamController<List<TodoEntity>>.broadcast();

  final List<TodoEntity> updated = <TodoEntity>[];
  final List<TodoEntity> created = <TodoEntity>[];
  final List<String> watchedOwners = <String>[];

  /// When set, create/update throw it.
  Object? failWith;

  int get writeCount => updated.length + created.length;

  @override
  Stream<List<TodoEntity>> watchTodos({required String ownerEmail}) {
    watchedOwners.add(ownerEmail);
    return controller.stream;
  }

  @override
  Future<TodoEntity> createTodo({required TodoEntity todo}) async {
    final Object? error = failWith;
    if (error != null) throw error;
    created.add(todo);
    return todo;
  }

  @override
  Future<void> updateTodo({required TodoEntity todo}) async {
    final Object? error = failWith;
    if (error != null) throw error;
    updated.add(todo);
  }
}

/// [TodoAccess] whose switches the test flips.
class FakeTodoAccess implements TodoAccess {
  FakeTodoAccess({
    this.canView = true,
    this.canCreate = true,
    this.canEdit = true,
    this.canDelete = true,
    this.canRestore = true,
  });

  @override
  String get currentUserEmail => 'owner@test.local';
  @override
  bool canView;
  @override
  bool canCreate;
  @override
  bool canEdit;
  @override
  bool canDelete;
  @override
  bool canRestore;
}

/// [TodoLogService] that records instead of writing System Logs.
class FakeTodoLogService implements TodoLogService {
  final List<String> actions = <String>[];

  @override
  void log(String action) => actions.add(action);
}

/// [TodoReminderSweeper] that records each sweep call.
class FakeReminderSweeper implements TodoReminderSweeper {
  final List<List<TodoEntity>> sweeps = <List<TodoEntity>>[];
  final List<bool> arabicFlags = <bool>[];

  /// When true, [sweep] throws (the cubit must swallow it).
  bool throwOnSweep = false;

  @override
  Future<TodoSweepReport> sweep({
    required List<TodoEntity> todos,
    required String ownerEmail,
    required DateTime now,
    required bool isArabic,
  }) async {
    sweeps.add(todos);
    arabicFlags.add(isArabic);
    if (throwOnSweep) throw StateError('sweep bug');
    return const TodoSweepReport();
  }

  @override
  List<TodoDueEvent> dueEvents({
    required List<TodoEntity> todos,
    required String ownerEmail,
    required DateTime now,
  }) =>
      const <TodoDueEvent>[];
}

/// Function Name: [initTestStorage]
///
/// Purpose: Open the default GetStorage box on a temp directory (the
/// path_provider channel is mocked to answer with it) and register a
/// `HapticController`. Haptics stay OFF (nothing stored), so taps are silent.
/// Call from `setUpAll`.
///
/// Return type: [Future<void>]
Future<void> initTestStorage() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final Directory dir = Directory.systemTemp.createTempSync('todo_test_');
  // GetStorage always asks path_provider first, even with an explicit path.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async => dir.path,
  );
  await GetStorage('GetStorage', dir.path).initStorage;
  if (!Get.isRegistered<HapticController>()) Get.put(HapticController());
}

/// A plain to-do with sensible defaults for tests.
TodoEntity makeTodo(
  String id, {
  String name = 'Task',
  String description = '',
  TodoPriority priority = TodoPriority.medium,
  bool isDone = false,
  DateTime? completedAt,
  bool isDeleted = false,
  DateTime? deletedAt,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool isScheduled = false,
  DateTime? startAt,
  DateTime? endAt,
  List<TodoItem> items = const <TodoItem>[],
}) =>
    TodoEntity(
      id: id,
      ownerEmail: 'owner@test.local',
      name: name,
      description: description,
      priority: priority,
      isDone: isDone,
      completedAt: completedAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isScheduled: isScheduled,
      startAt: startAt,
      endAt: endAt,
      items: items,
    );
