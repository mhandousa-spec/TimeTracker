// lib/features/grc/control_owner/data/data_source/owner_data_source.dart
/// Module: Control Owner Management
/// Description: Data source contract for Control Owner CRUD operations.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: OwnerModel

import 'package:knowticed_plus/features/grc/control_owner/data/models/owner_model.dart';

abstract class OwnerDataSource {
  Future<OwnerModel> create(OwnerModel model, {required String moduleId});

  Future<OwnerModel?> get(String ownerEmail, {required String moduleId});

  Future<List<OwnerModel>> getAll({
    required String moduleId,
    bool includeRemoved = false,
  });

  Future<OwnerModel> update(OwnerModel updatedModel, {required String moduleId});
}
