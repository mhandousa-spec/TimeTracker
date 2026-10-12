// ****************** FILE INFO ******************
// File Name: crm_client_form_cubit.dart
// Purpose: Cubit managing the dynamic client form: template loading, dynamic
//          validation, media uploads, and client record persistence
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/usecases/upload_client_files_use_case.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_layout_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'crm_client_form_state.dart';
import 'crm_field_validator.dart';

/// Manages the dynamic add/edit client form state and client persistence.
///
/// Repositories and the upload use case are injected (rule 4/18); validation
/// and platform file uploads are delegated to [CrmFieldValidator] and
/// [UploadClientFilesUseCase] so this Cubit stays thin and platform-free.
class CrmClientFormCubit extends Cubit<CrmClientFormState> {
  final CrmControlsBaseRepository controlsRepository;
  final CrmClientsBaseRepository clientsRepository;
  final UploadClientFilesUseCase uploadClientFilesUseCase;

  CrmClientFormCubit({
    CrmControlsBaseRepository? controlsRepository,
    CrmClientsBaseRepository? clientsRepository,
    UploadClientFilesUseCase? uploadClientFilesUseCase,
  })  : controlsRepository =
            controlsRepository ?? Get.find<CrmControlsBaseRepository>(),
        clientsRepository =
            clientsRepository ?? Get.find<CrmClientsBaseRepository>(),
        uploadClientFilesUseCase =
            uploadClientFilesUseCase ?? Get.find<UploadClientFilesUseCase>(),
        super(const CrmClientFormState());

  /// Loads the client type, its published template, sections, fields and
  /// layout for the dynamic form. [clientTypeId] takes precedence; when it is
  /// null the type is resolved from [clientTypeName] (display name or system
  /// key). [templateId] optionally pins the exact template to render (e.g.
  /// when opened from a specific template). Pass [editingRecord] to populate
  /// the form for editing.
  Future<void> init({
    String? clientTypeId,
    String? clientTypeName,
    String? templateId,
    CrmClientRecordModel? editingRecord,
  }) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));

    final Either<Failure, void> defaults =
        await controlsRepository.ensureDefaults(userEmail: _currentUserEmail);
    if (defaults.isLeft()) {
      defaults.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        ),
        (_) {},
      );
      return;
    }

    // 1. Resolve the client type.
    final CrmClientTypeModel? clientType = await _resolveClientType(
      clientTypeId: clientTypeId,
      clientTypeName: clientTypeName,
    );
    if (clientType == null || state.errorMessage != null) return;
    emit(state.copyWith(clientType: clientType));

    // 2. Resolve the template (exact id first, then active for this type).
    final CrmTemplateModel? template =
        await _resolveTemplate(clientType.id, templateId: templateId);
    if (template == null || state.errorMessage != null) return;
    emit(state.copyWith(template: template));

    // 3. Load sections, fields and layout in parallel.
    final List<CrmTemplateSectionModel> sections = await _watchRight(
      controlsRepository.watchTemplateSections(templateId: template.id),
    );
    final List<CrmTemplateFieldModel> fields = await _watchRight(
      controlsRepository.watchTemplateFields(templateId: template.id),
    );
    final CrmTemplateLayoutModel? layout = await _watchRightNullable(
      controlsRepository.watchTemplateLayout(templateId: template.id),
    );
    if (state.errorMessage != null) return;

    emit(
      state.copyWith(
        sections: sections,
        fields: fields,
        layout: layout,
        formValues: Map<String, dynamic>.from(
          editingRecord?.values ?? const <String, dynamic>{},
        ),
        formErrors: const <String, String?>{},
        isEditing: editingRecord != null,
        editingRecordId: editingRecord?.id,
        editingRecordAudit: editingRecord?.audit,
        isLoading: false,
        clearMessages: true,
      ),
    );
  }

  /// Stores a field value keyed by [fieldId] and clears its error.
  void onFieldValueChanged(String fieldId, dynamic value) {
    final Map<String, String?> errors =
        Map<String, String?>.from(state.formErrors)
          ..remove(fieldId)
          ..remove(CrmFieldValidator.englishKey(fieldId))
          ..remove(CrmFieldValidator.arabicKey(fieldId));
    emit(
      state.copyWith(
        formValues: {...state.formValues, fieldId: value},
        formErrors: errors,
        clearMessages: true,
      ),
    );
  }

  /// Validates all fields against template metadata. Returns true when the
  /// whole form is valid.
  bool validateForm({List<CrmTemplateFieldModel>? fields}) {
    final Map<String, String?> errors = <String, String?>{};
    for (final CrmTemplateFieldModel field
        in _activeTemplateFields(fields ?? state.fields)) {
      errors.addAll(CrmFieldValidator.validateErrorEntries(
        field,
        state.formValues[field.id],
        isArabic: _isArabic,
      ));
    }
    emit(state.copyWith(formErrors: errors, clearMessages: true));
    return errors.isEmpty;
  }

  /// Reports whether all active fields are currently valid without mutating
  /// the form error state. Used to control the final Add action.
  bool canSubmit({List<CrmTemplateFieldModel>? fields}) {
    return _activeTemplateFields(fields ?? state.fields).every(
      (CrmTemplateFieldModel field) => CrmFieldValidator.validateErrorEntries(
        field,
        state.formValues[field.id],
        isArabic: _isArabic,
      ).isEmpty,
    );
  }

  /// Validates a subset of fields, used by multi-page form navigation.
  bool validateFields(List<CrmTemplateFieldModel> fields) {
    final Map<String, String?> errors =
        Map<String, String?>.from(state.formErrors);
    for (final CrmTemplateFieldModel field in fields) {
      errors
        ..remove(field.id)
        ..remove(CrmFieldValidator.englishKey(field.id))
        ..remove(CrmFieldValidator.arabicKey(field.id));
      errors.addAll(CrmFieldValidator.validateErrorEntries(
        field,
        state.formValues[field.id],
        isArabic: _isArabic,
      ));
    }
    emit(state.copyWith(formErrors: errors, clearMessages: true));
    return fields.every(
      (CrmTemplateFieldModel field) =>
          errors[field.id] == null &&
          errors[CrmFieldValidator.englishKey(field.id)] == null &&
          errors[CrmFieldValidator.arabicKey(field.id)] == null,
    );
  }

  /// Uploads pending File values, then creates or updates the client record.
  /// Returns true on success.
  Future<bool> submitClientRecord({
    List<CrmTemplateFieldModel>? validationFields,
  }) async {
    if (!validateForm(fields: validationFields)) return false;

    final CrmTemplateModel? template = state.template;
    final CrmClientTypeModel? clientType = state.clientType;
    if (template == null || clientType == null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Client form is not ready',
        ),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    final String userEmail = _currentUserEmail;

    final Map<String, dynamic> uploaded =
        await _uploadPendingFiles(state.formValues);
    if (state.errorMessage != null) {
      emit(state.copyWith(isSubmitting: false));
      return false;
    }

    final CrmAuditModel audit = state.isEditing
        ? (state.editingRecordAudit ?? CrmAuditModel.now(userEmail: userEmail))
            .markUpdated(userEmail: userEmail)
        : CrmAuditModel.now(userEmail: userEmail);

    final CrmClientRecordModel record = CrmClientRecordModel(
      id: _recordId,
      clientTypeId: clientType.id,
      templateId: template.id,
      templateVersion: template.version,
      status: 'active',
      values: uploaded,
      audit: audit,
    );

    final Either<Failure, CrmClientRecordModel> result =
        await clientsRepository.saveClientRecord(record: record);

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (saved) {
        emit(
          state.copyWith(
            isSubmitting: false,
            clientId: saved.id,
            clearMessages: true,
          ),
        );
        return true;
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<CrmTemplateFieldModel> _activeTemplateFields(
    List<CrmTemplateFieldModel> fields,
  ) {
    return fields
        .where(
          (CrmTemplateFieldModel field) =>
              !field.isDeleted && field.status.toLowerCase() != 'deleted',
        )
        .toList();
  }

  Future<CrmClientTypeModel?> _resolveClientType({
    required String? clientTypeId,
    required String? clientTypeName,
  }) async {
    final List<CrmClientTypeModel> types = await _watchRight(
      controlsRepository.watchClientTypes(),
    );
    if (types.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'No client types available',
        ),
      );
      return null;
    }

    final String normalizedName = (clientTypeName ?? '').trim().toLowerCase();
    final String normalizedId = (clientTypeId ?? '').trim().toLowerCase();

    if (normalizedId.isNotEmpty) {
      for (final CrmClientTypeModel type in types) {
        if (type.id.toLowerCase() == normalizedId) return type;
      }
    }
    if (normalizedName.isNotEmpty) {
      for (final CrmClientTypeModel type in types) {
        final bool matchesKey =
            (type.systemKey ?? '').toLowerCase() == normalizedName;
        final bool matchesName = type.nameEn.toLowerCase() == normalizedName ||
            type.nameAr == clientTypeName?.trim();
        if (matchesKey || matchesName) return type;
      }
    }
    return types.first;
  }

  Future<CrmTemplateModel?> _resolveTemplate(
    String clientTypeId, {
    String? templateId,
  }) async {
    final List<CrmTemplateModel> templates = await _watchRight(
      controlsRepository.watchTemplates(),
    );

    // Exact template pinned by the caller (template-scoped add flow).
    if (templateId != null && templateId.trim().isNotEmpty) {
      for (final CrmTemplateModel template in templates) {
        if (template.id == templateId) return template;
      }
    }

    final List<CrmTemplateModel> forType = templates
        .where((template) => template.clientTypeId == clientTypeId)
        .toList();

    for (final CrmTemplateModel template in forType) {
      if (template.status.toLowerCase() == 'active' ||
          template.status.toLowerCase() == 'published') {
        return template;
      }
    }
    if (forType.isNotEmpty) return forType.first;

    emit(
      state.copyWith(
        isLoading: false,
        errorMessage:
            'No template found for client type: ${state.clientType?.nameEn ?? clientTypeId}',
      ),
    );
    return null;
  }

  Future<List<T>> _watchRight<T>(
    Stream<Either<Failure, List<T>>> stream,
  ) async {
    final Either<Failure, List<T>> result = await stream.first;
    return result.fold(
      (failure) {
        emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        );
        return <T>[];
      },
      (items) => items,
    );
  }

  Future<T?> _watchRightNullable<T>(
    Stream<Either<Failure, T?>> stream,
  ) async {
    final Either<Failure, T?> result = await stream.first;
    return result.fold(
      (failure) {
        emit(
          state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        );
        return null;
      },
      (item) => item,
    );
  }

  /// Delegates pending platform file uploads to [UploadClientFilesUseCase]
  /// (rule 17): the Cubit never touches [File] objects itself.
  Future<Map<String, dynamic>> _uploadPendingFiles(
    Map<String, dynamic> values,
  ) async {
    final Either<Failure, Map<String, dynamic>> result =
        await uploadClientFilesUseCase.execute(
      values: values,
      recordId: _recordId,
    );
    final Failure? failure = result.fold((left) => left, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: failure.errMessage,
        ),
      );
      return values;
    }
    return result.getOrElse(() => values);
  }

  /// Stable record id: the editing record's id when editing, otherwise a new
  /// timestamp-based id shared by the upload step and the save step.
  String get _recordId {
    final String? editingId = state.isEditing ? state.editingRecordId : null;
    return (editingId != null && editingId.trim().isNotEmpty)
        ? editingId
        : 'client_record_${DateTime.now().microsecondsSinceEpoch}';
  }

  bool get _isArabic => Get.locale.toString().contains('ar');

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
}
