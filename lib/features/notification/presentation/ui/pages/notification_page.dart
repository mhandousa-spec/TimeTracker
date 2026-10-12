/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_page.dart
/// Purpose: The notification inbox.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N05/N06/N11/N14: the two UI `try` blocks are gone; the drawer
///          cubit is read from the tree; `Get.snackbar` replaced with a themed,
///          localized toast; the unsafe `as int` / `as String` casts are guarded;
///          raw colours route through AppColors.
///
/// REMAINING (CR-SKEL-NOTIF-N02): still ~1,000 LOC.

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/51-custom_pop_up.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/todo_new_module/external/tasks_module/core/custom_widgets/SideFrameMasterServices.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/pin_notification.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/inventory_module/core/drop_down.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/services_mangment_module/core/custom_pop_up.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_card.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_filter_row.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/clear_page_notification.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
final List<Map<String, String>> NotificationTypeList = [
  {'key': 'approval_requests', 'value': 'Approval Requests'},
  {'key': 'approvals_updates', 'value': 'Approvals Updates'},
  {'key': 'assignments', 'value': 'Assignments'},
  {'key': 'reminders', 'value': 'Reminders'},
  {'key': 'scheduled_reminders', 'value': 'Scheduled Reminders'},
  {'key': 'messages_announcements', 'value': 'Messages / Announcements'},
  {'key': 'comments_mentions', 'value': 'Comments / Mentions'},
  {'key': 'document_record_changes', 'value': 'Document / Record Changes'},
  {'key': 'task_workflow_updates', 'value': 'Task / Workflow Updates'},
  {'key': 'sla_alerts', 'value': 'SLA Alerts'},
  {'key': 'due_dates', 'value': 'Due Dates'},
  {'key': 'compliance_alerts', 'value': 'Compliance Alerts'},
  {'key': 'risk_warnings', 'value': 'Risk Warnings'},
  {'key': 'hr_updates', 'value': 'HR Updates'},
  {'key': 'attendance_logs', 'value': 'Attendance Logs'},
  {'key': 'low_inventory', 'value': 'Low Inventory'},
  {'key': 'stock_updates', 'value': 'Stock Updates'},
  {'key': 'maintenance_needed', 'value': 'Maintenance Needed'},
  {'key': 'form_submissions', 'value': 'Form Submissions'},
  {'key': 'role_changes', 'value': 'Role Changes'},
  {'key': 'access_notifications', 'value': 'Access Notifications'},
  {'key': 'user_account_updates', 'value': 'User Account Updates'},
  {'key': 'events', 'value': 'Events'},
  {'key': 'service_closure', 'value': 'Service Closure'},
];

final List<Map<String, String>> notificationByeType = [
  {'key': 'system', 'value': 'System'},
  {'key': 'employee', 'value': 'Employee'},
  {'key': 'manager', 'value': 'Manager'},
];

final List<Map<String, String>> TimeFilterList = [
  {'key': 'day', 'value': 'Day'},
  {'key': 'week', 'value': 'Week'},
  {'key': 'month', 'value': 'Month'},
  {'key': 'year', 'value': 'Year'},
  {'key': 'custom', 'value': 'Custom'},
];

final List<Map<String, String>> NotificationTypeListArabic = [
  {'key': 'approval_requests', 'value': 'طلبات الموافقة'},
  {'key': 'approvals_updates', 'value': 'تحديثات الموافقات'},
  {'key': 'assignments', 'value': 'التعيينات'},
  {'key': 'reminders', 'value': 'التذكيرات'},
  {'key': 'scheduled_reminders', 'value': 'التذكيرات المجدولة'},
  {'key': 'messages_announcements', 'value': 'الرسائل / الإعلانات'},
  {'key': 'comments_mentions', 'value': 'التعليقات / الإشارات'},
  {'key': 'document_record_changes', 'value': 'تغييرات المستندات / السجلات'},
  {'key': 'task_workflow_updates', 'value': 'تحديثات المهام / سير العمل'},
  {'key': 'sla_alerts', 'value': 'تنبيهات اتفاقية مستوى الخدمة'},
  {'key': 'due_dates', 'value': 'تواريخ الاستحقاق'},
  {'key': 'compliance_alerts', 'value': 'تنبيهات الامتثال'},
  {'key': 'risk_warnings', 'value': 'تحذيرات المخاطر'},
  {'key': 'hr_updates', 'value': 'تحديثات الموارد البشرية'},
  {'key': 'attendance_logs', 'value': 'سجلات الحضور'},
  {'key': 'low_inventory', 'value': 'انخفاض المخزون'},
  {'key': 'stock_updates', 'value': 'تحديثات المخزون'},
  {'key': 'maintenance_needed', 'value': 'الصيانة المطلوبة'},
  {'key': 'form_submissions', 'value': 'تقديم النماذج'},
  {'key': 'role_changes', 'value': 'تغييرات الأدوار'},
  {'key': 'access_notifications', 'value': 'إشعارات الوصول'},
  {'key': 'user_account_updates', 'value': 'تحديثات حساب المستخدم'},
  {'key': 'events', 'value': 'الأحداث'},
  {'key': 'service_closure', 'value': 'إغلاق الخدمة'},
];

final List<Map<String, String>> notificationByeTypeArabic = [
  {'key': 'system', 'value': 'النظام'},
  {'key': 'employee', 'value': 'الموظفين'},
  {'key': 'manager', 'value': 'المدير'},
];

final List<Map<String, String>> TimeFilterListArabic = [
  {'key': 'day', 'value': 'يوم'},
  {'key': 'week', 'value': 'أسبوع'},
  {'key': 'month', 'value': 'شهر'},
  {'key': 'year', 'value': 'سنة'},
  {'key': 'custom', 'value': 'مخصص'},
];

// `getNotificationTypeList()`, `getNotificationByeType()` and
// `getTimeFilterList()` were deleted: three top-level helpers with no callers
// anywhere in lib/, each selecting an Arabic or English list with
// `Get.locale` (CR-SKEL-NOTIF-N06). The lists themselves are still used
// directly by the page.


// ============================================
// MAIN PAGE
// ============================================

class NotificationLandPage extends StatefulWidget {
  const NotificationLandPage({super.key});

  @override
  State<NotificationLandPage> createState() => _NotificationLandPageState();
}

class _NotificationLandPageState extends State<NotificationLandPage> {
  final FirestoreNotificationService _notificationService =
  FirestoreNotificationService();
  final MainCoreEmployeeController _employeeController =
  Get.find<MainCoreEmployeeController>();  // TODO(knowticed, 12/8/2026): inject

  String? _currentUserEmail;
  bool _hasMarkedAllAsRead = false;
  List<Modules> _allowedModules = [];

  @override
  void initState() {
    super.initState();
    _currentUserEmail = _employeeController.employeeEntity?.email;
    _loadAllowedModules();

    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      _markAllNotificationsAsRead();
    }
  }

  void _loadAllowedModules() {
    List<Modules> allModules = [
      Modules.services,
      Modules.tasks,
      // REMOVED 26/8/2026: Modules.employees — the "Org Chart" filter chip.
      // This list is what the chip row, the per-chip counts and the chip →
      // module-key lookup all read, so dropping it here removes the chip and
      // its count together. Org Chart notifications still arrive and still
      // show under "All"; they just no longer get a filter of their own.
      Modules.inventory,
      Modules.messages,
      Modules.knowledgeHub,
      Modules.qiyas,
      Modules.formBuilder,
      // CHANGED 9/10/2026 (Time Tracker phase 4): the real module, not the
      // legacy stub — NotificationRouting now resolves `time_tracker` here.
      Modules.timeTracker,
      Modules.todo,
      Modules.grc,
      Modules.database,
      Modules.roles,
      // ADDED 24/8/2026: settings notifications (change request submitted /
      // approved / rejected) store `Name_of_module: 'settings'`. The module was
      // missing from this list, so they landed in "All" with no tab of their
      // own and no way to filter to them. `Modules.settings` is always present
      // in the drawer (AppDrawerCubit adds it unconditionally), so tapping one
      // opens Settings rather than reporting access denied.
      Modules.settings,
    ];

    _allowedModules = allModules.where((module) {
      return _employeeController.hasModuleAccess(module);
    }).toList();
  }

  Future<void> _markAllNotificationsAsRead() async {
    if (_hasMarkedAllAsRead || _currentUserEmail == null) return;
    await _notificationService.markAllAsRead(_currentUserEmail!);
    _hasMarkedAllAsRead = true;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            S.of(context).userEmailNotFound,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: s.notifications,
        child: StreamBuilder<List<NotificationModelSystem>>(
          stream: _notificationService
              .streamNotificationsForUser(_currentUserEmail!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  // The raw Firestore error is not something a user can
                  // act on; it stays in the console, not on screen.
                  s.errorLoadingNotifications,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                  ),
                ),
              );
            }

            return _NotificationContent(
              allNotifications: snapshot.data ?? [],
              allowedModules: _allowedModules,
              currentUserEmail: _currentUserEmail!,
              notificationService: _notificationService,
              employeeController: _employeeController,
            );
          },
        ),
      ),
    );
  }
}

// ✅ SEPARATE STATEFUL WIDGET FOR CONTENT
class _NotificationContent extends StatefulWidget {
  final List<NotificationModelSystem> allNotifications;
  final List<Modules> allowedModules;
  final String currentUserEmail;
  final FirestoreNotificationService notificationService;
  final MainCoreEmployeeController employeeController;

  const _NotificationContent({
    required this.allNotifications,
    required this.allowedModules,
    required this.currentUserEmail,
    required this.notificationService,
    required this.employeeController,
  });

  @override
  State<_NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<_NotificationContent> {
  String selectStatus = "All";
  String? selectedNotificationType;
  String? selectedNotificationByeType;
  String? selectedNotificationTime;
  String? selectedNotificationDepartment;
  TextEditingController searchController = TextEditingController();
  String sortOrder = "newest";

  // ── Toolbar state (added 22/8/2026, Figma 4717:10740) ─────────────────
  //
  // The design carries a second filter row under the search field — Sender
  // Type and By Type on the leading side, Department and Time on the
  // trailing side — and a "Collapse Tools" link above the buttons. None of it
  // existed in the code.
  //
  // FIXED 25/8/2026 — all four filters opened the page on `null`, which is not
  // one of the options. Nothing was highlighted when the menu dropped open and
  // the trigger drew in the placeholder style, so the row read as "unset"
  // rather than "showing everything". They now start on
  // [NotificationFilters.all] — the sentinel behind the "All" entry, a real
  // value present in every option list — so "All" is the selection from the
  // first frame.
  //
  // CHANGED 26/8/2026: the "All" sentinel, the test for whether a value
  // narrows anything, the four option builders and the row itself all live in
  // notification_filter_row.dart, which the Pinned and Cleared pages already
  // used. This page kept a private copy of every one of them, so a fix to
  // either half only ever reached one of the three lists.

  /// Person-sent vs system-raised. Resolved from whether the sender email
  /// belongs to an employee record — the same test the card layout uses.
  String? senderTypeFilter = NotificationFilters.all;

  /// The module a notification came from. This is the only "type" the stored
  /// notification actually carries: `NotificationModelSystem` has title, body,
  /// module, sender, receiver, page, pinned, timestamp — and no type field. The
  /// `NotificationTypeList` at the top of this file (approval_requests,
  /// reminders, …) has nothing behind it in Firestore, so filtering by it would
  /// silently match nothing. Wiring a real one needs the field added to the
  /// model and to AppNotificationSender first.
  String? byTypeFilter = NotificationFilters.all;

  /// Department of the sender.
  String? departmentFilter = NotificationFilters.all;

  /// How far back to look: day / week / month / year.
  String? timeFilter = NotificationFilters.all;

  /// Whether the chips, search and filter rows are hidden to give the card
  /// list the full height ("Collapse Tools" / "Expand Tools" in the design).
  bool toolsCollapsed = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<NotificationModelSystem> _getFilteredNotifications() {
    List<NotificationModelSystem> filtered = widget.allNotifications;

    // ✅ DEBUG: Print all notifications before filtering
    for (var n in filtered) {
    }

    // Filter out pinned and cleaned
    filtered = filtered.where((n) => n.isPinned == false).toList();

    filtered = filtered.where((n) => n.isClean == false).toList();

    // Module filter.
    //
    // FIXED: this compared the stored `Name_of_module` string straight against
    // the chip's key, so only notifications whose module key happened to equal
    // a drawer module name were ever counted. Everything the role area sends —
    // `user_access`, `user_management`, `role_management` — matched no chip at
    // all and was reachable only through "All". Resolving through
    // NotificationRouting.moduleForStoredKey files all three under Roles, the
    // same mapping that decides where tapping the card navigates.
    //
    // The "All" test also accepts the localized label: the chips set
    // selectStatus to S.of(context).all, so in Arabic the literal "All" never
    // matched and the page filtered itself empty.
    if (selectStatus != "All" && selectStatus != S.of(context).all) {
      final String moduleFilter = _getModuleKeyFromName(selectStatus);

      filtered = filtered
          .where((n) => _moduleKeyOf(n.nameOfModule) == moduleFilter)
          .toList();
    }

    // Search filter
    if (searchController.text.isNotEmpty) {
      String query = searchController.text.toLowerCase();
      filtered = filtered.where((n) {
        // displayBody, not body: search matches what the card actually shows.
        // Matching the raw text would surface cards whose only hit is inside
        // the stripped "Reason:" clause, which the reader cannot see.
        // Both languages: a notification is stored in English AND Arabic
        // (30/8/2026), so searching only the English half would miss a card
        // the user is currently looking at in Arabic. See the model.
        return n.searchText.contains(query);
      }).toList();
    }

    // ── Toolbar filters ─────────────────────────────────────────────────
    // Sender Type / By Type / Department / Time. The predicate lives beside
    // the row that drives it, in notification_filter_row.dart, so the three
    // inboxes cannot disagree about what a selection means. This page used to
    // carry its own copy of all four tests.
    filtered = NotificationFilters.apply(
      source: filtered,
      employeeController: widget.employeeController,
      senderType: senderTypeFilter,
      byType: byTypeFilter,
      department: departmentFilter,
      time: timeFilter,
    );

    // Sort by timestamp
    filtered.sort((a, b) {
      if (sortOrder == "newest") {
        return (b.timestamp ?? 0).compareTo(a.timestamp ?? 0);
      } else {
        return (a.timestamp ?? 0).compareTo(b.timestamp ?? 0);
      }
    });

    return filtered;
  }

  /// Function Name: [_chipLabel]
  ///
  /// Purpose: The text a module's filter chip shows. ADDED 26/8/2026.
  ///
  /// [Modules.getModuleName] is the app-wide name — "Roles", "Services" — and
  /// the sidebar, the drawer and every module screen keep using it. This inbox
  /// spells those two out instead, so the override lives here rather than in
  /// the enum, where it would rename them across the whole app.
  ///
  /// Anything that compares against a chip label must go through this method
  /// too: [_getModuleKeyFromName] does, because `selectStatus` stores the
  /// LABEL rather than the enum, and a label the lookup can't resolve silently
  /// filters the list down to nothing.
  String _chipLabel(Modules module) {
    final bool isArabic = Get.locale.toString().contains('ar');
    switch (module) {
      case Modules.roles:
        return isArabic ? 'إدارة الأدوار' : 'Role Management';
      case Modules.services:
        return isArabic ? 'إدارة الخدمات' : 'Service Management';
      default:
        return module.getModuleName;
    }
  }

  // ✅ FIXED: Better module name matching
  String _getModuleKeyFromName(String displayName) {

    for (Modules module in widget.allowedModules) {
      // _chipLabel first — that is what the chip rendered and therefore what
      // selectStatus holds. getModuleName stays as a fallback so a value
      // captured before the 26/8/2026 rename still resolves.
      if (_chipLabel(module) == displayName ||
          module.getModuleName == displayName) {
        String key = _moduleEnumToKey(module);
        return key;
      }
    }

    return displayName.toLowerCase();
  }

  // ✅ FIXED: Ensure exact match with Firebase naming
  String _moduleEnumToKey(Modules module) {
    switch (module) {
      case Modules.services:
        return 'services';
      case Modules.roles:
        return 'roles';
      case Modules.tasks:
        return 'tasks';
      case Modules.employees:
        return 'employees';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.knowledgeHub:
        return 'knowledgeHub'; // ✅ Matches Firebase exactly
      case Modules.qiyas:
        return 'qiyas';
      case Modules.formBuilder:
        return 'formBuilder'; // ✅ Changed from 'services_app'
      case Modules.timeTracker: // CHANGED 9/10/2026 (was Modules.tracking)
        return 'tracking';
      case Modules.todo:
        return 'todo';
      case Modules.grc:
        return 'grc';
      case Modules.database:
        return 'database';
      default:
        return module.name.toLowerCase();
    }
  }

  /// Function Name: [_moduleKeyOf]
  ///
  /// Purpose: The chip key a stored notification belongs under.
  ///
  /// Notifications store the fine-grained AppModule key (`user_access`,
  /// `user_management`, `role_management`, `knowledge_hub`, `time_tracker`…),
  /// while the chips are the drawer's coarser [Modules]. NotificationRouting
  /// owns that mapping — the three role-area keys all collapse onto
  /// [Modules.roles] — so counting and filtering both go through it instead of
  /// string-matching the raw value.
  ///
  /// Returns: the chip key, or `null` for a module this inbox has no chip for.
  String? _moduleKeyOf(String storedModuleKey) {
    final Modules? module =
        NotificationRouting.moduleForStoredKey(storedModuleKey);
    return module == null ? null : _moduleEnumToKey(module);
  }

  Map<String, int> _getNotificationCountsByModule() {
    Map<String, int> counts = {'all': 0};

    for (Modules module in widget.allowedModules) {
      String key = _moduleEnumToKey(module);
      counts[key] = 0;
    }

    for (var notification in widget.allNotifications) {
      if (notification.isPinned || notification.isClean) continue;

      counts['all'] = (counts['all'] ?? 0) + 1;

      // Resolved, not string-matched — see [_moduleKeyOf]. This is why the
      // chips used to sum to less than "All": every user-access and
      // user-management alert fell through.
      final String? key = _moduleKeyOf(notification.nameOfModule);
      if (key != null && counts.containsKey(key)) {
        counts[key] = counts[key]! + 1;
      }
    }

    return counts;
  }

  Future<void> _handleCleanAll() async {
    final s = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/notification_lottie_assets/Simple Trash Clear.json',
      confirmTitle: s.cleaningNotifications,
      confirmSubtitle: s.areYouSureYouWantToCleanAll,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async {
        // `markAllAsCleaned` returns false on failure and catches at the
        // repository boundary (§11.2, CR-SKEL-NOTIF-N05).
        return widget.notificationService
            .markAllAsCleaned(widget.currentUserEmail);
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/approved.json',
      successTitle: s.allNotificationsCleared,
      successSubtitle: s.youSuccessfullyCleanedAllNotification,
    );
  }

  Future<void> _handlePinToggle(NotificationModelSystem notification) async {
    bool newPinStatus = !notification.isPinned;
    await widget.notificationService
        .updatePinStatus(notification.id!, newPinStatus);
  }

  /// Opens what a notification points at.
  ///
  /// CHANGED 12/9/2026: this was ~25 lines here, and the same ~25 lines in
  /// `clear_page_notification.dart` and `pin_notification.dart`. All three
  /// resolved the module and stopped, ignoring the `name_of_page` every
  /// notification stores. The shared version reads it, so a notification can
  /// land on the section it is about, and the three copies cannot drift again.
  void _handleViewNotification(NotificationModelSystem notification) =>
      NotificationRouting.openNotification(context, notification);


  // WIRED 21/9/2026 — was a no-op. See NotificationRouting.messageSender.
  void _handleMessageSender(NotificationModelSystem notification) =>
      NotificationRouting.messageSender(context, notification);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.sizeOf(context).width >= 900;
    var isMobile = ContextExtension(context).isPhone;
    final s = S.of(context);

    List<NotificationModelSystem> filteredNotifications =
    _getFilteredNotifications();
    Map<String, int> moduleCounts = _getNotificationCountsByModule();

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── "Collapse Tools" ──────────────────────────────────────
          // ADDED 22/8/2026 (Figma 4717:10740): a text link, trailing-aligned,
          // that hides the chips / search / filter rows so the card list gets
          // the full height. Reads "Expand Tools" once collapsed.
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: () =>
                  setState(() => toolsCollapsed = !toolsCollapsed),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.sp),
                // CHANGED 26/8/2026: was TextDecoration.underline, which sits
                // tight against the baseline and gives no control over the
                // gap. This draws the rule as its own 1.h line 3.h below the
                // text instead. IntrinsicWidth sizes the column to the text,
                // and CrossAxisAlignment.stretch hands that same width to the
                // line — so it tracks the label and stays exactly as wide,
                // including when it flips to "Expand Tools" or to Arabic.
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        toolsCollapsed ? s.expandTools : s.collapseTools,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(height: 1.h, color: AppColors.blue),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.sp),

          // ── What "Collapse Tools" hides ───────────────────────────────
          // CHANGED 26/8/2026. Collapsed now leaves exactly the search row
          // and the cards on screen, so this guard opens here — above the
          // Cleared / Pin buttons — rather than below them. It closes just
          // before the search row and reopens just after it, because that one
          // row is the only thing between here and the grid that survives.
          if (!toolsCollapsed) ...[
          // Top buttons
          Row(
            children: [
              customButtonWithSvg(
                title: s.cleared,
                // The root push this replaces covered the sidebar and app bar
                // ("frame of page is lost"): the shell's content area is not
                // wrapped in a nested Navigator. openInShell selects the index
                // the shell already renders this page at, and only pushes on
                // mobile, where there is no shell. See NotificationRouting.
                function: () => NotificationRouting.openInShell(
                  context,
                  shellIndex: NotificationRouting.clearedShellIndex,
                  pageBuilder: () => const CleanedNotificationLandPage(),
                ),
                width: 135.w,
                height: 38.h,
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
                space: 8.sp,
                radius: 8.r,
                svgColor: AppColors.textButton,
                image: "assets/icons_assets/notification_assets/broom_sweep.svg",
                widthImage: 22.sp,
                heightImage: 22.sp,
                colorBorder: AppColors.transparent,
              ),
              Spacer(),
              customButtonWithSvg(
                title: s.pin,
                // Same as Cleared above — select, don't push.
                function: () => NotificationRouting.openInShell(
                  context,
                  shellIndex: NotificationRouting.pinnedShellIndex,
                  pageBuilder: () => const PinNotificationLandPage(),
                ),
                width: 135.w,
                height: 38.h,
                color: AppColors.primary,
                svgColor: AppColors.textButton,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
                space: 8.sp,
                radius: 8.r,
                image: "assets/icons_assets/notification_assets/pin_round_head.svg",
                widthImage: 22.sp,
                heightImage: 22.sp,
                colorBorder: AppColors.transparent,
              ),
            ],
          ),
          SizedBox(height: 15.sp),

          // Filter chips
          //
          // CHANGED 13/9/2026 — was a local `_statusChip` plus a hand-rolled
          // horizontal Row, a near-copy of the shared component. Now
          // `StatusChipFilter` (core/custom/8-custom_filter_app.dart), which
          // already does the scroll row, the count box, the selected/
          // unselected colours and — the reason this page wanted it —
          // localises the count digits, so an Arabic screen no longer shows
          // ASCII "14" beside Arabic-Indic dates.
          //
          // The chip KEY stays the displayed name, not a module id, because
          // `selectStatus` is what `_getFilteredNotifications` feeds to
          // `_getModuleKeyFromName`. Changing the key would mean changing that
          // lookup too, and this change is meant to be visual only.
          StatusChipFilter(
            selectedKey: selectStatus,
            onSelected: (String key) => setState(() => selectStatus = key),
            innerSpacing: 16.sp,
            items: <StatusChipItem>[
              StatusChipItem(
                key: s.all,
                label: s.all,
                count: moduleCounts['all'] ?? 0,
              ),
              ...() {
                final List<Map<String, dynamic>> moduleData =
                    widget.allowedModules.map((module) {
                  final String moduleKey = _moduleEnumToKey(module);
                  return <String, dynamic>{
                    'count': moduleCounts[moduleKey] ?? 0,
                    // Not getModuleName — see [_chipLabel] for why this inbox
                    // renames Roles / Services locally.
                    'displayName': _chipLabel(module),
                  };
                }).toList();

                // Busiest module first. Was `(b['count'] as int)` — a missing
                // or wrongly-typed field threw during build
                // (CR-SKEL-NOTIF-N11).
                moduleData.sort((a, b) => ((b['count'] as num?)?.toInt() ?? 0)
                    .compareTo((a['count'] as num?)?.toInt() ?? 0));

                return moduleData.map<StatusChipItem>((data) {
                  final String name = data['displayName']?.toString() ?? '';
                  return StatusChipItem(
                    key: name,
                    label: name,
                    count: (data['count'] as num?)?.toInt() ?? 0,
                  );
                }).toList();
              }(),
            ],
          ),
          SizedBox(height: 15.sp),
          ],

          // Search and buttons. OUTSIDE the collapse guard on purpose — the
          // collapsed view is "search row + cards", so this row and the Sort /
          // Clean All buttons on it stay put either way.
          Row(
            children: [
              AppSearchTextField(
                controller: searchController,
                onChanged: (val) => setState(() {}),
              ),
              SizedBox(width: isMobile ? 8.sp : 15.w),
              // CHANGED 13/9/2026 (Figma MESBAH — mobile Notification screen).
              // At 375px the four filter dropdowns took a third of the screen
              // before a single card showed, so on mobile they move into a
              // dialog and this slot carries the Filter button that opens it.
              // Sort keeps the slot on tablet and desktop, where the dropdown
              // row still fits beside the cards.
              if (isMobile)
                NotificationFilterButton(
                  isActive:
                      NotificationFilters.isFiltering(senderTypeFilter) ||
                          NotificationFilters.isFiltering(byTypeFilter) ||
                          NotificationFilters.isFiltering(departmentFilter) ||
                          NotificationFilters.isFiltering(timeFilter),
                  onTap: () async {
                    final NotificationFilterSelection? picked =
                        await showNotificationFilterDialog(
                      context: context,
                      notifications: widget.allNotifications
                          .where((n) => !n.isPinned && !n.isClean)
                          .toList(),
                      employeeController: widget.employeeController,
                      current: NotificationFilterSelection(
                        senderType: senderTypeFilter,
                        byType: byTypeFilter,
                        department: departmentFilter,
                        time: timeFilter,
                      ),
                    );

                    // null = dismissed. Leave the page's filters alone.
                    if (picked == null || !mounted) return;
                    setState(() {
                      senderTypeFilter = picked.senderType;
                      byTypeFilter = picked.byType;
                      departmentFilter = picked.department;
                      timeFilter = picked.time;
                    });
                  },
                )
              else
              CustomPopupMenuButton(
                title: s.sort,
                iconPath: "assets/icons_assets/main_icons_assets/sort_lines.svg",
                backgroundColor: AppColors.card,
                iconColor: AppColors.secondaryText,
                width: 100,
                height: 38,
                options: [
                  // Was a hand-rolled locale ternary; the strings live in
                  // the ARB bundle now like every other label on the page.
                  PopupOption(value: "newest", label: s.newestFirst),
                  PopupOption(value: "oldest", label: s.oldestFirst),
                ],
                onSelected: (value) {
                  setState(() {
                    sortOrder = value;
                  });
                },
              ),
              SizedBox(width: isMobile ? 8.sp : 15.w),
              GestureDetector(
                onTap: _handleCleanAll,
                child: Container(
                  width: isMobile ? 38.w : 120.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.primary,
                  ),
                  child: isMobile
                      ? Center(
                    child: CustomSvgImage(
                      assetPath:
                      "assets/icons_assets/notification_assets/clear_all_document_broom.svg",
                      width: 20.w,
                      height: 20.h,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage(
                        assetPath:
                        "assets/icons_assets/notification_assets/clear_all_document_broom.svg",
                        width: 20.w,
                        height: 20.h,
                        fit: BoxFit.scaleDown,
                        color: AppColors.textButton,
                      ),
                      SizedBox(width: 8.w),
                      Text(s.cleanAll,
                          style: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Guard reopens: the filter dropdowns collapse with the rest.
          if (!toolsCollapsed) ...[
          SizedBox(height: 15.sp),

          // ── Filter row ────────────────────────────────────────────────
          // ADDED 22/8/2026 (Figma 4717:10740 + the 768 / 375 twins). Sender
          // Type and By Type lead, Department and Time trail. On mobile the
          // four stack into two rows of two rather than being cut off — the
          // design collapses them behind a filter icon there, but four
          // reachable dropdowns beat one icon that needs another sheet built
          // behind it.
          //
          // Shared with the Pinned and Cleared pages since 26/8/2026 — the
          // page keeps the four selected values and nothing else. The list
          // handed over is the one this page actually shows (unpinned and
          // uncleaned), because the By Type and Department menus are built
          // from it and must not offer an option that matches nothing.
          // Mobile reaches these through the Filter button above instead.
          if (!isMobile)
          NotificationFilterRow(
            notifications: widget.allNotifications
                .where((n) => !n.isPinned && !n.isClean)
                .toList(),
            employeeController: widget.employeeController,
            isMobile: isMobile,
            senderType: senderTypeFilter,
            byType: byTypeFilter,
            department: departmentFilter,
            time: timeFilter,
            onSenderTypeChanged: (v) => setState(() => senderTypeFilter = v),
            onByTypeChanged: (v) => setState(() => byTypeFilter = v),
            onDepartmentChanged: (v) => setState(() => departmentFilter = v),
            onTimeChanged: (v) => setState(() => timeFilter = v),
          ),

          ],

         isMobile
             ? (toolsCollapsed ? SizedBox(height: 15.sp) : SizedBox())
             : SizedBox(height: 15.sp),

          // Grid
          filteredNotifications.isEmpty
              ? Center(
            child: Padding(
                padding: EdgeInsets.all(40.sp),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50.h),
                      Lottie.asset('assets/lottie_assets/notification_lottie_assets/empty.json',
                          width: 250.w,
                          height: 250.h,
                          fit: BoxFit.fill,
                          repeat: true),
                    ],
                  ),
                )),
          )
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              // 160.sp left the card ~37px short of its own content once the
              // sender chip and the two button rows were laid out.
              // CHANGED 13/9/2026 — one tile height per form factor.
              //
              // A single 195.sp left a band of empty card under the buttons on
              // a phone: mobile shrinks the buttons to 75% (see
              // notification_card.dart), the avatar to 30.sp and the label
              // sizes with it, so the card needs roughly 25.sp less than a
              // desktop one. The body is Flexible now, so that surplus does
              // not stretch the text box — it just sits at the bottom of the
              // card, which is exactly the gap this removes.
              // +1 body line (owner round 4, 7/10/2026): bodies show
              // up to 3 lines — see NotificationCard.bodyMaxLines.
              mainAxisExtent: isMobile ? 190.sp : 212.sp,
              crossAxisSpacing: 15.sp,
              mainAxisSpacing: 15.sp,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return _buildNotificationCard(notification, isMobile, s);
            },
          ),
        ],
      ),
    );
  }

  /// One card. The layout lives in [NotificationCard], shared with the Pinned
  /// and Cleared pages — this only decides what the three buttons do here.
  Widget _buildNotificationCard(
      NotificationModelSystem notification, bool isMobile, S s) {
    // No Message button on a system notification (nobody to message) nor on
    // a To-Do one (personal — owner, 7/10/2026). Same rule the card uses.
    final bool hasHumanSender = NotificationCard.hasSenderSection(
        notification, widget.employeeController);

    return NotificationCard(
      notification: notification,
      employeeController: widget.employeeController,
      isMobile: isMobile,
      onTap: () => _handleViewNotification(notification),
      primaryAction: hasHumanSender
          ? NotificationCardAction(
              title: s.message,
              iconPath:
                  "assets/icons_assets/roles_assets/chat_messages_bubbles.svg",
              onTap: () => _handleMessageSender(notification),
            )
          : null,
      leadingAction: NotificationCardAction(
        title: s.pin,
        iconPath: "assets/icons_assets/notification_assets/pushpin.svg",
        // Grey once pinned — the same button unpins.
        background: notification.isPinned
            ? AppColors.secondaryText
            : AppColors.primary,
        onTap: () => _handlePinToggle(notification),
      ),
      trailingAction: NotificationCardAction(
        title: s.view,
        iconPath: "assets/icons_assets/notification_assets/document_search.svg",
        onTap: () => _handleViewNotification(notification),
      ),
    );
  }

}