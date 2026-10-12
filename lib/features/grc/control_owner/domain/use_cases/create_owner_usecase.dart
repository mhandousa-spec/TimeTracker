// lib/features/grc/control_owner/domain/use_cases/create_owner_usecase.dart
/// Module: Control Owner Management
/// Description: Use case for creating a new Control Owner.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, Failure, OwnerEntity, OwnerRepository, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/repository/owner_repository.dart';

class CreateOwnerParams {
  final String moduleId;
  final String ownerEmail;
  final List<AssigningControlEntity> assigningControls;
  final String editorId;
  final bool canGiveScore;

  const CreateOwnerParams({
    required this.moduleId,
    required this.ownerEmail,
    required this.assigningControls,
    required this.editorId,
    this.canGiveScore = true,
  });
}

class CreateOwnerUseCase {
  const CreateOwnerUseCase(this._repository);

  final OwnerRepository _repository;

  Future<Either<Failure, OwnerEntity>> call(CreateOwnerParams params) {
    return _repository.createOwner(
      moduleId: params.moduleId,
      ownerEmail: params.ownerEmail,
      assigningControls: params.assigningControls,
      editorId: params.editorId,
      canGiveScore: params.canGiveScore,
    );
  }
}
