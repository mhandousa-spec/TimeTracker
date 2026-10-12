/// Module: messaging / groups / data/data_source/remote_data_source/remote_data_source/demo_remote_data_source.dart
///************************* FILE INFO ****************************///
/// File Name: group_repository.dart
/// Purpose: This file contains the network functions for groups
/// Author: Mohamed Elrashidy
/// Created At: 15-10-2024

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/constants/message_module/api_constants.dart';
import 'package:knowticed_plus/core/services/message_module/firebase/repository/firebase_repository.dart';
import '../../models/group_model.dart';

class RemoteDataSource {
  WriteBatch batch = FirebaseFirestore.instance.batch();

  /// function name: uploadGroupImage
  /// purpose: upload group image to firebase storage
  /// parameters:
  ///            [image]: String - the image path to be uploaded
  /// return type: Future<Either<Failure, dynamic>>, return error if failed to upload image or image url if success
  uploadGroupImage(String image) async {
    return await FirebaseRepository.uploadFile(
        collectionName: ApiConstants.groups,
        documentName: image.split('/').last,
        filePath: image);
  }

  /// function name: addGroup
  /// purpose: add a new group to firebase
  /// parameters:
  ///            [groupModel]: GroupModel - the group to be added
  addGroup(GroupModel groupModel) async {
    return await FirebaseRepository.setDocumentWithId(
      collection: ApiConstants.groups,
      data: groupModel.toMap(),
      documentId: groupModel.groupId,
    );
  }

  /// function name: getGroups
  /// purpose: get all groups for a specific user as a stream
  /// parameters:
  ///            [userId]: String - the user id to get groups for
  /// return type: Stream<Either<Failure, dynamic>>, return error if failed to get groups or list of groups if success
  Stream<Either<Failure, dynamic>> getGroups(String userId) async* {
    yield* FirebaseRepository
        .getStreamOfDocumentsWithOneFieldValueAndHasValueOfList(
            collectionPath: ApiConstants.groups,
            fieldKey: GroupModel.IS_DELETED,
            fieldValue: false,
            specificValueInList: userId,
            listKey: GroupModel.CURRENT_EXISTING_MEMBERS);
  }

  /// function name: getGroup
  /// purpose: get a specific group
  /// parameters:
  ///            [groupId]: String - the group id to get
  /// return type: Future<Map<String, dynamic>>, return the group data
  getGroup({required String groupId}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.groups, documentId: groupId);
  }

  deleteGroup({required String groupId}) {
    return FirebaseRepository.updateDocumentWithId(
      collection: ApiConstants.groups,
      documentId: groupId,
      data: {
        GroupModel.IS_DELETED: true,
        GroupModel.DELETED_TIME: Timestamp.now()
      },
    );
  }
}
