/// Module: GRC / Approvals (Department Manager)
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_list_page.dart
/// Purpose: The Department Manager's Approvals list (MAGDY →
///          "MAIN PAGE : Approvals").
/// Author: Mohamed Magdy Abdelkhalek
/// Updated: 16/9/2026 - Responsive rebuild. One layout per design width:
///            * 1024 (desktop): 3 cards per row, labelled "Filter" button.
///            * 768  (tablet):  2 cards per row, labelled "Filter" button.
///            * 375  (mobile):  1 card per row, icon-only filter button.
///          The status bar (All / Approved / Pending / Rejected), search and
///          filter are the core FilterBarItem (79), AppSearchTextField (35)
///          and CustomFilterIcon (14); the filter narrows the list to one
///          Policy. Rows are equal height; empty / loading / error use the
///          app's CustomEmptyState (89) and CircleProgressMaster (66).
library;

import 'package:knowticed_plus/features/grc/approval/presentation/ui/widgets/approval_give_score_tab.dart';
import 'package:knowticed_plus/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_underline_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_item.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/ui/pages/approval_details_page.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/ui/widgets/approval_card.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/ui/widgets/approval_filter_dialog.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The 4 tabs shown on the list page, in the order the design calls for.
/// `null` represents "All" (every item regardless of status).
const List<ApprovalStatus?> _tabOrder = [
  null,
  ApprovalStatus.approved,
  ApprovalStatus.pending,
  ApprovalStatus.rejected,
];

/// Label colour of each tab, as drawn: All in the text colour, Approved
/// green, Pending orange, Rejected red.
Color? _tabColor(ApprovalStatus? status) {
  switch (status) {
    case null:
      return null;
    case ApprovalStatus.approved:
      return AppColors.green;
    case ApprovalStatus.pending:
      return AppColors.orange;
    case ApprovalStatus.rejected:
      return AppColors.red;
  }
}

class ApprovalsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  const ApprovalsListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApprovalCubit>(
      create: (_) => GetIt.instance<ApprovalCubit>()
        ..getMyApprovals(
          moduleId: module.moduleId,
          managerEmail: currentGrcUserEmail(),
          // GRC bug report p3: the Module Owner sees all module evidence.
          includeAllInModule: module.moduleOwners.any((e) =>
              e.trim().toLowerCase() ==
              currentGrcUserEmail().trim().toLowerCase()),
        ),
      child: _ApprovalsListBody(module: module),
    );
  }
}

class _ApprovalsListBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _ApprovalsListBody({required this.module});

  @override
  State<_ApprovalsListBody> createState() => _ApprovalsListBodyState();
}

class _ApprovalsListBodyState extends State<_ApprovalsListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0;

  /// GRC bug report p3: the Module Owner's three kinds of approval —
  /// 0 Reassign (reassign champion / owner requests), 1 Evidence (this list),
  /// 2 Give Score (controls whose owner may not score, see p2).
  int _section = 1;

  bool get _isModuleOwner {
    final String me = currentGrcUserEmail().trim().toLowerCase();
    return widget.module.moduleOwners
        .any((e) => e.trim().toLowerCase() == me);
  }

  /// Policy chosen in the filter dialog; null = every policy.
  String? _policyFilter;

  /// Last list the cubit delivered. Kept so the page does not blank out
  /// while a refresh (after an approve / reject) is loading.
  List<ApprovalItem> _lastItems = const <ApprovalItem>[];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ApprovalItem> _filter(List<ApprovalItem> items, bool isArabic) {
    final ApprovalStatus? status = _tabOrder[_selectedTabIndex];
    Iterable<ApprovalItem> result = status == null
        ? items
        : items.where((i) => i.approval.status == status);
    if (_policyFilter != null) {
      result = result.where((i) => i.policy.id == _policyFilter);
    }
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return result.toList();
    return result.where((i) {
      final String name =
          isArabic ? i.control.controlsNameAr : i.control.controlsNameEn;
      final String policyName =
          isArabic ? i.policy.policyNameAr : i.policy.policyNameEn;
      final String champion = employeeDisplayName(
          context, i.assignmentControl.controlChampionEmail);
      return name.toLowerCase().contains(query) ||
          policyName.toLowerCase().contains(query) ||
          champion.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openFilter(List<ApprovalItem> items, bool isArabic) async {
    final Map<String, String> byId = <String, String>{};
    for (final ApprovalItem i in items) {
      byId[i.policy.id] = isArabic ? i.policy.policyNameAr : i.policy.policyNameEn;
    }
    final String? picked = await showApprovalFilterDialog(
      context: context,
      selectedPolicyId: _policyFilter,
      policies: [
        for (final MapEntry<String, String> e in byId.entries)
          ApprovalPolicyOption(id: e.key, name: e.value),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _policyFilter = picked.isEmpty ? null : picked);
  }

  void _openDetails(ApprovalItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BlocProvider.value(
          value: context.read<ApprovalCubit>(),
          child: ApprovalDetailsPage(item: item, module: widget.module),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 2),
      secondTitle: widget.module.localizedName(isArabic: isArabic),
      onSecondTap: () => popFrameRoutes(context, 1),
      thirdTitle: S.of(context).approvals,
      // The list is an Expanded, which needs a bounded height on a phone.
      child: SideFrameBoundedBody(
        child: !_isModuleOwner
            ? _evidence(isArabic)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GrcUnderlineTabs(
                    labels: [
                      isArabic ? 'إعادة التعيين' : 'Reassign',
                      isArabic ? 'الأدلة' : 'Evidence',
                      isArabic ? 'منح الدرجة' : 'Give Score',
                    ],
                    selected: _section,
                    onChanged: (i) => setState(() => _section = i),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: switch (_section) {
                      0 => GrcRequestsListPage(
                          module: widget.module,
                          embedded: true,
                        ),
                      2 => ApprovalGiveScoreTab(module: widget.module),
                      _ => _evidence(isArabic),
                    },
                  ),
                ],
              ),
      ),
    );
  }

  /// The evidence approvals list (unchanged — now the "Evidence" tab for a
  /// Module Owner, and the whole page for everyone else).
  Widget _evidence(bool isArabic) {
    return BlocBuilder<ApprovalCubit, ApprovalState>(
          buildWhen: (_, current) =>
              current is ApprovalListLoaded ||
              current is ApprovalFailure ||
              current is ApprovalLoading,
          builder: (context, state) {
            if (state is ApprovalListLoaded) _lastItems = state.items;
            final bool isLoading = state is ApprovalLoading ||
                (state is! ApprovalListLoaded && state is! ApprovalFailure);
            final List<ApprovalItem> allItems = _lastItems;
            final List<ApprovalItem> filtered = _filter(allItems, isArabic);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusBar(allItems),
                SizedBox(height: 15.h),
                _buildSearchRow(allItems, isArabic),
                SizedBox(height: 15.h),
                Expanded(
                  child: _buildBody(
                    state: state,
                    isLoading: isLoading && allItems.isEmpty,
                    items: filtered,
                    isArabic: isArabic,
                  ),
                ),
              ],
            );
          },
        );
  }

  Widget _buildStatusBar(List<ApprovalItem> allItems) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: isMobile ? 15.sp : 30.sp,
          children: [
            for (var i = 0; i < _tabOrder.length; i++)
              FilterBarItem(
                title: _tabOrder[i] == null
                    ? S.of(context).all
                    : grcTr(context, _tabOrder[i]!.value),
                numberOfItems: _tabOrder[i] == null
                    ? allItems.length
                    : allItems
                        .where((e) => e.approval.status == _tabOrder[i])
                        .length,
                color: _tabColor(_tabOrder[i]),
                isSelected: _selectedTabIndex == i,
                onTap: () => setState(() => _selectedTabIndex = i),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow(List<ApprovalItem> allItems, bool isArabic) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final bool isFiltered = _policyFilter != null;
    return Row(
      children: [
        AppSearchTextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          hintText: S.of(context).search,
        ),
        SizedBox(width: isMobile ? 10.sp : 15.sp),
        // Phone: 38×38 icon only. Tablet / desktop: 100 wide "Filter".
        CustomFilterIcon(
          title: S.of(context).filter,
          onTap: () => _openFilter(allItems, isArabic),
          color: isFiltered ? AppColors.primary : AppColors.card,
          borderColor: AppColors.transparent,
          svgColor:
              isFiltered ? AppColors.textButton : AppColors.secondaryText,
          textStyle: StyleText.fontSize16Weight400.copyWith(
            color: isFiltered ? AppColors.textButton : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildBody({
    required ApprovalState state,
    required bool isLoading,
    required List<ApprovalItem> items,
    required bool isArabic,
  }) {
    if (state is ApprovalFailure && _lastItems.isEmpty) {
      return Center(
        child: Text(
          state.message,
          textAlign: TextAlign.center,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
        ),
      );
    }
    if (isLoading) {
      return const Center(child: CircleProgressMaster());
    }
    if (items.isEmpty) {
      return const Center(child: CustomEmptyState());
    }

    // 1 / 2 / 3 cards per row at 375 / 768 / 1024, equal height per row.
    final int columns =
        responsiveValue(context, mobile: 1, tablet: 2, desktop: 3);
    final int rows = (items.length / columns).ceil();
    final double gap = 15.sp;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 15.h),
        itemCount: rows,
        separatorBuilder: (_, __) => SizedBox(height: gap),
        itemBuilder: (_, row) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List<Widget>.generate(columns * 2 - 1, (slot) {
              if (slot.isOdd) return SizedBox(width: gap);
              final int index = row * columns + slot ~/ 2;
              if (index >= items.length) {
                return const Expanded(child: SizedBox());
              }
              final ApprovalItem item = items[index];
              return Expanded(
                child: ApprovalCard(
                  item: item,
                  isArabic: isArabic,
                  onTap: () => _openDetails(item),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
