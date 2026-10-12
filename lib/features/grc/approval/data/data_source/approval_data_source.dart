import 'package:knowticed_plus/features/grc/approval/data/models/approval_model.dart';

abstract class ApprovalDataSource {
  Future<ApprovalModel?> get(String id, {required String moduleId});

  Future<List<ApprovalModel>> getAll({required String moduleId});

  Future<ApprovalModel> create(
    ApprovalModel model, {
    required String moduleId,
  });

  Future<ApprovalModel> update(
    ApprovalModel model, {
    required String moduleId,
  });
}
