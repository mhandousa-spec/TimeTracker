/// Module: messaging / home / presentation/ui/pages/home_layout_helper.dart
/// ************************* FILE INFO *************************** ///
/// File Name: home_layout_helper.dart
/// Purpose: Home layout helper — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';


import '../../../../m1_chat/presentation/controller/main_controllers/group_chat_cubit.dart';
import '../../../../m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import '../../../../m1_chat/presentation/controller/media_controller.dart';
import '../../../../m1_chat/presentation/controller/message_controller.dart';
import '../../../../m2_connections/presentation/controller/community_controller.dart';
import '../../../../m2_connections/presentation/controller/connections_controller.dart';
import '../../../../m3_groups/presentation/controller/groups_controller.dart';
import '../../controller/messaging_home_controller.dart';
import '../../../../main_controller/helper/chat_settings_service.dart';
import './home_mobile_page.dart';
import './home_tablet_page.dart';

class HomePageHelperLayout extends StatelessWidget {
  const HomePageHelperLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // The messaging cubits are owned by GetX (see core/di/message_module/
    // dependency.dart), but the Home pages consume them with `context.read` /
    // `BlocBuilder`, which resolve through provider. Expose the *same*
    // instances to this subtree with BlocProvider.value — matching how
    // chat_mobile_view.dart bridges GetX and bloc.
    // NOTE: CommunityCubit is registered with Get.lazyPut, so it is only
    // "prepared" until something first resolves it — isRegistered alone would
    // report false here. Accept either state; Get.find() instantiates it.
    bool available<T>() => Get.isRegistered<T>() || Get.isPrepared<T>();

    if (!available<ConnectionsCubit>() ||
        !available<MessagingHomeCubit>() ||
        !available<CommunityCubit>() ||
        !available<GroupsCubit>() ||
        !available<MessageCubit>() ||
        !available<MediaCubit>() ||
        !available<SingleChatCubit>() ||

        !available<GroupChatCubit>()) {
      log('❌ HomePageHelper: messaging dependencies not registered. '
          'Make sure useGroupAndSingleMessaging() is called before navigating here.');
      return const SizedBox.shrink();
    }

    // Every GetX-owned cubit the Home/Connections/Groups widgets resolve with
    // context.read / BlocBuilder.
    //
    // SingleChatCubit / GroupChatCubit are included because the *tablet*
    // layout renders the chat panel inline in this subtree (tablet_body.dart)
    // and ConnectionsCubit.selectConnection reads SingleChatCubit off the
    // context. On mobile, ChatMobileView still provides its own MasterChatCubit
    // for the pushed route, which is unaffected by these.
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectionsCubit>.value(value: Get.find<ConnectionsCubit>()),
        BlocProvider<MessagingHomeCubit>.value(
            value: Get.find<MessagingHomeCubit>()),
        BlocProvider<CommunityCubit>.value(value: Get.find<CommunityCubit>()),
        BlocProvider<GroupsCubit>.value(value: Get.find<GroupsCubit>()),
        BlocProvider<MessageCubit>.value(value: Get.find<MessageCubit>()),
        BlocProvider<MediaCubit>.value(value: Get.find<MediaCubit>()),
        BlocProvider<SingleChatCubit>.value(value: Get.find<SingleChatCubit>()),
        BlocProvider<GroupChatCubit>.value(value: Get.find<GroupChatCubit>()),
      ],
      // MultiBlocProvider only accepts `child`, so a Builder is what gives us
      // a context that sits *below* the providers above — reading the cubits
      // with this widget's own context would still throw.
      child: Builder(builder: (context) => _buildLayout(context)),
    );
  }

  Widget _buildLayout(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionsCubit = context.read<ConnectionsCubit>();
      final homeCubit = context.read<MessagingHomeCubit>();

      // ── Guard: currentUser must be set by useGroupAndSingleMessaging() first ──
      // Uses the cubit's own init guard so the UI page holds no try/catch (§11.2).
      if (!connectionsCubit.isCurrentUserInitialized) {
        log('❌ HomePageHelper: currentUser not set on ConnectionsCubit yet. '
            'Make sure useGroupAndSingleMessaging() is called before navigating here.');
        return;
      }

      // Pinned / muted chat icons on the chat cards (bug report #20–22).
      ChatSettingsService.watch(connectionsCubit.currentUser.userId);

      // ── Guard: categories must be set ──
      if (connectionsCubit.categories == null ||
          connectionsCubit.categories!.isEmpty) {
        log('❌ HomePageHelper: categories not set on ConnectionsCubit.');
        return;
      }

      // ── initialize() sets searchController / sortType / selectedTab ──
      // This is safe to call multiple times (idempotent).
      connectionsCubit.initialize(
        searchController: homeCubit.searchController,
        sortType: null,
        selectedTab: connectionsCubit.categories!.first,
      );

      log('✅ HomePageHelper: calling getAllAppUsersInConnectionForm()');
      connectionsCubit.getAllAppUsersInConnectionForm();
    });

    return ResponsiveHelper(
      mobileWidget: HomeMobilePage(),
      tabletWidget: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => HomeTabletPage(),
        ),
      ),
    );
  }
}