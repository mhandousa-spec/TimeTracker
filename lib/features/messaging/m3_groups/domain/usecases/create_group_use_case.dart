/// Module: messaging / groups / domain/use_cases/create_group_use_case.dart
/// ************************* FILE INFO *************************** ///
/// File Name: create_group_use_case.dart
/// Purpose: Create group use case — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/helper/main_helper/single_value_tracking_model.dart';
import '../../data/models/group_admin_model.dart';
import '../../data/models/group_members.dart';
import '../../data/models/group_model.dart';
import '../entities/member_entity.dart';
import '../base_repository/base_group_repository.dart';

class CreateGroupUseCase {
  final BaseGroupsRepository groupRepository;

  CreateGroupUseCase({required this.groupRepository});

  Future<Either<Failure, void>> execute({
    required String groupName,
    String? groupNameAr, // ✅
    required String groupDescription,
    String? groupDescriptionAr, // ✅
    required String? groupImage,
    required bool isPublic,
    required bool isOnlyAdminsCanSend,
    required bool isUnMuted,
    required bool isDisappearingMessages,
    required String createdBy,
    required List<MemberEntity> groupMembers,
    required List<GroupAdminModel> groupAdmins,
  }) async {
    GroupModel groupModel = createGroupModel(
      groupName: groupName,
      groupNameAr: groupNameAr, // ✅
      groupDescription: groupDescription,
      groupDescriptionAr: groupDescriptionAr, // ✅
      groupImage: groupImage,
      isPublic: isPublic,
      isDisappearingMessages: isDisappearingMessages,
      isOnlyAdminsCanSend: isOnlyAdminsCanSend,
      isUnMuted: isUnMuted,
      createdBy: createdBy,
      groupMembers: groupMembers,
      groupAdmins: groupAdmins,
    );

    return await groupRepository.createGroup(groupModel: groupModel);
  }

  GroupModel createGroupModel({
    required String groupName,
    String? groupNameAr, // ✅
    required String groupDescription,
    String? groupDescriptionAr, // ✅
    required String? groupImage,
    required bool isPublic,
    required bool isDisappearingMessages,
    required bool isOnlyAdminsCanSend,
    required bool isUnMuted,
    required String createdBy,
    required List<MemberEntity> groupMembers,
    required List<GroupAdminModel> groupAdmins,
  }) {
    String groupId = '${createdBy}_${Timestamp.now().millisecondsSinceEpoch}';
    Timestamp creationTime = Timestamp.now();
    Map<String, GroupMember> members = {};
    groupMembers.forEach((member) {
      members[member.memberId] =
          member.toMemberModel(time: creationTime, status: true);
    });
    Map<String, GroupAdminModel> admins = {};
    for (var admin in groupAdmins) {
      admins[admin.adminId] = admin;
    }
    List<String> memberIds = groupMembers.map((e) => e.memberId).toList();

    return GroupModel(
      groupId: groupId,
      groupName: SingleValueTrackingModel<String>(
        values: [groupName],
        timestamps: [creationTime],
      ),
      groupNameAr: groupNameAr != null // ✅ only set if provided
          ? SingleValueTrackingModel<String>(
        values: [groupNameAr],
        timestamps: [creationTime],
      )
          : null,
      groupDescription: SingleValueTrackingModel<String>(
        values: [groupDescription],
        timestamps: [creationTime],
      ),
      groupDescriptionAr: groupDescriptionAr != null // ✅ only set if provided
          ? SingleValueTrackingModel<String>(
        values: [groupDescriptionAr],
        timestamps: [creationTime],
      )
          : null,
      groupImage: SingleValueTrackingModel<String>(
        values: (groupImage != null) ? [groupImage] : [],
        timestamps: (groupImage != null) ? [creationTime] : [],
      ),
      creationTime: creationTime,
      isPublic: SingleValueTrackingModel<bool>(
        values: [isPublic],
        timestamps: [creationTime],
      ),
      isDisappearingMessages: SingleValueTrackingModel<bool>(
        values: [isDisappearingMessages],
        timestamps: [creationTime],
      ),
      isOnlyAdminsCanSend: SingleValueTrackingModel<bool>(
        values: [isOnlyAdminsCanSend],
        timestamps: [creationTime],
      ),
      isDeleted: false,
      deletedTime: null,
      isUnMuted: SingleValueTrackingModel<bool>(
        values: [isUnMuted],
        timestamps: [creationTime],
      ),
      groupMembers: GroupMembers(members: members),
      groupAdmins: GroupAdminsModel(adminData: admins),
      groupLastMessageInfo: null,
      createdBy: createdBy,
      currentExistingMembers: memberIds,
    );
  }
}