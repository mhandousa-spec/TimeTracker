/// Module: GRC Module Management
/// Description: Use case responsible for fetching all GRC Module records,
///              with optional inclusion of soft-deleted ones.
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
/// File Name: get_all_grc_modules_use_case.dart
/// Purpose: Contains the GetAllGRCModulesUseCase class, which encapsulates
///          the business logic for fetching all GRC Module records.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GetAllGRCModulesUseCase]
///
/// purpose: encapsulate the business logic for fetching all GRC Module
///          records. Supports an [includeDeleted] flag to optionally include
///          soft-deleted records. Delegates to
///          [GRCModuleRepository.getAllModules] and returns the result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GetAllGRCModulesUseCase {
  final GRCModuleRepository _repository;

  GetAllGRCModulesUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch all GRC Module records. By default only active (non-deleted)
  ///          records are returned; pass [includeDeleted] = true to include
  ///          soft-deleted ones as well.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when true, soft-deleted modules are
  ///            included in the result (default: false)
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleEntity>>>] - the list of entities, or a Failure
  Future<Either<Failure, List<GRCModuleEntity>>> execute({
    bool includeDeleted = false,
  }) {
    return _repository.getAllModules(includeDeleted: includeDeleted);
  }
}
