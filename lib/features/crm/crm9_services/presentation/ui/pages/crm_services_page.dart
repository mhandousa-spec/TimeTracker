// ****************** FILE INFO ******************
// File Name: crm_services_page.dart
// Purpose: Full CRM Services page managing Categories and Items with Table and Grid views and full localization.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/controller/crm_services_cubit.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/controller/crm_services_state.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/widgets/crm_service_category_card.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/widgets/crm_service_item_card.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/widgets/crm_service_items_table.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/widgets/crm_services_empty_state.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/widgets/crm_services_kpi_bar.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/widgets/crm_services_search_bar.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/widgets/crm_services_tab_bar.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/widgets/crm_services_view_toggle_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmServicesPage extends StatefulWidget {
  const CrmServicesPage({super.key});

  @override
  State<CrmServicesPage> createState() => _CrmServicesPageState();
}

class _CrmServicesPageState extends State<CrmServicesPage> {
  final TextEditingController _searchController = TextEditingController();
  late final CrmServicesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CrmServicesCubit()..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _openCategoryForm(
    CrmServicesState state, {
    CrmServiceCategoryModel? category,
    String mode = 'add',
  }) async {
    final dynamic result =
        await CrmNavigationHelper.navigateToServiceCategoryForm(
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
    final CrmServiceCategoryModel? item =
        result['category'] as CrmServiceCategoryModel?;

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

  Future<void> _openServiceForm(
    CrmServicesState state, {
    CrmServiceItemModel? service,
    String mode = 'add',
  }) async {
    final dynamic result = await CrmNavigationHelper.navigateToServiceItemForm(
      context,
      arguments: <String, dynamic>{
        'service': service,
        'mode': mode,
        'categories': state.categories,
        'existingServices': state.services,
        'discounts': state.discounts,
      },
    );
    if (!mounted || result is! Map<String, dynamic>) return;
    final String? action = result['action'] as String?;
    final CrmServiceItemModel? item = result['service'] as CrmServiceItemModel?;

    showLoadingIndicator();
    final bool success = action == 'save' && item != null
        ? (service == null
            ? await _cubit.createService(item)
            : await _cubit.updateService(item))
        : action == 'delete' && service != null
            ? await _cubit.removeService(service)
            : action == 'status' && service != null
                ? await _cubit.setServiceActive(
                    service, result['isActive'] == true)
                : false;
    hideLoadingIndicator();

    if (mounted) {
      if (success) {
        final String subtitle = action == 'delete'
            ? S.current.servicesDeleteDone
            : service == null
                ? S.current.successfullyCreatedService
                : S.current.successfullyEditedService;
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccess,
          subtitle: subtitle,
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

  int _getServicesCrossAxisCount(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrmServicesCubit>.value(
      value: _cubit,
      child: BlocBuilder<CrmServicesCubit, CrmServicesState>(
        builder: (BuildContext context, CrmServicesState state) {
          final bool isCategoryTab = state.currentTab == 0;
          final int totalCount =
              isCategoryTab ? state.categories.length : state.services.length;
          final int activeCount = isCategoryTab
              ? state.categories
                  .where((CrmServiceCategoryModel c) => c.isActive)
                  .length
              : state.services
                  .where((CrmServiceItemModel s) => s.isActive)
                  .length;
          final int inactiveCount = isCategoryTab
              ? state.categories
                  .where((CrmServiceCategoryModel c) => !c.isActive)
                  .length
              : state.services
                  .where((CrmServiceItemModel s) => !s.isActive)
                  .length;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: S.current.crm,
              secondTitle: S.current.crmSectionServices,
              onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
              child: state.isLoading
                  ? const Center(child: CircleProgressMaster())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CrmServicesTabBar(
                            selectedIndex: state.currentTab,
                            onTabChanged: (int index) => _cubit.setTab(index),
                          ),
                          SizedBox(height: 16.sp),
                          CrmServicesSearchBar(
                            searchController: _searchController,
                            selectedStatus: state.status,
                            onSearchChanged: (String val) => _cubit.search(val),
                            onStatusChanged: (String val) =>
                                _cubit.setStatus(val),
                            addButtonTitle: isCategoryTab
                                ? S.current.crmAddCategory
                                : S.current.addService,
                            onAddTap: () {
                              if (isCategoryTab) {
                                _openCategoryForm(state, mode: 'add');
                              } else {
                                _openServiceForm(state, mode: 'add');
                              }
                            },
                          ),
                          SizedBox(height: 14.sp),
                          CrmServicesKpiBar(
                            totalCount: totalCount,
                            activeCount: activeCount,
                            inactiveCount: inactiveCount,
                            selectedStatus: state.status,
                            onStatusSelected: (String val) =>
                                _cubit.setStatus(val),
                          ),
                          if (!isCategoryTab &&
                              state.services.isNotEmpty) ...<Widget>[
                            SizedBox(height: 14.sp),
                            CrmServicesViewToggleBar(
                              isGridView: state.isGridView,
                              onViewModeChanged: (bool isGrid) =>
                                  _cubit.setViewMode(isGrid),
                              onExportTap: () {},
                            ),
                          ],
                          SizedBox(height: 16.sp),
                          if (isCategoryTab)
                            _buildCategoriesSection(state)
                          else
                            _buildServicesSection(state),
                          SizedBox(height: 24.sp),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection(CrmServicesState state) {
    if (state.filteredCategories.isEmpty) {
      return CrmServicesEmptyState(
        title: S.current.crmNoCategoriesAvailable,
        subtitle: S.current.crmPressToAdd,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        mainAxisExtent: 72.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: state.filteredCategories.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmServiceCategoryModel item = state.filteredCategories[index];
        return CrmServiceCategoryCard(
          category: item,
          onTap: () => _openCategoryForm(state, category: item, mode: 'view'),
        );
      },
    );
  }

  Widget _buildServicesSection(CrmServicesState state) {
    if (state.filteredServices.isEmpty) {
      return CrmServicesEmptyState(
        title: S.current.noServicesFound,
        subtitle: S.current.crmPressToAdd,
      );
    }

    if (state.isGridView) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getServicesCrossAxisCount(context),
          mainAxisExtent: 97.sp,
          crossAxisSpacing: 12.sp,
          mainAxisSpacing: 12.sp,
        ),
        itemCount: state.filteredServices.length,
        itemBuilder: (BuildContext context, int index) {
          final CrmServiceItemModel item = state.filteredServices[index];
          return CrmServiceItemCard(
            service: item,
            onTap: () => _openServiceForm(state, service: item, mode: 'view'),
          );
        },
      );
    }

    return CrmServiceItemsTable(
      services: state.filteredServices,
      onItemTap: (CrmServiceItemModel item) =>
          _openServiceForm(state, service: item, mode: 'view'),
    );
  }
}
