// Date: 2/9/2024
// By: Mohamed Ashraf
// Last update: 2/9/2024
// Objectives: This file is responsible for providing  the member model used in the community feature.

import 'package:get/get.dart';

import '../../../m3_groups/data/models/legacy_group_model.dart';

class Member {
  // generate a random id to each member for now
  String id;
  String firstName;
  String lastName;
  String avatarUrl;
  String chatAboutStatus;
  // messaging related properties
  RxBool isSelected = false.obs;
  bool isrUserTyping;
  bool isMessageRead;
  bool isMessageDelivered;
  String phoneNumber;
  bool isOnline;
  List<GroupModel> groupsInCommon;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.avatarUrl,
    this.isrUserTyping = false,
    this.isMessageRead = false,
    this.isMessageDelivered = false,
    this.chatAboutStatus = 'Hey there! I am using Property Management.',
    this.isOnline = true,
    this.groupsInCommon = const [],
  });
}
