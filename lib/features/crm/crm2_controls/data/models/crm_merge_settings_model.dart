// ****************** FILE INFO ******************
// File Name: crm_merge_settings_model.dart
// Purpose: Stores tenant-wide CRM merge undo configuration.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_matching_rule_model.dart';

enum MergeDurationUnit { minutes, hours, days, weeks, months, years }

class CrmMergeSettingsModel {
  static const String documentId = 'default';

  final bool undoEnabled;
  final int durationValue;
  final MergeDurationUnit durationUnit;
  final List<CrmMergeMatchingRuleModel> matchingRules;
  final CrmAuditModel? audit;

  const CrmMergeSettingsModel({
    this.undoEnabled = true,
    this.durationValue = 1,
    this.durationUnit = MergeDurationUnit.days,
    this.matchingRules = const <CrmMergeMatchingRuleModel>[],
    this.audit,
  });

  factory CrmMergeSettingsModel.defaults() => const CrmMergeSettingsModel();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CrmFirestoreKeys.UNDO_ENABLED_KEY: undoEnabled,
      CrmFirestoreKeys.DURATION_VALUE_KEY: durationValue,
      CrmFirestoreKeys.DURATION_UNIT_KEY: durationUnit.name,
      CrmFirestoreKeys.MATCHING_RULES_KEY: matchingRules
          .map((CrmMergeMatchingRuleModel rule) => rule.toMap())
          .toList(),
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
    };
  }

  factory CrmMergeSettingsModel.fromMap(Map<String, dynamic> map) {
    final String unitName = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.DURATION_UNIT_KEY,
              'durationUnit',
            ) ??
            MergeDurationUnit.days.name)
        .toString();
    return CrmMergeSettingsModel(
      undoEnabled: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.UNDO_ENABLED_KEY,
            'undoEnabled',
          ) !=
          false,
      durationValue: _readDurationValue(
        CrmFirestoreKeys.read(
          map,
          CrmFirestoreKeys.DURATION_VALUE_KEY,
          'durationValue',
        ),
      ),
      durationUnit: MergeDurationUnit.values.firstWhere(
        (MergeDurationUnit unit) => unit.name == unitName,
        orElse: () => MergeDurationUnit.days,
      ),
      matchingRules: ((CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.MATCHING_RULES_KEY,
                'matchingRules',
              ) as List?) ??
              const <dynamic>[])
          .whereType<Map>()
          .map(
              (Map<dynamic, dynamic> item) => CrmMergeMatchingRuleModel.fromMap(
                    Map<String, dynamic>.from(item),
                  ))
          .toList(),
      audit: CrmFirestoreKeys.read(map, CrmFirestoreKeys.AUDIT_KEY, 'audit')
              is Map<String, dynamic>
          ? CrmAuditModel.fromMap(
              CrmFirestoreKeys.read(map, CrmFirestoreKeys.AUDIT_KEY, 'audit')
                  as Map<String, dynamic>,
            )
          : null,
    );
  }

  CrmMergeSettingsModel copyWith({
    bool? undoEnabled,
    int? durationValue,
    MergeDurationUnit? durationUnit,
    List<CrmMergeMatchingRuleModel>? matchingRules,
    CrmAuditModel? audit,
  }) {
    return CrmMergeSettingsModel(
      undoEnabled: undoEnabled ?? this.undoEnabled,
      durationValue: durationValue ?? this.durationValue,
      durationUnit: durationUnit ?? this.durationUnit,
      matchingRules: matchingRules ?? this.matchingRules,
      audit: audit ?? this.audit,
    );
  }

  static int _readDurationValue(dynamic value) {
    final int parsed = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 1;
    return parsed.clamp(1, 999999);
  }
}
