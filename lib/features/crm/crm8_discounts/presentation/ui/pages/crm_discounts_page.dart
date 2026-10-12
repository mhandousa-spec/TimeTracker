// ****************** FILE INFO ******************
// File Name: crm_discounts_page.dart
// Purpose: Main Discounts page under CRM Controls with search, filter, sort, empty state, and grid
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/presentation/controller/crm_discounts_cubit.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/presentation/controller/crm_discounts_state.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/presentation/ui/widgets/crm_discount_card.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/presentation/ui/widgets/crm_discounts_search_and_filter.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDiscountsPage extends StatefulWidget {
  const CrmDiscountsPage({super.key});

  @override
  State<CrmDiscountsPage> createState() => _CrmDiscountsPageState();
}

class _CrmDiscountsPageState extends State<CrmDiscountsPage> {
  late final CrmDiscountsCubit _cubit;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _cubit = CrmDiscountsCubit()..init();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  int _getCrossAxisCount(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < 700) return 1;
    if (width < 1200) return 2;
    return 3;
  }

  Future<void> _onAddTap() async {
    final dynamic result =
        await CrmNavigationHelper.navigateToControlDiscountForm(
      context,
      arguments: <String, dynamic>{
        'mode': 'add',
        'existingDiscounts': _cubit.state.items,
        'categories': _cubit.state.categories,
        'products': _cubit.state.products,
        'clientTypes': _cubit.state.clientTypes,
        'tags': _cubit.state.tags,
      },
    );
    await _handleFormResult(result);
  }

  Future<void> _onDiscountTap(CrmDiscountModel discount) async {
    final dynamic result =
        await CrmNavigationHelper.navigateToControlDiscountDetails(
      context,
      arguments: <String, dynamic>{
        'discount': discount,
        'existingDiscounts': _cubit.state.items,
        'categories': _cubit.state.categories,
        'products': _cubit.state.products,
        'clientTypes': _cubit.state.clientTypes,
        'tags': _cubit.state.tags,
      },
    );
    await _handleFormResult(result, existingDiscount: discount);
  }

  Future<void> _handleFormResult(
    dynamic result, {
    CrmDiscountModel? existingDiscount,
  }) async {
    if (!mounted || result is! Map<String, dynamic>) return;
    final String action = (result['action'] ?? '').toString();

    if (action == 'save') {
      final CrmDiscountModel? discount =
          result['discount'] as CrmDiscountModel?;
      if (discount == null) return;

      showLoadingIndicator();
      bool saved = false;
      if (existingDiscount == null || existingDiscount.id.isEmpty) {
        saved = await _cubit.createDiscount(discount);
      } else {
        saved = await _cubit.updateDiscount(discount);
      }
      hideLoadingIndicator();

      if (!mounted || !saved) {
        if (mounted && _cubit.state.errorMessage != null) {
          CrmControlDialogs.showErrorDialog(
            context: context,
            title: S.current.crmAlert,
            subtitle: _cubit.state.errorMessage!,
          );
        }
        return;
      }

      await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: S.current.crmSuccess,
        subtitle: existingDiscount == null || existingDiscount.id.isEmpty
            ? S.current.crmDiscountSavedSuccess
            : S.current.crmDiscountUpdatedSuccess,
      );
      return;
    }

    if (action == 'delete' && existingDiscount != null) {
      showLoadingIndicator();
      final bool removed = await _cubit.deleteDiscount(existingDiscount);
      hideLoadingIndicator();
      if (!mounted || !removed) return;

      await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: S.current.crmSuccess,
        subtitle: S.current.crmDiscountDeletedSuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrmDiscountsCubit>.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: S.current.crmControlDiscount,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => Navigator.pop(context),
          child: BlocConsumer<CrmDiscountsCubit, CrmDiscountsState>(
            listener: (BuildContext context, CrmDiscountsState state) {},
            builder: (BuildContext context, CrmDiscountsState state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Top Search, Filter, Sort, Add Action Bar
                    CrmDiscountsSearchAndFilter(
                      searchController: _searchController,
                      onSearchChanged: (String query) => _cubit.search(query),
                      selectedStatus: state.selectedStatus,
                      onStatusChanged: (String status) =>
                          _cubit.setStatusFilter(status),
                      selectedSort: state.selectedSort,
                      onSortChanged: (String? sort) => _cubit.setSort(sort),
                      onAddTap: _onAddTap,
                    ),
                    SizedBox(height: 16.sp),

                    // Content: Loading / Empty / Grid List
                    if (state.isLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 80.sp),
                        child: const Center(child: CircleProgressMaster()),
                      )
                    else if (state.filteredItems.isEmpty)
                      _buildEmptyState()
                    else
                      _buildDiscountsGrid(state.filteredItems),

                    SizedBox(height: 24.sp),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: _onAddTap,
      borderRadius: BorderRadius.circular(8.sp),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.sp),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomSvgImage(
                assetPath: AppAssets.crmTemplateEmpty,
                width: 180.sp,
                height: 140.sp,
              ),
              SizedBox(height: 16.sp),
              Text(
                S.current.crmPressToAdd,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountsGrid(List<CrmDiscountModel> items) {
    final int crossAxisCount = _getCrossAxisCount(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 96.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmDiscountModel item = items[index];
        return CrmDiscountCard(
          item: item,
          onTap: () => _onDiscountTap(item),
        );
      },
    );
  }
}
