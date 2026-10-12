/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_components.dart
/// Purpose: Enum `HomeComponents` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - Time Tracker phase 6: the seven `Time_Tracker_…`
///          home cards (Figma "Widgets" column).

///********************** FILE INFO ****************************///
/// Purpose: Enum for home components determine which component to show and its assigned values
/// Created by: Mohamed Elrashidy
/// Create at: 21/9/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';

import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_chart_cards_extra.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_extra_widgets.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_roles_widgets.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_service_widgets.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/forms/forms_actions.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/inventory_actions.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/inventory_new_request.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/inventory_overview.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/my_request_inventory.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/stocks.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/knowledgehub/approval_knowledge.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/knowledgehub/knowledge_hub_actions.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/knowledgehub/knowledge_hub_overview.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/messages/schedule_message.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/qiyas/qiyas_assign_overview.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/settings/settings_home_widgets.dart';

import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/my_todo.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/to_check_box.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/todo_status.dart';
// ADDED 9/10/2026 — Time Tracker phase 6 home cards.
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/time_tracker/time_tracker_quick_cards.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/time_tracker/time_tracker_stat_cards.dart';


enum HomeComponents {
  /// Fallback for component names found in a stored layout that this
  /// build no longer knows (e.g. the removed messaging cards).
  /// widget() returns null for it, so such cards render as empty and are
  /// never offered in the add-widget picker.
  unknown,

  // ══════════════════════════════════════════════════════════════════════════
  // DECLARATION ORDER IS RENDER ORDER — do not shuffle casually.
  //
  // `AppHomeCubit.selectComponentToEdit` walks `HomeComponents.values` in this
  // order and keeps every value whose `widget()` is non-null;
  // `adding_widget_page.dart` then lays that list out with a `Wrap`. So this
  // list, plus each card's width, is what produces the rows on screen. There is
  // no other ordering step anywhere.
  //
  // REORDERED 25/8/2026 to Figma's reading order — file BuJXLizpGcK5eHVBqQomXc,
  // Settings > Home Layout > Adding Widget, node 7488:7483, top to bottom:
  //
  //   Messages → Forms → Services → Inventory → Qiyas → Knowledge Hub →
  //   To-Do → Settings → (Database / Role / User Access: designed, no
  //   components built yet)
  //
  // Previously the list opened with the two Form cards and interleaved the
  // service and inventory groups, so the picker's rows did not correspond to
  // the design's rows for any module.
  //
  // Changing a value's POSITION is safe — nothing persists it. Changing a
  // value's NAME or its `databaseName` is not: `HomeComponentModel.fromMap`
  // resolves a stored layout by `databaseName`, and an unrecognised one falls
  // back to `unknown`, silently blanking that card on someone's saved home
  // page.
  // ══════════════════════════════════════════════════════════════════════════

  // ── Messages ──────────────────────────────────────────────────────────────
  employeeMessages,
  groupMessages,
  scheduleMessages,

  // ── Form Builder ──────────────────────────────────────────────────────────
  formsSubmission,
  formActions,

  // ── Services ──────────────────────────────────────────────────────────────
  requestedService,
  serviceActions,
  myServices,
  serviceStatus,
  nearBreachedSLA,
  serviceOverview,
  myRequestServices,

  // ── Inventory ─────────────────────────────────────────────────────────────
  inventoryOverview,
  myRequestInventory,
  lowStocks,
  inventoryNewRequest,
  stocks,
  inventoryActions,

  // ── Qiyas ─────────────────────────────────────────────────────────────────
  qiyasAssignOverview,

  // ── Knowledge Hub ─────────────────────────────────────────────────────────
  knowledgeHubOverview,
  knowledgeHubActions,
  approvalDashboard,

  // ── To-Do ─────────────────────────────────────────────────────────────────
  myTodoList,
  MyTodoBox,
  myTodoStatus,

  // ── Time Tracker ──────────────────────────────────────────────────────────
  // ADDED 9/10/2026 (Time Tracker phase 6). Figma QVFDXSnFPExQVOIycX9ECb
  // "Widgets" column, in its reading order: Totals 2583:27002 · Presence
  // 2583:26557 · Tracker Status 2583:26899 · Tracker Approver 2583:26697 ·
  // My Request 2583:26771 · Quick Requests 2583:26873 · Quick Approvals
  // 2583:26886. Database names are `Time_Tracker_…` — NEVER rename them
  // (a stored layout resolves cards by them).
  timeTrackerTotals,
  timeTrackerPresence,
  timeTrackerStatus,
  timeTrackerApprover,
  timeTrackerMyRequest,
  timeTrackerQuickRequests,
  timeTrackerQuickApprovals,

  // ── Settings ──────────────────────────────────────────────────────────────
  // ADDED 25/8/2026. Figma puts these two side by side at y=2229, after the
  // Database row and before Role Management. Unlike every other card in the
  // picker, both read live records rather than previewing placeholder figures —
  // see `module_widget/settings/settings_home_widgets.dart`.
  commentsAndFeedbacks,
  mySettingsRequests,

  // ── Roles ─────────────────────────────────────────────────────────────────
  // ADDED 25/8/2026, in Figma's reading order — Role Management and User
  // Management sit side by side at y=2372, User Access and User Management
  // Requests at y=2499 (nodes 7488:10062, 7488:10143, 7490:11044, 7488:10264).
  // This is the "Role / User Access: designed, no components built yet" note
  // above being closed; only the Database row is still outstanding.
  //
  // All four read live counts through `RolesHomeStatsCubit` rather than
  // previewing Figma's placeholder 10s, like the Settings pair above.
  roleManagementOverview,
  userManagementOverview,
  userAccessOverview,
  userManagementRequests,

  // ── Charts ────────────────────────────────────────────────────────────────
  // Charts are components like any other so the Adding Widget page can offer
  // them through the same AddComponentWrapper → editComponent() → pop flow the
  // widget tab uses. They render via HomeChartCards.
  // Replaced 23/8/2026: the picker now offers the eleven charts the Figma
  // Chart & Graph tab actually shows (node 5356:111536), in that frame's
  // reading order. The Adding Widget page lays them out with a Wrap, so this
  // order plus each card's width is what produces Figma's rows — do not
  // reorder without re-checking the geometry note in
  // home_widgets/home_chart_cards_extra.dart.
  horizontalBarChart,
  baseLineChart,
  tableChart,
  barChart,
  stackedBarChart,
  groupedBarChart,
  pieChart,
  horizontalStackedBarChart,
  radialBarChart,
  barTrendChart,
  donutChart,
  none;

  String get databaseName {
    switch (this) {
      case HomeComponents.commentsAndFeedbacks:
        return 'Comments_And_Feedbacks';
      case HomeComponents.mySettingsRequests:
        return 'My_Settings_Requests';
      case HomeComponents.roleManagementOverview:
        return 'Role_Management_Overview';
      case HomeComponents.userManagementOverview:
        return 'User_Management_Overview';
      case HomeComponents.userAccessOverview:
        return 'User_Access_Overview';
      case HomeComponents.userManagementRequests:
        return 'User_Management_Requests';
      case HomeComponents.unknown:
        return 'Unknown';
      case HomeComponents.formActions:
        return 'Form_Actions';
      case HomeComponents.formsSubmission:
        return 'Forms_Submission';
      case HomeComponents.scheduleMessages:
        return 'Schedule_Messages';
      case HomeComponents.employeeMessages:
        return 'Employee_Messages';
      case HomeComponents.groupMessages:
        return 'Group_Messages';
      case HomeComponents.requestedService:
        return 'Requested_Service';
      case HomeComponents.serviceActions:
        return 'Service_Actions';
      case HomeComponents.serviceStatus:
        return 'Service_Status';
      case HomeComponents.myServices:
        return 'My_Services';
      case HomeComponents.nearBreachedSLA:
        return 'Near_Breached_SLA';
      case HomeComponents.inventoryActions:
        return 'Inventory_Actions';
      case HomeComponents.inventoryNewRequest:
        return 'Inventory_New_Request';
      case HomeComponents.inventoryOverview:
        return 'Inventory_Overview';
      case HomeComponents.stocks:
        return 'Stocks';
      case HomeComponents.knowledgeHubActions:
        return 'Knowledge_Hub_Actions';
      case HomeComponents.knowledgeHubOverview:
        return 'Knowledge_Hub_Overview';
      case HomeComponents.approvalDashboard:  // ✅ NEW CASE
        return 'Approval_Dashboard';
      case HomeComponents.serviceOverview:
        return 'Service_Overview';
      case HomeComponents.myRequestServices:
        return 'My_Request_Services';
      case HomeComponents.myRequestInventory:
        return 'My_Request_Inventory';
      case HomeComponents.lowStocks:
        return 'Low_Stocks';
      case HomeComponents.qiyasAssignOverview:
        return 'Qiyas_Assign_Overview';
      case HomeComponents.myTodoList:
        return 'My_Todo_List';
      case HomeComponents.myTodoStatus:
        return 'My_Todo_Status';
      case HomeComponents.MyTodoBox:
        return 'My_Todo_Check_Box';
      // Time Tracker (9/10/2026) — never rename.
      case HomeComponents.timeTrackerTotals:
        return 'Time_Tracker_Totals';
      case HomeComponents.timeTrackerPresence:
        return 'Time_Tracker_Presence';
      case HomeComponents.timeTrackerStatus:
        return 'Time_Tracker_Status';
      case HomeComponents.timeTrackerApprover:
        return 'Time_Tracker_Approver';
      case HomeComponents.timeTrackerMyRequest:
        return 'Time_Tracker_My_Request';
      case HomeComponents.timeTrackerQuickRequests:
        return 'Time_Tracker_Quick_Requests';
      case HomeComponents.timeTrackerQuickApprovals:
        return 'Time_Tracker_Quick_Approvals';
      case HomeComponents.horizontalBarChart:
        return 'Horizontal_Bar_Chart';
      case HomeComponents.baseLineChart:
        return 'Base_Line_Chart';
      case HomeComponents.tableChart:
        return 'Table_Chart';
      case HomeComponents.barChart:
        return 'Bar_Chart';
      case HomeComponents.stackedBarChart:
        return 'Stacked_Bar_Chart';
      case HomeComponents.groupedBarChart:
        return 'Grouped_Bar_Chart';
      case HomeComponents.pieChart:
        return 'Pie_Chart';
      case HomeComponents.horizontalStackedBarChart:
        return 'Horizontal_Stacked_Bar_Chart';
      case HomeComponents.radialBarChart:
        return 'Radial_Bar_Chart';
      case HomeComponents.barTrendChart:
        return 'Bar_Trend_Chart';
      case HomeComponents.donutChart:
        return 'Donut_Chart';
      case HomeComponents.none:
        return 'None';
    }
  }

  /// True for the chart components, which the Adding Widget page groups under
  /// its "Chart & Graph" tab instead of the widget grid.
  bool get isChart {
    switch (this) {
      case HomeComponents.horizontalBarChart:
      case HomeComponents.baseLineChart:
      case HomeComponents.tableChart:
      case HomeComponents.barChart:
      case HomeComponents.stackedBarChart:
      case HomeComponents.groupedBarChart:
      case HomeComponents.pieChart:
      case HomeComponents.horizontalStackedBarChart:
      case HomeComponents.radialBarChart:
      case HomeComponents.barTrendChart:
      case HomeComponents.donutChart:
        return true;
      default:
        return false;
    }
  }

  bool get isEditable {
    switch (this) {
      case HomeComponents.nearBreachedSLA:
        return true;
      default:
        return false;
    }
  }

  /// The module this widget belongs to.
  ///
  /// Drives the Adding Widget page filter: only modules the employee's role
  /// actually has (AppDrawerCubit.allowedDrawerModules) are offered, and
  /// picking one narrows the grid to that module's widgets. Returns null for
  /// components with no module home (unknown / none), which are never offered
  /// anyway because widget() returns null for them.
  Modules? get module {
    switch (this) {
      case HomeComponents.formActions:
      case HomeComponents.formsSubmission:
        return Modules.formBuilder;

      case HomeComponents.scheduleMessages:
      case HomeComponents.employeeMessages:
      case HomeComponents.groupMessages:
        return Modules.messages;

      case HomeComponents.qiyasAssignOverview:
        return Modules.qiyas;

      case HomeComponents.horizontalBarChart:
      case HomeComponents.baseLineChart:
      case HomeComponents.tableChart:
      case HomeComponents.barChart:
      case HomeComponents.stackedBarChart:
      case HomeComponents.groupedBarChart:
      case HomeComponents.pieChart:
      case HomeComponents.horizontalStackedBarChart:
      case HomeComponents.radialBarChart:
      case HomeComponents.barTrendChart:
      case HomeComponents.donutChart:
        return Modules.services;

      case HomeComponents.inventoryActions:
      case HomeComponents.inventoryNewRequest:
      case HomeComponents.inventoryOverview:
      case HomeComponents.stocks:
      case HomeComponents.myRequestInventory:
      case HomeComponents.lowStocks:
        return Modules.inventory;

      case HomeComponents.knowledgeHubActions:
      case HomeComponents.knowledgeHubOverview:
      case HomeComponents.approvalDashboard:
        return Modules.knowledgeHub;

      case HomeComponents.myTodoList:
      case HomeComponents.myTodoStatus:
      case HomeComponents.MyTodoBox:
        return Modules.todo;

      case HomeComponents.timeTrackerTotals:
      case HomeComponents.timeTrackerPresence:
      case HomeComponents.timeTrackerStatus:
      case HomeComponents.timeTrackerApprover:
      case HomeComponents.timeTrackerMyRequest:
      case HomeComponents.timeTrackerQuickRequests:
      case HomeComponents.timeTrackerQuickApprovals:
        return Modules.timeTracker;

      case HomeComponents.requestedService:
      case HomeComponents.serviceActions:
      case HomeComponents.serviceStatus:
      case HomeComponents.serviceOverview:
      case HomeComponents.myServices:
      case HomeComponents.myRequestServices:
      case HomeComponents.nearBreachedSLA:
        return Modules.services;

      case HomeComponents.commentsAndFeedbacks:
      case HomeComponents.mySettingsRequests:
        return Modules.settings;

      // All three source modules (r1 role management, r2 user management,
      // r3 user access) live under the one `Modules.roles` grant — they are
      // SECTIONS of it (`RolePermissionsSections`), not modules of their own —
      // so the picker offers all four behind a single "Roles" chip.
      case HomeComponents.roleManagementOverview:
      case HomeComponents.userManagementOverview:
      case HomeComponents.userAccessOverview:
      case HomeComponents.userManagementRequests:
        return Modules.roles;

      case HomeComponents.unknown:
      case HomeComponents.none:
        return null;
    }
  }

  Widget? widget(HomeComponentModel model) {
    switch (this) {
      case HomeComponents.scheduleMessages:
        return ScheduleMessage(model: model);
      case HomeComponents.formActions:
        return FormActions(model: model);
      case HomeComponents.formsSubmission:
        return FormsSubmission(model: model);
      case HomeComponents.employeeMessages:
        return EmployeeMessagesWidget(model: model);
      case HomeComponents.groupMessages:
        return GroupMessagesWidget(model: model);
      case HomeComponents.lowStocks:
        return LowStocks(model: model);
      case HomeComponents.serviceActions:
        return ServicesActions(model: model);
      case HomeComponents.requestedService:
        return RequestService(model: model);
      case HomeComponents.inventoryActions:
        return InventoryActions(model: model);
      case HomeComponents.inventoryNewRequest:
        return InventoryNewRequests(model: model);
      case HomeComponents.knowledgeHubActions:
        return KnowledgeHubActions(model: model);
      case HomeComponents.serviceStatus:
        return ServicesStatus(model: model);
      case HomeComponents.myServices:
        return MyServices(model: model);
      case HomeComponents.nearBreachedSLA:
        return NearBreachedSLA(model: model);
      case HomeComponents.inventoryOverview:
        return InventoryOverview(model: model);
      case HomeComponents.knowledgeHubOverview:
        return KnowledgeHubOverview(model: model);
      case HomeComponents.approvalDashboard:  // ✅ NEW CASE
        return ApprovalDashBoardWidget(model: model);
      case HomeComponents.serviceOverview:
        return ServiceOverview(model: model);
      case HomeComponents.myRequestServices:
        return MyRequestServices(model: model);
      case HomeComponents.myRequestInventory:
        return MyRequestInventory(model: model);
      case HomeComponents.myTodoList:
        return MyTodo(model: model);
      case HomeComponents.myTodoStatus:
        return MyTodoStatus(model: model);
      case HomeComponents.MyTodoBox:
        return MyTodoCheckBox(model: model);
      case HomeComponents.timeTrackerTotals:
        return TimeTrackerTotalsCard(model: model);
      case HomeComponents.timeTrackerPresence:
        return TimeTrackerPresenceCard(model: model);
      case HomeComponents.timeTrackerStatus:
        return TimeTrackerStatusCard(model: model);
      case HomeComponents.timeTrackerApprover:
        return TimeTrackerApproverCard(model: model);
      case HomeComponents.timeTrackerMyRequest:
        return TimeTrackerMyRequestCard(model: model);
      case HomeComponents.timeTrackerQuickRequests:
        return TimeTrackerQuickRequestsCard(model: model);
      case HomeComponents.timeTrackerQuickApprovals:
        return TimeTrackerQuickApprovalsCard(model: model);
      case HomeComponents.stocks:
        return Stocks(model: model);
      case HomeComponents.qiyasAssignOverview:
        return QiyasAssignOverview(model: model);
      case HomeComponents.commentsAndFeedbacks:
        return CommentsAndFeedbacksWidget(model: model);
      case HomeComponents.mySettingsRequests:
        return MySettingsRequestsWidget(model: model);
      case HomeComponents.roleManagementOverview:
        return RoleManagementWidget(model: model);
      case HomeComponents.userManagementOverview:
        return UserManagementWidget(model: model);
      case HomeComponents.userAccessOverview:
        return UserAccessWidget(model: model);
      case HomeComponents.userManagementRequests:
        return UserManagementRequestsWidget(model: model);
      case HomeComponents.horizontalBarChart:
        return const HomeHorizontalBarChart();
      case HomeComponents.baseLineChart:
        return const HomeBaseLineChart();
      case HomeComponents.tableChart:
        return const HomeTableChart();
      case HomeComponents.barChart:
        return const HomeBarChart();
      case HomeComponents.stackedBarChart:
        return const HomeStackedBarChart();
      case HomeComponents.groupedBarChart:
        return const HomeGroupedBarChart();
      case HomeComponents.pieChart:
        return const HomePieChart();
      case HomeComponents.horizontalStackedBarChart:
        return const HomeHorizontalStackedBarChart();
      case HomeComponents.radialBarChart:
        return const HomeRadialBarChart();
      case HomeComponents.barTrendChart:
        return const HomeBarChartTrend();
      case HomeComponents.donutChart:
        return const HomeDonutChart();
      default:
        return null;
    }
  }

  HomeComponentModel getModel(
      {required int rowNumber, required int columnNumber}) {
    switch (this) {
      case HomeComponents.nearBreachedSLA:
        return HomeComponentModel(
            component: this, rowNumber: rowNumber, columnNumber: columnNumber);

      default:
        return HomeComponentModel(
            component: this, rowNumber: rowNumber, columnNumber: columnNumber);
    }
  }
}