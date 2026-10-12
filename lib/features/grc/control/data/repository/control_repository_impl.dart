/// Module: Policy Management
/// Description: Data-layer implementation of [ControlRepository]. Combines
///              [ControlFirebaseDataSource] (Firestore) with
///              [PolicyStorageDataSource] (Firebase Storage, for Control
///              document uploads), and maps between Models (persistence)
///              and Entities (domain/UI).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, uuid, ControlRepository, ControlFirebaseDataSource,
///               PolicyStorageDataSource, ControlModel
/// Revision History: 2026-07-14 - Initial creation, extracted from the
///                                ad-hoc Control handling that had been
///                                sitting inside PolicyRepositoryImpl
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/data/data_source/control_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/policy/data/data_source/policy_storage_data_source.dart';
import 'package:knowticed_plus/features/grc/control/data/models/control_model.dart';

import 'package:knowticed_plus/features/grc/control/domain/repository/control_repository.dart';
import 'package:uuid/uuid.dart';

/// class name: [ControlRepositoryImpl]
///
/// purpose: implement [ControlRepository] by orchestrating calls to
///          [ControlFirebaseDataSource] (the Controls subcollection) and
///          [PolicyStorageDataSource] (Control document uploads),
///          converting Models to Entities and wrapping every result in
///          [Either<Failure, T>].
class ControlRepositoryImpl implements ControlRepository {
  ControlRepositoryImpl({
    required ControlFirebaseDataSource firebaseDataSource,
    required PolicyStorageDataSource storageDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _storageDataSource = storageDataSource;

  final ControlFirebaseDataSource _firebaseDataSource;
  final PolicyStorageDataSource _storageDataSource;

  @override
  Future<Either<Failure, ControlEntity>> createControl({
    required String moduleId,
    required String policyId,
    required String editorId,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsNumberEn,
    required String controlsNumberAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    required double controlsWeight,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    List<double>? departmentsWeights,
    required bool equalWeights,
    required int score,
    required ControlStatus status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    try {
      final controlId = const Uuid().v4();

      final resolvedDocumentEn = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: controlId,
          documentFile: controlsDocumentFileEn!,
          language: DocumentLanguage.en,
        ),
        file: controlsDocumentFileEn,
        fallbackUrl: controlsDocumentUrlEn,
      );

      final resolvedDocumentAr = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: controlId,
          documentFile: controlsDocumentFileAr!,
          language: DocumentLanguage.ar,
        ),
        file: controlsDocumentFileAr,
        fallbackUrl: controlsDocumentUrlAr,
      );

      final model = ControlModel.create(
        id: controlId,
        policyId: policyId,
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsDocumentEn: resolvedDocumentEn,
        controlsDocumentAr: resolvedDocumentAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        departmentWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        editorId: editorId,
      );

      final created = await _firebaseDataSource.create(
        model,
        moduleId: moduleId,
        policyId: policyId,
      );
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ControlEntity>> getControl(
    String id, {
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final model = await _firebaseDataSource.get(
        id,
        moduleId: moduleId,
        policyId: policyId,
      );
      if (model == null) {
        return Left(ValidationError('Control not found (id: $id)'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ControlEntity>>> getAllControls({
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        policyId: policyId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// function name: [getControlWeightHistory]
  ///
  /// purpose: fetch every Control's full revision history for
  ///          [moduleId]/[policyId] and flat-map
  ///          [ControlModel.toWeightHistory] across all of them, sorted by
  ///          date descending (most recent change first).
  ///
  /// parameters: see [ControlRepository.getControlWeightHistory]
  ///
  /// return type: [Future<Either<Failure, List<ControlWeightHistoryEntry>>>] - see [ControlRepository.getControlWeightHistory]
  @override
  Future<Either<Failure, List<ControlWeightHistoryEntry>>> getControlWeightHistory({
    required String moduleId,
    required String policyId,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        policyId: policyId,
      );
      final entries = models.expand((m) => m.toWeightHistory()).toList()
        ..sort((a, b) => b.dateOfAction.compareTo(a.dateOfAction));
      return Right(entries);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ControlEntity>> updateControl({
    required String id,
    required String moduleId,
    required String policyId,
    required String editorId,
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? departments,
    List<double>? departmentsWeights,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  }) async {
    try {
      final currentModel = await _firebaseDataSource.get(
        id,
        moduleId: moduleId,
        policyId: policyId,
      );
      if (currentModel == null) {
        return Left(ValidationError('Control not found (id: $id)'));
      }

      final resolvedDocumentEn = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: id,
          documentFile: controlsDocumentFileEn!,
          language: DocumentLanguage.en,
        ),
        file: controlsDocumentFileEn,
        fallbackUrl: controlsDocumentUrlEn,
      );

      final resolvedDocumentAr = await _resolveFile(
        uploadCallback: () => _storageDataSource.uploadControlDocument(
          policyId: policyId,
          controlId: id,
          documentFile: controlsDocumentFileAr!,
          language: DocumentLanguage.ar,
        ),
        file: controlsDocumentFileAr,
        fallbackUrl: controlsDocumentUrlAr,
      );

      final updatedModel = currentModel.copyWithUpdate(
        controlsNameEn: controlsNameEn,
        controlsNameAr: controlsNameAr,
        controlsNumberEn: controlsNumberEn,
        controlsNumberAr: controlsNumberAr,
        controlsDescriptionEn: controlsDescriptionEn,
        controlsDescriptionAr: controlsDescriptionAr,
        controlsDocumentEn: resolvedDocumentEn,
        controlsDocumentAr: resolvedDocumentAr,
        controlsWeight: controlsWeight,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        departments: departments,
        departmentWeights: departmentsWeights,
        equalWeights: equalWeights,
        score: score,
        status: status,
        editorId: editorId,
      );

      final saved = await _firebaseDataSource.update(
        updatedModel,
        moduleId: moduleId,
        policyId: policyId,
      );
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteControl(
    String id, {
    required String moduleId,
    required String policyId,
  }) async {
    try {
      await _firebaseDataSource.delete(
        id,
        moduleId: moduleId,
        policyId: policyId,
      );
      return const Right(unit);
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
