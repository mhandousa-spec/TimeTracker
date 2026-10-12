/// Module: Policy Management
/// Description: Data-layer implementation of [PolicyRepository]. Combines
///              [PolicyFirebaseDataSource] (Firestore) with
///              [PolicyStorageDataSource] (Firebase Storage), and maps
///              between Models (persistence) and Entities (domain/UI).
///              Control operations live in [ControlRepositoryImpl].
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, uuid, PolicyRepository, PolicyFirebaseDataSource,
///               PolicyStorageDataSource, PolicyModel
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Migrated to the new schema: soft-delete /
///                                restore now toggle PolicyStatus.removed
///                                instead of an Is_Deleted flag
///                   2026-07-14 - Extracted all Control CRUD into the
///                                dedicated ControlRepositoryImpl so
///                                PolicyRepositoryImpl only depends on
///                                Policy data sources again
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/policy/data/data_source/policy_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/policy/data/data_source/policy_storage_data_source.dart';
import 'package:knowticed_plus/features/grc/policy/data/models/policy_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/policy/domain/repository/policy_repository.dart';
import 'package:uuid/uuid.dart';

/// class name: [PolicyRepositoryImpl]
///
/// purpose: implement [PolicyRepository] by orchestrating calls to
///          [PolicyFirebaseDataSource] and [PolicyStorageDataSource],
///          converting Models to Entities and wrapping every result in
///          [Either<Failure, T>]. Controls are handled by
///          [ControlRepositoryImpl], not here.
class PolicyRepositoryImpl implements PolicyRepository {
  PolicyRepositoryImpl({
    required PolicyFirebaseDataSource firebaseDataSource,
    required PolicyStorageDataSource storageDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _storageDataSource = storageDataSource;

  final PolicyFirebaseDataSource _firebaseDataSource;
  final PolicyStorageDataSource _storageDataSource;

  @override
  Future<Either<Failure, PolicyEntity>> createPolicy({
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String editorId,
    required String moduleId,
    required PolicyStatus status,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    try {
      final policyId = const Uuid().v4();

      final resolvedImage = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyImage(
          policyId: policyId,
          imageFile: imageFile!,
        ),
        file: imageFile,
        fallbackUrl: imageUrl,
      );

      final resolvedDocumentEn = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: policyId,
          documentFile: policyDocumentFileEn!,
          language: DocumentLanguage.en,
        ),
        file: policyDocumentFileEn,
        fallbackUrl: policyDocumentUrlEn,
      );

      final resolvedDocumentAr = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: policyId,
          documentFile: policyDocumentFileAr!,
          language: DocumentLanguage.ar,
        ),
        file: policyDocumentFileAr,
        fallbackUrl: policyDocumentUrlAr,
      );

      final model = PolicyModel.create(
        id: policyId,
        moduleId: moduleId,
        policyImage: resolvedImage,
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        policyDocumentEn: resolvedDocumentEn,
        policyDocumentAr: resolvedDocumentAr,
        status: status,
        editorId: editorId,
      );

      final created = await _firebaseDataSource.create(model, moduleId: moduleId);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PolicyEntity>> getPolicy(
    String id, {
    required String moduleId,
  }) async {
    try {
      final model = await _firebaseDataSource.get(id, moduleId: moduleId);
      if (model == null) {
        return Left(ValidationError('Policy not found (id: $id)'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        includeRemoved: includeRemoved,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [getPolicyWeightHistory]
  ///
  /// purpose: fetch every Policy's full revision history for [moduleId] and
  ///          flat-map [PolicyModel.toWeightHistory] across all of them,
  ///          sorted by date descending (most recent change first). Uses
  ///          `includeRemoved: true` so a weight change is still visible in
  ///          history even if the policy was later removed.
  ///
  /// parameters: see [PolicyRepository.getPolicyWeightHistory]
  ///
  /// return type: [Future<Either<Failure, List<PolicyWeightHistoryEntry>>>] - see [PolicyRepository.getPolicyWeightHistory]
  @override
  Future<Either<Failure, List<PolicyWeightHistoryEntry>>> getPolicyWeightHistory({
    required String moduleId,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        includeRemoved: true,
      );
      final entries = models.expand((m) => m.toWeightHistory()).toList()
        ..sort((a, b) => b.dateOfAction.compareTo(a.dateOfAction));
      return Right(entries);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PolicyEntity>> updatePolicy({
    required String id,
    required String editorId,
    required String moduleId,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    double? score,
    PolicyStatus? status,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    try {
      final currentModel = await _firebaseDataSource.get(id, moduleId: moduleId);
      if (currentModel == null) {
        return Left(ValidationError('Policy not found (id: $id)'));
      }

      final resolvedImage = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyImage(
          policyId: id,
          imageFile: imageFile!,
        ),
        file: imageFile,
        fallbackUrl: imageUrl,
      );

      final resolvedDocumentEn = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: id,
          documentFile: policyDocumentFileEn!,
          language: DocumentLanguage.en,
        ),
        file: policyDocumentFileEn,
        fallbackUrl: policyDocumentUrlEn,
      );

      final resolvedDocumentAr = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadPolicyDocument(
          policyId: id,
          documentFile: policyDocumentFileAr!,
          language: DocumentLanguage.ar,
        ),
        file: policyDocumentFileAr,
        fallbackUrl: policyDocumentUrlAr,
      );

      final updatedModel = currentModel.copyWithUpdate(
        policyImage: resolvedImage,
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        score: score,
        policyDocumentEn: resolvedDocumentEn,
        policyDocumentAr: resolvedDocumentAr,
        status: status,
        editorId: editorId,
      );

      final saved = await _firebaseDataSource.update(updatedModel, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PolicyEntity>> deletePolicy({
    required String id,
    required String editorId,
    required String moduleId,
  }) async {
    try {
      final deleted = await _firebaseDataSource.delete(
        id,
        moduleId: moduleId,
        editorId: editorId,
      );
      return Right(deleted.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PolicyEntity>> restorePolicy({
    required String id,
    required String editorId,
    required String moduleId,
  }) async {
    try {
      final restored = await _firebaseDataSource.restore(
        id,
        moduleId: moduleId,
        editorId: editorId,
      );
      return Right(restored.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<String?> _resolveFile({
    required Future<String> Function() uploadCallback,
    File? file,
    String? fallbackUrl,
  }) async {
    if (file != null) return uploadCallback();
    return fallbackUrl;
  }
}