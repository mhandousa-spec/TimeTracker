// ****************** FILE INFO ******************
// File Name: crm_template_builder_cubit.dart
// Purpose: Cubit for CRM template builder live Firestore state
// Author: Mohand Adel
// Created At: 05/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_template_draft_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_controls_defaults.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'crm_template_builder_state.dart';

class CrmTemplateBuilderCubit extends Cubit<CrmTemplateBuilderState> {
  final CrmControlsBaseRepository repository;
  StreamSubscription<Either<Failure, CrmTemplateModel?>>? _templateSubscription;
  StreamSubscription<Either<Failure, List<CrmTemplateSectionModel>>>?
      _sectionsSubscription;
  StreamSubscription<Either<Failure, List<CrmTemplateFieldModel>>>?
      _fieldsSubscription;
  StreamSubscription<Either<Failure, List<CrmFieldTypeModel>>>?
      _fieldTypesSubscription;
  StreamSubscription<Either<Failure, List<CrmSavedSectionModel>>>?
      _savedSectionsSubscription;
  String _templateId = '';
  String _clientTypeId = '';
  bool _fieldTypesBackfillAttempted = false;

  CrmTemplateBuilderCubit({CrmControlsBaseRepository? repository})
      : repository = repository ?? Get.find<CrmControlsBaseRepository>(),
        super(const CrmTemplateBuilderState());

  Future<void> init({
    required String templateId,
    required String clientTypeId,
  }) async {
    _templateId = templateId;
    _clientTypeId = clientTypeId;
    _fieldTypesBackfillAttempted = false;
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final Either<Failure, void> controlsDefaults =
        await repository.ensureDefaults(userEmail: _currentUserEmail);
    if (controlsDefaults.isLeft()) {
      controlsDefaults.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (_) {},
      );
      return;
    }
    final Either<Failure, void> defaults =
        await repository.ensureTemplateDefaults(
      templateId: templateId,
      clientTypeId: clientTypeId,
      userEmail: _currentUserEmail,
    );
    if (defaults.isLeft()) {
      defaults.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (_) {},
      );
      return;
    }
    final Either<Failure, void> savedDefaults =
        await repository.ensureDefaultSavedSections(
      clientTypeId: clientTypeId,
      userEmail: _currentUserEmail,
    );
    savedDefaults.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errMessage)),
      (_) {},
    );
    _watchTemplate(templateId);
    _watchSections(templateId);
    _watchFields(templateId);
    _watchFieldTypes(clientTypeId);
    _watchSavedSections(clientTypeId);
  }

  void search(String query) {
    final String normalizedQuery = query.trim();
    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        filteredSections: _filterSections(
          state.sections,
          state.fields,
          normalizedQuery,
        ),
        filteredFields: _filterStandaloneFields(
          state.fields,
          normalizedQuery,
        ),
        clearMessages: true,
      ),
    );
  }

  int fieldCountForSection(String sectionId) {
    return state.fields.where((field) => field.sectionId == sectionId).length;
  }

  List<CrmTemplateFieldModel> fieldsForSection(String sectionId) {
    return state.fields.where((field) => field.sectionId == sectionId).toList();
  }

  CrmTemplateSectionModel? sectionById(String sectionId) {
    for (final CrmTemplateSectionModel section in state.sections) {
      if (section.id == sectionId) return section;
    }
    return null;
  }

  CrmTemplateFieldModel? fieldById(String fieldId) {
    for (final CrmTemplateFieldModel field in state.fields) {
      if (field.id == fieldId) return field;
    }
    return null;
  }

  void selectSavedSection(String savedSectionId) {
    for (final CrmSavedSectionModel section in state.savedSections) {
      if (section.id == savedSectionId) {
        emit(
          state.copyWith(
            selectedSavedSection: section,
            clearMessages: true,
          ),
        );
        return;
      }
    }
    emit(
      state.copyWith(
        clearSelectedSavedSection: true,
        clearMessages: true,
      ),
    );
  }

  Future<CrmSavedSectionTemplateDraftModel?> applySavedSection(
    String savedSectionId,
  ) async {
    CrmSavedSectionModel? savedSection;
    for (final CrmSavedSectionModel section in state.savedSections) {
      if (section.id == savedSectionId) {
        savedSection = section;
        break;
      }
    }
    if (savedSection == null) {
      emit(
        state.copyWith(
          savedSectionErrorMessage: 'Saved section not found',
        ),
      );
      return null;
    }
    emit(state.copyWith(isSavingAsSection: true, clearMessages: true));
    final Either<Failure, CrmSavedSectionTemplateDraftModel> result =
        await repository.buildTemplateSectionFromSavedSection(
      templateId: _templateId,
      clientTypeId: _clientTypeId,
      savedSection: savedSection,
      order: state.sections.length + 1,
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSavingAsSection: false,
            savedSectionErrorMessage: failure.errMessage,
          ),
        );
        return null;
      },
      (draft) {
        emit(
          state.copyWith(
            selectedSavedSection: savedSection,
            isSavingAsSection: false,
            clearMessages: true,
          ),
        );
        return draft;
      },
    );
  }

  Future<bool> saveCurrentDraftAsSection({
    required CrmTemplateSectionModel section,
    required List<CrmTemplateFieldModel> fields,
  }) async {
    if (section.nameEn.trim().isEmpty || section.nameAr.trim().isEmpty) {
      emit(
        state.copyWith(
          savedSectionErrorMessage: 'Section English and Arabic names required',
        ),
      );
      return false;
    }
    if (fields.isEmpty) {
      emit(
        state.copyWith(
          savedSectionErrorMessage: 'Add at least one field',
        ),
      );
      return false;
    }

    emit(state.copyWith(isSavingAsSection: true, clearMessages: true));
    final CrmAuditModel audit = CrmAuditModel.now(userEmail: _currentUserEmail);
    final String savedSectionId =
        '${_safeId(_clientTypeId)}_custom_${DateTime.now().millisecondsSinceEpoch}';
    final CrmSavedSectionModel savedSection =
        CrmSavedSectionModel.fromTemplateSection(
      id: savedSectionId,
      section: section.copyWith(
        clientTypeId: _clientTypeId,
        systemKey: 'custom',
        isDefault: false,
        isDeleted: false,
        status: 'active',
      ),
      audit: audit,
      isSystem: false,
      isDefault: false,
      order: state.savedSections.length + 1,
    );
    final List<CrmSavedSectionFieldModel> savedFields = [];
    for (int index = 0; index < fields.length; index++) {
      final CrmTemplateFieldModel field = fields[index].copyWith(
        clientTypeId: _clientTypeId,
        sectionId: savedSectionId,
        isDefault: false,
        isDeleted: false,
        status: 'active',
      );
      final String fieldKey =
          field.systemKey.trim().isNotEmpty ? field.systemKey : field.nameEn;
      savedFields.add(
        CrmSavedSectionFieldModel.fromTemplateField(
          id: '${savedSectionId}_${_safeId(fieldKey)}_${index + 1}',
          savedSectionId: savedSectionId,
          field: field,
          audit: audit,
          isSystem: false,
          isDefault: false,
          order: index + 1,
        ),
      );
    }
    final Either<Failure, void> result =
        await repository.saveReusableSectionWithFields(
      section: savedSection,
      fields: savedFields,
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSavingAsSection: false,
            savedSectionErrorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            isSavingAsSection: false,
            savedSectionSuccessMessage: 'Section saved',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> saveSectionWithFields({
    required CrmTemplateSectionModel section,
    required List<CrmTemplateFieldModel> fields,
  }) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result =
        await repository.saveTemplateSectionWithFields(
      section: section,
      fields: fields,
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'saved'));
        return true;
      },
    );
  }

  Future<bool> saveTemplateFields({
    required List<CrmTemplateFieldModel> fields,
  }) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    for (final CrmTemplateFieldModel field in fields) {
      final bool exists = state.fields.any((item) => item.id == field.id);
      final Either<Failure, void> result = exists
          ? await repository.updateTemplateField(
              field: field,
              changedBy: _currentUserEmail,
            )
          : await repository.addTemplateField(
              field: field,
              changedBy: _currentUserEmail,
            );
      if (result.isLeft()) {
        result.fold(
          (failure) => emit(
            state.copyWith(
              isSaving: false,
              errorMessage: failure.errMessage,
            ),
          ),
          (_) {},
        );
        return false;
      }
    }
    emit(state.copyWith(isSaving: false, successMessage: 'saved'));
    return true;
  }

  Future<bool> removeField(CrmTemplateFieldModel field) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.removeTemplateField(
      templateId: field.templateId,
      fieldId: field.id,
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'deleted'));
        return true;
      },
    );
  }

  Future<bool> removeSectionWithFields({
    required String templateId,
    required String sectionId,
  }) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result =
        await repository.removeTemplateSectionWithFields(
      templateId: templateId,
      sectionId: sectionId,
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'deleted'));
        return true;
      },
    );
  }

  Future<bool> updateTemplateStatus(String status) async {
    final CrmTemplateModel? template = state.template;
    if (template == null) return false;
    final String normalizedStatus = _statusValue(status);
    if (template.status.toLowerCase() == normalizedStatus) return true;
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.updateTemplateStatus(
      templateId: template.id,
      status: normalizedStatus,
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'status_changed'));
        return true;
      },
    );
  }

  String _statusValue(String status) {
    final String value = status.trim().toLowerCase();
    if (value == 'inactive') return 'draft';
    if (value == 'deleted') return 'deleted';
    return 'active';
  }

  Future<bool> updateTemplateNames({
    required String nameEn,
    required String nameAr,
  }) async {
    final CrmTemplateModel? template = state.template;
    if (template == null) return false;
    if (nameEn.trim().isEmpty || nameAr.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Template names are required'));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.updateTemplateNames(
      templateId: template.id,
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      changedBy: _currentUserEmail,
    );
    return result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'updated'));
        return true;
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  void _watchTemplate(String templateId) {
    _templateSubscription?.cancel();
    _templateSubscription =
        repository.watchTemplate(templateId: templateId).listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (template) => emit(
          state.copyWith(
            template: template,
            isLoading: false,
            clearMessages: true,
          ),
        ),
      );
    });
  }

  void _watchSections(String templateId) {
    _sectionsSubscription?.cancel();
    _sectionsSubscription =
        repository.watchTemplateSections(templateId: templateId).listen(
      (result) {
        result.fold(
          (failure) => emit(
            state.copyWith(isLoading: false, errorMessage: failure.errMessage),
          ),
          (sections) => emit(
            state.copyWith(
              sections: sections,
              filteredSections: _filterSections(
                sections,
                state.fields,
                state.searchQuery,
              ),
              filteredFields: _filterStandaloneFields(
                state.fields,
                state.searchQuery,
              ),
              isLoading: false,
              clearMessages: true,
            ),
          ),
        );
      },
    );
  }

  void _watchFields(String templateId) {
    _fieldsSubscription?.cancel();
    _fieldsSubscription =
        repository.watchTemplateFields(templateId: templateId).listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (fields) => emit(
          state.copyWith(
            fields: fields,
            filteredSections: _filterSections(
              state.sections,
              fields,
              state.searchQuery,
            ),
            filteredFields: _filterStandaloneFields(
              fields,
              state.searchQuery,
            ),
            isLoading: false,
            clearMessages: true,
          ),
        ),
      );
    });
  }

  void _watchFieldTypes(String clientTypeId) {
    _fieldTypesSubscription?.cancel();
    _fieldTypesSubscription =
        repository.watchFieldTypes(clientTypeId: clientTypeId).listen((result) {
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.errMessage)),
        (fieldTypes) {
          emit(
            state.copyWith(fieldTypes: fieldTypes, clearMessages: true),
          );
          unawaited(_auditAndRepairFieldTypes(fieldTypes));
        },
      );
    });
  }

  Future<void> _auditAndRepairFieldTypes(
    List<CrmFieldTypeModel> fieldTypes,
  ) async {
    if (_fieldTypesBackfillAttempted) return;

    final List<String> expectedIds =
        CrmControlsDefaults.expectedFieldTypeIdsForClientType(_clientTypeId);
    final Set<String> loadedIds =
        fieldTypes.map((CrmFieldTypeModel type) => type.id).toSet();
    final List<String> missingIds =
        expectedIds.where((String id) => !loadedIds.contains(id)).toList();

    if (missingIds.isEmpty) return;

    _fieldTypesBackfillAttempted = true;
    debugPrint(
      'CRM field types drift detected for $_clientTypeId. Missing: $missingIds',
    );

    final Either<Failure, void> result =
        await repository.ensureDefaults(userEmail: _currentUserEmail);
    result.fold(
      (Failure failure) => emit(
        state.copyWith(errorMessage: failure.errMessage),
      ),
      (_) {},
    );
  }

  void _watchSavedSections(String clientTypeId) {
    _savedSectionsSubscription?.cancel();
    _savedSectionsSubscription =
        repository.watchSavedSections(clientTypeId: clientTypeId).listen(
      (result) {
        result.fold(
          (failure) => emit(
            state.copyWith(savedSectionErrorMessage: failure.errMessage),
          ),
          (savedSections) {
            final CrmSavedSectionModel? selected =
                _selectedSavedSectionFrom(savedSections);
            emit(
              state.copyWith(
                savedSections: savedSections,
                selectedSavedSection: selected,
                clearSelectedSavedSection: selected == null,
                clearMessages: true,
              ),
            );
          },
        );
      },
    );
  }

  CrmSavedSectionModel? _selectedSavedSectionFrom(
    List<CrmSavedSectionModel> savedSections,
  ) {
    final CrmSavedSectionModel? selected = state.selectedSavedSection;
    if (selected == null) return null;
    for (final CrmSavedSectionModel section in savedSections) {
      if (section.id == selected.id) return section;
    }
    return null;
  }

  List<CrmTemplateSectionModel> _filterSections(
    List<CrmTemplateSectionModel> sections,
    List<CrmTemplateFieldModel> fields,
    String query,
  ) {
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return sections;
    return sections.where((section) {
      final bool matchesSection =
          section.nameEn.toLowerCase().contains(normalizedQuery) ||
              section.nameAr.toLowerCase().contains(normalizedQuery);
      final bool matchesField = fields
          .where((field) => field.sectionId == section.id)
          .any((field) =>
              field.nameEn.toLowerCase().contains(normalizedQuery) ||
              field.nameAr.toLowerCase().contains(normalizedQuery));
      return matchesSection || matchesField;
    }).toList();
  }

  List<CrmTemplateFieldModel> _filterStandaloneFields(
    List<CrmTemplateFieldModel> fields,
    String query,
  ) {
    final List<CrmTemplateFieldModel> standaloneFields = fields
        .where(
          (field) => field.sectionId == null || field.sectionId!.isEmpty,
        )
        .toList();
    final String normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return standaloneFields;
    return standaloneFields.where((field) {
      return field.nameEn.toLowerCase().contains(normalizedQuery) ||
          field.nameAr.toLowerCase().contains(normalizedQuery) ||
          field.fieldTypeId.toLowerCase().contains(normalizedQuery);
    }).toList();
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

  String _safeId(String value) {
    final String cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return cleaned.isEmpty ? 'section' : cleaned;
  }

  @override
  Future<void> close() async {
    await _templateSubscription?.cancel();
    await _sectionsSubscription?.cancel();
    await _fieldsSubscription?.cancel();
    await _fieldTypesSubscription?.cancel();
    await _savedSectionsSubscription?.cancel();
    return super.close();
  }
}
