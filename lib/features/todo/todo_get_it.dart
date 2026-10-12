/// Module: todo
///
///*************************** FILE INFO ****************************///
/// File Name: todo_get_it.dart
/// Purpose: Declares `setupTodoDependencies` — get_it registrations for the
///          To-Do module (same mechanism as `grc_get_it.dart`).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Called once from `main()` behind an `isRegistered` guard. Data source,
/// repository and services are lazy singletons; cubits are factories so each
/// screen gets a fresh one and closing it never kills another screen's state.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/todo/data/data_source/remote_data_source/todo_notification_log_data_source.dart';
import 'package:knowticed_plus/features/todo/data/data_source/remote_data_source/todo_remote_data_source.dart';
import 'package:knowticed_plus/features/todo/data/repository/todo_notification_log_repository.dart';
import 'package:knowticed_plus/features/todo/data/repository/todo_repository_impl.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_notification_service.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_reminder_sweeper.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/controller/todo_form_cubit.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/controller/todo_actions_cubit.dart';

/// Function Name: [setupTodoDependencies]
///
/// Purpose: Register every To-Do dependency on [sl].
///
/// Parameters:
///   [GetIt] sl: normally `GetIt.instance`.
///
/// Return type: [void]
void setupTodoDependencies(GetIt sl) {
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSource(firestore: FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<TodoBaseRepository>(
    () => TodoRepositoryImpl(
      remoteDataSource: sl<TodoRemoteDataSource>(),
      access: sl<TodoAccess>(),
    ),
  );
  sl.registerLazySingleton<TodoAccess>(() => const TodoAccess());
  sl.registerLazySingleton<TodoLogService>(() => const TodoLogService());

  // Time-driven notifications (reminder / now due / day before / overdue).
  sl.registerLazySingleton<TodoNotificationLogDataSource>(
    () => TodoNotificationLogDataSource(firestore: FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<TodoNotificationLogRepository>(
    () => TodoNotificationLogRepository(
      dataSource: sl<TodoNotificationLogDataSource>(),
    ),
  );
  sl.registerLazySingleton<TodoNotificationService>(
    () => const TodoNotificationService(),
  );
  // Singleton on purpose: its in-flight guard must be shared by every list
  // cubit, so two open screens never sweep at the same time.
  sl.registerLazySingleton<TodoReminderSweeper>(
    () => TodoReminderSweeper(
      logRepository: sl<TodoNotificationLogRepository>(),
      notificationService: sl<TodoNotificationService>(),
    ),
  );

  sl.registerFactory<TodoListCubit>(
    () => TodoListCubit(
      repository: sl<TodoBaseRepository>(),
      access: sl<TodoAccess>(),
      reminderSweeper: sl<TodoReminderSweeper>(),
    ),
  );
  sl.registerFactory<TodoActionsCubit>(
    () => TodoActionsCubit(
      repository: sl<TodoBaseRepository>(),
      access: sl<TodoAccess>(),
      logService: sl<TodoLogService>(),
    ),
  );

  /// Pass the to-do being edited as param1; null opens the create form.
  sl.registerFactoryParam<TodoFormCubit, TodoEntity?, void>(
    (TodoEntity? initial, _) => TodoFormCubit(
      repository: sl<TodoBaseRepository>(),
      access: sl<TodoAccess>(),
      logService: sl<TodoLogService>(),
      initial: initial,
    ),
  );
}
