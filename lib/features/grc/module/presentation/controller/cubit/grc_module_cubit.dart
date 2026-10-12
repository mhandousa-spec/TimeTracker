/// Module: GRC Module Management
/// Description: BLoC Cubit that manages GRC Module state for the presentation
///              layer. Delegates all operations to the corresponding use cases
///              and emits typed [GRCModuleState] subclasses.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: flutter_bloc, use cases, GRCModuleEntity
/// Revision History: 2026-06-30 - Initial creation
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/module/data/services/grc_module_notification_service.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_status.dart';
import 'dart:io';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/create_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/delete_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/get_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/restore_grc_module_use_case.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/update_grc_module_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'grc_module_state.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_cubit.dart
/// Purpose: Contains the GRCModuleCubit class, the presentation-layer state
///          manager for all GRC Module CRUD operations.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleCubit]
///
/// purpose: manage all GRC Module UI state. Each public method maps to one
///          use case and follows the pattern: emit [GRCModuleLoading] →
///          call use case → emit [GRCModuleActionSuccess] /
///          [GRCModuleListLoaded] / [GRCModuleSingleLoaded] on success, or
///          [GRCModuleFailure] on failure.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleCubit extends Cubit<GRCModuleState> {
  GRCModuleCubit({
    required CreateGRCModuleUseCase createGRCModuleUseCase,
    required GetGRCModuleUseCase getGRCModuleUseCase,
    required GetAllGRCModulesUseCase getAllGRCModulesUseCase,
    required UpdateGRCModuleUseCase updateGRCModuleUseCase,
    required DeleteGRCModuleUseCase deleteGRCModuleUseCase,
    required RestoreGRCModuleUseCase restoreGRCModuleUseCase,
  })  : _createUseCase = createGRCModuleUseCase,
        _getUseCase = getGRCModuleUseCase,
        _getAllUseCase = getAllGRCModulesUseCase,
        _updateUseCase = updateGRCModuleUseCase,
        _deleteUseCase = deleteGRCModuleUseCase,
        _restoreUseCase = restoreGRCModuleUseCase,
        super(GRCModuleInitial());

  final CreateGRCModuleUseCase _createUseCase;
  final GetGRCModuleUseCase _getUseCase;
  final GetAllGRCModulesUseCase _getAllUseCase;
  final UpdateGRCModuleUseCase _updateUseCase;
  final DeleteGRCModuleUseCase _deleteUseCase;
  final RestoreGRCModuleUseCase _restoreUseCase;

  /// Resolves the currently logged-in user's email (every GRC Module
  /// revision is attributed to an email, not an id — see Modifiers on
  /// GRCModuleModel).
  /// Falls back to MainCoreEmployeeController if Constant.emailUser isn't set yet.
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  /// function name: [getAllModules]
  ///
  /// purpose: fetch all GRC Module records and emit [GRCModuleListLoaded]
  ///          on success or [GRCModuleFailure] on failure.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when true, soft-deleted modules are
  ///            included in the result (default: false)
  ///
  /// return type: [Future<void>]
  Future<void> getAllModules({bool includeDeleted = false}) async {
    emit(GRCModuleLoading());
    final result = await _getAllUseCase.execute(includeDeleted: includeDeleted);
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (modules) => emit(GRCModuleListLoaded(modules)),
    );
  }

  /// function name: [getModule]
  ///
  /// purpose: fetch a single GRC Module by [id] and emit
  ///          [GRCModuleSingleLoaded] on success or [GRCModuleFailure] on
  ///          failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to fetch
  ///
  /// return type: [Future<void>]
  Future<void> getModule(String id) async {
    emit(GRCModuleLoading());
    final result = await _getUseCase.execute(id);
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) => emit(GRCModuleSingleLoaded(module)),
    );
  }

  /// function name: [createModule]
  ///
  /// purpose: create a new GRC Module and emit [GRCModuleActionSuccess] on
  ///          success or [GRCModuleFailure] on failure.
  ///
  /// parameters:
  ///            [String] grcModuleNameEnglish: English module name
  ///            [String] grcModuleNameArabic: Arabic module name
  ///            [String] descriptionEnglish: English description
  ///            [String] descriptionArabic: Arabic description
  ///            [String] owningDepartment: owning department
  ///            [DateTime] activationDate: activation date
  ///            [List<String>] owners: list of owner employee ids
  ///            [String] status: initial status
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] imageUrl: an already-hosted image URL, if any
  ///
  /// return type: [Future<void>]
  Future<void> createModule({
    required String grcModuleNameEnglish,
    required String grcModuleNameArabic,
    required String descriptionEnglish,
    required String descriptionArabic,
    required String owningDepartment,
    required DateTime activationDate,
    required List<String> owners,
    required String status,
    File? imageFile,
    String? imageUrl,
  }) async {
    emit(GRCModuleLoading());
    final result = await _createUseCase.execute(
      grcModuleNameEnglish: grcModuleNameEnglish,
      grcModuleNameArabic: grcModuleNameArabic,
      descriptionEnglish: descriptionEnglish,
      descriptionArabic: descriptionArabic,
      owningDepartment: owningDepartment,
      activationDate: activationDate,
      owners: owners,
      status: status,
      editorId: _currentUserEmail,
      imageFile: imageFile,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) {
        // Module Created → owners + admins.
        _notify(() => GrcModuleNotificationService.moduleCreated(
              actorEmail: _currentUserEmail,
              moduleName: module.moduleNameEn,
              recipients: _moduleAudience(module),
              isArabic: _isArabic,
            ));
        // Module Owner Assigned → the new owners themselves. Second person
        // ("You have been assigned"), so it goes to them and nobody else.
        _notify(() => GrcModuleNotificationService.ownerAssigned(
              actorEmail: _currentUserEmail,
              moduleName: module.moduleNameEn,
              newOwnerEmails: module.moduleOwners
                  .where((String e) => e.isNotEmpty && e != _currentUserEmail),
              isArabic: _isArabic,
            ));
        emit(GRCModuleActionSuccess(module));
      },
    );
  }

  /// function name: [updateModule]
  ///
  /// purpose: update an existing GRC Module and emit [GRCModuleActionSuccess]
  ///          on success or [GRCModuleFailure] on failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to update
  ///            [String] grcModuleNameEnglish: new English module name, if changed
  ///            [String] grcModuleNameArabic: new Arabic module name, if changed
  ///            [String] descriptionEnglish: new English description, if changed
  ///            [String] descriptionArabic: new Arabic description, if changed
  ///            [String] owningDepartment: new owning department, if changed
  ///            [DateTime] activationDate: new activation date, if changed
  ///            [List<String>] owners: new owners list, if changed
  ///            [String] status: new status, if changed
  ///            [File] imageFile: new local image file to upload, if changed
  ///            [String] imageUrl: a new already-hosted image URL, if changed
  ///
  /// return type: [Future<void>]
  Future<void> updateModule({
    required String id,
    String? grcModuleNameEnglish,
    String? grcModuleNameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? owningDepartment,
    DateTime? activationDate,
    List<String>? owners,
    String? status,
    File? imageFile,
    String? imageUrl,
  }) async {
    // Snapshot BEFORE the write. The spec's update notifications are all
    // differential — "status changed to Active", "date updated from X to Y",
    // "ownership reassigned" — so they cannot be derived from the saved result
    // alone. `_getUseCase` is the same read the repository does internally;
    // one extra read on a user-initiated save is a fair price for not sending
    // "date updated from 12 Oct to 12 Oct".
    //
    // Null when the read fails: the update still proceeds, and the
    // differential notifications are skipped rather than sent with wrong
    // values.
    final GRCModuleEntity? before = (await _getUseCase.execute(id)).fold(
      (_) => null,
      (GRCModuleEntity m) => m,
    );

    emit(GRCModuleLoading());
    final result = await _updateUseCase.execute(
      id: id,
      editorId: _currentUserEmail,
      grcModuleNameEnglish: grcModuleNameEnglish,
      grcModuleNameArabic: grcModuleNameArabic,
      descriptionEnglish: descriptionEnglish,
      descriptionArabic: descriptionArabic,
      owningDepartment: owningDepartment,
      activationDate: activationDate,
      owners: owners,
      status: status,
      imageFile: imageFile,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) {
        _notifyUpdate(before: before, after: module);
        emit(GRCModuleActionSuccess(module));
      },
    );
  }

  /// Raises whichever of the update notifications actually apply.
  ///
  /// One edit can legitimately trigger several — changing the owner AND the
  /// activation date in one save is two distinct events to two audiences — so
  /// these are independent `if`s, not a chain.
  ///
  /// "Module Updated/Edited" is the catch-all and fires only when nothing more
  /// specific did; otherwise every ownership change would arrive twice.
  void _notifyUpdate({
    required GRCModuleEntity? before,
    required GRCModuleEntity after,
  }) {
    final Set<String> audience = _moduleAudience(after);
    final String name = after.moduleNameEn;
    bool firedSpecific = false;

    if (before != null) {
      // ── Status ──────────────────────────────────────────────────────────
      if (before.status != after.status) {
        final bool isNowActive =
            after.status == GrcModuleStatus.active.value;
        // Only Active/Inactive have notifications in the spec. A move to
        // Scheduled or Removed is reported by its own event elsewhere.
        if (isNowActive || after.status == GrcModuleStatus.inactive.value) {
          firedSpecific = true;
          _notify(() => GrcModuleNotificationService.moduleStatusChanged(
                actorEmail: _currentUserEmail,
                moduleName: name,
                isNowActive: isNowActive,
                recipients: audience,
                isArabic: _isArabic,
              ));
        }
      }

      // ── Activation date ─────────────────────────────────────────────────
      if (!_isSameDay(before.moduleActivationDate, after.moduleActivationDate)) {
        firedSpecific = true;
        final DateFormat fmt =
            DateFormat('d MMM yyyy', _isArabic ? 'ar' : 'en');
        _notify(() => GrcModuleNotificationService.activationDateUpdated(
              actorEmail: _currentUserEmail,
              moduleName: name,
              oldDate: fmt.format(before.moduleActivationDate),
              newDate: fmt.format(after.moduleActivationDate),
              recipients: audience,
              isArabic: _isArabic,
            ));
      }

      // ── Ownership ───────────────────────────────────────────────────────
      final Set<String> oldOwners = before.moduleOwners.toSet();
      final Set<String> newOwners = after.moduleOwners.toSet();
      if (!_sameMembers(oldOwners, newOwners)) {
        firedSpecific = true;
        final Set<String> added = newOwners.difference(oldOwners)
          ..removeWhere((String e) => e.isEmpty);

        // Incoming owners get the second-person "you have been assigned".
        if (added.isNotEmpty) {
          _notify(() => GrcModuleNotificationService.ownerAssigned(
                actorEmail: _currentUserEmail,
                moduleName: name,
                newOwnerEmails: added.where((String e) => e != _currentUserEmail),
                isArabic: _isArabic,
              ));
        }

        // Everyone else hears the third-person "reassigned to {newOwnerName}" —
        // the owners who lost it, plus the audience, minus the new owners who
        // already got the message above.
        final Set<String> changedRecipients = <String>{
          ...oldOwners,
          ...audience,
        }
          ..removeAll(added)
          ..remove(_currentUserEmail)
          ..removeWhere((String e) => e.isEmpty);

        if (changedRecipients.isNotEmpty) {
          _notify(() => GrcModuleNotificationService.ownerChanged(
                actorEmail: _currentUserEmail,
                moduleName: name,
                newOwnerName: added.isEmpty ? '-' : added.first,
                recipients: changedRecipients,
                isArabic: _isArabic,
              ));
        }
      }

      // ── Owning department ───────────────────────────────────────────────
      if (before.moduleOwningDepartment != after.moduleOwningDepartment &&
          before.moduleOwningDepartment.isNotEmpty) {
        firedSpecific = true;
        // Goes to the department that LOST the module, per the wording
        // ("no longer under your department's responsibility"). Resolving that
        // department's members needs a lookup this cubit does not have, so the
        // current owners stand in until an audience resolver exists — the same
        // gap as the admin half of _moduleAudience.
        _notify(() => GrcModuleNotificationService.removedFromDepartment(
              actorEmail: _currentUserEmail,
              moduleName: name,
              departmentName: before.moduleOwningDepartment,
              recipients: audience,
              isArabic: _isArabic,
            ));
      }
    }

    if (!firedSpecific) {
      _notify(() => GrcModuleNotificationService.moduleUpdated(
            actorEmail: _currentUserEmail,
            moduleName: name,
            recipients: audience,
            isArabic: _isArabic,
          ));
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _sameMembers(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  /// function name: [deleteModule]
  ///
  /// purpose: soft-delete a GRC Module and emit [GRCModuleActionSuccess] on
  ///          success or [GRCModuleFailure] on failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to delete
  ///
  /// return type: [Future<void>]
  Future<void> deleteModule({required String id}) async {
    emit(GRCModuleLoading());
    final result = await _deleteUseCase.execute(
      id: id,
      editorId: _currentUserEmail,
    );
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) {
        _notify(() => GrcModuleNotificationService.moduleDeleted(
              actorEmail: _currentUserEmail,
              moduleName: module.moduleNameEn,
              recipients: _moduleAudience(module),
              isArabic: _isArabic,
            ));
        emit(GRCModuleActionSuccess(module));
      },
    );
  }

  /// function name: [restoreModule]
  ///
  /// purpose: restore a soft-deleted GRC Module and emit
  ///          [GRCModuleActionSuccess] on success or [GRCModuleFailure] on
  ///          failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to restore
  ///
  /// return type: [Future<void>]
  Future<void> restoreModule({required String id}) async {
    emit(GRCModuleLoading());
    final result = await _restoreUseCase.execute(
      id: id,
      editorId: _currentUserEmail,
    );
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) {
        _notify(() => GrcModuleNotificationService.moduleRestored(
              actorEmail: _currentUserEmail,
              moduleName: module.moduleNameEn,
              recipients: _moduleAudience(module),
              isArabic: _isArabic,
            ));
        emit(GRCModuleActionSuccess(module));
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS  —  spec §2.0 GRC, Module section
  // ══════════════════════════════════════════════════════════════════════
  //
  // Fired after a use case SUCCEEDS, never before: a notification about a save
  // that then failed is worse than no notification.
  //
  // Deliberately not awaited. A notification is a side effect of the action,
  // not part of it — blocking the emit on a Firestore write and an FCM round
  // trip would make every save feel slow, and a push failure must not surface
  // as a failed save. Errors are swallowed with a debugPrint for the same
  // reason.

  /// Who hears about something happening to [module].
  ///
  /// Per the agreed rule: the module's current owners, plus GRC admins.
  ///
  /// ⚠️ THE ADMIN HALF IS NOT RESOLVED YET, and that is deliberate rather than
  /// forgotten. This codebase has no admin-audience resolver — nothing
  /// anywhere answers "who are the GRC admins". Admin identity is also
  /// genuinely inconsistent here: AppDrawerCubit keys off `employee.id == '1'`
  /// (the subscription admin) while NavBarCubit keyed off role NAME, which is
  /// exactly the mismatch that hid GRC from the mobile nav. Inventing a third
  /// rule in a notification dispatcher would repeat that bug and silently mail
  /// the wrong people.
  ///
  /// Owners are unambiguous and are wired. To add admins, return them from
  /// here — it is the single seam, and every lifecycle notification picks them
  /// up at once.
  Set<String> _moduleAudience(GRCModuleEntity module) {
    final Set<String> audience = <String>{
      ...module.moduleOwners.where((String e) => e.isNotEmpty),
      // ...grcAdminEmails,   // ← see the note above
    }..remove(_currentUserEmail); // the actor already knows what they did

    // TEMPORARY (13/9/2026) — remove once GRC notifications are confirmed.
    // The two ways this silently produces nobody: the entity came back with an
    // empty owners list, or the only owner IS the actor. Both look identical
    // from the UI (an empty GRC tab), and neither raises an error anywhere.
    debugPrint('[grc-audience] module="${module.moduleNameEn}" '
        'owners=${module.moduleOwners} actor="$_currentUserEmail" '
        '-> audience=$audience');

    return audience;
  }

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  /// Runs a send without letting it affect the action that triggered it.
  void _notify(Future<int> Function() send) {
    unawaited(
      send().then((int sent) {
        // TEMPORARY (13/9/2026) — remove once GRC notifications are confirmed.
        // A send that resolves to 0 is indistinguishable from one that never
        // ran, which is what "I created a module and saw nothing" looks like
        // from the UI. AppNotificationSender logs WHY each recipient was
        // refused ([notify] lines); this says whether the call happened at all.
        debugPrint('[grc-notify] send resolved: $sent recipient(s). '
            'actor=$_currentUserEmail (the actor is never a recipient)');
        return sent;
      }).catchError((Object e, StackTrace st) {
        debugPrint('[grc-notify] send failed — $e\n$st');
        return 0;
      }),
    );
  }
}
