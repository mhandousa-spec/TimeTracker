/// Module: GRC Request Management
/// Description: Use case for approving a pending GRC request. Approval only
///              flips status — the actual champion transfer is deferred
///              until Start Date via the recompute-on-read resolver.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class ApproveGrcRequestParams {
  final String moduleId;
  final String requestId;
  final String decidedBy;

  const ApproveGrcRequestParams({
    required this.moduleId,
    required this.requestId,
    required this.decidedBy,
  });
}

class ApproveGrcRequestUseCase {
  const ApproveGrcRequestUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, GrcRequestEntity>> call(ApproveGrcRequestParams params) {
    return _repository.approveRequest(
      moduleId: params.moduleId,
      requestId: params.requestId,
      decidedBy: params.decidedBy,
    );
  }
}
