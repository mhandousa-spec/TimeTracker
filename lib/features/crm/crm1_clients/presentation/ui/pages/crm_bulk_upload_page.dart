// ****************** FILE INFO ******************
// File Name: crm_bulk_upload_page.dart
// Purpose: CRM bulk-upload review page scoped to a template; columns are
//          built dynamically from the template fields when a templateId is given
// Author: Mohand Adel
// Created At: 03/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/base_repository/crm_clients_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_field_validator.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_bulk_upload_controls.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_bulk_upload_table.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';

class CrmBulkUploadPage extends StatefulWidget {
  final String templateName;
  final String clientType;
  final String? clientTypeId;
  final String? templateId;

  const CrmBulkUploadPage({
    super.key,
    this.templateName = 'Template Name',
    this.clientType = 'Person',
    this.clientTypeId,
    this.templateId,
  });

  @override
  State<CrmBulkUploadPage> createState() => _CrmBulkUploadPageState();
}

class _CrmBulkUploadPageState extends State<CrmBulkUploadPage> {
  late final CrmControlsBaseRepository _controlsRepository =
      Get.find<CrmControlsBaseRepository>();
  late final CrmClientsBaseRepository _clientsRepository =
      Get.find<CrmClientsBaseRepository>();

  late List<CrmBulkUploadColumn> _columns;
  late List<Map<String, TextEditingController>> _rows;
  List<CrmTemplateFieldModel> _templateFields = <CrmTemplateFieldModel>[];
  CrmTemplateModel? _template;
  final Set<int> _selectedRows = <int>{};
  final Map<int, Set<String>> _invalidCells = <int, Set<String>>{};
  final Map<int, Map<String, String>> _cellMessages =
      <int, Map<String, String>>{};
  final Set<int> _duplicateRows = <int>{};
  bool _showDuplicationOnly = false;
  bool _showErrorsOnly = false;
  bool _isLoadingColumns = false;
  bool _isActivating = false;

  /// Fallback columns used when no template id is provided or the template
  /// has no fields yet.
  static const List<CrmBulkUploadColumn> _fallbackColumns =
      <CrmBulkUploadColumn>[
    CrmBulkUploadColumn(key: 'clientName', label: 'Client Name', width: 230),
    CrmBulkUploadColumn(key: 'phone', label: 'Phone'),
    CrmBulkUploadColumn(key: 'email', label: 'Email'),
  ];

  @override
  void initState() {
    super.initState();
    _columns = List<CrmBulkUploadColumn>.from(_fallbackColumns);
    _rows = _buildRows();
    _isLoadingColumns = (widget.templateId ?? '').isNotEmpty;
    _loadTemplateColumns();
  }

  @override
  void dispose() {
    _disposeRows();
    super.dispose();
  }

  /// Fetches the template fields (one shot) and rebuilds the table columns
  /// from them so the uploaded rows match the template schema.
  Future<void> _loadTemplateColumns() async {
    final String templateId = widget.templateId ?? '';
    if (templateId.isEmpty) return;

    final Either<Failure, CrmTemplateModel?> templateResult =
        await _controlsRepository.watchTemplate(templateId: templateId).first;
    final Either<Failure, List<CrmTemplateFieldModel>> result =
        await _controlsRepository
            .watchTemplateFields(templateId: templateId)
            .first;
    if (!mounted) return;

    templateResult.fold(
      (failure) {
        debugPrint('CrmBulkUploadPage template error: ${failure.errMessage}');
      },
      (template) => _template = template,
    );

    result.fold(
      (failure) {
        debugPrint('CrmBulkUploadPage columns error: ${failure.errMessage}');
        setState(() => _isLoadingColumns = false);
      },
      (fields) {
        final List<CrmTemplateFieldModel> active = fields.where((field) {
          return !field.isDeleted && field.status.toLowerCase() != 'deleted';
        }).toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        setState(() {
          if (active.isEmpty) {
            _templateFields = <CrmTemplateFieldModel>[];
            _isLoadingColumns = false;
            return;
          }
          _disposeRows();
          _templateFields = active;
          _columns = _buildColumnsFromFields(active);
          _rows = _buildRows();
          _isLoadingColumns = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<int> visibleIndexes = _visibleIndexes;
    final List<Map<String, TextEditingController>> visibleRows =
        visibleIndexes.map((int index) => _rows[index]).toList();
    final Map<int, Set<String>> visibleInvalidCells = <int, Set<String>>{};
    final Set<int> visibleSelectedRows = <int>{};

    for (int displayIndex = 0;
        displayIndex < visibleIndexes.length;
        displayIndex++) {
      final int sourceIndex = visibleIndexes[displayIndex];
      if (_invalidCells.containsKey(sourceIndex)) {
        visibleInvalidCells[displayIndex] = _invalidCells[sourceIndex]!;
      }
      if (_selectedRows.contains(sourceIndex)) {
        visibleSelectedRows.add(displayIndex);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmClients,
        thirdTitle: S.current.crmReviewBulkUpload,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        child: Column(
          children: [
            _buildActionsBar(),
            SizedBox(height: 24.sp),
            Expanded(
              child: _isLoadingColumns
                  ? const CircleProgressMaster()
                  : CrmBulkUploadTable(
                      columns: _columns,
                      rows: visibleRows,
                      selectedRows: visibleSelectedRows,
                      invalidCells: visibleInvalidCells,
                      onToggleRow: (int displayIndex) {
                        _toggleRow(visibleIndexes[displayIndex]);
                      },
                      onErrorTap: (int displayIndex, String key) {
                        _showCellWarning(visibleIndexes[displayIndex], key);
                      },
                    ),
            ),
            SizedBox(height: 16.sp),
            _buildFooterActions(),
          ],
        ),
      ),
    );
  }

  List<int> get _visibleIndexes {
    return List<int>.generate(_rows.length, (int index) => index)
        .where((int index) {
      if (_showDuplicationOnly && !_duplicateRows.contains(index)) return false;
      if (_showErrorsOnly && !(_invalidCells[index]?.isNotEmpty ?? false)) {
        return false;
      }
      return true;
    }).toList();
  }

  int get _errorCount {
    return _invalidCells.values.fold<int>(
      0,
      (int total, Set<String> cells) => total + cells.length,
    );
  }

  List<CrmBulkUploadColumn> _buildColumnsFromFields(
    List<CrmTemplateFieldModel> fields,
  ) {
    final List<CrmBulkUploadColumn> columns = <CrmBulkUploadColumn>[];
    for (final CrmTemplateFieldModel field in fields) {
      if (CrmFieldValidator.isBilingualTextField(field)) {
        columns.addAll(<CrmBulkUploadColumn>[
          CrmBulkUploadColumn(
            key: CrmFieldValidator.englishKey(field.id),
            fieldId: field.id,
            fieldTypeId: field.fieldTypeId,
            languageCode: 'en',
            label: field.nameEn.trim().isEmpty ? field.nameAr : field.nameEn,
          ),
          CrmBulkUploadColumn(
            key: CrmFieldValidator.arabicKey(field.id),
            fieldId: field.id,
            fieldTypeId: field.fieldTypeId,
            languageCode: 'ar',
            label: field.nameAr.trim().isEmpty ? field.nameEn : field.nameAr,
            isArabic: true,
          ),
        ]);
        continue;
      }
      columns.add(
        CrmBulkUploadColumn(
          key: field.id,
          fieldId: field.id,
          fieldTypeId: field.fieldTypeId,
          label: FormatHelper.localizedString(
            englishName: field.nameEn,
            arabicName: field.nameAr,
          ),
          isArabic:
              field.nameEn.trim().isEmpty && field.nameAr.trim().isNotEmpty,
        ),
      );
    }
    return columns;
  }

  void _toggleRow(int rowIndex) {
    setState(() {
      if (_selectedRows.contains(rowIndex)) {
        _selectedRows.remove(rowIndex);
      } else {
        _selectedRows.add(rowIndex);
      }
    });
  }

  void _removeSelection() {
    setState(() {
      final List<int> sortedRows = _selectedRows.toList()
        ..sort((int first, int second) => second.compareTo(first));
      for (final int index in sortedRows) {
        _disposeRow(_rows.removeAt(index));
      }
      _selectedRows.clear();
    });
  }

  Widget _buildActionsBar() {
    return Row(
      children: [
        CrmBulkUploadErrorCountButton(
          count: _errorCount,
          isActive: _showErrorsOnly,
          onTap: () => setState(() => _showErrorsOnly = !_showErrorsOnly),
        ),
        const Spacer(),
        customButtonWithSvg(
          title: S.current.crmRemoveSelection,
          function: _selectedRows.isEmpty ? () {} : _removeSelection,
          textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.background),
          color: AppColors.blackButton,
          image: AppAssets.crmMinus,
          widthImage: 12.sp,
          heightImage: 2.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.white,
        ),
        SizedBox(width: 10.sp),
        CrmBulkUploadFilterButton(
          title: S.current.crmDuplicationFound,
          onTap: () =>
              setState(() => _showDuplicationOnly = !_showDuplicationOnly),
        ),
        SizedBox(width: 10.sp),
        customButtonWithSvg(
          title: S.current.crmAddRow,
          function: _addRow,
          textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.background),
          color: AppColors.blackButton,
          image: AppAssets.crmPlusBold,
          widthImage: 12.sp,
          heightImage: 12.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.white,
        ),
      ],
    );
  }

  Widget _buildFooterActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: S.current.crmDiscard,
          function: () => CrmNavigationHelper.pop(context),
          color: AppColors.grey,
          textStyle: StyleText.fontSize16Weight600,
        ),
        customButton(
          title: S.current.crmActivate,
          function: _isActivating ? () {} : _activateRows,
          color: AppColors.primary,
          textStyle: StyleText.fontSize16Weight600,
        ),
      ],
    );
  }

  void _addRow() {
    setState(() {
      _rows.add(_buildRow());
    });
  }

  Future<void> _activateRows() async {
    final List<int> rowIndexes = _nonEmptyRowIndexes;
    final Map<int, Set<String>> errors = _validateRows(rowIndexes);
    if (errors.isNotEmpty) {
      setState(() {
        _invalidCells
          ..clear()
          ..addAll(errors);
      });
      _showLanguageWarning();
      return;
    }
    if (rowIndexes.isEmpty) return;
    setState(() {
      _invalidCells.clear();
      _cellMessages.clear();
    });

    final CrmTemplateModel? template = _template;
    final String templateId = (widget.templateId ?? '').trim().isNotEmpty
        ? widget.templateId!.trim()
        : template?.id ?? '';
    final String clientTypeId = (widget.clientTypeId ?? '').trim().isNotEmpty
        ? widget.clientTypeId!.trim()
        : template?.clientTypeId ?? '';
    if (templateId.isEmpty || clientTypeId.isEmpty) {
      _showLanguageWarning();
      return;
    }

    setState(() => _isActivating = true);
    for (final int rowIndex in rowIndexes) {
      final CrmClientRecordModel record = _recordFromRow(
        rowIndex: rowIndex,
        templateId: templateId,
        clientTypeId: clientTypeId,
        templateVersion: template?.version ?? 1,
      );
      final Either<Failure, CrmClientRecordModel> result =
          await _clientsRepository.saveClientRecord(record: record);
      if (!mounted) return;
      if (result.isLeft()) {
        setState(() => _isActivating = false);
        result.fold(
          (failure) => _showSaveFailure(failure.errMessage),
          (_) {},
        );
        return;
      }
    }
    if (!mounted) return;
    setState(() => _isActivating = false);
    CrmNavigationHelper.pop(context);
  }

  void _showCellWarning(int rowIndex, String key) {
    final String message = _cellMessages[rowIndex]?[key] ??
        (key.endsWith('__ar')
            ? S.current.crmWarningLanguageCheckSubtitle
            : S.current.crmEnglishLettersOnlySubtitle);
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          child: CrmBulkUploadWarningDialog(
            title: key.endsWith('__ar')
                ? S.current.crmWarningLanguageCheckTitle
                : S.current.crmEnglishLettersOnlyTitle,
            subtitle: message,
          ),
        );
      },
    );
  }

  void _showLanguageWarning() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          child: CrmBulkUploadWarningDialog(
            title: S.current.crmWarningLanguageCheckTitle,
            subtitle: S.current.crmWarningLanguageCheckSubtitle,
          ),
        );
      },
    );
  }

  void _showSaveFailure(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          child: CrmBulkUploadWarningDialog(
            title: S.current.error,
            subtitle: message,
          ),
        );
      },
    );
  }

  List<int> get _nonEmptyRowIndexes {
    return List<int>.generate(_rows.length, (int index) => index)
        .where((int index) {
      return _rows[index].values.any(
            (TextEditingController controller) =>
                controller.text.trim().isNotEmpty,
          );
    }).toList();
  }

  Map<int, Set<String>> _validateRows(List<int> rowIndexes) {
    final Map<int, Set<String>> errors = <int, Set<String>>{};
    _cellMessages.clear();
    for (final int rowIndex in rowIndexes) {
      final Map<String, TextEditingController> row = _rows[rowIndex];
      for (final CrmTemplateFieldModel field in _templateFields) {
        final Map<String, String> invalidCells =
            _invalidColumnMessagesForField(row, field);
        for (final MapEntry<String, String> entry in invalidCells.entries) {
          errors.putIfAbsent(rowIndex, () => <String>{}).add(entry.key);
          _cellMessages.putIfAbsent(
              rowIndex, () => <String, String>{})[entry.key] = entry.value;
        }
      }
    }
    return errors;
  }

  Map<String, String> _invalidColumnMessagesForField(
    Map<String, TextEditingController> row,
    CrmTemplateFieldModel field,
  ) {
    final Map<String, String> invalidMessages = <String, String>{};
    if (CrmFieldValidator.isBilingualTextField(field)) {
      final String english =
          row[CrmFieldValidator.englishKey(field.id)]?.text.trim() ?? '';
      final String arabic =
          row[CrmFieldValidator.arabicKey(field.id)]?.text.trim() ?? '';
      if (field.isRequired && english.isEmpty) {
        invalidMessages[CrmFieldValidator.englishKey(field.id)] =
            CrmFieldValidator.requiredFieldMessage(field, isArabic: false);
      }
      if (field.isRequired && arabic.isEmpty) {
        invalidMessages[CrmFieldValidator.arabicKey(field.id)] =
            CrmFieldValidator.requiredFieldMessage(field, isArabic: true);
      }
      final String? englishError =
          CrmFieldValidator.englishLanguageError(english);
      if (englishError != null) {
        invalidMessages[CrmFieldValidator.englishKey(field.id)] = englishError;
      }
      final String? arabicError = CrmFieldValidator.arabicLanguageError(arabic);
      if (arabicError != null) {
        invalidMessages[CrmFieldValidator.arabicKey(field.id)] = arabicError;
      }
      return invalidMessages;
    }

    final String value = row[field.id]?.text.trim() ?? '';
    if (field.isRequired && value.isEmpty) {
      invalidMessages[field.id] = CrmFieldValidator.requiredFieldMessage(
        field,
        isArabic: Get.locale.toString().contains('ar'),
      );
    }
    return invalidMessages;
  }

  CrmClientRecordModel _recordFromRow({
    required int rowIndex,
    required String templateId,
    required String clientTypeId,
    required int templateVersion,
  }) {
    final Map<String, TextEditingController> row = _rows[rowIndex];
    final Map<String, dynamic> values = <String, dynamic>{};
    for (final CrmTemplateFieldModel field in _templateFields) {
      if (CrmFieldValidator.isBilingualTextField(field)) {
        final String english =
            row[CrmFieldValidator.englishKey(field.id)]?.text.trim() ?? '';
        final String arabic =
            row[CrmFieldValidator.arabicKey(field.id)]?.text.trim() ?? '';
        if (english.isNotEmpty || arabic.isNotEmpty) {
          values[field.id] = <String, String>{'en': english, 'ar': arabic};
        }
        continue;
      }
      final String value = row[field.id]?.text.trim() ?? '';
      if (value.isNotEmpty) values[field.id] = value;
    }
    final DateTime now = DateTime.now();
    return CrmClientRecordModel(
      id: 'client_record_${now.microsecondsSinceEpoch}_$rowIndex',
      clientTypeId: clientTypeId,
      templateId: templateId,
      templateVersion: templateVersion,
      status: 'active',
      values: values,
      audit: CrmAuditModel.now(userEmail: _currentUserEmail),
    );
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

  /// Seeds a small number of empty editable rows for review.
  List<Map<String, TextEditingController>> _buildRows() {
    return List<Map<String, TextEditingController>>.generate(5, (int index) {
      return _buildRow();
    });
  }

  Map<String, TextEditingController> _buildRow() {
    return <String, TextEditingController>{
      for (final CrmBulkUploadColumn column in _columns)
        column.key: TextEditingController(),
    };
  }

  void _disposeRows() {
    for (final Map<String, TextEditingController> row in _rows) {
      _disposeRow(row);
    }
    _rows = <Map<String, TextEditingController>>[];
  }

  void _disposeRow(Map<String, TextEditingController> row) {
    for (final TextEditingController controller in row.values) {
      controller.dispose();
    }
  }
}
