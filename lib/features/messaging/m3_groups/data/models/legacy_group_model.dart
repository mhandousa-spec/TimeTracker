// Date: 1/9/2024
// By: Nada Mohammed
// Last update: 1/9/2024
// Objectives: This file is responsible for providing a model for group chatting feature in direct messaging screen.


import '../../../m2_connections/data/models/member_model.dart';

class GroupModel {
  String id;
  String groupName;
  String? groupImage;
  String? groupDescription;
  Member groupAdmin;
  List<Member> groupMembers;
  DateTime createdAt = DateTime.now();

  GroupModel({
    required this.id,
    required this.groupName,
    required this.groupAdmin,
    required this.groupMembers,
    this.groupDescription,
    this.groupImage,
  });

  bool get isMessageDelivered =>
      groupMembers.every((element) => element.isMessageDelivered);

  bool get isMessageRead =>
      groupMembers.every((element) => element.isMessageRead);

  String get isUserTyping {
    final userTyping = groupMembers.firstWhere(
      (element) => element.isrUserTyping,
      orElse: () => Member(id: '', firstName: '', avatarUrl: '', phoneNumber: '', lastName: '',),
    );
    return userTyping.firstName;
  }

  bool isGroupAdmin(Member member) => member.id == groupAdmin.id;
}
