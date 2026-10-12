/// Module: GRC Module Management
/// Description: Dependency injection setup for the GRC feature using get_it.
///              Registers all data sources, repository, use cases, and the
///              cubit as lazy singletons so they are only created on first use.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: get_it, GRCModuleFirebaseDataSource,
///               GRCModuleStorageDataSource, GRCModuleRepositoryImpl,
///               use cases, GRCModuleCubit
/// Revision History: 2026-06-30 - Initial creation
library;

import 'package:knowticed_plus/features/grc/control/data/data_source/control_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/control_champion/data/data_source/champion_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/control_owner/data/data_source/owner_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/module/data/data_source/grc_module_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/module/data/data_source/grc_module_storage_data_source.dart';
import 'package:knowticed_plus/features/grc/policy/data/data_source/policy_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/policy/data/data_source/policy_storage_data_source.dart';
import 'package:knowticed_plus/features/grc/approval/data/data_source/approval_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/approval/data/repository/approval_repository_impl.dart';
import 'package:knowticed_plus/features/grc/approval/domain/repository/approval_repository.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/create_or_update_pending_approval_usecase.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/decide_approval_usecase.dart';
import 'package:knowticed_plus/features/grc/approval/domain/use_cases/get_all_approvals_usecase.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:knowticed_plus/features/grc/my_audit/data/data_source/my_audit_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/my_audit/data/repository/my_audit_repository_impl.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/repository/my_audit_repository.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/apply_my_audit_score_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/create_or_update_pending_my_audit_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/decide_my_audit_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/use_cases/get_all_my_audits_usecase.dart';
import 'package:knowticed_plus/features/grc/my_audit/presentation/controller/my_audit_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/apply_owner_score_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/data_source/assignment_control_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_submission_history_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_request_resolver.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/apply_champion_reassignment_usecase.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/apply_owner_reassignment_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/data/data_source/grc_request_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/grc_request/data/repository/grc_request_repository_impl.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/repository/grc_request_repository.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_assignment_control_usecase.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/approve_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/cancel_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/reject_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:knowticed_plus/features/grc/control/data/repository/control_repository_impl.dart';
import 'package:knowticed_plus/features/grc/control_champion/data/repository/champion_repository_impl.dart';
import 'package:knowticed_plus/features/grc/control_owner/data/repository/owner_repository_impl.dart';
import 'package:knowticed_plus/features/grc/module/data/repository/grc_module_repository_impl.dart';
import 'package:knowticed_plus/features/grc/policy/data/repository/policy_repository_impl.dart';
import 'package:knowticed_plus/features/grc/control/domain/repository/control_repository.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/repository/champion_repository.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/repository/owner_repository.dart';
import 'package:knowticed_plus/features/grc/module/domain/repository/grc_module_repository.dart';
import 'package:knowticed_plus/features/grc/policy/domain/repository/policy_repository.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/create_champion_usecase.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/create_owner_usecase.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/create_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/create_policy_usecase.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/delete_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_weight_history_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/get_control_owner_history_usecase.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/get_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/get_grc_module_owner_history_use_case.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/restore_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/update_champion_usecase.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/update_owner_usecase.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/update_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/update_policy_usecase.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_module_cubit.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_previous_owners_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/controller/control_cubit.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/use_cases/get_grc_dashboard_use_case.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/controller/grc_dashboard_cubit.dart';
import 'package:get_it/get_it.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_get_it.dart
/// Purpose: Contains the setupGRCDependencies() function that registers
///          every GRC-feature dependency into the global [GetIt] service
///          locator. Call this once from main() before the app runs.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// function name: [setupGRCDependencies]
///
/// purpose: register all GRC feature dependencies into [sl] (the global
///          [GetIt] instance) in the correct order:
///            1. Data sources
///            2. Repository (implementation)
///            3. Use cases
///            4. Cubit (presentation layer)
///          All registrations use [registerLazySingleton] so instances are
///          created on first access and reused afterwards.
///
/// parameters:
///            [GetIt] sl: the global service locator instance
///
/// return type: [void]
void setupGRCDependencies(GetIt sl) {
  // ─── 1. Data Sources ────────────────────────────────────────────────────────

  /// class name: [GRCModuleFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for GRC Module documents.
  sl.registerLazySingleton<GRCModuleFirebaseDataSource>(
    () => GRCModuleFirebaseDataSource(),
  );

  /// class name: [GRCModuleStorageDataSource]
  /// purpose: Firebase Storage upload/delete for GRC Module images.
  sl.registerLazySingleton<GRCModuleStorageDataSource>(
    () => GRCModuleStorageDataSource(),
  );

  /// class name: [PolicyFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Policy documents.
  sl.registerLazySingleton<PolicyFirebaseDataSource>(
    () => PolicyFirebaseDataSource(),
  );

  /// class name: [PolicyStorageDataSource]
  /// purpose: Firebase Storage upload/delete for Policy images and documents.
  sl.registerLazySingleton<PolicyStorageDataSource>(
    () => PolicyStorageDataSource(),
  );

  /// class name: [ControlFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Control documents (the
  /// Controls subcollection nested under each Policy).
  sl.registerLazySingleton<ControlFirebaseDataSource>(
    () => ControlFirebaseDataSource(),
  );

  /// class name: [ChampionFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Control Champion documents.
  sl.registerLazySingleton<ChampionFirebaseDataSource>(
    () => ChampionFirebaseDataSource(),
  );

  /// class name: [OwnerFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Control Owner documents.
  sl.registerLazySingleton<OwnerFirebaseDataSource>(
    () => OwnerFirebaseDataSource(),
  );

  /// class name: [GrcRequestFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for GRC Request documents.
  sl.registerLazySingleton<GrcRequestFirebaseDataSource>(
    () => GrcRequestFirebaseDataSource(),
  );

  /// class name: [AssignmentControlFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Assignment Control documents.
  sl.registerLazySingleton<AssignmentControlFirebaseDataSource>(
    () => AssignmentControlFirebaseDataSource(),
  );

  /// class name: [ApprovalFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Approval documents.
  sl.registerLazySingleton<ApprovalFirebaseDataSource>(
    () => ApprovalFirebaseDataSource(),
  );

  /// class name: [MyAuditFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for My Audit documents.
  sl.registerLazySingleton<MyAuditFirebaseDataSource>(
    () => MyAuditFirebaseDataSource(),
  );

  // ─── 2. Repository ──────────────────────────────────────────────────────────

  /// class name: [GRCModuleRepositoryImpl] registered as [GRCModuleRepository]
  /// purpose: orchestrates the data sources and maps models to entities.
  sl.registerLazySingleton<GRCModuleRepository>(
    () => GRCModuleRepositoryImpl(
      firebaseDataSource: sl<GRCModuleFirebaseDataSource>(),
      storageDataSource: sl<GRCModuleStorageDataSource>(),
    ),
  );

  /// class name: [PolicyRepositoryImpl] registered as [PolicyRepository]
  /// purpose: orchestrates the data sources and maps models to entities.
  sl.registerLazySingleton<PolicyRepository>(
    () => PolicyRepositoryImpl(
      firebaseDataSource: sl<PolicyFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );

  /// class name: [ControlRepositoryImpl] registered as [ControlRepository]
  /// purpose: orchestrates the Controls subcollection data source and Storage
  /// uploads, and maps models to entities.
  sl.registerLazySingleton<ControlRepository>(
    () => ControlRepositoryImpl(
      firebaseDataSource: sl<ControlFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );

  /// class name: [ChampionRepositoryImpl] registered as [ChampionRepository]
  /// purpose: orchestrates the Champion data source and maps models to entities.
  sl.registerLazySingleton<ChampionRepository>(
    () => ChampionRepositoryImpl(
      firebaseDataSource: sl<ChampionFirebaseDataSource>(),
    ),
  );

  /// class name: [OwnerRepositoryImpl] registered as [OwnerRepository]
  /// purpose: orchestrates the Owner data source and maps models to entities.
  sl.registerLazySingleton<OwnerRepository>(
    () => OwnerRepositoryImpl(
      firebaseDataSource: sl<OwnerFirebaseDataSource>(),
    ),
  );

  /// class name: [GrcRequestRepositoryImpl] registered as [GrcRequestRepository]
  /// purpose: orchestrates the GRC Request data source and maps models to entities.
  sl.registerLazySingleton<GrcRequestRepository>(
    () => GrcRequestRepositoryImpl(
      firebaseDataSource: sl<GrcRequestFirebaseDataSource>(),
    ),
  );

  /// class name: [AssignmentControlRepositoryImpl] registered as [AssignmentControlRepository]
  /// purpose: orchestrates the Assignment Control data source and Storage
  /// uploads, and maps models to entities.
  sl.registerLazySingleton<AssignmentControlRepository>(
    () => AssignmentControlRepositoryImpl(
      dataSource: sl<AssignmentControlFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );

  /// class name: [ApprovalRepositoryImpl] registered as [ApprovalRepository]
  /// purpose: orchestrates the Approval data source and maps models to entities.
  sl.registerLazySingleton<ApprovalRepository>(
    () => ApprovalRepositoryImpl(dataSource: sl<ApprovalFirebaseDataSource>()),
  );

  /// class name: [MyAuditRepositoryImpl] registered as [MyAuditRepository]
  /// purpose: orchestrates the My Audit data source and maps models to entities.
  sl.registerLazySingleton<MyAuditRepository>(
    () => MyAuditRepositoryImpl(dataSource: sl<MyAuditFirebaseDataSource>()),
  );

  // ─── 3. Use Cases ───────────────────────────────────────────────────────────

  /// class name: [CreateGRCModuleUseCase]
  /// purpose: business logic for creating a new GRC Module.
  sl.registerLazySingleton<CreateGRCModuleUseCase>(
    () => CreateGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [GetGRCModuleUseCase]
  /// purpose: business logic for fetching a single GRC Module by id.
  sl.registerLazySingleton<GetGRCModuleUseCase>(
    () => GetGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [GetAllGRCModulesUseCase]
  /// purpose: business logic for fetching all GRC Module records.
  sl.registerLazySingleton<GetAllGRCModulesUseCase>(
    () => GetAllGRCModulesUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [UpdateGRCModuleUseCase]
  /// purpose: business logic for updating an existing GRC Module.
  sl.registerLazySingleton<UpdateGRCModuleUseCase>(
    () => UpdateGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [DeleteGRCModuleUseCase]
  /// purpose: business logic for soft-deleting a GRC Module.
  sl.registerLazySingleton<DeleteGRCModuleUseCase>(
    () => DeleteGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [RestoreGRCModuleUseCase]
  /// purpose: business logic for restoring a soft-deleted GRC Module.
  sl.registerLazySingleton<RestoreGRCModuleUseCase>(
    () => RestoreGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [GetGRCModuleOwnerHistoryUseCase]
  /// purpose: business logic for fetching a module's previous owner history.
  sl.registerLazySingleton<GetGRCModuleOwnerHistoryUseCase>(
    () => GetGRCModuleOwnerHistoryUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [GetPolicyWeightHistoryUseCase]
  /// purpose: business logic for fetching a module's Policy weight history.
  sl.registerLazySingleton<GetPolicyWeightHistoryUseCase>(
    () => GetPolicyWeightHistoryUseCase(sl<PolicyRepository>()),
  );

  /// class name: [CreatePolicyUseCase]
  /// purpose: business logic for creating a new Policy (with its Controls).
  sl.registerLazySingleton<CreatePolicyUseCase>(
    () => CreatePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [GetPolicyUseCase]
  /// purpose: business logic for fetching a single Policy by id.
  sl.registerLazySingleton<GetPolicyUseCase>(
    () => GetPolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [GetAllPoliciesUseCase]
  /// purpose: business logic for fetching all Policy records.
  sl.registerLazySingleton<GetAllPoliciesUseCase>(
    () => GetAllPoliciesUseCase(sl<PolicyRepository>()),
  );

  /// class name: [UpdatePolicyUseCase]
  /// purpose: business logic for updating an existing Policy.
  sl.registerLazySingleton<UpdatePolicyUseCase>(
    () => UpdatePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [DeletePolicyUseCase]
  /// purpose: business logic for soft-deleting a Policy.
  sl.registerLazySingleton<DeletePolicyUseCase>(
    () => DeletePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [RestorePolicyUseCase]
  /// purpose: business logic for restoring a soft-deleted Policy.
  sl.registerLazySingleton<RestorePolicyUseCase>(
    () => RestorePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [CreateControlUseCase]
  /// purpose: business logic for creating a new Control.
  sl.registerLazySingleton<CreateControlUseCase>(
    () => CreateControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [GetControlUseCase]
  /// purpose: business logic for fetching a single Control by id.
  sl.registerLazySingleton<GetControlUseCase>(
    () => GetControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [GetAllControlsUseCase]
  /// purpose: business logic for fetching all Controls under a Policy.
  sl.registerLazySingleton<GetAllControlsUseCase>(
    () => GetAllControlsUseCase(sl<ControlRepository>()),
  );

  /// class name: [UpdateControlUseCase]
  /// purpose: business logic for updating an existing Control.
  sl.registerLazySingleton<UpdateControlUseCase>(
    () => UpdateControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [DeleteControlUseCase]
  /// purpose: business logic for hard-deleting a Control.
  sl.registerLazySingleton<DeleteControlUseCase>(
    () => DeleteControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [GetControlWeightHistoryUseCase]
  /// purpose: business logic for fetching a policy's Control weight history.
  sl.registerLazySingleton<GetControlWeightHistoryUseCase>(
    () => GetControlWeightHistoryUseCase(sl<ControlRepository>()),
  );

  /// class name: [CreateChampionUseCase]
  /// purpose: business logic for creating a new Control Champion.
  sl.registerLazySingleton<CreateChampionUseCase>(
    () => CreateChampionUseCase(sl<ChampionRepository>()),
  );

  /// class name: [GetChampionUseCase]
  /// purpose: business logic for fetching a single Control Champion by email.
  sl.registerLazySingleton<GetChampionUseCase>(
    () => GetChampionUseCase(sl<ChampionRepository>()),
  );

  /// class name: [GetAllChampionsUseCase]
  /// purpose: business logic for fetching all Control Champion records.
  sl.registerLazySingleton<GetAllChampionsUseCase>(
    () => GetAllChampionsUseCase(sl<ChampionRepository>()),
  );

  /// class name: [UpdateChampionUseCase]
  /// purpose: business logic for updating (or soft-deleting/restoring) a Control Champion.
  sl.registerLazySingleton<UpdateChampionUseCase>(
    () => UpdateChampionUseCase(sl<ChampionRepository>()),
  );

  /// class name: [CreateOwnerUseCase]
  /// purpose: business logic for creating a new Control Owner.
  sl.registerLazySingleton<CreateOwnerUseCase>(
    () => CreateOwnerUseCase(sl<OwnerRepository>()),
  );

  /// class name: [GetOwnerUseCase]
  /// purpose: business logic for fetching a single Control Owner by email.
  sl.registerLazySingleton<GetOwnerUseCase>(
    () => GetOwnerUseCase(sl<OwnerRepository>()),
  );

  /// class name: [GetAllOwnersUseCase]
  /// purpose: business logic for fetching all Control Owner records.
  sl.registerLazySingleton<GetAllOwnersUseCase>(
    () => GetAllOwnersUseCase(sl<OwnerRepository>()),
  );

  /// class name: [UpdateOwnerUseCase]
  /// purpose: business logic for updating (or soft-deleting/restoring) a Control Owner.
  sl.registerLazySingleton<UpdateOwnerUseCase>(
    () => UpdateOwnerUseCase(sl<OwnerRepository>()),
  );

  /// class name: [GetControlOwnerHistoryUseCase]
  /// purpose: business logic for fetching a single Control's Owner-assignment history.
  sl.registerLazySingleton<GetControlOwnerHistoryUseCase>(
    () => GetControlOwnerHistoryUseCase(sl<OwnerRepository>()),
  );

  /// class name: [CreateGrcRequestUseCase]
  /// purpose: business logic for creating a new GRC Request.
  sl.registerLazySingleton<CreateGrcRequestUseCase>(
    () => CreateGrcRequestUseCase(sl<GrcRequestRepository>()),
  );

  /// class name: [GetGrcRequestsUseCase]
  /// purpose: business logic for fetching all GRC Request records for a module.
  sl.registerLazySingleton<GetGrcRequestsUseCase>(
    () => GetGrcRequestsUseCase(sl<GrcRequestRepository>()),
  );

  /// class name: [ApproveGrcRequestUseCase]
  /// purpose: business logic for approving a GRC Request.
  sl.registerLazySingleton<ApproveGrcRequestUseCase>(
    () => ApproveGrcRequestUseCase(sl<GrcRequestRepository>()),
  );

  /// class name: [RejectGrcRequestUseCase]
  /// purpose: business logic for rejecting a GRC Request.
  sl.registerLazySingleton<RejectGrcRequestUseCase>(
    () => RejectGrcRequestUseCase(sl<GrcRequestRepository>()),
  );

  /// class name: [CancelGrcRequestUseCase]
  /// purpose: business logic for canceling a pending GRC Request before its
  /// start date arrives.
  sl.registerLazySingleton<CancelGrcRequestUseCase>(
    () => CancelGrcRequestUseCase(sl<GrcRequestRepository>()),
  );

  /// class name: [ApplyChampionReassignmentUseCase]
  /// purpose: business logic for applying an approved champion reassignment
  /// request whose Start Date has arrived.
  sl.registerLazySingleton<ApplyChampionReassignmentUseCase>(
    () => ApplyChampionReassignmentUseCase(
      championRepository: sl<ChampionRepository>(),
      requestRepository: sl<GrcRequestRepository>(),
    ),
  );

  /// class name: [ApplyOwnerReassignmentUseCase]
  /// purpose: business logic for applying an approved owner reassignment
  /// request whose Start Date has arrived.
  sl.registerLazySingleton<ApplyOwnerReassignmentUseCase>(
    () => ApplyOwnerReassignmentUseCase(
      ownerRepository: sl<OwnerRepository>(),
      requestRepository: sl<GrcRequestRepository>(),
    ),
  );

  /// class name: [GetAssignmentControlUseCase]
  /// purpose: business logic for fetching a single Assignment Control by
  /// control+champion, or null if none has been submitted yet.
  sl.registerLazySingleton<GetAssignmentControlUseCase>(
    () => GetAssignmentControlUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [SubmitEvidenceUseCase]
  /// purpose: business logic for a Champion submitting (or resubmitting)
  /// evidence for one Control.
  sl.registerLazySingleton<SubmitEvidenceUseCase>(
    () => SubmitEvidenceUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [GetAssignmentControlByIdUseCase]
  /// purpose: business logic for fetching an Assignment Control directly
  /// by its raw Firestore doc id (used by the Approvals feature).
  sl.registerLazySingleton<GetAssignmentControlByIdUseCase>(
    () => GetAssignmentControlByIdUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [ApplyManagerDecisionUseCase]
  /// purpose: business logic for recording a Department Manager's
  /// Approve/Reject decision on an Assignment Control.
  sl.registerLazySingleton<ApplyManagerDecisionUseCase>(
    () => ApplyManagerDecisionUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [GetSubmissionHistoryUseCase]
  /// purpose: business logic for deriving the per-file Submission History
  /// (one card per distinct file) shown on MyAuditDetailsPage.
  sl.registerLazySingleton<GetSubmissionHistoryUseCase>(
    () => GetSubmissionHistoryUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [GetAllApprovalsUseCase]
  /// purpose: business logic for fetching every Approval in a module.
  sl.registerLazySingleton<GetAllApprovalsUseCase>(
    () => GetAllApprovalsUseCase(sl<ApprovalRepository>()),
  );

  /// class name: [CreateOrUpdatePendingApprovalUseCase]
  /// purpose: business logic for creating or resetting to Pending the
  /// Approval linked to a Champion's submission.
  sl.registerLazySingleton<CreateOrUpdatePendingApprovalUseCase>(
    () => CreateOrUpdatePendingApprovalUseCase(sl<ApprovalRepository>()),
  );

  /// class name: [DecideApprovalUseCase]
  /// purpose: business logic for recording a manager's Approve/Reject
  /// decision on an Approval.
  sl.registerLazySingleton<DecideApprovalUseCase>(
    () => DecideApprovalUseCase(sl<ApprovalRepository>()),
  );

  /// class name: [ApplyOwnerScoreUseCase]
  /// purpose: business logic for recording a Control Owner's score on an
  /// Assignment Control (used by My Audits).
  sl.registerLazySingleton<ApplyOwnerScoreUseCase>(
    () => ApplyOwnerScoreUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [GetAllMyAuditsUseCase]
  /// purpose: business logic for fetching every My Audit in a module.
  sl.registerLazySingleton<GetAllMyAuditsUseCase>(
    () => GetAllMyAuditsUseCase(sl<MyAuditRepository>()),
  );

  /// class name: [CreateOrUpdatePendingMyAuditUseCase]
  /// purpose: business logic for creating or resetting to Pending the My
  /// Audit linked to a manager-approved Approval.
  sl.registerLazySingleton<CreateOrUpdatePendingMyAuditUseCase>(
    () => CreateOrUpdatePendingMyAuditUseCase(sl<MyAuditRepository>()),
  );

  /// class name: [DecideMyAuditUseCase]
  /// purpose: business logic for recording a Control Owner's Approve/Reject
  /// decision on a My Audit.
  sl.registerLazySingleton<DecideMyAuditUseCase>(
    () => DecideMyAuditUseCase(sl<MyAuditRepository>()),
  );

  /// class name: [ApplyMyAuditScoreUseCase]
  /// purpose: business logic for recording a score on a My Audit.
  sl.registerLazySingleton<ApplyMyAuditScoreUseCase>(
    () => ApplyMyAuditScoreUseCase(sl<MyAuditRepository>()),
  );

  /// class name: [RecalculateScoreRollupUseCase]
  /// purpose: recomputes and persists Control -> Policy -> Module scores
  /// after a Control Owner submits or edits a score in My Audits.
  sl.registerLazySingleton<RecalculateScoreRollupUseCase>(
    () => RecalculateScoreRollupUseCase(
      updateControlUseCase: sl<UpdateControlUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      getPolicyUseCase: sl<GetPolicyUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updateGrcModuleUseCase: sl<UpdateGRCModuleUseCase>(),
    ),
  );

  /// class name: [GetGrcDashboardUseCase]
  /// purpose: loads the modules / policies / controls both GRC dashboards
  /// draw (module-scoped and main) through the existing GRC read use cases.
  sl.registerLazySingleton<GetGrcDashboardUseCase>(
    () => GetGrcDashboardUseCase(
      getAllModulesUseCase: sl<GetAllGRCModulesUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

  // ─── 4. Cubit (Presentation) ────────────────────────────────────────────────

  /// class name: [GRCModuleCubit]
  /// purpose: presentation-layer state manager for all GRC Module operations.
  /// Registered as a factory so each page gets an independent cubit instance,
  /// preventing state leaking between the list page and the details page.
  sl.registerFactory<GRCModuleCubit>(
    () => GRCModuleCubit(
      createGRCModuleUseCase: sl<CreateGRCModuleUseCase>(),
      getGRCModuleUseCase: sl<GetGRCModuleUseCase>(),
      getAllGRCModulesUseCase: sl<GetAllGRCModulesUseCase>(),
      updateGRCModuleUseCase: sl<UpdateGRCModuleUseCase>(),
      deleteGRCModuleUseCase: sl<DeleteGRCModuleUseCase>(),
      restoreGRCModuleUseCase: sl<RestoreGRCModuleUseCase>(),
    ),
  );

  /// class name: [GrcPreviousOwnersCubit]
  /// purpose: presentation-layer state manager for the previous module owners page.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<GrcPreviousOwnersCubit>(
    () => GrcPreviousOwnersCubit(
      getOwnerHistoryUseCase: sl<GetGRCModuleOwnerHistoryUseCase>(),
    ),
  );

  /// class name: [ControlCubit]
  /// purpose: presentation-layer state manager for standalone Control
  /// operations (create/update/delete/list-all). Registered as a factory so
  /// each flow-start page gets an independent instance, same convention as
  /// PolicyCubit/ChampionCubit/OwnerCubit.
  sl.registerFactory<ControlCubit>(
    () => ControlCubit(
      createControlUseCase: sl<CreateControlUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      deleteControlUseCase: sl<DeleteControlUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

  /// class name: [PolicyCubit]
  /// purpose: presentation-layer state manager for all Policy and Control
  /// operations. Registered as a factory so each flow-start page gets an
  /// independent cubit instance (the policy list, the Policy Details page, and
  /// the standalone Create flow each resolve their own). Pages pushed as a
  /// continuation of an existing flow do NOT resolve a fresh one — e.g. the
  /// Policy Edit page reuses the Details page's instance via
  /// BlocProvider.value so the two never diverge.
  sl.registerFactory<PolicyCubit>(
    () => PolicyCubit(
      createPolicyUseCase: sl<CreatePolicyUseCase>(),
      getPolicyUseCase: sl<GetPolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      deletePolicyUseCase: sl<DeletePolicyUseCase>(),
      restorePolicyUseCase: sl<RestorePolicyUseCase>(),
      createControlUseCase: sl<CreateControlUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      deleteControlUseCase: sl<DeleteControlUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

  /// class name: [PolicyWeightIssueCubit]
  /// purpose: presentation-layer state manager for the Policy Weight Issue
  /// page's editable table. Registered as a factory so each page gets an
  /// independent cubit instance.
  sl.registerFactory<PolicyWeightIssueCubit>(
    () => PolicyWeightIssueCubit(
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      recalculateScoreRollupUseCase: sl<RecalculateScoreRollupUseCase>(),
    ),
  );

  /// class name: [PolicyWeightHistoryCubit]
  /// purpose: presentation-layer state manager for the Policy Weight
  /// Issue page's History tab. Registered as a factory so each page gets
  /// an independent cubit instance.
  sl.registerFactory<PolicyWeightHistoryCubit>(
    () => PolicyWeightHistoryCubit(
      getPolicyWeightHistoryUseCase: sl<GetPolicyWeightHistoryUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

  /// class name: [ControlWeightIssueCubit]
  /// purpose: presentation-layer state manager for the Control Weight
  /// Issue page's editable table. Registered as a factory so each page
  /// gets an independent cubit instance.
  sl.registerFactory<ControlWeightIssueCubit>(
    () => ControlWeightIssueCubit(
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      recalculateScoreRollupUseCase: sl<RecalculateScoreRollupUseCase>(),
    ),
  );

  /// class name: [ControlWeightHistoryCubit]
  /// purpose: presentation-layer state manager for the Control Weight
  /// Issue page's History tab. Registered as a factory so each page gets
  /// an independent cubit instance.
  sl.registerFactory<ControlWeightHistoryCubit>(
    () => ControlWeightHistoryCubit(
      getControlWeightHistoryUseCase: sl<GetControlWeightHistoryUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

  /// class name: [ChampionCubit]
  /// purpose: presentation-layer state manager for Control Champion operations.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<ChampionCubit>(
    () => ChampionCubit(
      createChampionUseCase: sl<CreateChampionUseCase>(),
      getChampionUseCase: sl<GetChampionUseCase>(),
      getAllChampionsUseCase: sl<GetAllChampionsUseCase>(),
      updateChampionUseCase: sl<UpdateChampionUseCase>(),
      getGrcRequestsUseCase: sl<GetGrcRequestsUseCase>(),
      applyChampionReassignmentUseCase: sl<ApplyChampionReassignmentUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      getAllOwnersUseCase: sl<GetAllOwnersUseCase>(),
    ),
  );

  /// class name: [GrcRequestCubit]
  /// purpose: presentation-layer state manager for GRC Request (champion
  /// reassignment approval) operations. Registered as a factory so each page
  /// gets an independent cubit instance.
  sl.registerFactory<GrcRequestCubit>(
    () => GrcRequestCubit(
      createGrcRequestUseCase: sl<CreateGrcRequestUseCase>(),
      getGrcRequestsUseCase: sl<GetGrcRequestsUseCase>(),
      approveGrcRequestUseCase: sl<ApproveGrcRequestUseCase>(),
      rejectGrcRequestUseCase: sl<RejectGrcRequestUseCase>(),
      cancelGrcRequestUseCase: sl<CancelGrcRequestUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

  /// class name: [OwnerCubit]
  /// purpose: presentation-layer state manager for Control Owner operations.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<OwnerCubit>(
    () => OwnerCubit(
      createOwnerUseCase: sl<CreateOwnerUseCase>(),
      getOwnerUseCase: sl<GetOwnerUseCase>(),
      getAllOwnersUseCase: sl<GetAllOwnersUseCase>(),
      updateOwnerUseCase: sl<UpdateOwnerUseCase>(),
      getGrcRequestsUseCase: sl<GetGrcRequestsUseCase>(),
      applyOwnerReassignmentUseCase: sl<ApplyOwnerReassignmentUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
    ),
  );

  /// class name: [ControlPreviousOwnersCubit]
  /// purpose: presentation-layer state manager for the previous control owners page.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<ControlPreviousOwnersCubit>(
    () => ControlPreviousOwnersCubit(
      getOwnerHistoryUseCase: sl<GetControlOwnerHistoryUseCase>(),
    ),
  );

  /// class name: [AssignmentControlCubit]
  /// purpose: presentation-layer state manager for the Champion's
  /// Assignment Controls list and Submit-evidence action. Registered as a
  /// factory so each page gets an independent cubit instance.
  sl.registerFactory<AssignmentControlCubit>(
    () => AssignmentControlCubit(
      getChampionUseCase: sl<GetChampionUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      getAllOwnersUseCase: sl<GetAllOwnersUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAssignmentControlUseCase: sl<GetAssignmentControlUseCase>(),
      submitEvidenceUseCase: sl<SubmitEvidenceUseCase>(),
      createOrUpdatePendingApprovalUseCase: sl<CreateOrUpdatePendingApprovalUseCase>(),
    ),
  );

  /// class name: [ApprovalCubit]
  /// purpose: presentation-layer state manager for the Department
  /// Manager's Approvals list and Approve/Reject actions. Registered as a
  /// factory so each page gets an independent cubit instance.
  sl.registerFactory<ApprovalCubit>(
    () => ApprovalCubit(
      getAllApprovalsUseCase: sl<GetAllApprovalsUseCase>(),
      getAssignmentControlByIdUseCase: sl<GetAssignmentControlByIdUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      decideApprovalUseCase: sl<DecideApprovalUseCase>(),
      applyManagerDecisionUseCase: sl<ApplyManagerDecisionUseCase>(),
      createOrUpdatePendingMyAuditUseCase: sl<CreateOrUpdatePendingMyAuditUseCase>(),
    ),
  );

  /// class name: [MyAuditCubit]
  /// purpose: presentation-layer state manager for the Control Owner's My
  /// Audits list and Approve/Reject/Score actions. Registered as a factory
  /// so each page gets an independent cubit instance.
  sl.registerFactory<MyAuditCubit>(
    () => MyAuditCubit(
      getAllMyAuditsUseCase: sl<GetAllMyAuditsUseCase>(),
      getAssignmentControlByIdUseCase: sl<GetAssignmentControlByIdUseCase>(),
      getOwnerUseCase: sl<GetOwnerUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      decideMyAuditUseCase: sl<DecideMyAuditUseCase>(),
      applyMyAuditScoreUseCase: sl<ApplyMyAuditScoreUseCase>(),
      applyManagerDecisionUseCase: sl<ApplyManagerDecisionUseCase>(),
      applyOwnerScoreUseCase: sl<ApplyOwnerScoreUseCase>(),
      recalculateScoreRollupUseCase: sl<RecalculateScoreRollupUseCase>(),
    ),
  );

  /// class name: [SubmissionHistoryCubit]
  /// purpose: presentation-layer state manager for one Assignment
  /// Control's per-file Submission History cards, kept independent of the
  /// shared MyAuditCubit (see the class doc comment for why). Registered
  /// as a factory so each MyAuditDetailsPage instance gets its own cubit.
  sl.registerFactory<SubmissionHistoryCubit>(
    () => SubmissionHistoryCubit(
      getSubmissionHistoryUseCase: sl<GetSubmissionHistoryUseCase>(),
    ),
  );

  /// class name: [GrcDashboardCubit]
  /// purpose: state manager for GrcDashboardPage (module Dashboard and the
  /// GRC Main Dashboard). Factory, so each page gets its own instance.
  sl.registerFactory<GrcDashboardCubit>(
    () => GrcDashboardCubit(
      getGrcDashboardUseCase: sl<GetGrcDashboardUseCase>(),
    ),
  );
}
