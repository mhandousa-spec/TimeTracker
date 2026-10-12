/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: messaging_init_controller.dart
/// Purpose: Declares `MessagingInitController`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';
import 'package:knowticed_plus/features/messaging/main_controller/helper/scheduled_messages_service.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/di/message_module/dependency.dart';
import '../../../../../features/messaging/m1_chat/data/repository/group_chat_repository.dart';
import '../../../../../features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import '../../../../../features/messaging/m3_groups/domain/entities/group_entity.dart';
import '../entity/base_messaging_interface_parameters.dart';
import '../entity/group_chat_interface_parameters.dart';
import '../entity/messaging_configurations.dart';
import '../entity/single_chat_interface_parameters.dart';
import '../entity/user_category.dart';
import '../entity/user_connection_interface_parameters.dart';
import '../../main_helper/messaging_interface.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MessagingInitController implements MessagingInterface {
  MessagingInitController({required MessagingConfigurations configurations}) {
    messagingConfigurations = configurations;
    Dependency().init();
  }

  late MessagingConfigurations messagingConfigurations;

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // createNewConnection
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> createNewConnection({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters newConnectionUser,
  }) async {
    return await Get.find<ConnectionsCubit>().createNewConnection(
      currentUser: currentUser,
      newConnectionUser: newConnectionUser,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // showSpecificGroupChat
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<void> showSpecificGroupChat({
    required String groupId,
    required BuildContext context,
  }) async {
    final groupsCubit = Get.find<GroupsCubit>();

    if (groupsCubit.allGroups.any((element) => element.groupId == groupId)) {
      GroupEntity group = groupsCubit.allGroups
          .firstWhere((element) => element.groupId == groupId);

      Get.find<ConnectionsCubit>().clearSelectedConnection();
      groupsCubit.selectGroup(group);

      final chatController = GroupChatCubit(
        chatRepository: GroupChatRepository(),
        groupsCubit: Get.find<GroupsCubit>(),
      );

      await chatController.startChat(
        otherSideData: group,
        currentUserData: groupsCubit.currentUser,
      );

      chatController.messageFocusNode.unfocus();
      chatController.getFirstUnreadIndex();

      if (ContextExtension(context).isTablett) {
        // Tablet: panel updates in place via state
      } else {
        // Pure Bloc: push ChatMobileView with the active cubits (§3).
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatMobileView(
              masterChatCubit: chatController,
              connectionsCubit: Get.find<ConnectionsCubit>(),
              groupsCubit: Get.find<GroupsCubit>(),
            ),
          ),
        );
      }
    } else {
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // showSpecificSingleChat
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<void> showSpecificSingleChat({
    required String otherUserId,
    required BuildContext context,
  }) async {
    final connectionsCubit = Get.find<ConnectionsCubit>();

    // ✅ FIX: If connections are empty, wait for them to load first
    if (connectionsCubit.connections.isEmpty) {
      await connectionsCubit.getAllAppUsersInConnectionForm();

      // Wait briefly for the stream to deliver first batch
      int retries = 0;
      while (connectionsCubit.connections.isEmpty && retries < 20) {
        await Future.delayed(const Duration(milliseconds: 200));
        retries++;
      }

      if (connectionsCubit.connections.isEmpty) {
        return;
      }
    }

    if (connectionsCubit.filteredConnections
        .any((element) => element.userId == otherUserId)) {
      SingleConnectionEntity connection = connectionsCubit.filteredConnections
          .firstWhere((element) => element.userId == otherUserId);

      await connectionsCubit.selectConnection(connection, context);
    } else {

      // ✅ FIX: Check if user exists before firstWhere
      final hasConnection = connectionsCubit.connections
          .any((element) => element.userId == otherUserId);

      if (!hasConnection) {
        return;
      }

      try {
        SingleConnectionEntity connection =
        connectionsCubit.connections.firstWhere((element) {
          return element.userId == otherUserId;
        });

        BaseMessagingInterfaceParameters selectedConnection =
        connection.toBaseMessagingInterface();

        await connectionsCubit.createNewConnection(
          currentUser: connectionsCubit.currentUser,
          newConnectionUser: selectedConnection,
        );

        await connectionsCubit.selectConnection(connection, context);
      } catch (e) {
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // useGroupAndSingleMessaging  ← MAIN FIX IS HERE
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void useGroupAndSingleMessaging({
    required GroupChatInterfaceParameters groupChatParameters,
    required Future<List<UserConnectionInterfaceParameters>> Function()
    getAllUsersDate,
    required UserCategory defaultCategory,
    required BuildContext context,
  }) {
    setContext(context);

    // Insert default "All" category at position 0 only once
    if (!groupChatParameters.categories!
        .any((c) => c.categoryId == defaultCategory.categoryId)) {
      groupChatParameters.categories!.insert(0, defaultCategory);
    }

    // Resolved from GetX, not from `context`. These cubits are owned by
    // Dependency().init() (GetX), and this method is called from the login
    // flow — whose BuildContext has no messaging providers above it, so
    // context.read<>() threw ProviderNotFoundException here.
    final messagingHomeCubit = Get.find<MessagingHomeCubit>();
    final connectionsCubit = Get.find<ConnectionsCubit>();
    final groupsCubit = Get.find<GroupsCubit>();

    // ── Start clean for this user (Messages QA p.1 / p.2) ──────────────────
    // These cubits are permanent GetX instances, so they survive sign-out.
    // Without this reset the next account saw the previous account's chat
    // list and open conversation, and a chat started from the new account
    // could be written under the old one.
    unawaited(connectionsCubit.resetForNewUser());
    groupsCubit.clearSelectedGroup();
    if (Get.isRegistered<SingleChatCubit>()) {
      Get.find<SingleChatCubit>().resetChat();
    }

    // ── MessagingHomeCubit ──────────────────────────────────────────────────
    messagingHomeCubit.categories = groupChatParameters.categories;
    messagingHomeCubit.initialize(initialTab: defaultCategory);

    // ── GroupsCubit ─────────────────────────────────────────────────────────
    groupsCubit.currentUser = groupChatParameters;
    groupsCubit.getAllUsersDate = getAllUsersDate;
    groupsCubit.getGroups();

    // ── ConnectionsCubit ────────────────────────────────────────────────────
    connectionsCubit.currentUser = groupChatParameters;
    connectionsCubit.getAllUsersDate = getAllUsersDate;
    connectionsCubit.categories = groupChatParameters.categories!;

    // ✅ FIX: initialize() MUST be called here so selectedTab / searchController
    //         are set before HomePageHelper calls getAllAppUsersInConnectionForm()
    connectionsCubit.initialize(
      searchController: messagingHomeCubit.searchController,
      sortType: null,
      selectedTab: defaultCategory,
    );

    // Load THIS user's chats now, so the Messages tab never opens on the
    // previous account's list while it waits for its own first build.
    unawaited(connectionsCubit.getAllAppUsersInConnectionForm());

    // Send this user's due scheduled messages (Figma 6799:16821).
    ScheduledMessagesService.startDispatcher(groupChatParameters.userId);

  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stubs
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void updateMyInfoWithConnections({
    required BaseMessagingInterfaceParameters userParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  void useSingleMessagingOnly({
    required SingleChatInterfaceParameters singleChatParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  bool isConnected({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters otherUser,
  }) {
    throw UnimplementedError();
  }

  @override
  bool isThereAnyUnreadMessages({required String currentUserId}) {
    throw UnimplementedError();
  }

  @override
  void blockConnection({required String otherUserId}) {
    throw UnimplementedError();
  }

  @override
  void deleteConnection({required String otherUserId}) {
    throw UnimplementedError();
  }

  @override
  List<GroupEntity> getUserGroups() {
    if (_context == null) {
      throw StateError(
          'Context not set. Call useGroupAndSingleMessaging() first.');
    }
    return _context!.read<GroupsCubit>().allGroups;
  }
}