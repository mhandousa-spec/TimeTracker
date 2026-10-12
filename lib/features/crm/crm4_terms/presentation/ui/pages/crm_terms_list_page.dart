// ****************** FILE INFO ******************
// File Name: crm_terms_list_page.dart
// Purpose: Terms list page under CRM controls
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_card_helper.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm_di.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/presentation/controller/crm_terms_cubit.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/presentation/controller/crm_terms_state.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/presentation/ui/widgets/crm_term_card.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/presentation/ui/widgets/crm_terms_search_and_filter.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTermsListPage extends StatefulWidget {
  const CrmTermsListPage({super.key});

  @override
  State<CrmTermsListPage> createState() => _CrmTermsListPageState();
}

class _CrmTermsListPageState extends State<CrmTermsListPage> {
  final TextEditingController _searchController = TextEditingController();
  late final CrmTermsCubit _cubit;

  @override
  void initState() {
    super.initState();
    registerCrmDependencies();
    _cubit = CrmTermsCubit()..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _onAddTap() async {
    final dynamic result = await CrmNavigationHelper.navigateToControlTermForm(
      context,
      arguments: const <String, dynamic>{
        'mode': 'add',
      },
    );
    await _handleFormResult(result);
  }

  Future<void> _onTermTap(CrmTermModel term) async {
    final dynamic result = await CrmNavigationHelper.navigateToControlTermForm(
      context,
      arguments: <String, dynamic>{
        'term': term,
        'mode': 'view',
      },
    );
    await _handleFormResult(result, existingTerm: term);
  }

  Future<void> _handleFormResult(
    dynamic result, {
    CrmTermModel? existingTerm,
  }) async {
    if (!mounted || result is! Map<String, dynamic>) return;
    final String action = (result['action'] ?? '').toString();

    if (action == 'save') {
      final CrmTermModel? term = result['term'] as CrmTermModel?;
      if (term == null) return;

      showLoadingIndicator();
      bool saved = false;
      if (existingTerm == null || existingTerm.id.isEmpty) {
        saved = await _cubit.createTerm(
          nameEn: term.nameEn,
          nameAr: term.nameAr,
          status: term.status,
          clauses: term.clauses,
        );
      } else {
        saved = await _cubit.updateTerm(
          currentTerm: existingTerm,
          nameEn: term.nameEn,
          nameAr: term.nameAr,
          status: term.status,
          clauses: term.clauses,
        );
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
        subtitle: existingTerm == null || existingTerm.id.isEmpty
            ? S.current.crmTermAddedSuccess
            : S.current.crmTermUpdatedSuccess,
      );
      return;
    }

    if (action == 'delete' && existingTerm != null) {
      showLoadingIndicator();
      final bool removed = await _cubit.deleteTerm(existingTerm);
      hideLoadingIndicator();
      if (!mounted || !removed) return;
      await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: S.current.crmSuccess,
        subtitle: S.current.crmTermDeletedSuccess,
      );
    }
  }

  List<StatusChipItem> _statusItems(CrmTermsState state) {
    final int allCount = state.items.length;
    final int activeCount = state.items.where((t) => t.isActive).length;
    final int inactiveCount = state.items.where((t) => !t.isActive).length;

    return <StatusChipItem>[
      StatusChipItem(
        key: 'All',
        label: S.current.crmAll,
        count: allCount,
      ),
      StatusChipItem(
        key: 'Active',
        label: S.current.crmActive,
        count: activeCount,
      ),
      StatusChipItem(
        key: 'Inactive',
        label: S.current.crmInactive,
        count: inactiveCount,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = CrmCardHelper.getCrossAxisCountForCards(context);

    return BlocProvider<CrmTermsCubit>.value(
      value: _cubit,
      child: BlocBuilder<CrmTermsCubit, CrmTermsState>(
        builder: (BuildContext context, CrmTermsState state) {
          final List<CrmTermModel> items = state.filteredItems;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: S.current.crm,
              secondTitle: S.current.crmSectionControls,
              thirdTitle: S.current.crmTerms,
              onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
              onSecondTap: () => CrmNavigationHelper.pop(context),
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
                    CrmTermsSearchAndFilter(
                      searchController: _searchController,
                      onSearchChanged: _cubit.search,
                      selectedSort: state.selectedSort,
                      onSortChanged: _cubit.setSort,
                      onAddTap: _onAddTap,
                    ),
                    SizedBox(height: 16.sp),
                    if (state.isLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.sp),
                        child: const Center(child: CircleProgressMaster()),
                      )
                    else if (items.isEmpty)
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
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CrmTermModel term = items[index];
                          return CrmTermCard(
                            term: term,
                            onTap: () => _onTermTap(term),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomSvgImage(
              assetPath: AppAssets.crmRelationshipEmpty,
              width: 140.sp,
              height: 140.sp,
            ),
            SizedBox(height: 16.sp),
            Text(
              S.current.crmNoTermsAvailable,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 6.sp),
            Text(
              S.current.crmTermsAddPrompt,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
