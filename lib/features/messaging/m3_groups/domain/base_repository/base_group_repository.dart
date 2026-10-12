/// Module: messaging / groups / domain/repository/base_group_repository.dart
/// ************************* FILE INFO *************************** ///
/// File Name: base_group_repository.dart
/// Purpose: Base group repository — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import '../../data/models/group_model.dart';
import '../entities/group_entity.dart';
import '../entities/member_entity.dart';

abstract interface class BaseGroupsRepository {
  Future<Either<Failure, dynamic>> createGroup(
      {required GroupModel groupModel});

  Stream<Either<Failure, dynamic>> getGroups({required String userId});

  Future<Either<Failure, dynamic>> removeGroupMembers(
      {required String groupId, required List<String> members});

  addGroupAdmins({required String groupId, required List<String> admins});

  removeGroupAdmins({required String groupId, required List<String> admins});

  addGroupMembers({required String groupId, required MemberEntity member});

  updateGroupData({
    String? image,
    String? groupName,
    String? groupNameAr, // ✅ Arabic name
    String? groupDescription,
    String? groupDescriptionAr, // ✅ Arabic description
    bool? isPublic,
    bool? isOnlyAdminsCanSend,
    bool? isDisappearingMessages,
    bool? isUnMuted,
    GroupEntity? groupEntity,
  });

  void deleteGroup({required String groupId});
}