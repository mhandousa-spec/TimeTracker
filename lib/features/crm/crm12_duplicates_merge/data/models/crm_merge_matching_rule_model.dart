// ****************** FILE INFO ******************
// File Name: crm_merge_matching_rule_model.dart
// Purpose: Stores central dynamic-field matching rules for CRM duplicate detection.
// Author: Mohand Adel
// Created At: 28/08/2026

enum CrmMergeComparisonType { exact, fuzzy, ignore }

/// A central Merge Controls rule. It deliberately has no section id because
/// sections only organize the merge review UI; they never override matching.
class CrmMergeMatchingRuleModel {
  static const String fieldIdKey = 'Field_Id';
  static const String templateIdKey = 'Template_Id';
  static const String systemKeyKey = 'System_Key';
  static const String weightKey = 'Weight';
  static const String comparisonTypeKey = 'Comparison_Type';
  static const String identityKey = 'Is_Identity';
  static const String enabledKey = 'Is_Enabled';

  final String fieldId;
  final String templateId;
  final String systemKey;
  final int weight;
  final CrmMergeComparisonType comparisonType;
  final bool isIdentity;
  final bool isEnabled;

  const CrmMergeMatchingRuleModel({
    required this.fieldId,
    required this.templateId,
    this.systemKey = '',
    required this.weight,
    this.comparisonType = CrmMergeComparisonType.exact,
    this.isIdentity = false,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        fieldIdKey: fieldId,
        templateIdKey: templateId,
        systemKeyKey: systemKey,
        weightKey: weight,
        comparisonTypeKey: comparisonType.name,
        identityKey: isIdentity,
        enabledKey: isEnabled,
      };

  factory CrmMergeMatchingRuleModel.fromMap(Map<String, dynamic> map) {
    final String typeName = (map[comparisonTypeKey] ?? 'exact').toString();
    return CrmMergeMatchingRuleModel(
      fieldId: (map[fieldIdKey] ?? '').toString(),
      templateId: (map[templateIdKey] ?? '').toString(),
      systemKey: (map[systemKeyKey] ?? '').toString(),
      weight: ((map[weightKey] as num?)?.toInt() ?? 0).clamp(0, 100),
      comparisonType: CrmMergeComparisonType.values.firstWhere(
        (CrmMergeComparisonType type) => type.name == typeName,
        orElse: () => CrmMergeComparisonType.exact,
      ),
      isIdentity: map[identityKey] == true,
      isEnabled: map[enabledKey] != false,
    );
  }

  CrmMergeMatchingRuleModel copyWith({
    String? fieldId,
    String? templateId,
    String? systemKey,
    int? weight,
    CrmMergeComparisonType? comparisonType,
    bool? isIdentity,
    bool? isEnabled,
  }) =>
      CrmMergeMatchingRuleModel(
        fieldId: fieldId ?? this.fieldId,
        templateId: templateId ?? this.templateId,
        systemKey: systemKey ?? this.systemKey,
        weight: weight ?? this.weight,
        comparisonType: comparisonType ?? this.comparisonType,
        isIdentity: isIdentity ?? this.isIdentity,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}
