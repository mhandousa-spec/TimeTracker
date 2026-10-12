// ****************** FILE INFO ******************
// File Name: crm_templates_page.dart
// Purpose: Templates listing page inside CRM controls.
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_templates_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_templates_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_controls_template_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_demo_data.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_state_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplatesPage extends StatefulWidget {
  const CrmTemplatesPage({super.key});

  @override
  State<CrmTemplatesPage> createState() => _CrmTemplatesPageState();
}

class _CrmTemplatesPageState extends State<CrmTemplatesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CrmTemplatesCubit>().init();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final int crossAxisCount = isMobile
        ? 1
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmSectionControls,
        secondTitle: S.current.crmControlTemplates,
        onFirstTap: () => CrmNavigationHelper.pop(context),
        child: BlocConsumer<CrmTemplatesCubit, CrmTemplatesState>(
          listener: (context, state) {},
          builder: (context, state) {
            final List<CrmTemplateModel> templates =
                context.read<CrmTemplatesCubit>().visibleTemplates();
            final List<String> tabs = state.clientTypes
                .map((type) => type.nameEn.isEmpty ? type.title : type.nameEn)
                .toList();
            final int selectedTabIndex = _selectedTabIndex(state);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tabs.isNotEmpty)
                    CustomTabs(
                      spacing: isMobile ? 16.sp : 32.sp,
                      textStyle: isMobile
                          ? StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack)
                          : StyleText.fontSize20Weight500.copyWith(color: AppColors.secondaryBlack),
                      tabs: tabs,
                      selectedValue: selectedTabIndex,
                      onChanged: (int value) {
                        context.read<CrmTemplatesCubit>().selectClientType(
                              state.clientTypes[value].id,
                            );
                      },
                    ),
                  CrmTemplateStateView(
                    isLoading: state.isLoading && state.templates.isEmpty,
                    errorMessage:
                        state.templates.isEmpty ? state.errorMessage : null,
                    onRetry: context.read<CrmTemplatesCubit>().init,
                    overlayLoading: false,
                    minHeight: MediaQuery.sizeOf(context).height - 300.sp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isMobile ? 14.sp : 22.sp),
                        StatusChipFilter(
                          selectedKey: state.selectedStatus,
                          onSelected: (String key) {
                            context.read<CrmTemplatesCubit>().selectStatus(key);
                          },
                          items: _statusItems(state),
                        ),
                        SizedBox(height: 14.sp),
                        CustomSearchFilterSortBar<String, String>(
                          searchController: _searchController,
                          onSearchChanged:
                              context.read<CrmTemplatesCubit>().search,
                          searchHint: S.current.crmSearch,
                          showFilter: true,
                          selectedFilter: state.selectedToolbarFilter,
                          filterTitle: S.current.crmFilter,
                          filterItems: const <String>['Fields', 'Sections'],
                          filterLabelBuilder: (String value) =>
                              value == 'Fields'
                                  ? S.current.crmCategoryFields
                                  : S.current.crmSectionsTab,
                          onFilterChanged: context
                              .read<CrmTemplatesCubit>()
                              .setToolbarFilter,
                          showSort: true,
                          selectedSort: state.selectedSort,
                          sortTitle: S.current.crmSort,
                          sortItems: const <String>['Newest', 'Active'],
                          sortLabelBuilder: (String value) => value == 'Newest'
                              ? S.current.crmSortNewest
                              : S.current.crmActive,
                          onSortChanged:
                              context.read<CrmTemplatesCubit>().setSort,
                          trailingActionsBuilder:
                              (BuildContext context, bool isPhone) => <Widget>[
                            customButtonWithSvg(
                              title: isPhone
                                  ? ''
                                  : state.isSaving
                                      ? 'Saving...'
                                      : S.current.crmAdd,
                              function: state.isSaving || tabs.isEmpty
                                  ? () {}
                                  : () => _showCreateTemplateDialog(context),
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: AppColors.black,
                              ),
                              color: AppColors.primary,
                              image: AppAssets.crmPlusBold,
                              widthImage: 20.sp,
                              heightImage: 20.sp,
                              colorBorder: AppColors.transparent,
                              svgColor: AppColors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: 14.sp),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: isMobile ? 10.sp : 14.sp,
                            mainAxisSpacing: isMobile ? 10.sp : 14.sp,
                            mainAxisExtent: isMobile ? 96.sp : 114.sp,
                          ),
                          itemCount: templates.length,
                          itemBuilder: (BuildContext context, int index) {
                            final CrmTemplateModel template = templates[index];
                            final CrmClientTypeModel clientType =
                                _clientTypeForTemplate(state, template);
                            return CrmControlsTemplateCard(
                              template: _summaryFromTemplate(template),
                              onTap: () {
                                CrmNavigationHelper
                                    .navigateToControlTemplateBuilder(
                                  context,
                                  templateId: template.id,
                                  templateName: template.nameEn,
                                  clientTypeId: template.clientTypeId,
                                  clientType: clientType.nameEn.isEmpty
                                      ? clientType.title
                                      : clientType.nameEn,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context) {
    CrmControlDialogs.showAddTemplateDialog(
      context: context,
      onConfirm: (String nameEn, String nameAr) {
        _confirmCreateTemplate(context, nameEn, nameAr);
      },
    );
  }

  Future<void> _confirmCreateTemplate(
    BuildContext context,
    String nameEn,
    String nameAr,
  ) async {
    await CrmControlDialogs.showSaveDialog(
      context: context,
      title: 'Add Template',
      subtitle: 'Are you sure to add this template?',
      onConfirm: () => _createTemplate(context, nameEn, nameAr),
    );
  }

  Future<void> _createTemplate(
    BuildContext context,
    String nameEn,
    String nameAr,
  ) async {
    final CrmTemplatesCubit cubit = context.read<CrmTemplatesCubit>();
    showLoadingIndicator();
    await cubit.createTemplateDraft(
      nameEn: nameEn,
      nameAr: nameAr,
    );
    hideLoadingIndicator();
    if (!context.mounted) return;
    await CrmControlDialogs.showSuccessDialog(
      context: context,
      title: 'Successful!',
      subtitle: 'submit successfully.',
    );
  }

  List<StatusChipItem> _statusItems(CrmTemplatesState state) {
    final Iterable<CrmTemplateModel> scopedTemplates = state.templates.where(
      (template) =>
          state.selectedClientTypeId.isEmpty ||
          template.clientTypeId == state.selectedClientTypeId,
    );
    final int active = scopedTemplates
        .where((template) => template.status.toLowerCase() == 'active')
        .length;
    final int inactive = scopedTemplates
        .where((template) =>
            template.status.toLowerCase() == 'inactive' ||
            template.status.toLowerCase() == 'draft')
        .length;
    return <StatusChipItem>[
      StatusChipItem(
        key: 'All',
        label: 'All',
        count: scopedTemplates.length,
      ),
      StatusChipItem(
        key: 'Active',
        label: 'Active',
        count: active,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: 'Inactive',
        label: 'Inactive',
        count: inactive,
        labelColor: AppColors.orange,
      ),
      StatusChipItem(
        key: 'Deleted',
        label: 'Deleted',
        count: 0,
        labelColor: AppColors.red,
      ),
    ];
  }

  int _selectedTabIndex(CrmTemplatesState state) {
    final int index = state.clientTypes.indexWhere(
      (type) => type.id == state.selectedClientTypeId,
    );
    return index < 0 ? 0 : index;
  }

  CrmClientTypeModel _clientTypeForTemplate(
    CrmTemplatesState state,
    CrmTemplateModel template,
  ) {
    return state.clientTypes.firstWhere(
      (type) => type.id == template.clientTypeId,
      orElse: () => CrmClientTypeModel(
        id: template.clientTypeId,
        title: 'Individuals',
        svgAsset: '',
      ),
    );
  }

  CrmTemplateSummaryData _summaryFromTemplate(CrmTemplateModel template) {
    return CrmTemplateSummaryData(
      name: template.nameEn,
      author: template.audit.createdBy.isEmpty
          ? template.audit.updatedBy
          : template.audit.createdBy,
      createdAt: _formatDate(template.audit.createdAt),
      fieldCount: template.fieldCount,
      status: _statusLabel(template.status),
    );
  }

  String _statusLabel(String status) {
    if (status.toLowerCase() == 'draft') return 'Inactive';
    if (status.isEmpty) return 'Inactive';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
