/// Module: Policy Management
/// Description: Use case responsible for creating a new Policy record.
///              Controls are created separately via CreateControlUseCase
///              once the Policy id is known — see PolicyCubit for the
///              orchestration.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, PolicyRepository
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Removed the `controls` field (Controls are
///                                no longer created through PolicyRepository)
///                                and split policyDocumentFile/Url into
///                                En/Ar pairs to match the current
///                                PolicyRepository.createPolicy signature
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/repository/policy_repository.dart';

/// class name: [CreatePolicyParams]
///
/// purpose: groups every field needed to create a new Policy record into a
///          single strongly-typed object passed to [CreatePolicyUseCase].
class CreatePolicyParams {
  final String policyNameEn;
  final String policyNameAr;
  final String policyNumberEn;
  final String policyNumberAr;
  final String policyDescriptionEn;
  final String policyDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final double policyWeight;
  final String editorId;
  final String moduleId;
  final PolicyStatus status;
  final File? imageFile;
  final String? imageUrl;
  final File? policyDocumentFileEn;
  final String? policyDocumentUrlEn;
  final File? policyDocumentFileAr;
  final String? policyDocumentUrlAr;

  const CreatePolicyParams({
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.policyWeight,
    required this.editorId,
    required this.moduleId,
    required this.status,
    this.imageFile,
    this.imageUrl,
    this.policyDocumentFileEn,
    this.policyDocumentUrlEn,
    this.policyDocumentFileAr,
    this.policyDocumentUrlAr,
  });
}

/// class name: [CreatePolicyUseCase]
///
/// purpose: encapsulate the "create a Policy" business action.
class CreatePolicyUseCase {
  const CreatePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  Future<Either<Failure, PolicyEntity>> call(CreatePolicyParams params) {
    return _repository.createPolicy(
      status: params.status,
      policyNameEn: params.policyNameEn,
      policyNameAr: params.policyNameAr,
      policyNumberEn: params.policyNumberEn,
      policyNumberAr: params.policyNumberAr,
      policyDescriptionEn: params.policyDescriptionEn,
      policyDescriptionAr: params.policyDescriptionAr,
      startDate: params.startDate,
      endDate: params.endDate,
      policyWeight: params.policyWeight,
      editorId: params.editorId,
      moduleId: params.moduleId,
      imageFile: params.imageFile,
      imageUrl: params.imageUrl,
      policyDocumentFileEn: params.policyDocumentFileEn,
      policyDocumentUrlEn: params.policyDocumentUrlEn,
      policyDocumentFileAr: params.policyDocumentFileAr,
      policyDocumentUrlAr: params.policyDocumentUrlAr,
    );
  }
}
