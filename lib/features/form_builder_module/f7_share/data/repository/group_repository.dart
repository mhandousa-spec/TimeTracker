import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/data/data_source/group_data_source.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/data/models/forms_group_model.dart';

// Date: 21/2/2025
// By: Fouad
// Last update: 21/2/2025
// Objectives: Implementation of group repository
class GroupRepository implements GroupBaseRepository {
  final GroupDataSource groupDataSource = GroupDataSource();

  /// Method Name: [createGroup]
  ///
  /// Purpose: Creates a group in the data source
  ///
  /// Parameters:
  /// [selectedPersons] The list of persons to be added to the group,
  /// [description] The description of the group,
  /// [groupName] The name of the group,
  /// [currentUserId] The id of the current user,
  /// [image] The image of the group,
  ///
  /// Returns a [Right] with no value if the creation is successful, a [Left] with a [Failure] if the creation fails.
  @override
  Future<dynamic> createGroup(
      {required List<PersonEntity> selectedPersons,
      required String description,
      required String groupName,
      required String currentUserId,
      String? image}) async {
    String id = "${currentUserId}_${Timestamp.now().microsecondsSinceEpoch}";

    if (image != null) {
      Either<Failure, dynamic> result = await groupDataSource.uploadImage(
        image: image,
        userId: currentUserId,
        groupId: id,
      );
      if (result.isLeft()) return result;
      image = result.getOrElse(() => "");
      
    }

    FormsGroupModel formsGroupModel = FormsGroupModel(
        id: id,
        emails: selectedPersons.map((e) => e.id).toList(),
        status: selectedPersons.map((e) => "active").toList(),
        image: image == null ? [] : [image ?? ''],
        name: [groupName],
        description: [description],
        timestamp: [Timestamp.now()]);

    return await groupDataSource.createGroup(
        formsGroupModel, id, currentUserId);
  }

  /// Gets all groups from the data source
  ///
  /// Returns a [Right] with a list of [FormsGroupModel] if the retrieval is successful, a [Left] with a [Failure]
  /// if the retrieval fails.
  @override
  Future<dynamic> getGroups({required String currentUserId}) async {
    Either<Failure, dynamic> result =
        await groupDataSource.getGroups(currentUserId: currentUserId);
    if (result.isLeft()) return result;
    List<Map<String, dynamic>> data = result.getOrElse(() => []);
    List<FormsGroupModel> groups =
        data.map((e) => FormsGroupModel.fromMap(e)).toList();
    groups.removeWhere((element) => element.status.last == "inactive");
    return result = Right(groups);
  }

  @override
  Future<dynamic> deleteGroup(
      {required String userId, required String groupId}) async {
    return await groupDataSource.deleteGroup(groupId: groupId, userId: userId);
  }

  /// Method Name: [editGroup]
  ///
  /// Purpose: Edits an existing group in the data source
  ///
  /// Parameters:
  ///             [groupImage] The new image of the group (optional),
  ///             [groupName] The new name of the group,
  ///             [description] The new description of the group,
  ///             [groupId] The id of the group to be edited,
  ///             [removedPersons] The list of persons to be removed from the group,
  ///             [CurrentUserId] The id of the current user,
  ///
  /// Returns a [Right] with no value if the edit is successful, a [Left] with a [Failure] if the edit fails.
  @override
  Future<dynamic> editGroup(
      {String? groupImage,
      required String groupName,
      required String description,
      required String groupId,
      required List<String> removedPersons,
      required String currentUserId}) async {
    Either<Failure, dynamic> result = await groupDataSource.getGroupData(
        groupId: groupId, currentUserId: currentUserId);
    if (result.isLeft()) return result;
    Map<String, dynamic> data = result.getOrElse(() => {});
    FormsGroupModel group = FormsGroupModel.fromMap(data);
    if (groupName != group.name.last) group.name.add(groupName);
    if (description != group.description.last)
      group.description.add(description);
    for (int i = 0; i < group.emails.length; i++) {
      if (removedPersons.contains(group.emails[i])) {
        group.status[i] = "inactive";
      }
    }
    if (groupImage != null) {
      Either<Failure, dynamic> result = await groupDataSource.uploadImage(
        image: groupImage,
        userId: currentUserId,
        groupId: groupId,
      );
      if (result.isLeft()) return result;
      String image = result.getOrElse(() => "");
      group.image.add(image);
    }

    group.timestamp.add(Timestamp.now());

    return await groupDataSource.createGroup(group, groupId, currentUserId);
  }
}
