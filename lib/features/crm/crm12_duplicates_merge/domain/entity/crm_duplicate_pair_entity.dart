// ****************** FILE INFO ******************
// File Name: crm_duplicate_pair_entity.dart
// Purpose: Pure Dart domain entity representing a detected duplicate client pair
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/enums/crm_duplicates_enums.dart';

class CrmDuplicateClientInfoEntity {
  final String id;
  final String name;
  final String nameAr;
  final String email;
  final String phone;
  final String company;
  final String clientType;
  final String address;
  final String avatarUrl;
  final String note;
  final int activeDealsCount;
  final int activitiesCount;
  final DateTime createdAt;

  const CrmDuplicateClientInfoEntity({
    required this.id,
    required this.name,
    this.nameAr = '',
    required this.email,
    required this.phone,
    required this.company,
    required this.clientType,
    this.address = '',
    this.avatarUrl = '',
    this.note = '',
    this.activeDealsCount = 0,
    this.activitiesCount = 0,
    required this.createdAt,
  });
}

class CrmDuplicatePairEntity {
  final String id;
  final CrmDuplicateClientInfoEntity record1;
  final CrmDuplicateClientInfoEntity record2;
  final int matchScore; // e.g. 98%
  final CrmDuplicateMatchLevel matchLevel;
  final String mergeLevelId;
  final String mergeLevelName;
  final String mergeLevelColorHex;
  final List<String>
      matchReasons; // e.g. ['Matching Phone Number', 'Similar Name']
  final CrmDuplicateStatus status;
  final DateTime detectedAt;

  const CrmDuplicatePairEntity({
    required this.id,
    required this.record1,
    required this.record2,
    required this.matchScore,
    required this.matchLevel,
    this.mergeLevelId = '',
    this.mergeLevelName = '',
    this.mergeLevelColorHex = '',
    required this.matchReasons,
    this.status = CrmDuplicateStatus.pending,
    required this.detectedAt,
  });
}
