/// Module: messaging / groups / data/repository/group_repository.dart
///************************* FILE INFO *****************************
/// File Name: group_repository.dart
/// Purpose: This file contains the repository for groups
/// Author: Mohamed Elrashidy
/// Created At: 15-10-2024

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/helper/main_helper/single_value_tracking_model.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/base_repository/base_group_repository.dart';
import '../data_source/remote_data_source/remote_data_source.dart';
import '../models/group_admin_model.dart';
import '../models/group_model.dart';

class GroupsRepository implements BaseGroupsRepository {
  RemoteDataSource remoteDataSource = RemoteDataSource();

  @override
  Future<Either<Failure, dynamic>> createGroup(
      {required GroupModel groupModel}) async {
    Either<Failure, dynamic> result;
    if (groupModel.groupImage.values.isNotEmpty) {
      result = await remoteDataSource
          .uploadGroupImage(groupModel.groupImage.values.last);
      if (result.isLeft()) return result;
      String imageUrl = result.getOrElse(() => '');
      groupModel.groupImage.values.last = imageUrl;
    }
    result = await remoteDataSource.addGroup(groupModel);
    return result;
  }

  @override
  Stream<Either<Failure, dynamic>> getGroups({required String userId}) async* {
    Stream<Either<Failure, dynamic>> groupsStream =
    remoteDataSource.getGroups(userId);
    await for (final Either<Failure, dynamic> groups in groupsStream) {
      if (groups.isLeft()) {
        yield groups;
      } else {
        List<Map<String, dynamic>> groupsList = groups.getOrElse(() => []);
        List<GroupModel> groupsModelList = [];
        for (Map<String, dynamic> group in groupsList) {
          groupsModelList.add(GroupModel.fromMap(group));
        }
        yield Right(groupsModelList);
      }
    }
  }

  @override
  Future<Either<Failure, dynamic>> removeGroupMembers(
      {required String groupId, required List<String> members}) async {
    Either<Failure, dynamic> result =
    await remoteDataSource.getGroup(groupId: groupId);
    if (result.isLeft()) return result;
    Map<String, dynamic> data = result.getOrElse(() => {});
    GroupModel groupModel = GroupModel.fromMap(data);
    _updateGroupMembersState(members: members, group: groupModel);
    _updateGroupAdminState(members: members, group: groupModel);
    return await remoteDataSource.addGroup(groupModel);
  }

  @override
  addGroupAdmins(
      {required String groupId, required List<String> admins}) async {
    Either<Failure, dynamic> result =
    await remoteDataSource.getGroup(groupId: groupId);
    if (result.isLeft()) return result;
    Map<String, dynamic> data = result.getOrElse(() => {});
    GroupModel groupModel = GroupModel.fromMap(data);
    _updateGroupAdminState(members: admins, group: groupModel, state: true);
    return await remoteDataSource.addGroup(groupModel);
  }

  @override
  removeGroupAdmins(
      {required String groupId, required List<String> admins}) async {
    Either<Failure, dynamic> result =
    await remoteDataSource.getGroup(groupId: groupId);
    if (result.isLeft()) return result;
    Map<String, dynamic> data = result.getOrElse(() => {});
    GroupModel groupModel = GroupModel.fromMap(data);
    _updateGroupAdminState(members: admins, group: groupModel);
    return await remoteDataSource.addGroup(groupModel);
  }

  _updateGroupMembersState(
      {required List<String> members,
        required GroupModel group,
        bool state = false}) {
    for (String memberId in members) {
      if (group.groupMembers.members.containsKey(memberId)) {
        group.groupMembers.members[memberId]!.isMember.add(state);
        group.groupMembers.members[memberId]!.timestamps.add(Timestamp.now());
      }
      group.currentExistingMembers.remove(memberId);
    }
  }

  _updateGroupAdminState(
      {required List<String> members,
        required GroupModel group,
        bool state = false}) {
    for (String memberId in members) {
      if (group.groupAdmins.adminData.containsKey(memberId)) {
        group.groupAdmins.adminData[memberId]!.isAdmin.add(state);
        group.groupAdmins.adminData[memberId]!.timestamps.add(Timestamp.now());
      } else if (state) {
        group.groupAdmins.adminData[memberId] = GroupAdminModel(
            adminId: memberId, isAdmin: [state], timestamps: [Timestamp.now()]);
      }
    }
  }

  @override
  addGroupMembers(
      {required String groupId, required MemberEntity member}) async {
    Either<Failure, dynamic> result =
    await remoteDataSource.getGroup(groupId: groupId);
    if (result.isLeft()) return result;
    Map<String, dynamic> data = result.getOrElse(() => {});
    GroupModel groupModel = GroupModel.fromMap(data);
    _addMemberToGroup(member: member, group: groupModel);
    return await remoteDataSource.addGroup(groupModel);
  }

  _addMemberToGroup({required MemberEntity member, required GroupModel group}) {
    if (group.groupMembers.members.containsKey(member.memberId)) {
      group.groupMembers.members[member.memberId]!.isMember.add(true);
      group.groupMembers.members[member.memberId]!.timestamps
          .add(Timestamp.now());
    } else {
      group.groupMembers.members[member.memberId] =
          member.toMemberModel(time: Timestamp.now(), status: true);
    }
    group.currentExistingMembers.add(member.memberId);
  }

  @override
  updateGroupData({
    String? image,
    String? groupName,
    String? groupNameAr, // ✅
    String? groupDescription,
    String? groupDescriptionAr, // ✅ ADD THIS
    bool? isPublic,
    bool? isOnlyAdminsCanSend,
    bool? isDisappearingMessages,
    bool? isUnMuted,
    GroupEntity? groupEntity,
  }) async {
    Either<Failure, dynamic> result =
    await remoteDataSource.getGroup(groupId: groupEntity!.groupId);
    if (result.isLeft()) return result;
    Map<String, dynamic> data = result.getOrElse(() => {});
    GroupModel groupModel = GroupModel.fromMap(data);

    if (image != null) {
      Either<Failure, dynamic> imageResult =
      await remoteDataSource.uploadGroupImage(image);
      if (imageResult.isLeft()) return imageResult;
      String imageUrl = imageResult.getOrElse(() => '');
      groupModel.groupImage.values.add(imageUrl);
      groupModel.groupImage.timestamps.add(Timestamp.now());
    }
    if (groupName != null) {
      groupModel.groupName.values.add(groupName);
      groupModel.groupName.timestamps.add(Timestamp.now());
    }
    if (groupNameAr != null) { // ✅
      groupModel.groupNameAr ??= SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      );
      groupModel.groupNameAr!.values.add(groupNameAr);
      groupModel.groupNameAr!.timestamps.add(Timestamp.now());
    }
    if (groupDescription != null) {
      groupModel.groupDescription.values.add(groupDescription);
      groupModel.groupDescription.timestamps.add(Timestamp.now());
    }
    if (groupDescriptionAr != null) { // ✅ ADD THIS BLOCK
      groupModel.groupDescriptionAr ??= SingleValueTrackingModel<String>(
        values: [],
        timestamps: [],
      );
      groupModel.groupDescriptionAr!.values.add(groupDescriptionAr);
      groupModel.groupDescriptionAr!.timestamps.add(Timestamp.now());
    }
    if (isPublic != null) {
      groupModel.isPublic.values.add(isPublic);
      groupModel.isPublic.timestamps.add(Timestamp.now());
    }
    if (isOnlyAdminsCanSend != null) {
      groupModel.isOnlyAdminsCanSend.values.add(isOnlyAdminsCanSend);
      groupModel.isOnlyAdminsCanSend.timestamps.add(Timestamp.now());
    }
    if (isDisappearingMessages != null) {
      groupModel.isDisappearingMessages.values.add(isDisappearingMessages);
      groupModel.isDisappearingMessages.timestamps.add(Timestamp.now());
    }
    if (isUnMuted != null) {
      groupModel.isUnMuted.values.add(isUnMuted);
      groupModel.isUnMuted.timestamps.add(Timestamp.now());
    }

    return await remoteDataSource.addGroup(groupModel);
  }

  @override
  Future<void> deleteGroup({required String groupId}) async {
    return await remoteDataSource.deleteGroup(groupId: groupId);
  }
}