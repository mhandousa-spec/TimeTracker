/// Module: GRC Request Management
/// Description: Data-layer implementation of [GrcRequestRepository]. Maps
///              between Models (persistence) and Entities (domain), and
///              wraps every result in Either<Failure, T>.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, GrcRequestRepository, GrcRequestFirebaseDataSource, GrcRequestModel

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/data/models/assigning_control_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/grc_request/data/data_source/grc_request_firebase_data_source.dart';
import 'package:knowticed_plus/features/grc/grc_request/data/models/grc_request_model.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/repository/grc_request_repository.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';


class GrcRequestRepositoryImpl implements GrcRequestRepository {
  GrcRequestRepositoryImpl({required GrcRequestFirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  final GrcRequestFirebaseDataSource _firebaseDataSource;

  List<AssigningControlModel> _toModels(List<AssigningControlEntity> entities) {
    return entities
        .map((a) => AssigningControlModel(
              policyId: a.policyId,
              controlId: a.controlId,
              expiresOn: a.expiresOn,
            ))
        .toList();
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> createReassignChampionRequest({
    required String moduleId,
    required String requestedBy,
    required String note,
    required String currentChampionEmail,
    required String newChampionEmail,
    required List<AssigningControlEntity> controls,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final model = GrcRequestModel(
        id: '', // overwritten by the data source on create
        moduleId: moduleId,
        type: GrcRequestType.reassignChampion.value,
        status: ApprovalStatus.pending.name,
        requestedBy: requestedBy,
        requestDate: DateTime.now(),
        note: note,
        currentChampionEmail: currentChampionEmail,
        newChampionEmail: newChampionEmail,
        controls: _toModels(controls),
        startDate: startDate,
        endDate: endDate,
      );
      final created = await _firebaseDataSource.create(model, moduleId: moduleId);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> createReassignOwnerRequest({
    required String moduleId,
    required String requestedBy,
    required String note,
    required String currentOwnerEmail,
    required String newOwnerEmail,
    required List<AssigningControlEntity> controls,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final model = GrcRequestModel(
        id: '', // overwritten by the data source on create
        moduleId: moduleId,
        type: GrcRequestType.reassignOwner.value,
        status: ApprovalStatus.pending.name,
        requestedBy: requestedBy,
        requestDate: DateTime.now(),
        note: note,
        currentOwnerEmail: currentOwnerEmail,
        newOwnerEmail: newOwnerEmail,
        controls: _toModels(controls),
        startDate: startDate,
        endDate: endDate,
      );
      final created = await _firebaseDataSource.create(model, moduleId: moduleId);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GrcRequestEntity>>> getRequestsForModule(
    String moduleId,
  ) async {
    try {
      final models = await _firebaseDataSource.getAll(moduleId: moduleId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, GrcRequestModel>> _getById({
    required String moduleId,
    required String requestId,
  }) async {
    final all = await _firebaseDataSource.getAll(moduleId: moduleId);
    final match = all.where((m) => m.id == requestId);
    if (match.isEmpty) {
      return Left(ValidationError('GRC Request not found (id: $requestId)'));
    }
    return Right(match.first);
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> approveRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = current.copyWith(
            status: ApprovalStatus.approved.name,
            decidedBy: decidedBy,
            decisionDate: DateTime.now(),
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> rejectRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
    required String reason,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = current.copyWith(
            status: ApprovalStatus.rejected.name,
            rejectionReason: reason,
            decidedBy: decidedBy,
            decisionDate: DateTime.now(),
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> cancelRequest({
    required String moduleId,
    required String requestId,
    required String canceledBy,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = current.copyWith(
            status: ApprovalStatus.canceled.name,
            decidedBy: canceledBy,
            decisionDate: DateTime.now(),
          );
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrcRequestEntity>> markApplied({
    required String moduleId,
    required String requestId,
  }) async {
    try {
      final currentResult = await _getById(moduleId: moduleId, requestId: requestId);
      return await currentResult.fold(
        (failure) async => Left(failure),
        (current) async {
          final updated = current.copyWith(appliedAt: DateTime.now());
          final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
          return Right(saved.toEntity());
        },
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
