// ****************** FILE INFO ******************
// File Name: crm_template_layout_page.dart
// Purpose: Interactive layout arrangement page for CRM templates.
// Author: Mohand Adel
// Created At: 04/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_layout_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_layout_actions_bar.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_layout_data.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_layout_row_card.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateLayoutPage extends StatefulWidget {
  const CrmTemplateLayoutPage({
    required this.templateId,
    required this.templateName,
    required this.clientTypeId,
    required this.clientType,
    super.key,
  });

  final String templateId;
  final String templateName;
  final String clientTypeId;
  final String clientType;

  @override
  State<CrmTemplateLayoutPage> createState() => _CrmTemplateLayoutPageState();
}

class _CrmTemplateLayoutPageState extends State<CrmTemplateLayoutPage> {
  late List<CrmLayoutItem> _allAvailableSections;
  late List<CrmLayoutItem> _allAvailableFields;
  late List<CrmLayoutPageData> _pages;
  bool _isSaving = false;
  bool _isLoadingLayout = true;
  bool _hasLoadedInitialLayout = false;
  StreamSubscription<Either<Failure, CrmTemplateLayoutModel?>>?
      _layoutSubscription;
  late final CrmControlsBaseRepository _repository =
      Get.find<CrmControlsBaseRepository>();

  @override
  void initState() {
    super.initState();
    _initItemsFromCubit();
    _initDefaultLayout();
    _subscribeToLayout();
  }

  @override
  void dispose() {
    _layoutSubscription?.cancel();
    for (final CrmLayoutPageData page in _pages) {
      for (final CrmLayoutRowData row in page.rows) {
        row.dispose();
      }
    }
    super.dispose();
  }

  void _subscribeToLayout() {
    if (widget.templateId.isEmpty) {
      if (mounted) setState(() => _isLoadingLayout = false);
      return;
    }
    _layoutSubscription = _repository
        .watchTemplateLayout(templateId: widget.templateId)
        .listen((result) {
      if (!mounted) return;
      result.fold(
        (failure) {
          if (mounted) {
            setState(() => _isLoadingLayout = false);
          }
        },
        (CrmTemplateLayoutModel? layoutModel) {
          if (layoutModel != null &&
              layoutModel.pages.isNotEmpty &&
              !_hasLoadedInitialLayout) {
            _populateFromLayoutModel(layoutModel);
          }
          if (mounted) {
            setState(() {
              _hasLoadedInitialLayout = true;
              _isLoadingLayout = false;
            });
          }
        },
      );
    });
  }

  void _populateFromLayoutModel(CrmTemplateLayoutModel layoutModel) {
    for (final CrmLayoutPageData page in _pages) {
      for (final CrmLayoutRowData row in page.rows) {
        row.dispose();
      }
    }

    final List<CrmLayoutPageData> loadedPages = <CrmLayoutPageData>[];

    for (int pIdx = 0; pIdx < layoutModel.pages.length; pIdx++) {
      final CrmTemplatePageModel pageModel = layoutModel.pages[pIdx];
      final List<CrmLayoutRowData> loadedRows = <CrmLayoutRowData>[];

      for (int rIdx = 0; rIdx < pageModel.rows.length; rIdx++) {
        final CrmTemplateRowModel rowModel = pageModel.rows[rIdx];

        CrmLayoutColumnData? col1;
        CrmLayoutColumnData? col2;
        bool isSecMode = false;

        if (rowModel.columns.isNotEmpty) {
          final CrmTemplateColumnModel col1Model = rowModel.columns[0];
          isSecMode = col1Model.type == 'section';
          final CrmLayoutItem? item1 = _findItemByRefId(
            col1Model.refId,
            isSection: isSecMode,
          );
          if (item1 != null) {
            col1 = CrmLayoutColumnData(
              selectedItemId: item1.id,
              selectedItemName: item1.name,
              isSection: isSecMode,
            );
          }
        }

        if (rowModel.columns.length > 1) {
          final CrmTemplateColumnModel col2Model = rowModel.columns[1];
          final bool col2IsSec = col2Model.type == 'section';
          final CrmLayoutItem? item2 = _findItemByRefId(
            col2Model.refId,
            isSection: col2IsSec,
          );
          if (item2 != null) {
            col2 = CrmLayoutColumnData(
              selectedItemId: item2.id,
              selectedItemName: item2.name,
              isSection: col2IsSec,
            );
          }
        }

        final CrmLayoutRowData rowData = CrmLayoutRowData(
          id: rowModel.id.isNotEmpty ? rowModel.id : 'r_${pIdx}_$rIdx',
          title: _rowOrdinalName(rIdx + 1),
          numberOfColumns: rowModel.columnsCount,
          isSectionMode: isSecMode,
        );
        rowData.column1 = col1;
        rowData.column2 = col2;
        loadedRows.add(rowData);
      }

      final String pageTitle =
          pageModel.titleEn.isNotEmpty ? pageModel.titleEn : 'Page ${pIdx + 1}';

      loadedPages.add(
        CrmLayoutPageData(
          id: pageModel.id.isNotEmpty ? pageModel.id : 'p_${pIdx + 1}',
          title: pageTitle,
          rows: loadedRows,
        ),
      );
    }

    if (loadedPages.isNotEmpty) {
      _pages = loadedPages;
    }
  }

  CrmLayoutItem? _findItemByRefId(String refId, {required bool isSection}) {
    if (isSection) {
      for (final item in _allAvailableSections) {
        if (item.id == refId) return item;
      }
    } else {
      for (final item in _allAvailableFields) {
        if (item.id == refId) return item;
      }
    }
    for (final item in _allAvailableSections) {
      if (item.id == refId) return item;
    }
    return null;
  }

  /// Function Name: _initItemsFromCubit
  ///
  /// Purpose: Reads sections and fields from the already-loaded cubit state
  /// and converts them to CrmLayoutItem lists for the dropdown.
  ///
  /// Returns: void
  void _initItemsFromCubit() {
    final CrmTemplateBuilderState state =
        context.read<CrmTemplateBuilderCubit>().state;

    _allAvailableSections = state.sections
        .where(
          (CrmTemplateSectionModel s) =>
              !s.isDeleted && s.status.toLowerCase() == 'active',
        )
        .map(
          (CrmTemplateSectionModel s) =>
              CrmLayoutItem(id: s.id, name: s.nameEn, isSection: true),
        )
        .toList();

    _allAvailableFields = state.fields
        .where(
          (field) => !field.isDeleted && field.status.toLowerCase() == 'active',
        )
        .map(
          (field) => CrmLayoutItem(id: field.id, name: field.nameEn),
        )
        .toList();

    // Fallback to hardcoded items if Firestore data is not yet loaded.
    if (_allAvailableSections.isEmpty) {
      _allAvailableSections = <CrmLayoutItem>[
        const CrmLayoutItem(
          id: 'sec_client_details',
          name: 'Client Details',
          isSection: true,
        ),
        const CrmLayoutItem(
          id: 'sec_address',
          name: 'Address',
          isSection: true,
        ),
      ];
    }
    if (_allAvailableFields.isEmpty) {
      _allAvailableFields = <CrmLayoutItem>[
        const CrmLayoutItem(id: 'f_first_name', name: 'Client First Name'),
        const CrmLayoutItem(id: 'f_last_name', name: 'Client Last Name'),
        const CrmLayoutItem(id: 'f_phone', name: 'Phone'),
        const CrmLayoutItem(id: 'f_email', name: 'Email'),
        const CrmLayoutItem(id: 'f_national_id', name: 'National ID'),
        const CrmLayoutItem(id: 'f_language', name: 'Preferred Language'),
        const CrmLayoutItem(id: 'f_channel', name: 'Preferred Contact Channel'),
        const CrmLayoutItem(id: 'f_date', name: 'Business Initiation Date'),
        const CrmLayoutItem(id: 'f_tags', name: 'Tags'),
        const CrmLayoutItem(id: 'f_country', name: 'Country'),
        const CrmLayoutItem(id: 'f_city', name: 'City'),
        const CrmLayoutItem(id: 'f_province', name: 'Province'),
        const CrmLayoutItem(id: 'f_street', name: 'Street'),
      ];
    }
  }

  void _initDefaultLayout() {
    _pages = <CrmLayoutPageData>[
      CrmLayoutPageData(
        id: 'p1',
        title: 'Page 1',
        rows: <CrmLayoutRowData>[
          CrmLayoutRowData(
            id: 'r1_1',
            title: 'First Row',
            numberOfColumns: 1,
            isSectionMode: false,
          ),
        ],
      ),
    ];
  }

  Set<String> get _placedItemIds {
    final Set<String> placed = <String>{};
    for (final CrmLayoutPageData page in _pages) {
      for (final CrmLayoutRowData row in page.rows) {
        if (row.column1?.selectedItemId != null) {
          placed.add(row.column1!.selectedItemId!);
        }
        if (row.column2?.selectedItemId != null) {
          placed.add(row.column2!.selectedItemId!);
        }
      }
    }
    return placed;
  }

  int get _unassignedItemsCount {
    final int total = _allAvailableSections.length + _allAvailableFields.length;
    return total - _placedItemIds.length;
  }

  bool get _canAddMore => _unassignedItemsCount > 0;

  bool get _canSave => _placedItemIds.isNotEmpty && !_isSaving;

  void _showLimitReachedFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All template fields and sections are already assigned.'),
      ),
    );
  }

  void _addRow(int pageIndex) {
    if (!_canAddMore) {
      _showLimitReachedFeedback();
      return;
    }
    setState(() {
      final CrmLayoutPageData page = _pages[pageIndex];
      final int rowNum = page.rows.length + 1;
      final String rowTitle = _rowOrdinalName(rowNum);
      page.rows.add(
        CrmLayoutRowData(
          id: 'r_${pageIndex}_$rowNum',
          title: rowTitle,
          numberOfColumns: 1,
          isSectionMode: false,
        ),
      );
    });
  }

  void _addPage() {
    if (!_canAddMore) {
      _showLimitReachedFeedback();
      return;
    }
    setState(() {
      final int pageNum = _pages.length + 1;
      _pages.add(
        CrmLayoutPageData(
          id: 'p_$pageNum',
          title: 'Page $pageNum',
          rows: <CrmLayoutRowData>[
            CrmLayoutRowData(
              id: 'r_${pageNum}_1',
              title: 'First Row',
              numberOfColumns: 1,
              isSectionMode: false,
            ),
          ],
        ),
      );
    });
  }

  String _rowOrdinalName(int num) {
    switch (num) {
      case 1:
        return 'First Row';
      case 2:
        return 'Second Row';
      case 3:
        return 'Third Row';
      case 4:
        return 'Fourth Row';
      case 5:
        return 'Fifth Row';
      case 6:
        return 'Sixth Row';
      default:
        return 'Row $num';
    }
  }

  void _discardLayout() {
    for (final CrmLayoutPageData page in _pages) {
      for (final CrmLayoutRowData row in page.rows) {
        row.dispose();
      }
    }
    setState(() {
      _hasLoadedInitialLayout = false;
      _isLoadingLayout = true;
      _initDefaultLayout();
    });
    _layoutSubscription?.cancel();
    _subscribeToLayout();
  }

  void _openPreview() {
    final CrmTemplateBuilderState cubitState =
        context.read<CrmTemplateBuilderCubit>().state;
    CrmNavigationHelper.navigateToControlTemplatePreview(
      context,
      templateName: widget.templateName,
      clientType: widget.clientType,
      layoutPages: _pages,
      templateSections: cubitState.sections,
      templateFields: cubitState.fields,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLayout) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crmControlTemplates,
          secondTitle: widget.templateName,
          thirdTitle: 'Layout',
          onFirstTap: () => CrmNavigationHelper.pop(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          child: const Center(
            child: CircleProgressMaster(),
          ),
        ),
      );
    }

    final Set<String> placed = _placedItemIds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmControlTemplates,
        secondTitle: widget.templateName,
        thirdTitle: 'Layout',
        onFirstTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int pIdx = 0; pIdx < _pages.length; pIdx++) ...[
                _buildPageSection(context, pIdx, placed),
                SizedBox(height: 20.sp),
              ],
              CrmTemplateLayoutActionsBar(
                canAddMore: _canAddMore,
                canSave: _canSave,
                isSaving: _isSaving,
                onAddRow: () =>
                    _addRow(_pages.isNotEmpty ? _pages.length - 1 : 0),
                onAddPage: _addPage,
                onLimitReached: _showLimitReachedFeedback,
                onDiscard: _discardLayout,
                onSave: _saveLayout,
                onPreview: _openPreview,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Function Name: _saveLayout
  ///
  /// Purpose: Converts the in-memory layout pages to a CrmTemplateLayoutModel
  /// and persists it to Firestore via the repository.
  ///
  /// Returns: `Future<void>`
  Future<void> _saveLayout() async {
    if (widget.templateId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No template ID — cannot save layout.')),
        );
      }
      return;
    }
    setState(() => _isSaving = true);
    final CrmTemplateLayoutModel model = _buildLayoutModel();
    final result = await _repository.saveTemplateLayout(
      layout: model,
      changedBy: _currentUserEmail,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.errMessage)),
      ),
      (_) => CrmControlDialogs.showSuccessDialog(
        context: context,
        title: 'Successful!',
        subtitle: 'Layout saved successfully.',
        onComplete: () => CrmNavigationHelper.pop(context),
      ),
    );
  }

  /// Function Name: _buildLayoutModel
  ///
  /// Purpose: Converts CrmLayoutPageData list to a CrmTemplateLayoutModel
  /// ready for Firestore persistence.
  ///
  /// Returns: CrmTemplateLayoutModel
  CrmTemplateLayoutModel _buildLayoutModel() {
    final List<CrmTemplatePageModel> pages = <CrmTemplatePageModel>[];
    for (int pIdx = 0; pIdx < _pages.length; pIdx++) {
      final CrmLayoutPageData page = _pages[pIdx];
      final List<CrmTemplateRowModel> rows = <CrmTemplateRowModel>[];
      for (int rIdx = 0; rIdx < page.rows.length; rIdx++) {
        final CrmLayoutRowData row = page.rows[rIdx];
        final List<CrmTemplateColumnModel> columns = <CrmTemplateColumnModel>[];
        if (row.column1?.selectedItemId != null) {
          final String type = row.isSectionMode ? 'section' : 'field';
          columns.add(
            CrmTemplateColumnModel(
              type: type,
              refId: row.column1!.selectedItemId!,
            ),
          );
        }
        if (row.column2?.selectedItemId != null) {
          columns.add(
            CrmTemplateColumnModel(
              type: 'field',
              refId: row.column2!.selectedItemId!,
            ),
          );
        }
        if (columns.isNotEmpty) {
          rows.add(
            CrmTemplateRowModel(
              id: row.id,
              columnsCount: row.numberOfColumns,
              columns: columns,
            ),
          );
        }
      }
      if (rows.isNotEmpty) {
        pages.add(
          CrmTemplatePageModel(
            id: page.id,
            titleEn: page.title,
            titleAr: page.title,
            order: pIdx,
            rows: rows,
          ),
        );
      }
    }
    return CrmTemplateLayoutModel(
      id: widget.templateId,
      templateId: widget.templateId,
      pages: pages,
      updatedAt: DateTime.now(),
      updatedBy: _currentUserEmail,
    );
  }

  /// Function Name: _currentUserEmail
  ///
  /// Purpose: Resolves the current user's email from GetX or fallback.
  ///
  /// Returns: String
  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    return 'system';
  }

  Widget _buildPageSection(
    BuildContext context,
    int pageIndex,
    Set<String> placed,
  ) {
    final CrmLayoutPageData page = _pages[pageIndex];
    final bool showHeader = _pages.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                page.title,
                style: StyleText.fontSize20Weight400.copyWith(
                  color: AppColors.black,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() => page.isExpanded = !page.isExpanded);
                },
                child: Text(
                  page.isExpanded ? 'Hide' : 'Show',
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.lightBlue).copyWith(
                    color: AppColors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          if (page.isExpanded) SizedBox(height: 14.sp),
        ],
        if (!showHeader || page.isExpanded) ...[
          for (int rIdx = 0; rIdx < page.rows.length; rIdx++) ...[
            CrmTemplateLayoutRowCard(
              row: page.rows[rIdx],
              availableSections: _allAvailableSections,
              availableFields: _allAvailableFields,
              placed: placed,
              onChanged: () => setState(() {}),
            ),
            SizedBox(height: 16.sp),
          ],
        ],
      ],
    );
  }
}
