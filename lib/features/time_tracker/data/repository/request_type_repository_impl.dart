/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_repository_impl.dart
/// Purpose: Declares `RequestTypeRepositoryImpl` — request types in
///          `Modules/time_tracker/Request_Types/{id}`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// "Remove" is a status (removed), never a hard delete — the history stays
/// and old requests keep resolving their type name.
/// Updated: 9/10/2026 - phase 4: [fetchRequestType] (approval side effects).

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_type_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_history_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';

class RequestTypeRepositoryImpl extends TimeTrackerHistoryRepository<RequestType>
    implements RequestTypeBaseRepository {
  RequestTypeRepositoryImpl({
    required super.remoteDataSource,
    required super.access,
  });

  @override
  String get collectionPath => TimeTrackerFirestorePaths.requestTypes;

  @override
  String get entityLabel => 'request type';

  @override
  RequestType decode(TimeTrackerDocument document) =>
      RequestTypeModel.fromMap(document.id, document.data);

  @override
  Map<String, Object?> encode(
    RequestType entity, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      RequestTypeModel.row(entity, id: id, audit: audit);

  @override
  void validate(RequestType entity) {
    if (entity.nameEn.trim().isEmpty && entity.nameAr.trim().isEmpty) {
      throw Exception('A request type needs a name.');
    }
  }

  @override
  Stream<List<RequestType>> watchRequestTypes() => watchAll();

  @override
  Future<RequestType> createRequestType({required RequestType type}) async =>
      write(type, id: null, mustExist: false, newId: const NewDocId('RQT'));

  @override
  Future<RequestType> updateRequestType({required RequestType type}) async =>
      write(type, id: requireId(type.id), mustExist: true);

  @override
  Future<RequestType?> fetchRequestType({required String id}) async =>
      id.trim().isEmpty ? null : fetchOne(id);
}
