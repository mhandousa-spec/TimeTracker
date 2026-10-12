// ****************** FILE INFO ******************
// File Name: crm_team_status_enum.dart
// Purpose: Enum defining status of a CRM Team.
// Author: Mohand Adel
// Created At: 27/08/2026

enum CrmTeamStatus {
  active('active', 'Active', 'نشط'),
  inactive('inactive', 'Inactive', 'غير نشط');

  final String code;
  final String labelEn;
  final String labelAr;

  const CrmTeamStatus(this.code, this.labelEn, this.labelAr);

  static CrmTeamStatus fromString(String? val) {
    if (val?.toLowerCase() == 'inactive') return CrmTeamStatus.inactive;
    return CrmTeamStatus.active;
  }
}
