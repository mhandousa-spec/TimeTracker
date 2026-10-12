/// Module: GRC Module Management
/// Description: Provides the GRC dashboard/details page showing module
///              analytics, filter tabs, and quick-action buttons.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies: Flutter SDK, AppColors, AppTheme, PaginationAppBar,
///               PolicyCubit, GRCModuleEntity
/// Revision History: 2026-06-28 - Initial creation
///                   2026-07-06 - Scoped to a single GRC Module: real title,
///                                real policy list/counts from PolicyCubit,
///                                Create Policy now passes moduleId
///                                (Mohamed Magdy Abdelkhalek)
///                   2026-07-27 - Split per-tab bodies into dedicated widget
///                                files and dispatch tabs via enum switch
///                                (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_details_page.dart
/// Purpose: Contains GrcModuleDetailsPage, the GRC dashboard screen scoped
///          to a single GRC Module and its Policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/ui/pages/approvals_list_page.dart';
import 'package:knowticed_plus/features/grc/approved_evidence/presentation/ui/pages/approved_evidence_page.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/ui/pages/grc_dashboard_page.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/widgets/department_common_widgets.dart'
    show kDepartmentPhoneControlHeight;
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/widgets/department_dashboard_tab.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/my_audit/presentation/ui/pages/my_audits_list_page.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_module_champions_tab.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_module_owners_tab.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_module_policies_tab.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/ui/pages/assignment_controls_list_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';

/// enum name: [GrcModuleDetailTab]
///
/// purpose: identifies which tab body is currently selected on the GRC module
///          details screen. The order matches the [_GrcModuleDetailsBodyState]
///          `_tabs` labels so `GrcModuleDetailTab.values[index]` maps a
///          CustomTabs index to its tab identity.
enum GrcModuleDetailTab { policies, champions, owners, departments }

/// class name: [GrcModuleDetailsPage]
///
/// purpose: GRC dashboard screen scoped to a single [GRCModuleEntity].
///          Provides a [PolicyCubit] that loads every Policy belonging to
///          [module] and renders the real status counts and policy list.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GrcModuleDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;

  const GrcModuleDetailsPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(
          create: (_) => GetIt.instance<PolicyCubit>()
            ..getAllPolicies(moduleId: module.moduleId),
        ),
        BlocProvider<ChampionCubit>(
          create: (_) => GetIt.instance<ChampionCubit>()
            ..getAllChampions(moduleId: module.moduleId),
        ),
        BlocProvider<OwnerCubit>(
          create: (_) => GetIt.instance<OwnerCubit>()
            ..getAllOwners(moduleId: module.moduleId),
        ),
      ],
      child: _GrcModuleDetailsBody(module: module),
    );
  }
}

class _GrcModuleDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _GrcModuleDetailsBody({required this.module});

  @override
  State<_GrcModuleDetailsBody> createState() => _GrcModuleDetailsBodyState();
}

class _GrcModuleDetailsBodyState extends State<_GrcModuleDetailsBody> {
  static const _tabs = [
    'Policies',
    'Control Champions',
    'Control Owners',
    'Departments',
  ];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final selectedTab = GrcModuleDetailTab.values[_selectedTab];
    final isChampionOrOwnerTab = selectedTab == GrcModuleDetailTab.champions ||
        selectedTab == GrcModuleDetailTab.owners ||
        // The Departments design also shows only Dashboard up top.
        selectedTab == GrcModuleDetailTab.departments;

    // Frame owns the Scaffold (phone), the breadcrumb and the 15.sp side
    // padding, so this page no longer builds any of them itself.
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => Navigator.of(context).maybePop(),
      secondTitle: widget.module.localizedName(isArabic: context.isArabic),
      child: SideFrameBoundedBody(
        // The tab content at the foot of this column is an Expanded, which
        // needs a bounded height — the frame's phone branch does not give one.
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Module action buttons. Figma draws these at 38 high with
              // fixed widths (Approved Evidence 180, Assignment Controls 175,
              // the rest 135) and a 10 gap, at all three sizes -- what
              // changes is how they are arranged:
              //
              //   iPad (768) / desktop (1024): two rows --
              //     [Approved Evidence ............... Dashboard]
              //     [Approvals  Assignment Controls .. My Audits]
              //
              //   iPhone (375): 345 of content cannot hold that, so the
              //     design flows all five through one spread-out wrap --
              //     [Assignment Controls ..... Dashboard]
              //     [Approvals ......... Approved Evidence]
              //     [My Audits]
              _buildModuleActions(isChampionOrOwnerTab),
              SizedBox(height: 15.h),

              CustomTabs(
                // CustomTabs takes titles that are ALREADY translated -- the
                // raw _tabs strings were reaching it untouched, which is why
                // the tab row stayed English on an Arabic screen while the
                // heading under it (line ~359) was correct: that one already
                // went through grcTr. _tabs stays English because it is the
                // lookup key, for grcTr here and for GrcModuleDetailTab.
                tabs: <String>[
                  for (final String tab in _tabs) grcTr(context, tab),
                ],
                selectedValue: _selectedTab,
                onChanged: (v) => setState(() => _selectedTab = v),
              ),
              SizedBox(height: 15.h),

              Expanded(
                child: _buildTabContent(context, selectedTab),
              ),
            ],
          ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // MODULE ACTION BUTTONS
  // ------------------------------------------------------------------

  /// Figma's button widths, shared by every breakpoint so the phone wrap
  /// and the iPad rows stay the same buttons. Height is not listed per
  /// button: ButtonSizing pins every custom button to 38 app-wide, which is
  /// exactly what the design draws.
  static const double _actionHeight = 38;
  static const double _wideActionWidth = 180;   // Approved Evidence
  static const double _mediumActionWidth = 155; // Assignment Controls
  /// The rest: 100 on a phone, 135 on tablet / desktop. A getter, not a
  /// static field -- it needs this State's `context`, which a static
  /// initializer cannot see.
  double get _actionWidth => context.isPhone ? 100 : 135;

  TextStyle get _actionTextStyle => context.isPhone ?StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton):
      StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton);

  Widget _approvedEvidenceButton() {
    return customButton(
      width: context.isPhone ?  _wideActionWidth : 190.sp ,
      radius: 8.r,
      title: S.of(context).approvedEvidence,
      function: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              ApprovedEvidencePage(module: widget.module),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      color: AppColors.primary,
      textStyle: _actionTextStyle,
    );
  }

  Widget _dashboardButton() {
    return customButton(
      title: S.of(context).dashboard,
      // Same page from every tab (Policies, Champions, Owners), scoped to
      // this module. Gated upstream on Main_Module_Dashboard.
      function: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              GrcDashboardPage(module: widget.module),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      width: _actionWidth.w,
      color: AppColors.primary,
      textStyle: _actionTextStyle,
    );
  }

  Widget _approvalsButton() {
    return customButton(
      title: S.of(context).approvals,
      function: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              ApprovalsListPage(module: widget.module),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      width: _actionWidth.w,
      color:  AppColors.primary,
      textStyle: _actionTextStyle,
    );
  }

  Widget _assignmentControlsButton() {
    return customButton(
      title: S.of(context).assignmentControls,
      function: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              AssignmentControlsListPage(module: widget.module),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      width: context.isPhone ?  _mediumActionWidth.w : 170.sp ,
      color: AppColors.primary,
      textStyle: _actionTextStyle,
    );
  }

  Widget _myAuditsButton() {
    return customButton(
      title: S.of(context).myAudits,
      function: () async {
        await Navigator.push<bool>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                MyAuditsListPage(module: widget.module),
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
      width: _actionWidth.w,
      color: AppColors.primary,
      textStyle: _actionTextStyle,
    );
  }

  /// function name: [_buildModuleActions]
  ///
  /// purpose: lay the module action buttons out the way the design draws
  ///          them for the current screen size.
  ///
  /// parameters:
  ///            [bool] isChampionOrOwnerTab: on the Champions and Owners
  ///            tabs only the Dashboard action applies, so the rest are
  ///            dropped and it sits on the trailing edge -- unchanged from
  ///            before this became responsive.
  ///
  /// return type: [Widget]
  Widget _buildModuleActions(bool isChampionOrOwnerTab) {
    final bool canOpenDashboard = GrcPermission.canOpenMainModuleDashboard;

    if (isChampionOrOwnerTab) {
      if (!canOpenDashboard) return const SizedBox.shrink();
      final bool isPhone = screenSizeOf(context) == ScreenSize.mobile;
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        // Phone: 33.sp, matching the Departments tab controls under it
        // (customButton draws 38.sp; the tight box wins).
        child: SizedBox(
          height: isPhone ? kDepartmentPhoneControlHeight.sp : null,
          child: _dashboardButton(),
        ),
      );
    }

    // iPhone (375): one wrap, spread across the row, in the order the
    // design lists them.
    if (screenSizeOf(context) == ScreenSize.mobile) {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _assignmentControlsButton(),
            _approvedEvidenceButton(),
            _approvalsButton(),
            _myAuditsButton(),
            if (canOpenDashboard) _dashboardButton(),
          ],
        ),
      );
    }

    // iPad (768) and desktop (1024): the two-row arrangement.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _approvedEvidenceButton(),
            if (canOpenDashboard) _dashboardButton(),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _approvalsButton(),
            SizedBox(width: 10.w),
            _assignmentControlsButton(),
            const Spacer(),
            _myAuditsButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context, GrcModuleDetailTab tab) {
    switch (tab) {
      case GrcModuleDetailTab.policies:
        return GrcModulePoliciesTab(module: widget.module);
      case GrcModuleDetailTab.champions:
        return GrcModuleChampionsTab(module: widget.module);
      case GrcModuleDetailTab.owners:
        return GrcModuleOwnersTab(module: widget.module);
      case GrcModuleDetailTab.departments:
        // MAGDY "Dashboard Of All Departments".
        return DepartmentDashboardTab(module: widget.module);
    }
  }
}
