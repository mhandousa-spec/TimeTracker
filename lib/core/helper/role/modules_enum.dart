/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: modules_enum.dart
/// Purpose: Enum `Modules` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 2/9/2026 - `Modules.notification` now has enum-backed permission
///          sections (`NotificationPermissionsSections`), so it is registered
///          in `moduleFirstColumnPermissions` and in `modulesHasPermission`.
/// Updated: 7/10/2026 - `Modules.todo` registered: enum-backed sections
///          (`TodoPermissionsSections`), the permission gate, and the
///          `TodoModuleEntry` page.
/// Updated: 8/10/2026 - `Modules.timeTracker` registered (Time Tracker phase
///          1): enum-backed sections (`TimeTrackerPermissionsSections`), the
///          permission gate, and the `TimeTrackerModuleEntry` page.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/85-module_page_stubs.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_responsive_page.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/pages/grc_page.dart';

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/database_builder/database_builder_responsive_page.dart';
import 'package:knowticed_plus/features/home/main_controller/helper/home_layout_helper.dart';
// HrModuleLandingPage supplies HrModuleDataCubit and the module's nested
// Navigator (which wraps the dashboard in HrDashboardCubit). Do NOT route to
// HRDashboardPage directly — it has no provider ancestor and throws
// ProviderNotFoundException.
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/ui/pages/home_layout_helper.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/ui/pages/employees_responsive_page.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/services_mangment_module/responsive_services.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/grc/grc_permissions_sections_enum.dart';

// REMOVED_MODULE: import'package:knowticed_plus/features/external/services_app_module/core/configs/extensions/extensions.dart';
// REMOVED_MODULE: import'package:knowticed_plus/features/external/services_app_module/core/routes/app_routes.dart';
// REMOVED_MODULE: import'package:knowticed_plus/features/external/services_app_module/core/routes/get_pages.dart';
// REMOVED_MODULE: import'package:knowticed_plus/features/external/services_app_module/core/services/form_navigator_service.dart';
// REMOVED_MODULE: import'package:knowticed_plus/features/roles/database_builder/database_responsive_page.dart';


// REMOVED_MODULE: import'package:knowticed_plus/features/roles/inventory_module/inventory_responsive_page.dart';
// REMOVED_MODULE: import'package:knowticed_plus/features/roles/knowledge_hub_module/knowledge_hub_responsive_page.dart';
// REMOVED_MODULE: import'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s1_create_service/home_services/home_page_services_toggle.dart';

// REMOVED_MODULE: import'package:knowticed_plus/features/external/todo_module/todo_responsive_page.dart';
// REMOVED_MODULE: import'package:knowticed_plus/features/roles/todo_new_module/todo_responsive_page.dart';

// REMOVED_MODULE: import'package:knowticed_plus/features/external/tracking_module/tracking_responsive_page.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/home_responsive_page.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/pages/more_page.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_control.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/responsive_services.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_screen.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
// ADDED 2/9/2026 — the Messages block on "Adding New Role".
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/messages/messages_sections_enum.dart';
// ADDED 2/9/2026 — the Notification Control block on "Adding New Role".
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/notification/notification_sections_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';
// ADDED 7/10/2026 — the To Do Permissions block on "Adding New Role".
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/todo/todo_sections_enum.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/pages/todo_module_entry.dart';
// ADDED 8/10/2026 — the Time Tracker block on "Adding New Role" + its entry.
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/time_tracker/time_tracker_sections_enum.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_module_entry.dart';

import '../../../features/database/db1_create_database/presentation/ui/pages/database_builder_page.dart';
// KnowledgeHubPage supplies the MultiBlocProvider (CreateKnowledgeCubit, etc.)
// that the knowledge hub screens read from. Do NOT route to ViewKnowledgeHub
// directly — it has no provider ancestor and throws ProviderNotFoundException.
import '../../../features/knowledge_hub/main_controller/presentation/ui/pages/knowledge_hub_responsive_page.dart';



// ✅ DECLARE GLOBAL KEYS OUTSIDE THE ENUM (at file level)
// This ensures only ONE instance of each key exists
GlobalKey? servicesKey;
GlobalKey? trackerAppKey;
GlobalKey? grcNavKey;

enum Modules {
  home,
  tasks,
  employees,
  messages,
  inventory,
  roles,
  services,
  todo,
  requests,
  grc,
  events,
  notes,
  tracking,
  knowledgeHub,
  qiyas,
  database,
  formBuilder,
  settings,
  hr,           // ✅ ADDED
  crm,          // ✅ ADDED
  notification, // ✅ ADDED
  timeTracker, // ADDED 8/10/2026 — Time Tracker (licence key 'time_tracker')
  more;

  String get iconPath {
    switch (this) {
      case Modules.home:
        return 'assets/icons_assets/roles_assets/home.svg';
      case Modules.tasks:
        return 'assets/icons_assets/home_assets/todo_checklist_clipboard.svg';
      case Modules.employees:
        return 'assets/icons_assets/roles_assets/organization_chart_tree.svg';
      case Modules.messages:
        return 'assets/icons_assets/roles_assets/chat_messages_bubbles.svg';
      case Modules.inventory:
        return 'assets/icons_assets/roles_assets/inventory_warehouse.svg';
      case Modules.roles:
        return 'assets/icons_assets/roles_assets/roles_people_gear.svg';
      case Modules.services:
        return 'assets/icons_assets/services_assets/headset_support.svg';
      case Modules.todo:
        return 'assets/icons_assets/roles_assets/todo_list_document.svg';
      case Modules.grc:
        return 'assets/icons_assets/roles_assets/governance_gavel_warning.svg';
      case Modules.requests:
        return 'assets/icons_assets/main_icons_assets/doc_file_blue.svg';
      case Modules.events:
        return 'assets/icons_assets/home_assets/calendar_event_star_white.svg';
      case Modules.notes:
        return 'assets/icons_assets/home_assets/quotation_marks.svg';
      case Modules.tracking:
        return 'assets/icons_assets/roles_assets/time_tracking_dashed_clock.svg';
      // ADDED 8/10/2026 — reuses the existing dashed-clock tracking icon.
      case Modules.timeTracker:
        return 'assets/icons_assets/roles_assets/time_tracking_dashed_clock.svg';
      case Modules.knowledgeHub:
        return 'assets/icons_assets/roles_assets/knowledge_book_idea.svg';
      case Modules.qiyas:
        return 'assets/icons_assets/roles_assets/governance_gavel_warning.svg';
      case Modules.formBuilder:
        return 'assets/icons_assets/roles_assets/form_document.svg';
      case Modules.database:
        return 'assets/icons_assets/database_builder_assets/create_data_base.svg';
      case Modules.settings:
        return 'assets/icons_assets/roles_assets/settings_gear.svg';
      case Modules.hr:  // ✅ ADDED
        return 'assets/icons_assets/roles_assets/hr_desk.svg';
      case Modules.crm:  // ✅ ADDED — TODO: replace with CRM icon
        return 'assets/icons_assets/roles_assets/team_gear_people.svg';
      case Modules.notification:  // ✅ ADDED
        return 'assets/icons_assets/main_icons_assets/notification_bell.svg';
      case Modules.more:
        return 'assets/icons_assets/roles_assets/menu_lines_bold.svg';
      default:
        return 'home';
    }
  }

  String get iconPathRole {
    switch (this) {
      case Modules.home:
        return 'assets/icons_assets/roles_assets/home.svg';
      case Modules.tasks:
        return 'assets/icons_assets/home_assets/todo_checklist_clipboard.svg';
      case Modules.employees:
        return 'assets/icons_assets/roles_assets/organization_chart_tree.svg';
      case Modules.messages:
        return 'assets/icons_assets/roles_assets/chat_messages_bubbles.svg';
      case Modules.inventory:
        return 'assets/icons_assets/roles_assets/inventory_warehouse.svg';
      case Modules.roles:
        return 'assets/icons_assets/roles_assets/roles_people_gear.svg';
      case Modules.services:
        return 'assets/icons_assets/services_assets/headset_support.svg';
      case Modules.todo:
        return 'assets/icons_assets/roles_assets/todo_list_document.svg';
      case Modules.requests:
        return 'assets/icons_assets/main_icons_assets/doc_file_blue.svg';
      case Modules.events:
        return 'assets/icons_assets/home_assets/calendar_event_star_white.svg';
      case Modules.notes:
        return 'assets/icons_assets/home_assets/quotation_marks.svg';
      case Modules.tracking:
        return 'assets/icons_assets/roles_assets/time_tracking_dashed_clock.svg';
      // ADDED 8/10/2026 — reuses the existing dashed-clock tracking icon.
      case Modules.timeTracker:
        return 'assets/icons_assets/roles_assets/time_tracking_dashed_clock.svg';
      case Modules.knowledgeHub:
        return 'assets/icons_assets/roles_assets/knowledge_book_idea.svg';
      case Modules.qiyas:
        return 'assets/icons_assets/roles_assets/analytics_chart_cycle.svg';
      case Modules.grc:
        return 'assets/icons_assets/roles_assets/governance_gavel_warning.svg';
      case Modules.formBuilder:
        return 'assets/icons_assets/roles_assets/form_document.svg';
      case Modules.database:
        return 'assets/icons_assets/database_builder_assets/create_data_base.svg';
      case Modules.settings:
        return 'assets/icons_assets/roles_assets/settings_gear.svg';
      case Modules.hr:  // ✅ ADDED
        return 'assets/icons_assets/roles_assets/hr_desk.svg';
      case Modules.crm:  // ✅ ADDED — TODO: replace with CRM icon
        return 'assets/icons_assets/roles_assets/team_gear_people.svg';
      case Modules.notification:  // ✅ ADDED
        return 'assets/icons_assets/main_icons_assets/notification_bell.svg';
      case Modules.more:
        return 'assets/icons_assets/roles_assets/menu_lines_bold.svg';
      default:
        return 'home';
    }
  }

  String get getModuleName {
    switch (this) {
      case Modules.home:
        return Get.locale.toString().contains('ar') ? 'الرئيسية' : 'Home';
      case Modules.employees:
        return Get.locale.toString().contains('ar') ? 'الموظفين' : 'Org Chart';
      case Modules.services:
        return Get.locale.toString().contains('ar') ? 'الخدمات' : 'Services';
      case Modules.tasks:
        return Get.locale.toString().contains('ar') ? 'المهام' : 'Tasks';
      case Modules.todo:
        return Get.locale.toString().contains('ar') ? 'قائمة المهام' : 'Todo';
      case Modules.events:
        return Get.locale.toString().contains('ar') ? 'الأحداث' : 'Events';
      case Modules.notes:
        return Get.locale.toString().contains('ar') ? 'الملاحظات' : 'Notes';
      case Modules.grc:
        return Get.locale.toString().contains('ar') ? ' الحوكمة و المخاطر و الآلتزام' : 'GRC';
      case Modules.requests:
        return Get.locale.toString().contains('ar') ? 'الطلبات' : 'Requests';
      case Modules.knowledgeHub:
        return Get.locale.toString().contains('ar') ? 'مركز المعرفة' : 'Knowledge Hub';
      case Modules.qiyas:
        return Get.locale.toString().contains('ar') ? 'قياس' : 'Qiyas';
      case Modules.tracking:
        return Get.locale.toString().contains('ar') ? 'التتبع' : 'Tracking';
      // ADDED 8/10/2026 — Time Tracker.
      case Modules.timeTracker:
        return Get.locale.toString().contains('ar') ? 'تتبع الوقت' : 'Time Tracker';
      case Modules.inventory:
        return Get.locale.toString().contains('ar') ? 'المخزون' : 'Inventory';
      case Modules.messages:
        return Get.locale.toString().contains('ar') ? 'الرسائل' : 'Messages';
      case Modules.database:
        return Get.locale.toString().contains('ar') ? 'قاعدة البيانات' : 'Database';
      case Modules.formBuilder:
        return Get.locale.toString().contains('ar') ? 'منشئ النماذج' : 'Form Builder';
      case Modules.roles:
        return Get.locale.toString().contains('ar') ? 'الأدوار' : 'Roles';
      case Modules.settings:
        return Get.locale.toString().contains('ar') ? 'الإعدادات' : 'Settings';
      case Modules.hr:  // ✅ ADDED
        return Get.locale.toString().contains('ar') ? 'الموارد البشرية' : 'HR';
      case Modules.crm:  // ✅ ADDED
        return Get.locale.toString().contains('ar') ? 'إدارة علاقات العملاء' : 'CRM';
      case Modules.notification:  // ✅ ADDED
        return Get.locale.toString().contains('ar') ? 'الإشعارات' : 'Notification';
      case Modules.more:
        return Get.locale.toString().contains('ar') ? 'المزيد' : 'More';
      default:
        return name;
    }
  }

  Widget get widget {
    switch (this) {
      case Modules.home:
        return HomeResponsivePage();
      case Modules.tasks:
        return TasksResponsivePage();
      case Modules.employees:
        return EmployeesResponsivePage();
      case Modules.tracking:
        return TrackerPageResponsivePageRefactor();
      case Modules.inventory:
        return Container();
      case Modules.grc:
        return GrcResponsivePageLayout();
      case Modules.roles:
        // RoleScreen is used for every form factor, so no responsive split is
        // needed here — it only requires these three cubits to be in scope.
        return BlocProvider<UserAccessCubit>.value(
          value: accountStatusCubit,
          child: BlocProvider<UserManagementAccessCubit>.value(
            value: userManagementCubit,
            child: BlocProvider<RoleCubit>.value(
              value: roleCubit,
              // RoleScreenHost wraps RoleScreen in a nested Navigator so that
              // pushes inside the module (AddingNewRole, RoleDetailsPage, ...)
              // render inside the app shell instead of covering it.
              child: RoleScreenHost(),
            ),
          ),
        );

      case Modules.services:
        if (servicesKey == null) {
          servicesKey = GlobalKey();
        }
        return ServicesResponsivePage();

      case Modules.todo:
        // ADDED 7/10/2026 — TodoModuleEntry provides TodoListCubit +
        // TodoActionsCubit and the module's nested Navigator.
        return const TodoModuleEntry();
      case Modules.timeTracker:
        // ADDED 8/10/2026 — TimeTrackerModuleEntry provides the module's
        // cubits, the View gate and its nested Navigator (no GlobalKey).
        return const TimeTrackerModuleEntry();
      case Modules.hr:
        return  Container();
      case Modules.crm:
        return Container();
      case Modules.database:
        return DatabaseBuilderPage();
      case Modules.messages:
        return HomePageHelperLayout();

      case Modules.formBuilder:
        return FormResponsivePageLayout();

      case Modules.tracking:
        if (trackerAppKey == null) {
          trackerAppKey = GlobalKey();
        }
        return TrackerPageResponsivePageRefactor();

      case Modules.knowledgeHub:
        return KnowledgeHubPage();
      case Modules.settings:
        return SettingsScreen();
      case Modules.more:
        return MorePage();

      case Modules.qiyas:
        if (grcNavKey == null) {
          grcNavKey = GlobalKey();
        } else {
        }
        return GrcResponsivePage();

    // ✅ ADDED: HR Module
      case Modules.hr:
        return Container();  // TODO: Create this page

    // ✅ ADDED: CRM Module
      case Modules.crm:
        return Container();  // TODO: Create this page

    // ✅ ADDED: Notification Module
      case Modules.notification:
        return NotificationControlPage();  // TODO: Create this page

      default:
        return Scaffold();
    }
  }

  List<Enum> get moduleFirstColumnPermissions {
    switch (this) {
      case Modules.services:
        return ServicePermissionsSections.firstColumnValues;
      case Modules.formBuilder:
        return FormPermissionsSections.firstColumnValues;
      case Modules.settings:
        return SettingsPermissionsSections.firstColumnValues;
      case Modules.roles:
        return RolePermissionsSections.firstColumnValues;
      // ADDED 2/9/2026. Without these two cases the Messages block renders no
      // switches at all — the enums exist but nothing asks them for columns.
      case Modules.messages:
        return MessagesPermissionsSections.firstColumnValues;
      // ADDED 2/9/2026 — the Notification Control block. One column only: the
      // design leaves the right-hand column of that row blank, so
      // `moduleLastColumnPermissions` below deliberately has no
      // `Modules.notification` case and falls through to the empty default.
      case Modules.notification:
        return NotificationPermissionsSections.firstColumnValues;
      // ADDED 13/9/2026 — the GRC block. Its four section enums existed but
      // nothing asked them for columns, so the module fell through to the
      // empty default and ModuleSwitchesBuilder drew no switches at all.
      // Left column per the design: Module Permissions above Policy.
      case Modules.grc:
        return GrcPermissionsSections.firstColumnValues;
      // ADDED 21/9/2026 — Knowledge Hub. Its section enums existed but no
      // column asked for them, so the module had no switches (bug report p.2).
      case Modules.knowledgeHub:
        return KnowledgeHubPermissionsSections.firstColumnValues;
      // ADDED 7/10/2026 — To-Do: one section (master toggle + 5 switches).
      case Modules.todo:
        return TodoPermissionsSections.firstColumnValues;
      // ADDED 8/10/2026 — Time Tracker: left = everyday flows (5 sections).
      case Modules.timeTracker:
        return TimeTrackerPermissionsSections.firstColumnValues;
      default:
        return [];
    }
  }

  List<Enum> get moduleLastColumnPermissions {
    switch (this) {
      case Modules.services:
        return ServicePermissionsSections.lastColumnValues;
      case Modules.formBuilder:
        return FormPermissionsSections.lastColumnValues;
      case Modules.settings:
        return SettingsPermissionsSections.lastColumnValues;
      case Modules.roles:
        return RolePermissionsSections.lastColumnValues;
      case Modules.messages:
        return MessagesPermissionsSections.lastColumnValues;
      // Right column per the design: Dashboards above Control Permissions.
      case Modules.grc:
        return GrcPermissionsSections.lastColumnValues;
      case Modules.knowledgeHub:
        return KnowledgeHubPermissionsSections.lastColumnValues;
      // Empty by design — the To Do block has a single column.
      case Modules.todo:
        return TodoPermissionsSections.lastColumnValues;
      // ADDED 8/10/2026 — Time Tracker: right = set-up screens (5 sections).
      case Modules.timeTracker:
        return TimeTrackerPermissionsSections.lastColumnValues;
      default:
        return [];
    }
  }

  /// Modules whose permission switches are rendered on the "Role Permissions"
  /// step (role_permission_switches.dart). A module missing from this list is
  /// filtered out there and shows NO switches at all, even when the admin
  /// dashboard has written permissions for it into Demo_Permissions.
  ///
  /// Modules without enum-backed permission sections (crm, hr — notification
  /// gained sections on 2/9/2026 and is no longer one of them)
  /// fall through to ModuleSwitchesBuilder._buildFirebaseOnlySwitches, which
  /// builds the switch list straight from the Demo_Permissions document — so
  /// adding them here is safe: if the doc has no entry for the module, the
  /// builder still collapses to SizedBox.shrink().
  static List<Modules> get modulesHasPermission {
    return [
      Modules.services,
      Modules.formBuilder,
      Modules.roles,
      Modules.settings,
      Modules.crm,  // ✅ ADDED
      Modules.hr,   // ✅ ADDED
      // ADDED 2/9/2026. This list is the gate, not the enums: a module absent
      // from here is filtered out of role_permission_switches.dart and shows
      // no switches even with its columns defined above.
      Modules.messages,
      // ADDED 2/9/2026. `Modules.notification` was already reachable as a
      // module but had no enum-backed sections, so it fell through to
      // ModuleSwitchesBuilder._buildFirebaseOnlySwitches and drew whatever
      // Demo_Permissions happened to hold — or nothing. It now has real
      // sections, so it belongs in the gate.
      Modules.notification,
      // ADDED 13/9/2026. THIS is the switch that was actually missing: the
      // columns above decide WHAT renders, this list decides WHETHER the
      // module is offered at all. role_permission_switches.dart filters on it,
      // so GRC was dropped before its sections were ever consulted — which is
      // why no GRC switches appeared even though the admin dashboard writes 32
      // GRC permission keys into Demo_Permissions.
      Modules.grc,
      // ADDED 21/9/2026 — Knowledge Hub was absent from this gate, so it was
      // filtered out of role_permission_switches.dart before any switch drew.
      Modules.knowledgeHub,
      // ADDED 7/10/2026 — To-Do. Without it every To-Do switch was filtered
      // out of role_permission_switches.dart.
      Modules.todo,
      // ADDED 8/10/2026 — Time Tracker (10 sections / 48 switches).
      Modules.timeTracker,
    ];
  }
}