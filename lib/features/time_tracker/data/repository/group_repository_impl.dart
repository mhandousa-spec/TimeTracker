/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: group_repository_impl.dart
/// Purpose: Declares `GroupRepositoryImpl` — employee groups in
///          `Modules/time_tracker/Groups/{id}`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Delete is soft (`Is_Deleted`) — STATUS.md assumption A4.

import 'package:knowticed_plus/features/time_tracker/data/models/employee_group_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_history_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';

class GroupRepositoryImpl extends TimeTrackerHistoryRepository<EmployeeGroup>
    implements GroupBaseRepository {
  GroupRepositoryImpl({
    required super.remoteDataSource,
    required super.access,
  });

  @override
  String get collectionPath => TimeTrackerFirestorePaths.groups;

  @override
  String get entityLabel => 'group';

  @override
  EmployeeGroup decode(TimeTrackerDocument document) =>
      EmployeeGroupModel.fromMap(document.id, document.data);

  @override
  Map<String, Object?> encode(
    EmployeeGroup entity, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      EmployeeGroupModel.row(entity, id: id, audit: audit);

  @override
  void validate(EmployeeGroup entity) {
    if (entity.name.trim().isEmpty) {
      throw Exception('A group needs a name.');
    }
    if (entity.rules.isBreakAllowed && entity.rules.breakMinutes <= 0) {
      throw Exception('Enter the break length.');
    }
  }

  @override
  Stream<List<EmployeeGroup>> watchGroups() => watchAll();

  @override
  Future<EmployeeGroup> createGroup({required EmployeeGroup group}) async =>
      write(group, id: null, mustExist: false);

  @override
  Future<EmployeeGroup> updateGroup({required EmployeeGroup group}) async =>
      write(group, id: requireId(group.id), mustExist: true);
}
