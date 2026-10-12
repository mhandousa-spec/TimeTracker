/// Module: Control Champion Management
/// Description: BLoC Cubit that manages Control Champion state for the
///              presentation layer, mirroring PolicyCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, use cases, ChampionEntity, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notification_service.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notifier.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/create_champion_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/update_champion_usecase.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_request_resolver.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/apply_champion_reassignment_usecase.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';

part 'champion_state.dart';

class ChampionCubit extends Cubit<ChampionState> {
  ChampionCubit({
    required CreateChampionUseCase createChampionUseCase,
    required GetChampionUseCase getChampionUseCase,
    required GetAllChampionsUseCase getAllChampionsUseCase,
    required UpdateChampionUseCase updateChampionUseCase,
    required GetGrcRequestsUseCase getGrcRequestsUseCase,
    required ApplyChampionReassignmentUseCase applyChampionReassignmentUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required UpdateControlUseCase updateControlUseCase,
    required GetAllOwnersUseCase getAllOwnersUseCase,
  })  : _createUseCase = createChampionUseCase,
        _getUseCase = getChampionUseCase,
        _getAllUseCase = getAllChampionsUseCase,
        _updateUseCase = updateChampionUseCase,
        _getGrcRequestsUseCase = getGrcRequestsUseCase,
        _applyReassignmentUseCase = applyChampionReassignmentUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _updateControlUseCase = updateControlUseCase,
        _getAllOwnersUseCase = getAllOwnersUseCase,
        super(ChampionInitial());

  final CreateChampionUseCase _createUseCase;
  final GetChampionUseCase _getUseCase;
  final GetAllChampionsUseCase _getAllUseCase;
  final UpdateChampionUseCase _updateUseCase;
  final GetGrcRequestsUseCase _getGrcRequestsUseCase;
  final ApplyChampionReassignmentUseCase _applyReassignmentUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final UpdateControlUseCase _updateControlUseCase;
  final GetAllOwnersUseCase _getAllOwnersUseCase;

  Future<void> getAllChampions({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    emit(ChampionLoading());
    await _applyDueReassignments(moduleId);
    await _stripExpiredControls(moduleId, includeRemoved: includeRemoved);
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champions) => emit(ChampionListLoaded(champions)),
    );
  }

  Future<void> _applyDueReassignments(String moduleId) async {
    final requestsResult = await _getGrcRequestsUseCase.call(moduleId);
    await requestsResult.fold(
      (_) async {}, // no requests fetched — nothing to apply, champion list still loads
      (requests) async {
        final due = findDueReassignmentRequests(requests);
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
      (champions) async {
        for (final champion in champions) {
          final expired = findExpiredControls(champion.assigningControls);
          if (expired.isEmpty) continue;
          final remaining = champion.assigningControls.where((ac) {
            return !expired.any(
              (ex) => ex.policyId == ac.policyId && ex.controlId == ac.controlId,
            );
          }).toList();
          await _updateUseCase.call(
            UpdateChampionParams(
              championEmail: champion.championEmail,
              moduleId: moduleId,
              editorId: currentGrcUserEmail(),
              assigningControls: remaining,
              status: remaining.isEmpty ? ChampionStatus.removed : null,
            ),
          );
        }
      },
    );
  }

  Future<void> getChampion(String championEmail, {required String moduleId}) async {
    emit(ChampionLoading());
    final result = await _getUseCase.call(championEmail, moduleId: moduleId);
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champion) => emit(ChampionActionSuccess(champion)),
    );
  }

  Future<Either<Failure, ChampionEntity>> createChampion({
    required String moduleId,
    required String championEmail,
    required List<AssigningControlEntity> assigningControls,
    /// false for bulk uploads, which announce the whole batch once instead
    /// of one notification per row.
    bool notify = true,
  }) async {
    emit(ChampionLoading());
    final result = await _createUseCase.call(
      CreateChampionParams(
        moduleId: moduleId,
        championEmail: championEmail,
        assigningControls: assigningControls,
        editorId: currentGrcUserEmail(),
      ),
    );
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champion) {
        if (notify) {
          GrcAssigneeNotifier.assignmentChanged(
            role: GrcAssigneeRole.champion,
            moduleId: moduleId,
            assigneeEmail: championEmail,
            before: const <AssigningControlEntity>[],
            after: assigningControls,
            isNewAssignee: true,
          );
        }
        emit(ChampionActionSuccess(champion));
      },
    );
    return result;
  }

  Future<void> updateChampion({
    required String championEmail,
    required String moduleId,
    List<AssigningControlEntity>? assigningControls,
    ChampionStatus? status,
    /// false for bulk uploads — see createChampion.
    bool notify = true,
  }) async {
    emit(ChampionLoading());
    // The assignee as it was before this save, so the notification can say
    // which controls were added or taken off.
    final ChampionEntity? previous = notify
        ? (await _getUseCase.call(championEmail, moduleId: moduleId))
            .fold<ChampionEntity?>((_) => null, (champion) => champion)
        : null;
    final result = await _updateUseCase.call(
      UpdateChampionParams(
        championEmail: championEmail,
        moduleId: moduleId,
        editorId: currentGrcUserEmail(),
        assigningControls: assigningControls,
        status: status,
      ),
    );
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champion) {
        if (previous != null) {
          GrcAssigneeNotifier.assignmentChanged(
            role: GrcAssigneeRole.champion,
            moduleId: moduleId,
            assigneeEmail: championEmail,
            before: previous.assigningControls,
            after: champion.assigningControls,
            removedFromModule: status == ChampionStatus.removed &&
                previous.status != ChampionStatus.removed,
          );
        }
        emit(ChampionActionSuccess(champion));
      },
    );
  }

  /// Thin pass-throughs for the Policy/Control/Owner use cases the three
  /// Control Champion pages used to resolve straight out of `GetIt` inside
  /// their own `State`. Routing them through the Cubit (instead of adding
  /// new emitted states) keeps each page's existing `result.fold(...)`
  /// call-site logic byte-for-byte the same — only where the use case
  /// instance comes from changes.
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

  Future<Either<Failure, List<OwnerEntity>>> getAllOwners({
    required String moduleId,
  }) {
    return _getAllOwnersUseCase.call(moduleId: moduleId);
  }

  /// Raw champions fetch with none of [getAllChampions]'s side effects
  /// (reassignment sweep, expired-control stripping, state emission) — used
  /// internally by pages that just need the current champion list for a
  /// computation, not to update the Cubit's list state.
  Future<Either<Failure, List<ChampionEntity>>> getAllChampionsRaw({
    required String moduleId,
    bool includeRemoved = false,
  }) {
    return _getAllUseCase.call(moduleId: moduleId, includeRemoved: includeRemoved);
  }

  /// Every champion email in [champions] whose Assigning_Controls already
  /// includes this exact {[policyId], [controlId]} pair. Moved verbatim from
  /// AddEditControlPage's former `_alreadyAssignedChampionEmails`, with the
  /// control/policy id threaded in as parameters instead of read from widget
  /// state.
  List<String> alreadyAssignedEmails(
    List<ChampionEntity> champions, {
    required String policyId,
    required String controlId,
  }) {
    return champions
        .where((c) => c.assigningControls
            .any((a) => a.policyId == policyId && a.controlId == controlId))
        .map((c) => c.championEmail)
        .toList();
  }

  ChampionEntity? _findByEmail(List<ChampionEntity> all, String email) {
    for (final c in all) {
      if (c.championEmail == email) return c;
    }
    return null;
  }

  /// Reconciles [selected] (the picker's current selection) against
  /// [alreadyAssigned] (what was true when the page opened) by
  /// appending/removing this {[policyId], [controlId]} pair on exactly the
  /// champions whose selection state actually changed. Every call is awaited
  /// sequentially — at most a handful of people per save, simplicity over
  /// throughput. Returns false if any individual update/create failed. Moved
  /// verbatim from AddEditControlPage's former `_applyChampionDiff`; the
  /// `cubit`/`this.moduleId`/`this.policyId` it used to close over are now
  /// `this`/[moduleId]/[policyId] parameters.
  Future<bool> applyAssignmentDiff({
    required List<ChampionEntity> allChampions,
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
      final existing = _findByEmail(allChampions, email);
      if (existing != null) {
        await updateChampion(
          championEmail: email,
          moduleId: moduleId,
          assigningControls: [
            ...existing.assigningControls,
            AssigningControlEntity(policyId: policyId, controlId: controlId),
          ],
        );
      } else {
        await createChampion(
          moduleId: moduleId,
          championEmail: email,
          assigningControls: [
            AssigningControlEntity(policyId: policyId, controlId: controlId),
          ],
        );
      }
      if (state is ChampionFailure) success = false;
    }

    for (final email in removed) {
      final existing = _findByEmail(allChampions, email);
      if (existing == null) continue;
      await updateChampion(
        championEmail: email,
        moduleId: moduleId,
        assigningControls: existing.assigningControls
            .where((a) => !(a.policyId == policyId && a.controlId == controlId))
            .toList(),
      );
      if (state is ChampionFailure) success = false;
    }

    return success;
  }
}
