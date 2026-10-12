// ****************** FILE INFO ******************
// File Name: crm_duplicate_pair_model.dart
// Purpose: Data model for duplicate client pair with serialization and entity mapping
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/entity/crm_duplicate_pair_entity.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/enums/crm_duplicates_enums.dart';

class CrmDuplicateClientInfoModel extends CrmDuplicateClientInfoEntity {
  const CrmDuplicateClientInfoModel({
    required super.id,
    required super.name,
    super.nameAr = '',
    required super.email,
    required super.phone,
    required super.company,
    required super.clientType,
    super.address = '',
    super.avatarUrl = '',
    super.note = '',
    super.activeDealsCount = 0,
    super.activitiesCount = 0,
    required super.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'email': email,
        'phone': phone,
        'company': company,
        'clientType': clientType,
        'address': address,
        'avatarUrl': avatarUrl,
        'note': note,
        'activeDealsCount': activeDealsCount,
        'activitiesCount': activitiesCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CrmDuplicateClientInfoModel.fromMap(Map<String, dynamic> map) {
    return CrmDuplicateClientInfoModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      nameAr: map['nameAr']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      clientType: map['clientType']?.toString() ?? 'Individual',
      address: map['address']?.toString() ?? '',
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      activeDealsCount: (map['activeDealsCount'] as num?)?.toInt() ?? 0,
      activitiesCount: (map['activitiesCount'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CrmDuplicateClientInfoModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? email,
    String? phone,
    String? company,
    String? clientType,
    String? address,
    String? avatarUrl,
    String? note,
    int? activeDealsCount,
    int? activitiesCount,
    DateTime? createdAt,
  }) {
    return CrmDuplicateClientInfoModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      clientType: clientType ?? this.clientType,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      note: note ?? this.note,
      activeDealsCount: activeDealsCount ?? this.activeDealsCount,
      activitiesCount: activitiesCount ?? this.activitiesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CrmDuplicatePairModel extends CrmDuplicatePairEntity {
  const CrmDuplicatePairModel({
    required super.id,
    required CrmDuplicateClientInfoModel super.record1,
    required CrmDuplicateClientInfoModel super.record2,
    required super.matchScore,
    required super.matchLevel,
    super.mergeLevelId = '',
    super.mergeLevelName = '',
    super.mergeLevelColorHex = '',
    required super.matchReasons,
    super.status = CrmDuplicateStatus.pending,
    required super.detectedAt,
  });

  @override
  CrmDuplicateClientInfoModel get record1 =>
      super.record1 as CrmDuplicateClientInfoModel;

  @override
  CrmDuplicateClientInfoModel get record2 =>
      super.record2 as CrmDuplicateClientInfoModel;

  Map<String, dynamic> toMap() => {
        'id': id,
        'record1': record1.toMap(),
        'record2': record2.toMap(),
        'matchScore': matchScore,
        'matchLevel': matchLevel.name,
        'mergeLevelId': mergeLevelId,
        'mergeLevelName': mergeLevelName,
        'mergeLevelColorHex': mergeLevelColorHex,
        'matchReasons': matchReasons,
        'status': status.name,
        'detectedAt': detectedAt.toIso8601String(),
      };

  factory CrmDuplicatePairModel.fromMap(Map<String, dynamic> map) {
    return CrmDuplicatePairModel(
      id: map['id']?.toString() ?? '',
      record1: CrmDuplicateClientInfoModel.fromMap(
        Map<String, dynamic>.from(map['record1'] as Map? ?? {}),
      ),
      record2: CrmDuplicateClientInfoModel.fromMap(
        Map<String, dynamic>.from(map['record2'] as Map? ?? {}),
      ),
      matchScore: (map['matchScore'] as num?)?.toInt() ?? 0,
      matchLevel: CrmDuplicateMatchLevel.values.firstWhere(
        (e) => e.name == map['matchLevel'],
        orElse: () => CrmDuplicateMatchLevel.exact,
      ),
      mergeLevelId: map['mergeLevelId']?.toString() ?? '',
      mergeLevelName: map['mergeLevelName']?.toString() ?? '',
      mergeLevelColorHex: map['mergeLevelColorHex']?.toString() ?? '',
      matchReasons:
          (map['matchReasons'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      status: CrmDuplicateStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CrmDuplicateStatus.pending,
      ),
      detectedAt: map['detectedAt'] != null
          ? DateTime.tryParse(map['detectedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CrmDuplicatePairModel copyWith({
    String? id,
    CrmDuplicateClientInfoModel? record1,
    CrmDuplicateClientInfoModel? record2,
    int? matchScore,
    CrmDuplicateMatchLevel? matchLevel,
    String? mergeLevelId,
    String? mergeLevelName,
    String? mergeLevelColorHex,
    List<String>? matchReasons,
    CrmDuplicateStatus? status,
    DateTime? detectedAt,
  }) {
    return CrmDuplicatePairModel(
      id: id ?? this.id,
      record1: record1 ?? this.record1,
      record2: record2 ?? this.record2,
      matchScore: matchScore ?? this.matchScore,
      matchLevel: matchLevel ?? this.matchLevel,
      mergeLevelId: mergeLevelId ?? this.mergeLevelId,
      mergeLevelName: mergeLevelName ?? this.mergeLevelName,
      mergeLevelColorHex: mergeLevelColorHex ?? this.mergeLevelColorHex,
      matchReasons: matchReasons ?? this.matchReasons,
      status: status ?? this.status,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }
}
