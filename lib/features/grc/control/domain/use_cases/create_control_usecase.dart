/// Module: Policy Management
/// Description: Use case responsible for creating a new Control record
///              inside a Policy's Controls subcollection.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, Failure, ControlEntity, ControlRepository
/// Revision History: 2026-07-14 - Initial creation
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';

import 'package:knowticed_plus/features/grc/control/domain/repository/control_repository.dart';

/// class name: [CreateControlParams]
///
/// purpose: groups every field needed to create a new Control record,
///          including the ids of its parent Module/Policy.
class CreateControlParams {
  final String moduleId;
  final String policyId;
  final String editorId;
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final double controlsWeight;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> departments;
  final bool equalWeights;
  final int score;
  final ControlStatus status;
  final File? controlsDocumentFileEn;
  final String? controlsDocumentUrlEn;
  final File? controlsDocumentFileAr;
  final String? controlsDocumentUrlAr;
  final List<double>? departmentsWeights;

  const CreateControlParams({
    required this.moduleId,
    required this.policyId,
    required this.editorId,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsWeight,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.departments,
    required this.equalWeights,
    required this.score,
    required this.status,
    this.controlsDocumentFileEn,
    this.controlsDocumentUrlEn,
    this.controlsDocumentFileAr,
    this.controlsDocumentUrlAr,
    this.departmentsWeights,
  });
}

/// class name: [CreateControlUseCase]
///
/// purpose: encapsulate the "create a Control" business action.
class CreateControlUseCase {
  const CreateControlUseCase(this._repository);

  final ControlRepository _repository;

  Future<Either<Failure, ControlEntity>> call(CreateControlParams params) {
    return _repository.createControl(
      moduleId: params.moduleId,
      policyId: params.policyId,
      editorId: params.editorId,
      controlsNameEn: params.controlsNameEn,
      controlsNameAr: params.controlsNameAr,
      controlsNumberEn: params.controlsNumberEn,
      controlsNumberAr: params.controlsNumberAr,
      controlsDescriptionEn: params.controlsDescriptionEn,
      controlsDescriptionAr: params.controlsDescriptionAr,
      controlsWeight: params.controlsWeight,
      frequency: params.frequency,
      startDate: params.startDate,
      endDate: params.endDate,
      departments: params.departments,
      departmentsWeights: params.departmentsWeights,
      equalWeights: params.equalWeights,
      score: params.score,
      status: params.status,
      controlsDocumentFileEn: params.controlsDocumentFileEn,
      controlsDocumentUrlEn: params.controlsDocumentUrlEn,
      controlsDocumentFileAr: params.controlsDocumentFileAr,
      controlsDocumentUrlAr: params.controlsDocumentUrlAr,
    );
  }
}
