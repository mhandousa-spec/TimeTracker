/// Module: GRC shared helpers
/// Description: One entry point for every "Message <person>" button on the
///              GRC champion / owner / request screens.
/// Author: Knowticed Plus team
/// Date: 2026-09-15
/// Dependencies: MessagingInterfaceImplementation
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/messaging_interface_implementation.dart';

/// function name: [openGrcChat]
///
/// purpose: opens the one-to-one chat with [email]. The GRC person cards
///          all shipped with an empty `() {}` Message handler; the flow they
///          need is `openChatWithUser`, which works from outside the
///          messaging subtree (the obvious `ConnectionsCubit.selectConnection`
///          throws here — no SingleChatCubit is provided above this module).
///
/// parameters:
///            [BuildContext] context: any navigable context
///            [String] email: the colleague's email (= messaging user id)
///
/// return type: [Future<void>]
Future<void> openGrcChat(BuildContext context, String email) async {
  if (email.trim().isEmpty) return;
  final OpenChatResult result = await MessagingInterfaceImplementation()
      .tryOpenChatWithUser(context: context, userEmail: email);
  if (context.mounted) await showOpenChatFailure(context, result);
}
