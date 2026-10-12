/// Module: database / db1_create_database / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: database_module_entry.dart
/// Purpose: Declares `DatabaseModuleEntry` and `databaseNavKey`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
/// Updated: 15/8/2026 - Hosts the module's own Navigator so the nav rail and
///          the header stay visible while the create wizard is open.
///
/// WHERE THE DRAWER AND THE HEADER COME FROM
/// -----------------------------------------
/// `features/home/h3_app_drawer/.../custom_drawer.dart` builds:
///
///     Row(
///       [ the nav rail  ]          <- the module icons
///       Expanded(
///         Column(
///           CustomAppBar(),        <- the header: bell + avatar + name/role
///           Expanded(
///             IndexedStack(        <- the active module renders HERE
///               index: controller.selectedIndex,
///               children: screens,
///             )
///
/// So a module screen is a LEAF inside that IndexedStack, and the rail and
/// header are its siblings, not its children.
///
/// WHY THIS FILE HOSTS A NAVIGATOR
/// -------------------------------
/// A module that pushes routes must push them into a Navigator that lives
/// INSIDE its IndexedStack pane. `Navigator.of(context)` walks up the tree,
/// so without one here the nearest Navigator is `GetMaterialApp`'s root — and
/// a route pushed there covers the whole window, rail and header included.
/// That is exactly what happened when "Create Database" opened the wizard:
/// the page was correct, it was just drawn on top of the shell instead of
/// inside it.
///
/// Every other module that navigates internally solves it the same way:
///
///   home_responsive_page.dart   Navigator(key: homeNavKey,     …)
///   settings_screen.dart        Navigator(key: settingsKey,    …)
///   custom_tab_view.dart        Navigator(key: …navigatorKey,  …)
///
/// [databaseNavKey] is this module's equivalent, exposed for the same reason
/// theirs are: so code outside the subtree can reset the module to its root.
///
/// TWO LEVELS OF NAVIGATOR, ON PURPOSE
/// -----------------------------------
///   this one          list  <->  wizard        (survives for the module's life)
///   CreateDatabaseFlow's    details -> access -> review   (one draft's life)
///
/// The inner one is what lets the wizard's cubit be created and disposed with
/// the wizard rather than living as long as the module is open — a half-filled
/// draft should not outlive the flow that made it.
///
/// HOW TO MOUNT IT
/// ---------------
///   1. Add a `Modules.database` case to the drawer's enum, with icon + label.
///   2. In `AppDrawerCubit`, map that case to `const DatabaseModuleEntry()`
///      so it lands in `drawerItems` / the IndexedStack.
///   3. Grant the module in role management so it appears in
///      `allowedDrawerModules` for the signed-in user.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/90-app_scroll_behavior.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/database_builder_page.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:get/get.dart';

/// Root of this module's navigation stack. Mirrors `homeNavKey` /
/// `settingsKey`; use it to pop the module back to the list from outside.
final GlobalKey<NavigatorState> databaseNavKey = GlobalKey<NavigatorState>();

class DatabaseModuleEntry extends StatelessWidget {
  const DatabaseModuleEntry({super.key, this.createdBy});

  /// Employee id stamped on records created from here.
  ///
  /// Optional, and [_signedInEmployeeId] is the fallback. This USED to say "the
  /// drawer knows the signed-in employee, so it is passed down rather than
  /// looked up" — and the drawer never did. `modules_enum.dart` mounts the
  /// module as `const DatabaseModuleEntry()`, so the whole tree ran on null:
  /// every database, table and grant was written with `created_by: null`, and
  /// the Comments screen — which refuses to post without an author — told a
  /// signed-in user to sign in (17/8/2026).
  ///
  /// The parameter stays, because a caller that already has the id should not
  /// pay for a lookup, and a test must be able to pass a fake one.
  final String? createdBy;

  /// The signed-in employee's id, or null when nobody is.
  ///
  /// Read at BUILD time, not in a constructor: `EmployeeController` is
  /// registered by `LoginController` and this widget's enclosing switch is
  /// evaluated by the drawer, so a value captured any earlier is null for the
  /// whole session. Guarded with `isRegistered` because `Get.find` throws when
  /// it is not there, which is the state at app startup and on the login
  /// screen — the same guard `MainCoreEmployeeController` uses.
  String? get _signedInEmployeeId {
    if (!Get.isRegistered<EmployeeController>()) {
      debugPrint(
        '[DatabaseModule] EmployeeController is NOT registered — every record '
        'written from this module will have created_by: null, and the Comments '
        'screen will say "Sign in to leave a comment".',
      );
      return null;
    }

    final String? id = Get.find<EmployeeController>().employee?.id;
    debugPrint(
      '[DatabaseModule] signed-in employee id = "${id ?? '<null>'}"'
      '${id == null ? '   <-- EmployeeController.employee is null; login has not finished loading it' : ''}',
    );
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final Widget landing =
        DatabaseBuilderPage(createdBy: createdBy ?? _signedInEmployeeId);

    // ONE SCROLL STYLE FOR THE WHOLE MODULE (16/8/2026).
    //
    // `ScrollConfiguration` is inherited, so wrapping the module root settles
    // it for every list, grid and scroll view under it — db1, db2, db3, and
    // whatever is added next — instead of each page repeating the same
    // `copyWith(scrollbars: false)` and the next one forgetting to.
    //
    // It goes OUTSIDE the Navigator on purpose: routes pushed into
    // [databaseNavKey] build below it, so the wizard inherits this too.

    // On a phone the drawer is an overlay rather than a persistent rail, so
    // there is no pane to stay inside — pushing to the root navigator is the
    // correct behaviour there. Same guard as HomeResponsivePage.
    //
    // Which is also why this is not the only place the rule is applied: a
    // route pushed to the ROOT navigator is not a descendant of this widget.
    // `CreateDatabaseMetrics.pageScroll` carries it too, per page.
    if (ContextExtension(context).isPhone) return NoScrollbar(child: landing);

    return NoScrollbar(
      child: Navigator(
        key: databaseNavKey,
        onGenerateRoute: (RouteSettings settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => landing,
        ),
      ),
    );
  }
}
