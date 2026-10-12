// ****************** FILE INFO ******************
// File Name: crm_relationship_list_page.dart
// Purpose: Firebase-backed relationship categories list page under CRM controls
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_card_helper.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm_di.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/presentation/controller/crm_relationship_cubit.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/presentation/controller/crm_relationship_state.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/presentation/ui/widgets/crm_relationship_card.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/presentation/ui/widgets/crm_relationship_search_and_filter.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmRelationshipListPage extends StatefulWidget {
  const CrmRelationshipListPage({super.key});

  @override
  State<CrmRelationshipListPage> createState() =>
      _CrmRelationshipListPageState();
}

class _CrmRelationshipListPageState extends State<CrmRelationshipListPage> {
  final TextEditingController _searchController = TextEditingController();
  late final CrmRelationshipCubit _cubit;

  @override
  void initState() {
    super.initState();
    registerCrmDependencies();
    _cubit = CrmRelationshipCubit()..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _onAddTap() async {
    final dynamic result =
        await CrmNavigationHelper.navigateToControlRelationshipAddCategory(
      context,
      arguments: const <String, dynamic>{
        'mode': 'add',
      },
    );
    await _handleFormResult(result);
  }

  Future<void> _onCategoryTap(CrmRelationshipCategoryModel category) async {
    final dynamic result =
        await CrmNavigationHelper.navigateToControlRelationshipAddCategory(
      context,
      arguments: <String, dynamic>{
        'category': category,
        'mode': 'view',
      },
    );
    await _handleFormResult(result, existingCategory: category);
  }

  Future<void> _handleFormResult(
    dynamic result, {
    CrmRelationshipCategoryModel? existingCategory,
  }) async {
    if (!mounted || result is! Map<String, dynamic>) return;
    final String action = (result['action'] ?? '').toString();

    if (action == 'save') {
      final CrmRelationshipCategoryModel? category =
          result['category'] as CrmRelationshipCategoryModel?;
      if (category == null) return;

      showLoadingIndicator();
      bool saved = false;
      if (existingCategory == null) {
        saved = await _cubit.createCategory(
          nameEn: category.nameEn,
          nameAr: category.nameAr,
          status: category.status,
          types: category.types
              .map(
                (type) => <String, String>{
                  'Id': type.id,
                  'Name_En': type.nameEn,
                  'Name_Ar': type.nameAr,
                },
              )
              .toList(),
        );
      } else {
        saved = await _cubit.updateCategory(
          currentCategory: existingCategory,
          nameEn: category.nameEn,
          nameAr: category.nameAr,
          status: category.status,
          types: category.types
              .map(
                (type) => <String, String>{
                  'Id': type.id,
                  'Name_En': type.nameEn,
                  'Name_Ar': type.nameAr,
                },
              )
              .toList(),
        );
      }
      hideLoadingIndicator();
      if (!mounted || !saved) return;
      await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: S.current.crmSuccess,
        subtitle: existingCategory == null
            ? S.current.crmRelationshipAddedSuccess
            : S.current.crmRelationshipUpdatedSuccess,
      );
      return;
    }

    if (action == 'delete' && existingCategory != null) {
      showLoadingIndicator();
      final bool removed =
          await _cubit.removeCategory(category: existingCategory);
      hideLoadingIndicator();
      if (!mounted || !removed) return;
      await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: S.current.crmSuccess,
        subtitle: S.current.crmRelationshipDeletedSuccess,
      );
    }
  }

  List<StatusChipItem> _statusItems(CrmRelationshipState state) {
    final List<CrmRelationshipCategoryModel> categories = state.items;
    final int total = categories.length;
    final int active =
        categories.where((c) => c.status.toLowerCase() == 'active').length;
    final int inactive =
        categories.where((c) => c.status.toLowerCase() == 'inactive').length;

    return <StatusChipItem>[
      StatusChipItem(
        key: 'All',
        label: S.current.crmAll,
        count: total,
      ),
      StatusChipItem(
        key: 'Active',
        label: S.current.crmActive,
        count: active,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: 'Inactive',
        label: S.current.crmInactive,
        count: inactive,
        labelColor: AppColors.orange,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrmRelationshipCubit>.value(
      value: _cubit,
      child: BlocConsumer<CrmRelationshipCubit, CrmRelationshipState>(
        listener: (BuildContext context, CrmRelationshipState state) {
          final String? message = state.errorMessage;
          if (message != null && message.isNotEmpty) {
            CrmControlDialogs.showErrorDialog(
              context: context,
              title: S.current.crmAlert,
              subtitle: message,
            );
            _cubit.clearMessages();
          }
        },
        builder: (BuildContext context, CrmRelationshipState state) {
          final int crossAxisCount = _getCrossAxisCount(context);
          final List<CrmRelationshipCategoryModel> displayed =
              state.filteredItems;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: S.current.crm,
              secondTitle: S.current.crmRelationship,
              onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (state.items.isNotEmpty) ...<Widget>[
                      StatusChipFilter(
                        selectedKey: state.selectedStatus,
                        onSelected: _cubit.setStatusFilter,
                        items: _statusItems(state),
                      ),
                      SizedBox(height: 14.sp),
                    ],
                    CrmRelationshipSearchAndFilter(
                      searchController: _searchController,
                      onSearchChanged: _cubit.search,
                      selectedSort: state.selectedSort,
                      onSortChanged: _cubit.setSort,
                      onFilterChanged: _cubit.setSort,
                      onAddTap: _onAddTap,
                    ),
                    SizedBox(height: 22.sp),
                    if (state.isLoading && state.items.isEmpty)
                      const SizedBox(
                        height: 240,
                        child: Center(child: CircleProgressMaster()),
                      )
                    else if (displayed.isEmpty)
                      _buildEmptyState()
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: 78.sp,
                          crossAxisSpacing: 14.sp,
                          mainAxisSpacing: 14.sp,
                        ),
                        itemCount: displayed.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CrmRelationshipCategoryModel category =
                              displayed[index];
                          return CrmRelationshipCard(
                            category: category,
                            onTap: () => _onCategoryTap(category),
                          );
                        },
                      ),
                    if (state.isSaving) ...<Widget>[
                      SizedBox(height: 16.sp),
                      const Center(child: CircleProgressMaster()),
                    ],
                    SizedBox(height: 32.sp),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    return CrmCardHelper.getCrossAxisCountForCards(context);
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: _onAddTap,
      borderRadius: BorderRadius.circular(12.sp),
      child: Container(
        width: double.infinity,
        height: 400.sp,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomSvgImage(
              assetPath: AppAssets.crmRelationshipEmpty,
              width: 250.sp,
              height: 250.sp,
            ),
            SizedBox(height: 16.sp),
            Text(
              S.current.crmPressToAdd,
              style: StyleText.fontSize16Weight500.copyWith(color: AppColors.inputColor).copyWith(
                color: AppColors.lightGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
