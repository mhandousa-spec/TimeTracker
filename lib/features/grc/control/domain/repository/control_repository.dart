/// Module: Policy Management
/// Description: Defines the Domain-layer repository contract for Control
///              operations. Controls are their own Firestore subcollection
///              nested under a Policy document:
///              GRC Modules/{Module_ID}/Policies/{Policy_ID}/Controls/{Control_ID}.
///              Unlike Policies, Controls have no "Removed" status, so
///              delete is always a hard delete.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: dartz, Failure, ControlEntity, ControlStatus
/// Revision History: 2026-07-14 - Initial creation
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_weight_history_entry.dart';


/// class name: [ControlRepository]
///
/// purpose: define the contract for all Control operations exposed to the
///          rest of the app. Uses Entities (not Models) and returns
///          [Either<Failure, T>] so callers handle success and failure
///          explicitly.
abstract class ControlRepository {
  Future<Either<Failure, ControlEntity>> createControl({
    required String moduleId,
    required String policyId,
    required String editorId,
    required String controlsNameEn,
    required String controlsNameAr,
    required String controlsNumberEn,
    required String controlsNumberAr,
    required String controlsDescriptionEn,
    required String controlsDescriptionAr,
    required double controlsWeight,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> departments,
    List<double>? departmentsWeights,
    required bool equalWeights,
    required int score,
    required ControlStatus status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  });

  Future<Either<Failure, ControlEntity>> getControl(
    String id, {
    required String moduleId,
    required String policyId,
  });

  Future<Either<Failure, List<ControlEntity>>> getAllControls({
    required String moduleId,
    required String policyId,
  });

  /// function name: [getControlWeightHistory]
  ///
  /// purpose: fetch every recorded weight change across all Controls under
  ///          one Policy, reconstructed from each Control's own revision
  ///          history (see [ControlModel.toWeightHistory]). No dedicated
  ///          Firestore log exists for this — it's derived on read.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyId: id of the parent Policy
  ///
  /// return type: [Future<Either<Failure, List<ControlWeightHistoryEntry>>>] - every weight-change entry across the policy's controls, sorted by date descending, or a Failure
  Future<Either<Failure, List<ControlWeightHistoryEntry>>> getControlWeightHistory({
    required String moduleId,
    required String policyId,
  });

  Future<Either<Failure, ControlEntity>> updateControl({
    required String id,
    required String moduleId,
    required String policyId,
    required String editorId,
    String? controlsNameEn,
    String? controlsNameAr,
    String? controlsNumberEn,
    String? controlsNumberAr,
    String? controlsDescriptionEn,
    String? controlsDescriptionAr,
    double? controlsWeight,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? departments,
    List<double>? departmentsWeights,
    bool? equalWeights,
    int? score,
    ControlStatus? status,
    File? controlsDocumentFileEn,
    String? controlsDocumentUrlEn,
    File? controlsDocumentFileAr,
    String? controlsDocumentUrlAr,
  });

  /// hard delete — Controls have no Removed status.
  Future<Either<Failure, Unit>> deleteControl(
    String id, {
    required String moduleId,
    required String policyId,
  });
}
