// ****************** FILE INFO ******************
// File Name: crm_saved_section_template_draft_model.dart
// Purpose: Holds a copied saved section draft ready for template insertion
// Author: Mohand Adel
// Created At: 05/08/2026

import 'crm_template_field_model.dart';
import 'crm_template_section_model.dart';

class CrmSavedSectionTemplateDraftModel {
  final CrmTemplateSectionModel section;
  final List<CrmTemplateFieldModel> fields;

  const CrmSavedSectionTemplateDraftModel({
    required this.section,
    required this.fields,
  });
}
