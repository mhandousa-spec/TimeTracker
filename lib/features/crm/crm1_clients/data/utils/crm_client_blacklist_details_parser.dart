// ****************** FILE INFO ******************
// File Name: crm_client_blacklist_details_parser.dart
// Purpose: Reads current and legacy blacklist metadata shapes from client records
// Author: Mohand Adel
// Created At: 26/08/2026

abstract class CrmClientBlacklistDetailsParser {
  static Map<String, dynamic> fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> details = Map<String, dynamic>.from(
      map['Blacklist_Details'] as Map? ?? const {},
    );
    if (details.isNotEmpty) return details;
    for (final String key in <String>[
      'Reason',
      'Requested_At',
      'Requested_By',
      'Removal_Reason',
      'Removal_Requested_At',
      'Removal_Requested_By',
      'Removal_Status',
    ]) {
      final String legacyKey = 'Blacklist_Details.$key';
      if (map.containsKey(legacyKey)) details[key] = map[legacyKey];
    }
    return details;
  }
}
