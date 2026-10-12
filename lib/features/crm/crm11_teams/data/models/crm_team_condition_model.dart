// ****************** FILE INFO ******************
// File Name: crm_team_condition_model.dart
// Purpose: Model representation of a team condition with serialization.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm11_teams/domain/entity/crm_team_condition_entity.dart';

class CrmTeamConditionModel extends CrmTeamConditionEntity {
  static const String CATEGORY = 'category';
  static const String VALUE = 'value';
  static const String PRIORITY = 'priority';

  const CrmTeamConditionModel({
    required super.category,
    required super.value,
    super.priority = 'Choose',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CATEGORY: category,
      VALUE: value,
      PRIORITY: priority,
    };
  }

  factory CrmTeamConditionModel.fromMap(Map<String, dynamic> map) {
    return CrmTeamConditionModel(
      category: map[CATEGORY]?.toString() ?? '',
      value: map[VALUE]?.toString() ?? '',
      priority: map[PRIORITY]?.toString() ?? 'Choose',
    );
  }

  factory CrmTeamConditionModel.fromEntity(CrmTeamConditionEntity entity) {
    return CrmTeamConditionModel(
      category: entity.category,
      value: entity.value,
      priority: entity.priority,
    );
  }

  CrmTeamConditionModel copyWith({
    String? category,
    String? value,
    String? priority,
  }) {
    return CrmTeamConditionModel(
      category: category ?? this.category,
      value: value ?? this.value,
      priority: priority ?? this.priority,
    );
  }
}
