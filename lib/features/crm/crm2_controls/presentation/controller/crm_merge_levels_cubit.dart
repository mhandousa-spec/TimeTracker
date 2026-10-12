// ****************** FILE INFO ******************
// File Name: crm_merge_levels_cubit.dart
// Purpose: Cubit for CRM merge levels Firebase integration and UI state management
// Author: Mohand Adel
// Created At: 26/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_matching_rule_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'crm_merge_levels_state.dart';

class CrmMergeLevelsCubit extends Cubit<CrmMergeLevelsState> {
  final CrmControlsBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmMergeLevelModel>>>?
      _mergeLevelsSubscription;
  StreamSubscription<Either<Failure, CrmMergeSettingsModel>>?
      _mergeSettingsSubscription;

  CrmMergeLevelsCubit({
    CrmControlsBaseRepository? repository,
  })  : repository = repository ?? Get.find<CrmControlsBaseRepository>(),
        super(const CrmMergeLevelsState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await Future.wait<void>(<Future<void>>[
      watchMergeLevels(),
      watchMergeSettings(),
    ]);
  }

  Future<void> watchMergeLevels() async {
    await _mergeLevelsSubscription?.cancel();
    _mergeLevelsSubscription = repository.watchMergeLevels().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.errMessage,
          ),
        ),
        (items) => emit(
          state.copyWith(
            items: items,
            filteredItems: _visibleItems(items),
            isLoading: false,
            clearMessages: true,
          ),
        ),
      );
    });
  }

  Future<void> watchMergeSettings() async {
    await _mergeSettingsSubscription?.cancel();
    _mergeSettingsSubscription = repository.watchMergeSettings().listen(
      (Either<Failure, CrmMergeSettingsModel> result) {
        result.fold(
          (Failure failure) => emit(
            state.copyWith(isLoading: false, errorMessage: failure.errMessage),
          ),
          (CrmMergeSettingsModel settings) => emit(
            state.copyWith(
                settings: settings, isLoading: false, clearMessages: true),
          ),
        );
      },
    );
  }

  void search(String query) {
    final String normalizedQuery = query.trim();
    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        filteredItems: _visibleItems(state.items, searchQuery: normalizedQuery),
        clearMessages: true,
      ),
    );
  }

  void selectStatus(String status) {
    emit(state.copyWith(
      selectedStatus: status,
      filteredItems: _visibleItems(state.items, selectedStatus: status),
      clearMessages: true,
    ));
  }

  void setSort(String? sort) {
    emit(sort == null
        ? state.copyWith(
            clearSort: true,
            filteredItems: _visibleItems(state.items, selectedSort: null),
            clearMessages: true,
          )
        : state.copyWith(
            selectedSort: sort,
            filteredItems: _visibleItems(state.items, selectedSort: sort),
            clearMessages: true,
          ));
  }

  Future<bool> saveSettings({
    required bool undoEnabled,
    required int durationValue,
    required MergeDurationUnit durationUnit,
  }) async {
    if (durationValue < 1) {
      emit(state.copyWith(errorMessage: 'Duration must be at least 1'));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final CrmMergeSettingsModel updated = state.settings.copyWith(
      undoEnabled: undoEnabled,
      durationValue: durationValue,
      durationUnit: durationUnit,
    );
    final Either<Failure, void> result = await repository.saveMergeSettings(
      settings: updated,
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (Failure failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(
            settings: updated,
            isSaving: false,
            successMessage: 'settings_updated'));
        return true;
      },
    );
  }

  Future<bool> saveMatchingRules(
    List<CrmMergeMatchingRuleModel> rules,
  ) async {
    final List<CrmMergeMatchingRuleModel> activeRules = rules
        .where((CrmMergeMatchingRuleModel rule) => rule.isEnabled)
        .toList();
    final int totalWeight = activeRules.fold<int>(
      0,
      (int total, CrmMergeMatchingRuleModel rule) => total + rule.weight,
    );
    if (activeRules.isEmpty ||
        totalWeight != 100 ||
        !activeRules.any((CrmMergeMatchingRuleModel rule) => rule.isIdentity)) {
      emit(state.copyWith(
        errorMessage:
            'Rules need an identity field and enabled weights totaling 100%',
      ));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final CrmMergeSettingsModel updated = state.settings.copyWith(
      matchingRules: rules,
    );
    final Either<Failure, void> result = await repository.saveMergeSettings(
      settings: updated,
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (Failure failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(
          settings: updated,
          isSaving: false,
          successMessage: 'matching_rules_updated',
        ));
        return true;
      },
    );
  }

  void selectLevel(CrmMergeLevelModel level) {
    emit(state.copyWith(selectedLevel: level, clearMessages: true));
  }

  Future<bool> createLevel({
    required String nameEn,
    required String nameAr,
    required double rangeFrom,
    required double rangeTo,
    required String colorHex,
  }) async {
    if (!_validateInputs(
      nameEn: nameEn,
      nameAr: nameAr,
      rangeFrom: rangeFrom,
      rangeTo: rangeTo,
    )) {
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final String levelId =
        'merge_level_${DateTime.now().microsecondsSinceEpoch}';

    final Either<Failure, CrmMergeLevelModel> result =
        await repository.createMergeLevel(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      rangeFrom: rangeFrom,
      rangeTo: rangeTo,
      colorHex: colorHex.trim().isNotEmpty ? colorHex.trim() : '#FFD043',
      userEmail: _currentUserEmail,
      levelId: levelId,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (level) {
        emit(
          state.copyWith(
            selectedLevel: level,
            isSaving: false,
            successMessage: 'created',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> updateLevel({
    required CrmMergeLevelModel currentLevel,
    required String nameEn,
    required String nameAr,
    required double rangeFrom,
    required double rangeTo,
    required String colorHex,
    bool? isActive,
  }) async {
    if (!_validateInputs(
      nameEn: nameEn,
      nameAr: nameAr,
      rangeFrom: rangeFrom,
      rangeTo: rangeTo,
      excludedLevelId: currentLevel.id,
      isActive: isActive ?? currentLevel.isActive,
    )) {
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));

    final CrmMergeLevelModel updatedLevel = currentLevel.copyWith(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      rangeFrom: rangeFrom,
      rangeTo: rangeTo,
      colorHex:
          colorHex.trim().isNotEmpty ? colorHex.trim() : currentLevel.colorHex,
      isActive: isActive ?? currentLevel.isActive,
    );

    final Either<Failure, void> result = await repository.updateMergeLevel(
      level: updatedLevel,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            selectedLevel: updatedLevel,
            isSaving: false,
            successMessage: 'updated',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> removeLevel(CrmMergeLevelModel level) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.removeMergeLevel(
      level: level,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            clearSelectedLevel: true,
            isSaving: false,
            successMessage: 'removed',
          ),
        );
        return true;
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  bool _validateInputs({
    required String nameEn,
    required String nameAr,
    required double rangeFrom,
    required double rangeTo,
    String? excludedLevelId,
    bool isActive = true,
  }) {
    if (nameEn.trim().isEmpty || nameAr.trim().isEmpty) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Merge level English and Arabic names are required',
        ),
      );
      return false;
    }
    if (rangeTo < rangeFrom) {
      emit(state.copyWith(
          isSaving: false,
          errorMessage:
              'Range To must be greater than or equal to Range From'));
      return false;
    }
    if (isActive &&
        state.items.any((CrmMergeLevelModel level) {
          return level.isActive &&
              level.id != excludedLevelId &&
              rangeFrom < level.rangeTo &&
              rangeTo > level.rangeFrom;
        })) {
      emit(state.copyWith(
          isSaving: false,
          errorMessage: 'The range overlaps an active likelihood level'));
      return false;
    }
    return true;
  }

  List<CrmMergeLevelModel> _visibleItems(List<CrmMergeLevelModel> items,
      {String? searchQuery, String? selectedStatus, String? selectedSort}) {
    final String status = selectedStatus ?? state.selectedStatus;
    final String query = searchQuery ?? state.searchQuery;
    final String normalizedQuery = query.toLowerCase().trim();
    final List<CrmMergeLevelModel> visible = items.where((item) {
      final bool matchesStatus = status == 'All' ||
          (status == 'Active' ? item.isActive : !item.isActive);
      final bool matchesQuery = normalizedQuery.isEmpty ||
          item.nameEn.toLowerCase().contains(normalizedQuery) ||
          item.nameAr.toLowerCase().contains(normalizedQuery);
      return matchesStatus && matchesQuery;
    }).toList();
    switch (selectedSort ?? state.selectedSort) {
      case 'name_asc':
        visible.sort((a, b) => a.displayName.compareTo(b.displayName));
      case 'name_desc':
        visible.sort((a, b) => b.displayName.compareTo(a.displayName));
      case 'range_asc':
        visible.sort((a, b) => a.rangeFrom.compareTo(b.rangeFrom));
      case 'range_desc':
        visible.sort((a, b) => b.rangeFrom.compareTo(a.rangeFrom));
    }
    return visible;
  }

  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    final String? fallbackEmail = Constant.emailUser;
    if (fallbackEmail != null && fallbackEmail.trim().isNotEmpty) {
      return fallbackEmail.trim().toLowerCase();
    }
    return 'system';
  }

  @override
  Future<void> close() async {
    await _mergeLevelsSubscription?.cancel();
    await _mergeSettingsSubscription?.cancel();
    return super.close();
  }
}
