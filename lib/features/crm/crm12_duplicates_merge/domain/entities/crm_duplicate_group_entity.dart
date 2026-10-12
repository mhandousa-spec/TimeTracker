// ****************** FILE INFO ******************
// File Name: crm_duplicate_group_entity.dart
// Purpose: Defines a connected set of potential duplicate client records.
// Author: Mohand Adel
// Created At: 28/08/2026

class CrmMergeMatchRecord {
  final String id;
  final String templateId;
  final Map<String, dynamic> values;
  final String displayName;
  final String displayNameAr;
  final String email;
  final String phone;
  final String company;
  final String clientTypeId;
  final DateTime? createdAt;

  const CrmMergeMatchRecord({
    required this.id,
    required this.templateId,
    required this.values,
    this.displayName = '',
    this.displayNameAr = '',
    this.email = '',
    this.phone = '',
    this.company = '',
    this.clientTypeId = '',
    this.createdAt,
  });

  dynamic valueFor(String fieldId, String systemKey) {
    if (values.containsKey(fieldId)) return values[fieldId];
    if (systemKey.isNotEmpty && values.containsKey(systemKey)) {
      return values[systemKey];
    }
    for (final MapEntry<String, dynamic> entry in values.entries) {
      if (systemKey.isNotEmpty && entry.key.endsWith('_$systemKey')) {
        return entry.value;
      }
    }
    return null;
  }
}

enum CrmMergeMatchComparisonType { exact, fuzzy, ignore }

class CrmMergeMatchRule {
  final String fieldId;
  final String templateId;
  final String systemKey;
  final int weight;
  final CrmMergeMatchComparisonType comparisonType;
  final bool isIdentity;
  final bool isEnabled;

  const CrmMergeMatchRule({
    required this.fieldId,
    required this.templateId,
    required this.weight,
    this.systemKey = '',
    this.comparisonType = CrmMergeMatchComparisonType.exact,
    this.isIdentity = false,
    this.isEnabled = true,
  });
}

class CrmDuplicatePairMatchEntity {
  final String firstRecordId;
  final String secondRecordId;
  final int score;
  final List<String> reasons;

  const CrmDuplicatePairMatchEntity({
    required this.firstRecordId,
    required this.secondRecordId,
    required this.score,
    required this.reasons,
  });
}

class CrmDuplicateGroupEntity {
  final String id;
  final List<CrmMergeMatchRecord> records;
  final List<CrmDuplicatePairMatchEntity> pairMatches;
  final DateTime detectedAt;

  const CrmDuplicateGroupEntity({
    required this.id,
    required this.records,
    required this.pairMatches,
    required this.detectedAt,
  });
}
