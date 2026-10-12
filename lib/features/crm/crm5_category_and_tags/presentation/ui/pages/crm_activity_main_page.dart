// ****************** FILE INFO ******************
// File Name: crm_activity_main_page.dart
// Purpose: Dual-tab (Categories & Tags) main list page under CRM Activity Controls
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';

import 'package:knowticed_plus/core/helper/crm_helper/crm_card_helper.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm_di.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/controller/crm_category_and_tags_cubit.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/controller/crm_category_and_tags_state.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/widgets/crm_activity_empty_state.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/widgets/crm_activity_search_bar.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/widgets/crm_activity_tab_bar.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/widgets/crm_category_card.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/widgets/crm_tag_card.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/widgets/crm_tag_form_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmActivityMainPage extends StatefulWidget {
  const CrmActivityMainPage({super.key});

  @override
  State<CrmActivityMainPage> createState() => _CrmActivityMainPageState();
}

class _CrmActivityMainPageState extends State<CrmActivityMainPage> {
  final TextEditingController _searchController = TextEditingController();
  late final CrmCategoryAndTagsCubit _cubit;

  @override
  void initState() {
    super.initState();
    registerCrmDependencies();
    _cubit = CrmCategoryAndTagsCubit()..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _onAddTap() async {
    if (_cubit.state.currentTab == 0) {
      final dynamic result =
          await CrmNavigationHelper.navigateToControlCategoryForm(
        context,
        arguments: const <String, dynamic>{'mode': 'add'},
      );
      await _handleCategoryResult(result);
    } else {
      final CrmTagModel? newTag = await CrmTagFormDialog.show(
        context: context,
        isEditing: false,
      );
      if (newTag != null && mounted) {
        showLoadingIndicator();
        final bool saved = await _cubit.createTag(
          nameEn: newTag.nameEn,
          nameAr: newTag.nameAr,
          status: newTag.status,
        );
        hideLoadingIndicator();
        if (saved && mounted) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: S.current.crmTagSavedSuccess,
          );
        }
      }
    }
  }

  Future<void> _onCategoryTap(CrmCategoryModel category) async {
    final dynamic result =
        await CrmNavigationHelper.navigateToControlCategoryForm(
      context,
      arguments: <String, dynamic>{
        'category': category,
        'mode': 'view',
      },
    );
    await _handleCategoryResult(result, existingCategory: category);
  }

  Future<void> _handleCategoryResult(
    dynamic result, {
    CrmCategoryModel? existingCategory,
  }) async {
    if (!mounted || result is! Map<String, dynamic>) return;
    final String action = (result['action'] ?? '').toString();

    if (action == 'save') {
      final CrmCategoryModel? category =
          result['category'] as CrmCategoryModel?;
      if (category == null) return;

      showLoadingIndicator();
      bool saved = false;
      if (existingCategory == null || existingCategory.id.isEmpty) {
        saved = await _cubit.createCategory(
          nameEn: category.nameEn,
          nameAr: category.nameAr,
          status: category.status,
          types: category.types,
        );
      } else {
        saved = await _cubit.updateCategory(
          currentCategory: existingCategory,
          nameEn: category.nameEn,
          nameAr: category.nameAr,
          status: category.status,
          types: category.types,
        );
      }
      hideLoadingIndicator();

      if (saved && mounted) {
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: S.current.crmCategorySavedSuccess,
        );
      }
    } else if (action == 'delete' && existingCategory != null) {
      showLoadingIndicator();
      final bool deleted = await _cubit.deleteCategory(existingCategory);
      hideLoadingIndicator();

      if (deleted && mounted) {
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: S.current.crmCategoryDeletedSuccess,
        );
      }
    }
  }

  Future<void> _onTagTap(CrmTagModel tag) async {
    if (_cubit.state.isTagEditMode) return;
    final CrmTagModel? editedTag = await CrmTagFormDialog.show(
      context: context,
      tag: tag,
      isEditing: true,
    );
    if (editedTag != null && mounted) {
      showLoadingIndicator();
      final bool saved = await _cubit.updateTag(
        currentTag: tag,
        nameEn: editedTag.nameEn,
        nameAr: editedTag.nameAr,
        status: editedTag.status,
      );
      hideLoadingIndicator();
      if (saved && mounted) {
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: S.current.crmTagUpdatedSuccess,
        );
      }
    }
  }

  Future<void> _onTagDelete(CrmTagModel tag) async {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmDeleteTag,
      subtitle: S.current.crmDeleteTagConfirm,
      onConfirm: () async {
        showLoadingIndicator();
        final bool deleted = await _cubit.deleteTag(tag);
        hideLoadingIndicator();
        if (deleted && mounted) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: S.current.crmTagDeletedSuccess,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlActivity,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocConsumer<CrmCategoryAndTagsCubit, CrmCategoryAndTagsState>(
          bloc: _cubit,
          listener: (BuildContext ctx, CrmCategoryAndTagsState state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              CrmControlDialogs.showErrorDialog(
                context: ctx,
                title: S.current.crmAlert,
                subtitle: state.errorMessage!,
              );
            }
          },
          builder: (BuildContext ctx, CrmCategoryAndTagsState state) {
            if (state.isLoading &&
                state.categories.isEmpty &&
                state.tags.isEmpty) {
              return const Center(child: CircleProgressMaster());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Tab Bar
                    CrmActivityTabBar(
                      selectedIndex: state.currentTab,
                      onTabChanged: (int index) => _cubit.setTab(index),
                    ),
                    SizedBox(height: 16.h),

                    // Search, Filter, Sort, Add Bar
                    CrmActivitySearchBar(
                      searchController: _searchController,
                      onSearchChanged: (String q) => _cubit.search(q),
                      selectedStatus: state.selectedStatus,
                      onStatusChanged: (String s) => _cubit.setStatusFilter(s),
                      selectedSort: state.selectedSort,
                      onSortChanged: (String? s) => _cubit.setSort(s),
                      onAddTap: _onAddTap,
                      addButtonTitle: state.currentTab == 0
                          ? (isArabic ? 'إضافة فئة' : 'Add Category')
                          : (isArabic ? 'إضافة وسم' : 'Add Tag'),
                    ),
                    SizedBox(height: 16.h),

                    // Tab Body
                    if (state.currentTab == 0)
                      _buildCategoriesTab(state, isArabic)
                    else
                      _buildTagsTab(state, isArabic),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(
    CrmCategoryAndTagsState state,
    bool isArabic,
  ) {
    if (state.filteredCategories.isEmpty) {
      return CrmActivityEmptyState(
        title: S.current.crmNoCategoriesAvailable,
        subtitle: S.current.crmCategoriesAddPrompt,
      );
    }

    final int crossAxisCount = CrmCardHelper.getCrossAxisCountForCards(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 78.sp,
        crossAxisSpacing: 14.sp,
        mainAxisSpacing: 14.sp,
      ),
      itemCount: state.filteredCategories.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmCategoryModel category = state.filteredCategories[index];
        return CrmCategoryCard(
          category: category,
          onTap: () => _onCategoryTap(category),
        );
      },
    );
  }

  Widget _buildTagsTab(
    CrmCategoryAndTagsState state,
    bool isArabic,
  ) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // Edit Mode Toggle Button
        if (state.tags.isNotEmpty) ...[
          customButtonWithSvg(
            title: isMobile
                ? ''
                : (state.isTagEditMode ? S.current.crmDone : S.current.crmEdit),
            function: () => _cubit.toggleTagEditMode(),
            color: state.isTagEditMode ? AppColors.grey : AppColors.primary,
            image: AppAssets.edit,
            svgColor: AppColors.black,
            widthImage: 16.sp,
            heightImage: 16.sp,
            colorBorder: AppColors.transparent,
            textStyle: StyleText.fontSize14Weight500,
          ),
          SizedBox(height: 12.h),
        ],

        if (state.filteredTags.isEmpty)
          CrmActivityEmptyState(
            title: S.current.crmNoTagsAvailable,
            subtitle: S.current.crmTagsAddPrompt,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                      context),
              mainAxisExtent: 44.sp,
              crossAxisSpacing: 12.sp,
              mainAxisSpacing: 12.sp,
            ),
            itemCount: state.filteredTags.length,
            itemBuilder: (BuildContext context, int index) {
              final CrmTagModel tag = state.filteredTags[index];
              return CrmTagCard(
                tag: tag,
                isEditMode: state.isTagEditMode,
                onTap: () => _onTagTap(tag),
                onDeleteTap: () => _onTagDelete(tag),
              );
            },
          ),
      ],
    );
  }
}
