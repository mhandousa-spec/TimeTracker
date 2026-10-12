/// Module: Control Owner Management
/// Description: BLoC Cubit that manages Control Owner state for the
///              presentation layer, mirroring ChampionCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, use cases, OwnerEntity, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notification_service.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notifier.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status_resolver.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_request_resolver.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/apply_owner_reassignment_usecase.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/create_owner_usecase.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/update_owner_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';

part 'owner_state.dart';

class OwnerCubit extends Cubit<OwnerState> {
  OwnerCubit({
    required CreateOwnerUseCase createOwnerUseCase,
    required GetOwnerUseCase getOwnerUseCase,
    required GetAllOwnersUseCase getAllOwnersUseCase,
    required UpdateOwnerUseCase updateOwnerUseCase,
    required GetGrcRequestsUseCase getGrcRequestsUseCase,
    required ApplyOwnerReassignmentUseCase applyOwnerReassignmentUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required UpdateControlUseCase updateControlUseCase,
  })  : _createUseCase = createOwnerUseCase,
        _getUseCase = getOwnerUseCase,
        _getAllUseCase = getAllOwnersUseCase,
        _updateUseCase = updateOwnerUseCase,
        _getGrcRequestsUseCase = getGrcRequestsUseCase,
        _applyReassignmentUseCase = applyOwnerReassignmentUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _updateControlUseCase = updateControlUseCase,
        super(OwnerInitial());

  final CreateOwnerUseCase _createUseCase;
  final GetOwnerUseCase _getUseCase;
  final GetAllOwnersUseCase _getAllUseCase;
  final UpdateOwnerUseCase _updateUseCase;
  final GetGrcRequestsUseCase _getGrcRequestsUseCase;
  final ApplyOwnerReassignmentUseCase _applyReassignmentUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final UpdateControlUseCase _updateControlUseCase;

  Future<void> getAllOwners({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    emit(OwnerLoading());
    await _applyDueReassignments(moduleId);
    await _stripExpiredControls(moduleId, includeRemoved: includeRemoved);
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owners) => emit(OwnerListLoaded(owners)),
    );
  }

  Future<void> _applyDueReassignments(String moduleId) async {
    final requestsResult = await _getGrcRequestsUseCase.call(moduleId);
    await requestsResult.fold(
      (_) async {}, // no requests fetched — nothing to apply, owner list still loads
      (requests) async {
        final due = findDueReassignmentRequests(
          requests,
          type: GrcRequestType.reassignOwner,
        );
        for (final request in due) {
          await _applyReassignmentUseCase.call(request);
        }
      },
    );
  }

  Future<void> _stripExpiredControls(
    String moduleId, {
    required bool includeRemoved,
  }) async {
    final currentResult = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    await currentResult.fold(
      (_) async {},
      (owners) async {
        for (final owner in owners) {
          final expired = findExpiredControls(owner.assigningControls);
          if (expired.isEmpty) continue;
          final remaining = owner.assigningControls.where((ac) {
            return !expired.any(
              (ex) => ex.policyId == ac.policyId && ex.controlId == ac.controlId,
            );
          }).toList();
          await _updateUseCase.call(
            UpdateOwnerParams(
              ownerEmail: owner.ownerEmail,
              moduleId: moduleId,
              editorId: currentGrcUserEmail(),
              assigningControls: remaining,
              status: remaining.isEmpty ? OwnerStatus.removed : null,
            ),
          );
        }
      },
    );
  }

  /// Thin pass-throughs for the Policy/Control use cases the Add Control
  /// Owner and Control Owner Details pages used to resolve straight out of
  /// `GetIt` inside their own `State`. Routing them through the Cubit
  /// (instead of adding new emitted states) keeps each page's existing
  /// `result.fold(...)` call-site logic byte-for-byte the same — only where
  /// the use case instance comes from changes.
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    required String moduleId,
  }) {
    return _getAllPoliciesUseCase.call(moduleId: moduleId);
  }

  Future<Either<Failure, List<ControlEntity>>> getAllControlsForPolicy({
    required String moduleId,
    required String policyId,
  }) {
    return _getAllControlsUseCase.call(moduleId: moduleId, policyId: policyId);
  }

  Future<Either<Failure, ControlEntity>> updateControl(
    UpdateControlParams params,
  ) {
    return _updateControlUseCase.call(params);
  }

  Future<void> getOwner(String ownerEmail, {required String moduleId}) async {
    emit(OwnerLoading());
    final result = await _getUseCase.call(ownerEmail, moduleId: moduleId);
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owner) => emit(OwnerActionSuccess(owner)),
    );
  }

  Future<Either<Failure, OwnerEntity>> createOwner({
    required String moduleId,
    required String ownerEmail,
    required List<AssigningControlEntity> assigningControls,
    /// false for bulk uploads, which announce the whole batch once instead
    /// of one notification per row.
    bool notify = true,
    /// GRC bug report p2 "Give score" switch.
    bool canGiveScore = true,
  }) async {
    emit(OwnerLoading());
    final result = await _createUseCase.call(
      CreateOwnerParams(
        moduleId: moduleId,
        ownerEmail: ownerEmail,
        assigningControls: assigningControls,
        editorId: currentGrcUserEmail(),
        canGiveScore: canGiveScore,
      ),
    );
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owner) {
        if (notify) {
          GrcAssigneeNotifier.assignmentChanged(
            role: GrcAssigneeRole.owner,
            moduleId: moduleId,
            assigneeEmail: ownerEmail,
            before: const <AssigningControlEntity>[],
            after: assigningControls,
            isNewAssignee: true,
          );
        }
        emit(OwnerActionSuccess(owner));
      },
    );
    return result;
  }

  Future<void> updateOwner({
    required String ownerEmail,
    required String moduleId,
    List<AssigningControlEntity>? assigningControls,
    List<List<String>>? controlOwnerPermissions,
    OwnerStatus? status,
    /// false for bulk uploads — see createOwner.
    bool notify = true,
  }) async {
    emit(OwnerLoading());
    // The assignee as it was before this save, so the notification can say
    // which controls were added or taken off.
    final OwnerEntity? previous = notify
        ? (await _getUseCase.call(ownerEmail, moduleId: moduleId))
            .fold<OwnerEntity?>((_) => null, (owner) => owner)
        : null;
    final result = await _updateUseCase.call(
      UpdateOwnerParams(
        ownerEmail: ownerEmail,
        moduleId: moduleId,
        editorId: currentGrcUserEmail(),
        assigningControls: assigningControls,
        controlOwnerPermissions: controlOwnerPermissions,
        status: status,
      ),
    );
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owner) {
        if (previous != null) {
          GrcAssigneeNotifier.assignmentChanged(
            role: GrcAssigneeRole.owner,
            moduleId: moduleId,
            assigneeEmail: ownerEmail,
            before: previous.assigningControls,
            after: owner.assigningControls,
            removedFromModule: status == OwnerStatus.removed &&
                previous.status != OwnerStatus.removed,
          );
        }
        emit(OwnerActionSuccess(owner));
      },
    );
  }

  /// Raw owners fetch with none of [getAllOwners]'s side effects
  /// (reassignment sweep, expired-control stripping, state emission) — used
  /// internally by pages that just need the current owner list for a
  /// computation, not to update the Cubit's list state.
  Future<Either<Failure, List<OwnerEntity>>> getAllOwnersRaw({
    required String moduleId,
    bool includeRemoved = false,
  }) {
    return _getAllUseCase.call(moduleId: moduleId, includeRemoved: includeRemoved);
  }

  /// Every owner email in [owners] whose Assigning_Controls already includes
  /// this exact {[policyId], [controlId]} pair. Moved verbatim from
  /// AddEditControlPage's former `_alreadyAssignedOwnerEmails`, with the
  /// control/policy id threaded in as parameters instead of read from widget
  /// state.
  List<String> alreadyAssignedEmails(
    List<OwnerEntity> owners, {
    required String policyId,
    required String controlId,
  }) {
    return owners
        .where((o) => o.assigningControls
            .any((a) => a.policyId == policyId && a.controlId == controlId))
        .map((o) => o.ownerEmail)
        .toList();
  }

  /// function name: [recomputeControlStatuses]
  ///
  /// purpose: before the Owner's controls are persisted, recompute the status
  ///          of every control whose assignment to [owner] just changed
  ///          — a newly-added control flips Unassigned -> Scheduled/Active;
  ///          a newly-removed one flips back to Unassigned, but only if no
  ///          other Owner or Champion in the module still covers it.
  ///          Controls currently Draft/Inactive/Expired are left untouched
  ///          either way (see [shouldRecomputeAssigneeBasedStatus]).
  ///
  ///          Moved verbatim out of EditOwnerControlsPage's former private
  ///          `_recomputeControlStatuses`, with the owner, the newly-selected
  ///          controls, the moduleId and the policy->controls lookup threaded
  ///          in as explicit parameters instead of read from widget/State.
  ///          Intentionally emits no state: it touches Control documents
  ///          directly, not the Owner document this cubit's state tracks, so
  ///          the page invokes it fire-and-forget alongside updateOwner.
  Future<void> recomputeControlStatuses({
    required OwnerEntity owner,
    required List<AssigningControlEntity> newControls,
    required String moduleId,
    required Map<String, List<ControlEntity>> policyControls,
  }) async {
    final originalPairs = owner.assigningControls
        .map((ac) => (ac.policyId, ac.controlId))
        .toSet();
    final newPairs =
        newControls.map((ac) => (ac.policyId, ac.controlId)).toSet();
    final added = newPairs.difference(originalPairs);
    final removed = originalPairs.difference(newPairs);
    if (added.isEmpty && removed.isEmpty) return;

    var champions = const <ChampionEntity>[];
    var otherOwners = const <OwnerEntity>[];
    if (removed.isNotEmpty) {
      final championsResult = await GetIt.instance<GetAllChampionsUseCase>()
          .call(moduleId: moduleId);
      champions =
          championsResult.fold((failure) => const <ChampionEntity>[], (c) => c);
      final ownersResult = await GetIt.instance<GetAllOwnersUseCase>()
          .call(moduleId: moduleId);
      otherOwners = ownersResult.fold(
        (failure) => const <OwnerEntity>[],
        (owners) => owners
            .where((o) => o.ownerEmail != owner.ownerEmail)
            .toList(),
      );
    }

    final editor = currentGrcUserEmail();
    final updateUseCase = GetIt.instance<UpdateControlUseCase>();

    Future<void> applyStatus(
      (String, String) pair, {
      required bool hasAnyAssignee,
    }) async {
      final control = findControlInPolicy(policyControls, pair.$1, pair.$2);
      if (control == null) return;
      if (!shouldRecomputeAssigneeBasedStatus(control.status)) return;
      final newStatus = computeAssigneeBasedControlStatus(
        effectiveStartDate: control.startDate,
        hasAnyAssignee: hasAnyAssignee,
      );
      if (newStatus == control.status) return;
      await updateUseCase.call(
        UpdateControlParams(
          id: control.id,
          moduleId: moduleId,
          policyId: pair.$1,
          editorId: editor,
          status: newStatus,
        ),
      );
    }

    for (final pair in added) {
      await applyStatus(pair, hasAnyAssignee: true);
    }
    for (final pair in removed) {
      final stillCovered = champions.any((c) => c.assigningControls
              .any((ac) => ac.policyId == pair.$1 && ac.controlId == pair.$2)) ||
          otherOwners.any((o) => o.assigningControls
              .any((ac) => ac.policyId == pair.$1 && ac.controlId == pair.$2));
      await applyStatus(pair, hasAnyAssignee: stillCovered);
    }
  }

  OwnerEntity? _findByEmail(List<OwnerEntity> all, String email) {
    for (final o in all) {
      if (o.ownerEmail == email) return o;
    }
    return null;
  }

  /// Mirrors ChampionCubit.applyAssignmentDiff for Control Owners. Reconciles
  /// [selected] against [alreadyAssigned] by appending/removing this
  /// {[policyId], [controlId]} pair on exactly the owners whose selection
  /// changed. Returns false if any individual update/create failed. Moved
  /// verbatim from AddEditControlPage's former `_applyOwnerDiff`.
  Future<bool> applyAssignmentDiff({
    required List<OwnerEntity> allOwners,
    required List<String> alreadyAssigned,
    required List<String> selected,
    required String moduleId,
    required String policyId,
    required String controlId,
  }) async {
    var success = true;
    final added = selected.where((e) => !alreadyAssigned.contains(e));
    final removed = alreadyAssigned.where((e) => !selected.contains(e));

    for (final email in added) {
      final existing = _findByEmail(allOwners, email);
      if (existing != null) {
        await updateOwner(
          ownerEmail: email,
          moduleId: moduleId,
          assigningControls: [
            ...existing.assigningControls,
            AssigningControlEntity(policyId: policyId, controlId: controlId),
          ],
        );
      } else {
        await createOwner(
          moduleId: moduleId,
          ownerEmail: email,
          assigningControls: [
            AssigningControlEntity(policyId: policyId, controlId: controlId),
          ],
        );
      }
      if (state is OwnerFailure) success = false;
    }

    for (final email in removed) {
      final existing = _findByEmail(allOwners, email);
      if (existing == null) continue;
      await updateOwner(
        ownerEmail: email,
        moduleId: moduleId,
        assigningControls: existing.assigningControls
            .where((a) => !(a.policyId == policyId && a.controlId == controlId))
            .toList(),
      );
      if (state is OwnerFailure) success = false;
    }

    return success;
  }
}
