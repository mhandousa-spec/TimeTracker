/// Module: GRC Module Management
/// Description: Use case responsible for soft-deleting a GRC Module record.
///              The record is NOT physically removed — a new revision is
///              appended with isDeleted = true so it can be restored later.
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
/// File Name: delete_grc_module_use_case.dart
/// Purpose: Contains the DeleteGRCModuleUseCase class, which encapsulates
///          the business logic for soft-deleting a GRC Module record.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [DeleteGRCModuleUseCase]
///
/// purpose: encapsulate the business logic for soft-deleting a GRC Module.
///          The record remains in the database; only a new revision with
///          isDeleted = true is appended. Delegates to
///          [GRCModuleRepository.deleteModule] and returns the result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class DeleteGRCModuleUseCase {
  final GRCModuleRepository _repository;

  DeleteGRCModuleUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: soft-delete the GRC Module identified by [id]. The record stays
  ///          in the database and can be recovered via [RestoreGRCModuleUseCase].
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to delete
  ///            [String] editorId: id of the user performing the delete
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the entity after the delete revision, or a Failure
  Future<Either<Failure, GRCModuleEntity>> execute({
    required String id,
    required String editorId,
  }) {
    return _repository.deleteModule(id: id, editorId: editorId);
  }
}
