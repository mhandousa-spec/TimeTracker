// ****************** FILE INFO ******************
// File Name: crm_client_form_state.dart
// Purpose: State model for the dynamic CRM client form controller
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_layout_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';

/// State for [CrmClientFormCubit] covering the whole lifecycle:
/// - initial: empty state before [CrmClientFormCubit.init].
/// - loading: [isLoading] while fetching template, sections, fields, layout.
/// - loaded: [template] != null && !isLoading — holds [sections], [fields],
///   [layout], [formValues] and [formErrors].
/// - submitting: [isSubmitting] while uploading media and saving the record.
/// - success: [clientId] != null — the record was created/updated.
/// - error: [errorMessage] != null.
class CrmClientFormState {
  final CrmClientTypeModel? clientType;
  final CrmTemplateModel? template;
  final List<CrmTemplateSectionModel> sections;
  final List<CrmTemplateFieldModel> fields;
  final CrmTemplateLayoutModel? layout;
  final Map<String, dynamic> formValues;
  final Map<String, String?> formErrors;
  final bool isLoading;
  final bool isSubmitting;
  final bool isEditing;
  final String? editingRecordId;
  final CrmAuditModel? editingRecordAudit;
  final String? clientId;
  final String? errorMessage;

  const CrmClientFormState({
    this.clientType,
    this.template,
    this.sections = const [],
    this.fields = const [],
    this.layout,
    this.formValues = const {},
    this.formErrors = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.isEditing = false,
    this.editingRecordId,
    this.editingRecordAudit,
    this.clientId,
    this.errorMessage,
  });

  bool get isLoaded => template != null && !isLoading;

  CrmClientFormState copyWith({
    CrmClientTypeModel? clientType,
    CrmTemplateModel? template,
    List<CrmTemplateSectionModel>? sections,
    List<CrmTemplateFieldModel>? fields,
    CrmTemplateLayoutModel? layout,
    Map<String, dynamic>? formValues,
    Map<String, String?>? formErrors,
    bool? isLoading,
    bool? isSubmitting,
    bool? isEditing,
    String? editingRecordId,
    CrmAuditModel? editingRecordAudit,
    String? clientId,
    bool clearClientId = false,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return CrmClientFormState(
      clientType: clientType ?? this.clientType,
      template: template ?? this.template,
      sections: sections ?? this.sections,
      fields: fields ?? this.fields,
      layout: layout ?? this.layout,
      formValues: formValues ?? this.formValues,
      formErrors: formErrors ?? this.formErrors,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isEditing: isEditing ?? this.isEditing,
      editingRecordId: editingRecordId ?? this.editingRecordId,
      editingRecordAudit: editingRecordAudit ?? this.editingRecordAudit,
      clientId: clearClientId ? null : clientId ?? this.clientId,
      errorMessage: clearMessages ? null : errorMessage,
    );
  }
}
