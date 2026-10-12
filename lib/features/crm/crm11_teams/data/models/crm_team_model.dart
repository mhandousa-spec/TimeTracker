// ****************** FILE INFO ******************
// File Name: crm_team_model.dart
// Purpose: Main CRM Team model with serialization and validation logic.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_condition_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/entity/crm_team_entity.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/enums/crm_team_status_enum.dart';

class CrmTeamModel extends CrmTeamEntity {
  static const String ID = 'id';
  static const String TEAM_TYPE = 'teamType';
  static const String NAME_EN = 'nameEn';
  static const String NAME_AR = 'nameAr';
  static const String MANAGER = 'manager';
  static const String MEMBERS = 'members';
  static const String NOTE_EN = 'noteEn';
  static const String NOTE_AR = 'noteAr';
  static const String CONDITIONS = 'conditions';
  static const String STATUS = 'status';
  static const String CREATED_AT = 'createdAt';
  static const String UPDATED_AT = 'updatedAt';

  const CrmTeamModel({
    required super.id,
    required super.teamType,
    required super.nameEn,
    required super.nameAr,
    super.manager,
    super.members = const <CrmTeamMemberModel>[],
    super.noteEn = '',
    super.noteAr = '',
    super.conditions = const <CrmTeamConditionModel>[],
    super.status = CrmTeamStatus.active,
    required super.createdAt,
    required super.updatedAt,
  });

  bool get isActive => status == CrmTeamStatus.active;
  bool get isInactive => status == CrmTeamStatus.inactive;
  String get displayName => nameEn.isNotEmpty ? nameEn : nameAr;
  int get membersCount => members.length;

  /// Returns condition value for a given category (or 'Choose' / empty).
  String getConditionValue(String category) {
    for (final condition in conditions) {
      if (condition.category.toLowerCase() == category.toLowerCase()) {
        return condition.value;
      }
    }
    return 'Choose';
  }

  /// Returns condition priority for a given category.
  String getConditionPriority(String category) {
    for (final condition in conditions) {
      if (condition.category.toLowerCase() == category.toLowerCase()) {
        return condition.priority;
      }
    }
    return 'Choose';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ID: id,
      TEAM_TYPE: teamType,
      NAME_EN: nameEn,
      NAME_AR: nameAr,
      MANAGER: manager != null
          ? (manager is CrmTeamMemberModel
              ? (manager as CrmTeamMemberModel).toMap()
              : CrmTeamMemberModel.fromEntity(manager!).toMap())
          : null,
      MEMBERS: members
          .map((m) => m is CrmTeamMemberModel
              ? m.toMap()
              : CrmTeamMemberModel.fromEntity(m).toMap())
          .toList(),
      NOTE_EN: noteEn,
      NOTE_AR: noteAr,
      CONDITIONS: conditions
          .map((c) => c is CrmTeamConditionModel
              ? c.toMap()
              : CrmTeamConditionModel.fromEntity(c).toMap())
          .toList(),
      STATUS: status.code,
      CREATED_AT: createdAt.toIso8601String(),
      UPDATED_AT: updatedAt.toIso8601String(),
    };
  }

  factory CrmTeamModel.fromMap(Map<String, dynamic> map) {
    CrmTeamMemberModel? mgr;
    if (map[MANAGER] is Map<String, dynamic>) {
      mgr = CrmTeamMemberModel.fromMap(map[MANAGER] as Map<String, dynamic>);
    }

    final List<CrmTeamMemberModel> mbrs = <CrmTeamMemberModel>[];
    if (map[MEMBERS] is List) {
      for (final dynamic item in map[MEMBERS] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          mbrs.add(CrmTeamMemberModel.fromMap(item));
        }
      }
    }

    final List<CrmTeamConditionModel> conds = <CrmTeamConditionModel>[];
    if (map[CONDITIONS] is List) {
      for (final dynamic item in map[CONDITIONS] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          conds.add(CrmTeamConditionModel.fromMap(item));
        }
      }
    }

    return CrmTeamModel(
      id: map[ID]?.toString() ?? '',
      teamType: map[TEAM_TYPE]?.toString() ?? 'Sales',
      nameEn: map[NAME_EN]?.toString() ?? '',
      nameAr: map[NAME_AR]?.toString() ?? '',
      manager: mgr,
      members: mbrs,
      noteEn: map[NOTE_EN]?.toString() ?? '',
      noteAr: map[NOTE_AR]?.toString() ?? '',
      conditions: conds,
      status: CrmTeamStatus.fromString(map[STATUS]?.toString()),
      createdAt: map[CREATED_AT] != null
          ? DateTime.tryParse(map[CREATED_AT].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map[UPDATED_AT] != null
          ? DateTime.tryParse(map[UPDATED_AT].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CrmTeamModel copyWith({
    String? id,
    String? teamType,
    String? nameEn,
    String? nameAr,
    CrmTeamMemberModel? manager,
    List<CrmTeamMemberModel>? members,
    String? noteEn,
    String? noteAr,
    List<CrmTeamConditionModel>? conditions,
    CrmTeamStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CrmTeamModel(
      id: id ?? this.id,
      teamType: teamType ?? this.teamType,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      manager: manager ?? (this.manager as CrmTeamMemberModel?),
      members: members ??
          this.members.map((m) => CrmTeamMemberModel.fromEntity(m)).toList(),
      noteEn: noteEn ?? this.noteEn,
      noteAr: noteAr ?? this.noteAr,
      conditions: conditions ??
          this
              .conditions
              .map((c) => CrmTeamConditionModel.fromEntity(c))
              .toList(),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
