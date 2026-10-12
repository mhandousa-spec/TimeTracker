// ****************** FILE INFO ******************
// File Name: crm_template_builder_state.dart
// Purpose: State model for CRM template builder
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';

class CrmTemplateBuilderState {
  final CrmTemplateModel? template;
  final List<CrmTemplateSectionModel> sections;
  final List<CrmTemplateFieldModel> fields;
  final List<CrmFieldTypeModel> fieldTypes;
  final List<CrmSavedSectionModel> savedSections;
  final CrmSavedSectionModel? selectedSavedSection;
  final List<CrmTemplateSectionModel> filteredSections;
  final List<CrmTemplateFieldModel> filteredFields;
  final String searchQuery;
  final bool isLoading;
  final bool isSaving;
  final bool isSavingAsSection;
  final String? errorMessage;
  final String? successMessage;
  final String? savedSectionErrorMessage;
  final String? savedSectionSuccessMessage;

  const CrmTemplateBuilderState({
    this.template,
    this.sections = const [],
    this.fields = const [],
    this.fieldTypes = const [],
    this.savedSections = const [],
    this.selectedSavedSection,
    this.filteredSections = const [],
    this.filteredFields = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.isSaving = false,
    this.isSavingAsSection = false,
    this.errorMessage,
    this.successMessage,
    this.savedSectionErrorMessage,
    this.savedSectionSuccessMessage,
  });

  CrmTemplateBuilderState copyWith({
    CrmTemplateModel? template,
    List<CrmTemplateSectionModel>? sections,
    List<CrmTemplateFieldModel>? fields,
    List<CrmFieldTypeModel>? fieldTypes,
    List<CrmSavedSectionModel>? savedSections,
    CrmSavedSectionModel? selectedSavedSection,
    List<CrmTemplateSectionModel>? filteredSections,
    List<CrmTemplateFieldModel>? filteredFields,
    String? searchQuery,
    bool? isLoading,
    bool? isSaving,
    bool? isSavingAsSection,
    String? errorMessage,
    String? successMessage,
    String? savedSectionErrorMessage,
    String? savedSectionSuccessMessage,
    bool clearMessages = false,
    bool clearSelectedSavedSection = false,
  }) {
    return CrmTemplateBuilderState(
      template: template ?? this.template,
      sections: sections ?? this.sections,
      fields: fields ?? this.fields,
      fieldTypes: fieldTypes ?? this.fieldTypes,
      savedSections: savedSections ?? this.savedSections,
      selectedSavedSection: clearSelectedSavedSection
          ? null
          : selectedSavedSection ?? this.selectedSavedSection,
      filteredSections: filteredSections ?? this.filteredSections,
      filteredFields: filteredFields ?? this.filteredFields,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSavingAsSection: isSavingAsSection ?? this.isSavingAsSection,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearMessages ? null : successMessage ?? this.successMessage,
      savedSectionErrorMessage: clearMessages
          ? null
          : savedSectionErrorMessage ?? this.savedSectionErrorMessage,
      savedSectionSuccessMessage: clearMessages
          ? null
          : savedSectionSuccessMessage ?? this.savedSectionSuccessMessage,
    );
  }
}
