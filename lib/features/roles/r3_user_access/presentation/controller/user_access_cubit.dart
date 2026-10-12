/// Module: roles / r3_user_access / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_cubit.dart
/// Purpose: Declares `UserAccessCubit` — the state holder for the user-access
///          screen (status filtering, search, sort, and the activate /
///          deactivate / schedule write paths).
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Every repository result is now folded and a failure
///          emits `UserAccessError`; GetX removed; notification side effects
///          pulled out of the domain use case into this layer.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/custom/76-date_time_in_arabic.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/enums/sort_option_role.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/usecases/get_user_access_entities_use_case.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/usecases/update_user_access_status_use_case.dart';
import './user_access_state.dart';

/// App-wide shared UserAccessCubit instance.
///
/// Moved here from role_responsive_page.dart when that wrapper page was
/// removed. Top-level variables are lazily initialised in Dart, so this is
/// only constructed on first use.
UserAccessCubit accountStatusCubit = UserAccessCubit();

class UserAccessCubit extends Cubit<UserAccessState> {
  /// [repository] is injectable so tests can supply a fake; it defaults to the
  /// concrete implementation to keep the existing zero-argument construction
  /// used by the shared singleton above working (§16 DI).
  UserAccessCubit({UserAccessRepository? repository})
      : repository = repository ?? UserAccessRepository(),
        super(UserAccessInitial());

  final UserAccessRepository repository;

  EmployeeStatusEnum selectedStatus = EmployeeStatusEnum.all;
  SortOptionRole? selectedSortOption;

  /// Direction of [selectedSortOption].
  ///
  /// Always ascending in practice since 29/8/2026: picking the active option
  /// again clears the sort rather than flipping this (see [selectSortOption]).
  /// The field stays because [sortAccountsStatusEntities] reads it on every
  /// re-apply, and a direction control may come back as its own affordance.
  bool sortAscending = true;
  Map<EmployeeStatusEnum, List<UserAccessEntity>> accountStatusEntities = {};
  List<UserAccessEntity> filteredSortedSelectedEntities = [];
  String? selectedDepartment;

  /// Job-title filter (English title, compared case-insensitively). ADDED
  /// 30/9/2026 — Role QA p.37 asked for a Title filter next to Department.
  String? selectedTitle;

  /// The current search term.
  ///
  /// Was a `TextEditingController` held on the cubit, which §16 forbids — form
  /// state belongs to the page's StatefulWidget. The page owns the controller
  /// and pushes its text down here as a plain value.
  String searchTerm = '';

  /// Function Name: [emitSafely]
  ///
  /// Purpose: Publish [state] only while this cubit is still open.
  ///
  /// Every write path here awaits Firestore before emitting; navigating away
  /// mid-flight would otherwise emit on a closed cubit.
  ///
  /// Parameters:
  /// - [state]: The state to publish.
  ///
  /// Returns: [void]
  void emitSafely(UserAccessState state) {
    if (isClosed) return;
    emit(state);
  }

  /// Function Name: [getAccountsStatusEntities]
  ///
  /// Purpose: Load every employee's account status, grouped by status.
  ///
  /// ERROR HANDLING: this used to act only on `result.isRight()`. On failure
  /// [accountStatusEntities] stayed `{}`, no error state was emitted, and
  /// [searchAccountsStatusEntities] then dereferenced a missing key with `!`
  /// and threw. Both halves are fixed: the Left branch emits, and the search
  /// no longer force-unwraps.
  ///
  /// Returns: [Future<void>]
  Future<void> getAccountsStatusEntities() async {
    final Either<Failure, dynamic> result =
        await GetUserAccessEntitiesUseCase(repository).execute();

    result.fold(
      (failure) {
        debugPrint('getAccountsStatusEntities failed: ${failure.errMessage}');
        emitSafely(UserAccessError(failure.errMessage));
      },
      (data) {
        accountStatusEntities = data ?? {};
        searchAccountsStatusEntities(searchTerm, selectedSortOption);
      },
    );
  }

  /// Function Name: [selectSortOption]
  ///
  /// Purpose: Apply the sort option the user just picked in the dropdown.
  ///
  /// Re-picking the option that is already active CLEARS the sort: the option
  /// is deselected, the list goes back to its unsorted order, and the Sort
  /// button drops out of its active fill. A different option always starts
  /// ascending.
  ///
  /// CHANGED 29/8/2026 — re-picking used to flip the direction (A→Z became
  /// Z→A). The menu is a list of options with the active one filled, not a
  /// direction control, so the second tap on a filled row read as "turn this
  /// off" and instead silently reordered the list; there was also no way to get
  /// back to no sort at all, since the menu has no "none" row.
  ///
  /// [sortAscending] stays in the class — [sortAccountsStatusEntities] still
  /// reads it — and is reset to true whenever a sort is chosen or cleared, so
  /// nothing can inherit a descending direction from a previous selection.
  ///
  /// Parameters:
  /// - [option]: Sort key chosen by the user; `null` is ignored.
  ///
  /// Returns: [void]
  void selectSortOption(SortOptionRole? option) {
    if (option == null) return;

    if (option == selectedSortOption) {
      // Deselect. Cleared BEFORE the rebuild, because
      // `searchAccountsStatusEntities` re-applies whatever
      // `selectedSortOption` holds when it is handed a non-null option — and
      // `sortAccountsStatusEntities` assigns the field on every call, so
      // clearing after the rebuild would be written straight back.
      selectedSortOption = null;
      sortAscending = true;
      searchAccountsStatusEntities(searchTerm, null);
      return;
    }

    selectedSortOption = option;
    sortAscending = true;
    sortAccountsStatusEntities(option);
  }

  /// Function Name: [sortAccountsStatusEntities]
  ///
  /// Purpose: Sort the visible rows by [option] in the current
  /// [sortAscending] direction.
  ///
  /// This is the re-apply path — it is also called after searching, filtering
  /// and status changes, so it never flips the direction on its own. User
  /// selections go through [selectSortOption].
  ///
  /// Parameters:
  /// - [option]: Sort key; `null` leaves the order untouched.
  ///
  /// Returns: [void]
  void sortAccountsStatusEntities(SortOptionRole? option) {
    if (option == null) return;

    selectedSortOption = option;

    /// Applies [sortAscending] to a comparator written ascending-first.
    int directed(int comparison) => sortAscending ? comparison : -comparison;

    switch (option) {
      case SortOptionRole.firstName:
        filteredSortedSelectedEntities.sort((a, b) => directed(a.englishName
            .split(" ")
            .first
            .compareTo(b.englishName.split(" ").first)));
        break;
      case SortOptionRole.lastName:
        filteredSortedSelectedEntities.sort((a, b) => directed(a.englishName
            .split(" ")
            .last
            .compareTo(b.englishName.split(" ").last)));
        break;
      case SortOptionRole.firstLogin:
        filteredSortedSelectedEntities.sort((a, b) {
          // Missing dates stay at the bottom in both directions.
          if (a.firstLogin == null) return 1;
          if (b.firstLogin == null) return -1;
          return directed(a.firstLogin!.compareTo(b.firstLogin!));
        });
        break;
      case SortOptionRole.lastLogin:
        filteredSortedSelectedEntities.sort((a, b) {
          if (a.lastLogin == null) return 1;
          if (b.lastLogin == null) return -1;
          return directed(a.lastLogin!.compareTo(b.lastLogin!));
        });
        break;
    }

    emitSafely(UserAccessLoaded());
  }

  /// Function Name: [searchAccountsStatusEntities]
  ///
  /// Purpose: Rebuild the visible list from the search term, department filter
  /// and sort option.
  ///
  /// Parameters:
  /// - [searchValue]: Free-text match against the English and Arabic names.
  /// - [option]: Optional sort key applied after filtering.
  ///
  /// Returns: [void]
  void searchAccountsStatusEntities(String searchValue, SortOptionRole? option) {
    searchTerm = searchValue;
    filteredSortedSelectedEntities = [];

    // Was `accountStatusEntities[selectedStatus]!` — a null-check operator on a
    // map that is empty whenever the load failed, so a failed load crashed the
    // list instead of showing an error.
    final List<UserAccessEntity> source =
        accountStatusEntities[selectedStatus] ?? const <UserAccessEntity>[];

    final String needle = searchValue.toLowerCase();
    for (final UserAccessEntity entity in source) {
      final bool matchesName =
          entity.englishName.toLowerCase().contains(needle) ||
              entity.arabicName.toLowerCase().contains(needle);
      if (!matchesName) continue;

      if (selectedTitle != null &&
          entity.englishTitle.trim().toLowerCase() !=
              selectedTitle!.trim().toLowerCase()) {
        continue;
      }

      if (selectedDepartment == null || selectedDepartment == entity.department) {
        filteredSortedSelectedEntities.add(entity);
      }
    }

    if (option != null) {
      sortAccountsStatusEntities(option);
    } else {
      emitSafely(UserAccessLoaded());
    }
  }

  /// Function Name: [selectStatus]
  ///
  /// Purpose: Change the status tab and re-filter.
  ///
  /// Parameters:
  /// - [newStatus]: The status bucket to show.
  ///
  /// Returns: [void]
  void selectStatus(EmployeeStatusEnum newStatus) {
    selectedStatus = newStatus;
    searchAccountsStatusEntities(searchTerm, selectedSortOption);
  }

  /// Function Name: [updateAccountStatus]
  ///
  /// Purpose: Activate or deactivate an account.
  ///
  /// ERROR HANDLING: the Left branch used to be dropped entirely — the admin
  /// tapped activate, the Firestore write failed, and the UI showed nothing at
  /// all while the row stayed unchanged.
  ///
  /// Parameters:
  /// - [accountStatusAccessEntity]: The row being toggled.
  ///
  /// Returns: [Future<void>]
  Future<void> updateAccountStatus(
      UserAccessEntity accountStatusAccessEntity) async {
    final Either<Failure, dynamic> result =
        await UpdateUserAccessStatusUseCase(repository)
            .execute(accountStatusAccessEntity);

    await result.fold(
      (failure) async {
        debugPrint('updateAccountStatus failed: ${failure.errMessage}');
        emitSafely(UserAccessError(failure.errMessage));
      },
      (_) async {
        // The push used to fire from inside the domain use case, and fired
        // whether or not the write succeeded. It now belongs to this layer and
        // only runs once the write is confirmed.
        _notifyStatusChanged(accountStatusAccessEntity);
        await getAccountsStatusEntities();
      },
    );
  }

  /// Function Name: [updateAccessDetails]
  ///
  /// Purpose: Persist the password expiry settings for one account.
  ///
  /// Parameters:
  /// - [accountStatusAccessEntity]: The row being edited.
  ///
  /// Returns: [Future<void>]
  Future<void> updateAccessDetails(
      UserAccessEntity accountStatusAccessEntity) async {
    try {
      emitSafely(UserAccessLoading());
      await repository.updateAccessDetails(accountStatusAccessEntity);
      await getAccountsStatusEntities();
      emitSafely(UserAccessLoaded());
    } catch (e, stackTrace) {
      debugPrint('updateAccessDetails failed: $e\n$stackTrace');
      emitSafely(
          UserAccessError('Failed to update access details: ${e.toString()}'));
    }
  }

  /// Function Name: [scheduleReactivation]
  ///
  /// Purpose: Schedule a future reactivation for an account.
  ///
  /// ERROR HANDLING: the Left branch was dropped — a failed schedule write was
  /// indistinguishable from a successful one.
  ///
  /// Parameters:
  /// - [accountStatusAccessEntity]: The account to reactivate.
  /// - [reactivationTime]: The scheduled moment, already formatted.
  ///
  /// Returns: [Future<void>]
  Future<void> scheduleReactivation(
    UserAccessEntity accountStatusAccessEntity,
    String reactivationTime,
  ) async {
    // Inlined from the removed ScheduleReactivationTimeUseCase.
    final Either<Failure, dynamic> result = await repository
        .scheduleReactivationTime(accountStatusAccessEntity, reactivationTime);

    await result.fold(
      (failure) async {
        debugPrint('scheduleReactivation failed: ${failure.errMessage}');
        emitSafely(UserAccessError(failure.errMessage));
      },
      (_) async {
        _notifyScheduled(
          email: accountStatusAccessEntity.email,
          title: _reactivatedTitleEn,
          arabicTitle: _reactivatedTitleAr,
          body: 'Your account will be reactivated at $reactivationTime.',
          arabicBody:
              'سيتم اعادة تنشيط حسابك في ${dateforamtToArabic(reactivationTime)}.',
        );
        await getAccountsStatusEntities();
      },
    );
  }

  /// Function Name: [scheduleDeactivation]
  ///
  /// Purpose: Schedule a future deactivation for an account.
  ///
  /// ERROR HANDLING: as [scheduleReactivation] — the Left branch was dropped.
  ///
  /// Parameters:
  /// - [accountStatusEntity]: The account to deactivate.
  /// - [selectedDateTime]: The scheduled moment, already formatted.
  ///
  /// Returns: [Future<void>]
  Future<void> scheduleDeactivation(
    UserAccessEntity accountStatusEntity,
    String selectedDateTime,
  ) async {
    // Inlined from the removed ScheduleDeactivationTimeUseCase.
    final Either<Failure, dynamic> result = await repository
        .scheduleDeactivationTime(accountStatusEntity, selectedDateTime);

    await result.fold(
      (failure) async {
        debugPrint('scheduleDeactivation failed: ${failure.errMessage}');
        emitSafely(UserAccessError(failure.errMessage));
      },
      (_) async {
        _notifyScheduled(
          email: accountStatusEntity.email,
          title: _deactivatedTitleEn,
          arabicTitle: _deactivatedTitleAr,
          body: 'Your account will be deactivated at $selectedDateTime.',
          arabicBody:
              'سيتم الغاء تنشيط حسابك في ${dateforamtToArabic(selectedDateTime)}.',
        );
        await getAccountsStatusEntities();
      },
    );
  }

  // ── Push-notification copy ──────────────────────────────────────────────
  //
  // These stay as literal EN/AR pairs rather than `S.of(context)` keys on
  // purpose: `sendNotification` takes both languages at once and delivers to a
  // device whose locale is not this admin's. Resolving a single locale through
  // `S` here would drop half the payload. They are hoisted to constants so the
  // copy is edited in one place.
  static const String _reactivatedTitleEn = 'Reactivated Account';
  static const String _reactivatedTitleAr = 'إعادة تنشيط الحساب';
  static const String _deactivatedTitleEn = 'Deactivated Account';
  static const String _deactivatedTitleAr = 'تم ايقاف حسابك';

  /// Function Name: [_notifyStatusChanged]
  ///
  /// Purpose: Tell the employee their account was activated or deactivated.
  ///
  /// Moved here 12/8/2026 from `UpdateUserAccessStatusUseCase._sendNotification`,
  /// which made a `domain/` file import a presentation cubit and reach into the
  /// GetX locator (§3). The branches read the entity's pre-change flags, which
  /// are still intact at this point.
  ///
  /// Parameters:
  /// - [entity]: The row whose status was just written.
  ///
  /// Returns: [void]
  void _notifyStatusChanged(UserAccessEntity entity) {
    if (entity.isLocked) {
      _send(
        email: entity.email,
        title: 'Account Activated',
        arabicTitle: 'تم تفعيل حسابك',
        body: 'Your account is now activated. You can login now.',
        arabicBody: 'تم تفعيل حسابك الان . يمكنك تسجيل الدخول',
      );
      return;
    }

    if (entity.isActive || entity.isInactive) {
      _send(
        email: entity.email,
        title: 'Account Deactivated',
        arabicTitle: 'تم ايقاف حسابك',
        body: 'Your account is now deactivated. You can no longer login.',
        arabicBody: 'تم ايقاف حسابك الان . لا يمكنك تسجيل الدخول',
      );
      return;
    }

    if (entity.isDeactivated) {
      _send(
        email: entity.email,
        title: 'Account Reactivated',
        arabicTitle: 'تم اعادة تفعيل حسابك',
        body: 'Your account is now reactivated. You can now login.',
        arabicBody: 'تم اعادة تفعيل حسابك الان . يمكنك تسجيل الدخول',
      );
    }
  }

  /// Bilingual push sent after a schedule write succeeds.
  void _notifyScheduled({
    required String email,
    required String title,
    required String arabicTitle,
    required String body,
    required String arabicBody,
  }) {
    _send(
      email: email,
      title: title,
      arabicTitle: arabicTitle,
      body: body,
      arabicBody: arabicBody,
    );
  }

  /// Function Name: [_send]
  ///
  /// Purpose: Single exit point to the push service.
  ///
  /// The swallow is deliberate — a push failure must not break the write flow
  /// that already succeeded — but it logs rather than vanishing (§11.5). Was
  /// `Get.find<AppNotificationCubit>()`; now goes through the DI seam.
  void _send({
    required String email,
    required String title,
    required String arabicTitle,
    required String body,
    required String arabicBody,
  }) {
    try {
      AppControllers.notifications.sendNotification(
        type: 'employee',
        topic: email,
        title: title,
        arabicTitle: arabicTitle,
        body: body,
        arabicBody: arabicBody,
      );
    } catch (e, stackTrace) {
      debugPrint('user-access push notification failed: $e\n$stackTrace');
    }
  }
}
