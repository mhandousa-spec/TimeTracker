/// Module: roles / r2_user_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_home.dart
/// Purpose: Declares `UserManagementHome`, `UserAccessStatusColor`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Search now uses the shared AppSearchTextField.
/// Updated: 25/8/2026 - Status filter chips now render localized names.
/// Updated: 30/8/2026 - The `Access Granted` / `Access Revoked` grouping chips
///                      dropped from the status filter bar.
/// Updated: 30/8/2026 - The Requests button hides itself for a company that
///                      owns the HR module, which administers those requests.

import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED 25/8/2026: `2-custom_textfield.dart` — the only CustomTextField on
// this page was the search box, now AppSearchTextField (which wraps it).
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/services_app_module/core/configs/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/svg_custom.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/custom_buttons.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/custom_button_with_image.dart' hide customButtonWithImage;
// REMOVED 9/10/2026: user_role_repository.dart import — only the deleted limit debug dialog used it.
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/request_page_approval.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
// REMOVED 9/10/2026: api_constants.dart import — only the deleted `_getCompanyId` used it.
// ADDED 28/8/2026 for the Requests button's pending-count badge — same
// collection and path the Requests screen itself reads.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/localized_digits.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s1_create_service/upload_file/upload_file.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s2_details_service/details_service/widget/info_text.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
// ADDED 30/8/2026: the company-licence gate behind `_showRequests`.
import 'package:knowticed_plus/core/helper/role/company_modules.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/user_management_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_access_status_label.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/grid_table_export.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_management_export_dialog.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_management_table_widget.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_permission_overview.dart';
import './add_new_users_access.dart';
// REPLACED 21/9/2026: `import_page.dart` (UploadFileTabletRoles) was never
// reachable and wrote Firestore directly; the Import button opens this.
import './bulk_access_upload/access_bulk_upload_page.dart';
import './role_user_details.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
// ADDED 8/9/2026: the Requests button draws its own content (count + label),
// so it takes its height/radius/padding from the same source customButton does.
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:collection/collection.dart';
part '../widgets/user_management_home_methods1.dart';

class UserManagementHome extends StatefulWidget {
  @override
  State<UserManagementHome> createState() => _UserManagementHomeState();
}

class _UserManagementHomeState extends State<UserManagementHome> {
  late UserManagementAccessCubit controller;
  bool isGridView = true;

  /// Extra safety net: if a role IS present in RoleCubit but its current status
  /// is one of these, hide it anyway.
  static const Set<String> _hiddenRoleStatuses = {'inactive', 'deleted'};

  /// The statuses the filter bar offers.
  ///
  /// ADDED 30/8/2026: every [UserAccessStatus] except the two grouping values
  /// [UserAccessStatus.accessGranted] and [UserAccessStatus.accessRevoked],
  /// which are unions of the states already listed here and so gave the bar two
  /// chips that could not narrow anything the others did not.
  static const List<UserAccessStatus> _visibleStatusFilters = <UserAccessStatus>[
    UserAccessStatus.all,
    UserAccessStatus.active,
    UserAccessStatus.scheduled,
    UserAccessStatus.inactive,
    UserAccessStatus.expiringSoon,
  ];

  /// Whether the Requests button belongs on this screen at all.
  ///
  /// ADDED 30/8/2026. See the note at the call site in `build`: the role
  /// permission and the company's HR licence are two different questions, and
  /// the button needs a yes from the first and a no from the second.
  bool get _showRequests {
    final bool mayReviewRequests = AppControllers.employee.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userManagement,
      permission: UserManagement.usersRequests,
    );

    return mayReviewRequests && !CompanyModules.hasHr;
  }

  @override
  void initState() {
    super.initState();
    RoleLogService.log(RoleLogService.pageUserManagementHome);

    try {
      controller = context.read<UserManagementAccessCubit>();

      WidgetsBinding.instance.addPostFrameCallback((_) {

        controller.initializeWithAllFilter();

        controller.getUserAccess();

      });

    } catch (e, stackTrace) {
      // Was an empty `catch {}` — a failure to kick off the initial load left
      // the page blank with no signal at all (§11.5).
      debugPrint('user_management_home: initial load failed: $e\n$stackTrace');
    }
  }

  /// Resolve a role from RoleCubit by its stored access key (case-insensitive).
  RoleHistoryModel? _resolveRole(String roleKey) {
    final String normalizedKey = roleKey.trim().toLowerCase();
    try {
      final RoleCubit roleCubit = context.read<RoleCubit>();
      return roleCubit.roles.firstWhereOrNull(
            (r) =>
        r.currentRoleName.trim().toLowerCase() == normalizedKey ||
            r.roleId.trim().toLowerCase() == normalizedKey,
      );
    } catch (e) {
      return null;
    }
  }



  /// ✅ Get localized role name from role ID (case-insensitive resolve).
  String _getLocalizedRoleName(String roleId) {
    final role = _resolveRole(roleId);

    if (role != null) {
      return !context.isArabic
          ? role.currentRoleName
          : role.currentRoleNameAr;
    }

    return FormatHelper.capitalize(roleId);
  }


  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return BlocListener<UserManagementAccessCubit, UserManagementAccessState>(
      listenWhen: (_, state) => state is UserManagementAccessError,
      listener: (context, state) {
        if (state is UserManagementAccessError) {
          CustomDialogManager.showSuccess(
            context: context,
            lottiePath: 'assets/lottie_assets/main_lottie_assets/warning.json',
            title: state.message,
          );
        }
      },
      child: BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
        buildWhen: (_, currentState) {
          return currentState is UserPermissionsDataLoaded ||
              currentState is UserPermissionsDataLoading ||
              currentState is UserPermissionsDataError;
        },
        builder: (context, state) {
          if (state is UserPermissionsDataLoading) {
            return Center(child: CircleProgressMaster());
          }

          if (state is UserPermissionsDataError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
                  SizedBox(height: 16.sp),
                  Text('Error: ${state.message}'),
                  SizedBox(height: 16.sp),
                  ElevatedButton(
                    onPressed: () => controller.getUserAccess(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final sortedRoles = _getSortedRolesWithAll();

          // ✅ Hide users whose assigned role no longer exists (deleted/inactive),
          // so the grid/table stays consistent with the filter-bar counts.
          final visiblePermissions = controller.filteredUsersPermissions
              .where((p) => _isRoleVisible(p.accessName ?? 'unknown'))
              .toList();

          return Column(
            spacing: 10.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Role QA p.7: the Requests button moved up, above the role
              // counts, so the counts sit directly on top of the search row.
              // ── Requests button ───────────────────────────────────────────
              //
              // Two gates, asking different things. The permission asks whether
              // THIS EMPLOYEE may review requests; [CompanyModules.hasHr] asks
              // whether THIS COMPANY owns the HR module.
              //
              // ADDED 30/8/2026: a company that owns HR raises and approves
              // employee requests there, so this queue would be a second inbox
              // over the same work — and a request actioned in one place would
              // leave the other's badge counting it. HR present ⇒ no Requests
              // button here, whatever the role permission says.
              //
              // `hasHr` is false whenever the licence is unknown (see
              // CompanyModules), so a slow or failed licence read leaves the
              // button exactly where it was rather than hiding a queue someone
              // is working.
              _showRequests
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _requestsButtonWithBadge(context),
                ],
              )
                  : SizedBox.shrink(),


              // Role filter bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 30.sp,
                  children: [
                    for (var roleEntry in sortedRoles)
                      FilterBarItem(
                        title: FormatHelper.capitalize(
                            roleEntry.key == 'all'
                                ? S.of(context).all
                                : _getLocalizedRoleName(roleEntry.key)
                        ),
                        numberOfItems: roleEntry.value,
                        onTap: () => controller.selectNewRole(roleEntry.key),
                        isSelected: controller.selectedRole == roleEntry.key,
                      ),
                  ],
                ),
              ),

              SizedBox(height: 5.sp),

              // Search and action buttons row
              Row(
                children: [
                  // REPLACED 25/8/2026: a search box hand-rolled out of
                  // CustomTextField. [AppSearchTextField] is the app's search
                  // field; using it also retires two local quirks — a Material
                  // `Icons.search` where every other search shows the app's
                  // magnifier SVG, and a hardcoded ar/en hint ternary where the
                  // widget's default `S.of(context).search` covers every locale.
                  //
                  // It supplies its OWN `Expanded`, so it goes straight into
                  // this Row with no wrapper.
                  AppSearchTextField(
                    controller: controller.homePageSearchController,
                    fillColor: AppColors.card,
                    textInputAction: TextInputAction.search,
                    // 16.sp search hint per design.
                    hintFontSize: 16,
                    // Role QA p.7: the magnifier sat tight against the hint;
                    // same icon with room on both sides.
                    prefixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: 12.sp, end: 8.sp),
                      child: CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/search_magnifier_alt.svg",
                        width: 16.sp,
                        height: 16.sp,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          AppTheme.isDark
                              ? AppColors.lightGrey
                              : AppColors.neutralIconGrey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    onChanged: (value) => controller.filterHomePageUser(value),
                  ),

                  AppControllers.employee.isHasPermission(
                    module: Modules.roles,
                    section: RolePermissionsSections.userManagement,
                    permission: UserManagement.giveAccess,
                  )
                      ? Row(
                        children: [
                          SizedBox(width: 10.sp),
                          customButtonWithSvg(
                                              title: isMobile ? "" : S.of(context).access,
                                              function: () {
                          RoleCubit roleCubit = context.read<RoleCubit>();
                          final validRoles = roleCubit.roles
                              .where((e) => e.currentRoleName.isNotEmpty)
                              .toList();
                          List<String> roleNames = validRoles
                              .map((e) => e.currentRoleName)
                              .toList();
                          List<String> roleNamesAr = validRoles
                              .map((e) => e.currentRoleNameAr.trim().isNotEmpty
                              ? e.currentRoleNameAr.trim()
                              : e.currentRoleName)
                              .toList();

                          controller.initNewAccessController(roleNames, roleNamesAr);
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                            return BlocProvider<UserManagementAccessCubit>.value(
                              value: controller,
                              child: AddNewUsersAccess(),
                            );
                          }));
                                              },
                                              color: AppColors.primary,
                                              textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                                              ),
                                              heightImage: 16.h,
                                              widthImage: 16.w,
                                              svgColor: AppColors.textButton,
                                              image: "assets/icons_assets/main_icons_assets/user_access_workflow.svg",
                                              space: 8.sp,
                                              colorBorder: AppColors.transparent,),
                        ],
                      )
                      : SizedBox(),
                ],
              ),

              // Status filter and export row
              //
              // FIXED 8/9/2026: "A RenderFlex overflowed by 97 pixels on the
              // right." The status chips are as wide as their labels — five of
              // them in Arabic, plus the view/export buttons, do not fit one
              // phone width. The chips now scroll horizontally inside an
              // Expanded, so the row can never overflow however many filters
              // are visible, and the view/export buttons stay pinned at the end
              // where they were.
              Row(
                spacing: 8.sp,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8.sp,
                        children: [
                  // REMOVED 30/8/2026: the two grouping chips, `accessGranted`
                  // and `accessRevoked`. They are views over the lifecycle
                  // states already on this row (granted = active + scheduled +
                  // expiring soon, revoked = inactive), so they duplicated the
                  // chips beside them. The enum values stay — the access-date
                  // columns and the export still speak in those terms — only
                  // the filter bar drops them.
                  for (UserAccessStatus status in _visibleStatusFilters)
                    customButton(
                      // Filter chips hug their label (+10.sp each side)
                      // instead of the app-wide fixed button width.
                      wrapContent: true,
                      contentHorizontalPadding: 10.sp,
                      color: controller.selectedUserAccessStatus == status
                          ? AppColors.primary
                          : AppColors.card,
                      textStyle: controller.selectedUserAccessStatus == status
                          ? null
                          : StyleText.fontSize14Weight400.copyWith(
                        color: status.color,
                      ),
                      // LOCALIZED 25/8/2026: was
                      // `FormatHelper.capitalize(status.name)`, the raw enum
                      // identifier — English on an Arabic screen, and
                      // `expiringSoon` kept its camelCase hump because
                      // `capitalize` only touches the first letter.
                      title: status.label(context),
                      function: () => controller.selectNewAccessStatus(status),),
                        ],
                      ),
                    ),
                  ),
                  ViewToggleButtons(
                    isGridView: isGridView,
                    onTableViewTap: () => setState(() => isGridView = false),
                    onGridViewTap: () => setState(() => isGridView = true),
                    showExport: true,
                    // ADDED 21/9/2026 — bug report p.1 / Figma 4717:33513.
                    // Behind the role's `Import_Users_Data` switch, like the
                    // Access button beside the search is behind `Give_Access`.
                    onImportTap: AppControllers.employee.isHasPermission(
                      module: Modules.roles,
                      section: RolePermissionsSections.userManagement,
                      permission: UserManagement.importUsersData,
                    )
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AccessBulkUploadPage(
                                userManagement: controller,
                              ),
                            ))
                        : null,
                    onExportTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => UserManagementExportDialog(
                          userPermissions: visiblePermissions,
                        ),
                      );
                    },
                  )
                ],
              ),

              // Grid or Table view
              Expanded(
                child: visiblePermissions.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                          width: 200.w,
                          height: 200.h,
                          "assets/lottie_assets/notification_lottie_assets/empty.json",
                          fit: BoxFit.fill,
                          repeat: true
                      ),
                    ],
                  ),
                )
                    : isGridView
                    ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: CrossAxisCountHelper
                          .getCrossAxisCountForDefaultTablet2(context),
                      // 96.sp was ~8sp short of the card's real content height
                      // (avatar + name/role/status stack + the dates row),
                      // which is what produced the bottom overflow stripes.
                      mainAxisExtent: context.isPhone ? 100.sp : 108.sp,
                      mainAxisSpacing: 10.sp,
                      crossAxisSpacing: 10.sp,
                    ),
                    itemCount: visiblePermissions.length,
                    itemBuilder: (context, index) {
                      return UserPermissionOverview(
                          userPermissionEntity: visiblePermissions[index]
                      );
                    })
                    : SingleChildScrollView(
                  child: UserManagementTableWidget(
                    userPermissions: visiblePermissions,
                    locale: context.languageCode,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }











  /// Function Name: [_requestsButtonWithBadge]
  ///
  /// Purpose: The Requests button, carrying a count of the requests still
  /// waiting on a reviewer.
  ///
  /// ADDED 28/8/2026.
  ///
  /// The number is the PENDING count, not the total: this badge exists to say
  /// "there is something here for you to action", and approved / rejected /
  /// cancelled rows are already dealt with. It reads the same collection the
  /// Requests screen itself loads (`_fetchRequestsFromFirebase` in
  /// request_page_approval.dart) so the two can never disagree, and it is a
  /// STREAM rather than a one-shot read, so acting on a request updates the
  /// badge without coming back to this page.
  ///
  /// The count is scoped to the whole queue, matching that screen — this button
  /// is only rendered behind the `Users_Requests` permission, so its audience
  /// is reviewers, for whom the queue is the right scope.
  ///
  /// The badge hides itself at zero rather than drawing a "0".
  Widget _requestsButtonWithBadge(BuildContext context) {
    final String title = FormatHelper.capitalize(S.of(context).requests);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .doc('${getBaseUrl('Modules')}/roles')
          .collection(FirebaseCollections.employeesRequest)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // While connecting, or if the read fails, show the bare button — a
        // badge is an extra, and a failed count must not cost the button.
        final int pendingCount =
            snapshot.hasError ? 0 : (snapshot.data?.docs.length ?? 0);

        // CHANGED 8/9/2026: the count used to be a red tag pinned OUTSIDE the
        // button's top-start corner, overhanging whatever sat above it. It now
        // sits INSIDE the button, before the label: an AppColors.card chip with
        // the number in AppColors.text.
        //
        // The button is built here rather than through `customButton` because
        // that takes a title string and no child, so there is nowhere to put
        // the chip. Height, radius and horizontal padding still come from
        // [ButtonSizing], so it matches every other button in the app.
        // Hidden at zero rather than drawing a "0".
        return GestureDetector(
          onTap: () {
            HapticController.low();
            navigateTo(context, RequestPageApproval());
          },
          child: Container(
            height: ButtonSizing.height,
            padding: EdgeInsets.symmetric(
              horizontal: ButtonSizing.horizontalPadding,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(ButtonSizing.radius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (pendingCount > 0) ...<Widget>[
                  Container(
                    // padding: EdgeInsets.symmetric(
                    //   horizontal: 6.sp,
                    //   vertical: 2.sp,
                    // ),
                    // constraints: BoxConstraints(minWidth: 18.sp),

                    width: 25.sp,
                    height: 30.sp,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(6.sp),
                    ),
                    child: Text(
                      LocalizedDigits.apply(
                        '$pendingCount',
                        context.isArabic ? 'ar' : 'en',
                      ),
                      style: StyleText.fontSize12Weight600
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                  SizedBox(width: 8.sp),
                ],
                Text(
                  title,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.textButton),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Maps [UserAccessStatus] to a theme colour.
///
/// This used to be `UserAccessStatus.getColor(BuildContext)` declared on the
/// enum itself, which forced `package:flutter/material.dart` into the data
/// layer. Colour is a presentation concern, so the mapping lives here — the
/// only place that ever asked for it.
extension UserAccessStatusColor on UserAccessStatus {
  Color get color {
    switch (this) {
      case UserAccessStatus.all:
        return AppColors.text;
      case UserAccessStatus.active:
        return AppColors.green;
      case UserAccessStatus.scheduled:
        return AppColors.orange;
      case UserAccessStatus.inactive:
        return AppColors.red;
      case UserAccessStatus.expiringSoon:
        return AppColors.expiringSoon;
      case UserAccessStatus.accessGranted:
        return AppColors.green;
      case UserAccessStatus.accessRevoked:
        return AppColors.red;
    }
  }
}
