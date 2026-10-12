// ****************** FILE INFO ******************
// File Name: crm_team_member_model.dart
// Purpose: Model representation of a team manager or member with serialization
//          and mapping from the real employee entity (EmployeeEntityPro).
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm11_teams/domain/entity/crm_team_member_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmTeamMemberModel extends CrmTeamMemberEntity {
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String ROLE = 'role';
  static const String DEPARTMENT = 'department';
  static const String PHONE = 'phone';
  static const String EMAIL = 'email';
  static const String AVATAR_URL = 'avatarUrl';

  const CrmTeamMemberModel({
    required super.id,
    required super.name,
    required super.role,
    super.department = '',
    super.phone = '',
    super.email = '',
    super.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ID: id,
      NAME: name,
      ROLE: role,
      DEPARTMENT: department,
      PHONE: phone,
      EMAIL: email,
      AVATAR_URL: avatarUrl,
    };
  }

  factory CrmTeamMemberModel.fromMap(Map<String, dynamic> map) {
    return CrmTeamMemberModel(
      id: map[ID]?.toString() ?? '',
      name: map[NAME]?.toString() ?? '',
      role: map[ROLE]?.toString() ?? '',
      department: map[DEPARTMENT]?.toString() ?? '',
      phone: map[PHONE]?.toString() ?? '',
      email: map[EMAIL]?.toString() ?? '',
      avatarUrl: map[AVATAR_URL]?.toString(),
    );
  }

  factory CrmTeamMemberModel.fromEntity(CrmTeamMemberEntity entity) {
    return CrmTeamMemberModel(
      id: entity.id,
      name: entity.name,
      role: entity.role,
      department: entity.department,
      phone: entity.phone,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
    );
  }

  /// Maps a real [EmployeeEntityPro] from [MainCoreEmployeeController] to a
  /// [CrmTeamMemberModel]. Uses the employee's `title` field as the display
  /// role (falls back to `role` then empty string) and `photo` as avatar.
  factory CrmTeamMemberModel.fromEmployeeEntity(EmployeeEntityPro employee) {
    final String fullName =
        '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim();
    final String phoneStr = employee.mobilePhone?.number ?? '';

    return CrmTeamMemberModel(
      id: employee.id ?? '',
      name: fullName,
      role: employee.title ?? employee.role ?? '',
      department: employee.departmentId ?? '',
      phone: phoneStr,
      email: employee.email ?? '',
      avatarUrl: employee.photo,
    );
  }

  CrmTeamMemberModel copyWith({
    String? id,
    String? name,
    String? role,
    String? department,
    String? phone,
    String? email,
    String? avatarUrl,
  }) {
    return CrmTeamMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
