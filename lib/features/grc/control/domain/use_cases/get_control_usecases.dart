/// Module: Policy Management
/// Description: Use cases for reading (single/all) and deleting Control
///              records. No restore use case — Controls have no Removed
///              status.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, Failure, ControlEntity, ControlRepository
/// Revision History: 2026-07-14 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/repository/control_repository.dart';

/// class name: [GetControlUseCase]
///
/// purpose: encapsulate the "fetch a single Control" business action.
class GetControlUseCase {
  const GetControlUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, ControlEntity>> call(
    String id, {
    required String moduleId,
    required String policyId,
  }) {
    return _repository.getControl(id, moduleId: moduleId, policyId: policyId);
  }
}

/// class name: [GetAllControlsUseCase]
///
/// purpose: encapsulate the "fetch all Controls for a Policy" business
///          action.
class GetAllControlsUseCase {
  const GetAllControlsUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, List<ControlEntity>>> call({
    required String moduleId,
    required String policyId,
  }) {
    return _repository.getAllControls(moduleId: moduleId, policyId: policyId);
  }
}

/// class name: [DeleteControlParams]
///
/// purpose: groups the fields required to hard-delete a Control record.
class DeleteControlParams {
  final String id;
  final String moduleId;
  final String policyId;

  const DeleteControlParams({
    required this.id,
    required this.moduleId,
    required this.policyId,
  });
}

/// class name: [DeleteControlUseCase]
///
/// purpose: encapsulate the "delete a Control" business action (hard
///          delete — Controls have no Removed status).
class DeleteControlUseCase {
  const DeleteControlUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, Unit>> call(DeleteControlParams params) {
    return _repository.deleteControl(
      params.id,
      moduleId: params.moduleId,
      policyId: params.policyId,
    );
  }
}
