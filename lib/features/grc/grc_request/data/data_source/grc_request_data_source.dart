/// Module: GRC Request Management
/// Description: Data source contract for GRC Request CRUD operations,
///              independent of any specific backend.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: GrcRequestModel

import 'package:knowticed_plus/features/grc/grc_request/data/models/grc_request_model.dart';

abstract class GrcRequestDataSource {
  Future<GrcRequestModel> create(GrcRequestModel model, {required String moduleId});

  Future<List<GrcRequestModel>> getAll({required String moduleId});

  Future<GrcRequestModel> update(GrcRequestModel updatedModel, {required String moduleId});
}
