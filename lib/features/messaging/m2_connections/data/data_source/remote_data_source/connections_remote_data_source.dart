/// Module: messaging / connections / data/data_source/remote_data_source/connections_remote_data_source.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_remote_data_source.dart
/// Purpose: Connections remote data source — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/constants/message_module/api_constants.dart';
import 'package:knowticed_plus/core/services/firebase/models/query_data_model.dart';
import 'package:knowticed_plus/core/services/message_module/firebase/repository/firebase_repository.dart';
import '../../models/user_connection_last_message_info_model.dart';
import '../../models/users_connection_model.dart';

class ConnectionsRemoteDataSource {
  Future<Either<Failure, void>> createNewConnection(
      {required UsersConnectionModel currentUserConnectionModel,
      required UsersConnectionModel otherUserConnectionModel}) async {
    // user id for each document come from other as each user has information about the other user
    return await FirebaseRepository.setMultipleDocuments(queryDataModels: [
      QueryDataModel(
          collectionPath:
              '${ApiConstants.usersConnections}/${otherUserConnectionModel.userId}/${ApiConstants.lastMessage}',
          documentId: currentUserConnectionModel.userId,
          queryData: currentUserConnectionModel.toMap()),
      QueryDataModel(
          collectionPath:
              '${ApiConstants.usersConnections}/${currentUserConnectionModel.userId}/${ApiConstants.lastMessage}',
          documentId: otherUserConnectionModel.userId,
          queryData: otherUserConnectionModel.toMap())
    ]);
  }

  Stream<Either<Failure, List<Map<String, dynamic>>>> getCurrentUserConnection(
      {required String currentUserId}) async* {
    log(
        "collection path: ${ApiConstants.usersConnections}/$currentUserId/${ApiConstants.lastMessage}");
    // CHANGED 29/9/2026 (bug report p.11): each map now also carries its
    // DOCUMENT ID under [connectionDocIdKey]. The doc id IS the other user's
    // id, and it is the only way to recover a conversation whose document
    // holds just the last-message fields (no User_ID / names) — see
    // ConnectionsRepository.getCurrentUserConnections.
    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in FirebaseFirestore.instance
              .collection(
                  '${ApiConstants.usersConnections}/$currentUserId/${ApiConstants.lastMessage}')
              // CHANGED 30/9/2026 (Messages QA p.2): no server-side orderBy.
              // Firestore's orderBy silently DROPS every document that lacks
              // the ordered field, so a conversation whose doc had no
              // Last_Message_Time never reached the Direct Message list. The
              // list is sorted newest-first on the client
              // (GetAllAppUsersInConnectionFormUseCase), so nothing is lost.
              .snapshots()) {
        yield Right(snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                <String, dynamic>{...doc.data(), connectionDocIdKey: doc.id})
            .toList());
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  /// Key under which [getCurrentUserConnection] passes each document's id.
  static const String connectionDocIdKey = '__connection_doc_id';
}
