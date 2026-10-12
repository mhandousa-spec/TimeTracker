/// Module: Control Owner Management
/// Description: Applies one due Reassign Control Owner request: moves its
///              controls from the current owner to the new owner (tagging
///              each with the request's End Date as expiresOn), then marks
///              the request applied. Mirrors
///              ApplyChampionReassignmentUseCase exactly, for OwnerRepository.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, OwnerRepository, GrcRequestRepository, GrcRequestEntity
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/repository/owner_repository.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class ApplyOwnerReassignmentUseCase {
  const ApplyOwnerReassignmentUseCase({
    required OwnerRepository ownerRepository,
    required GrcRequestRepository requestRepository,
  })  : _ownerRepository = ownerRepository,
        _requestRepository = requestRepository;

  final OwnerRepository _ownerRepository;
  final GrcRequestRepository _requestRepository;

  Future<Either<Failure, Unit>> call(GrcRequestEntity request) async {
    final currentEmail = request.currentOwnerEmail;
    final newEmail = request.newOwnerEmail;
    final controls = request.controls;
    if (currentEmail == null || newEmail == null || controls == null) {
      return Left(ValidationError(
        'Reassignment request ${request.id} is missing owner/control data',
      ));
    }

    final currentResult = await _ownerRepository.getOwner(
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
        final updateResult = await _ownerRepository.updateOwner(
          ownerEmail: currentEmail,
          moduleId: request.moduleId,
          editorId: request.requestedBy,
          assigningControls: remaining,
          status: remaining.isEmpty ? OwnerStatus.removed : null,
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

    final newOwnerResult = await _ownerRepository.getOwner(
      newEmail,
      moduleId: request.moduleId,
    );
    final additionResult = await newOwnerResult.fold<Future<Either<Failure, Unit>>>(
      (failure) async {
        final createResult = await _ownerRepository.createOwner(
          moduleId: request.moduleId,
          ownerEmail: newEmail,
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
        final updateResult = await _ownerRepository.updateOwner(
          ownerEmail: newEmail,
          moduleId: request.moduleId,
          editorId: request.requestedBy,
          assigningControls: merged,
          status: OwnerStatus.active,
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
