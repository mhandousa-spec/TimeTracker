// ****************** FILE INFO ******************
// File Name: crm_duplicates_state.dart
// Purpose: State definition for CRM Duplicates and Merge module with status counts and filtering
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/enums/crm_duplicates_enums.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmMergePreviewData {
  final String fullName;
  final String phone;
  final String email;
  final String jobTitle;
  final int totalFieldCount;

  const CrmMergePreviewData({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.jobTitle,
    required this.totalFieldCount,
  });
}

class CrmUndoAvailability {
  final bool isAvailable;
  final DateTime? expiresAt;
  final String durationLabel;

  const CrmUndoAvailability({
    required this.isAvailable,
    required this.expiresAt,
    required this.durationLabel,
  });
}

class CrmDuplicatesState {
  final bool isLoading;
  final Failure? error;
  final List<CrmDuplicatePairModel> duplicatePairs;
  final List<CrmMergeHistoryModel> mergeHistory;
  final List<CrmMergeLevelModel> mergeLevels;
  final CrmMergeSettingsModel? _mergeSettings;
  final CrmDuplicatesTab activeTab;
  final String searchQuery;
  final String selectedFilter;
  final String selectedSort;
  final bool isGridView;

  // Merge Wizard State
  final CrmDuplicatePairModel? currentWizardPair;
  final CrmMergeStep currentStep;
  final String? selectedMasterRecordId;
  final Map<String, int>
      selectedFieldRecordSources; // fieldKey -> 1 (record1) or 2 (record2)

  const CrmDuplicatesState({
    this.isLoading = false,
    this.error,
    this.duplicatePairs = const [],
    this.mergeHistory = const [],
    this.mergeLevels = const <CrmMergeLevelModel>[],
    CrmMergeSettingsModel mergeSettings = const CrmMergeSettingsModel(),
    this.activeTab = CrmDuplicatesTab.duplicate,
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.selectedSort = 'Default',
    this.isGridView = true,
    this.currentWizardPair,
    this.currentStep = CrmMergeStep.selectDuplicates,
    this.selectedMasterRecordId,
    this.selectedFieldRecordSources = const {},
  }) : _mergeSettings = mergeSettings;

  /// Falls back safely for state objects that survived a hot reload before
  /// the Merge Controls setting was added to this state shape.
  CrmMergeSettingsModel get mergeSettings =>
      _mergeSettings ?? CrmMergeSettingsModel.defaults();

  int get totalCount => duplicatePairs
      .where((p) => p.status == CrmDuplicateStatus.pending)
      .length;
  int get activePendingCount => duplicatePairs
      .where((p) => p.status == CrmDuplicateStatus.pending)
      .length;
  int get veryLikelyCount => duplicatePairs
      .where(
          (p) => p.status == CrmDuplicateStatus.pending && p.matchScore >= 90)
      .length;
  int get possibleCount => duplicatePairs
      .where((p) =>
          p.status == CrmDuplicateStatus.pending &&
          p.matchScore >= 70 &&
          p.matchScore < 90)
      .length;
  int get unlikelyCount => duplicatePairs
      .where((p) => p.status == CrmDuplicateStatus.pending && p.matchScore < 70)
      .length;

  int get mergedCount =>
      duplicatePairs.where((p) => p.status == CrmDuplicateStatus.merged).length;
  int get ignoredCount => duplicatePairs
      .where((p) => p.status == CrmDuplicateStatus.ignored)
      .length;

  Map<String, int> get pendingCountByMergeLevel {
    final Map<String, int> result = <String, int>{};
    for (final CrmDuplicatePairModel pair in duplicatePairs) {
      if (pair.status != CrmDuplicateStatus.pending ||
          pair.mergeLevelId.isEmpty) {
        continue;
      }
      result[pair.mergeLevelId] = (result[pair.mergeLevelId] ?? 0) + 1;
    }
    return result;
  }

  List<CrmDuplicatePairModel> get filteredPairs {
    List<CrmDuplicatePairModel> list =
        List<CrmDuplicatePairModel>.from(duplicatePairs);

    if (activeTab == CrmDuplicatesTab.duplicate) {
      list = list.where((p) => p.status == CrmDuplicateStatus.pending).toList();
    } else {
      list = list.where((p) => p.status != CrmDuplicateStatus.pending).toList();
    }

    if (selectedFilter.isNotEmpty && selectedFilter != 'All') {
      if (selectedFilter.startsWith('level:')) {
        final String levelId = selectedFilter.substring('level:'.length);
        list = list
            .where((CrmDuplicatePairModel pair) => pair.mergeLevelId == levelId)
            .toList();
      } else if (selectedFilter == 'Very Likely') {
        list = list.where((p) => p.matchScore >= 90).toList();
      } else if (selectedFilter == 'Possible') {
        list =
            list.where((p) => p.matchScore >= 70 && p.matchScore < 90).toList();
      } else if (selectedFilter == 'Unlikely') {
        list = list.where((p) => p.matchScore < 70).toList();
      }
    }

    if (searchQuery.trim().isNotEmpty) {
      final String q = searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.record1.name.toLowerCase().contains(q) ||
            p.record2.name.toLowerCase().contains(q) ||
            p.record1.email.toLowerCase().contains(q) ||
            p.record2.email.toLowerCase().contains(q) ||
            p.record1.phone.toLowerCase().contains(q) ||
            p.record2.phone.toLowerCase().contains(q) ||
            p.record1.company.toLowerCase().contains(q) ||
            p.record2.company.toLowerCase().contains(q);
      }).toList();
    }

    if (selectedSort == 'Match % (High to Low)') {
      list.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    } else if (selectedSort == 'Match % (Low to High)') {
      list.sort((a, b) => a.matchScore.compareTo(b.matchScore));
    } else if (selectedSort == 'Name (A-Z)') {
      list.sort((a, b) => a.record1.name.compareTo(b.record1.name));
    }

    return list;
  }

  List<CrmMergeHistoryModel> get filteredMergeHistory {
    List<CrmMergeHistoryModel> list =
        List<CrmMergeHistoryModel>.from(mergeHistory);
    if (searchQuery.trim().isNotEmpty) {
      final String query = searchQuery.trim().toLowerCase();
      list = list.where((CrmMergeHistoryModel history) {
        return history.masterClientName.toLowerCase().contains(query) ||
            history.mergedClientName.toLowerCase().contains(query) ||
            history.mergedBy.toLowerCase().contains(query);
      }).toList();
    }
    if (selectedSort == 'Name (A-Z)') {
      list.sort((CrmMergeHistoryModel first, CrmMergeHistoryModel second) =>
          first.masterClientName.compareTo(second.masterClientName));
    } else if (selectedSort == 'Date (Newest First)' ||
        selectedSort == 'Default') {
      list.sort((CrmMergeHistoryModel first, CrmMergeHistoryModel second) =>
          second.mergedAt.compareTo(first.mergedAt));
    }
    return list;
  }

  CrmUndoAvailability undoAvailabilityFor(CrmMergeHistoryModel history) {
    final String durationLabel =
        '${mergeSettings.durationValue} ${mergeSettings.durationUnit.name}';
    if (!mergeSettings.undoEnabled || history.isRolledBack) {
      return CrmUndoAvailability(
        isAvailable: false,
        expiresAt: null,
        durationLabel: durationLabel,
      );
    }
    final DateTime expiresAt = _undoExpiry(history.mergedAt);
    return CrmUndoAvailability(
      isAvailable: DateTime.now().isBefore(expiresAt),
      expiresAt: expiresAt,
      durationLabel: durationLabel,
    );
  }

  DateTime _undoExpiry(DateTime mergedAt) {
    final int amount = mergeSettings.durationValue;
    return switch (mergeSettings.durationUnit.name) {
      'minutes' => mergedAt.add(Duration(minutes: amount)),
      'hours' => mergedAt.add(Duration(hours: amount)),
      'days' => mergedAt.add(Duration(days: amount)),
      'weeks' => mergedAt.add(Duration(days: amount * 7)),
      'months' =>
        DateTime(mergedAt.year, mergedAt.month + amount, mergedAt.day),
      _ => DateTime(mergedAt.year + amount, mergedAt.month, mergedAt.day),
    };
  }

  CrmMergePreviewData mergePreviewFor(CrmMergeHistoryModel history) {
    final Map<String, dynamic> record = history.mergedRecordSnapshot.isNotEmpty
        ? history.mergedRecordSnapshot
        : _masterSnapshot(history);
    final Map<String, dynamic> values = Map<String, dynamic>.from(
      CrmFirestoreKeys.read(
            record,
            CrmFirestoreKeys.VALUES_KEY,
            'values',
          ) as Map? ??
          const <String, dynamic>{},
    );
    final String selectedName = _stringValue(values['name']);
    final String firstName = _valueFor(values, 'first_name');
    final String lastName = _valueFor(values, 'last_name');
    final String fullName = selectedName.isNotEmpty
        ? selectedName
        : <String>[firstName, lastName]
            .where((String value) => value.isNotEmpty)
            .join(' ');
    return CrmMergePreviewData(
      fullName: fullName.isEmpty ? history.masterClientName : fullName,
      phone: _firstValue(
        values,
        const <String>['phone', 'phone_number', 'mobile'],
      ),
      email: _firstValue(values, const <String>['email']),
      jobTitle: _firstValue(values, const <String>['job_title']),
      totalFieldCount: values.values
          .where((dynamic value) => _stringValue(value).isNotEmpty)
          .length,
    );
  }

  Map<String, dynamic> _masterSnapshot(CrmMergeHistoryModel history) {
    for (final Map<String, dynamic> snapshot in history.snapshot) {
      final String id = (CrmFirestoreKeys.read(
                snapshot,
                CrmFirestoreKeys.ID_KEY,
                'id',
              ) ??
              '')
          .toString();
      if (id == history.masterClientId) return snapshot;
    }
    return const <String, dynamic>{};
  }

  String _firstValue(Map<String, dynamic> values, List<String> systemKeys) {
    for (final String systemKey in systemKeys) {
      final String value = _valueFor(values, systemKey);
      if (value.isNotEmpty) return value;
    }
    return '—';
  }

  String _valueFor(Map<String, dynamic> values, String systemKey) {
    if (values.containsKey(systemKey)) {
      return _stringValue(values[systemKey]);
    }
    for (final MapEntry<String, dynamic> entry in values.entries) {
      if (entry.key.endsWith('_$systemKey')) {
        return _stringValue(entry.value);
      }
    }
    return '';
  }

  String _stringValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value
          .map(_stringValue)
          .where((String item) => item.isNotEmpty)
          .join(', ');
    }
    if (value is Map) {
      final String localized =
          (value['en'] ?? value['EN'] ?? value['ar'] ?? value['AR'] ?? '')
              .toString()
              .trim();
      if (localized.isNotEmpty) return localized;
      return value.values
          .map(_stringValue)
          .where((String item) => item.isNotEmpty)
          .join(', ');
    }
    return value.toString().trim();
  }

  CrmDuplicatesState copyWith({
    bool? isLoading,
    Failure? error,
    bool clearError = false,
    List<CrmDuplicatePairModel>? duplicatePairs,
    List<CrmMergeHistoryModel>? mergeHistory,
    List<CrmMergeLevelModel>? mergeLevels,
    CrmMergeSettingsModel? mergeSettings,
    CrmDuplicatesTab? activeTab,
    String? searchQuery,
    String? selectedFilter,
    String? selectedSort,
    bool? isGridView,
    CrmDuplicatePairModel? currentWizardPair,
    bool clearWizardPair = false,
    CrmMergeStep? currentStep,
    String? selectedMasterRecordId,
    Map<String, int>? selectedFieldRecordSources,
  }) {
    return CrmDuplicatesState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      duplicatePairs: duplicatePairs ?? this.duplicatePairs,
      mergeHistory: mergeHistory ?? this.mergeHistory,
      mergeLevels: mergeLevels ?? this.mergeLevels,
      mergeSettings: mergeSettings ?? this.mergeSettings,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedSort: selectedSort ?? this.selectedSort,
      isGridView: isGridView ?? this.isGridView,
      currentWizardPair: clearWizardPair
          ? null
          : (currentWizardPair ?? this.currentWizardPair),
      currentStep: currentStep ?? this.currentStep,
      selectedMasterRecordId:
          selectedMasterRecordId ?? this.selectedMasterRecordId,
      selectedFieldRecordSources:
          selectedFieldRecordSources ?? this.selectedFieldRecordSources,
    );
  }
}
