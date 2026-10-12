/// Module: GRC Module Management
/// Description: Use case responsible for fetching a single GRC Module record
///              by its unique id.
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
/// File Name: get_grc_module_use_case.dart
/// Purpose: Contains the GetGRCModuleUseCase class, which encapsulates
///          the business logic for fetching a single GRC Module by id.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GetGRCModuleUseCase]
///
/// purpose: encapsulate the business logic for fetching a single GRC Module
///          record by its unique id. Delegates to
///          [GRCModuleRepository.getModule] and returns the result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GetGRCModuleUseCase {
  final GRCModuleRepository _repository;

  GetGRCModuleUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch a single GRC Module record that matches [id].
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to fetch
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the matching entity, or a Failure
  Future<Either<Failure, GRCModuleEntity>> execute(String id) {
    return _repository.getModule(id);
  }
}
