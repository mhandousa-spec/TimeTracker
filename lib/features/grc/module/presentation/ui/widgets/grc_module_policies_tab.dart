/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_policies_tab.dart
/// Purpose: Policies tab body for GrcModuleDetailsPage. Renders the status
///          filter bar, search, create/bulk-upload action, weight-issue entry,
///          view-mode icons, and the policy list for a single GRC Module.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_export.dart';
import 'package:knowticed_plus/core/custom/51-custom_pop_up.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_policy_table_view.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/policy_list_card.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/create_new_policy.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_page.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_details_page.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart';
import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [GrcModulePoliciesTab]
///
/// purpose: Policies tab for a single [GRCModuleEntity]. Reads the provided
///          [PolicyCubit] from the widget tree and owns its own search and
///          status-filter state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class GrcModulePoliciesTab extends StatefulWidget {
  final GRCModuleEntity module;

  const GrcModulePoliciesTab({super.key, required this.module});

  @override
  State<GrcModulePoliciesTab> createState() => _GrcModulePoliciesTabState();
}

class _GrcModulePoliciesTabState extends State<GrcModulePoliciesTab> {
  final _searchController = TextEditingController();
  final GlobalKey _addPolicyButtonKey = GlobalKey();
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';

  /// Card list (grid) vs. table. Same default and same meaning as
  /// role_management_home.dart: cards first, table on request.
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// function name: [_onAddPolicyPressed]
  ///
  /// purpose: what the "+ Policy" button does, which depends on the screen.
  ///
  ///          iPhone (375) goes STRAIGHT to the single Create New Policy
  ///          page. There is no bulk-upload screen in the phone design at
  ///          all -- it exists only at 768 and 1024 -- so a two-item menu
  ///          there offered a route the phone does not have.
  ///
  ///          iPad (768) and desktop (1024) keep the anchored popup with
  ///          Add Policy / Bulk Upload.
  ///
  /// parameters:
  ///            [BuildContext] context: used to anchor the menu and push
  ///
  /// return type: [Future<void>]
  /// Whether "+ Policy" has anywhere to go on this screen.
  ///
  /// iPad/desktop show it when EITHER create switch is on, because the menu
  /// offers both routes. The phone has no bulk-upload screen, so only
  /// Create_Single_Policy can put a button there -- otherwise it would open
  /// a menu with nothing in it.
  bool _canShowAddPolicy(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.mobile
          ? GrcPermission.canCreateSinglePolicy
          : GrcPermission.canCreateAnyPolicy;

  Future<void> _onAddPolicyPressed(BuildContext context) async {
    if (screenSizeOf(context) == ScreenSize.mobile) {
      // The phone has no bulk-upload screen, so its only route is the single
      // one -- and it opens only if that switch is on. With just the bulk
      // switch granted there is nothing a phone can do here.
      if (GrcPermission.canCreateSinglePolicy) {
        await _openCreatePolicy(context);
      }
      return;
    }
    await _showPolicyCreationMenu(context);
  }

  Future<void> _showPolicyCreationMenu(BuildContext context) async {
    final buttonBox =
        _addPolicyButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonBox.localToGlobal(Offset(0, buttonBox.size.height),
            ancestor: overlayBox),
        buttonBox.localToGlobal(buttonBox.size.bottomRight(Offset.zero),
            ancestor: overlayBox),
      ),
      Offset.zero & overlayBox.size,
    );

    // GRC bug report p13 ("UI"): the stock white Material menu. Same styled
    // menu as Add Champion / Add Owner now — card colour, 8 radius, hover.
    final choice = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      color: AppColors.card,
      items: [
        // Create_Single_Policy / Create_Bulk_Upload_Policy, independently.
        if (GrcPermission.canCreateSinglePolicy)
          HoverablePopupMenuItem(value: 'add', label: S.of(context).addPolicy),
        if (GrcPermission.canBulkUploadPolicy)
          HoverablePopupMenuItem(
              value: 'bulk', label: S.of(context).bulkUpload),
      ],
    );

    if (!context.mounted) return;
    if (choice == 'add') {
      await _openCreatePolicy(context);
    } else if (choice == 'bulk') {
      await _openBulkUpload(context);
    }
  }

  /// Push the single-policy wizard, then refresh the list on the way back.
  Future<void> _openCreatePolicy(BuildContext context) async {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CreateNewPolicyPage(
          moduleId: widget.module.moduleId,
          moduleNameEn: widget.module.moduleNameEn,
          moduleNameAr: widget.module.moduleNameAr,
          moduleOwners: widget.module.moduleOwners,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    _reloadPolicies(context);
  }

  /// Push the bulk-upload flow, then refresh the list on the way back.
  Future<void> _openBulkUpload(BuildContext context) async {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PolicyBulkUploadPage(
          moduleId: widget.module.moduleId,
          moduleNameEn: widget.module.moduleNameEn,
          moduleNameAr: widget.module.moduleNameAr,
          moduleOwners: widget.module.moduleOwners,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    _reloadPolicies(context);
  }

  void _reloadPolicies(BuildContext context) {
    if (!context.mounted) return;
    context.read<PolicyCubit>().getAllPolicies(moduleId: widget.module.moduleId);
  }

  PolicyStatus? _statusForKey(String key) {
    switch (key) {
      case 'Active':
        return PolicyStatus.active;
      case 'Inactive':
        return PolicyStatus.inactive;
      case 'Scheduled':
        return PolicyStatus.scheduled;
      case 'Expired':
        return PolicyStatus.expired;
      case 'Draft':
        return PolicyStatus.draft;
      default:
        return null;
    }
  }

  List<PolicyEntity> _applyStatusFilter(List<PolicyEntity> policies) {
    final status = _statusForKey(_selectedStatusFilter);
    if (status == null) return policies;
    return policies.where((p) => p.status == status).toList();
  }

  List<PolicyEntity> _applySearch(List<PolicyEntity> policies) {
    if (_searchQuery.isEmpty) return policies;
    final q = _searchQuery.toLowerCase();
    return policies
        .where((p) =>
            p.policyNameEn.toLowerCase().contains(q) ||
            p.policyNameAr.toLowerCase().contains(q))
        .toList();
  }

  Map<String, int> _countByStatus(List<PolicyEntity> policies) {
    return {
      'all': policies.length,
      'Active': policies.where((p) => p.status == PolicyStatus.active).length,
      'Inactive':
          policies.where((p) => p.status == PolicyStatus.inactive).length,
      'Scheduled':
          policies.where((p) => p.status == PolicyStatus.scheduled).length,
      'Expired': policies.where((p) => p.status == PolicyStatus.expired).length,
      'Draft': policies.where((p) => p.status == PolicyStatus.draft).length,
    };
  }

  /// CSV of the policies currently shown (GRC bug report p20).
  Future<void> _exportPolicies(
      BuildContext context, List<PolicyEntity> rows) {
    final S s = S.of(context);
    final bool isArabic = context.isArabic;
    final DateFormat date = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');
    return exportGrcCsv(
      context: context,
      defaultFileName: 'policies',
      header: [
        s.no,
        s.policyNumber,
        s.policyName,
        s.score,
        s.policyWeight,
        s.status,
        s.startDate,
        s.endDate,
      ],
      rows: [
        for (var i = 0; i < rows.length; i++)
          <Object?>[
            i + 1,
            isArabic ? rows[i].policyNumberAr : rows[i].policyNumberEn,
            isArabic ? rows[i].policyNameAr : rows[i].policyNameEn,
            rows[i].score,
            rows[i].policyWeight,
            grcTr(context, rows[i].status.value),
            date.format(rows[i].startDate),
            date.format(rows[i].endDate),
          ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return BlocBuilder<PolicyCubit, PolicyState>(
      builder: (context, state) {
        final allPolicies =
            state is PolicyListLoaded ? state.policies : <PolicyEntity>[];
        final counts = _countByStatus(allPolicies);
        final filtered = _applySearch(_applyStatusFilter(allPolicies));
        final weightScopedPolicies = allPolicies.where((p) =>
            p.status == PolicyStatus.active ||
            p.status == PolicyStatus.scheduled);
        final weightIssueTotal = weightScopedPolicies.fold<double>(
            0, (sum, p) => sum + p.policyWeight);
        final hasPolicyWeightIssue = weightScopedPolicies.isNotEmpty &&
            (weightIssueTotal - 100).abs() >= 0.001;

        final List<MapEntry<String, Map<String, dynamic>>> status = [
          MapEntry('all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
          MapEntry('Active',
              {'num': counts['Active'] ?? 0, 'color': AppColors.green}),
          MapEntry('Inactive',
              {'num': counts['Inactive'] ?? 0, 'color': AppColors.orange}),
          MapEntry('Scheduled',
              // GRC bug report p20 "color": was orange, identical to
              // Inactive. Brand yellow, as the module list and control cards
              // colour Scheduled.
              {'num': counts['Scheduled'] ?? 0, 'color': AppColors.primary}),
          MapEntry('Expired',
              {'num': counts['Expired'] ?? 0, 'color': AppColors.red}),
          MapEntry('Draft',
              {'num': counts['Draft'] ?? 0, 'color': AppColors.colorGrey}),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 30.sp,
                  children: [
                    for (var roleEntry in status)
                      FilterBarItem(
                        // roleEntry.key is the FILTER key and stays English --
                        // _selectedStatusFilter and _countByStatus both match
                        // on it. Only the visible label is translated, which
                        // is what was missing: the bar read "Active / Expired
                        // / Draft" in the middle of an Arabic page. 'all' is
                        // lower-case as a key; its grcTr entry is 'All'.
                        title: grcTr(
                          context,
                          roleEntry.key == 'all' ? 'All' : roleEntry.key,
                        ),
                        numberOfItems: roleEntry.value['num'],
                        color: roleEntry.value['color'],
                        onTap: () => setState(
                            () => _selectedStatusFilter = roleEntry.key),
                        isSelected: roleEntry.key == _selectedStatusFilter,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15.h),

            // Search + Create Policy — stack on mobile
            if (isTablet)
              Row(
                spacing: 10.w,
                children: [
                  AppSearchTextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    hintText: S.of(context).search,
                    controller: _searchController,
                  ),
                  if (_canShowAddPolicy(context))
                  Container(
                    key: _addPolicyButtonKey,
                    child: customButtonWithSvg(
                      colorBorder: AppColors.primary,
                      space: 10.w,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      function: () => _onAddPolicyPressed(context),
                      // Was a hard-coded English literal, so the one button
                      // on the page stayed "Policy" under Arabic.
                      title: S.of(context).policy,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.textButton),
                      image:
                          'assets/icons_assets/watermark/plicy_icon.svg',
                      color: AppColors.primary,
                      svgColor: AppColors.textButton,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppSearchTextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        hintText: S.of(context).search,
                        controller: _searchController,
                      ),
                    ],
                  ),
                  if (_canShowAddPolicy(context)) ...[
                  SizedBox(height: 8.h),
                  Container(
                    key: _addPolicyButtonKey,
                    child: customButtonWithSvg(
                      colorBorder: AppColors.primary,
                      space: 10.w,
                      radius: 8.r,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      function: () => _onAddPolicyPressed(context),
                      // Was a hard-coded English literal, so the one button
                      // on the page stayed "Policy" under Arabic.
                      title: S.of(context).policy,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.textButton),
                      image: 'assets/icons_assets/watermark/plicy_icon.svg',
                      color: AppColors.primary,
                      width: double.infinity,
                      height: 36.h,
                      svgColor: AppColors.textButton,
                    ),
                  ),
                  ],
                ],
              ),
            SizedBox(height: 15.h),

            // Policy Weight Issue + view-mode icons
            Row(
              children: [
                if (hasPolicyWeightIssue &&
                    GrcPermission.canOpenPolicyWeightIssue)
                  customButton(
                    title: S.of(context).policyWeightIssue,
                    function: () async {
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              PolicyWeightIssuePage(module: widget.module),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                      if (context.mounted) {
                        context
                            .read<PolicyCubit>()
                            .getAllPolicies(moduleId: widget.module.moduleId);
                      }
                    },
                    width: isTablet ? 180.w : 160.w,
                    height: 38.h,
                    color: AppColors.primary,
                    // 14.sp on mobile (width-based), 16.sp otherwise.
                    textStyle: screenSizeOf(context) == ScreenSize.mobile
                        ? StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton, fontSize: 14.sp)
                        : StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                  ),
                const Spacer(),
                // GRC bug report p20: Export, in front of the view toggle —
                // exports exactly the policies currently listed (status tab
                // and search applied), like the other GRC tabs' Export.
                customButtonWithSvg(
                  title: '',
                  function: () => _exportPolicies(context, filtered),
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                  color: AppColors.primary,
                  image: AppAssets.export,
                  widthImage: 20.sp,
                  heightImage: 20.sp,
                  colorBorder: AppColors.transparent,
                  svgColor: AppColors.textButton,
                  fixedWidth: 38.sp,
                  fixedHeight: 38.sp,
                ),
                SizedBox(width: 8.sp),
                // Table / grid toggle. These used to be two bare Containers
                // with no onTap and no state, which is why nothing happened
                // when you pressed them. They now drive [_isGridView] through
                // the same core buttons role_management_home.dart uses, so the
                // selected/unselected look is identical across the app.
                // Hidden on mobile: a 10-column table has nowhere to go at
                // 375px, so phones stay on cards (also what roles does).
                if (screenSizeOf(context) != ScreenSize.mobile) ...[
                  customTableButton(
                    function: () => setState(() => _isGridView = false),
                    isSelected: !_isGridView,
                    color: AppColors.card,
                    selectedColor: AppColors.primary,
                    svgColor: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                    selectedSvgColor: AppColors.textButton,
                  ),
                  SizedBox(width: 8.sp),
                  customGridButton(
                    function: () => setState(() => _isGridView = true),
                    isSelected: _isGridView,
                    color: AppColors.card,
                    selectedColor: AppColors.primary,
                    svgColor: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                    selectedSvgColor: AppColors.textButton,
                  ),
                ],
              ],
            ),
            SizedBox(height: 15.h),

            Expanded(
              child: _buildPolicyList(context, state, filtered),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPolicyList(
    BuildContext context,
    PolicyState state,
    List<PolicyEntity> policies,
  ) {
    if (state is PolicyLoading) {
      return Center(
        child: const CircleProgressMaster(),
      );
    }

    if (state is PolicyFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    // The app's one empty state: the lottie_empty animation, centred, no
    // words (see 89-custom_empty_state.dart). Replaces the "noPoliciesFound"
    // sentence this branch used to print.
    if (policies.isEmpty) {
      return const Center(child: CustomEmptyState());
    }

    // Mobile never gets the table (the toggle is hidden there), so the
    // guard is belt-and-braces against a stale _isGridView after a resize.
    if (!_isGridView && screenSizeOf(context) != ScreenSize.mobile) {
      // No SingleChildScrollView here: GrcPolicyTableView already owns both
      // scrollers (horizontal outside, vertical inside), and wrapping it in a
      // second vertical one would hand its inner viewport an unbounded height.
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: GrcPolicyTableView(
          policies: policies,
          showScore: GrcPermission.canSeePolicyScore,
          onPolicyTap: (policy) =>
              openGrcPolicy(context, policy, widget.module),
        ),
      );
    }

    // Controls count + departments for each policy. Empty until PolicyCubit's
    // second pass lands -- the cards draw "-" for those two lines meanwhile.
    final Map<String, PolicyControlsSummary> summaries =
        state is PolicyListLoaded
            ? state.controlsSummary
            : const <String, PolicyControlsSummary>{};

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: policies.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) {
          final PolicyEntity policy = policies[index];
          return PolicyListCard(
            policy: policy,
            summary: summaries[policy.id],
            // Policy_Score: the block is dropped, not blanked, exactly as
            // the old ModuleInfoCard chip was.
            showScore: GrcPermission.canSeePolicyScore,
            onTap: () => openGrcPolicy(context, policy, widget.module),
          );
        },
      ),
    );
  }
}

/// function name: [openGrcPolicy]
///
/// purpose: the one navigation destination for a policy row, shared by the
///          card list and the table so both land in the same place -- a draft
///          re-opens the create wizard on the step it was left at, anything
///          else opens [PolicyDetailsPage]. Reloads the module's policies on
///          return so a status or weight change shows without a manual pull.
///
/// authors: Mohamed Magdy Abdelkhalek
Future<void> openGrcPolicy(
  BuildContext context,
  PolicyEntity policy,
  GRCModuleEntity module,
) async {
  if (policy.status == PolicyStatus.draft) {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CreateNewPolicyPage(
          moduleId: module.moduleId,
          moduleNameEn: module.moduleNameEn,
          moduleNameAr: module.moduleNameAr,
          moduleOwners: module.moduleOwners,
          existingPolicy: policy,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  } else {
    await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PolicyDetailsPage(
          policyId: policy.id,
          moduleId: module.moduleId,
          module: module,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  if (context.mounted) {
    context.read<PolicyCubit>().getAllPolicies(moduleId: module.moduleId);
  }
}
