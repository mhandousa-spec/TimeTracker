// ****************** FILE INFO ******************
// File Name: crm_duplicate_matching_engine.dart
// Purpose: Calculates central-rule duplicate scores and connected record groups.
// Author: Mohand Adel
// Created At: 28/08/2026

import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/entities/crm_duplicate_group_entity.dart';

class CrmDuplicateMatchingEngine {
  const CrmDuplicateMatchingEngine();

  List<CrmDuplicateGroupEntity> buildGroups({
    required List<CrmMergeMatchRecord> records,
    required List<CrmMergeMatchRule> rules,
    required bool Function(int score) isEligible,
  }) {
    final List<_Match> matches = <_Match>[];
    final List<int> parent = List<int>.generate(records.length, (int i) => i);
    for (int first = 0; first < records.length; first++) {
      for (int second = first + 1; second < records.length; second++) {
        final _Match match = _compare(records[first], records[second], rules);
        if (match.hasEvidence && isEligible(match.score)) {
          matches.add(match.copyWith(first: first, second: second));
          _union(parent, first, second);
        }
      }
    }
    final Map<int, List<int>> members = <int, List<int>>{};
    for (int index = 0; index < records.length; index++) {
      final int root = _find(parent, index);
      members.putIfAbsent(root, () => <int>[]).add(index);
    }
    return members.values.where((List<int> item) => item.length > 1).map(
      (List<int> indexes) {
        final Set<int> included = indexes.toSet();
        final List<CrmDuplicatePairMatchEntity> groupMatches = matches
            .where((item) =>
                included.contains(item.first) && included.contains(item.second))
            .map((item) => CrmDuplicatePairMatchEntity(
                  firstRecordId: records[item.first].id,
                  secondRecordId: records[item.second].id,
                  score: item.score,
                  reasons: item.reasons,
                ))
            .toList();
        return CrmDuplicateGroupEntity(
          id: indexes.map((int item) => records[item].id).join('_'),
          records: indexes.map((int item) => records[item]).toList(),
          pairMatches: groupMatches,
          detectedAt: DateTime.now(),
        );
      },
    ).toList();
  }

  _Match _compare(
    CrmMergeMatchRecord first,
    CrmMergeMatchRecord second,
    List<CrmMergeMatchRule> rules,
  ) {
    int weightedScore = 0;
    int positiveFields = 0;
    bool identityMatch = false;
    final List<String> reasons = <String>[];
    for (final CrmMergeMatchRule rule in rules.where(
      (CrmMergeMatchRule item) =>
          item.isEnabled &&
          item.comparisonType != CrmMergeMatchComparisonType.ignore,
    )) {
      final String firstValue = _valueFor(first, rule);
      final String secondValue = _valueFor(second, rule);
      if (firstValue.isEmpty || secondValue.isEmpty) {
        continue;
      }
      final int similarity =
          rule.comparisonType == CrmMergeMatchComparisonType.exact
              ? (firstValue == secondValue ? 100 : 0)
              : _similarity(firstValue, secondValue);
      weightedScore += rule.weight * similarity;
      if (similarity > 0) {
        positiveFields++;
        reasons.add(rule.systemKey.isNotEmpty ? rule.systemKey : rule.fieldId);
        if (rule.isIdentity && similarity == 100) identityMatch = true;
      }
    }
    return _Match(
      score: (weightedScore / 100).round().clamp(0, 100),
      hasEvidence: identityMatch || positiveFields >= 2,
      reasons: reasons,
    );
  }

  String _valueFor(CrmMergeMatchRecord record, CrmMergeMatchRule rule) {
    if (record.templateId != rule.templateId && rule.systemKey.isEmpty) {
      return '';
    }
    return _normalize(record.valueFor(rule.fieldId, rule.systemKey));
  }

  String _normalize(dynamic value) {
    String text = value?.toString().toLowerCase().trim() ?? '';
    const Map<String, String> arabicDigits = <String, String>{
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };
    for (final MapEntry<String, String> digit in arabicDigits.entries) {
      text = text.replaceAll(digit.key, digit.value);
    }
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
  }

  int _similarity(String first, String second) {
    if (first == second) return 100;
    final int distance = _levenshtein(first, second);
    final int length =
        first.length > second.length ? first.length : second.length;
    return ((1 - distance / length) * 100).round().clamp(0, 100);
  }

  int _levenshtein(String first, String second) {
    List<int> previous = List<int>.generate(second.length + 1, (int i) => i);
    for (int i = 1; i <= first.length; i++) {
      final List<int> current = <int>[i];
      for (int j = 1; j <= second.length; j++) {
        final int cost = first[i - 1] == second[j - 1] ? 0 : 1;
        current.add([
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + cost
        ].reduce((int a, int b) => a < b ? a : b));
      }
      previous = current;
    }
    return previous.last;
  }

  int _find(List<int> parent, int item) =>
      parent[item] == item ? item : parent[item] = _find(parent, parent[item]);
  void _union(List<int> parent, int first, int second) =>
      parent[_find(parent, first)] = _find(parent, second);
}

class _Match {
  final int score;
  final bool hasEvidence;
  final List<String> reasons;
  final int first;
  final int second;
  const _Match(
      {required this.score,
      required this.hasEvidence,
      required this.reasons,
      this.first = -1,
      this.second = -1});
  _Match copyWith({int? first, int? second}) => _Match(
      score: score,
      hasEvidence: hasEvidence,
      reasons: reasons,
      first: first ?? this.first,
      second: second ?? this.second);
}
