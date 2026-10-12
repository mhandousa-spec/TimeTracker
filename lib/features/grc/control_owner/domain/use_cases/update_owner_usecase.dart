// lib/features/grc/control_owner/domain/use_cases/update_owner_usecase.dart
/// Module: Control Owner Management
/// Description: Use case for updating an existing Control Owner (also
///              covers soft-delete/restore via status).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, Failure, OwnerEntity, OwnerStatus, OwnerRepository, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/repository/owner_repository.dart';

class UpdateOwnerParams {
  final String ownerEmail;
  final String moduleId;
  final String editorId;
  final List<AssigningControlEntity>? assigningControls;
  final List<List<String>>? controlOwnerPermissions;
  final OwnerStatus? status;

  const UpdateOwnerParams({
    required this.ownerEmail,
    required this.moduleId,
    required this.editorId,
    this.assigningControls,
    this.controlOwnerPermissions,
    this.status,
  });
}

class UpdateOwnerUseCase {
  const UpdateOwnerUseCase(this._repository);

  final OwnerRepository _repository;

  Future<Either<Failure, OwnerEntity>> call(UpdateOwnerParams params) {
    return _repository.updateOwner(
      ownerEmail: params.ownerEmail,
      moduleId: params.moduleId,
      editorId: params.editorId,
      assigningControls: params.assigningControls,
      controlOwnerPermissions: params.controlOwnerPermissions,
      status: params.status,
    );
  }
}
