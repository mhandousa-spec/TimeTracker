/// Module: messaging / connections / data/models/users_connection_model.dart
/// ************************* FILE INFO *************************** ///
/// File Name: users_connection_model.dart
/// Purpose: Users connection model — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../domain/entities/single_connection_entity.dart';
import './user_connection_last_message_info_model.dart';

class UsersConnectionModel {
  /// ************************** USER INFO ****************************
  String userPrimaryLanguageName;
  String? userSecondaryLanguageName;
  String? userPrimaryLanguageSubInfo;
  String? userSecondaryLanguageSubInfo;
  String userImageUri;
  String userId;
  String? userPhone;
  String? userCategoryId;

  /// ************************** CONNECTION INFO ****************************
  Timestamp startedConnectionTime;
  bool isDeletedConnection;
  bool isBlockedConnection;
  String connectionId;

  /// ************************** MESSAGE INFO ****************************
  late UserConnectionLastMessageInfoModel lastMessageInfo;

  UsersConnectionModel({
    required this.connectionId,
    required this.userPrimaryLanguageName,
    required this.userSecondaryLanguageName,
    required this.userPrimaryLanguageSubInfo,
    required this.userSecondaryLanguageSubInfo,
    required this.userImageUri,
    required this.userId,
    required this.userPhone,
    required this.userCategoryId,
    required this.startedConnectionTime,
    this.isDeletedConnection = false,
    this.isBlockedConnection = false,
    MessageTypes messageType = MessageTypes.none,
    String? messageText,
    int myUnreadMessagesCount = 0,
    int otherUnreadMessagesCount = 0,
    Timestamp? lastMessageTime,
  }) {
    lastMessageInfo = UserConnectionLastMessageInfoModel(
      messageType: messageType,
      isLastMessageSenderCurrentUser: false,
      textMessage: messageText,
      myUnreadMessagesCount: myUnreadMessagesCount,
      otherUnreadMessagesCount: otherUnreadMessagesCount,
      lastMessageTime: lastMessageTime ?? startedConnectionTime,
    );
  }

  /// ************************** Fields Key Constants ****************************
  static const String USER_PRIMARY_LANGUAGE_NAME = 'User_Primary_Language_Name';
  static const String USER_SECONDARY_LANGUAGE_NAME = 'User_Secondary_Language_Name';
  static const String USER_PRIMARY_LANGUAGE_SUB_INFO = 'User_Primary_Language_Sub_Info';
  static const String USER_SECONDARY_LANGUAGE_SUB_INFO = 'User_Secondary_Language_Sub_Info';
  static const String USER_IMAGE_URI = 'User_Image_Uri';
  static const String USER_ID = 'User_ID';
  static const String USER_PHONE = 'User_Phone';
  static const String USER_CATEGORY_ID = 'User_Category_ID';
  static const String STARTED_CONNECTION_TIME = 'Started_Connection_Time';
  static const String IS_DELETED_CONNECTION = 'Is_Deleted_Connection';
  static const String IS_BLOCKED_CONNECTION = 'Is_Blocked_Connection';
  static const String CONNECTION_ID = 'Connection_ID';

  /// ************************** Methods ****************************
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      USER_PRIMARY_LANGUAGE_NAME: userPrimaryLanguageName,
      USER_SECONDARY_LANGUAGE_NAME: userSecondaryLanguageName,
      USER_PRIMARY_LANGUAGE_SUB_INFO: userPrimaryLanguageSubInfo,
      USER_SECONDARY_LANGUAGE_SUB_INFO: userSecondaryLanguageSubInfo,
      USER_IMAGE_URI: userImageUri,
      USER_ID: userId,
      USER_PHONE: userPhone,
      USER_CATEGORY_ID: userCategoryId,
      STARTED_CONNECTION_TIME: startedConnectionTime,
      IS_DELETED_CONNECTION: isDeletedConnection,
      IS_BLOCKED_CONNECTION: isBlockedConnection,
      CONNECTION_ID: connectionId,
    };
    data.addAll(lastMessageInfo.toMap());
    return data;
  }

  UsersConnectionModel.fromMap(Map<String, dynamic> map)
      : userPrimaryLanguageName = map[USER_PRIMARY_LANGUAGE_NAME],
        userSecondaryLanguageName = map[USER_SECONDARY_LANGUAGE_NAME],
        userPrimaryLanguageSubInfo = map[USER_PRIMARY_LANGUAGE_SUB_INFO],
        userSecondaryLanguageSubInfo = map[USER_SECONDARY_LANGUAGE_SUB_INFO],
        userImageUri = map[USER_IMAGE_URI],
        userId = map[USER_ID],
        userPhone = map[USER_PHONE],
        userCategoryId = map[USER_CATEGORY_ID] is int
            ? (map[USER_CATEGORY_ID] as int).toString()
            : map[USER_CATEGORY_ID],
        startedConnectionTime = map[STARTED_CONNECTION_TIME],
        isDeletedConnection = map[IS_DELETED_CONNECTION],
        isBlockedConnection = map[IS_BLOCKED_CONNECTION],
        connectionId = map[CONNECTION_ID],
        lastMessageInfo = UserConnectionLastMessageInfoModel.fromMap(map);

  // ✅ FIX: categories passed in directly — no more Get.find<ConnectionsCubit>()
  SingleConnectionEntity toSingleConnectionEntity({
    required List<UserCategory> categories,
  }) {
    UserCategory? userCategory;
    if (userCategoryId != null) {
      for (var element in categories) {
        if (element.categoryId == userCategoryId.toString()) {
          userCategory = element;
          break;
        }
      }
    }

    bool isRead = (lastMessageInfo.otherUnreadMessagesCount == 0 &&
        lastMessageInfo.isLastMessageSenderCurrentUser == true);

    return SingleConnectionEntity(
      connectionId: connectionId,
      primaryLanguageName: userPrimaryLanguageName,
      secondaryLanguageName: userSecondaryLanguageName,
      primaryLanguageSubInfo: userPrimaryLanguageSubInfo,
      secondaryLanguageSubInfo: userSecondaryLanguageSubInfo,
      imageUri: userImageUri,
      userId: userId,
      phone: userPhone,
      userCategory: userCategory,
      myNumUnreadMessage: lastMessageInfo.myUnreadMessagesCount ?? 0,
      lastMessageTime: lastMessageInfo.lastMessageTime,
      messageType: lastMessageInfo.messageType,
      messageContent: lastMessageInfo.textMessage,
      otherSideId: userId,
      isLastMessageSenderIsCurrentUser:
      lastMessageInfo.isLastMessageSenderCurrentUser ?? true,
      otherNumUnreadMessage: lastMessageInfo.otherUnreadMessagesCount,
      isSeen: isRead,
    );
  }
}