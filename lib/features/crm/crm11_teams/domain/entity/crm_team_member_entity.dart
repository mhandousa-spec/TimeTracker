// ****************** FILE INFO ******************
// File Name: crm_team_member_entity.dart
// Purpose: Pure Dart domain entity representing a team manager or member.
//          Includes CrmTeamManagerRules backed by the shared RoleKeywords constants.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/constants/role_keywords.dart';

/// Business rules that determine whether an employee is eligible to manage a team.
///
/// Eligible roles:
/// 1.  Chief Executive Officer (CEO)
/// 2.  Chief Operating Officer (COO)
/// 3.  Chief Financial Officer (CFO)
/// 4.  Chief Technology Officer (CTO)
/// 5.  Chief Human Resources Officer (CHRO)
/// 6.  Chief Marketing Officer (CMO)
/// 7.  Chief Sales Officer (CSO)
/// 8.  Chief Data Officer (CDO)
/// 9.  Chief Compliance Officer (CCO)
/// 10. Chief Customer Experience Officer (CXO)
/// 11. Any job title containing "manager" or "manger" (case-insensitive).
abstract class CrmTeamManagerRules {
  static bool isEligibleManager(String role) {
    final String clean = role.trim().toLowerCase();
    if (clean.isEmpty) return false;

    // Reuse the shared leadership keywords (includes 'manager', 'chief', etc.)
    for (final String keyword in RoleKeywords.leadership) {
      if (clean.contains(keyword.toLowerCase())) return true;
    }

    // Explicit C-level abbreviation check (e.g. "CEO", "CTO" as standalone)
    for (final String abbr in _cLevelAbbreviations) {
      if (clean == abbr || clean.contains('($abbr)') || clean.endsWith(' $abbr')) {
        return true;
      }
    }
    return false;
  }

  static const List<String> _cLevelAbbreviations = <String>[
    'ceo', 'coo', 'cfo', 'cto', 'chro', 'cmo', 'cso', 'cdo', 'cco', 'cxo',
  ];
}

class CrmTeamMemberEntity {
  final String id;
  final String name;
  final String role;
  final String department;
  final String phone;
  final String email;
  final String? avatarUrl;

  const CrmTeamMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    this.department = '',
    this.phone = '',
    this.email = '',
    this.avatarUrl,
  });

  /// Returns true if this employee is eligible to be a Team Manager.
  bool get isManagerEligible => CrmTeamManagerRules.isEligibleManager(role);
}
