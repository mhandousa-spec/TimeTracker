/// Module: messaging / chat / data/data_source/group_chat_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/constants/message_module/api_constants.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import 'package:knowticed_plus/core/services/message_module/firebase/repository/firebase_repository.dart';
import '../../../m3_groups/data/models/group_last_message_info.dart';
import '../../../m3_groups/data/models/group_members.dart';
import '../../../m3_groups/data/models/group_model.dart';
import '../models/group_chat_message_model.dart';
import '../models/group_member_seen_model.dart';

/// ******************************** FILE INFO *****************************
/// Class Name: GroupChatRemoteDataSource
/// Purpose: This file contains the class for group chat remote data source, to have functions that work repository need
/// Author: Mohamed Elrashidy

class GroupChatRemoteDataSource {
  WriteBatch _batch = FirebaseFirestore.instance.batch();

  sendMessage({required GroupChatMessageModel messageModel}) async {
    FirebaseRepository.setDocumentWithIdWithBatch(
        collection:
            "${ApiConstants.groupsChat}/${messageModel.groupId}/${ApiConstants.messages}",
        data: messageModel.toMap(),
        documentId: messageModel.messageId,
        batch: _batch);
  }

  /// Function Name : startBatch
  /// Purpose: function to start batch to commit multiple operations at once
  void startBatch() {
    _batch = FirebaseFirestore.instance.batch();
  }

  /// Function Name : commitBatch
  /// Purpose: function to commit batch to commit multiple operations at once
  Future<Either<Failure, dynamic>> commitBatch() async {
    return await FirebaseRepository.commitBatch(batch: _batch);
  }




  /// Update pinned message ID on the group document
  Future<Either<Failure, void>> updateGroupPinnedMessageId({
    required String groupId,
    required String? pinnedMessageId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(ApiConstants.groups)
          .doc(groupId)
          .update({
        GroupModel.PINNED_MESSAGE_ID: pinnedMessageId,
      });
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }


  /// Function Name : updateGroupMessageData
  /// Purpose: function to add update group message data to batch
  /// Parameters:
  ///            data: Map<String,dynamic> - Map<String, dynamic> data
  ///            groupId: String - group id
  void updateGroupMessageData(
      {required Map<String, dynamic> data, required String groupId}) {
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection: ApiConstants.groups,
        data: data,
        documentId: groupId,
        batch: _batch);
  }

  Stream<Either<Failure, List<Map<String, dynamic>>>> getGroupChatMessages(
      {required String groupId}) async* {
    yield* FirebaseRepository.getStreamOfCollectionSorted(
        collectionPath:
            "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        sortedBy: GroupChatMessageModel.SEND_TIME);
  }

  /// Function Name : updateUserSeenMessages
  /// Purpose: function to add update in batch for user seen messages in message models that were not seen before
  /// Parameters:
  ///           chatId: String - chat id
  ///           messageId: List<String> - list of unseen message ids
  ///           userId: String - user id
  ///           seenTime: Timestamp - seen time
  updateUserSeenMessages({
    required String chatId,
    required List<String> messageId,
    required String userId,
    required Timestamp seenTime,
  }) async {
    for (String id in messageId) {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection(ApiConstants.groupsChat)
          .doc(chatId)
          .collection(ApiConstants.messages)
          .doc(id);
      _batch.update(documentReference, {
        GroupChatMessageModel.SEEN_BY: FieldValue.arrayUnion([
          {
            GroupMemberSeenModel.MEMBER_ID: userId,
            GroupMemberSeenModel.SEEN_TIME: seenTime,
          }
        ])
      });
    }
  }

  /// Function Name : updateUserNumOfUnreadMessages
  /// Purpose: function to update user number of unread messages in group model
  /// Parameters:
  ///          groupId: String - group id
  ///          userId: String - user id
  ///          numOfUnreadMessages: int - number of unread messages

  void updateUserNumOfUnreadMessages(
      {required String groupId,
      required String userId,
      required int numOfUnreadMessages}) {
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection: ApiConstants.groups,
        data: {
          "${GroupMembers.membersKey}.${userId.replaceAll(".", "---")}.${GroupMember.numOfUnreadMessagesKey}":
              numOfUnreadMessages,
              GroupModel.MENTIONED_MEMBERS: FieldValue.arrayRemove([userId])
        },
        documentId: groupId,
        batch: _batch);
  }

  uploadMedia({required String filePath}) async {
    return await FirebaseRepository.uploadFile(
        collectionName: ApiConstants.groupsChat,
        documentName: filePath.split("/").last,
        filePath: filePath);
  }

  /// Function Name : deleteMessage
  /// Purpose: function to delete message from group chat and update group last message info
  /// Parameters:
  ///          messageId: String - message id
  ///          groupId: String - group id
  ///          currentUserId: String - current user id
  ///          Return: Future<Either<Failure, dynamic>> - Future of either failure or dynamic
  ///
  Future<Either<Failure, dynamic>> deleteMessage(
      {required String messageId,
      required String groupId,
      required String currentUserId}) async {
    // start batch to commit multiple operations at once
    startBatch();
    // update message data to be deleted
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection:
            "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        data: {
          GroupChatMessageModel.MESSAGE_TYPE: MessageTypes.deleted.index,
          GroupChatMessageModel.IS_DELETED: true,
        },
        documentId: messageId,
        batch: _batch);
    // get group data to check if the message is the last message in the group
    await _updateGroupLastMessageInfoIfSame(messageId, groupId, {
      "${GroupModel.GROUP_LAST_MESSAGE_INFO}.${GroupLastMessageInfo.MESSAGE_TYPE}":
          MessageTypes.deleted.index
    });
    // commit batch to commit multiple operations at once
    return await commitBatch();
  }
  
  getMessage(String messageId, String groupId) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        documentId: messageId);
  }

  /// Function Name : _updateGroupLastMessageInfoIfSame
  /// Purpose: function to update group last message info if the message is the last message in the group
  /// Parameters:
  ///         messageId: String - message id to check if last message same as it
  ///         groupId: String - group id
  ///         updatedData: Map<String, dynamic> - updated data

  _updateGroupLastMessageInfoIfSame(String messageId, String groupId,
      Map<String, dynamic> updatedData) async {
    var data = await FirebaseFirestore.instance
        .collection(ApiConstants.groups)
        .where(
            "${GroupModel.GROUP_LAST_MESSAGE_INFO}.${GroupLastMessageInfo.MESSAGE_ID}",
            isEqualTo: messageId)
        .get();

    if (data.docs.isNotEmpty) {
      FirebaseRepository.updateDocumentWithIdWithBatch(
          collection: ApiConstants.groups,
          data: updatedData,
          documentId: groupId,
          batch: _batch);
    }
  }

  editTextMessage(
      {required String newMessageText,
      required String messageId,
      required String groupId,
      required String currentUserId}) async {
    startBatch();
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection:
            "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        data: {
          GroupChatMessageModel.MESSAGE_CONTENT: newMessageText,
          GroupChatMessageModel.IS_EDITED: true
        },
        documentId: messageId,
        batch: _batch);

    await _updateGroupLastMessageInfoIfSame(messageId, groupId, {
      "${GroupModel.GROUP_LAST_MESSAGE_INFO}.${GroupLastMessageInfo.TEXT_MESSAGE}":
          newMessageText
    });

    return commitBatch();
  }

  void updateGroupMentionList(
      {required String groupId, required List<String> mentions}) {
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection: ApiConstants.groups,
        documentId: groupId,
        data: {GroupModel.MENTIONED_MEMBERS: FieldValue.arrayUnion(mentions)},
        batch: _batch);
  }

  updateMessage(String messageId, String groupId, Map<String, dynamic> data) async {
  return await  FirebaseRepository.setDocumentWithId(
        collection: "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        documentId: messageId,
        data: data,
        );
  }
}