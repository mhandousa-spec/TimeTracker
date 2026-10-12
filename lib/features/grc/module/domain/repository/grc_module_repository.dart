/// Module: GRC Module Management
/// Description: Defines the Domain-layer repository contract for GRC Module
///              operations. The domain layer only knows about Entities and
///              Failures - it has no knowledge of Firebase, Models, or any
///              other data-layer detail.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: dartz, Failure, GRCModuleEntity
/// Revision History: 2026-06-30 - Initial creation
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';

import '../entities/grc_module_entity.dart';
import '../entities/grc_module_owner_history_entry.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_repository.dart
/// Purpose: Contains the GRCModuleRepository abstract class (interface) that
///          the Data layer must implement, and that the Domain/Presentation
///          layers (use cases, controllers, blocs, etc.) depend on.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleRepository]
///
/// purpose: define the contract for all GRC Module operations exposed to
///          the rest of the app (create/get/update/delete/restore), using
///          Entities (not Models) and returning [Either<Failure, T>] so
///          callers can handle success and failure explicitly.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
abstract class GRCModuleRepository {
  /// function name: [createModule]
  ///
  /// purpose: create a new GRC Module record. If [imageFile] is provided, it
  ///          is uploaded to Firebase Storage first and its download URL is
  ///          used as the module's image; otherwise [imageUrl] (if any) is
  ///          used directly.
  ///
  /// parameters:
  ///            [String] grcModuleNameEnglish: English module name
  ///            [String] grcModuleNameArabic: Arabic module name
  ///            [String] descriptionEnglish: English description
  ///            [String] descriptionArabic: Arabic description
  ///            [String] owningDepartment: owning department
  ///            [DateTime] activationDate: activation date
  ///            [List<String>] owners: list of owners
  ///            [String] status: initial status
  ///            [String] editorId: id of the user creating the record
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] imageUrl: an already-hosted image URL to use directly, if any
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the created entity, or a Failure
  Future<Either<Failure, GRCModuleEntity>> createModule({
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
  });

  /// function name: [getModule]
  ///
  /// purpose: fetch a single GRC Module by its id, mapped to its latest
  ///          (current) Entity representation.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to fetch
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the matching entity, or a Failure (e.g. [NotFoundFailure])
  Future<Either<Failure, GRCModuleEntity>> getModule(String id);

  /// function name: [getAllModules]
  ///
  /// purpose: fetch all GRC Module records, mapped to their latest (current)
  ///          Entity representation.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when false (default), soft-deleted modules are excluded
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleEntity>>>] - the list of entities, or a Failure
  Future<Either<Failure, List<GRCModuleEntity>>> getAllModules({
    bool includeDeleted = false,
  });

  /// function name: [updateModule]
  ///
  /// purpose: update an existing GRC Module record. Only the fields passed
  ///          (non-null) are changed; everything else keeps its previous
  ///          value. If [imageFile] is provided, it is uploaded to Firebase
  ///          Storage first and its download URL replaces the current image.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to update
  ///            [String] grcModuleNameEnglish: new English module name, if changed
  ///            [String] grcModuleNameArabic: new Arabic module name, if changed
  ///            [String] descriptionEnglish: new English description, if changed
  ///            [String] descriptionArabic: new Arabic description, if changed
  ///            [String] owningDepartment: new owning department, if changed
  ///            [DateTime] activationDate: new activation date, if changed
  ///            [List<String>] owners: new owners list, if changed
  ///            [String] status: new status, if changed
  ///            [String] editorId: id of the user performing the update
  ///            [File] imageFile: new local image file to upload, if changed
  ///            [String] imageUrl: a new already-hosted image URL to use directly, if changed
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the updated entity, or a Failure
  Future<Either<Failure, GRCModuleEntity>> updateModule({
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
  });

  /// function name: [deleteModule]
  ///
  /// purpose: soft-delete a GRC Module record (the record stays in the
  ///          database, with a new revision marking it as deleted) so it can
  ///          be restored later via [restoreModule].
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to delete
  ///            [String] editorId: id of the user performing the delete
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the entity after the delete revision, or a Failure
  Future<Either<Failure, GRCModuleEntity>> deleteModule({
    required String id,
    required String editorId,
  });

  /// function name: [restoreModule]
  ///
  /// purpose: restore a previously soft-deleted GRC Module record.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to restore
  ///            [String] editorId: id of the user performing the restore
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the entity after the restore revision, or a Failure
  Future<Either<Failure, GRCModuleEntity>> restoreModule({
    required String id,
    required String editorId,
  });

  /// function name: [getModuleOwnerHistory]
  ///
  /// purpose: fetch the full owner-assignment history of a GRC Module —
  ///          every owner who has since been removed, who assigned them,
  ///          and the date range they held the role.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>] - completed owner stints, or a Failure
  Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>
      getModuleOwnerHistory(String id);
}
