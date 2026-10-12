// ****************** FILE INFO ******************
// File Name: crm_products_page.dart
// Purpose: Full CRM Products page managing Categories and Items with Table and Grid views.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/controller/crm_products_cubit.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/controller/crm_products_state.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/widgets/crm_product_category_card.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/widgets/crm_product_item_card.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/widgets/crm_product_items_table.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/widgets/crm_products_empty_state.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/widgets/crm_products_kpi_bar.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/widgets/crm_products_search_bar.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/widgets/crm_products_tab_bar.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/widgets/crm_products_view_toggle_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmProductsPage extends StatefulWidget {
  const CrmProductsPage({super.key});

  @override
  State<CrmProductsPage> createState() => _CrmProductsPageState();
}

class _CrmProductsPageState extends State<CrmProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  late final CrmProductsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CrmProductsCubit()..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _openCategoryForm(
    CrmProductsState state, {
    CrmProductCategoryModel? category,
    String mode = 'add',
  }) async {
    final dynamic result =
        await CrmNavigationHelper.navigateToProductCategoryForm(
      context,
      arguments: <String, dynamic>{
        'category': category,
        'mode': mode,
        'clientTypes': state.clientTypes,
        'tags': state.tags,
        'existingCategories': state.categories,
      },
    );
    if (!mounted || result is! Map<String, dynamic>) return;
    final String? action = result['action'] as String?;
    final CrmProductCategoryModel? item =
        result['category'] as CrmProductCategoryModel?;

    showLoadingIndicator();
    final bool success = action == 'save' && item != null
        ? (category == null
            ? await _cubit.create(item)
            : await _cubit.update(item))
        : action == 'delete' && category != null
            ? await _cubit.remove(category)
            : action == 'status' && category != null
                ? await _cubit.setActive(category, result['isActive'] == true)
                : false;
    hideLoadingIndicator();

    if (mounted) {
      if (success) {
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: action == 'delete'
              ? S.current.crmCategoryDeletedSuccess
              : S.current.crmCategorySavedSuccess,
        );
      } else if (_cubit.state.errorMessage != null) {
        CrmControlDialogs.showErrorDialog(
          context: context,
          title: S.current.crmAlert,
          subtitle: _cubit.state.errorMessage!,
        );
      }
    }
  }

  Future<void> _openProductForm(
    CrmProductsState state, {
    CrmProductItemModel? product,
    String mode = 'add',
  }) async {
    final dynamic result = await CrmNavigationHelper.navigateToProductItemForm(
      context,
      arguments: <String, dynamic>{
        'product': product,
        'mode': mode,
        'categories': state.categories,
        'existingProducts': state.products,
        'discounts': state.discounts,
      },
    );
    if (!mounted || result is! Map<String, dynamic>) return;
    final String? action = result['action'] as String?;
    final CrmProductItemModel? item = result['product'] as CrmProductItemModel?;

    showLoadingIndicator();
    final bool success = action == 'save' && item != null
        ? (product == null
            ? await _cubit.createProduct(item)
            : await _cubit.updateProduct(item))
        : action == 'delete' && product != null
            ? await _cubit.removeProduct(product)
            : action == 'status' && product != null
                ? await _cubit.setProductActive(
                    product, result['isActive'] == true)
                : false;
    hideLoadingIndicator();

    if (mounted) {
      if (success) {
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: action == 'delete'
              ? S.current.crmCategoryDeletedSuccess
              : S.current.crmCategorySavedSuccess,
        );
      } else if (_cubit.state.errorMessage != null) {
        CrmControlDialogs.showErrorDialog(
          context: context,
          title: S.current.crmAlert,
          subtitle: _cubit.state.errorMessage!,
        );
      }
    }
  }

  void _onAddTap(CrmProductsState state) {
    if (state.currentTab == 0) {
      _openCategoryForm(state);
    } else {
      _openProductForm(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrmProductsCubit>.value(
      value: _cubit,
      child: BlocBuilder<CrmProductsCubit, CrmProductsState>(
        builder: (BuildContext context, CrmProductsState state) {
          final int totalCount = state.currentTab == 0
              ? state.categories.length
              : state.products.length;
          final int activeCount = state.currentTab == 0
              ? state.categories
                  .where((CrmProductCategoryModel item) => item.isActive)
                  .length
              : state.products
                  .where((CrmProductItemModel item) => item.isActive)
                  .length;
          final int inactiveCount = state.currentTab == 0
              ? state.categories
                  .where((CrmProductCategoryModel item) => !item.isActive)
                  .length
              : state.products
                  .where((CrmProductItemModel item) => !item.isActive)
                  .length;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: S.current.crm,
              secondTitle: S.current.crmSectionProducts,
              onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Dual Tab Switcher: Categories / Items
                    CrmProductsTabBar(
                      selectedIndex: state.currentTab,
                      onTabChanged: _cubit.setTab,
                    ),
                    SizedBox(height: 18.sp),

                    // 2. Status KPI Counters Chip Bar (All, Active, Inactive)
                    CrmProductsKpiBar(
                      totalCount: totalCount,
                      activeCount: activeCount,
                      inactiveCount: inactiveCount,
                      selectedStatus: state.status,
                      onStatusSelected: _cubit.setStatus,
                    ),
                    SizedBox(height: 18.sp),

                    // 3. Search and Action Row (Search field + Filter popup + Add button)
                    CrmProductsSearchBar(
                      searchController: _searchController,
                      onSearchChanged: _cubit.search,
                      selectedStatus: state.status,
                      onStatusChanged: _cubit.setStatus,
                      onAddTap: () => _onAddTap(state),
                      addButtonTitle: S.current.crmAdd,
                    ),
                    SizedBox(height: 16.sp),

                    // 4. View Mode Toggles Bar (Items tab only)
                    if (state.currentTab == 1) ...[
                      CrmProductsViewToggleBar(
                        isGridView: state.isGridView,
                        onViewModeChanged: _cubit.setViewMode,
                        onExportTap: () {
                          CrmControlDialogs.showSuccessDialog(
                            context: context,
                            title: S.current.crmSuccess,
                            subtitle: 'Export started successfully',
                          );
                        },
                      ),
                      SizedBox(height: 14.sp),
                    ],

                    // 5. Grid or Table or Empty State Content
                    _buildContent(state),
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

  Widget _buildContent(CrmProductsState state) {
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 48.sp),
        child: const Center(child: CircleProgressMaster()),
      );
    }

    if (state.currentTab == 0) {
      return _buildCategoriesContent(state);
    } else {
      return _buildProductsContent(state);
    }
  }

  Widget _buildCategoriesContent(CrmProductsState state) {
    if (state.filteredCategories.isEmpty) {
      return CrmProductsEmptyState(
        title: S.current.crmPressToAdd,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        mainAxisExtent: 70.sp,
        crossAxisSpacing: 14.sp,
        mainAxisSpacing: 14.sp,
      ),
      itemCount: state.filteredCategories.length,
      itemBuilder: (BuildContext ctx, int index) {
        final CrmProductCategoryModel item = state.filteredCategories[index];
        return CrmProductCategoryCard(
          category: item,
          onTap: () => _openCategoryForm(state, category: item, mode: 'view'),
        );
      },
    );
  }

  Widget _buildProductsContent(CrmProductsState state) {
    if (state.filteredProducts.isEmpty) {
      return CrmProductsEmptyState(
        title: S.current.crmNoCategoriesAvailable,
        subtitle: S.current.crmPressToAdd,
      );
    }

    if (!state.isGridView) {
      // Table View matching Figma 119:132799
      return CrmProductItemsTable(
        products: state.filteredProducts,
        onItemTap: (CrmProductItemModel item) =>
            _openProductForm(state, product: item, mode: 'view'),
      );
    }

    // Grid View matching Figma 119:134728
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getProductsCrossAxisCount(context),
        mainAxisExtent: 97.sp,
        crossAxisSpacing: 14.sp,
        mainAxisSpacing: 14.sp,
      ),
      itemCount: state.filteredProducts.length,
      itemBuilder: (BuildContext ctx, int index) {
        final CrmProductItemModel item = state.filteredProducts[index];
        return CrmProductItemCard(
          product: item,
          onTap: () => _openProductForm(state, product: item, mode: 'view'),
        );
      },
    );
  }

  int _getProductsCrossAxisCount(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 650) {
      return 1;
    } else if (screenWidth < 1350) {
      return 2;
    } else if (screenWidth < 1800) {
      return 3;
    } else {
      return 4;
    }
  }
}
