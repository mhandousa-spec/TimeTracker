/// Module: Policy Management
/// Description: Use cases for reading (single/all), soft-deleting, and
///              restoring Policy records.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, PolicyRepository
/// Revision History: 2026-07-5 - Initial creation
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/repository/policy_repository.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: get_policy_usecases.dart
/// Purpose: Contains GetPolicyUseCase, GetAllPoliciesUseCase,
///          DeletePolicyUseCase, and RestorePolicyUseCase.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

// ================================================================
// GET (single)
// ================================================================

/// class name: [GetPolicyUseCase]
///
/// purpose: encapsulate the "fetch a single Policy" business action.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class GetPolicyUseCase {
  const GetPolicyUseCase(this._repository);

  final PolicyRepository _repository;

  /// function name: [call]
  ///
  /// purpose: forward the fetch request to [PolicyRepository.getPolicy].
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to fetch
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the matching entity, or a Failure
  Future<Either<Failure, PolicyEntity>> call(
    String id, {
    required String moduleId,
  }) {
    return _repository.getPolicy(id, moduleId: moduleId);
  }
}

// ================================================================
// GET ALL
// ================================================================

/// class name: [GetAllPoliciesUseCase]
///
/// purpose: encapsulate the "fetch all Policies" business action.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class GetAllPoliciesUseCase {
  const GetAllPoliciesUseCase(this._repository);

  final PolicyRepository _repository;

  /// function name: [call]
  ///
  /// purpose: forward the fetch-all request to [PolicyRepository.getAllPolicies].
  ///
  /// parameters:
  ///            [bool] includeRemoved: when false (default), removed policies are excluded
  ///
  /// return type: [Future<Either<Failure, List<PolicyEntity>>>] - the list of entities, or a Failure
  Future<Either<Failure, List<PolicyEntity>>> call({
    required String moduleId,
    bool includeRemoved = false,
  }) {
    return _repository.getAllPolicies(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
  }
}

// ================================================================
// DELETE  (soft)
// ================================================================

/// class name: [DeletePolicyParams]
///
/// purpose: groups the fields required to soft-delete a Policy record.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class DeletePolicyParams {
  final String id;
  final String editorId;
  final String moduleId;

  const DeletePolicyParams({
    required this.id,
    required this.editorId,
    required this.moduleId,
  });
}

/// class name: [DeletePolicyUseCase]
///
/// purpose: encapsulate the "soft-delete a Policy" business action.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class DeletePolicyUseCase {
  const DeletePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  /// function name: [call]
  ///
  /// purpose: forward the delete request to [PolicyRepository.deletePolicy].
  ///
  /// parameters:
  ///            [DeletePolicyParams] params: the id of the policy and the editor performing the delete
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the entity after the delete revision, or a Failure
  Future<Either<Failure, PolicyEntity>> call(DeletePolicyParams params) {
    return _repository.deletePolicy(
      id: params.id,
      editorId: params.editorId,
      moduleId: params.moduleId,
    );
  }
}

// ================================================================
// RESTORE
// ================================================================

/// class name: [RestorePolicyParams]
///
/// purpose: groups the fields required to restore a soft-deleted Policy.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class RestorePolicyParams {
  final String id;
  final String editorId;
  final String moduleId;

  const RestorePolicyParams({
    required this.id,
    required this.editorId,
    required this.moduleId,
  });
}

/// class name: [RestorePolicyUseCase]
///
/// purpose: encapsulate the "restore a soft-deleted Policy" business action.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class RestorePolicyUseCase {
  const RestorePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  /// function name: [call]
  ///
  /// purpose: forward the restore request to [PolicyRepository.restorePolicy].
  ///
  /// parameters:
  ///            [RestorePolicyParams] params: the id of the policy and the editor performing the restore
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the entity after the restore revision, or a Failure
  Future<Either<Failure, PolicyEntity>> call(RestorePolicyParams params) {
    return _repository.restorePolicy(
      id: params.id,
      editorId: params.editorId,
      moduleId: params.moduleId,
    );
  }
}
