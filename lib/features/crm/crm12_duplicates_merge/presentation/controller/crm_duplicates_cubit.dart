// ****************** FILE INFO ******************
// File Name: crm_duplicates_cubit.dart
// Purpose: Cubit controller managing CRM Duplicates Review & Merge flows, filter/sort, wizard steps, and history
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/enums/crm_duplicates_enums.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/interfaces/crm_duplicates_repository_interface.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';
import 'crm_duplicates_state.dart';

class CrmDuplicatesCubit extends Cubit<CrmDuplicatesState> {
  final ICrmDuplicatesRepository repository;

  CrmDuplicatesCubit({required this.repository})
      : super(const CrmDuplicatesState()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final pairsResult = await repository.getDuplicatePairs();
    final historyResult = await repository.getMergeHistory();
    final levelsResult = await repository.getMergeLevels();
    final settingsResult = await repository.getMergeSettings();

    pairsResult.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error)),
      (pairs) {
        historyResult.fold(
          (error) => emit(state.copyWith(isLoading: false, error: error)),
          (history) => levelsResult.fold(
            (error) => emit(state.copyWith(isLoading: false, error: error)),
            (levels) => settingsResult.fold(
              (error) => emit(state.copyWith(isLoading: false, error: error)),
              (CrmMergeSettingsModel settings) => emit(state.copyWith(
                isLoading: false,
                duplicatePairs: pairs,
                mergeHistory: history,
                mergeLevels: levels.where((level) => level.isActive).toList()
                  ..sort((a, b) => a.rangeFrom.compareTo(b.rangeFrom)),
                mergeSettings: settings,
              )),
            ),
          ),
        );
      },
    );
  }

  void setActiveTab(CrmDuplicatesTab tab) {
    emit(state.copyWith(
      activeTab: tab,
      selectedFilter: 'All',
      selectedSort: 'Default',
    ));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setSelectedFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  void setSelectedSort(String sort) {
    emit(state.copyWith(selectedSort: sort));
  }

  void setViewMode(bool isGrid) {
    emit(state.copyWith(isGridView: isGrid));
  }

  void startMergeWizard(CrmDuplicatePairModel pair) {
    final Map<String, int> defaultSources = {
      'name': 1,
      'nameAr': 1,
      'phone': 1,
      'email': 1,
      'company': 1,
      'clientType': 1,
      'address': 1,
      'note': 1,
    };

    emit(state.copyWith(
      currentWizardPair: pair,
      currentStep: CrmMergeStep.selectDuplicates,
      selectedMasterRecordId: pair.record1.id,
      selectedFieldRecordSources: defaultSources,
    ));
  }

  void setMasterRecord(String recordId) {
    final int recordNumber =
        state.currentWizardPair?.record1.id == recordId ? 1 : 2;

    final Map<String, int> updatedSources = {
      'name': recordNumber,
      'nameAr': recordNumber,
      'phone': recordNumber,
      'email': recordNumber,
      'company': recordNumber,
      'clientType': recordNumber,
      'address': recordNumber,
      'note': recordNumber,
    };

    emit(state.copyWith(
      selectedMasterRecordId: recordId,
      selectedFieldRecordSources: updatedSources,
    ));
  }

  void selectFieldSource(String fieldKey, int recordNumber) {
    final Map<String, int> updated =
        Map<String, int>.from(state.selectedFieldRecordSources);
    updated[fieldKey] = recordNumber;
    emit(state.copyWith(selectedFieldRecordSources: updated));
  }

  void goToStep(CrmMergeStep step) {
    emit(state.copyWith(currentStep: step));
  }

  Future<bool> executeMerge() async {
    final CrmDuplicatePairModel? pair = state.currentWizardPair;
    final String? masterId = state.selectedMasterRecordId;
    if (pair == null || masterId == null) return false;

    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> chosenValues = {};
    state.selectedFieldRecordSources.forEach((field, sourceNum) {
      final record = sourceNum == 1 ? pair.record1 : pair.record2;
      switch (field) {
        case 'name':
          chosenValues['name'] = record.name;
          break;
        case 'nameAr':
          chosenValues['nameAr'] = record.nameAr;
          break;
        case 'phone':
          chosenValues['phone'] = record.phone;
          break;
        case 'email':
          chosenValues['email'] = record.email;
          break;
        case 'company':
          chosenValues['company'] = record.company;
          break;
        case 'clientType':
          chosenValues['clientType'] = record.clientType;
          break;
        case 'address':
          chosenValues['address'] = record.address;
          break;
        case 'note':
          chosenValues['note'] = record.note;
          break;
      }
    });

    final result = await repository.mergeDuplicatePair(
      pairId: pair.id,
      masterRecordId: masterId,
      recordIds: <String>[pair.record1.id, pair.record2.id],
      selectedFieldValues: chosenValues,
    );

    return result.fold(
      (error) {
        emit(state.copyWith(isLoading: false, error: error));
        return false;
      },
      (success) {
        emit(state.copyWith(
          isLoading: false,
          currentStep: CrmMergeStep.completed,
        ));
        loadData();
        return true;
      },
    );
  }

  Future<bool> ignorePair(String pairId) async {
    emit(state.copyWith(isLoading: true));
    final result = await repository.ignoreDuplicatePair(pairId);
    return result.fold(
      (error) {
        emit(state.copyWith(isLoading: false, error: error));
        return false;
      },
      (success) {
        emit(state.copyWith(isLoading: false));
        loadData();
        return true;
      },
    );
  }

  Future<bool> rollbackMerge(String historyId) async {
    emit(state.copyWith(isLoading: true));
    final result = await repository.rollbackMerge(historyId);
    return result.fold(
      (error) {
        emit(state.copyWith(isLoading: false, error: error));
        return false;
      },
      (success) {
        emit(state.copyWith(isLoading: false));
        loadData();
        return true;
      },
    );
  }
}
