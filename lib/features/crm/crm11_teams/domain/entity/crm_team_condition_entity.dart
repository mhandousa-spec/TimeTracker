// ****************** FILE INFO ******************
// File Name: crm_team_condition_entity.dart
// Purpose: Pure Dart domain entity for conditions assigned to a team.
// Author: Mohand Adel
// Created At: 27/08/2026

class CrmTeamConditionEntity {
  final String category; // 'Countries', 'Preferred Language', 'Industry', 'Sector'
  final String value;
  final String priority; // 'High', 'Medium', 'Low', 'Choose', etc.

  const CrmTeamConditionEntity({
    required this.category,
    required this.value,
    this.priority = 'Choose',
  });
}
