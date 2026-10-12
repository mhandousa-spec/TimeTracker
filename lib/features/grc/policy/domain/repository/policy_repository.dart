/// Module: Policy Management
/// Description: Defines the Domain-layer repository contract for Policy
///              operations. The domain layer only knows about Entities and
///              Failures — no Firebase, no Models. Control operations live
///              in the separate [ControlRepository] since Controls are now
///              their own Firestore subcollection under each Policy.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: dartz, Failure, PolicyEntity, PolicyStatus
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Migrated to the new schema: Control CRUD
///                                moved out into a dedicated
///                                ControlRepository (Controls are their own
///                                subcollection: GRC_Modules/{Module_ID}/
///                                Policies/{Policy_ID}/Controls/{Control_ID}).
///                                Policy documents are now split into En/Ar
///                                variants, Policy_Image replaces Image, and
///                                includeDeleted was renamed to
///                                includeRemoved since soft-delete is now
///                                expressed via PolicyStatus.removed
///                                (Mohamed Magdy Abdelkhalek)

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_weight_history_entry.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_repository.dart
/// Purpose: Contains the PolicyRepository abstract class (interface) that
///          the Data layer must implement and the Domain/Presentation layers
///          depend on.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyRepository]
///
/// purpose: define the contract for all Policy operations exposed to the
///          rest of the app. Uses Entities (not Models) and returns
///          [Either<Failure, T>] so callers handle success and failure
///          explicitly. Controls are NOT handled here — use
///          [ControlRepository] for creating/reading/updating/deleting the
///          Controls that live under a Policy.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
abstract class PolicyRepository {
  // ================================================================
  // POLICY OPERATIONS
  // ================================================================

  /// function name: [createPolicy]
  ///
  /// purpose: create a new Policy record. Optionally uploads [imageFile]
  ///          and/or the En/Ar document files to Firebase Storage first and
  ///          uses their download URLs in the Firestore document. To also
  ///          create initial Controls for this Policy, call
  ///          [ControlRepository.createControl] separately once the Policy
  ///          id is known.
  ///
  /// parameters:
  ///            [String] policyNameEn: English policy name
  ///            [String] policyNameAr: Arabic policy name
  ///            [String] policyNumberEn: English policy number
  ///            [String] policyNumberAr: Arabic policy number
  ///            [String] policyDescriptionEn: English description
  ///            [String] policyDescriptionAr: Arabic description
  ///            [DateTime] startDate: policy start date
  ///            [DateTime] endDate: policy end date
  ///            [double] policyWeight: policy weight value
  ///            [String] editorId: id/email of the user creating the policy
  ///            [String] moduleId: id of the parent GRC Module
  ///            [PolicyStatus] status: initial lifecycle status
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] imageUrl: already-hosted image URL to use directly, if any
  ///            [File] policyDocumentFileEn: local English document file to upload, if any
  ///            [String] policyDocumentUrlEn: already-hosted English document URL to use directly, if any
  ///            [File] policyDocumentFileAr: local Arabic document file to upload, if any
  ///            [String] policyDocumentUrlAr: already-hosted Arabic document URL to use directly, if any
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the created entity, or a Failure
  Future<Either<Failure, PolicyEntity>> createPolicy({
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String editorId,
    required String moduleId,
    required PolicyStatus status,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  });

  /// function name: [getPolicy]
  ///
  /// purpose: fetch a single Policy record by its id, mapped to its latest
  ///          Entity representation. Does not include its Controls — use
  ///          [ControlRepository.getAllControls] for that.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to fetch
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the matching entity, or a Failure
  Future<Either<Failure, PolicyEntity>> getPolicy(
    String id, {
    required String moduleId,
  });

  /// function name: [getAllPolicies]
  ///
  /// purpose: fetch all Policy records mapped to their latest Entity
  ///          representation.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///            [bool] includeRemoved: when false (default), Policies whose latest status is PolicyStatus.removed are excluded
  ///
  /// return type: [Future<Either<Failure, List<PolicyEntity>>>] - the list of entities, or a Failure
  Future<Either<Failure, List<PolicyEntity>>> getAllPolicies({
    required String moduleId,
    bool includeRemoved = false,
  });

  /// function name: [getPolicyWeightHistory]
  ///
  /// purpose: fetch every recorded weight change across all Policies in a
  ///          Module, reconstructed from each Policy's own revision
  ///          history (see [PolicyModel.toWeightHistory]). No dedicated
  ///          Firestore log exists for this — it's derived on read.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<Either<Failure, List<PolicyWeightHistoryEntry>>>] - every weight-change entry across the module's policies, sorted by date descending, or a Failure
  Future<Either<Failure, List<PolicyWeightHistoryEntry>>> getPolicyWeightHistory({
    required String moduleId,
  });

  /// function name: [updatePolicy]
  ///
  /// purpose: update an existing Policy record. Only non-null fields are
  ///          changed; everything else keeps its last value. Optionally
  ///          uploads new files to Storage before saving. Controls are not
  ///          touched here — use [ControlRepository.updateControl].
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to update
  ///            [String] editorId: id/email of the user performing the update
  ///            [String] moduleId: id of the parent GRC Module
  ///            [String] policyNameEn: new English policy name, if changed
  ///            [String] policyNameAr: new Arabic policy name, if changed
  ///            [String] policyNumberEn: new English policy number, if changed
  ///            [String] policyNumberAr: new Arabic policy number, if changed
  ///            [String] policyDescriptionEn: new English description, if changed
  ///            [String] policyDescriptionAr: new Arabic description, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [double] policyWeight: new weight value, if changed
  ///            [PolicyStatus] status: new lifecycle status, if changed
  ///            [File] imageFile: new local image file to upload, if changed
  ///            [String] imageUrl: new already-hosted image URL, if changed
  ///            [File] policyDocumentFileEn: new local English document file to upload, if changed
  ///            [String] policyDocumentUrlEn: new already-hosted English document URL, if changed
  ///            [File] policyDocumentFileAr: new local Arabic document file to upload, if changed
  ///            [String] policyDocumentUrlAr: new already-hosted Arabic document URL, if changed
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the updated entity, or a Failure
  Future<Either<Failure, PolicyEntity>> updatePolicy({
    required String id,
    required String editorId,
    required String moduleId,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    double? score,
    PolicyStatus? status,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  });

  /// function name: [deletePolicy]
  ///
  /// purpose: soft-delete a Policy record by appending a revision with
  ///          [PolicyStatus.removed] (the record stays in the database) so
  ///          it can be restored later.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to delete
  ///            [String] editorId: id/email of the user performing the delete
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the entity after the delete revision, or a Failure
  Future<Either<Failure, PolicyEntity>> deletePolicy({
    required String id,
    required String editorId,
    required String moduleId,
  });

  /// function name: [restorePolicy]
  ///
  /// purpose: restore a previously soft-deleted Policy record, reverting its
  ///          status away from [PolicyStatus.removed].
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to restore
  ///            [String] editorId: id/email of the user performing the restore
  ///            [String] moduleId: id of the parent GRC Module
  ///
  /// return type: [Future<Either<Failure, PolicyEntity>>] - the entity after the restore revision, or a Failure
  Future<Either<Failure, PolicyEntity>> restorePolicy({
    required String id,
    required String editorId,
    required String moduleId,
  });
}