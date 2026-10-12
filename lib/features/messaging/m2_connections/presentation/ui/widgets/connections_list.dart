/// Module: messaging / connections / presentation/ui/widgets/connections_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_list.dart
/// Purpose: Connections list — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 1/9/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 18/9/2024
// Objectives: This file is responsible for providing the community chats list used in the community feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../domain/entities/single_connection_entity.dart';
import '../../../../main_controller/helper/chat_settings_service.dart';
import './connection_tile.dart';
import './connectionless_tile.dart';

class ConnectionsList extends StatelessWidget {
  final bool seeAll;

  const ConnectionsList({
    this.seeAll = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionsCubit, ConnectionsState>(
      builder: (context, state) {
        final controller = context.read<ConnectionsCubit>();
        // 21/9/2026 — the emitted state first: it is what the counts above
        // are drawn from, so the list and the counts can no longer disagree.
        List<SingleConnectionEntity> filteredList = state is ConnectionsLoaded
            ? state.filteredConnections
            : controller.filteredConnections;

        // CHANGED 30/9/2026 (Messages QA p.3 — "order the chats by the time
        // of the most recent message"): pinned chats used to be lifted to the
        // top (bug report #22), which put yesterday's pinned chats above a
        // chat that received a message this morning. The list is now strictly
        // newest-first; a pinned chat keeps its pin icon on the tile.
        // Still listens to pinnedChats so the tiles repaint when a pin changes.
        return ValueListenableBuilder<Set<String>>(
          valueListenable: ChatSettingsService.pinnedChats,
          builder: (context, pinned, _) {
        // Only when no Sort option is picked — Read / Unread keep their order.
        if (controller.sortType == null) {
        filteredList = List<SingleConnectionEntity>.of(filteredList)
          ..sort((a, b) {
            final at = a.lastMessageTime;
            final bt = b.lastMessageTime;
            if (at == null && bt == null) return 0;
            if (at == null) return 1;
            if (bt == null) return -1;
            return bt.compareTo(at);
          });
        }

        // ✅ When seeAll=false (in "All" tab), show only 3
        // When seeAll=true (in "Direct Messages" tab OR after clicking See More), show all
        final itemCount = seeAll
            ? filteredList.length
            : filteredList.length.clamp(0, 3);

        return ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          shrinkWrap: true,
          itemCount: itemCount,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            SingleConnectionEntity connection = filteredList[index];
            return connection.messageType != MessageTypes.none
                ? ConnectionTile(connection: connection)
                : ConnectionlessTile(chatModel: connection);
          },
        );
          },
        );
      },
    );
  }
}