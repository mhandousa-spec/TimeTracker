/// Module: roles / r1_role_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: role_screen.dart
/// Purpose: Declares `RoleScreenHost`, `RoleScreen`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Header is now SideFrameMasterServices, not PaginationAppBar.
/// Updated: 30/8/2026 - The Active Directory tab hides itself for a company
///                      that owns the HR module, which is where that company
///                      administers its employee records.

// ============================================================================
// COMPLETE WORKING IMPLEMENTATION
// ============================================================================

// FILE 1: role_screen.dart (UPDATED)
// ============================================================================

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/permission_label.dart';
// REMOVED 25/8/2026: `pagination_app_bar.dart` — replaced by the shared frame.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/helpers/circle_progress.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/pages/user_access_container.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/pages/csv.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/user_management_home.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/pages/system_logs_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
// ADDED 30/8/2026: the company-licence gate, used alongside the role gate in
// `_buildVisibleTabs` — see the note there.
import 'package:knowticed_plus/core/helper/role/company_modules.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_controller.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
/// Navigator key for the Roles module's nested navigator.
///
/// The app shell (left rail + CustomAppBar) is built by CustomDrawer, which is
/// itself a route on the root MaterialApp navigator. Without a nested navigator
/// here, every `Navigator.of(context).push` inside the roles module resolves to
/// the ROOT navigator and the pushed page covers the whole shell. Wrapping the
/// module in its own Navigator (same pattern as settings_screen.dart) keeps
/// sub-pages — AddingNewRole, RoleDetailsPage, RolePermissionSwitches, the user
/// management details pages — inside the frame.
GlobalKey rolesNavigatorKey = GlobalKey();

/// RoleScreen wrapped in its own Navigator. Use this wherever the roles module
/// is mounted as a drawer/nav destination; use [RoleScreen] directly only when
/// it is already inside a navigator that should own its pushes.
class RoleScreenHost extends StatelessWidget {
  const RoleScreenHost({Key? key, this.selectedIndex}) : super(key: key);
  final int? selectedIndex;

  /// Tab this module should open on, set by whoever is about to navigate here.
  ///
  /// Added 22/8/2026 so a notification can land the user on the right tab.
  /// `Modules.roles` is one drawer entry covering five tabs (Role Management,
  /// User Management, User Access, Active Directory, System Logs), and
  /// `modules_enum.dart` builds `RoleScreenHost()` with no index — so an
  /// account-locked notification, which belongs to User Access, dropped the
  /// admin on Role Management with no hint of where to go next.
  ///
  /// A static rather than a constructor argument because the caller is the
  /// notification inbox, which does not build this widget: it asks
  /// AppDrawerCubit to select the Roles entry, and `modules_enum` constructs
  /// the host afterwards. Indices match [Constants.tabletRolePageTabs].
  ///
  /// Consumed once and cleared by [RoleScreen], so it cannot silently pin the
  /// module to one tab for the rest of the session. It is honoured only if the
  /// user's permissions make that tab visible.
  static int? pendingInitialTab;

  @override
  Widget build(BuildContext context) {
    // WATERMARK 25/8/2026. This host is the whole of `Modules.roles` —
    // `modules_enum.dart` builds exactly one `RoleScreenHost()` for every form
    // factor — so one wrap here covers the module.
    //
    // The layer sits ABOVE the nested Navigator on purpose. Everything the
    // module pushes (AddingNewRole, RoleDetailsPage, RolePermissionSwitches,
    // the user-management detail pages) goes into THIS navigator by design —
    // that is the whole reason it exists — so stamping above it covers all five
    // tabs and every page reachable from them, and a roles page added later is
    // watermarked without touching this file.
    // `module: Modules.roles` ADDED 28/9/2026 — without it this layer always
    // stamped, whatever the Roles tile in the Watermark grid said.
    return WatermarkLayer(
      module: Modules.roles,
      child: Navigator(
        key: rolesNavigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => RoleScreen(selectedIndex: selectedIndex),
        ),
      ),
    );
  }
}

class RoleScreen extends StatefulWidget {
  RoleScreen({Key? key, this.selectedIndex}) : super(key: key);
  final int? selectedIndex;

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  int selectedIndex = 0;
  List<int> visibleTabIndices = [];
  late MainCoreEmployeeController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
//
    controller = AppControllers.employee;

    // Load data first
    userManagementController.getUsersPermissionsData();
    context.read<UserManagementAccessCubit>().getUserAccess();
    context.read<UserAccessCubit>().getAccountsStatusEntities();

    // ✅ Initialize everything including role permissions
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    final roleCubit = context.read<RoleCubit>();

    // Wait a bit to ensure permissions are loaded
    await Future.delayed(Duration(milliseconds: 500));

    // Force reload permissions to ensure cache is populated
    await controller.loadEmployeeRole();

    // Now check permissions and build visible tabs
    _buildVisibleTabs();

    // Set initial selected index.
    //
    // Precedence: an explicit constructor argument, then a deep link left by
    // whoever navigated here (see RoleScreenHost.pendingInitialTab), then the
    // first tab this user is allowed to see. The deep link is consumed here so
    // it applies exactly once.
    final int? requestedTab =
        widget.selectedIndex ?? RoleScreenHost.pendingInitialTab;
    RoleScreenHost.pendingInitialTab = null;

    if (requestedTab != null && visibleTabIndices.contains(requestedTab)) {
      selectedIndex = requestedTab;
    } else if (visibleTabIndices.isNotEmpty) {
      selectedIndex = visibleTabIndices.first;
    }

    // ✅ CRITICAL: Load all roles first
    await roleCubit.getUnDeletedRoles();

    // ✅ Filter out Master Admin and Operational roles
    roleCubit.filteredRoles.removeWhere((role) {
      String roleName = role.currentRoleName.toLowerCase();
      String roleNameAr = role.currentRoleNameAr.toLowerCase();

      return roleName == 'master admin' || roleNameAr == 'مسؤول رئيسي';
    });


    // ✅ CRITICAL: Preload ALL role permissions before showing screen
    if (selectedIndex == 0) {
      await roleCubit.preloadAllRolePermissions();
    }

    setState(() {
      isLoading = false;
    });
  }

  void _buildVisibleTabs() {
    visibleTabIndices.clear();

    final hasRoleManagementPermission = controller.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.roleManagement,
      permission: null,
    );
    if (hasRoleManagementPermission) {
      visibleTabIndices.add(0);
    }

    final hasUserManagementPermission = controller.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userManagement,
      permission: null,
    );
    if (hasUserManagementPermission) {
      visibleTabIndices.add(1);
    }

    final hasUserAccessPermission = controller.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: null,
    );
    if (hasUserAccessPermission) {
      visibleTabIndices.add(2);
    }

    // ── Active Directory ──────────────────────────────────────────────────
    //
    // Two gates, and they are different questions. The permission asks whether
    // THIS EMPLOYEE may see the tab; [CompanyModules.hasHr] asks whether THIS
    // COMPANY owns the HR module.
    //
    // ADDED 30/8/2026: a company that owns HR administers its employee records
    // there, and this tab is the same directory reached through a second front
    // door — two screens over one dataset, each with its own permissions, is
    // how they drift apart. So HR present ⇒ the tab is gone, whatever the role
    // permission says.
    //
    // `hasHr` is false whenever the licence is unknown (see CompanyModules), so
    // a slow or failed licence read leaves this tab exactly as it was rather
    // than hiding a screen someone needs.
    final hasActiveDirectoryPermission = controller.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.activeDirectory,
      permission: null,
    );
    if (hasActiveDirectoryPermission && !CompanyModules.hasHr) {
      visibleTabIndices.add(3);
    }

    visibleTabIndices.add(4);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED 25/8/2026: a local `isTablet` that nothing in this method read.
    // The frame does its own breakpoint work.

    // ✅ Show loading indicator while everything loads
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircleProgressMaster(),
        ),
      );
    }

    // FRAME 25/8/2026: the page header is now the shared
    // [SideFrameMasterServices] instead of `PaginationAppBar`, so the roles
    // module wears the same breadcrumb as the rest of the app (and the same one
    // its own sub-pages already use — see `employee_details_methods2.dart`).
    //
    // No `secondTitle` here: this IS the module's root screen, and the frame
    // only draws the back chevron when a deeper crumb is supplied.
    //
    // The frame also owns the 15.sp horizontal padding the page used to apply
    // itself, so the manual `Padding` is gone.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints pageConstraints) {
            return SideFrameMasterServices(
              // Role QA p.2: on a phone the long title was cut to
              // "Platform Controls and Manage..."; the shorter title fits.
              titleText: ContextExtension(context).isPhone
                  ? S.of(context).controlsAndManagement
                  : S.of(context).platformControlsAndManagement,
              child: _buildTabsAndContent(pageConstraints.maxHeight),
            );
          },
        ),
      ),
    );
  }

  /// The tab strip and the selected tab's page.
  ///
  /// [pageHeight] is the bounded height of the whole screen, measured OUTSIDE
  /// the frame — it is only consulted on the phone branch, see below.
  ///
  /// WHY THE HEIGHT DANCE
  /// --------------------
  /// [SideFrameMasterServices] lays its child out two different ways. On tablet
  /// and desktop the child goes into an `Expanded`, so it arrives with a bounded
  /// height and the `Expanded` below works normally. On a phone the frame wraps
  /// the child in a `SingleChildScrollView`, so the incoming height is
  /// UNBOUNDED — and an `Expanded` under an unbounded constraint throws
  /// ("RenderFlex children have non-zero flex but incoming height constraints
  /// are unbounded").
  ///
  /// Every tab this hosts (RoleManagementHome, UserManagementHome, the user
  /// access and logs tables) uses `Expanded` internally and therefore needs a
  /// bounded height. So on the phone branch the content is given one
  /// explicitly, leaving room for the frame's own header.
  Widget _buildTabsAndContent(double pageHeight) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget body = _tabsAndSelectedPage();

        if (constraints.hasBoundedHeight) return body;

        // Phone branch. `_phoneFrameHeaderHeight` is the frame's title row plus
        // the 20.sp gap it puts under it; the clamp keeps the content usable on
        // a very short viewport rather than collapsing to nothing.
        final double available =
            (pageHeight - _phoneFrameHeaderHeight).clamp(200.sp, pageHeight);
        return SizedBox(height: available, child: body);
      },
    );
  }

  /// Height of [SideFrameMasterServices]'s phone header: 15.sp top padding +
  /// 10.h vertical padding either side of a `fontSize24Weight600` title, plus
  /// the 20.sp spacer the frame adds beneath it.
  double get _phoneFrameHeaderHeight => 90.sp;

  Widget _tabsAndSelectedPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 32.sp,
            children: [
              for (int i = 0; i < visibleTabIndices.length; i++)
                GestureDetector(
                  onTap: () {
                    if (selectedIndex != visibleTabIndices[i]) {
                      setState(() {
                        selectedIndex = visibleTabIndices[i];
                      });
                    }
                  },
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          // FIXED 13/8/2026: Constants.tabletRolePageTabs
                          // is a hardcoded English List<String>. The
                          // list stays canonical (its indices drive
                          // selectedIndex -> indexContainer); only the
                          // rendered text is translated.
                          PermissionLabel.of(context,
                              Constants.tabletRolePageTabs[visibleTabIndices[i]]),
                          style: StyleText.fontSize20Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                            height: 1.3,
                            color: selectedIndex == visibleTabIndices[i]
                                ? AppColors.primary
                                : AppColors.secondaryBlack,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        if (selectedIndex == visibleTabIndices[i])
                          Container(
                            height: 1.5.sp,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
        SizedBox(height: 30.sp),
        Expanded(child: indexContainer(selectedIndex)),
        SizedBox(height: 20.sp),
      ],
    );
  }

  Widget indexContainer(int index) {
    switch (index) {
      case 0:
        return PlatFormRoleContainer.RoleManagementHome();
      case 1:
        roleCubit.selectedRole = null;
        userManagementController.filterUsersPermissionEntity(searchText: "");
        return UserManagementHome();
      case 2:
        return UserAccessHomePage();
      case 3:
        return const CsvView();
      case 4:
        AppControllers.systemLogs.systemLogsAction(
          'open Logs',
          module: Modules.roles,
        );
        return SystemLogsTable();
      default:
        return Container();
    }
  }
}
