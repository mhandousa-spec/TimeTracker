// ****************** FILE INFO ******************
// File Name: crm_duplicates_repository_interface.dart
// Purpose: Abstract repository contract for CRM Duplicates and Merge module
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/entities/crm_duplicate_group_entity.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';

abstract class ICrmDuplicatesRepository {
  Future<Either<Failure, List<CrmDuplicatePairModel>>> getDuplicatePairs();

  Future<Either<Failure, List<CrmDuplicateGroupEntity>>> getDuplicateGroups();

  Future<Either<Failure, List<CrmMergeLevelModel>>> getMergeLevels();

  Future<Either<Failure, CrmMergeSettingsModel>> getMergeSettings();

  Future<Either<Failure, List<CrmMergeHistoryModel>>> getMergeHistory();

  Future<Either<Failure, bool>> ignoreDuplicatePair(String pairId);

  Future<Either<Failure, bool>> mergeDuplicatePair({
    required String pairId,
    required String masterRecordId,
    required List<String> recordIds,
    required Map<String, dynamic> selectedFieldValues,
  });

  Future<Either<Failure, bool>> rollbackMerge(String historyId);
}
