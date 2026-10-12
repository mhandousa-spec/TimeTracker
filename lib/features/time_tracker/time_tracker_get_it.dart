/// Module: time_tracker
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_get_it.dart
/// Purpose: Declares `setupTimeTrackerDependencies` — get_it registrations
///          for the Time Tracker module (same mechanism as `todo_get_it.dart`).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Called once from `main()` behind an `isRegistered` guard. Data sources,
/// repositories, services and the work-set-up sources are lazy singletons;
/// cubits are factories so each screen gets a fresh one.
///
/// Updated: 8/10/2026 - phase 2: manager resolver (decision 18), absent-day
/// sweeper (20), device location, attachment upload, transaction service and
/// the Check In / Dashboard / Attendance / Transaction cubits.
/// Updated: 9/10/2026 - phase 3: employee directory, sheet reader, group
/// service and the Locations / Employees / Groups / Request Types cubits
/// (the form cubits take the record being edited as `param1`).
/// Updated: 9/10/2026 - phase 4: role reader + approver directory,
/// notifications, request effects, Request / Approval services and the
/// Requests / Request Actions / Request Form cubits; the transaction service
/// now notifies the first approver.
/// Updated: 9/10/2026 - phase 6: Notification_Log repository + the reminder
/// sweeper (missed check-in / check-out, pending approvals).
/// Updated: 9/10/2026 - phase 5: HR dashboard data source / repository /
/// cubit and the Vacation Balances cubit.
/// Updated: 9/10/2026 - code review: `RequestEffects` only plans (the
/// request repository writes request + effects in one transaction); the
/// approver directory knows who may read the company's requests; the
/// transaction service reads the schedule (overnight rule); the Requests /
/// Attendance cubits get the approver directory / work set-up resolver.
/// Updated: 9/10/2026 - UI quality pass: the DEBUG-ONLY demo data service +
/// cubit (appended at the end).
/// Updated: 9/10/2026 - data model: `RequestCommentBaseRepository`
/// (`Requests/{id}/Comments`), passed to `RequestService`.
/// Updated: 9/10/2026 - QA KP-TT-015: `TodayAttendanceHub` (lazy singleton,
/// the shared check-in state) passed to every `CheckInCubit`.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/company_modules_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/hr_work_setup_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/group_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/hr_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_assignment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_comment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_type_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/company_modules_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/today_attendance_hub.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_assignment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_comment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/vacation_balance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/employee_directory_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_storage_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attachment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/geolocator_location_repository.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/org_chart_manager_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/absent_day_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/manager_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/controller/transaction_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/local_data_source/time_tracker_sheet_reader.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/employee_directory_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/group_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/location_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/controller/group_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_type_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/role_approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/approval_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_effects.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/controller/request_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_notification_log_repository.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_reminder_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_dashboard_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/hr_dashboard_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/hr_dashboard_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_service.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_demo_cubit.dart';

/// Function Name: [setupTimeTrackerDependencies]
///
/// Purpose: Register every Time Tracker dependency on [sl].
///
/// Parameters:
///   [GetIt] sl: normally `GetIt.instance`.
///
/// Return type: [void]
void setupTimeTrackerDependencies(GetIt sl) {
  // Services.
  sl.registerLazySingleton<TimeTrackerAccess>(() => const TimeTrackerAccess());
  sl.registerLazySingleton<TimeTrackerLogService>(
    () => const TimeTrackerLogService(),
  );

  // Data sources.
  sl.registerLazySingleton<TimeTrackerRemoteDataSource>(
    () => TimeTrackerRemoteDataSource(firestore: FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<HrWorkSetupRemoteDataSource>(
    () => HrWorkSetupRemoteDataSource(firestore: FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<CompanyModulesRemoteDataSource>(
    () => CompanyModulesRemoteDataSource(firestore: FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<CompanyModulesService>(
    () => CompanyModulesService(
      dataSource: sl<CompanyModulesRemoteDataSource>(),
    ),
  );

  // Repositories (one per collection).
  sl.registerLazySingleton<AttendanceBaseRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerLazySingleton<RequestBaseRepository>(
    () => RequestRepositoryImpl(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  // 9/10/2026 (data model): Requests/{id}/Comments, one document per comment.
  sl.registerLazySingleton<RequestCommentBaseRepository>(
    () => RequestCommentRepositoryImpl(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerLazySingleton<RequestTypeBaseRepository>(
    () => RequestTypeRepositoryImpl(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerLazySingleton<LocationBaseRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerLazySingleton<LocationAssignmentBaseRepository>(
    () => LocationAssignmentRepositoryImpl(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerLazySingleton<GroupBaseRepository>(
    () => GroupRepositoryImpl(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerLazySingleton<VacationBalanceBaseRepository>(
    () => VacationBalanceRepositoryImpl(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );

  // Work set-up: Time Tracker-owned vs HR-owned, picked per company.
  sl.registerLazySingleton<TimeTrackerWorkSetupSource>(
    () => TimeTrackerWorkSetupSource(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<HrWorkSetupSource>(
    () => HrWorkSetupSource(remoteDataSource: sl<HrWorkSetupRemoteDataSource>()),
  );
  sl.registerLazySingleton<WorkSetupSourceResolver>(
    () => WorkSetupSourceResolver(
      companyModules: sl<CompanyModulesService>(),
      timeTrackerSource: sl<TimeTrackerWorkSetupSource>(),
      hrSource: sl<HrWorkSetupSource>(),
    ),
  );

  // Phase 2 (8/10/2026).
  sl.registerLazySingleton<EmployeeDirectoryRemoteDataSource>(
    () => EmployeeDirectoryRemoteDataSource(firestore: FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<ManagerResolver>(
    () => OrgChartManagerResolver(
      remoteDataSource: sl<EmployeeDirectoryRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<DeviceLocationReader>(
    () => const GeolocatorLocationRepository(),
  );
  sl.registerLazySingleton<TimeTrackerStorageRemoteDataSource>(
    () => TimeTrackerStorageRemoteDataSource(),
  );
  sl.registerLazySingleton<AttachmentBaseRepository>(
    () => AttachmentRepositoryImpl(
      remoteDataSource: sl<TimeTrackerStorageRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<AbsentDaySweeper>(
    () => AbsentDaySweeper(
      attendance: sl<AttendanceBaseRepository>(),
      requests: sl<RequestBaseRepository>(),
      resolver: sl<WorkSetupSourceResolver>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerLazySingleton<TransactionService>(
    () => TransactionService(
      requests: sl<RequestBaseRepository>(),
      managers: sl<ManagerResolver>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
      // Phase 4 (9/10/2026): notify the first approver.
      approvers: sl<ApproverDirectory>(),
      notifier: sl<TimeTrackerNotificationService>(),
      // Code review (9/10/2026): the shift decides the next-day rule.
      resolver: sl<WorkSetupSourceResolver>(),
    ),
  );

  // Cubits.
  sl.registerFactory<TimeTrackerHomeCubit>(
    () => TimeTrackerHomeCubit(
      access: sl<TimeTrackerAccess>(),
      resolver: sl<WorkSetupSourceResolver>(),
      sweeper: sl<AbsentDaySweeper>(),
    ),
  );
  // QA KP-TT-015 (9/10/2026): ONE shared check-in state for the module
  // header and every Home quick card (each still gets its own cubit).
  sl.registerLazySingleton<TodayAttendanceHub>(
    () => TodayAttendanceHub(attendance: sl<AttendanceBaseRepository>()),
  );
  sl.registerFactory<CheckInCubit>(
    () => CheckInCubit(
      attendance: sl<AttendanceBaseRepository>(),
      resolver: sl<WorkSetupSourceResolver>(),
      location: sl<DeviceLocationReader>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
      hub: sl<TodayAttendanceHub>(),
    ),
  );
  sl.registerFactory<PersonalDashboardCubit>(
    () => PersonalDashboardCubit(
      attendance: sl<AttendanceBaseRepository>(),
      requests: sl<RequestBaseRepository>(),
      balances: sl<VacationBalanceBaseRepository>(),
      resolver: sl<WorkSetupSourceResolver>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerFactory<AttendanceCubit>(
    () => AttendanceCubit(
      attendance: sl<AttendanceBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
      // Code review (9/10/2026, finding 1): the schedule hides untrusted
      // absent rows.
      resolver: sl<WorkSetupSourceResolver>(),
    ),
  );
  sl.registerFactory<TransactionFormCubit>(
    () => TransactionFormCubit(
      service: sl<TransactionService>(),
      attachments: sl<AttachmentBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );

  // Phase 3 (9/10/2026) — Locations, Employees / Groups, Request Types.
  sl.registerLazySingleton<EmployeeDirectoryBaseRepository>(
    () => const EmployeeDirectoryRepositoryImpl(),
  );
  sl.registerLazySingleton<TimeTrackerSheetReader>(() => const TimeTrackerSheetReader());
  sl.registerLazySingleton<GroupService>(
    () => GroupService(
      groups: sl<GroupBaseRepository>(),
      assignments: sl<LocationAssignmentBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
    ),
  );
  sl.registerFactory<LocationsCubit>(
    () => LocationsCubit(
      locations: sl<LocationBaseRepository>(),
      assignments: sl<LocationAssignmentBaseRepository>(),
      resolver: sl<WorkSetupSourceResolver>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
    ),
  );
  sl.registerFactoryParam<LocationFormCubit, WorkLocation?, void>(
    (WorkLocation? original, _) => LocationFormCubit(
      locations: sl<LocationBaseRepository>(),
      device: sl<DeviceLocationReader>(),
      resolver: sl<WorkSetupSourceResolver>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
      original: original,
    ),
  );
  sl.registerFactory<EmployeesCubit>(
    () => EmployeesCubit(
      directory: sl<EmployeeDirectoryBaseRepository>(),
      assignments: sl<LocationAssignmentBaseRepository>(),
      groups: sl<GroupBaseRepository>(),
      locations: sl<LocationBaseRepository>(),
      groupService: sl<GroupService>(),
      resolver: sl<WorkSetupSourceResolver>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
    ),
  );
  sl.registerFactoryParam<GroupFormCubit, EmployeeGroup?, void>(
    (EmployeeGroup? original, _) => GroupFormCubit(
      attachments: sl<AttachmentBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
      original: original,
    ),
  );
  sl.registerFactory<RequestTypesCubit>(
    () => RequestTypesCubit(
      types: sl<RequestTypeBaseRepository>(),
      resolver: sl<WorkSetupSourceResolver>(),
      directory: sl<EmployeeDirectoryBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
    ),
  );
  sl.registerFactoryParam<RequestTypeFormCubit, RequestType?, void>(
    (RequestType? original, _) => RequestTypeFormCubit(
      types: sl<RequestTypeBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
      original: original,
    ),
  );

  // Phase 4 (9/10/2026) — Requests, Approvals, notifications.
  sl.registerLazySingleton<TimeTrackerNotificationService>(
    () => const TimeTrackerNotificationService(),
  );
  sl.registerLazySingleton<TimeTrackerRoleRemoteDataSource>(
    () => TimeTrackerRoleRemoteDataSource(),
  );
  sl.registerLazySingleton<ApproverDirectory>(
    () => RoleApproverDirectory(
      roles: sl<TimeTrackerRoleRemoteDataSource>(),
      directory: sl<EmployeeDirectoryBaseRepository>(),
      requests: sl<RequestBaseRepository>(),
      // Code review finding 9 (9/10/2026).
      readsCompanyRequests: () => sl<TimeTrackerAccess>().readsCompanyRequests,
    ),
  );
  sl.registerLazySingleton<RequestEffects>(
    () => RequestEffects(
      resolver: sl<WorkSetupSourceResolver>(),
      directory: sl<EmployeeDirectoryBaseRepository>(),
    ),
  );
  sl.registerLazySingleton<RequestService>(
    () => RequestService(
      requests: sl<RequestBaseRepository>(),
      comments: sl<RequestCommentBaseRepository>(),
      types: sl<RequestTypeBaseRepository>(),
      balances: sl<VacationBalanceBaseRepository>(),
      resolver: sl<WorkSetupSourceResolver>(),
      managers: sl<ManagerResolver>(),
      approvers: sl<ApproverDirectory>(),
      effects: sl<RequestEffects>(),
      notifier: sl<TimeTrackerNotificationService>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
    ),
  );
  sl.registerLazySingleton<ApprovalService>(
    () => ApprovalService(
      requests: sl<RequestBaseRepository>(),
      types: sl<RequestTypeBaseRepository>(),
      approvers: sl<ApproverDirectory>(),
      effects: sl<RequestEffects>(),
      notifier: sl<TimeTrackerNotificationService>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
    ),
  );
  sl.registerFactory<RequestsCubit>(
    () => RequestsCubit(
      requests: sl<RequestBaseRepository>(),
      types: sl<RequestTypeBaseRepository>(),
      directory: sl<EmployeeDirectoryBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
      // Code review finding 7 (9/10/2026): blocked manager steps.
      approvers: sl<ApproverDirectory>(),
    ),
  );
  sl.registerFactory<RequestActionsCubit>(
    () => RequestActionsCubit(
      requests: sl<RequestService>(),
      approvals: sl<ApprovalService>(),
    ),
  );
  sl.registerFactory<RequestFormCubit>(
    () => RequestFormCubit(
      service: sl<RequestService>(),
      attachments: sl<AttachmentBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );

  // Phase 6 (9/10/2026) — reminder sweep (missed check-in / check-out,
  // pending approvals) deduped in Notification_Log.
  sl.registerLazySingleton<TimeTrackerNotificationLogRepository>(
    () => TimeTrackerNotificationLogRepository(
      remoteDataSource: sl<TimeTrackerRemoteDataSource>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerLazySingleton<TimeTrackerReminderSweeper>(
    () => TimeTrackerReminderSweeper(
      attendance: sl<AttendanceBaseRepository>(),
      requests: sl<RequestBaseRepository>(),
      resolver: sl<WorkSetupSourceResolver>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerNotificationLogRepository>(),
      notifier: sl<TimeTrackerNotificationService>(),
    ),
  );

  // Phase 5 (9/10/2026) — HR dashboard (company-wide bounded reads) and the
  // Vacation Balances tab.
  sl.registerLazySingleton<TimeTrackerDashboardRemoteDataSource>(
    () => TimeTrackerDashboardRemoteDataSource(firestore: FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<HrDashboardBaseRepository>(
    () => HrDashboardRepositoryImpl(
      remoteDataSource: sl<TimeTrackerDashboardRemoteDataSource>(),
      resolver: sl<WorkSetupSourceResolver>(),
    ),
  );
  sl.registerFactory<HrDashboardCubit>(
    () => HrDashboardCubit(
      dashboard: sl<HrDashboardBaseRepository>(),
      requests: sl<RequestBaseRepository>(),
      types: sl<RequestTypeBaseRepository>(),
      directory: sl<EmployeeDirectoryBaseRepository>(),
      resolver: sl<WorkSetupSourceResolver>(),
      access: sl<TimeTrackerAccess>(),
    ),
  );
  sl.registerFactory<VacationBalancesCubit>(
    () => VacationBalancesCubit(
      balances: sl<VacationBalanceBaseRepository>(),
      directory: sl<EmployeeDirectoryBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
      log: sl<TimeTrackerLogService>(),
    ),
  );

  // UI quality pass (9/10/2026) — DEBUG-ONLY demo data (the 🧪 button is
  // built under kDebugMode only; nothing here runs in a release build).
  sl.registerLazySingleton<TimeTrackerDemoService>(
    () => TimeTrackerDemoService(
      remote: sl<TimeTrackerRemoteDataSource>(),
      directory: sl<EmployeeDirectoryBaseRepository>(),
      managers: sl<ManagerResolver>(),
      approvers: sl<ApproverDirectory>(),
      resolver: sl<WorkSetupSourceResolver>(),
      attachments: sl<AttachmentBaseRepository>(),
      access: sl<TimeTrackerAccess>(),
      storage: sl<TimeTrackerStorageRemoteDataSource>(),
    ),
  );
  sl.registerFactory<TimeTrackerDemoCubit>(
    () => TimeTrackerDemoCubit(service: sl<TimeTrackerDemoService>()),
  );
}
