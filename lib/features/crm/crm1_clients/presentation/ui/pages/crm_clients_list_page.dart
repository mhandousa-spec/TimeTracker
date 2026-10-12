// ****************** FILE INFO ******************
// File Name: crm_clients_list_page.dart
// Purpose: Main CRM Clients page displaying Client Type Tabs, KPI stats,
//          Search/Sort bar, and a grid of published Templates (Image 1 design)
// Author: Mohand Adel
// Created At: 02/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_type_tabs_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_clients_filter_dialog.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_kpi_stats_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_clients_search_sort_bar_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_template_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/generated/l10n.dart';

/// Main CRM Clients Dashboard displaying Client Type tabs, KPI stats, search/sort,
/// and published templates (Image 1 design).
class CrmClientsListPage extends StatefulWidget {
  const CrmClientsListPage({super.key});

  @override
  State<CrmClientsListPage> createState() => _CrmClientsListPageState();
}

class _CrmClientsListPageState extends State<CrmClientsListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<CrmClientsListCubit>().init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CrmClientTypeModel? _clientTypeFor(
    CrmClientsListState state,
    CrmTemplateModel template,
  ) {
    for (final CrmClientTypeModel type in state.clientTypes) {
      if (type.id == template.clientTypeId) return type;
    }
    return null;
  }

  int _clientsCountFor(
    CrmClientsListState state,
    CrmTemplateModel template,
  ) {
    int count = 0;
    for (final CrmClientRecordModel record in state.records) {
      if (record.templateId == template.id &&
          record.status.toLowerCase() != 'deleted') {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmClients,
        onFirstTap: () => CrmNavigationHelper.pop(context),
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
              return _buildMainContent(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    CrmClientsListState state,
  ) {
    final List<CrmTemplateModel> filteredTemplates =
        context.read<CrmClientsListCubit>().visibleTemplates();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Client Type Switcher Tabs (Image 1)
          CrmClientTypeTabsWidget(
            clientTypes: state.clientTypes,
            selectedClientTypeId: state.selectedClientTypeId,
            onTabSelected: (String typeId) {
              context.read<CrmClientsListCubit>().selectClientType(typeId);
            },
          ),
          SizedBox(height: 16.sp),

          // 2. KPI Summary Stat Cards Bar (Image 1)
          _buildKpiSection(state),
          SizedBox(height: 16.sp),

          // 3. Custom Search and Sort Row (Image 1)
          CrmClientsSearchSortBarWidget(
            controller: _searchController,
            selectedSortOption: state.selectedSortOption,
            onChanged: (String val) {
              context.read<CrmClientsListCubit>().setSearchQuery(val);
            },
            onSortChanged: (String? opt) {
              context.read<CrmClientsListCubit>().setSortOption(opt);
            },
            onFilterTap: () {
              CrmClientsFilterDialog.show(
                context,
                initialStatus: state.templateFilterStatus,
                initialCreationDate: null,
                initialLastUpdate: null,
                initialClientCountRange: null,
                onApply: ({
                  String? status,
                  DateTime? creationDate,
                  DateTime? lastUpdate,
                  String? clientCountRange,
                }) {
                  context
                      .read<CrmClientsListCubit>()
                      .setTemplateFilterStatus(status);
                },
              );
            },
          ),
          SizedBox(height: 16.sp),

          // 4. Templates Grid (Image 1)
          if (filteredTemplates.isEmpty)
            _buildEmptyState(context)
          else
            _buildTemplatesGrid(context, state, filteredTemplates),
          SizedBox(height: 32.sp),
        ],
      ),
    );
  }

  Widget _buildKpiSection(CrmClientsListState state) {
    final List<CrmClientRecordModel> forSelectedType = state.records
        .where(
          (CrmClientRecordModel r) =>
              r.clientTypeId == state.selectedClientTypeId &&
              r.status.toLowerCase() != 'deleted',
        )
        .toList();

    final int total = forSelectedType.length;
    final int active = forSelectedType
        .where(
          (CrmClientRecordModel r) =>
              r.status.toLowerCase() == 'active' || r.status.isEmpty,
        )
        .length;
    final int inactive = forSelectedType
        .where((CrmClientRecordModel r) => r.status.toLowerCase() == 'inactive')
        .length;
    final int prospect = forSelectedType
        .where((CrmClientRecordModel r) => r.status.toLowerCase() == 'prospect')
        .length;
    final int archived = forSelectedType
        .where((CrmClientRecordModel r) => r.status.toLowerCase() == 'archived')
        .length;

    return CrmKpiStatsWidget(
      totalCount: total,
      activeCount: active,
      inactiveCount: inactive,
      prospectCount: prospect,
      archivedCount: archived,
    );
  }

  Widget _buildTemplatesGrid(
    BuildContext context,
    CrmClientsListState state,
    List<CrmTemplateModel> templates,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    int crossAxisCount = 1;
    if (screenWidth >= 1920) {
      crossAxisCount = 4;
    } else if (screenWidth >= 1366) {
      crossAxisCount = 3;
    } else if (screenWidth >= 600) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: isMobile ? 96.sp : 100.sp,
        crossAxisSpacing: isMobile ? 10.sp : 14.sp,
        mainAxisSpacing: isMobile ? 10.sp : 14.sp,
      ),
      itemCount: templates.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmTemplateModel template = templates[index];
        final CrmClientTypeModel? clientType = _clientTypeFor(state, template);
        return CrmTemplateCard(
          template: template,
          clientType: clientType,
          clientsCount: _clientsCountFor(state, template),
          onTap: () {
            CrmNavigationHelper.navigateToTemplateDetails(
              context,
              templateId: template.id,
              templateName: FormatHelper.localizedString(
                englishName: template.nameEn,
                arabicName: template.nameAr,
              ),
              clientType: clientType?.nameEn ?? '',
              clientTypeId: template.clientTypeId,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          CustomSvgImage(
            assetPath: AppAssets.crmTemplateEmpty,
            width: 140.sp,
            height: 140.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            S.current.crmNoTemplates,
            textAlign: TextAlign.center,
            style: StyleText.fontSize16Weight600,
          ),
        ],
      ),
    );
  }
}
