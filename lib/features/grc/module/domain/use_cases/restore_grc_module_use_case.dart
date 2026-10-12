/// Module: GRC Module Management
/// Description: Use case responsible for restoring a previously soft-deleted
///              GRC Module record by appending a new revision with
///              isDeleted = false.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: dartz, GRCModuleRepository, GRCModuleEntity, Failure
/// Revision History: 2026-06-30 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/domain/repository/grc_module_repository.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: restore_grc_module_use_case.dart
/// Purpose: Contains the RestoreGRCModuleUseCase class, which encapsulates
///          the business logic for restoring a soft-deleted GRC Module record.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [RestoreGRCModuleUseCase]
///
/// purpose: encapsulate the business logic for restoring a previously
///          soft-deleted GRC Module. A new revision with isDeleted = false
///          is appended to the history. Delegates to
///          [GRCModuleRepository.restoreModule] and returns the result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class RestoreGRCModuleUseCase {
  final GRCModuleRepository _repository;

  RestoreGRCModuleUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: restore the soft-deleted GRC Module identified by [id] by
  ///          appending a new revision with isDeleted = false.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to restore
  ///            [String] editorId: id of the user performing the restore
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the entity after the restore revision, or a Failure
  Future<Either<Failure, GRCModuleEntity>> execute({
    required String id,
    required String editorId,
  }) {
    return _repository.restoreModule(id: id, editorId: editorId);
  }
}
