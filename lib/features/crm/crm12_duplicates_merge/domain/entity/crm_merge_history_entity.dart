// ****************** FILE INFO ******************
// File Name: crm_merge_history_entity.dart
// Purpose: Pure Dart domain entity representing a merge history audit record
// Author: Mohand Adel
// Created At: 27/08/2026

class CrmMergeHistoryEntity {
  final String id;
  final String masterClientId;
  final String masterClientName;
  final String mergedClientId;
  final String mergedClientName;
  final List<String> mergedClientIds;
  final String mergedBy;
  final DateTime mergedAt;
  final List<String> fieldsUpdated;
  final int dealsTransferred;
  final int activitiesTransferred;
  final bool isRolledBack;
  final DateTime? rolledBackAt;
  final String? rolledBackBy;
  final DateTime? undoExpiresAt;
  final List<Map<String, dynamic>> snapshot;
  final Map<String, dynamic> mergedRecordSnapshot;

  const CrmMergeHistoryEntity({
    required this.id,
    required this.masterClientId,
    required this.masterClientName,
    required this.mergedClientId,
    required this.mergedClientName,
    this.mergedClientIds = const <String>[],
    required this.mergedBy,
    required this.mergedAt,
    required this.fieldsUpdated,
    this.dealsTransferred = 0,
    this.activitiesTransferred = 0,
    this.isRolledBack = false,
    this.rolledBackAt,
    this.rolledBackBy,
    this.undoExpiresAt,
    this.snapshot = const <Map<String, dynamic>>[],
    this.mergedRecordSnapshot = const <String, dynamic>{},
  });
}
