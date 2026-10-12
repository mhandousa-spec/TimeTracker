/// Module: messaging / groups / domain/use_cases/get_groups_use_case.dart
/// ************************* FILE INFO *************************** ///
/// File Name: get_groups_use_case.dart
/// Purpose: Get groups use case — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../data/models/group_model.dart';
import '../entities/group_entity.dart';
import '../base_repository/base_group_repository.dart';

class GetGroupsUseCase {
  final BaseGroupsRepository groupRepository;

  GetGroupsUseCase({required this.groupRepository});

  Stream<Either<Failure, dynamic>> execute({
    required String userId,
    List<UserCategory>? categories,
  }) async* {
    Stream<Either<Failure, dynamic>> groupsStream =
        groupRepository.getGroups(userId: userId);
    await for (final groups in groupsStream) {
      {
        if (groups.isLeft()) {
          yield groups;

        }
        List<GroupEntity> groupEntities = [];
        List<GroupModel> groupsList = groups.getOrElse(() => [] as List<GroupModel>) as List<GroupModel>;
        for (GroupModel group in groupsList) {
          groupEntities.add(
              GroupEntity.fromModel(group, userId, categories: categories));
        }
        yield Right(groupEntities);
      }
    }
  }
}
