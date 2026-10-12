/// Module: GRC Module Management
/// Description: Use case responsible for fetching a GRC Module's owner
///              assignment history.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: dartz, GRCModuleRepository, GRCModuleOwnerHistoryEntry, Failure
/// Revision History: 2026-07-13 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/module/domain/repository/grc_module_repository.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: get_grc_module_owner_history_use_case.dart
/// Purpose: Contains the GetGRCModuleOwnerHistoryUseCase class, which
///          encapsulates the business logic for fetching a module's owner
///          assignment history.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 13/7/2026

/// class name: [GetGRCModuleOwnerHistoryUseCase]
///
/// purpose: encapsulate the business logic for fetching a single GRC
///          Module's owner-assignment history by its id. Delegates to
///          [GRCModuleRepository.getModuleOwnerHistory] and returns the
///          result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 13/7/2026
class GetGRCModuleOwnerHistoryUseCase {
  final GRCModuleRepository _repository;

  GetGRCModuleOwnerHistoryUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch the owner-assignment history for the module matching [id].
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>] - completed owner stints, or a Failure
  Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>> execute(
    String id,
  ) {
    return _repository.getModuleOwnerHistory(id);
  }
}
