/// Module: GRC Module Management
/// Description: Use case responsible for updating an existing GRC Module
///              record. Only fields that are explicitly provided are changed.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: dartz, GRCModuleRepository, GRCModuleEntity, Failure
/// Revision History: 2026-06-30 - Initial creation
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/domain/repository/grc_module_repository.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: update_grc_module_use_case.dart
/// Purpose: Contains the UpdateGRCModuleUseCase class, which encapsulates
///          the business logic for updating an existing GRC Module record.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [UpdateGRCModuleUseCase]
///
/// purpose: encapsulate the business logic for updating an existing GRC
///          Module. Only the fields explicitly passed to [execute] are
///          changed; all others keep their previous values. Delegates to
///          [GRCModuleRepository.updateModule] and returns the result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class UpdateGRCModuleUseCase {
  final GRCModuleRepository _repository;

  UpdateGRCModuleUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: update an existing GRC Module record. Any parameter left null
  ///          is not changed; only provided (non-null) values overwrite the
  ///          existing ones. A new revision is appended to the history.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to update
  ///            [String] editorId: id of the user performing the update
  ///            [String] grcModuleNameEnglish: new English module name, if changed
  ///            [String] grcModuleNameArabic: new Arabic module name, if changed
  ///            [String] descriptionEnglish: new English description, if changed
  ///            [String] descriptionArabic: new Arabic description, if changed
  ///            [String] owningDepartment: new owning department, if changed
  ///            [DateTime] activationDate: new activation date, if changed
  ///            [List<String>] owners: new owners list, if changed
  ///            [String] status: new status, if changed
  ///            [File] imageFile: new local image file to upload, if changed
  ///            [String] imageUrl: a new already-hosted image URL, if changed
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the updated entity, or a Failure
  Future<Either<Failure, GRCModuleEntity>> execute({
    required String id,
    required String editorId,
    String? grcModuleNameEnglish,
    String? grcModuleNameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? owningDepartment,
    DateTime? activationDate,
    List<String>? owners,
    String? status,
    double? score,
    File? imageFile,
    String? imageUrl,
  }) {
    return _repository.updateModule(
      id: id,
      editorId: editorId,
      grcModuleNameEnglish: grcModuleNameEnglish,
      grcModuleNameArabic: grcModuleNameArabic,
      descriptionEnglish: descriptionEnglish,
      descriptionArabic: descriptionArabic,
      owningDepartment: owningDepartment,
      activationDate: activationDate,
      owners: owners,
      status: status,
      score: score,
      imageFile: imageFile,
      imageUrl: imageUrl,
    );
  }
}
