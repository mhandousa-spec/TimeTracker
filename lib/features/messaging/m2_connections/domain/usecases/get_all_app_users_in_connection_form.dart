/// Module: messaging / connections / domain/use_cases/get_all_app_users_in_connection_form.dart
/// ************************* FILE INFO *************************** ///
/// File Name: get_all_app_users_in_connection_form.dart
/// Purpose: Get all app users in connection form — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../../../core/helper/message_module/interface/entity/user_connection_interface_parameters.dart';
import '../base_repository/base_connections_repository.dart';
import '../entities/single_connection_entity.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';

/// created by Mohamed Elrashidy
/// created at 30/9/2024
/// description: this class will get all app users and connections and then
/// return single connection entity of all of this entities sorted by the
/// last message time

class GetAllAppUsersInConnectionFormUseCase {
  final ConnectionsRepositoryInterface connectionRepository;

  GetAllAppUsersInConnectionFormUseCase({required this.connectionRepository});

  Stream<Either<Failure, List<SingleConnectionEntity>>> execute({
    required String currentUserId,
    required Future<List<UserConnectionInterfaceParameters>> Function() getAllUsers,
    required List<UserCategory> categories, // ✅ added
  }) async* {
    // Domain stays pure — no try/catch here (§11.2). Any failure from the
    // injected data source propagates to the caller (cubit), which handles it
    // via the stream's onError.
    final List<UserConnectionInterfaceParameters> allUsers = await getAllUsers();

    List<SingleConnectionEntity> connectionLessUsers = mapConnectionLessUsers(
      allUsers: allUsers,
      currentUserId: currentUserId,
    );

    yield* startStreamOfConnections(
      currentUserId,
      connectionLessUsers,
      categories, // ✅ pass through
    );
  }

  Stream<Either<Failure, List<SingleConnectionEntity>>> startStreamOfConnections(
      String currentUserId,
      List<SingleConnectionEntity> allUsers,
      List<UserCategory> categories, // ✅ added
      ) async* {
    await for (final connections in connectionRepository
        .getCurrentUserConnections(
      currentUserId: currentUserId,
      categories: categories, // ✅ pass through
    )) {
      if (connections.isLeft()) {
        yield Left(connections.fold(
              (l) => l,
              (r) => FirebaseFailure(""),
        ));
      } else if (connections.isRight()) {
        List<SingleConnectionEntity> existedConnections =
        connections.getOrElse(() => [] as List<SingleConnectionEntity>)
        as List<SingleConnectionEntity>;

        List<SingleConnectionEntity> allUsersInConnectionForm =
        getAllDataInSingleConnectionForm(
          allUsers,
          existedConnections,
          currentUserId,
        );

        yield Right(allUsersInConnectionForm);
      }
    }
  }

  List<SingleConnectionEntity> getAllDataInSingleConnectionForm(
      List<SingleConnectionEntity> allUsers,
      List<SingleConnectionEntity> existedConnections,
      String currentUserId,
      ) {
    List<SingleConnectionEntity> allUsersInConnectionForm = [];
    Set<String> ids = {};

    for (SingleConnectionEntity connection in existedConnections) {
      if (connection.isProfileMissing) {
        // Bug report p.11: the conversation exists but its doc lacks the
        // other user's profile — borrow it from the employee list.
        SingleConnectionEntity? profile;
        for (final SingleConnectionEntity u in allUsers) {
          if (u.userId.toLowerCase() == connection.userId.toLowerCase()) {
            profile = u;
            break;
          }
        }
        if (profile == null) continue; // unknown user — nothing to show
        connection
          ..primaryLanguageName = profile.primaryLanguageName
          ..secondaryLanguageName = profile.secondaryLanguageName
          ..primaryLanguageSubInfo = profile.primaryLanguageSubInfo
          ..secondaryLanguageSubInfo = profile.secondaryLanguageSubInfo
          ..imageUri = profile.imageUri
          ..userId = profile.userId
          ..otherSideId = profile.userId
          ..phone = profile.phone
          ..userCategory = profile.userCategory
          ..connectionId = profile.connectionId
          ..isProfileMissing = false;
      }
      // CHANGED 30/9/2026 (Messages QA p.2 — a new chat did not show under
      // Direct Message): ids are compared ignoring case. The same person
      // could have two connection docs whose ids differ only in case (one
      // written when the chat was opened, one when the first message was
      // sent); the empty one ("no messages yet") could win and hide the real
      // conversation. The doc that actually carries a message wins, then the
      // newer one.
      final String key = connection.userId.trim().toLowerCase();
      final int existing = allUsersInConnectionForm.indexWhere(
          (c) => c.userId.trim().toLowerCase() == key);
      if (existing == -1) {
        ids.add(key);
        allUsersInConnectionForm.add(connection);
      } else if (_isBetter(connection, allUsersInConnectionForm[existing])) {
        allUsersInConnectionForm[existing] = connection;
      }
    }

    final String me = currentUserId.trim().toLowerCase();
    for (SingleConnectionEntity user in allUsers) {
      final String key = user.userId.trim().toLowerCase();
      if (ids.contains(key)) continue;
      if (key == me) continue;
      allUsersInConnectionForm.add(user);
    }

    // FIXED 24/9/2026 — realtime: `lastMessageTime!` threw on a doc without a
    // time, which killed the connections stream (the list stopped updating
    // with new messages until restart). Missing times now sort last.
    allUsersInConnectionForm.sort((a, b) {
      final at = a.lastMessageTime;
      final bt = b.lastMessageTime;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });

    return allUsersInConnectionForm;
  }

  /// Whether [a] should replace [b] for the same person (see above).
  bool _isBetter(SingleConnectionEntity a, SingleConnectionEntity b) {
    final bool aHas = a.messageType != MessageTypes.none;
    final bool bHas = b.messageType != MessageTypes.none;
    if (aHas != bHas) return aHas;
    final at = a.lastMessageTime;
    final bt = b.lastMessageTime;
    if (at == null) return false;
    if (bt == null) return true;
    return at.compareTo(bt) > 0;
  }

  List<SingleConnectionEntity> mapConnectionLessUsers({
    required List<UserConnectionInterfaceParameters> allUsers,
    required String currentUserId,
  }) {
    List<SingleConnectionEntity> connectionLessUsers = [];
    for (UserConnectionInterfaceParameters user in allUsers) {
      connectionLessUsers.add(
        SingleConnectionEntity.fromBaseMessagingInterface(user, currentUserId),
      );
    }
    return connectionLessUsers;
  }
}