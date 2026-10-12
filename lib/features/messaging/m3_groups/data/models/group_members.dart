/// Module: messaging / groups / data/models/group_members.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_members.dart
/// Purpose: Group members — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMembers {
  final Map<String, GroupMember> members;
  const GroupMembers({required this.members});

  static const String membersKey = 'Members';

  GroupMembers copyWith({Map<String, GroupMember>? members}) {
    return GroupMembers(members: members ?? this.members);
  }

  // make map with title members and values userid as key and groupMember data as value
  Map<String, dynamic> toMap() {
    return {
      membersKey: members.map(
          (key, value) => MapEntry(key.replaceAll(".", "---"), value.toMap()))
    };
  }

  factory GroupMembers.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> mapMembers = map[membersKey] as Map<String, dynamic>;
    Map<String, GroupMember> members = mapMembers.map((key, value) =>
        MapEntry(key.replaceAll("---", "."), GroupMember.fromMap(value)));
    return GroupMembers(members: members);
  }
}

class GroupMember {
  final String memberId;
  final String primaryLanguageName;
  final String? secondaryLanguageName;
  final String? primaryLanguageSubInfo;
  final String? secondaryLanguageSubInfo;
  final int numOfUnreadMessages;
  final String? memberPhone;
  final String memberImage;
  final List<bool> isMember;
  final List<Timestamp> timestamps;
  final String? categoryId;

  const GroupMember(
      {required this.memberId,
      required this.primaryLanguageName,
      required this.secondaryLanguageName,
      required this.primaryLanguageSubInfo,
      required this.secondaryLanguageSubInfo,
      required this.memberPhone,
      required this.memberImage,
      required this.isMember,
      required this.categoryId,
      required this.timestamps,
      required this.numOfUnreadMessages});

  static const String memberIdKey = 'Member_Id';
  static const String primaryLanguageNameKey = 'Primary_Language_Name';
  static const String secondaryLanguageNameKey = 'Secondary_Language_Name';
  static const String primaryLanguageSubInfoKey = 'Primary_Language_Sub_Info';
  static const String secondaryLanguageSubInfoKey =
      'Secondary_Language_Sub_Info';
  static const String memberPhoneKey = 'Member_Phone';
  static const String memberImageKey = 'Member_Image';
  static const String isMemberKey = 'Is_Member';
  static const String timestampsKey = 'Timestamps';
  static const String numOfUnreadMessagesKey = 'Num_Of_Unread_Messages';
  static const String categoryIdKey = 'Category_Id';

  Map<String, dynamic> toMap() {
    return {
      memberIdKey: memberId,
      primaryLanguageNameKey: primaryLanguageName,
      secondaryLanguageNameKey: secondaryLanguageName,
      primaryLanguageSubInfoKey: primaryLanguageSubInfo,
      secondaryLanguageSubInfoKey: secondaryLanguageSubInfo,
      memberPhoneKey: memberPhone,
      memberImageKey: memberImage,
      isMemberKey: isMember,
      timestampsKey: timestamps,
      numOfUnreadMessagesKey: numOfUnreadMessages,
      categoryIdKey: categoryId,
    };
  }
  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      memberId: map[memberIdKey] as String,
      primaryLanguageName: map[primaryLanguageNameKey] as String,
      secondaryLanguageName: map[secondaryLanguageNameKey] as String?,
      primaryLanguageSubInfo: map[primaryLanguageSubInfoKey] as String?,
      secondaryLanguageSubInfo: map[secondaryLanguageSubInfoKey] as String?,
      memberPhone: map[memberPhoneKey] as String?,
      memberImage: map[memberImageKey] as String? ?? '',
      isMember: List<bool>.from(map[isMemberKey] as List),
      timestamps: List<Timestamp>.from(map[timestampsKey] as List),
      numOfUnreadMessages: map[numOfUnreadMessagesKey] as int? ?? 0,
      categoryId: map[categoryIdKey] as String?,
    );
  }

  GroupMember copyWith({
    String? memberId,
    String? primaryLanguageName,
    String? secondaryLanguageName,
    String? primaryLanguageSubInfo,
    String? secondaryLanguageSubInfo,
    int? numOfUnreadMessages,
    String? memberPhone,
    String? memberImage,
    List<bool>? isMember,
    List<Timestamp>? timestamps,
    String? categoryId,
  }) {
    return GroupMember(
      memberId: memberId ?? this.memberId,
      primaryLanguageName: primaryLanguageName ?? this.primaryLanguageName,
      secondaryLanguageName:
          secondaryLanguageName ?? this.secondaryLanguageName,
      primaryLanguageSubInfo:
          primaryLanguageSubInfo ?? this.primaryLanguageSubInfo,
      secondaryLanguageSubInfo:
          secondaryLanguageSubInfo ?? this.secondaryLanguageSubInfo,
      numOfUnreadMessages: numOfUnreadMessages ?? this.numOfUnreadMessages,
      memberPhone: memberPhone ?? this.memberPhone,
      memberImage: memberImage ?? this.memberImage,
      isMember: isMember ?? this.isMember,
      timestamps: timestamps ?? this.timestamps,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
