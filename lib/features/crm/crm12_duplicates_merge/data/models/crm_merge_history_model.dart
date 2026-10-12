// ****************** FILE INFO ******************
// File Name: crm_merge_history_model.dart
// Purpose: Data model for merge history audit record with serialization
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/entity/crm_merge_history_entity.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmMergeHistoryModel extends CrmMergeHistoryEntity {
  const CrmMergeHistoryModel({
    required super.id,
    required super.masterClientId,
    required super.masterClientName,
    required super.mergedClientId,
    required super.mergedClientName,
    super.mergedClientIds = const <String>[],
    required super.mergedBy,
    required super.mergedAt,
    required super.fieldsUpdated,
    super.dealsTransferred = 0,
    super.activitiesTransferred = 0,
    super.isRolledBack = false,
    super.rolledBackAt,
    super.rolledBackBy,
    super.undoExpiresAt,
    super.snapshot = const <Map<String, dynamic>>[],
    super.mergedRecordSnapshot = const <String, dynamic>{},
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'masterClientId': masterClientId,
        'masterClientName': masterClientName,
        'mergedClientId': mergedClientId,
        'mergedClientName': mergedClientName,
        CrmFirestoreKeys.MERGED_CLIENT_IDS_KEY: mergedClientIds,
        'mergedBy': mergedBy,
        'mergedAt': mergedAt.toIso8601String(),
        'fieldsUpdated': fieldsUpdated,
        'dealsTransferred': dealsTransferred,
        'activitiesTransferred': activitiesTransferred,
        'isRolledBack': isRolledBack,
        if (rolledBackAt != null)
          'rolledBackAt': rolledBackAt!.toIso8601String(),
        if (rolledBackBy != null) 'rolledBackBy': rolledBackBy,
        if (undoExpiresAt != null)
          CrmFirestoreKeys.UNDO_EXPIRES_AT_KEY:
              undoExpiresAt!.toIso8601String(),
        CrmFirestoreKeys.SNAPSHOT_KEY: snapshot,
        CrmFirestoreKeys.MERGED_RECORD_SNAPSHOT_KEY: mergedRecordSnapshot,
      };

  factory CrmMergeHistoryModel.fromMap(Map<String, dynamic> map) {
    return CrmMergeHistoryModel(
      id: map['id']?.toString() ?? '',
      masterClientId: map['masterClientId']?.toString() ?? '',
      masterClientName: map['masterClientName']?.toString() ?? '',
      mergedClientId: map['mergedClientId']?.toString() ?? '',
      mergedClientName: map['mergedClientName']?.toString() ?? '',
      mergedClientIds: List<String>.from(
        map[CrmFirestoreKeys.MERGED_CLIENT_IDS_KEY] as List? ??
            const <String>[],
      ),
      mergedBy: map['mergedBy']?.toString() ?? 'Admin',
      mergedAt: map['mergedAt'] != null
          ? DateTime.tryParse(map['mergedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      fieldsUpdated:
          (map['fieldsUpdated'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      dealsTransferred: (map['dealsTransferred'] as num?)?.toInt() ?? 0,
      activitiesTransferred:
          (map['activitiesTransferred'] as num?)?.toInt() ?? 0,
      isRolledBack: map['isRolledBack'] as bool? ?? false,
      rolledBackAt: map['rolledBackAt'] != null
          ? DateTime.tryParse(map['rolledBackAt'].toString())
          : null,
      rolledBackBy: map['rolledBackBy']?.toString(),
      undoExpiresAt: map[CrmFirestoreKeys.UNDO_EXPIRES_AT_KEY] == null
          ? null
          : DateTime.tryParse(
              map[CrmFirestoreKeys.UNDO_EXPIRES_AT_KEY].toString()),
      snapshot: (map[CrmFirestoreKeys.SNAPSHOT_KEY] as List? ??
              const <dynamic>[])
          .whereType<Map>()
          .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
          .toList(),
      mergedRecordSnapshot: Map<String, dynamic>.from(
        map[CrmFirestoreKeys.MERGED_RECORD_SNAPSHOT_KEY] as Map? ??
            const <String, dynamic>{},
      ),
    );
  }

  CrmMergeHistoryModel copyWith({
    String? id,
    String? masterClientId,
    String? masterClientName,
    String? mergedClientId,
    String? mergedClientName,
    List<String>? mergedClientIds,
    String? mergedBy,
    DateTime? mergedAt,
    List<String>? fieldsUpdated,
    int? dealsTransferred,
    int? activitiesTransferred,
    bool? isRolledBack,
    DateTime? rolledBackAt,
    String? rolledBackBy,
    DateTime? undoExpiresAt,
    List<Map<String, dynamic>>? snapshot,
    Map<String, dynamic>? mergedRecordSnapshot,
  }) {
    return CrmMergeHistoryModel(
      id: id ?? this.id,
      masterClientId: masterClientId ?? this.masterClientId,
      masterClientName: masterClientName ?? this.masterClientName,
      mergedClientId: mergedClientId ?? this.mergedClientId,
      mergedClientName: mergedClientName ?? this.mergedClientName,
      mergedClientIds: mergedClientIds ?? this.mergedClientIds,
      mergedBy: mergedBy ?? this.mergedBy,
      mergedAt: mergedAt ?? this.mergedAt,
      fieldsUpdated: fieldsUpdated ?? this.fieldsUpdated,
      dealsTransferred: dealsTransferred ?? this.dealsTransferred,
      activitiesTransferred:
          activitiesTransferred ?? this.activitiesTransferred,
      isRolledBack: isRolledBack ?? this.isRolledBack,
      rolledBackAt: rolledBackAt ?? this.rolledBackAt,
      rolledBackBy: rolledBackBy ?? this.rolledBackBy,
      undoExpiresAt: undoExpiresAt ?? this.undoExpiresAt,
      snapshot: snapshot ?? this.snapshot,
      mergedRecordSnapshot: mergedRecordSnapshot ?? this.mergedRecordSnapshot,
    );
  }
}
