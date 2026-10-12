/// Module: Control Owner Management
/// Description: Use case responsible for fetching one Control's Owner
///              assignment history.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: dartz, OwnerRepository, ControlOwnerHistoryEntry, Failure
/// Revision History: 2026-07-21 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/repository/owner_repository.dart';

/// class name: [GetControlOwnerHistoryUseCase]
///
/// purpose: encapsulate the business logic for fetching one Control's
///          Owner-assignment history. Delegates to
///          [OwnerRepository.getControlOwnerHistory] and returns the
///          result.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class GetControlOwnerHistoryUseCase {
  final OwnerRepository _repository;

  GetControlOwnerHistoryUseCase(this._repository);

  /// function name: [execute]
  ///
  /// purpose: fetch the Owner-assignment history for the Control matching
  ///          [policyId] + [controlId] inside Module [moduleId].
  ///
  /// parameters:
  ///            [String] moduleId: the GRC Module this Control belongs to
  ///            [String] policyId: the Policy this Control belongs to
  ///            [String] controlId: the Control to fetch history for
  ///
  /// return type: [Future<Either<Failure, List<ControlOwnerHistoryEntry>>>] - completed stints, or a Failure
  Future<Either<Failure, List<ControlOwnerHistoryEntry>>> execute({
    required String moduleId,
    required String policyId,
    required String controlId,
  }) {
    return _repository.getControlOwnerHistory(
      moduleId: moduleId,
      policyId: policyId,
      controlId: controlId,
    );
  }
}
