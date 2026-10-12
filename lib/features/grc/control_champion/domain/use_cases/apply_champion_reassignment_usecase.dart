/// Module: Control Champion Management
/// Description: Applies one due Reassign Control Champion request: moves
///              its controls from the current champion to the new champion
///              (tagging each with the request's End Date as expiresOn),
///              then marks the request applied. This is the logic that used
///              to run immediately on ReassignChampionPage's submit button —
///              it now only runs once a request's Start Date has arrived,
///              found by champion_request_resolver.findDueReassignmentRequests.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, ChampionRepository, GrcRequestRepository, GrcRequestEntity
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/repository/champion_repository.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class ApplyChampionReassignmentUseCase {
  const ApplyChampionReassignmentUseCase({
    required ChampionRepository championRepository,
    required GrcRequestRepository requestRepository,
  })  : _championRepository = championRepository,
        _requestRepository = requestRepository;

  final ChampionRepository _championRepository;
  final GrcRequestRepository _requestRepository;

  Future<Either<Failure, Unit>> call(GrcRequestEntity request) async {
    final currentEmail = request.currentChampionEmail;
    final newEmail = request.newChampionEmail;
    final controls = request.controls;
    if (currentEmail == null || newEmail == null || controls == null) {
      return Left(ValidationError(
        'Reassignment request ${request.id} is missing champion/control data',
      ));
    }

    final currentResult = await _championRepository.getChampion(
      currentEmail,
      moduleId: request.moduleId,
    );
    final removalResult = await currentResult.fold<Future<Either<Failure, Unit>>>(
      (failure) async => Left(failure),
      (current) async {
        final remaining = current.assigningControls.where((ac) {
          return !controls.any(
            (rc) => rc.policyId == ac.policyId && rc.controlId == ac.controlId,
          );
        }).toList();
        final updateResult = await _championRepository.updateChampion(
          championEmail: currentEmail,
          moduleId: request.moduleId,
          editorId: request.requestedBy,
          assigningControls: remaining,
          status: remaining.isEmpty ? ChampionStatus.removed : null,
        );
        return updateResult.fold((f) => Left(f), (_) => const Right(unit));
      },
    );
    if (removalResult.isLeft()) {
      return removalResult;
    }

    final taggedControls = controls
        .map((c) => c.copyWith(expiresOn: request.endDate))
        .toList();

    final newChampionResult = await _championRepository.getChampion(
      newEmail,
      moduleId: request.moduleId,
    );
    final additionResult = await newChampionResult.fold<Future<Either<Failure, Unit>>>(
      (failure) async {
        final createResult = await _championRepository.createChampion(
          moduleId: request.moduleId,
          championEmail: newEmail,
          assigningControls: taggedControls,
          editorId: request.requestedBy,
        );
        return createResult.fold((f) => Left(f), (_) => const Right(unit));
      },
      (existing) async {
        final merged = <AssigningControlEntity>[...existing.assigningControls];
        for (final tc in taggedControls) {
          final exists = merged.any(
            (ac) => ac.policyId == tc.policyId && ac.controlId == tc.controlId,
          );
          if (!exists) merged.add(tc);
        }
        final updateResult = await _championRepository.updateChampion(
          championEmail: newEmail,
          moduleId: request.moduleId,
          editorId: request.requestedBy,
          assigningControls: merged,
          status: ChampionStatus.active,
        );
        return updateResult.fold((f) => Left(f), (_) => const Right(unit));
      },
    );
    if (additionResult.isLeft()) {
      return additionResult;
    }

    final markResult = await _requestRepository.markApplied(
      moduleId: request.moduleId,
      requestId: request.id,
    );
    return markResult.fold((f) => Left(f), (_) => const Right(unit));
  }
}
