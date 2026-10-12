/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_roles_widgets.dart
/// Purpose: The four Roles cards on the home page and in the Adding Widget
///          picker — `RoleManagementWidget`, `UserManagementWidget`,
///          `UserAccessWidget` and `UserManagementRequestsWidget`.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// Source: Figma file BuJXLizpGcK5eHVBqQomXc, Settings > Home Layout >
/// Adding Widget — nodes 7488:10062 (Role Management, 265x120),
/// 7488:10143 (User Management, 405x120), 7490:11044 (User Access, 405x120)
/// and 7488:10264 (User Management Requests, 265x120). Until now
/// `home_components.dart` carried the note "(Database / Role / User Access:
/// designed, no components built yet)" — this closes the Role / User Access
/// half of it.
///
/// LIVE FIGURES, NOT PLACEHOLDERS
/// ------------------------------
/// Every count comes from `RolesHomeStatsCubit`, which reads the same
/// repositories the three feature modules read. Figma draws a 10 in each slot;
/// those are placeholder values in the design, not a spec. The Settings pair
/// (`CommentsAndFeedbacksWidget` / `MySettingsRequestsWidget`) set the
/// precedent for a picker card showing real records.
///
/// LABELS AND COLOURS ARE THE FEATURES' OWN
/// ----------------------------------------
/// Nothing here re-spells a status. `RoleStatus.localizedName`,
/// `UserAccessStatusLabel.label` and `EmployeeStatusStyle.localizedName` are
/// the same extensions the role, user-management and user-access screens use,
/// so a card and the screen behind it always read the same word in the same
/// language. Only four ARB keys are new, and only because Figma names the role
/// tiles "Active Roles" / "Inactive Roles" / "Draft Roles" rather than plain
/// "Active" / "Inactive" / "Draft".
///
/// ICONS
/// -----
/// The glyphs are the app's own status icons, not the Figma exports. The
/// exported assets for these frames come back as a dozen sub-path fragments per
/// icon (g2461, g469, g1357 …) rather than whole glyphs, so they cannot be
/// committed as icon files; the closest existing asset is used instead. If a
/// designer wants exact parity, the icons need re-exporting from Figma as
/// flattened SVGs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/roles_home_stats_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/roles_home_stats_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/theme/employee_status_style.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_access_status_label.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The module glyph in every Roles card header — the yellow people-and-gear
/// mark Figma draws top-right on all four.
final String _kRolesIcon = Modules.roles.iconPath;

/// Shared scaffolding for the four cards.
///
/// Each one is `HomeWidgetCard` + a row of `HomeStatTile`s over the same cubit,
/// differing only in title, width and which counts it pulls — so the BlocBuilder,
/// the `ensureLoaded` call and the loading placeholder live here once.
class _RolesStatCard extends StatelessWidget {
  final String title;
  final double width;

  /// Builds the tiles from the loaded cubit. Called on every state, including
  /// while loading — [_RolesStatCard] passes the placeholder through
  /// [countOf] rather than swapping the whole card for a spinner, so the
  /// layout does not jump when the figures land.
  final List<HomeStatTile> Function(BuildContext context, String Function(int) format)
      tiles;

  const _RolesStatCard({
    required this.title,
    required this.width,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    // Lazy by design: BlocProvider builds the cubit on this first read, and the
    // cubit fetches on this first ensureLoaded. A user who never opens Home or
    // the widget picker never triggers either.
    context.read<RolesHomeStatsCubit>().ensureLoaded();

    return BlocBuilder<RolesHomeStatsCubit, RolesHomeStatsState>(
      builder: (BuildContext context, RolesHomeStatsState state) {
        final bool ready = state is RolesHomeStatsLoaded;

        // An em dash while the counts are in the air, and if a source failed.
        // Showing 0 there would be a claim we cannot make — "no pending
        // requests" and "we could not read the requests" are different facts.
        String format(int value) =>
            ready ? LocalizedNumber.of(context, value) : '—';

        return HomeWidgetCard(
          title: title,
          icon: _kRolesIcon,
          width: width,
          child: HomeStatTileRow(tiles: tiles(context, format)),
        );
      },
    );
  }
}



/// Figma 7488:10062 — "Role Management", two grid columns.
class RoleManagementWidget extends StatelessWidget {
  /// Carried for parity with every other component widget.
  final HomeComponentModel model;

  const RoleManagementWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _RolesStatCard(
      title: l.roleManagement,
      // Three stats — the compact width. Was a bare `260`; same number, now
      // shared by every three-stat card. See [kHomeWidgetCompactWidth].
      width: kHomeWidgetCompactWidth,
      tiles: (BuildContext context, String Function(int) format) {
        final Map<RoleStatus, int> counts =
            context.read<RolesHomeStatsCubit>().roleCounts;
        return <HomeStatTile>[
          HomeStatTile(
            icon: HomeWidgetSvg.statusActive,
            label: l.activeRoles,
            value: format(counts[RoleStatus.active] ?? 0),
            iconColor: RoleStatus.active.color,
            labelMaxLines: 1,
          ),
          HomeStatTile(
            icon: HomeWidgetSvg.statusInactive,
            label: l.inactiveRoles,
            value: format(counts[RoleStatus.inactive] ?? 0),
            iconColor: RoleStatus.inactive.color,
            labelMaxLines: 1,
          ),
          HomeStatTile(
            icon: HomeWidgetSvg.statusDraft,
            label: l.draftRoles,
            value: format(counts[RoleStatus.draft] ?? 0),
            iconColor: RoleStatus.draft.color,
            labelMaxLines: 1,
          ),
        ];
      },
    );
  }
}

/// Figma 7488:10143 — "User Management", three grid columns.
///
/// Counts access GRANTS (`UserPermissionEntity.accessStatus`), which is what
/// the user-management home's own status chips count — not accounts. The User
/// Access card below is the one that counts accounts.
class UserManagementWidget extends StatelessWidget {
  final HomeComponentModel model;

  const UserManagementWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _RolesStatCard(
      title: l.userManagement,
      // WIDENED 21/9/2026 to kHomeWidgetFullWidth, together with User Access
      // below — "Expiring Soon" was ellipsed at 405 (bug report p.14).
      width: kHomeWidgetFullWidth,
      tiles: (BuildContext context, String Function(int) format) {
        final Map<UserAccessStatus, int> counts =
            context.read<RolesHomeStatsCubit>().accessCounts;

        HomeStatTile tile(UserAccessStatus status, String icon) => HomeStatTile(
              icon: icon,
              label: status.label(context),
              value: format(counts[status] ?? 0),
              labelMaxLines: 1,
            );

        return <HomeStatTile>[
          tile(UserAccessStatus.active, HomeWidgetSvg.statusActive),
          tile(UserAccessStatus.inactive, HomeWidgetSvg.statusInactive),
          tile(UserAccessStatus.scheduled, HomeWidgetSvg.statusScheduled),
          tile(UserAccessStatus.expiringSoon, HomeWidgetSvg.pending),
        ];
      },
    );
  }
}

/// Figma 7490:11044 — "User Access", three grid columns.
///
/// The four statuses are the first four chips of
/// `AccountStatusConstants.employeeStatus` after "All", in that order —
/// Active · Deactivate · Locked · Scheduled Deactivation.
class UserAccessWidget extends StatelessWidget {
  final HomeComponentModel model;

  const UserAccessWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _RolesStatCard(
      title: l.userAccess,
      // NARROWED 28/8/2026 back to kHomeWidgetWideWidth (405), the four-stat
      // width User Management uses — the stat cards take only two widths now,
      // one per tile count, so this card lines up with the rest of the row
      // instead of running to 600 on its own.
      //
      // This reverses the 25/8/2026 widening, which was made because "Scheduled
      // Deactivation" does not fit ~90pt at this type size. It still does not:
      // that label (and its Arabic counterpart, which runs wider) now
      // ELLIPSES rather than wrapping, because every tile here passes
      // `labelMaxLines: 1`. So the row stays aligned and nothing overflows —
      // the cost is a truncated label on the widest tile. Restoring the full
      // label means either a shorter string for that status or letting this one
      // card off the two-width rule.
      //
      // WIDENED 21/9/2026 — review asked for the full labels ("Deactivated",
      // "Scheduled Deactivation" were ellipsed, bug report p.14). Both
      // four-stat cards (this one and User Management) now take
      // kHomeWidgetFullWidth, so they still share one width with each other.
      width: kHomeWidgetFullWidth,
      tiles: (BuildContext context, String Function(int) format) {
        final Map<EmployeeStatusEnum, int> counts =
            context.read<RolesHomeStatsCubit>().accountCounts;

        HomeStatTile tile(EmployeeStatusEnum status, String icon) =>
            HomeStatTile(
              icon: icon,
              label: status.localizedName(context),
              value: format(counts[status] ?? 0),
              iconColor: status.color,
              labelMaxLines: 1,
            );

        return <HomeStatTile>[
          tile(EmployeeStatusEnum.active, HomeWidgetSvg.statusActive),
          tile(EmployeeStatusEnum.deactivated, HomeWidgetSvg.statusDeactivated),
          tile(EmployeeStatusEnum.locked, HomeWidgetSvg.statusLocked),
          tile(EmployeeStatusEnum.willBeDeactivated,
              HomeWidgetSvg.statusScheduled),
        ];
      },
    );
  }
}

/// Figma 7488:10264 — "User Management Requests", two grid columns.
///
/// The review QUEUE, matching `RequestPageApproval`: every employee's change
/// requests, not the signed-in user's own.
class UserManagementRequestsWidget extends StatelessWidget {
  final HomeComponentModel model;

  const UserManagementRequestsWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return _RolesStatCard(
      title: l.userManagementRequests,
      // NARROWED 28/8/2026 from kHomeWidgetWidth (320). Three stats, so it
      // takes the same compact width as Role Management — the stat cards use
      // only two widths now, one per tile count.
      width: kHomeWidgetCompactWidth,
      tiles: (BuildContext context, String Function(int) format) {
        final Map<String, int> counts =
            context.read<RolesHomeStatsCubit>().requestCounts;
        return <HomeStatTile>[
          // No iconColor: these three assets are already green / orange / red.
          HomeStatTile(
            icon: HomeWidgetSvg.approved,
            label: l.approved,
            value: format(counts[RequestStatusKey.approved] ?? 0),
            labelMaxLines: 1,
          ),
          HomeStatTile(
            icon: HomeWidgetSvg.pending,
            label: l.pending,
            value: format(counts[RequestStatusKey.pending] ?? 0),
            labelMaxLines: 1,
          ),
          HomeStatTile(
            icon: HomeWidgetSvg.rejected,
            label: l.rejected,
            value: format(counts[RequestStatusKey.rejected] ?? 0),
            labelMaxLines: 1,
          ),
        ];
      },
    );
  }
}
