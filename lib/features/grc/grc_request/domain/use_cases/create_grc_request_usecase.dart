/// Module: GRC Request Management
/// Description: Use case for creating a new reassignment request — either
///              Reassign Control Champion (default, [type] left unset) or
///              Reassign Control Owner ([type]: GrcRequestType.reassignOwner).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class CreateGrcRequestParams {
  final String moduleId;
  final String requestedBy;
  final String note;
  final GrcRequestType type;

  // Reassign Control Champion (required when type == reassignChampion)
  final String? currentChampionEmail;
  final String? newChampionEmail;

  // Reassign Control Owner (required when type == reassignOwner)
  final String? currentOwnerEmail;
  final String? newOwnerEmail;

  final List<AssigningControlEntity> controls;
  final DateTime startDate;
  final DateTime? endDate;

  const CreateGrcRequestParams({
    required this.moduleId,
    required this.requestedBy,
    required this.note,
    required this.controls,
    required this.startDate,
    this.type = GrcRequestType.reassignChampion,
    this.currentChampionEmail,
    this.newChampionEmail,
    this.currentOwnerEmail,
    this.newOwnerEmail,
    this.endDate,
  });
}

class CreateGrcRequestUseCase {
  const CreateGrcRequestUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, GrcRequestEntity>> call(CreateGrcRequestParams params) {
    if (params.type == GrcRequestType.reassignOwner) {
      return _repository.createReassignOwnerRequest(
        moduleId: params.moduleId,
        requestedBy: params.requestedBy,
        note: params.note,
        currentOwnerEmail: params.currentOwnerEmail!,
        newOwnerEmail: params.newOwnerEmail!,
        controls: params.controls,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    }
    return _repository.createReassignChampionRequest(
      moduleId: params.moduleId,
      requestedBy: params.requestedBy,
      note: params.note,
      currentChampionEmail: params.currentChampionEmail!,
      newChampionEmail: params.newChampionEmail!,
      controls: params.controls,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
