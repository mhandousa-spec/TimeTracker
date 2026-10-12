// ****************** FILE INFO ******************
// File Name: crm_duplicates_repository.dart
// Purpose: Repository implementation for CRM duplicate discovery using real client records
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/data_source/crm_merge_history_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/enums/crm_duplicates_enums.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/interfaces/crm_duplicates_repository_interface.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_matching_rule_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/entities/crm_duplicate_group_entity.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/usecases/crm_duplicate_matching_engine.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';

class CrmDuplicatesRepository implements ICrmDuplicatesRepository {
  final CrmClientsBaseRepository clientsRepository;
  final CrmControlsBaseRepository controlsRepository;
  final CrmMergeHistoryRemoteDataSource? _mergeHistoryRemoteDataSource;
  final CrmDuplicateMatchingEngine _matchingEngine;

  /// Keeps hot-reloaded repository instances compatible when the history
  /// source is introduced after the instance was already registered in GetX.
  CrmMergeHistoryRemoteDataSource get mergeHistoryRemoteDataSource =>
      _mergeHistoryRemoteDataSource ?? CrmMergeHistoryRemoteDataSource();

  CrmDuplicatesRepository({
    required this.clientsRepository,
    required this.controlsRepository,
    CrmMergeHistoryRemoteDataSource? mergeHistoryRemoteDataSource,
    CrmDuplicateMatchingEngine matchingEngine =
        const CrmDuplicateMatchingEngine(),
  })  : _mergeHistoryRemoteDataSource =
            mergeHistoryRemoteDataSource ?? CrmMergeHistoryRemoteDataSource(),
        _matchingEngine = matchingEngine;

  List<CrmDuplicatePairModel> _pairs = <CrmDuplicatePairModel>[];

  @override
  Future<Either<Failure, List<CrmMergeLevelModel>>> getMergeLevels() {
    return controlsRepository.watchMergeLevels().first;
  }

  @override
  Future<Either<Failure, CrmMergeSettingsModel>> getMergeSettings() {
    return controlsRepository.watchMergeSettings().first;
  }

  @override
  Future<Either<Failure, List<CrmDuplicatePairModel>>>
      getDuplicatePairs() async {
    final Either<Failure, List<CrmDuplicateGroupEntity>> groupsResult =
        await getDuplicateGroups();
    final Either<Failure, List<CrmMergeLevelModel>> levelsResult =
        await controlsRepository.watchMergeLevels().first;
    return levelsResult.fold(
      (Failure failure) => Left(failure),
      (List<CrmMergeLevelModel> levels) =>
          groupsResult.map((List<CrmDuplicateGroupEntity> groups) {
        return groups.expand((CrmDuplicateGroupEntity group) {
          final List<CrmDuplicatePairMatchEntity> matches = group.pairMatches;
          return matches.map((CrmDuplicatePairMatchEntity match) {
            final CrmMergeMatchRecord first = group.records.firstWhere(
              (CrmMergeMatchRecord item) => item.id == match.firstRecordId,
            );
            final CrmMergeMatchRecord second = group.records.firstWhere(
              (CrmMergeMatchRecord item) => item.id == match.secondRecordId,
            );
            final CrmMergeLevelModel? level =
                _levelForScore(levels, match.score);
            return CrmDuplicatePairModel(
              id: '${group.id}_${match.firstRecordId}_${match.secondRecordId}',
              record1: _toClientInfo(first),
              record2: _toClientInfo(second),
              matchScore: match.score,
              matchLevel: CrmDuplicateMatchLevel.high,
              mergeLevelId: level?.id ?? '',
              mergeLevelName: level?.displayName ?? '',
              mergeLevelColorHex: level?.colorHex ?? '',
              matchReasons: match.reasons,
              detectedAt: group.detectedAt,
            );
          });
        }).toList();
      }),
    );
  }

  CrmMergeLevelModel? _levelForScore(
    List<CrmMergeLevelModel> levels,
    int score,
  ) {
    for (final CrmMergeLevelModel level in levels) {
      if (level.isActive &&
          score >= level.rangeFrom &&
          score <= level.rangeTo) {
        return level;
      }
    }
    return null;
  }

  @override
  Future<Either<Failure, List<CrmDuplicateGroupEntity>>>
      getDuplicateGroups() async {
    final Either<Failure, List<CrmClientRecordModel>> recordsResult =
        await clientsRepository.watchClientRecords().first;
    final Either<Failure, CrmMergeSettingsModel> settingsResult =
        await controlsRepository.watchMergeSettings().first;
    final Either<Failure, List<CrmMergeLevelModel>> levelsResult =
        await controlsRepository.watchMergeLevels().first;
    return recordsResult.fold(
      (Failure failure) => Left(failure),
      (List<CrmClientRecordModel> records) => settingsResult.fold(
        (Failure failure) => Left(failure),
        (settings) => levelsResult.fold(
          (Failure failure) => Left(failure),
          (List<CrmMergeLevelModel> levels) {
            final List<CrmMergeMatchingRuleModel> configuredRules =
                List<CrmMergeMatchingRuleModel>.from(settings.matchingRules);
            final List<CrmMergeMatchRule> configuredDomainRules =
                configuredRules
                    .map((CrmMergeMatchingRuleModel rule) => CrmMergeMatchRule(
                          fieldId: rule.fieldId,
                          templateId: rule.templateId,
                          systemKey: rule.systemKey,
                          weight: rule.weight,
                          comparisonType:
                              CrmMergeMatchComparisonType.values.firstWhere(
                            (CrmMergeMatchComparisonType item) =>
                                item.name == rule.comparisonType.name,
                          ),
                          isIdentity: rule.isIdentity,
                          isEnabled: rule.isEnabled,
                        ))
                    .toList();
            final List<CrmMergeMatchRecord> matchRecords = records
                .where(_isAvailableForMerge)
                .map((CrmClientRecordModel record) => CrmMergeMatchRecord(
                      id: record.id,
                      templateId: record.templateId,
                      values: record.values,
                      displayName: _clientDisplayName(record),
                      displayNameAr: _clientDisplayNameAr(record),
                      email: _clientValue(record, const <String>['email']),
                      phone: _clientValue(
                        record,
                        const <String>['phone_number', 'phone', 'mobile'],
                      ),
                      company: _clientValue(
                        record,
                        const <String>['company_name', 'entity_name'],
                      ),
                      clientTypeId: record.clientTypeId,
                      createdAt: record.audit.createdAt,
                    ))
                .toList();
            final bool hasActiveLevels = levels.any((level) => level.isActive);
            if (!hasActiveLevels) {
              return const Right(<CrmDuplicateGroupEntity>[]);
            }
            final List<CrmMergeMatchRule> rules = configuredDomainRules.isEmpty
                ? _fallbackRules(matchRecords)
                : configuredDomainRules;
            if (rules.isEmpty) {
              return const Right(<CrmDuplicateGroupEntity>[]);
            }
            return Right(_matchingEngine.buildGroups(
              records: matchRecords,
              rules: rules,
              isEligible: (int score) => levels.any(
                (level) =>
                    level.isActive &&
                    score >= level.rangeFrom &&
                    score <= level.rangeTo,
              ),
            ));
          },
        ),
      ),
    );
  }

  List<CrmMergeMatchRule> _fallbackRules(
    List<CrmMergeMatchRecord> records,
  ) {
    final Map<String, Set<String>> keysByTemplate = <String, Set<String>>{};
    for (final CrmMergeMatchRecord record in records) {
      final Set<String> keys = keysByTemplate.putIfAbsent(
        record.templateId,
        () => <String>{},
      );
      keys.addAll(record.values.entries
          .where((MapEntry<String, dynamic> entry) =>
              entry.value is! List && entry.value is! Map)
          .map((MapEntry<String, dynamic> entry) => entry.key));
    }
    final List<CrmMergeMatchRule> rules = <CrmMergeMatchRule>[];
    for (final MapEntry<String, Set<String>> entry in keysByTemplate.entries) {
      final List<String> keys = entry.value.toList()..sort();
      if (keys.isEmpty) continue;
      final int baseWeight = 100 ~/ keys.length;
      final int remainder = 100 % keys.length;
      for (int index = 0; index < keys.length; index++) {
        final String key = keys[index];
        final String normalizedKey = key.toLowerCase();
        final bool isIdentity = normalizedKey.contains('phone') ||
            normalizedKey.contains('email') ||
            normalizedKey.contains('mobile');
        rules.add(CrmMergeMatchRule(
          fieldId: key,
          templateId: entry.key,
          weight: baseWeight + (index < remainder ? 1 : 0),
          comparisonType: isIdentity
              ? CrmMergeMatchComparisonType.exact
              : CrmMergeMatchComparisonType.fuzzy,
          isIdentity: isIdentity,
        ));
      }
    }
    return rules;
  }

  CrmDuplicateClientInfoModel _toClientInfo(CrmMergeMatchRecord record) =>
      CrmDuplicateClientInfoModel(
        id: record.id,
        name: record.displayName.isEmpty ? record.id : record.displayName,
        nameAr: record.displayNameAr,
        email: record.email,
        phone: record.phone,
        company: record.company,
        clientType: record.clientTypeId.isEmpty
            ? record.templateId
            : record.clientTypeId,
        createdAt: record.createdAt ?? DateTime.now(),
      );

  bool _isAvailableForMerge(CrmClientRecordModel record) {
    final String status = record.status.trim().toLowerCase();
    return status != 'deleted' && status != 'merged';
  }

  String _clientDisplayName(CrmClientRecordModel record) {
    final String fullName = <String>[
      _clientValue(record, const <String>['first_name']),
      _clientValue(record, const <String>['last_name']),
    ].where((String value) => value.isNotEmpty).join(' ');
    if (fullName.isNotEmpty) return fullName;
    return _clientValue(
      record,
      const <String>['company_name', 'entity_name'],
      fallback: record.primaryDisplayValue ?? record.id,
    );
  }

  String _clientDisplayNameAr(CrmClientRecordModel record) {
    return <String>[
      _clientValue(record, const <String>['first_name_ar']),
      _clientValue(record, const <String>['last_name_ar']),
    ].where((String value) => value.isNotEmpty).join(' ');
  }

  String _clientValue(
    CrmClientRecordModel record,
    List<String> systemKeys, {
    String fallback = '',
  }) {
    for (final String systemKey in systemKeys) {
      final String value = _stringValue(record.valueFor(null, systemKey));
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  String _stringValue(dynamic value) {
    if (value == null || value is List) return '';
    if (value is Map) {
      final String english = (value['en'] ?? value['EN'] ?? '').toString();
      if (english.trim().isNotEmpty) return english.trim();
      return (value['ar'] ?? value['AR'] ?? '').toString().trim();
    }
    return value.toString().trim();
  }

  @override
  Future<Either<Failure, List<CrmMergeHistoryModel>>> getMergeHistory() async {
    final Either<Failure, List<CrmMergeHistoryModel>> persistedResult =
        await mergeHistoryRemoteDataSource.getMergeHistory();
    final Either<Failure, List<CrmClientRecordModel>> recordsResult =
        await clientsRepository.watchClientRecords().first;
    return persistedResult.fold(
      (Failure failure) => Left(failure),
      (List<CrmMergeHistoryModel> persisted) => recordsResult.fold(
        (Failure failure) => Left(failure),
        (List<CrmClientRecordModel> records) {
          final List<CrmMergeHistoryModel> combined = <CrmMergeHistoryModel>[
            ...persisted,
            ..._legacyMergeHistory(records, persisted),
          ].map((CrmMergeHistoryModel history) {
            if (history.isRolledBack &&
                _hasPendingClientRestoration(history, records)) {
              return history.copyWith(isRolledBack: false);
            }
            return history;
          }).toList()
            ..sort(
              (CrmMergeHistoryModel first, CrmMergeHistoryModel second) =>
                  second.mergedAt.compareTo(first.mergedAt),
            );
          return Right(combined);
        },
      ),
    );
  }

  List<CrmMergeHistoryModel> _legacyMergeHistory(
    List<CrmClientRecordModel> records,
    List<CrmMergeHistoryModel> persisted,
  ) {
    final Set<String> persistedMergedIds = persisted
        .expand((CrmMergeHistoryModel history) => <String>{
              history.mergedClientId,
              ...history.mergedClientIds,
            })
        .toSet();
    final Map<String, List<CrmClientRecordModel>> mergedByMaster =
        <String, List<CrmClientRecordModel>>{};
    for (final CrmClientRecordModel record in records) {
      final String masterId = record.mergedIntoId?.trim() ?? '';
      if (record.status.toLowerCase() != 'merged' ||
          masterId.isEmpty ||
          persistedMergedIds.contains(record.id)) {
        continue;
      }
      mergedByMaster
          .putIfAbsent(masterId, () => <CrmClientRecordModel>[])
          .add(record);
    }
    return mergedByMaster.entries.map(
      (MapEntry<String, List<CrmClientRecordModel>> entry) {
        final CrmClientRecordModel? master = records
            .where((CrmClientRecordModel record) => record.id == entry.key)
            .firstOrNull;
        final List<CrmClientRecordModel> mergedRecords = entry.value;
        final CrmClientRecordModel firstMerged = mergedRecords.first;
        return CrmMergeHistoryModel(
          id: 'legacy_${entry.key}',
          masterClientId: entry.key,
          masterClientName:
              master == null ? entry.key : _clientDisplayName(master),
          mergedClientId: firstMerged.id,
          mergedClientName: _clientDisplayName(firstMerged),
          mergedClientIds: mergedRecords
              .map((CrmClientRecordModel record) => record.id)
              .toList(),
          mergedBy: firstMerged.audit.updatedBy.isEmpty
              ? 'Current User'
              : firstMerged.audit.updatedBy,
          mergedAt: firstMerged.audit.updatedAt,
          fieldsUpdated: const <String>[],
          undoExpiresAt: DateTime.fromMillisecondsSinceEpoch(0),
          mergedRecordSnapshot: master?.toMap() ?? const <String, dynamic>{},
        );
      },
    ).toList();
  }

  @override
  Future<Either<Failure, bool>> ignoreDuplicatePair(String pairId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _pairs = _pairs.map((p) {
      if (p.id == pairId) {
        return p.copyWith(status: CrmDuplicateStatus.ignored);
      }
      return p;
    }).toList();
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> mergeDuplicatePair({
    required String pairId,
    required String masterRecordId,
    required List<String> recordIds,
    required Map<String, dynamic> selectedFieldValues,
  }) async {
    final Either<Failure, CrmMergeSettingsModel> settingsResult =
        await controlsRepository.watchMergeSettings().first;
    return settingsResult.fold<Future<Either<Failure, bool>>>(
      (Failure failure) async => Left(failure),
      (CrmMergeSettingsModel settings) async {
        final Either<Failure, List<CrmClientRecordModel>> recordsResult =
            await clientsRepository.watchClientRecords().first;
        return recordsResult.fold<Future<Either<Failure, bool>>>(
          (Failure failure) async => Left(failure),
          (List<CrmClientRecordModel> records) async {
            final List<CrmClientRecordModel> selected = records
                .where((CrmClientRecordModel record) =>
                    recordIds.contains(record.id))
                .toList();
            if (selected.length < 2 || !recordIds.contains(masterRecordId)) {
              return Left(
                FeatureFailure('Choose a master record and duplicates'),
              );
            }
            final CrmClientRecordModel master = selected.firstWhere(
              (CrmClientRecordModel record) => record.id == masterRecordId,
            );
            final List<CrmClientRecordModel> secondary = selected
                .where((CrmClientRecordModel record) =>
                    record.id != masterRecordId)
                .toList();
            final CrmClientRecordModel updatedMaster = master.copyWith(
              values: <String, dynamic>{
                ...master.values,
                ...selectedFieldValues,
              },
            );
            final Either<Failure, CrmClientRecordModel> masterResult =
                await clientsRepository.saveClientRecord(
              record: updatedMaster,
            );
            final Failure? masterFailure = masterResult.fold(
              (Failure failure) => failure,
              (CrmClientRecordModel _) => null,
            );
            if (masterFailure != null) return Left(masterFailure);

            for (final CrmClientRecordModel record in secondary) {
              final Either<Failure, CrmClientRecordModel> saveResult =
                  await clientsRepository.saveClientRecord(
                record: record.copyWith(
                  status: 'merged',
                  mergedIntoId: masterRecordId,
                ),
              );
              final Failure? saveFailure = saveResult.fold(
                (Failure failure) => failure,
                (CrmClientRecordModel _) => null,
              );
              if (saveFailure != null) return Left(saveFailure);
            }

            final DateTime now = DateTime.now();
            final CrmMergeHistoryModel history = CrmMergeHistoryModel(
              id: 'hist_${now.microsecondsSinceEpoch}',
              masterClientId: masterRecordId,
              masterClientName: _clientDisplayName(master),
              mergedClientId: secondary.first.id,
              mergedClientName: _clientDisplayName(secondary.first),
              mergedClientIds: secondary
                  .map((CrmClientRecordModel record) => record.id)
                  .toList(),
              mergedBy: 'Current User',
              mergedAt: now,
              undoExpiresAt:
                  settings.undoEnabled ? _undoExpiry(settings, now) : now,
              fieldsUpdated: selectedFieldValues.keys.toList(),
              snapshot: selected
                  .map((CrmClientRecordModel record) => record.toMap())
                  .toList(),
              mergedRecordSnapshot: updatedMaster.toMap(),
            );
            final Either<Failure, void> historyResult =
                await mergeHistoryRemoteDataSource.saveMergeHistory(
              history: history,
            );
            final Failure? historyFailure = historyResult.fold(
              (Failure failure) => failure,
              (_) => null,
            );
            if (historyFailure != null) return Left(historyFailure);
            return const Right(true);
          },
        );
      },
    );
  }

  DateTime _undoExpiry(CrmMergeSettingsModel settings, DateTime start) {
    final int amount = settings.durationValue;
    return switch (settings.durationUnit.name) {
      'minutes' => start.add(Duration(minutes: amount)),
      'hours' => start.add(Duration(hours: amount)),
      'days' => start.add(Duration(days: amount)),
      'weeks' => start.add(Duration(days: amount * 7)),
      'months' => DateTime(start.year, start.month + amount, start.day),
      _ => DateTime(start.year + amount, start.month, start.day),
    };
  }

  @override
  Future<Either<Failure, bool>> rollbackMerge(String historyId) async {
    final Either<Failure, List<CrmMergeHistoryModel>> historyResult =
        await getMergeHistory();
    final Failure? loadFailure = historyResult.fold(
      (Failure failure) => failure,
      (_) => null,
    );
    if (loadFailure != null) return Left(loadFailure);
    final List<CrmMergeHistoryModel> historyItems = historyResult.getOrElse(
      () => const <CrmMergeHistoryModel>[],
    );
    final CrmMergeHistoryModel? history = historyItems
        .where((CrmMergeHistoryModel item) => item.id == historyId)
        .firstOrNull;
    if (history == null || history.isRolledBack) {
      return Left(FeatureFailure('This merge cannot be undone'));
    }
    final Either<Failure, CrmMergeSettingsModel> settingsResult =
        await controlsRepository.watchMergeSettings().first;
    final Failure? settingsFailure = settingsResult.fold(
      (Failure failure) => failure,
      (_) => null,
    );
    if (settingsFailure != null) return Left(settingsFailure);
    final CrmMergeSettingsModel settings = settingsResult.getOrElse(
      () => CrmMergeSettingsModel.defaults(),
    );
    if (!settings.undoEnabled) {
      return Left(FeatureFailure('Undo is disabled in Merge Controls'));
    }
    if (DateTime.now().isAfter(_undoExpiry(settings, history.mergedAt))) {
      return Left(FeatureFailure('The undo period has expired'));
    }
    final Either<Failure, List<CrmClientRecordModel>> recordsResult =
        await clientsRepository.watchClientRecords().first;
    final Failure? recordsFailure = recordsResult.fold(
      (Failure failure) => failure,
      (_) => null,
    );
    if (recordsFailure != null) return Left(recordsFailure);
    final List<CrmClientRecordModel> currentRecords = recordsResult.getOrElse(
      () => const <CrmClientRecordModel>[],
    );
    final List<CrmClientRecordModel> recordsToRestore =
        _recordsToRestore(history, currentRecords);
    if (recordsToRestore.isEmpty) {
      return Left(
          FeatureFailure('No merged client records were found to restore'));
    }
    for (final CrmClientRecordModel record in recordsToRestore) {
      final Either<Failure, dynamic> result =
          await clientsRepository.saveClientRecord(record: record);
      if (result.isLeft()) return result.map((_) => false);
    }
    final CrmMergeHistoryModel rolledBackHistory = history.copyWith(
      isRolledBack: true,
      rolledBackAt: DateTime.now(),
      rolledBackBy: 'Current User',
    );
    final Either<Failure, void> saveHistoryResult =
        await mergeHistoryRemoteDataSource.saveMergeHistory(
      history: rolledBackHistory,
    );
    final Failure? saveHistoryFailure = saveHistoryResult.fold(
      (Failure failure) => failure,
      (_) => null,
    );
    if (saveHistoryFailure != null) return Left(saveHistoryFailure);
    return const Right(true);
  }

  List<CrmClientRecordModel> _recordsToRestore(
    CrmMergeHistoryModel history,
    List<CrmClientRecordModel> currentRecords,
  ) {
    final Map<String, CrmClientRecordModel> recordsById =
        <String, CrmClientRecordModel>{};
    for (final Map<String, dynamic> snapshot in history.snapshot) {
      final CrmClientRecordModel record =
          CrmClientRecordModel.fromMap(snapshot);
      if (record.id.isNotEmpty) recordsById[record.id] = record;
    }

    final Set<String> secondaryIds = <String>{
      history.mergedClientId,
      ...history.mergedClientIds,
    }..removeWhere((String id) => id.isEmpty);
    for (final CrmClientRecordModel record in currentRecords) {
      final bool isMergedSecondary = secondaryIds.contains(record.id) &&
          record.status.toLowerCase() == 'merged' &&
          record.mergedIntoId == history.masterClientId;
      if (!isMergedSecondary || recordsById.containsKey(record.id)) continue;
      recordsById[record.id] = record.copyWith(
        status: 'active',
        clearMergedIntoId: true,
      );
    }
    return recordsById.values.toList();
  }

  bool _hasPendingClientRestoration(
    CrmMergeHistoryModel history,
    List<CrmClientRecordModel> records,
  ) {
    final Set<String> secondaryIds = <String>{
      history.mergedClientId,
      ...history.mergedClientIds,
    }..removeWhere((String id) => id.isEmpty);
    return records.any((CrmClientRecordModel record) {
      return secondaryIds.contains(record.id) &&
          record.status.toLowerCase() == 'merged' &&
          record.mergedIntoId == history.masterClientId;
    });
  }
}
