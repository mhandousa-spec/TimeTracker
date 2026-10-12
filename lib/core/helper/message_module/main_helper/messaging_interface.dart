/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: messaging_interface.dart
/// Purpose: Declares `MessagingInterface`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import '../../../../features/messaging/m3_groups/domain/entities/group_entity.dart';
import '../interface/entity/base_messaging_interface_parameters.dart';
import '../interface/entity/group_chat_interface_parameters.dart';
import '../interface/entity/messaging_configurations.dart';
import '../interface/entity/single_chat_interface_parameters.dart';
import '../interface/entity/specific_group_chat_interface_parameters.dart';
import '../interface/entity/user_category.dart';
import '../interface/entity/user_connection_interface_parameters.dart';


// all interface
abstract class MessagingInterface {
  MessagingInterface(
      {required MessagingConfigurations messagingConfigurations});

  //
  useSingleMessagingOnly(
      {required SingleChatInterfaceParameters singleChatParameters});
  useGroupAndSingleMessaging(
      {required GroupChatInterfaceParameters groupChatParameters,
      required Future<List<UserConnectionInterfaceParameters>> Function()
          getAllUsersDate,
      required UserCategory defaultCategory,
      required BuildContext context});
  showSpecificSingleChat(
      {required String otherUserId, required BuildContext context});

  showSpecificGroupChat(
      {required String groupId, required BuildContext context});

  updateMyInfoWithConnections(
      {required BaseMessagingInterfaceParameters userParameters});

  Future<Either<Failure, void>> createNewConnection(
      {required BaseMessagingInterfaceParameters currentUser,
      required BaseMessagingInterfaceParameters newConnectionUser});

  bool isConnected(
      {required BaseMessagingInterfaceParameters currentUser,
      required BaseMessagingInterfaceParameters otherUser});
  bool isThereAnyUnreadMessages({required String currentUserId});

  deleteConnection({required String otherUserId});

  blockConnection({required String otherUserId});

  List<GroupEntity> getUserGroups();
}
