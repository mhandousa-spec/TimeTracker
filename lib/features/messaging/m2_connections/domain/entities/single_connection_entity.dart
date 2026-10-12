/// Module: messaging / connections / domain/entities/single_connection_entity.dart
/// ************************* FILE INFO *************************** ///
/// File Name: single_connection_entity.dart
/// Purpose: Single connection entity — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/localized_text_helper.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../../../core/helper/message_module/interface/entity/user_connection_interface_parameters.dart';
import '../../../m4_messaging_home/domain/entities/chat_type_entity.dart';

class SingleConnectionEntity extends ChatTypeEntity {
  String connectionId;
  int otherNumUnreadMessage;
  bool isrUserTyping;
  String? primaryLanguageSubInfo;
  String? secondaryLanguageSubInfo;

  String userId;
  String? phone;
  UserCategory? userCategory;
  bool hasPinnedMessage; // ✅ Pin indicator for connection tile

  /// True for a conversation whose Firestore doc had only the last-message
  /// fields (29/9/2026, bug report p.11). Its name/photo/category are filled
  /// in from the employee list by GetAllAppUsersInConnectionFormUseCase.
  bool isProfileMissing;

  SingleConnectionEntity({
    required super.primaryLanguageName,
    required super.secondaryLanguageName,
    required this.primaryLanguageSubInfo,
    required this.secondaryLanguageSubInfo,
    required super.imageUri,
    required this.userId,
    required this.phone,
    required this.userCategory,
    required super.myNumUnreadMessage,
    required super.messageType,
    required super.messageContent,
    required super.lastMessageTime,
    this.isrUserTyping = false,
    required this.connectionId,
    required super.isLastMessageSenderIsCurrentUser,
    required this.otherNumUnreadMessage,
    required super.isSeen,
    required super.otherSideId,
    this.hasPinnedMessage = false, // ✅ default false
    this.isProfileMissing = false,
  });

  static fromBaseMessagingInterface(
      UserConnectionInterfaceParameters userConnection, String currentUserId) {
    return SingleConnectionEntity(
      connectionId: '$currentUserId.${userConnection.userId}',
      primaryLanguageName: userConnection.primaryLanguageName,
      secondaryLanguageName: userConnection.secondaryLanguageName,
      primaryLanguageSubInfo: userConnection.primaryLanguageSubInfo,
      secondaryLanguageSubInfo: userConnection.secondaryLanguageSubInfo,
      imageUri: userConnection.imageUri,
      userId: userConnection.userId,
      phone: userConnection.phone,
      userCategory: userConnection.userCategory,
      messageType: MessageTypes.none,
      messageContent: null,
      lastMessageTime: userConnection.userAccountActivationTime,
      otherNumUnreadMessage: 0,
      isLastMessageSenderIsCurrentUser: false,
      myNumUnreadMessage: 0,
      isSeen: false,
      otherSideId: userConnection.userId,
      hasPinnedMessage: false, // ✅ no pin by default for new connections
    );
  }

  toBaseMessagingInterface() {
    return BaseMessagingInterfaceParameters(
      primaryLanguageName: primaryLanguageName,
      secondaryLanguageName: secondaryLanguageName,
      primaryLanguageSubInfo: primaryLanguageSubInfo,
      secondaryLanguageSubInfo: secondaryLanguageSubInfo,
      imageUri: imageUri,
      userId: userId,
      phone: phone,
      userCategory: userCategory,
    );
  }

  String get subInfo => LocalizedTextHelper.formatString(
      secondaryLanguageText: secondaryLanguageSubInfo,
      primaryLanguageText: primaryLanguageSubInfo!);

  String get name => LocalizedTextHelper.formatString(
    secondaryLanguageText: secondaryLanguageName,
    primaryLanguageText: primaryLanguageName,
  );
}