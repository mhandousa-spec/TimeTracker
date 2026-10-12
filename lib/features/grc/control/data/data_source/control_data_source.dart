/// Module: Policy Management
/// Description: Defines the data source contract for Control CRUD
///              operations, independent of any specific backend
///              implementation. Controls live in their own Firestore
///              subcollection nested under a Policy document.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: ControlModel
/// Revision History: 2026-07-14 - Initial creation, split out of the old
///                                nested-controls handling in
///                                PolicyDataSource now that Controls are
///                                their own subcollection (Mohamed Magdy
///                                Abdelkhalek)

import 'package:knowticed_plus/features/grc/control/data/models/control_model.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: control_data_source.dart
/// Purpose: Contains the ControlDataSource abstract class (interface) that
///          any concrete data source implementation must follow.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 14/7/2026

/// class name: [ControlDataSource]
///
/// purpose: define the contract that any concrete implementation (Firebase,
///          REST API, local database, etc.) must follow to provide
///          create/read/update/delete operations for Control records.
///          Firestore path: GRC_Modules/{Module_ID}/Policies/{Policy_ID}/
///          Controls/{Control_ID}. Unlike Policies, Controls have no
///          "Removed" status, so [delete] is a hard delete of the document
///          rather than a status change.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 14/7/2026
abstract class ControlDataSource {
  Future<ControlModel> create(
    ControlModel model, {
    required String moduleId,
    required String policyId,
  });

  Future<ControlModel?> get(
    String id, {
    required String moduleId,
    required String policyId,
  });

  Future<List<ControlModel>> getAll({
    required String moduleId,
    required String policyId,
  });

  Future<ControlModel> update(
    ControlModel updatedModel, {
    required String moduleId,
    required String policyId,
  });

  /// hard-delete: Controls have no Removed status, so this physically
  /// deletes the Control document from the subcollection.
  Future<void> delete(
    String id, {
    required String moduleId,
    required String policyId,
  });
}