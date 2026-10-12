// ****************** FILE INFO ******************
// File Name: crm_template_element_form_page.dart
// Purpose: Firestore-backed CRM template section and field editor page
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_template_draft_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_details_actions_bar.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_element_form_actions.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_element_validator.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edits_list.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_section_details_panel.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_setting_section.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_state_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateElementFormPage extends StatefulWidget {
  const CrmTemplateElementFormPage({
    required this.templateId,
    required this.templateName,
    required this.clientTypeId,
    required this.clientType,
    required this.sectionId,
    required this.fieldId,
    required this.isSection,
    required this.isEditing,
    super.key,
  });

  final String templateId;
  final String templateName;
  final String clientTypeId;
  final String clientType;
  final String sectionId;
  final String fieldId;
  final bool isSection;
  final bool isEditing;

  @override
  State<CrmTemplateElementFormPage> createState() =>
      _CrmTemplateElementFormPageState();
}

class _CrmTemplateElementFormPageState
    extends State<CrmTemplateElementFormPage> {
  final TextEditingController _sectionNameEnController =
      TextEditingController();
  final TextEditingController _sectionNameArController =
      TextEditingController();
  final List<CrmTemplateFieldEditModel> _fieldEdits = [];

  bool _isSettingExpanded = true;
  bool _isSectionDetailsExpanded = true;
  bool _isDirty = false;
  bool _draftPrepared = false;
  late bool _isEditingMode;
  String _loadedSignature = '';
  late String _selectedCategory;
  CrmTemplateSectionModel? _section;
  String? _sectionNameEnError;
  String? _sectionNameArError;

  @override
  void initState() {
    super.initState();
    _isEditingMode = widget.isEditing || _isAddMode;
    _selectedCategory = _isExistingSectionMode
        ? 'Section'
        : _isExistingFieldMode
            ? 'Fields'
            : '';
    _sectionNameEnController.addListener(_onFieldInputChanged);
    _sectionNameArController.addListener(_onFieldInputChanged);
    if (widget.templateId.isNotEmpty && widget.clientTypeId.isNotEmpty) {
      context.read<CrmTemplateBuilderCubit>().init(
            templateId: widget.templateId,
            clientTypeId: widget.clientTypeId,
          );
    }
  }

  @override
  void dispose() {
    _sectionNameEnController.dispose();
    _sectionNameArController.dispose();
    _disposeFieldEditsNow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmControlTemplates,
        secondTitle: widget.templateName,
        thirdTitle: _pageTitle,
        onFirstTap: () => CrmNavigationHelper.pop(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocConsumer<CrmTemplateBuilderCubit, CrmTemplateBuilderState>(
          listener: (context, state) {},
          builder: (context, state) {
            _syncFromState(state);
            if (state.isLoading &&
                ((_isExistingSectionMode && _section == null) ||
                    (_isExistingFieldMode && _fieldEdits.isEmpty))) {
              return const CrmTemplateStateView(
                isLoading: true,
                errorMessage: null,
                child: SizedBox.shrink(),
              );
            }
            if (_isExistingSectionMode && _section == null) {
              return const CrmTemplateStateView(
                isLoading: false,
                errorMessage: 'Section not found',
                child: SizedBox.shrink(),
              );
            }
            if (_isExistingFieldMode && _fieldEdits.isEmpty) {
              return const CrmTemplateStateView(
                isLoading: false,
                errorMessage: 'Field not found',
                child: SizedBox.shrink(),
              );
            }
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CrmTemplateBuilderState state,
  ) {
    final String? operationError =
        state.errorMessage ?? state.savedSectionErrorMessage;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isDetailsMode) ...[
            CrmTemplateDetailsActionsBar(
              onEdit: () => setState(() => _isEditingMode = true),
              onRemove: () => _confirmRemove(context),
            ),
            SizedBox(height: 24.sp),
          ],
          if (_isAddMode) ...[
            CrmTemplateSettingSection(
              isExpanded: _isSettingExpanded,
              selectedCategory: _selectedCategory,
              onToggle: () {
                setState(() => _isSettingExpanded = !_isSettingExpanded);
              },
              onCategoryChanged: (String value) {
                setState(() {
                  _selectedCategory = value;
                  if (value == 'Section') {
                    _section ??= _createDraftSection();
                    _clearFieldEditsAfterFrame();
                    _draftPrepared = false;
                    _ensureInitialField();
                  } else if (value == 'Fields') {
                    _section = null;
                    _clearFieldEditsAfterFrame();
                    _draftPrepared = false;
                    _ensureInitialField();
                  }
                  _isDirty = true;
                });
              },
            ),
            SizedBox(height: 16.sp),
          ],
          if (_showsSectionDetails) ...[
            CrmTemplateSectionDetailsPanel(
              isExpanded: _isSectionDetailsExpanded,
              nameEnController: _sectionNameEnController,
              nameArController: _sectionNameArController,
              readOnly: _isReadOnly,
              onToggle: () {
                setState(() {
                  _isSectionDetailsExpanded = !_isSectionDetailsExpanded;
                });
              },
              showSavedSectionsSelector: _canUseSavedSections,
              savedSections: state.savedSections,
              selectedSavedSectionId: state.selectedSavedSection?.id ?? '',
              onSavedSectionChanged: (String value) {
                _applySavedSection(context, value);
              },
              nameEnError: _sectionNameEnError,
              nameArError: _sectionNameArError,
            ),
            SizedBox(height: 16.sp),
          ],
          CrmTemplateFieldEditsList(
            fieldEdits: _fieldEdits,
            fieldTypes: state.fieldTypes,
            readOnly: _isReadOnly,
            showRemove: !_isExistingFieldMode,
            operationError: operationError,
            onChanged: () {
              setState(() => _isDirty = true);
            },
            onRemove: (edit) => _confirmRemoveField(context, edit),
          ),
          if (!_isReadOnly) ...[
            CrmTemplateElementFormActions(
              onDiscard: () => _discard(context),
              onAddField: _addField,
              showAddField: !_isExistingFieldMode,
              canUseSavedSections: _canUseSavedSections,
              isSavingAsSection: state.isSavingAsSection,
              onSaveAsSection: () => _saveAsSection(context),
              isFormValid: _isFormValid,
              isSaving: state.isSaving,
              isAddMode: _isAddMode,
              onSave: () => _confirmSave(context),
            ),
          ],
          SizedBox(height: 24.sp),
        ],
      ),
    );
  }

  String get _pageTitle {
    if (_isExistingFieldMode) {
      return _isEditingMode ? 'Edit Field' : 'Field';
    }
    if (_isExistingSectionMode) {
      return _isEditingMode ? 'Edit Section' : 'Section';
    }
    return 'Add Field & Section';
  }

  void _syncFromState(CrmTemplateBuilderState state) {
    if (_isExistingFieldMode) {
      final CrmTemplateFieldModel? field =
          context.read<CrmTemplateBuilderCubit>().fieldById(widget.fieldId);
      final String signature = field?.id ?? '';
      if (_isDirty && signature == _loadedSignature) return;
      if (field == null || signature == _loadedSignature) return;
      _section = null;
      _replaceFieldEdits([field]);
      _loadedSignature = signature;
      _isDirty = false;
      return;
    }
    if (!_isExistingSectionMode) {
      if (_selectedCategory == 'Fields' && !_draftPrepared) {
        _ensureInitialField();
      }
      return;
    }
    final CrmTemplateSectionModel? section =
        context.read<CrmTemplateBuilderCubit>().sectionById(widget.sectionId);
    final List<CrmTemplateFieldModel> fields =
        context.read<CrmTemplateBuilderCubit>().fieldsForSection(
              widget.sectionId,
            );
    final String signature =
        '${section?.id}|${fields.map((e) => e.id).join(',')}';
    if (_isDirty && signature == _loadedSignature) return;
    if (section == null || signature == _loadedSignature) return;
    _section = section;
    _sectionNameEnController.text = section.nameEn;
    _sectionNameArController.text = section.nameAr;
    _replaceFieldEdits(fields);
    _loadedSignature = signature;
    _isDirty = false;
  }

  void _addField() {
    if (_selectedCategory.isEmpty) {
      _selectedCategory = 'Fields';
    }
    if (_selectedCategory == 'Section') {
      _section ??= _createDraftSection();
    }
    final CrmTemplateSectionModel? section =
        _selectedCategory == 'Section' ? _section : null;
    final int order = _fieldEdits.length + 1;
    final CrmTemplateFieldModel field = _createDraftField(
      order: order,
      sectionId: section?.id,
    );
    final CrmTemplateFieldEditModel edit =
        CrmTemplateFieldEditModel.fromField(field);
    _attachListenersToEdit(edit);
    setState(() {
      _fieldEdits.add(edit);
      _draftPrepared = true;
      _isDirty = true;
    });
  }

  Future<void> _confirmSave(BuildContext context) async {
    if (_isAddMode) {
      await _performSave(context);
      return;
    }
    await CrmControlDialogs.showSaveDialog(
      context: context,
      title: 'Save',
      subtitle: 'Are you sure to save Changes?',
      onConfirm: () => _performSave(context),
    );
  }

  Future<void> _performSave(BuildContext context) async {
    showLoadingIndicator();
    final bool saved = await _saveWithoutNavigation(context);
    hideLoadingIndicator();
    if (!mounted || !saved) return;
    setState(() {
      _isDirty = false;
      if (!_isAddMode) _isEditingMode = false;
    });
    await CrmControlDialogs.showSuccessDialog(
      context: this.context,
      title: 'Successful!',
      subtitle: 'submit successfully.',
      onComplete: () {
        if (_isAddMode && mounted) {
          CrmNavigationHelper.pop(this.context);
        }
      },
    );
  }

  Future<bool> _saveWithoutNavigation(BuildContext context) async {
    bool hasValidationError = false;

    if (_selectedCategory == 'Section' || _isExistingSectionMode) {
      final (:enError, :arError) =
          CrmTemplateElementValidator.validateSectionNames(
        nameEn: _sectionNameEnController.text,
        nameAr: _sectionNameArController.text,
      );
      _sectionNameEnError = enError;
      _sectionNameArError = arError;
      if (enError != null || arError != null) {
        hasValidationError = true;
      }
    }

    if (_fieldEdits.isEmpty) {
      return false;
    }

    for (final CrmTemplateFieldEditModel edit in _fieldEdits) {
      if (CrmTemplateElementValidator.validateFieldEdit(edit)) {
        hasValidationError = true;
      }
    }

    if (hasValidationError) {
      setState(() {});
      return false;
    }

    final List<CrmTemplateFieldModel> fields =
        _fieldEdits.map((edit) => edit.toField()).toList();
    if (_selectedCategory == 'Fields' || _isExistingFieldMode) {
      return context.read<CrmTemplateBuilderCubit>().saveTemplateFields(
            fields: fields,
          );
    }
    final CrmTemplateSectionModel savedSection = _currentSectionWithNames();
    final List<CrmTemplateFieldModel> sectionFields =
        _attachFieldsToSection(savedSection, fields);
    return context.read<CrmTemplateBuilderCubit>().saveSectionWithFields(
          section: savedSection,
          fields: sectionFields,
        );
  }

  Future<void> _applySavedSection(
    BuildContext context,
    String savedSectionId,
  ) async {
    final CrmSavedSectionTemplateDraftModel? draft =
        await context.read<CrmTemplateBuilderCubit>().applySavedSection(
              savedSectionId,
            );
    if (!mounted || draft == null) return;
    setState(() {
      _selectedCategory = 'Section';
      _section = draft.section;
      _sectionNameEnController.text = draft.section.nameEn;
      _sectionNameArController.text = draft.section.nameAr;
      _replaceFieldEdits(draft.fields);
      _loadedSignature = draft.section.id;
      _draftPrepared = true;
      _isDirty = true;
    });
  }

  Future<void> _saveAsSection(BuildContext context) async {
    final List<CrmTemplateFieldModel> fields =
        _fieldEdits.map((edit) => edit.toField()).toList();
    final CrmTemplateSectionModel section = _currentSectionWithNames();
    final List<CrmTemplateFieldModel> sectionFields =
        _attachFieldsToSection(section, fields);
    final bool saved =
        await context.read<CrmTemplateBuilderCubit>().saveCurrentDraftAsSection(
              section: section,
              fields: sectionFields,
            );
    if (!mounted || !saved) return;
    setState(() => _isDirty = false);
  }

  Future<void> _confirmRemoveField(
    BuildContext context,
    CrmTemplateFieldEditModel edit,
  ) async {
    final bool exists =
        context.read<CrmTemplateBuilderCubit>().state.fields.any(
              (field) => field.id == edit.field.id,
            );
    if (!exists) {
      setState(() {
        _fieldEdits.remove(edit);
        _disposeFieldEditAfterFrame(edit);
        _isDirty = true;
      });
      return;
    }
    await CrmControlDialogs.showRemoveDialog(
      context: context,
      title: 'Remove Field',
      subtitle: 'Are you sure to remove this field?',
      onConfirm: () async {
        showLoadingIndicator();
        final bool removed = await context
            .read<CrmTemplateBuilderCubit>()
            .removeField(edit.field);
        hideLoadingIndicator();
        if (!mounted || !removed) return;
        setState(() {
          _fieldEdits.remove(edit);
          _disposeFieldEditAfterFrame(edit);
          _isDirty = true;
        });
        await CrmControlDialogs.showSuccessDialog(
          context: this.context,
          title: 'Successful!',
          subtitle: 'Removed successfully .',
        );
      },
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    await CrmControlDialogs.showRemoveDialog(
      context: context,
      title: _isExistingFieldMode ? 'Remove Field' : 'Remove Section',
      subtitle: _isExistingFieldMode
          ? 'Are you sure to remove this field?'
          : 'Are you sure to remove this section?',
      onConfirm: () async {
        showLoadingIndicator();
        final bool removed = _isExistingFieldMode && _fieldEdits.isNotEmpty
            ? await context
                .read<CrmTemplateBuilderCubit>()
                .removeField(_fieldEdits.first.field)
            : await _removeSectionWithoutNavigation(context);
        hideLoadingIndicator();
        if (!mounted || !removed) return;
        await CrmControlDialogs.showSuccessDialog(
          context: this.context,
          title: 'Successful!',
          subtitle: 'Removed successfully .',
          onComplete: () {
            if (mounted) CrmNavigationHelper.pop(this.context);
          },
        );
      },
    );
  }

  Future<bool> _removeSectionWithoutNavigation(BuildContext context) async {
    final CrmTemplateSectionModel? section = _section;
    if (section == null) return false;
    return context.read<CrmTemplateBuilderCubit>().removeSectionWithFields(
          templateId: widget.templateId,
          sectionId: section.id,
        );
  }

  void _discard(BuildContext context) {
    if (_isAddMode) {
      CrmNavigationHelper.pop(context);
      return;
    }
    setState(() {
      _isEditingMode = false;
      _isDirty = false;
      _loadedSignature = '';
    });
  }

  void _replaceFieldEdits(List<CrmTemplateFieldModel> fields) {
    final List<CrmTemplateFieldEditModel> oldEdits =
        List<CrmTemplateFieldEditModel>.from(_fieldEdits);
    final List<CrmTemplateFieldEditModel> newEdits =
        fields.map(CrmTemplateFieldEditModel.fromField).toList();
    for (final edit in newEdits) {
      _attachListenersToEdit(edit);
    }
    _fieldEdits
      ..clear()
      ..addAll(newEdits);
    _disposeFieldEditsAfterFrame(oldEdits);
  }

  void _attachListenersToEdit(CrmTemplateFieldEditModel edit) {
    edit.nameEnController.addListener(_onFieldInputChanged);
    edit.nameArController.addListener(_onFieldInputChanged);
    edit.errorEnController.addListener(_onFieldInputChanged);
    edit.errorArController.addListener(_onFieldInputChanged);
  }

  void _onFieldInputChanged() {
    if (mounted) {
      _isDirty = true;
      CrmTemplateElementValidator.validateLiveInputs(
        sectionNameEn: _sectionNameEnController.text,
        sectionNameAr: _sectionNameArController.text,
        onSectionErrorChanged: (enErr, arErr) {
          _sectionNameEnError = enErr;
          _sectionNameArError = arErr;
        },
        fieldEdits: _fieldEdits,
      );
      setState(() {});
    }
  }

  bool get _isFormValid {
    final bool valid = CrmTemplateElementValidator.isFormValid(
      selectedCategory: _selectedCategory,
      isExistingSectionMode: _isExistingSectionMode,
      isExistingFieldMode: _isExistingFieldMode,
      sectionNameEn: _sectionNameEnController.text,
      sectionNameAr: _sectionNameArController.text,
      fieldEdits: _fieldEdits,
    );
    if (!valid) return false;
    if (_isExistingSectionMode || _isExistingFieldMode) {
      return _isDirty;
    }
    return true;
  }

  void _clearFieldEditsAfterFrame() {
    final List<CrmTemplateFieldEditModel> oldEdits =
        List<CrmTemplateFieldEditModel>.from(_fieldEdits);
    _fieldEdits.clear();
    _disposeFieldEditsAfterFrame(oldEdits);
  }

  void _disposeFieldEditAfterFrame(CrmTemplateFieldEditModel edit) =>
      _disposeFieldEditsAfterFrame([edit]);

  void _disposeFieldEditsAfterFrame(List<CrmTemplateFieldEditModel> edits) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final CrmTemplateFieldEditModel edit in edits) {
        edit.dispose();
      }
    });
  }

  void _disposeFieldEditsNow() {
    for (final CrmTemplateFieldEditModel edit in _fieldEdits) {
      edit.dispose();
    }
    _fieldEdits.clear();
  }

  bool get _isExistingSectionMode => widget.sectionId.isNotEmpty;
  bool get _isExistingFieldMode => widget.fieldId.isNotEmpty;
  bool get _isAddMode => !_isExistingSectionMode && !_isExistingFieldMode;
  bool get _isDetailsMode => !_isAddMode && !_isEditingMode;
  bool get _isReadOnly => _isDetailsMode;
  bool get _showsSectionDetails =>
      _isExistingSectionMode || _selectedCategory == 'Section';
  bool get _canUseSavedSections =>
      !_isExistingSectionMode && _selectedCategory == 'Section';

  void _ensureInitialField() {
    if (_fieldEdits.isNotEmpty) return;
    final CrmTemplateFieldModel field = _createDraftField(order: 1);
    final CrmTemplateFieldEditModel edit =
        CrmTemplateFieldEditModel.fromField(field);
    _attachListenersToEdit(edit);
    _fieldEdits.add(edit);
    _draftPrepared = true;
  }

  CrmTemplateSectionModel _createDraftSection() {
    final String id =
        '${widget.templateId}_custom_section_${DateTime.now().millisecondsSinceEpoch}';
    return CrmTemplateSectionModel(
      id: id,
      templateId: widget.templateId,
      clientTypeId: widget.clientTypeId,
      nameEn: _sectionNameEnController.text.trim(),
      nameAr: _sectionNameArController.text.trim(),
      order: context.read<CrmTemplateBuilderCubit>().state.sections.length + 1,
      audit: CrmAuditModel.now(userEmail: 'system'),
    );
  }

  CrmTemplateFieldModel _createDraftField({
    required int order,
    String? sectionId,
  }) {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String id =
        '${widget.templateId}_${sectionId ?? 'field'}_custom_$timestamp';
    return CrmTemplateFieldModel(
      id: id,
      templateId: widget.templateId,
      clientTypeId: widget.clientTypeId,
      sectionId: sectionId,
      fieldTypeId: '',
      nameEn: '',
      nameAr: '',
      validationType: 'none',
      isRequired: false,
      showBothLanguages: true,
      systemKey: '',
      configuration: const {
        CrmFirestoreKeys.FIELD_KIND_KEY: 'text',
        CrmFirestoreKeys.IS_ENABLED_KEY: true,
        CrmFirestoreKeys.MAX_LENGTH_ENABLED_KEY: true,
        CrmFirestoreKeys.TRIM_SPACES_KEY: true,
      },
      order: order,
      audit: CrmAuditModel.now(userEmail: 'system'),
    );
  }

  CrmTemplateSectionModel _currentSectionWithNames() {
    final CrmTemplateSectionModel section = _section ?? _createDraftSection();
    return section.copyWith(
      templateId: widget.templateId,
      clientTypeId: widget.clientTypeId,
      nameEn: _sectionNameEnController.text.trim(),
      nameAr: _sectionNameArController.text.trim(),
    );
  }

  List<CrmTemplateFieldModel> _attachFieldsToSection(
    CrmTemplateSectionModel section,
    List<CrmTemplateFieldModel> fields,
  ) {
    return fields
        .map(
          (field) => field.copyWith(
            templateId: widget.templateId,
            clientTypeId: widget.clientTypeId,
            sectionId: section.id,
          ),
        )
        .toList();
  }
}
