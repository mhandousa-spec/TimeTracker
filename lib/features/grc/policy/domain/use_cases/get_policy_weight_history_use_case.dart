/// Module: Policy Management
/// Description: Use case responsible for fetching every recorded weight
///              change across a Module's Policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, PolicyRepository, PolicyWeightHistoryEntry, Failure
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/policy/domain/repository/policy_repository.dart';

/// class name: [GetPolicyWeightHistoryUseCase]
///
/// purpose: encapsulate the business logic for fetching a Module's Policy
///          weight-change history. Delegates to
///          [PolicyRepository.getPolicyWeightHistory].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class GetPolicyWeightHistoryUseCase {
  final PolicyRepository _repository;

  GetPolicyWeightHistoryUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch the weight-change history for every Policy under
  ///          [moduleId].
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<Either<Failure, List<PolicyWeightHistoryEntry>>>] - every weight-change entry, or a Failure
  Future<Either<Failure, List<PolicyWeightHistoryEntry>>> execute(
    String moduleId,
  ) {
    return _repository.getPolicyWeightHistory(moduleId: moduleId);
  }
}
