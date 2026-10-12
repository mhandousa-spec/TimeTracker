/// Module: GRC Module Management
/// Description: Use case responsible for creating a new GRC Module record.
///              Delegates to [GRCModuleRepository] and returns the created
///              entity or a [Failure].
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
/// File Name: create_grc_module_use_case.dart
/// Purpose: Contains the CreateGRCModuleUseCase class, which encapsulates
///          the business logic for creating a new GRC Module record.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [CreateGRCModuleUseCase]
///
/// purpose: encapsulate the business logic for creating a new GRC Module.
///          Receives all required parameters via [execute], delegates to
///          [GRCModuleRepository.createModule], and returns the result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class CreateGRCModuleUseCase {
  final GRCModuleRepository _repository;

  CreateGRCModuleUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: create a new GRC Module record. Optionally uploads [imageFile]
  ///          to Firebase Storage (via the repository) before persisting the
  ///          record; otherwise uses [imageUrl] if provided.
  ///
  /// parameters:
  ///            [String] grcModuleNameEnglish: English module name
  ///            [String] grcModuleNameArabic: Arabic module name
  ///            [String] descriptionEnglish: English description
  ///            [String] descriptionArabic: Arabic description
  ///            [String] owningDepartment: owning department
  ///            [DateTime] activationDate: activation date
  ///            [List<String>] owners: list of owner employee ids
  ///            [String] status: initial status
  ///            [String] editorId: id of the user performing the action
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] imageUrl: an already-hosted image URL, if any
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the created entity, or a Failure
  Future<Either<Failure, GRCModuleEntity>> execute({
    required String grcModuleNameEnglish,
    required String grcModuleNameArabic,
    required String descriptionEnglish,
    required String descriptionArabic,
    required String owningDepartment,
    required DateTime activationDate,
    required List<String> owners,
    required String status,
    required String editorId,
    File? imageFile,
    String? imageUrl,
  }) {
    return _repository.createModule(
      grcModuleNameEnglish: grcModuleNameEnglish,
      grcModuleNameArabic: grcModuleNameArabic,
      descriptionEnglish: descriptionEnglish,
      descriptionArabic: descriptionArabic,
      owningDepartment: owningDepartment,
      activationDate: activationDate,
      owners: owners,
      status: status,
      editorId: editorId,
      imageFile: imageFile,
      imageUrl: imageUrl,
    );
  }
}
