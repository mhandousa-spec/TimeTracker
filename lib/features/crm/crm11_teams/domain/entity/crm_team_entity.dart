// ****************** FILE INFO ******************
// File Name: crm_team_entity.dart
// Purpose: Pure Dart domain entity for CRM Team.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm11_teams/domain/entity/crm_team_condition_entity.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/entity/crm_team_member_entity.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/enums/crm_team_status_enum.dart';

class CrmTeamEntity {
  final String id;
  final String teamType;
  final String nameEn;
  final String nameAr;
  final CrmTeamMemberEntity? manager;
  final List<CrmTeamMemberEntity> members;
  final String noteEn;
  final String noteAr;
  final List<CrmTeamConditionEntity> conditions;
  final CrmTeamStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CrmTeamEntity({
    required this.id,
    required this.teamType,
    required this.nameEn,
    required this.nameAr,
    this.manager,
    this.members = const <CrmTeamMemberEntity>[],
    this.noteEn = '',
    this.noteAr = '',
    this.conditions = const <CrmTeamConditionEntity>[],
    this.status = CrmTeamStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });
}
