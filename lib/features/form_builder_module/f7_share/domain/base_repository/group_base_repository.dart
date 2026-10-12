/// Module: services_app_module/share
///
/// FILE INFO
/// File Name   : group_base_repository.dart
/// Objective   : Domain contract for group operations. Presentation/domain
///               depend on this interface instead of the concrete data
///               implementation (§3, §4.3).
library;

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

abstract class GroupBaseRepository {
  Future<dynamic> createGroup({
    required List<PersonEntity> selectedPersons,
    required String description,
    required String groupName,
    required String currentUserId,
    String? image,
  });

  Future<dynamic> getGroups({required String currentUserId});

  Future<dynamic> deleteGroup({required String userId, required String groupId});

  Future<dynamic> editGroup({
    String? groupImage,
    required String groupName,
    required String description,
    required String groupId,
    required List<String> removedPersons,
    required String currentUserId,
  });
}
