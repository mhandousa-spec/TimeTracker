/// Module: GRC Request Management
/// Description: Use case for rejecting a pending GRC request with a reason.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class RejectGrcRequestParams {
  final String moduleId;
  final String requestId;
  final String decidedBy;
  final String reason;

  const RejectGrcRequestParams({
    required this.moduleId,
    required this.requestId,
    required this.decidedBy,
    required this.reason,
  });
}

class RejectGrcRequestUseCase {
  const RejectGrcRequestUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, GrcRequestEntity>> call(RejectGrcRequestParams params) {
    return _repository.rejectRequest(
      moduleId: params.moduleId,
      requestId: params.requestId,
      decidedBy: params.decidedBy,
      reason: params.reason,
    );
  }
}
