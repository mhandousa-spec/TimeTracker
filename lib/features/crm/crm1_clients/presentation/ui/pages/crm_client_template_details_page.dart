// ****************** FILE INFO ******************
// File Name: crm_client_template_details_page.dart
// Purpose: Page displaying template details with a dynamic records grid, add
//          actions, and a read-only dynamic record detail view
// Author: Mohand Adel
// Created At: 02/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_card.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_record_detail_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_clients_table_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_template_records_header_widget.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmClientTemplateDetailsPage extends StatefulWidget {
  final String templateName;
  final String clientType;
  final String? clientTypeId;
  final String? templateId;
  final String? recordId;

  const CrmClientTemplateDetailsPage({
    super.key,
    this.templateName = 'Template Name',
    this.clientType = 'Person',
    this.clientTypeId,
    this.templateId,
    this.recordId,
  });

  @override
  State<CrmClientTemplateDetailsPage> createState() =>
      _CrmClientTemplateDetailsPageState();
}

class _CrmClientTemplateDetailsPageState
    extends State<CrmClientTemplateDetailsPage> {
  late final TextEditingController _searchController;
  static const List<String> _savedViewOptions = <String>[
    'All Clients',
    'Recent Clients',
    'Active Clients',
  ];
  static const List<String> _tagOptions = <String>[
    'VIP',
    'Lead',
    'New',
  ];
  String? _selectedSortOption;
  String _selectedStatusFilter = 'all';
  String? _selectedSavedView;
  String? _selectedTag;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CrmClientTypeModel? get _clientType {
    final CrmClientsListState state = context.read<CrmClientsListCubit>().state;
    if (widget.clientTypeId != null && widget.clientTypeId!.isNotEmpty) {
      for (final CrmClientTypeModel type in state.clientTypes) {
        if (type.id == widget.clientTypeId) return type;
      }
    }
    final String normalizedName = widget.clientType.trim().toLowerCase();
    for (final CrmClientTypeModel type in state.clientTypes) {
      if ((type.systemKey ?? '').toLowerCase() == normalizedName ||
          type.nameEn.toLowerCase() == normalizedName) {
        return type;
      }
    }
    return state.clientTypes.isEmpty ? null : state.clientTypes.first;
  }

  CrmTemplateModel? _templateFor(CrmClientsListState state) {
    if (widget.templateId != null && widget.templateId!.isNotEmpty) {
      for (final CrmTemplateModel template in state.templates) {
        if (template.id == widget.templateId) return template;
      }
    }
    final CrmClientTypeModel? type = _clientType;
    if (type == null) return null;
    return context.read<CrmClientsListCubit>().activeTemplateFor(type.id);
  }

  String get _displayTemplateName {
    final CrmClientsListState state = context.read<CrmClientsListCubit>().state;
    final CrmTemplateModel? template = _templateFor(state);
    if (template != null && template.nameEn.isNotEmpty) {
      return FormatHelper.localizedString(
        englishName: template.nameEn,
        arabicName: template.nameAr,
      );
    }
    return widget.templateName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmClients,
        thirdTitle: _displayTemplateName,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocListener<CrmClientsListCubit, CrmClientsListState>(
          listener: (BuildContext context, CrmClientsListState state) {
            final String? message = state.errorMessage;
            if (message != null && message.isNotEmpty) {
              CrmControlDialogs.showErrorDialog(
                context: context,
                title: S.current.errorOccurred,
                subtitle: message,
              );
              context.read<CrmClientsListCubit>().clearMessages();
            }
          },
          child: BlocBuilder<CrmClientsListCubit, CrmClientsListState>(
            builder: (BuildContext context, CrmClientsListState state) {
              if (state.isLoading && state.clientTypes.isEmpty) {
                return const CircleProgressMaster();
              }

              final CrmClientTypeModel? type = _clientType;
              final String clientTypeId = type?.id ?? widget.clientTypeId ?? '';

              if (widget.recordId != null && widget.recordId!.isNotEmpty) {
                return _buildRecordDetail(context, state, type);
              }

              return _buildTemplateContent(context, state, type, clientTypeId);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateContent(
    BuildContext context,
    CrmClientsListState state,
    CrmClientTypeModel? type,
    String clientTypeId,
  ) {
    final CrmTemplateModel? template = _templateFor(state);
    final bool isMobile = MediaQuery.sizeOf(context).width < 600;
    final List<CrmClientRecordModel> records;
    if (template != null) {
      records = state.records.where((CrmClientRecordModel record) {
        final bool matchesTemplate = record.templateId == template.id;
        final bool legacyMatch = record.templateId.isEmpty &&
            record.clientTypeId == template.clientTypeId;
        return (matchesTemplate || legacyMatch) &&
            record.status.toLowerCase() != 'deleted';
      }).toList();
    } else if (type != null) {
      records = state.records
          .where(
            (CrmClientRecordModel record) =>
                record.clientTypeId == type.id &&
                record.status.toLowerCase() != 'deleted',
          )
          .toList();
    } else {
      records = const [];
    }
    final List<CrmClientRecordModel> filteredRecords =
        _filteredRecords(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (records.isEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customButtonWithSvg(
                title: S.current.crmBulkUpload,
                function: () {
                  final String templateName =
                      template != null && template.nameEn.isNotEmpty
                          ? FormatHelper.localizedString(
                              englishName: template.nameEn,
                              arabicName: template.nameAr,
                            )
                          : widget.templateName;
                  CrmNavigationHelper.navigateToBulkUpload(
                    context,
                    templateName: templateName,
                    clientType: type?.nameEn ?? widget.clientType,
                    clientTypeId: type?.id,
                    templateId: template?.id,
                  );
                },
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
                color: AppColors.primary,
                colorBorder: AppColors.transparent,
                image: AppAssets.upload,
                widthImage: 16.sp,
                heightImage: 16.sp,
                svgColor: AppColors.black,
              ),
              SizedBox(width: 12.sp),
              customButtonWithSvg(
                title: S.current.crmAdd,
                function: () {
                  final String templateName =
                      template != null && template.nameEn.isNotEmpty
                          ? FormatHelper.localizedString(
                              englishName: template.nameEn,
                              arabicName: template.nameAr,
                            )
                          : widget.templateName;
                  CrmNavigationHelper.navigateToAddClient(
                    context,
                    templateName: templateName,
                    clientType: type?.nameEn ?? widget.clientType,
                    clientTypeId: type?.id,
                    templateId: template?.id,
                  );
                },
                textStyle: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
                color: AppColors.primary,
                colorBorder: AppColors.transparent,
                image: AppAssets.add,
                widthImage: 20.sp,
                heightImage: 20.sp,
                svgColor: AppColors.black,
              ),
            ],
          ),
        ] else ...[
          CrmTemplateRecordsHeaderWidget(
            statusItems: _buildStatusItems(records),
            selectedStatusKey: _selectedStatusFilter,
            onStatusChanged: (String key) {
              setState(() => _selectedStatusFilter = key);
            },
            searchController: _searchController,
            onSearchChanged: (_) => setState(() {}),
            selectedSortOption: _selectedSortOption,
            onSortChanged: (String? option) {
              setState(() => _selectedSortOption = option);
            },
            onDashboardTap: () {
              CrmNavigationHelper.navigateToTemplateDashboard(
                context,
                templateId: template?.id ?? '',
                templateName: _displayTemplateName,
                clientType: type?.nameEn ?? widget.clientType,
                clientTypeId: type?.id,
              );
            },
            onBulkUploadTap: () {
              final String templateName =
                  template != null && template.nameEn.isNotEmpty
                      ? FormatHelper.localizedString(
                          englishName: template.nameEn,
                          arabicName: template.nameAr,
                        )
                      : widget.templateName;
              CrmNavigationHelper.navigateToBulkUpload(
                context,
                templateName: templateName,
                clientType: type?.nameEn ?? widget.clientType,
                clientTypeId: type?.id,
                templateId: template?.id,
              );
            },
            onAddTap: () {
              final String templateName =
                  template != null && template.nameEn.isNotEmpty
                      ? FormatHelper.localizedString(
                          englishName: template.nameEn,
                          arabicName: template.nameAr,
                        )
                      : widget.templateName;
              CrmNavigationHelper.navigateToAddClient(
                context,
                templateName: templateName,
                clientType: type?.nameEn ?? widget.clientType,
                clientTypeId: type?.id,
                templateId: template?.id,
              );
            },
            onAddViewTap: () => CrmControlDialogs.showSuccessDialog(
              context: context,
              title: S.current.crmAddView,
              subtitle: S.current.crmAddViewComingSoon,
            ),
            onExportTap: () => CrmControlDialogs.showSuccessDialog(
              context: context,
              title: S.current.crmExport,
              subtitle: S.current.crmExportComingSoon,
            ),
            savedViewOptions: _savedViewOptions,
            selectedSavedView: _selectedSavedView,
            onSavedViewChanged: (String? value) {
              setState(() => _selectedSavedView = value);
            },
            tagOptions: _tagOptions,
            selectedTag: _selectedTag,
            onTagChanged: (String? value) {
              setState(() => _selectedTag = value);
            },
            isGridView: _isGridView,
            onGridTap: () => setState(() => _isGridView = true),
            onListTap: () => setState(() => _isGridView = false),
          ),
        ],
        SizedBox(height: 16.sp),
        if (isMobile)
          records.isEmpty
              ? _buildEmptyState(context, template, type)
              : _buildRecordsContent(context, filteredRecords, type)
        else
          Expanded(
            child: records.isEmpty
                ? _buildEmptyState(context, template, type)
                : _buildRecordsContent(context, filteredRecords, type),
          ),
      ],
    );
  }

  Widget _buildRecordsContent(
    BuildContext context,
    List<CrmClientRecordModel> records,
    CrmClientTypeModel? type,
  ) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile || _isGridView) {
      final int crossAxisCount = isMobile
          ? 1
          : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

      return GridView.builder(
        shrinkWrap: isMobile,
        physics: isMobile
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisExtent: isMobile ? 86.sp : 90.sp,
          crossAxisSpacing: isMobile ? 10.sp : 14.sp,
          mainAxisSpacing: isMobile ? 10.sp : 14.sp,
        ),
        itemCount: records.length,
        itemBuilder: (BuildContext context, int index) {
          final CrmClientRecordModel record = records[index];
          return CrmClientCard(
            record: record,
            clientType: type,
            onTap: () => _openRecordDetails(context, record, type),
          );
        },
      );
    }

    return CrmClientsTableWidget(
      records: records,
      onRecordTap: (CrmClientRecordModel record) =>
          _openRecordDetails(context, record, type),
    );
  }

  List<StatusChipItem> _buildStatusItems(List<CrmClientRecordModel> records) {
    final int active = records.where((CrmClientRecordModel record) {
      final String status = record.status.toLowerCase();
      return status.isEmpty || status == 'active';
    }).length;
    final int inactive = records.where((CrmClientRecordModel record) {
      return record.status.toLowerCase() == 'inactive';
    }).length;
    final int prospect = records.where((CrmClientRecordModel record) {
      return record.status.toLowerCase() == 'prospect';
    }).length;
    final int archived = records.where((CrmClientRecordModel record) {
      return record.status.toLowerCase() == 'archived';
    }).length;

    return <StatusChipItem>[
      StatusChipItem(
        key: 'all',
        label: S.current.crmAll,
        count: records.length,
      ),
      StatusChipItem(
        key: 'active',
        label: S.current.crmActive,
        count: active,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: 'inactive',
        label: S.current.crmInactive,
        count: inactive,
        labelColor: AppColors.orange,
      ),
      StatusChipItem(
        key: 'prospect',
        label: S.current.crmProspect,
        count: prospect,
        labelColor: AppColors.blue,
      ),
      StatusChipItem(
        key: 'archived',
        label: S.current.crmArchived,
        count: archived,
      ),
    ];
  }

  List<CrmClientRecordModel> _filteredRecords(
    List<CrmClientRecordModel> records,
  ) {
    final String query = _searchController.text.trim().toLowerCase();
    List<CrmClientRecordModel> filtered =
        records.where((CrmClientRecordModel record) {
      final bool matchesQuery = query.isEmpty ||
          (record.primaryDisplayValue ?? '').toLowerCase().contains(query) ||
          (record.secondaryDisplayValue ?? '').toLowerCase().contains(query);

      final String status = record.status.toLowerCase();
      final bool matchesStatus;
      switch (_selectedStatusFilter) {
        case 'active':
          matchesStatus = status.isEmpty || status == 'active';
          break;
        case 'inactive':
          matchesStatus = status == 'inactive';
          break;
        case 'prospect':
          matchesStatus = status == 'prospect';
          break;
        case 'archived':
          matchesStatus = status == 'archived';
          break;
        case 'all':
        default:
          matchesStatus = true;
          break;
      }

      return matchesQuery && matchesStatus;
    }).toList();

    switch (_selectedSortOption) {
      case 'name_desc':
        filtered.sort((CrmClientRecordModel a, CrmClientRecordModel b) =>
            (b.primaryDisplayValue ?? '')
                .compareTo(a.primaryDisplayValue ?? ''));
        break;
      case 'date_asc':
        filtered.sort((CrmClientRecordModel a, CrmClientRecordModel b) =>
            a.audit.createdAt.compareTo(b.audit.createdAt));
        break;
      case 'date_desc':
        filtered.sort((CrmClientRecordModel a, CrmClientRecordModel b) =>
            b.audit.createdAt.compareTo(a.audit.createdAt));
        break;
      case 'name_asc':
      default:
        filtered.sort((CrmClientRecordModel a, CrmClientRecordModel b) =>
            (a.primaryDisplayValue ?? '')
                .compareTo(b.primaryDisplayValue ?? ''));
        break;
    }

    return filtered;
  }

  void _openRecordDetails(
    BuildContext context,
    CrmClientRecordModel record,
    CrmClientTypeModel? type,
  ) {
    CrmNavigationHelper.navigateToClientProfile(
      context,
      recordId: record.id,
      templateName: record.primaryDisplayValue ?? widget.templateName,
      clientType: type?.nameEn ?? widget.clientType,
      clientTypeId: type?.id,
      templateId:
          record.templateId.isNotEmpty ? record.templateId : widget.templateId,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    CrmTemplateModel? template,
    CrmClientTypeModel? type,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.sp),
          onTap: () {
            final String templateName =
                template != null && template.nameEn.isNotEmpty
                    ? FormatHelper.localizedString(
                        englishName: template.nameEn,
                        arabicName: template.nameAr,
                      )
                    : widget.templateName;
            CrmNavigationHelper.navigateToAddClient(
              context,
              templateName: templateName,
              clientType: type?.nameEn ?? widget.clientType,
              clientTypeId: type?.id,
              templateId: template?.id,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvgImage(
                  assetPath: AppAssets.crmTemplateEmpty,
                  width: 220.sp,
                  height: 220.sp,
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.current.crmPressToAdd,
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordDetail(
    BuildContext context,
    CrmClientsListState state,
    CrmClientTypeModel? type,
  ) {
    CrmClientRecordModel? record;
    for (final CrmClientRecordModel item in state.records) {
      if (item.id == widget.recordId) {
        record = item;
        break;
      }
    }
    if (record == null) {
      return Center(
        child: Text(
          S.current.errorOccurred,
          style: StyleText.fontSize16Weight600.copyWith(
            color: AppColors.red,
          ),
        ),
      );
    }

    CrmTemplateModel? template;
    if (record.templateId.isNotEmpty) {
      for (final CrmTemplateModel item in state.templates) {
        if (item.id == record.templateId) {
          template = item;
          break;
        }
      }
    }
    template ??= context.read<CrmClientsListCubit>().activeTemplateFor(
          record.clientTypeId,
        );

    return CrmClientRecordDetailWidget(
      record: record,
      template: template,
      clientType: type,
      fallbackTemplateName: widget.templateName,
    );
  }
}
