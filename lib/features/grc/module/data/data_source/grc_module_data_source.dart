/// Module: GRC Module Management
/// Description: Defines the data source contract for GRC Module CRUD
///              operations, independent of any specific backend.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: GRCModuleModel
/// Revision History: 2026-06-30 - Initial creation
///                    2026-06-30 - Switched delete() to soft-delete and added restore() (Mohamed Magdy Abdelkhalek)

import 'package:knowticed_plus/features/grc/module/data/models/grc_module_model.dart';



/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_data_source.dart
/// Purpose: Contains the GRCModuleDataSource abstract class (interface) that
///          any concrete data source implementation must follow.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleDataSource]
///
/// purpose: define the contract that any concrete implementation (Firebase,
///          REST API, local database, etc.) must follow to provide
///          create/read/update/delete operations for GRC Module records.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
abstract class GRCModuleDataSource {
  /// function name: [create]
  ///
  /// purpose: persist a brand new GRC Module record (first revision, where
  ///          every history List starts with a single element).
  ///
  /// parameters:
  ///            [GRCModuleModel] model: the model instance to be created
  ///
  /// return type: [Future<GRCModuleModel>] - the created model instance
  Future<GRCModuleModel> create(GRCModuleModel model);

  /// function name: [get]
  ///
  /// purpose: fetch a single GRC Module record, including its full revision
  ///          history, by its unique id.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the record to fetch
  ///
  /// return type: [Future<GRCModuleModel?>] - the matching model, or null if not found
  Future<GRCModuleModel?> get(String id);

  /// function name: [getAll]
  ///
  /// purpose: fetch GRC Module records currently stored.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when false (default), soft-deleted
  ///            records (latest revision has isDeleted = true) are excluded
  ///            from the result
  ///
  /// return type: [Future<List<GRCModuleModel>>] - the list of matching model instances
  Future<List<GRCModuleModel>> getAll({bool includeDeleted = false});

  /// function name: [update]
  ///
  /// purpose: persist an updated GRC Module record. The caller is expected
  ///          to have already produced [updatedModel] via
  ///          [GRCModuleModel.copyWithUpdate], so every history List already
  ///          contains the new revision before this method is called.
  ///
  /// parameters:
  ///            [GRCModuleModel] updatedModel: the model instance with the new revision appended
  ///
  /// return type: [Future<GRCModuleModel>] - the persisted, updated model instance
  Future<GRCModuleModel> update(GRCModuleModel updatedModel);

  /// function name: [delete]
  ///
  /// purpose: soft-delete a GRC Module record. The record is NOT physically
  ///          removed from the database; instead, a new revision is appended
  ///          to every history List with [isDeleted] set to true, so the
  ///          full history (and the ability to [restore]) is preserved.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the record to soft-delete
  ///            [String] editorId: id of the user performing the delete
  ///
  /// return type: [Future<GRCModuleModel>] - the model instance after the delete revision has been appended
  Future<GRCModuleModel> delete(String id, {required String editorId});

  /// function name: [restore]
  ///
  /// purpose: restore a previously soft-deleted GRC Module record by
  ///          appending a new revision with [isDeleted] set to false.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the record to restore
  ///            [String] editorId: id of the user performing the restore
  ///
  /// return type: [Future<GRCModuleModel>] - the model instance after the restore revision has been appended
  Future<GRCModuleModel> restore(String id, {required String editorId});
}