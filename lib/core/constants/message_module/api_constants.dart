/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: api_constants.dart
/// Purpose: Declares `ApiConstants`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/message_module/interface/controller/messaging_init_controller.dart';

class ApiConstants {
  static String get baseUri {return Get.find<MessagingInitController>().messagingConfigurations.baseUri.call();}
  /// 24/9/2026: every messaging collection / Storage folder now lives under
  /// the module root `Demo/{companyId}/Modules/messages/...` instead of the
  /// tenant root.
  static String get moduleBase => "$baseUri/Modules/messages";
  static String get usersConnections => "$moduleBase/Connections";
  static String get lastMessage => "Last Message";
  static String get singleChatMessages => "$moduleBase/Single Chat Message";
  static String get messages => "Messages";

  static String get images => "Images";

  static String get groups => "$moduleBase/Messaging Groups";
  static String get memberGroups => "$moduleBase/Member Groups";

  static String get groupsChat => "$moduleBase/Groups Chat";
}
