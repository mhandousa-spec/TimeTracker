// ****************** FILE INFO ******************
// File Name: crm_dynamic_form_renderer.dart
// Purpose: Unified dynamic form renderer resolving saved layout or section fallback
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_dynamic_field_builders.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_layout_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Renders a published template's fields dynamically.
///
/// Layout resolution:
/// 1. If a saved [CrmTemplateLayoutModel] exists, iterate pages → rows →
///    columns. A column with `type == 'section'` renders its section header
///    and child fields; `type == 'field'` resolves the field by `refId`.
/// 2. Fallback: group fields by `sectionId`, render sections in `order` and
///    fields in `order` using responsive 2-column rows.
class CrmDynamicFormRenderer extends StatefulWidget {
  final List<CrmTemplateSectionModel> sections;
  final List<CrmTemplateFieldModel> fields;
  final CrmTemplateLayoutModel? layout;
  final Map<String, dynamic> formValues;
  final Map<String, String?> formErrors;
  final void Function(String fieldId, dynamic value) onFieldValueChanged;
  final bool isSubmitting;
  final WidgetBuilder? actionsBuilder;
  final bool Function(List<CrmTemplateFieldModel> fields)? onValidatePageFields;
  final ValueChanged<List<CrmTemplateFieldModel>>? onRenderableFieldsChanged;

  const CrmDynamicFormRenderer({
    super.key,
    required this.sections,
    required this.fields,
    required this.layout,
    required this.formValues,
    required this.formErrors,
    required this.onFieldValueChanged,
    this.isSubmitting = false,
    this.actionsBuilder,
    this.onValidatePageFields,
    this.onRenderableFieldsChanged,
  });

  @override
  State<CrmDynamicFormRenderer> createState() => _CrmDynamicFormRendererState();
}

class _CrmDynamicFormRendererState extends State<CrmDynamicFormRenderer> {
  int _activePageIndex = 0;
  String _lastRenderableFieldSignature = '';

  @override
  void didUpdateWidget(covariant CrmDynamicFormRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activePageIndex >= _visiblePages.length) {
      _activePageIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    _notifyRenderableFieldsChanged();
    final List<Widget> blocks = _hasSavedLayout
        ? _buildLayoutBlocks(context)
        : _buildFallbackBlocks(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...blocks,
        if (_hasNextPage) _buildNextButton(),
        if (!_hasNextPage && widget.actionsBuilder != null)
          widget.actionsBuilder!(context),
      ],
    );
  }

  bool get _hasSavedLayout => widget.layout != null && _visiblePages.isNotEmpty;

  List<CrmTemplatePageModel> get _visiblePages {
    final List<CrmTemplatePageModel> pages =
        List<CrmTemplatePageModel>.from(widget.layout?.pages ?? const [])
          ..sort((a, b) => a.order.compareTo(b.order));
    return pages
        .where((CrmTemplatePageModel page) => page.rows.isNotEmpty)
        .toList();
  }

  bool get _hasNextPage =>
      _hasSavedLayout && _activePageIndex < _visiblePages.length - 1;

  // ── Saved layout path ────────────────────────────────────────────────────

  List<Widget> _buildLayoutBlocks(BuildContext context) {
    final List<Widget> blocks = <Widget>[];
    final List<CrmTemplatePageModel> pages = _visiblePages;
    if (pages.isEmpty) return blocks;
    final CrmTemplatePageModel activePage = pages[_activePageIndex];
    final List<CrmTemplateRowModel> rows =
        List<CrmTemplateRowModel>.from(activePage.rows);
    for (final CrmTemplateRowModel row in rows) {
      final Widget? rowBlock = _buildLayoutRow(context, row);
      if (rowBlock == null) continue;
      blocks.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.sp),
          child: rowBlock,
        ),
      );
    }
    return blocks;
  }

  Widget? _buildLayoutRow(BuildContext context, CrmTemplateRowModel row) {
    final List<CrmTemplateColumnModel> columns = row.columns
        .where(
          (CrmTemplateColumnModel column) => column.refId.trim().isNotEmpty,
        )
        .toList();
    if (columns.isEmpty) return null;

    final bool isFieldOnlyRow = columns.every(
      (CrmTemplateColumnModel column) => column.type != 'section',
    );
    if (isFieldOnlyRow) return _buildFieldOnlyRow(context, columns);

    final List<Widget> columnBlocks = columns
        .map((CrmTemplateColumnModel column) => _buildColumn(context, column))
        .where((Widget block) => block is! SizedBox)
        .toList();
    if (columnBlocks.isEmpty) return null;
    if (columnBlocks.length == 1) return columnBlocks.first;
    return buildResponsiveFields(
      context: context,
      left: columnBlocks.first,
      right:
          columnBlocks.length > 1 ? columnBlocks[1] : const SizedBox.shrink(),
      mobileSpacing: 12.sp,
    );
  }

  Widget? _buildFieldOnlyRow(
    BuildContext context,
    List<CrmTemplateColumnModel> columns,
  ) {
    final List<CrmTemplateFieldModel> rowFields = columns
        .map((CrmTemplateColumnModel column) => _fieldById(column.refId))
        .whereType<CrmTemplateFieldModel>()
        .where(_shouldRenderStandaloneField)
        .toList();
    if (rowFields.isEmpty) return null;
    return _buildFieldsCard(context, rowFields);
  }

  Widget _buildColumn(BuildContext context, CrmTemplateColumnModel column) {
    if (column.type == 'section') {
      final CrmTemplateSectionModel? section = _sectionById(column.refId);
      if (section == null) return const SizedBox.shrink();
      return _buildSectionCard(
        context,
        section,
        _fieldsOfSection(section.id),
      );
    }

    // type == 'field'
    final CrmTemplateFieldModel? field = _fieldById(column.refId);
    if (field == null) return const SizedBox.shrink();
    if (!_shouldRenderStandaloneField(field)) return const SizedBox.shrink();
    return _buildFieldsCard(context, <CrmTemplateFieldModel>[field]);
  }

  // ── Fallback path (no saved layout) ──────────────────────────────────────

  List<Widget> _buildFallbackBlocks(BuildContext context) {
    final List<CrmTemplateSectionModel> orderedSections =
        List<CrmTemplateSectionModel>.from(_activeSections)
          ..sort((a, b) => a.order.compareTo(b.order));

    final List<CrmTemplateFieldModel> unassigned = _activeFields
        .where((field) => field.sectionId == null)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final List<Widget> blocks = orderedSections
        .map(
          (section) => _buildSectionCard(
            context,
            section,
            _fieldsOfSection(section.id),
          ),
        )
        .toList();

    if (unassigned.isNotEmpty) {
      blocks.add(
        _buildSectionCard(
          context,
          CrmTemplateSectionModel(
            id: '_unassigned',
            templateId: '',
            clientTypeId: '',
            nameEn: '',
            nameAr: '',
            order: 0,
            audit: widget.sections.isEmpty
                ? CrmAuditModel(
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    createdBy: 'system',
                    updatedBy: 'system',
                  )
                : widget.sections.first.audit,
          ),
          unassigned,
          hideHeader: true,
        ),
      );
    }

    return blocks;
  }

  // ── Shared section rendering ─────────────────────────────────────────────

  Widget _buildSectionCard(
    BuildContext context,
    CrmTemplateSectionModel section,
    List<CrmTemplateFieldModel> sectionFields, {
    bool hideHeader = false,
  }) {
    final String title = crmDynamicFieldLabel(
      CrmTemplateFieldModel(
        id: section.id,
        templateId: section.templateId,
        clientTypeId: section.clientTypeId,
        fieldTypeId: 'text',
        nameEn: section.nameEn,
        nameAr: section.nameAr,
        order: section.order,
        audit: section.audit,
      ),
    );

    final List<Widget> children = <Widget>[];
    children.add(
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.sp),
        decoration: _sectionCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!hideHeader && title.isNotEmpty) ...<Widget>[
              _buildSectionHeader(title),
              SizedBox(height: 12.h),
            ],
            if (sectionFields.isEmpty)
              Text(
                title.isEmpty ? '' : _noFieldsLabel,
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
                  color: AppColors.grey,
                ),
              )
            else
              ..._buildFieldPairs(context, sectionFields),
          ],
        ),
      ),
    );

    children.add(SizedBox(height: 16.h));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildFieldsCard(
    BuildContext context,
    List<CrmTemplateFieldModel> cardFields,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: _sectionCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildFieldPairs(context, cardFields),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: customButton(
          title: 'Next',
          function: widget.isSubmitting
              ? () {}
              : () {
                  final bool canNavigate =
                      widget.onValidatePageFields?.call(_currentPageFields) ??
                          true;
                  if (canNavigate) {
                    setState(() => _activePageIndex += 1);
                  }
                },
          color: AppColors.primary,
          textStyle: StyleText.fontSize16Weight600.copyWith(
            color: AppColors.black,
          ),
        ),
      ),
    );
  }

  BoxDecoration get _sectionCardDecoration => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      );

  String get _noFieldsLabel {
    return 'No fields';
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: StyleText.fontSize16Weight600.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  bool _shouldRenderStandaloneField(CrmTemplateFieldModel field) {
    if (field.isDeleted || field.status.toLowerCase() == 'deleted') {
      return false;
    }
    final String? sectionId = field.sectionId;
    if (sectionId == null || sectionId.isEmpty) return true;
    return !_layoutSectionIds.contains(sectionId);
  }

  Set<String> get _layoutSectionIds {
    final Set<String> ids = <String>{};
    for (final CrmTemplatePageModel page in _visiblePages) {
      for (final CrmTemplateRowModel row in page.rows) {
        for (final CrmTemplateColumnModel column in row.columns) {
          if (column.type == 'section') ids.add(column.refId);
        }
      }
    }
    return ids;
  }

  List<CrmTemplateFieldModel> get _currentPageFields {
    if (!_hasSavedLayout) return _activeFields;
    final List<CrmTemplatePageModel> pages = _visiblePages;
    if (pages.isEmpty) return const <CrmTemplateFieldModel>[];
    final CrmTemplatePageModel activePage = pages[_activePageIndex];
    final Map<String, CrmTemplateFieldModel> fieldsById =
        <String, CrmTemplateFieldModel>{};
    for (final CrmTemplateRowModel row in activePage.rows) {
      for (final CrmTemplateColumnModel column in row.columns) {
        if (column.type == 'section') {
          for (final CrmTemplateFieldModel field
              in _fieldsOfSection(column.refId)) {
            fieldsById[field.id] = field;
          }
          continue;
        }
        final CrmTemplateFieldModel? field = _fieldById(column.refId);
        if (field != null && _shouldRenderStandaloneField(field)) {
          fieldsById[field.id] = field;
        }
      }
    }
    return fieldsById.values.toList();
  }

  List<CrmTemplateFieldModel> get _renderableFields {
    if (!_hasSavedLayout) return _activeFields;
    final Map<String, CrmTemplateFieldModel> fieldsById =
        <String, CrmTemplateFieldModel>{};
    for (final CrmTemplatePageModel page in _visiblePages) {
      for (final CrmTemplateRowModel row in page.rows) {
        for (final CrmTemplateColumnModel column in row.columns) {
          if (column.type == 'section') {
            for (final CrmTemplateFieldModel field
                in _fieldsOfSection(column.refId)) {
              fieldsById[field.id] = field;
            }
            continue;
          }
          final CrmTemplateFieldModel? field = _fieldById(column.refId);
          if (field != null && _shouldRenderStandaloneField(field)) {
            fieldsById[field.id] = field;
          }
        }
      }
    }
    return fieldsById.values.toList();
  }

  void _notifyRenderableFieldsChanged() {
    final ValueChanged<List<CrmTemplateFieldModel>>? callback =
        widget.onRenderableFieldsChanged;
    if (callback == null) return;
    final List<CrmTemplateFieldModel> fields = _renderableFields;
    final String signature = fields.map((field) => field.id).join('|');
    if (signature == _lastRenderableFieldSignature) return;
    _lastRenderableFieldSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      callback(List<CrmTemplateFieldModel>.unmodifiable(fields));
    });
  }

  List<CrmTemplateFieldModel> get _activeFields {
    return widget.fields
        .where(
          (CrmTemplateFieldModel field) =>
              !field.isDeleted && field.status.toLowerCase() != 'deleted',
        )
        .toList();
  }

  List<CrmTemplateSectionModel> get _activeSections {
    return widget.sections
        .where(
          (CrmTemplateSectionModel section) =>
              !section.isDeleted && section.status.toLowerCase() != 'deleted',
        )
        .toList();
  }

  // ── Field rendering helpers ──────────────────────────────────────────────

  List<Widget> _buildFieldPairs(
    BuildContext context,
    List<CrmTemplateFieldModel> sectionFields,
  ) {
    final List<CrmTemplateFieldModel> ordered =
        List<CrmTemplateFieldModel>.from(sectionFields)
          ..sort((a, b) => a.order.compareTo(b.order));

    final List<Widget> rows = <Widget>[];
    for (int index = 0; index < ordered.length; index++) {
      final CrmTemplateFieldModel currentField = ordered[index];
      if (_isBothLanguageTextField(currentField)) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(bottom: 12.sp),
            child: _buildSingleField(context, currentField),
          ),
        );
        continue;
      }

      final CrmTemplateFieldModel? nextField =
          index + 1 < ordered.length ? ordered[index + 1] : null;
      final bool canPairWithNext =
          nextField != null && !_isBothLanguageTextField(nextField);
      final Widget left = _buildSingleField(context, currentField);
      final Widget right = canPairWithNext
          ? _buildSingleField(context, nextField)
          : const SizedBox.shrink();
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.sp),
          child: buildResponsiveFields(
            context: context,
            left: left,
            right: right,
            mobileSpacing: 12.sp,
          ),
        ),
      );
      if (canPairWithNext) index++;
    }
    return rows;
  }

  bool _isBothLanguageTextField(CrmTemplateFieldModel field) {
    if (!field.showBothLanguages) return false;
    final String type = field.fieldTypeId.toLowerCase();
    return type == 'text' || type == 'description' || type.isEmpty;
  }

  Widget _buildSingleField(
    BuildContext context,
    CrmTemplateFieldModel field,
  ) {
    final dynamic value = widget.formValues[field.id];
    final String? error = widget.formErrors[field.id];
    final String? englishError = widget.formErrors[_englishErrorKey(field.id)];
    final String? arabicError = widget.formErrors[_arabicErrorKey(field.id)];

    return crmDynamicFieldBuilder(
      context: context,
      field: field,
      value: value,
      error: error,
      englishError: englishError,
      arabicError: arabicError,
      formValues: widget.formValues,
      allFields: _activeFields,
      onChanged: (dynamic newValue) {
        widget.onFieldValueChanged(field.id, newValue);
        if (_isCountryAddressField(field)) {
          for (final CrmTemplateFieldModel dependent
              in _dependentAddressFields(field)) {
            widget.onFieldValueChanged(dependent.id, null);
          }
        }
      },
    );
  }

  String _englishErrorKey(String fieldId) => '${fieldId}__en';

  String _arabicErrorKey(String fieldId) => '${fieldId}__ar';

  // ── Resolution helpers ───────────────────────────────────────────────────

  CrmTemplateSectionModel? _sectionById(String sectionId) {
    for (final CrmTemplateSectionModel section in _activeSections) {
      if (section.id == sectionId) return section;
    }
    return null;
  }

  CrmTemplateFieldModel? _fieldById(String fieldId) {
    for (final CrmTemplateFieldModel field in _activeFields) {
      if (field.id == fieldId) return field;
    }
    return null;
  }

  List<CrmTemplateFieldModel> _fieldsOfSection(String sectionId) {
    return _activeFields
        .where(
          (field) =>
              field.sectionId == sectionId &&
              !field.isDeleted &&
              field.status.toLowerCase() != 'deleted',
        )
        .toList();
  }

  bool _isCountryAddressField(CrmTemplateFieldModel field) {
    if (field.fieldTypeId.toLowerCase() != 'address') return false;
    final String component =
        (field.configuration[CrmFirestoreKeys.ADDRESS_COMPONENT_KEY] ?? '')
            .toString()
            .trim()
            .toLowerCase();
    return component.contains('country');
  }

  List<CrmTemplateFieldModel> _dependentAddressFields(
    CrmTemplateFieldModel countryField,
  ) {
    return _activeFields.where((CrmTemplateFieldModel field) {
      if (field.id == countryField.id) return false;
      if (field.sectionId != countryField.sectionId) return false;
      if (field.fieldTypeId.toLowerCase() != 'address') return false;
      final String component =
          (field.configuration[CrmFirestoreKeys.ADDRESS_COMPONENT_KEY] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      return !component.contains('country');
    }).toList();
  }
}
