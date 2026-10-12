/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: roles_home_stats_cubit.dart
/// Purpose: Declares `RolesHomeStatsCubit` — the counts behind the four Roles
///          cards on the home page and in the Adding Widget picker.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// The four cards (Role Management / User Management / User Access / User
/// Management Requests) show live figures, not the placeholder 10s the rest of
/// the picker previews. Their data lives in three feature modules whose cubits
/// are only provided on their own pages — `RoleCubit` by the role-management
/// route, `UserManagementAccessCubit` by user management, `UserAccessCubit` by
/// user access. A home widget has none of them in scope, so `context.read` for
/// any of the three throws there.
///
/// Rather than provide three feature cubits at the root (each one carries a lot
/// more than a count: search controllers, selection state, edit flows), this
/// reads the same repositories they read and keeps only the numbers. It is
/// provided in `main.dart` beside `AppHomeCubit`, so all four cards share one
/// instance and one pass over Firestore.
///
/// `BlocProvider` is lazy, so nothing is fetched until a card is actually
/// built — a user who never opens Home or the widget picker pays nothing.
///
/// KEEPING THE BUCKETS HONEST
/// -------------------------
/// The counts deliberately go through the SAME code the feature screens use, so
/// a card and the screen it links to can never disagree:
///   * roles          — `RoleStatus` off `RoleHistoryModel.currentStatus`,
///                      as `RoleCubit.filterRoles` does.
///   * access grants  — `UserPermissionEntity.accessStatus`, as
///                      `UserManagementAccessCubit.getAccessSummary` does.
///   * accounts       — `GetUserAccessEntitiesUseCase`, which owns the
///                      locked-beats-schedule bucketing rule and the folding of
///                      the three unrendered statuses. Do NOT re-derive that
///                      here; see the long note on `_bucketFor`.
///   * requests       — the `Employees_Request` collection, same scope and
///                      same status keys as `RequestPageApproval`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/usecases/get_user_access_entities_use_case.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/roles_home_stats_state.dart';

/// Status keys stored on an employee change request.
///
/// The same three literals `RequestPageApproval` declares (`kApproved` /
/// `kPending` / `kRejected`). Duplicated rather than imported because those are
/// top-level constants in a page file, and a home widget importing a page to
/// read a string would drag that whole route in.
abstract class RequestStatusKey {
  static const String approved = 'approved';
  static const String pending = 'pending';
  static const String rejected = 'rejected';
}

class RolesHomeStatsCubit extends Cubit<RolesHomeStatsState> {
  RolesHomeStatsCubit() : super(RolesHomeStatsInitial());

  final RoleRepository _roleRepository = RoleRepository();
  final UserManagementAccessRepository _userManagementRepository =
      UserManagementAccessRepository();
  final GetUserAccessEntitiesUseCase _accountsUseCase =
      GetUserAccessEntitiesUseCase(UserAccessRepository());

  // ── Counts ────────────────────────────────────────────────────────────────
  // Every map is fully populated with zeros before a load runs, so a card can
  // read `roleCounts[status]!` without a null check even if that source failed.

  /// Roles by lifecycle status — the Role Management card.
  Map<RoleStatus, int> roleCounts = _zeroed(RoleStatus.values);

  /// Access grants by status — the User Management card.
  Map<UserAccessStatus, int> accessCounts = _zeroed(UserAccessStatus.values);

  /// Employee accounts by status — the User Access card.
  Map<EmployeeStatusEnum, int> accountCounts =
      _zeroed(EmployeeStatusEnum.values);

  /// Employee change requests by status key — the User Management Requests
  /// card. Keyed by [RequestStatusKey].
  Map<String, int> requestCounts = <String, int>{
    RequestStatusKey.approved: 0,
    RequestStatusKey.pending: 0,
    RequestStatusKey.rejected: 0,
  };

  static Map<T, int> _zeroed<T>(List<T> values) =>
      <T, int>{for (final T value in values) value: 0};

  /// Guards against a second load while one is already in flight — all four
  /// cards call [ensureLoaded] from their first build.
  bool _loading = false;

  /// True once a load has finished, however it went.
  bool _loadedOnce = false;

  void emitSafely(RolesHomeStatsState state) {
    if (isClosed) return;
    emit(state);
  }

  /// Function Name: [ensureLoaded]
  ///
  /// Purpose: Load once, no matter how many of the four cards are on screen.
  ///
  /// Each card calls this from `build`, which runs on every rebuild — so this
  /// has to be idempotent, not just cheap.
  ///
  /// The fetch is deferred to after the frame, and `_loading` is claimed
  /// synchronously so the other three cards building in the same frame do not
  /// each queue one. Calling [load] directly from here would `emit` during the
  /// build phase, and the BlocBuilder above would then be marked dirty while it
  /// is being built — the "setState() called during build" assertion.
  void ensureLoaded() {
    if (_loading || _loadedOnce) return;
    _loading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      // load() re-checks the flag; release it first so it is not a no-op.
      _loading = false;
      load();
    });
  }

  /// Function Name: [load]
  ///
  /// Purpose: Refresh every count. Safe to call again to re-read.
  ///
  /// The four sources are independent and are read concurrently. A source that
  /// fails leaves its own map at zero and does NOT take the other three with
  /// it: one broken collection should blank one card, not all four. Only a
  /// total failure emits [RolesHomeStatsError].
  ///
  /// Returns: [Future<void>]
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    emitSafely(RolesHomeStatsLoading());

    final List<bool> results = await Future.wait(<Future<bool>>[
      _loadRoleCounts(),
      _loadAccessCounts(),
      _loadAccountCounts(),
      _loadRequestCounts(),
    ]);

    _loading = false;
    _loadedOnce = true;

    if (results.every((bool ok) => !ok)) {
      emitSafely(RolesHomeStatsError('Roles home stats could not be loaded'));
      return;
    }
    emitSafely(RolesHomeStatsLoaded());
  }

  /// Role Management: active / inactive / draft, off the undeleted roles.
  ///
  /// `getUnDeletedRoles` is the same read the role-management home does, so a
  /// deleted role is out of both by construction.
  Future<bool> _loadRoleCounts() async {
    return _guard('roles', () async {
      // FirebaseFailure, not Failure — `RoleRepository.getUnDeletedRoles`
      // narrows the left side, exactly as `RoleCubit` annotates it.
      final Either<FirebaseFailure, dynamic> result =
          await _roleRepository.getUnDeletedRoles();
      if (result.isLeft()) return false;

      final List<RoleHistoryModel> roles =
          List<RoleHistoryModel>.from(result.getOrElse(() => <RoleHistoryModel>[]));

      final Map<RoleStatus, int> counts = _zeroed(RoleStatus.values);
      for (final RoleHistoryModel role in roles) {
        counts[role.currentStatus] = (counts[role.currentStatus] ?? 0) + 1;
      }
      counts[RoleStatus.all] = roles.length;
      roleCounts = counts;
      return true;
    });
  }

  /// User Management: access grants by [UserAccessStatus].
  Future<bool> _loadAccessCounts() async {
    return _guard('access grants', () async {
      final Either<Failure, dynamic> result =
          await _userManagementRepository.getUsersPermissionsData();
      if (result.isLeft()) return false;

      final List<UserPermissionEntity> permissions =
          List<UserPermissionEntity>.from(
              result.getOrElse(() => <UserPermissionEntity>[]));

      final Map<UserAccessStatus, int> counts = _zeroed(UserAccessStatus.values);
      for (final UserPermissionEntity permission in permissions) {
        counts[permission.accessStatus] =
            (counts[permission.accessStatus] ?? 0) + 1;
      }
      counts[UserAccessStatus.all] = permissions.length;
      accessCounts = counts;
      return true;
    });
  }

  /// User Access: accounts by [EmployeeStatusEnum].
  ///
  /// Straight off the use case, which already returns one list per status and
  /// owns the bucketing rule. Counting the lists here rather than re-deriving
  /// the buckets is the whole point — see this file's header.
  Future<bool> _loadAccountCounts() async {
    return _guard('accounts', () async {
      final Either<Failure, dynamic> result = await _accountsUseCase.execute();
      if (result.isLeft()) return false;

      final Map<EmployeeStatusEnum, List<UserAccessEntity>> buckets =
          Map<EmployeeStatusEnum, List<UserAccessEntity>>.from(
              result.getOrElse(
                  () => <EmployeeStatusEnum, List<UserAccessEntity>>{}));

      final Map<EmployeeStatusEnum, int> counts =
          _zeroed(EmployeeStatusEnum.values);
      buckets.forEach((EmployeeStatusEnum status, List<UserAccessEntity> list) {
        counts[status] = list.length;
      });
      accountCounts = counts;
      return true;
    });
  }

  /// User Management Requests: approved / pending / rejected.
  ///
  /// Whole-collection scope, matching `RequestPageApproval`: this is the review
  /// QUEUE, not the signed-in user's own requests. A document with no `status`
  /// counts as pending, exactly as that screen defaults it.
  Future<bool> _loadRequestCounts() async {
    return _guard('requests', () async {
      final String basePath = getBaseUrl('Modules');

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .doc('$basePath/roles')
              .collection(FirebaseCollections.employeesRequest)
              .get();

      final Map<String, int> counts = <String, int>{
        RequestStatusKey.approved: 0,
        RequestStatusKey.pending: 0,
        RequestStatusKey.rejected: 0,
      };

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final String status =
            (doc.data()['status'] ?? RequestStatusKey.pending).toString();
        if (counts.containsKey(status)) {
          counts[status] = counts[status]! + 1;
        }
      }

      requestCounts = counts;
      return true;
    });
  }

  /// Runs [read] and turns any throw into `false` rather than letting it take
  /// down the whole `Future.wait`.
  Future<bool> _guard(String label, Future<bool> Function() read) async {
    try {
      return await read();
    } catch (e, stackTrace) {
      debugPrint('RolesHomeStatsCubit: $label failed: $e\n$stackTrace');
      return false;
    }
  }
}
