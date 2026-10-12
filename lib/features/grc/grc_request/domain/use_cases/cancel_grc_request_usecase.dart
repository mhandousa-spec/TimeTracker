/// Module: GRC Request Management
/// Description: Use case for canceling a pending GRC request before its
///              start date arrives (requester withdrawing their own request).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class CancelGrcRequestParams {
  final String moduleId;
  final String requestId;
  final String canceledBy;

  const CancelGrcRequestParams({
    required this.moduleId,
    required this.requestId,
    required this.canceledBy,
  });
}

class CancelGrcRequestUseCase {
  const CancelGrcRequestUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, GrcRequestEntity>> call(CancelGrcRequestParams params) {
    return _repository.cancelRequest(
      moduleId: params.moduleId,
      requestId: params.requestId,
      canceledBy: params.canceledBy,
    );
  }
}
