/// Module: messaging / groups / domain/entity/member_entity.dart
/// ************************* FILE INFO *************************** ///
/// File Name: member_entity.dart
/// Purpose: Member entity — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:cloud_firestore_platform_interface/src/timestamp.dart';

import 'package:knowticed_plus/core/helper/message_module/main_helper/localized_text_helper.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../data/models/group_members.dart';

class MemberEntity {
  final String memberId;
  final String primaryLanguageName;
  final String? secondaryLanguageName;
  final String? primaryLanguageSubInfo;
  final String? secondaryLanguageSubInfo;

  /// Transient UI selection state (toggled in place by GroupsCubit); kept
  /// mutable on purpose since selection uses reference identity.
  bool isSelected;
  final UserCategory? category;
  final String? memberPhone;
  final String memberImage;
  final int numOfUnreadMessages;
  final Timestamp? addedTime;
  final bool isAdmin;

  MemberEntity({
    this.category,
    required this.memberId,
    required this.primaryLanguageName,
    required this.secondaryLanguageName,
    required this.primaryLanguageSubInfo,
    required this.secondaryLanguageSubInfo,
    required this.memberPhone,
    required this.memberImage,
    required this.numOfUnreadMessages,
    required this.addedTime,
    required this.isAdmin,
    this.isSelected = false,
  });

  GroupMember toMemberModel({required Timestamp time, required bool status}) {
    return GroupMember(
      memberId: memberId,
      categoryId: category?.categoryId,
      primaryLanguageName: primaryLanguageName,
      secondaryLanguageName: secondaryLanguageName,
      primaryLanguageSubInfo: primaryLanguageSubInfo,
      secondaryLanguageSubInfo: secondaryLanguageSubInfo,
      memberPhone: memberPhone,
      memberImage: memberImage,
      numOfUnreadMessages: numOfUnreadMessages,
      isMember: [status],
      timestamps: [time],
    );
  }

  MemberEntity.fromSingleConnectionEntity(SingleConnectionEntity connection)
      : memberId = connection.userId,
        primaryLanguageName = connection.primaryLanguageName,
        secondaryLanguageName = connection.secondaryLanguageName,
        primaryLanguageSubInfo = connection.primaryLanguageSubInfo,
        secondaryLanguageSubInfo = connection.secondaryLanguageSubInfo,
        category = connection.userCategory,
        memberPhone = connection.phone,
        memberImage = connection.imageUri,
        isAdmin = false,
        numOfUnreadMessages = 0,
        addedTime = null,
        isSelected = false;

  /// Pure lookup — categories are passed in by the caller (no GetX / no
  /// presentation dependency). Domain depends on nothing (§3).
  static UserCategory? _resolveCategory(
      String? categoryId, List<UserCategory>? categories) {
    if (categoryId == null || categories == null) return null;
    for (final cat in categories) {
      if (cat.categoryId.toLowerCase() == categoryId.toLowerCase()) return cat;
    }
    return null;
  }

  MemberEntity.fromModel(
    GroupMember member,
    bool admin, {
    List<UserCategory>? categories,
  })  : memberId = member.memberId,
        primaryLanguageName = member.primaryLanguageName,
        secondaryLanguageName = member.secondaryLanguageName,
        primaryLanguageSubInfo = member.primaryLanguageSubInfo,
        secondaryLanguageSubInfo = member.secondaryLanguageSubInfo,
        category = _resolveCategory(member.categoryId, categories),
        memberPhone = member.memberPhone,
        memberImage = member.memberImage,
        numOfUnreadMessages = member.numOfUnreadMessages,
        isSelected = false,
        isAdmin = admin,
        addedTime = member.timestamps.last;

  MemberEntity copyWith({
    String? memberId,
    String? primaryLanguageName,
    String? secondaryLanguageName,
    String? primaryLanguageSubInfo,
    String? secondaryLanguageSubInfo,
    bool? isSelected,
    UserCategory? category,
    String? memberPhone,
    String? memberImage,
    int? numOfUnreadMessages,
    Timestamp? addedTime,
    bool? isAdmin,
  }) {
    return MemberEntity(
      memberId: memberId ?? this.memberId,
      primaryLanguageName: primaryLanguageName ?? this.primaryLanguageName,
      secondaryLanguageName:
          secondaryLanguageName ?? this.secondaryLanguageName,
      primaryLanguageSubInfo:
          primaryLanguageSubInfo ?? this.primaryLanguageSubInfo,
      secondaryLanguageSubInfo:
          secondaryLanguageSubInfo ?? this.secondaryLanguageSubInfo,
      isSelected: isSelected ?? this.isSelected,
      category: category ?? this.category,
      memberPhone: memberPhone ?? this.memberPhone,
      memberImage: memberImage ?? this.memberImage,
      numOfUnreadMessages: numOfUnreadMessages ?? this.numOfUnreadMessages,
      addedTime: addedTime ?? this.addedTime,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  String get fullName {
    return LocalizedTextHelper.formatString(
        secondaryLanguageText: secondaryLanguageName,
        primaryLanguageText: primaryLanguageName);
  }
  String get departmentName {
    if (category != null) {
      return LocalizedTextHelper.formatString(
        secondaryLanguageText: category?.secondaryLanguageName,
        primaryLanguageText: category?.primaryLanguageName ?? '',
      );
    }
    // Category is resolved at construction from the passed-in categories list;
    // no presentation/GetX fallback here (domain stays pure, §3).
    return '';
  }

  String get subInfo {
    return LocalizedTextHelper.formatString(
      secondaryLanguageText: secondaryLanguageSubInfo,
      primaryLanguageText: primaryLanguageSubInfo ?? '',
    );
  }
}