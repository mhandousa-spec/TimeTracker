import 'package:knowticed_plus/features/grc/my_audit/data/models/my_audit_model.dart';

abstract class MyAuditDataSource {
  Future<MyAuditModel?> get(String id, {required String moduleId});

  Future<List<MyAuditModel>> getAll({required String moduleId});

  Future<MyAuditModel> create(MyAuditModel model, {required String moduleId});

  Future<MyAuditModel> update(MyAuditModel model, {required String moduleId});
}
