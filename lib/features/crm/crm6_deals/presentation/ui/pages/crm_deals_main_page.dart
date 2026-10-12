// ****************** FILE INFO ******************
// File Name: crm_deals_main_page.dart
// Purpose: Main Controls page for Deals Categories & Stages management
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deals_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deals_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deals_presentation_controller.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_category_card.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_category_form_dialog.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_category_view_dialog.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_deal_stage_edit_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_stage_card.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deals_empty_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deals_kpi_bar.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deals_search_bar.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deals_tab_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDealsMainPage extends StatefulWidget {
  const CrmDealsMainPage({super.key});

  @override
  State<CrmDealsMainPage> createState() => _CrmDealsMainPageState();
}

class _CrmDealsMainPageState extends State<CrmDealsMainPage> {
  late final CrmDealsCubit _cubit;
  late final TextEditingController _searchController;
  final CrmDealsPresentationController _presentationController =
      const CrmDealsPresentationController();

  @override
  void initState() {
    super.initState();
    _cubit = CrmDealsCubit();
    _cubit.init();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Action Handlers
  // ---------------------------------------------------------------------------

  Future<void> _onAddTap() async {
    if (_cubit.state.currentTab == 0) {
      final CrmDealCategoryModel? newCategory =
          await CrmDealCategoryFormDialog.show(
        context: context,
        isEditing: false,
      );
      if (newCategory != null && mounted) {
        showLoadingIndicator();
        final bool saved = await _cubit.createCategory(
          nameEn: newCategory.nameEn,
          nameAr: newCategory.nameAr,
          status: newCategory.status,
        );
        hideLoadingIndicator();
        if (saved && mounted) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: S.current.crmCategorySavedSuccess,
          );
        }
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext ctx) => CrmDealStageEditPage(
            cubit: _cubit,
            isEditing: false,
          ),
        ),
      );
    }
  }

  void _onCategoryTap(CrmDealCategoryModel category) {
    if (_cubit.state.isEditMode) return;
    CrmDealCategoryViewDialog.show(
      context: context,
      category: category,
      initialStatus: _presentationController.statusOption(category.isActive),
      onStatusChanged: (String status) async {
        final bool shouldBeActive = status.toLowerCase() == 'active';
        if (category.isActive == shouldBeActive) return;
        showLoadingIndicator();
        final bool saved = await _cubit.toggleCategoryStatus(category);
        hideLoadingIndicator();
        if (saved && mounted) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: S.current.crmCategorySavedSuccess,
          );
        }
      },
      onEdit: () async {
        final CrmDealCategoryModel? editedCategory =
            await CrmDealCategoryFormDialog.show(
          context: context,
          category: category,
          isEditing: true,
        );
        if (editedCategory != null && mounted) {
          showLoadingIndicator();
          final bool updated = await _cubit.updateCategory(
            currentCategory: category,
            nameEn: editedCategory.nameEn,
            nameAr: editedCategory.nameAr,
            status: editedCategory.status,
          );
          hideLoadingIndicator();
          if (updated && mounted) {
            CrmControlDialogs.showSuccessDialog(
              context: context,
              title: S.current.crmSuccess,
              subtitle: S.current.crmCategorySavedSuccess,
            );
          }
        }
      },
    );
  }

  void _onCategoryDelete(CrmDealCategoryModel category) {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmDeleteCategory,
      subtitle: S.current.crmDeleteCategoryConfirm,
      onConfirm: () async {
        showLoadingIndicator();
        final bool deleted = await _cubit.deleteCategory(category);
        hideLoadingIndicator();
        if (deleted && mounted) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: S.current.crmCategoryDeletedSuccess,
          );
        }
      },
    );
  }

  void _onStageTap(CrmDealStageModel stage) {
    if (_cubit.state.isEditMode) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => CrmDealStageEditPage(
          stage: stage,
          cubit: _cubit,
          isReadOnly: true,
        ),
      ),
    );
  }

  void _onStageDelete(CrmDealStageModel stage) {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmDeleteStage,
      subtitle: S.current.crmDeleteStageConfirm,
      onConfirm: () async {
        showLoadingIndicator();
        final bool deleted = await _cubit.deleteStage(stage);
        hideLoadingIndicator();
        if (deleted && mounted) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: S.current.crmStageDeletedSuccess,
          );
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlDeals,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocConsumer<CrmDealsCubit, CrmDealsState>(
          bloc: _cubit,
          listener: (BuildContext ctx, CrmDealsState state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              final String err = state.errorMessage!;
              _cubit.clearMessages();
              CrmControlDialogs.showErrorDialog(
                context: ctx,
                title: S.current.crmAlert,
                subtitle: err,
              );
            }
          },
          builder: (BuildContext ctx, CrmDealsState state) {
            if (state.isLoading &&
                state.categories.isEmpty &&
                state.stages.isEmpty) {
              return const Center(child: CircleProgressMaster());
            }

            final bool isMobile = MediaQuery.of(context).size.width < 600;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Dual Tab Switcher (Categories / Stages)
                  CrmDealsTabBar(
                    selectedIndex: state.currentTab,
                    onTabChanged: (int index) => _cubit.setTab(index),
                  ),
                  SizedBox(height: 14.sp),

                  // 2. Responsive KPI Metrics Bar (All, Active, Inactive)
                  CrmDealsKpiBar(
                    totalCount: state.currentTotalCount,
                    activeCount: state.currentActiveCount,
                    inactiveCount: state.currentInactiveCount,
                    selectedStatus: state.selectedStatus,
                    onStatusSelected: (String status) =>
                        _cubit.setStatusFilter(status),
                  ),
                  SizedBox(height: 14.sp),

                  // 3. Search, Filter, Sort & Add Bar
                  CrmDealsSearchBar(
                    searchController: _searchController,
                    onSearchChanged: (String q) => _cubit.search(q),
                    selectedStatus: state.selectedStatusFilterValue,
                    onStatusChanged: (String s) => _cubit.setStatusFilter(s),
                    selectedSort: state.selectedSort,
                    onSortChanged: (String? s) => _cubit.setSort(s),
                    onAddTap: _onAddTap,
                    addButtonTitle: state.currentTab == 0
                        ? S.current.crmAddCategory
                        : S.current.crmAddStage,
                  ),
                  SizedBox(height: 14.sp),

                  // 4. Edit Mode Button (below search/sort row, aligned end above cards)
                  if ((state.currentTab == 0 && state.categories.isNotEmpty) ||
                      (state.currentTab == 1 && state.stages.isNotEmpty)) ...[
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: customButtonWithSvg(
                        title: isMobile
                            ? ''
                            : (state.isEditMode
                                ? S.current.crmDone
                                : S.current.edit),
                        function: () => _cubit.toggleEditMode(),
                        color: state.isEditMode
                            ? AppColors.grey
                            : AppColors.primary,
                        image: AppAssets.edit,
                        svgColor: AppColors.black,
                        widthImage: 16.sp,
                        heightImage: 16.sp,
                        colorBorder: AppColors.transparent,
                        textStyle: StyleText.fontSize14Weight500,
                      ),
                    ),
                    SizedBox(height: 14.sp),
                  ],

                  // 5. Tab Grid Content
                  if (state.currentTab == 0)
                    _buildCategoriesGrid(state)
                  else
                    _buildStagesGrid(state),

                  SizedBox(height: 32.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(CrmDealsState state) {
    if (state.filteredCategories.isEmpty) {
      return CrmDealsEmptyState(
        title: S.current.crmNoCategoriesAvailable,
        subtitle: S.current.crmCategoriesAddPrompt,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        mainAxisExtent: 44.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: state.filteredCategories.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmDealCategoryModel category = state.filteredCategories[index];
        return CrmDealCategoryCard(
          category: category,
          displayTitle: _presentationController.categoryDisplayName(category),
          statusLabel: _presentationController.statusLabel(category.isActive),
          isEditMode: state.isEditMode,
          onTap: () => _onCategoryTap(category),
          onDeleteTap: () => _onCategoryDelete(category),
        );
      },
    );
  }

  Widget _buildStagesGrid(CrmDealsState state) {
    if (state.filteredStages.isEmpty) {
      return CrmDealsEmptyState(
        title: S.current.crmNoStagesAvailable,
        subtitle: S.current.crmStagesAddPrompt,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        mainAxisExtent: 44.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: state.filteredStages.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmDealStageModel stage = state.filteredStages[index];
        return CrmDealStageCard(
          stage: stage,
          displayTitle: _presentationController.stageDisplayName(stage),
          statusLabel: _presentationController.statusLabel(stage.isActive),
          probabilityLabel:
              _presentationController.stageCardProbabilityLabel(stage),
          isEditMode: state.isEditMode,
          onTap: () => _onStageTap(stage),
          onDeleteTap: () => _onStageDelete(stage),
        );
      },
    );
  }
}
