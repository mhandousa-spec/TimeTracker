// ****************** FILE INFO ******************
// File Name: crm_deal_form_cubit.dart
// Purpose: Owns CRM deal form validation, transformations, ordering, and submission
// Author: Mohand Adel
// Created At: 22/08/2026

import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_stage_checklist_item_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'crm_deal_form_state.dart';
import 'crm_deals_cubit.dart';

class CrmDealFormCubit extends Cubit<CrmDealFormState> {
  final CrmDealsCubit dealsCubit;
  int _nextChecklistId = 0;

  CrmDealFormCubit({required this.dealsCubit})
      : super(const CrmDealFormState());

  void prepareCategory() {
    dealsCubit.setFormOpen(true);
    emit(const CrmDealFormState());
  }

  void prepareStage({CrmDealStageModel? stage, required bool isEditing}) {
    dealsCubit.setFormOpen(true);
    final int stagesCount = dealsCubit.state.stages.length;
    final int selectedOrder =
        isEditing && stage != null ? max(1, stage.order) : stagesCount + 1;
    final int optionCount =
        isEditing ? max(max(1, stagesCount), selectedOrder) : stagesCount + 1;
    final List<CrmDealChecklistInput> checklistInputs =
        stage != null && stage.checklistItems.isNotEmpty
            ? stage.checklistItems
                .map(
                  (CrmStageChecklistItemModel item) => CrmDealChecklistInput(
                    id: _nextChecklistId++,
                    nameEn: item.nameEn,
                    nameAr: item.nameAr,
                  ),
                )
                .toList()
            : <CrmDealChecklistInput>[
                CrmDealChecklistInput(id: _nextChecklistId++),
              ];

    emit(
      CrmDealFormState(
        selectedOrder: selectedOrder,
        orderOptions:
            List<CrmDealOrderOption>.generate(optionCount, (int index) {
          final int value = index + 1;
          return CrmDealOrderOption(value: value, label: value.toString());
        }),
        probabilityText: stage != null && stage.probability > 0
            ? stage.probability.toString()
            : '',
        checklistInputs: checklistInputs,
      ),
    );
  }

  void clearNameEnError() {
    if (state.nameEnError != null) {
      emit(state.copyWith(clearNameEnError: true));
    }
  }

  void clearNameArError() {
    if (state.nameArError != null) {
      emit(state.copyWith(clearNameArError: true));
    }
  }

  void selectOrder(int value) {
    emit(state.copyWith(selectedOrder: value));
  }

  void addChecklistItem() {
    emit(
      state.copyWith(
        checklistInputs: <CrmDealChecklistInput>[
          ...state.checklistInputs,
          CrmDealChecklistInput(id: _nextChecklistId++),
        ],
      ),
    );
  }

  void removeChecklistItem(int id) {
    if (state.checklistInputs.length <= 1) return;
    emit(
      state.copyWith(
        checklistInputs: state.checklistInputs
            .where((CrmDealChecklistInput item) => item.id != id)
            .toList(),
      ),
    );
  }

  void updateChecklistNameEn(int id, String value) {
    _updateChecklistItem(id, nameEn: value);
  }

  void updateChecklistNameAr(int id, String value) {
    _updateChecklistItem(id, nameAr: value);
  }

  void submitCategory({
    required CrmDealCategoryModel? category,
    required String nameEn,
    required String nameAr,
  }) {
    if (!_validateNames(
      nameEn: nameEn,
      nameAr: nameAr,
      nameEnMessage: S.current.crmPleaseEnterCategoryNameEn,
      nameArMessage: S.current.crmPleaseEnterCategoryNameAr,
    )) {
      return;
    }
    _submitCategory(category: category, nameEn: nameEn, nameAr: nameAr);
  }

  Future<void> _submitCategory({
    required CrmDealCategoryModel? category,
    required String nameEn,
    required String nameAr,
  }) async {
    emit(state.copyWith(isSubmitting: true, submitSucceeded: false));
    final bool succeeded = category == null
        ? await dealsCubit.createCategory(
            nameEn: nameEn,
            nameAr: nameAr,
            status: 'active',
          )
        : await dealsCubit.updateCategory(
            currentCategory: category,
            nameEn: nameEn,
            nameAr: nameAr,
            status: category.status,
          );
    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false, submitSucceeded: succeeded));
    }
  }

  void submitStage({
    required CrmDealStageModel? stage,
    required String nameEn,
    required String nameAr,
    String? probabilityText,
  }) {
    if (!_validateNames(
      nameEn: nameEn,
      nameAr: nameAr,
      nameEnMessage: S.current.crmPleaseEnterStageNameEn,
      nameArMessage: S.current.crmPleaseEnterStageNameAr,
    )) {
      return;
    }
    _submitStage(
      stage: stage,
      nameEn: nameEn,
      nameAr: nameAr,
      probabilityText: probabilityText,
    );
  }

  Future<void> _submitStage({
    required CrmDealStageModel? stage,
    required String nameEn,
    required String nameAr,
    required String? probabilityText,
  }) async {
    emit(state.copyWith(isSubmitting: true, submitSucceeded: false));
    final List<CrmStageChecklistItemModel> checklistItems =
        state.checklistInputs
            .where(
      (CrmDealChecklistInput item) =>
          item.nameEn.trim().isNotEmpty || item.nameAr.trim().isNotEmpty,
    )
            .map((CrmDealChecklistInput item) {
      final String nameEnValue = item.nameEn.trim();
      final String nameArValue = item.nameAr.trim();
      return CrmStageChecklistItemModel(
        nameEn: nameEnValue,
        nameAr: nameArValue.isNotEmpty ? nameArValue : nameEnValue,
      );
    }).toList();

    final int probability = probabilityText == null
        ? stage?.probability ?? 0
        : (int.tryParse(probabilityText.trim()) ?? 0).clamp(0, 100);
    final bool succeeded = stage == null
        ? await dealsCubit.createStage(
            nameEn: nameEn,
            nameAr: nameAr,
            status: 'active',
            probability: probability,
            order: state.selectedOrder,
            checklistItems: checklistItems,
          )
        : await dealsCubit.updateStage(
            currentStage: stage,
            nameEn: nameEn,
            nameAr: nameAr,
            status: stage.status,
            probability: probability,
            color: stage.color,
            order: state.selectedOrder,
            checklistItems: checklistItems,
          );
    if (!isClosed) {
      emit(state.copyWith(isSubmitting: false, submitSucceeded: succeeded));
    }
  }

  bool _validateNames({
    required String nameEn,
    required String nameAr,
    required String nameEnMessage,
    required String nameArMessage,
  }) {
    final String? nameEnError = nameEn.trim().isEmpty ? nameEnMessage : null;
    final String? nameArError = nameAr.trim().isEmpty ? nameArMessage : null;
    emit(
      state.copyWith(
        nameEnError: nameEnError,
        nameArError: nameArError,
        clearNameEnError: nameEnError == null,
        clearNameArError: nameArError == null,
        submitSucceeded: false,
      ),
    );
    return nameEnError == null && nameArError == null;
  }

  void _updateChecklistItem(int id, {String? nameEn, String? nameAr}) {
    emit(
      state.copyWith(
        checklistInputs: state.checklistInputs
            .map(
              (CrmDealChecklistInput item) => item.id == id
                  ? item.copyWith(nameEn: nameEn, nameAr: nameAr)
                  : item,
            )
            .toList(),
      ),
    );
  }

  @override
  Future<void> close() {
    if (!dealsCubit.isClosed) dealsCubit.setFormOpen(false);
    return super.close();
  }
}
