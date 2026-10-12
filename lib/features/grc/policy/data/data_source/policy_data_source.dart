/// Module: Policy Management
/// Description: Defines the data source contract for Policy CRUD operations,
///              independent of any specific backend implementation. Controls
///              are handled by a separate [ControlDataSource] since they now
///              live in their own Firestore subcollection under each Policy.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: PolicyModel
/// Revision History: 2026-07-5  - Initial creation
///                   2026-07-14 - Migrated to the new schema: soft-delete is
///                                now expressed through
///                                PolicyStatus.removed instead of a
///                                dedicated Is_Deleted flag, so
///                                includeDeleted was renamed to
///                                includeRemoved. Controls are no longer
///                                part of this contract (Mohamed Magdy
///                                Abdelkhalek)

import 'package:knowticed_plus/features/grc/policy/data/models/policy_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_data_source.dart
/// Purpose: Contains the PolicyDataSource abstract class (interface) that
///          any concrete data source implementation must follow.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyDataSource]
///
/// purpose: define the contract that any concrete implementation (Firebase,
///          REST API, local database, etc.) must follow to provide
///          create/read/update/soft-delete/restore operations for Policy
///          records. Controls are managed separately through
///          [ControlDataSource] since they are stored in their own
///          subcollection: GRC_Modules/{Module_ID}/Policies/{Policy_ID}/
///          Controls/{Control_ID}.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
abstract class PolicyDataSource {
  Future<PolicyModel> create(PolicyModel model, {required String moduleId});

  Future<PolicyModel?> get(String id, {required String moduleId});

  /// [includeRemoved]: when false (default), Policies whose latest status is
  /// [PolicyStatus.removed] are excluded from the result.
  Future<List<PolicyModel>> getAll({
    required String moduleId,
    bool includeRemoved = false,
  });

  Future<PolicyModel> update(PolicyModel updatedModel, {required String moduleId});

  /// soft-delete: appends a new revision with status set to
  /// [PolicyStatus.removed]. The document itself is never physically
  /// deleted, preserving the full history.
  Future<PolicyModel> delete(
    String id, {
    required String moduleId,
    required String editorId,
  });

  /// restore: appends a new revision that reverts the status away from
  /// [PolicyStatus.removed], back to whatever status the Policy had right
  /// before it was removed (falling back to [PolicyStatus.draft] if no
  /// earlier status is available).
  Future<PolicyModel> restore(
    String id, {
    required String moduleId,
    required String editorId,
  });
}