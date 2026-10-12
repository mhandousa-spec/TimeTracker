/// Module: messaging / connections / data/repository/connections_repository.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_repository.dart
/// Purpose: Connections repository — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../domain/base_repository/base_connections_repository.dart';
import '../../domain/entities/single_connection_entity.dart';
import '../data_source/remote_data_source/connections_remote_data_source.dart';
import '../models/users_connection_model.dart';
import '../models/user_connection_last_message_info_model.dart';

// created by Mohamed Elrashidy
// created at 30/9/2024
// description: this class is a repository class that will be used to handle user connections
class ConnectionsRepository extends ConnectionsRepositoryInterface {
  ConnectionsRemoteDataSource remoteDataSource = ConnectionsRemoteDataSource();

  @override
  Future<Either<Failure, void>> createNewConnection({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters newConnectionUser,
  }) async {
    log('creating new connection repository');
    Timestamp timestamp = Timestamp.now();
    String connectionId = "${currentUser.userId}.${newConnectionUser.userId}";
    UsersConnectionModel currentUserConnectionModel = _createConnectionModel(
      user: newConnectionUser,
      timestamp: timestamp,
      connectionId: connectionId,
    );
    UsersConnectionModel newConnectionUserConnectionModel =
    _createConnectionModel(
      user: currentUser,
      timestamp: timestamp,
      connectionId: connectionId,
    );
    return await remoteDataSource.createNewConnection(
      currentUserConnectionModel: currentUserConnectionModel,
      otherUserConnectionModel: newConnectionUserConnectionModel,
    );
  }

  UsersConnectionModel _createConnectionModel({
    required BaseMessagingInterfaceParameters user,
    required Timestamp timestamp,
    required String connectionId,
  }) {
    return UsersConnectionModel(
      connectionId: connectionId,
      userPrimaryLanguageName: user.primaryLanguageName,
      userSecondaryLanguageName: user.secondaryLanguageName,
      userPrimaryLanguageSubInfo: user.primaryLanguageSubInfo,
      userSecondaryLanguageSubInfo: user.secondaryLanguageSubInfo,
      userPhone: user.phone,
      userCategoryId: user.userCategory?.categoryId,
      userId: user.userId,
      userImageUri: user.imageUri,
      startedConnectionTime: timestamp,
    );
  }

  /// Placeholder for a last-message doc with no profile fields. Null when the
  /// doc id is missing or even the last-message part cannot be read.
  SingleConnectionEntity? _orphanConnection(
    Map<String, dynamic> map,
    List<UserCategory> categories,
  ) {
    final Object? docId =
        map[ConnectionsRemoteDataSource.connectionDocIdKey];
    if (docId is! String || docId.isEmpty) return null;
    try {
      final UserConnectionLastMessageInfoModel info =
          UserConnectionLastMessageInfoModel.fromMap(map);
      return SingleConnectionEntity(
        connectionId: '',
        primaryLanguageName: docId,
        secondaryLanguageName: null,
        primaryLanguageSubInfo: null,
        secondaryLanguageSubInfo: null,
        imageUri: '',
        userId: docId,
        phone: null,
        userCategory: null,
        myNumUnreadMessage: info.myUnreadMessagesCount ?? 0,
        lastMessageTime: info.lastMessageTime,
        messageType: info.messageType,
        messageContent: info.textMessage,
        otherSideId: docId,
        isLastMessageSenderIsCurrentUser:
            info.isLastMessageSenderCurrentUser ?? true,
        otherNumUnreadMessage: info.otherUnreadMessagesCount,
        isSeen: info.otherUnreadMessagesCount == 0 &&
            info.isLastMessageSenderCurrentUser == true,
        isProfileMissing: true,
      );
    } catch (_) {
      return null;
    }
  }

  // ✅ FIX: categories parameter added so toSingleConnectionEntity()
  //         can resolve UserCategory without GetX
  @override
  Stream<Either<Failure, dynamic>> getCurrentUserConnections({
    required String currentUserId,
    required List<UserCategory> categories,
  }) async* {
    await for (final futureResult in remoteDataSource.getCurrentUserConnection(
        currentUserId: currentUserId)) {
      final result = futureResult;
      if (result.isRight()) {
        List<Map<String, dynamic>> connections = result.getOrElse(() => []);

        for (var connection in connections) {
          log('Connection: ${connection.toString()}');
        }

        // FIXED 21/9/2026 — one malformed document emptied the whole list.
        //
        // A connection doc that only carries the last-message fields (no
        // User_ID / Connection_ID / names — seen on demo@: `{Text_Message,
        // Message_Type, Message_Id, Last_Message_Time, …}`) made fromMap throw
        // "type 'Null' is not a subtype of type 'String'". The throw killed
        // the stream, the cubit went to ConnectionsError, and Direct Message
        // AND the category chips disappeared for that account while every
        // other account (without such a doc) looked fine. A bad doc is now
        // skipped and logged; the rest of the chats still load.
        final List<SingleConnectionEntity> existedConnections =
            <SingleConnectionEntity>[];
        for (final Map<String, dynamic> connection in connections) {
          try {
            existedConnections.add(UsersConnectionModel.fromMap(connection)
                .toSingleConnectionEntity(categories: categories));
          } catch (e) {
            // CHANGED 29/9/2026 (bug report p.11 — "when chat with new
            // account show his chat here"): such a doc is a REAL conversation
            // whose profile half was never written. Dropping it hid the chat
            // from Direct Message even though messages were exchanged. Keep
            // it as a placeholder keyed by the doc id (= the other user's id);
            // GetAllAppUsersInConnectionFormUseCase fills in the profile from
            // the employee list.
            final SingleConnectionEntity? orphan =
                _orphanConnection(connection, categories);
            if (orphan != null) {
              existedConnections.add(orphan);
            } else {
              log('⚠️ skipped malformed connection doc ($e): $connection');
            }
          }
        }

        yield Right(existedConnections);
      } else if (result.isLeft()) {
        yield result;
      }
    }
  }
}