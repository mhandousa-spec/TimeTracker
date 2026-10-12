// ****************** FILE INFO ******************
// File Name: crm_deal_form_state.dart
// Purpose: Immutable controller state for CRM deal category and stage forms
// Author: Mohand Adel
// Created At: 22/08/2026

class CrmDealChecklistInput {
  final int id;
  final String nameEn;
  final String nameAr;

  const CrmDealChecklistInput({
    required this.id,
    this.nameEn = '',
    this.nameAr = '',
  });

  CrmDealChecklistInput copyWith({String? nameEn, String? nameAr}) {
    return CrmDealChecklistInput(
      id: id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
    );
  }
}

class CrmDealOrderOption {
  final int value;
  final String label;

  const CrmDealOrderOption({required this.value, required this.label});
}

class CrmDealFormState {
  final String? nameEnError;
  final String? nameArError;
  final bool isSubmitting;
  final bool submitSucceeded;
  final int? selectedOrder;
  final List<CrmDealOrderOption> orderOptions;
  final String probabilityText;
  final List<CrmDealChecklistInput> checklistInputs;

  const CrmDealFormState({
    this.nameEnError,
    this.nameArError,
    this.isSubmitting = false,
    this.submitSucceeded = false,
    this.selectedOrder,
    this.orderOptions = const <CrmDealOrderOption>[],
    this.probabilityText = '',
    this.checklistInputs = const <CrmDealChecklistInput>[],
  });

  CrmDealFormState copyWith({
    String? nameEnError,
    String? nameArError,
    bool clearNameEnError = false,
    bool clearNameArError = false,
    bool? isSubmitting,
    bool? submitSucceeded,
    int? selectedOrder,
    List<CrmDealOrderOption>? orderOptions,
    String? probabilityText,
    List<CrmDealChecklistInput>? checklistInputs,
  }) {
    return CrmDealFormState(
      nameEnError: clearNameEnError ? null : nameEnError ?? this.nameEnError,
      nameArError: clearNameArError ? null : nameArError ?? this.nameArError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      orderOptions: orderOptions ?? this.orderOptions,
      probabilityText: probabilityText ?? this.probabilityText,
      checklistInputs: checklistInputs ?? this.checklistInputs,
    );
  }
}
