/// Module: Policy Management
/// Description: Use case responsible for fetching every recorded weight
///              change across one Policy's Controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: dartz, ControlRepository, ControlWeightHistoryEntry, Failure
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:knowticed_plus/features/grc/control/domain/repository/control_repository.dart';

/// class name: [GetControlWeightHistoryUseCase]
///
/// purpose: encapsulate the business logic for fetching a Policy's Control
///          weight-change history. Delegates to
///          [ControlRepository.getControlWeightHistory].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class GetControlWeightHistoryUseCase {
  final ControlRepository _repository;

  GetControlWeightHistoryUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch the weight-change history for every Control under
  ///          [moduleId]/[policyId].
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<Either<Failure, List<ControlWeightHistoryEntry>>>] - every weight-change entry, or a Failure
  Future<Either<Failure, List<ControlWeightHistoryEntry>>> execute(
    String moduleId,
    String policyId,
  ) {
    return _repository.getControlWeightHistory(
      moduleId: moduleId,
      policyId: policyId,
    );
  }
}
