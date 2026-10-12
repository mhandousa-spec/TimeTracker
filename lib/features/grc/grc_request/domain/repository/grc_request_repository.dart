/// Module: GRC Request Management
/// Description: Domain-layer repository contract for GRC approval
///              requests. Knows only about Entities and Failures.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestType, AssigningControlEntity
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';

abstract class GrcRequestRepository {
  Future<Either<Failure, GrcRequestEntity>> createReassignChampionRequest({
    required String moduleId,
    required String requestedBy,
    required String note,
    required String currentChampionEmail,
    required String newChampionEmail,
    required List<AssigningControlEntity> controls,
    required DateTime startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, GrcRequestEntity>> createReassignOwnerRequest({
    required String moduleId,
    required String requestedBy,
    required String note,
    required String currentOwnerEmail,
    required String newOwnerEmail,
    required List<AssigningControlEntity> controls,
    required DateTime startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<GrcRequestEntity>>> getRequestsForModule(
    String moduleId,
  );

  Future<Either<Failure, GrcRequestEntity>> approveRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
  });

  Future<Either<Failure, GrcRequestEntity>> rejectRequest({
    required String moduleId,
    required String requestId,
    required String decidedBy,
    required String reason,
  });

  Future<Either<Failure, GrcRequestEntity>> cancelRequest({
    required String moduleId,
    required String requestId,
    required String canceledBy,
  });

  Future<Either<Failure, GrcRequestEntity>> markApplied({
    required String moduleId,
    required String requestId,
  });
}
