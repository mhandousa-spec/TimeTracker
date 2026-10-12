/// Module: GRC Module Management
/// Description: Data-layer implementation of [GRCModuleRepository]. Combines
///              [GRCModuleFirebaseDataSource] (Firestore) and
///              [GRCModuleStorageDataSource] (Firebase Storage), and maps
///              between Models (used internally for persistence) and
///              Entities (exposed to the Domain/Presentation layers).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: dartz, GRCModuleRepository, GRCModuleFirebaseDataSource,
///               GRCModuleStorageDataSource, GRCModuleModel
/// Revision History: 2026-06-30 - Initial creation
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/module/data/data_source/grc_module_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/module/data/data_source/grc_module_storage_data_source.dart';
import 'package:knowticed_plus/features/grc/module/domain/repository/grc_module_repository.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/grc_module_entity.dart';
import '../../domain/entities/grc_module_owner_history_entry.dart';

import '../models/grc_module_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_repository_impl.dart
/// Purpose: Contains the GRCModuleRepositoryImpl class, the concrete
///          Data-layer implementation of [GRCModuleRepository].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleRepositoryImpl]
///
/// purpose: implement [GRCModuleRepository] by orchestrating calls to the
///          Firestore data source (records) and the Storage data source
///          (images), converting Models to Entities before returning data
///          to the Domain/Presentation layers, and wrapping every result in
///          [Either<Failure, T>].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleRepositoryImpl implements GRCModuleRepository {
  GRCModuleRepositoryImpl({
    required GRCModuleFirebaseDataSource firebaseDataSource,
    required GRCModuleStorageDataSource storageDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _storageDataSource = storageDataSource;

  final GRCModuleFirebaseDataSource _firebaseDataSource;
  final GRCModuleStorageDataSource _storageDataSource;

  /// function name: [createModule]
  ///
  /// purpose: generate a new id, optionally upload [imageFile] to Storage,
  ///          build the first revision of a [GRCModuleModel] via
  ///          [GRCModuleModel.create], persist it through the Firestore data
  ///          source, then return the mapped [GRCModuleEntity].
  ///
  /// parameters: see [GRCModuleRepository.createModule]
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the created entity, or a [ServerFailure]
  @override
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
  }) async {
    try {
      final id = const Uuid().v4();

      final resolvedImageUrl = await _resolveImageUrl(
        moduleId: id,
        imageFile: imageFile,
        fallbackUrl: imageUrl,
      );

      final model = GRCModuleModel.create(
        moduleId: id,
        moduleImage: resolvedImageUrl,
        moduleNameEn: grcModuleNameEnglish,
        moduleNameAr: grcModuleNameArabic,
        moduleDescriptionEn: descriptionEnglish,
        moduleDescriptionAr: descriptionArabic,
        moduleOwningDepartment: owningDepartment,
        moduleActivationDate: activationDate,
        owners: owners,
        status: status,
        modifierEmail: editorId,
      );

      final createdModel = await _firebaseDataSource.create(model);
      return Right(createdModel.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [getModule]
  ///
  /// purpose: fetch a module by id from the Firestore data source and map
  ///          it to its latest [GRCModuleEntity] representation.
  ///
  /// parameters: see [GRCModuleRepository.getModule]
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the matching entity, a [NotFoundFailure], or a [ServerFailure]
  @override
  Future<Either<Failure, GRCModuleEntity>> getModule(String id) async {
    try {
      final model = await _firebaseDataSource.get(id);
      if (model == null) {
        return Left(ValidationError('GRC Module not found (id: $id)'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [getAllModules]
  ///
  /// purpose: fetch all modules from the Firestore data source and map each
  ///          one to its latest [GRCModuleEntity] representation.
  ///
  /// parameters: see [GRCModuleRepository.getAllModules]
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleEntity>>>] - the list of entities, or a [ServerFailure]
  @override
  Future<Either<Failure, List<GRCModuleEntity>>> getAllModules({
    bool includeDeleted = false,
  }) async {
    try {
      final models =
          await _firebaseDataSource.getAll(includeDeleted: includeDeleted);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [updateModule]
  ///
  /// purpose: fetch the current model, optionally upload [imageFile] to
  ///          Storage, append a new revision via
  ///          [GRCModuleModel.copyWithUpdate] with the changed fields,
  ///          persist it, then return the mapped [GRCModuleEntity].
  ///
  /// parameters: see [GRCModuleRepository.updateModule]
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the updated entity, a [NotFoundFailure], or a [ServerFailure]
  @override
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
  }) async {
    try {
      final currentModel = await _firebaseDataSource.get(id);
      if (currentModel == null) {
        return Left(ValidationError('GRC Module not found (id: $id)'));
      }

      final resolvedImageUrl = await _resolveImageUrl(
        moduleId: id,
        imageFile: imageFile,
        fallbackUrl: imageUrl,
      );

      final updatedModel = currentModel.copyWithUpdate(
        moduleImage: resolvedImageUrl,
        moduleNameEn: grcModuleNameEnglish,
        moduleNameAr: grcModuleNameArabic,
        moduleDescriptionEn: descriptionEnglish,
        moduleDescriptionAr: descriptionArabic,
        moduleOwningDepartment: owningDepartment,
        moduleActivationDate: activationDate,
        owners: owners,
        status: status,
        score: score,
        modifierEmail: editorId,
      );

      final savedModel = await _firebaseDataSource.update(updatedModel);
      return Right(savedModel.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [deleteModule]
  ///
  /// purpose: soft-delete a module through the Firestore data source and
  ///          return the mapped [GRCModuleEntity].
  ///
  /// parameters: see [GRCModuleRepository.deleteModule]
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the entity after the delete revision, or a [ServerFailure]
  @override
  Future<Either<Failure, GRCModuleEntity>> deleteModule({
    required String id,
    required String editorId,
  }) async {
    try {
      final deletedModel =
          await _firebaseDataSource.delete(id, editorId: editorId);
      return Right(deletedModel.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [restoreModule]
  ///
  /// purpose: restore a previously soft-deleted module through the
  ///          Firestore data source and return the mapped [GRCModuleEntity].
  ///
  /// parameters: see [GRCModuleRepository.restoreModule]
  ///
  /// return type: [Future<Either<Failure, GRCModuleEntity>>] - the entity after the restore revision, or a [ServerFailure]
  @override
  Future<Either<Failure, GRCModuleEntity>> restoreModule({
    required String id,
    required String editorId,
  }) async {
    try {
      final restoredModel =
          await _firebaseDataSource.restore(id, editorId: editorId);
      return Right(restoredModel.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [getModuleOwnerHistory]
  ///
  /// purpose: fetch a module by id from the Firestore data source and map
  ///          its full revision history to completed owner-assignment
  ///          stints via [GRCModuleModel.toOwnerHistory].
  ///
  /// parameters: see [GRCModuleRepository.getModuleOwnerHistory]
  ///
  /// return type: [Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>] - completed owner stints, a [ValidationError], or a [FirebaseFailure]
  @override
  Future<Either<Failure, List<GRCModuleOwnerHistoryEntry>>>
      getModuleOwnerHistory(String id) async {
    try {
      final model = await _firebaseDataSource.get(id);
      if (model == null) {
        return Left(ValidationError('GRC Module not found (id: $id)'));
      }
      return Right(model.toOwnerHistory());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [_resolveImageUrl]
  ///
  /// purpose: upload [imageFile] to Firebase Storage when provided and
  ///          return its download URL; otherwise fall back to [fallbackUrl]
  ///          (an already-hosted URL) or null when neither is provided,
  ///          meaning the image field should stay unchanged.
  ///
  /// parameters:
  ///            [String] moduleId: id of the module the image belongs to
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] fallbackUrl: an already-hosted image URL to use directly, if any
  ///
  /// return type: [Future<String?>] - the resolved image URL, or null if there is nothing new to set
  Future<String?> _resolveImageUrl({
    required String moduleId,
    File? imageFile,
    String? fallbackUrl,
  }) async {
    if (imageFile != null) {
      return _storageDataSource.uploadImage(
        moduleId: moduleId,
        imageFile: imageFile,
      );
    }
    return fallbackUrl;
  }
}
