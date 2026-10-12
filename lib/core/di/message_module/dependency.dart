/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: dependency.dart
/// Purpose: Declares `Dependency`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';

import 'package:knowticed_plus/features/messaging/m1_chat/data/repository/group_chat_repository.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/repository/single_chat_repository.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';

import 'package:knowticed_plus/features/messaging/m2_connections/data/repository/connections_repository.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/data/repository/group_repository.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/community_controller.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/message_controller.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/media_controller.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';

// Dependency
class Dependency {
  /// Registers the messaging module's repositories and cubits with GetX.
  ///
  /// Everything is `permanent: true` / `fenix: true` on purpose. This runs
  /// during the login flow, and GetX's smart management disposes any
  /// non-permanent instance when the route that created it is popped — which
  /// is exactly what happens when login navigates to the main screen. Without
  /// `permanent`, every messaging cubit was destroyed ("deleted from memory")
  /// moments after being created, leaving the Messages tab with nothing.
  init() {
    Get.lazyPut(() => MessageCubit(), fenix: true);
    Get.lazyPut(() => CommunityCubit(), fenix: true);
    //Get.lazyPut(() => GroupsController());
    Get.lazyPut(() => MediaCubit(), fenix: true);

    // Repositories
    Get.put(ConnectionsRepository(), permanent: true);
    Get.put(GroupsRepository(), permanent: true);
    Get.put(SingleChatRepository(), permanent: true); // ✅ added
    Get.put(GroupChatRepository(), permanent: true); // ✅ added

    // Cubits with dependencies
    Get.put(ConnectionsCubit(repository: Get.find<ConnectionsRepository>()),
        permanent: true);
    Get.put(GroupsCubit(repository: Get.find<GroupsRepository>()),
        permanent: true);

    // MessagingHomeCubit with dependencies
    Get.put(
      MessagingHomeCubit(
        connectionsCubit: Get.find<ConnectionsCubit>(),
        groupsCubit: Get.find<GroupsCubit>(),
      ),
      permanent: true,
    );

    // Chat cubits. On mobile these are created per-route by ChatMobileView,
    // but the tablet layout renders the chat panel *inline* next to the list
    // (see m2_connections/.../layouts/tablet_body.dart) and resolves them with
    // context.read — as does ConnectionsCubit.selectConnection. So they need
    // to be long-lived and provided alongside the other messaging cubits.
    Get.put(
      SingleChatCubit(chatRepository: Get.find<SingleChatRepository>()),
      permanent: true,
    );
    Get.put(
      GroupChatCubit(
        chatRepository: Get.find<GroupChatRepository>(),
        groupsCubit: Get.find<GroupsCubit>(),
      ),
      permanent: true,
    );
  }
}