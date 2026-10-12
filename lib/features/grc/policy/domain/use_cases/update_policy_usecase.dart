/// Module: Policy Management
/// Description: Use case responsible for updating an existing Policy
///              record. Controls are updated separately via
///              UpdateControlUseCase.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, PolicyRepository
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Removed the `controls` field and split
///                                policyDocumentFile/Url into En/Ar pairs
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/repository/policy_repository.dart';

/// class name: [UpdatePolicyParams]
///
/// purpose: groups every field that can be changed on an existing Policy
///          record. Fields left null are not changed.
class UpdatePolicyParams {
  final String id;
  final String editorId;
  final String moduleId;
  final String? policyNameEn;
  final String? policyNameAr;
  final String? policyNumberEn;
  final String? policyNumberAr;
  final String? policyDescriptionEn;
  final String? policyDescriptionAr;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? policyWeight;
  final double? score;
  final PolicyStatus? status;
  final File? imageFile;
  final String? imageUrl;
  final File? policyDocumentFileEn;
  final String? policyDocumentUrlEn;
  final File? policyDocumentFileAr;
  final String? policyDocumentUrlAr;

  const UpdatePolicyParams({
    required this.id,
    required this.editorId,
    required this.moduleId,
    this.policyNameEn,
    this.policyNameAr,
    this.policyNumberEn,
    this.policyNumberAr,
    this.policyDescriptionEn,
    this.policyDescriptionAr,
    this.startDate,
    this.endDate,
    this.policyWeight,
    this.score,
    this.status,
    this.imageFile,
    this.imageUrl,
    this.policyDocumentFileEn,
    this.policyDocumentUrlEn,
    this.policyDocumentFileAr,
    this.policyDocumentUrlAr,
  });
}

/// class name: [UpdatePolicyUseCase]
///
/// purpose: encapsulate the "update a Policy" business action.
class UpdatePolicyUseCase {
  const UpdatePolicyUseCase(this._repository);

  final PolicyRepository _repository;

  Future<Either<Failure, PolicyEntity>> call(UpdatePolicyParams params) {
    return _repository.updatePolicy(
      id: params.id,
      editorId: params.editorId,
      moduleId: params.moduleId,
      policyNameEn: params.policyNameEn,
      policyNameAr: params.policyNameAr,
      policyNumberEn: params.policyNumberEn,
      policyNumberAr: params.policyNumberAr,
      policyDescriptionEn: params.policyDescriptionEn,
      policyDescriptionAr: params.policyDescriptionAr,
      startDate: params.startDate,
      endDate: params.endDate,
      policyWeight: params.policyWeight,
      score: params.score,
      status: params.status,
      imageFile: params.imageFile,
      imageUrl: params.imageUrl,
      policyDocumentFileEn: params.policyDocumentFileEn,
      policyDocumentUrlEn: params.policyDocumentUrlEn,
      policyDocumentFileAr: params.policyDocumentFileAr,
      policyDocumentUrlAr: params.policyDocumentUrlAr,
    );
  }
}
