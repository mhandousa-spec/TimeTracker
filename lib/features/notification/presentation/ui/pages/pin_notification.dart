/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: pin_notification.dart
/// Purpose: Pinned notifications.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N05/N06/N11/N14: the two UI `try` blocks are gone; the drawer
///          cubit is read from the tree; toasts are themed and localized; the
///          unsafe casts are guarded.

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/51-custom_pop_up.dart';

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/todo_new_module/external/tasks_module/core/custom_widgets/SideFrameMasterServices.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/inventory_module/core/drop_down.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/services_mangment_module/core/custom_pop_up.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_filter_row.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_card.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';


import 'package:knowticed_plus/core/extensions/context_extensions.dart';
// ✅ PINNED NOTIFICATIONS PAGE - Shows only isPinned == true
class PinNotificationLandPage extends StatefulWidget {
  const PinNotificationLandPage({super.key});

  @override
  State<PinNotificationLandPage> createState() => _PinNotificationLandPageState();
}

class _PinNotificationLandPageState extends State<PinNotificationLandPage> {
  final FirestoreNotificationService _notificationService = FirestoreNotificationService();
  /// Resolved lazily rather than in a field initializer, so the page can be
  /// built before the GetX bindings have registered it (CR-SKEL-NOTIF-N06).
  MainCoreEmployeeController get _employeeController =>
      Get.find<MainCoreEmployeeController>();  // TODO(knowticed, 12/8/2026): inject

  String? _currentUserEmail;
  List<Modules> _allowedModules = [];

  @override
  void initState() {
    super.initState();
    _currentUserEmail = _employeeController.employeeEntity?.email;
    _loadAllowedModules();
  }

  void _loadAllowedModules() {
    List<Modules> allModules = [
      Modules.services,
      Modules.tasks,
      Modules.employees,
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            S.of(context).userEmailNotFound,
            style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
          ),
        ),
      );
    }

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: s.notifications,
        // FIXED 22/8/2026: was `updateSelectedIndex(19)` — a raw index into
        // the drawer's permission-filtered module list, which points at a
        // different entry on every tenant. This page is pushed on top of the
        // inbox now, so popping is both correct and layout-independent; the
        // drawer selection is only touched when there is nothing to pop back
        // to (deep link straight into this page).
        // Pops when this page was pushed (mobile), otherwise selects the
        // inbox's shell index. The old fallback resolved
        // Modules.notification, which is the Notification CONTROL page.
        onFirstTap: () => NotificationRouting.backToInbox(context),
        secondTitle: s.pinned,
        child: StreamBuilder<List<NotificationModelSystem>>(
          stream: _notificationService.streamNotificationsForUser(_currentUserEmail!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  // The raw Firestore error is not something a user can
                  // act on; it stays in the console, not on screen.
                  s.errorLoadingNotifications,
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
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
  TextEditingController searchController = TextEditingController();
  String sortOrder = "newest";

  /// Toolbar filters — the same four the inbox carries. All open on
  /// [NotificationFilters.all], a real option, so "All" reads as selected from
  /// the first frame.
  String? senderTypeFilter = NotificationFilters.all;
  String? byTypeFilter = NotificationFilters.all;
  String? departmentFilter = NotificationFilters.all;
  String? timeFilter = NotificationFilters.all;

  /// The pinned and not cleaned notifications this page shows, before the toolbar
  /// narrows them. Feeds the By Type / Department option lists so neither menu
  /// offers a value that matches nothing here.
  List<NotificationModelSystem> _scopedNotifications() =>
      widget.allNotifications.where((n) => n.isPinned && !n.isClean).toList();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ✅ ONLY show PINNED notifications (isPinned == true) - EXACT MATCH TO MAIN PAGE
  List<NotificationModelSystem> _getFilteredNotifications() {
    List<NotificationModelSystem> filtered = widget.allNotifications;

    // ✅ DEBUG: Print all notifications before filtering
    for (var n in filtered) {
    }

    // ✅ ONLY show PINNED notifications (isPinned == true)
    filtered = filtered.where((n) => n.isPinned == true).toList();

    // Still filter out cleaned notifications
    filtered = filtered.where((n) => n.isClean == false).toList();

    // ✅ FIXED: Module filter with better debugging (EXACT MATCH TO MAIN PAGE)
    // Resolved through NotificationRouting so role-area notifications file
    // under the Roles chip; the "All" test accepts the localized label too.
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
        // displayBody, not body — search matches what the card shows. See the
        // model: the "Reason: …" clause is stripped from every card.
        // Both languages: a notification is stored in English AND Arabic
        // (30/8/2026), so searching only the English half would miss a card
        // the user is currently looking at in Arabic. See the model.
        return n.searchText.contains(query);
      }).toList();
    }

    // Toolbar filters — sender type / module / department / time window.
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

  // ✅ FIXED: Better module name matching (EXACT MATCH TO MAIN PAGE)
  String _getModuleKeyFromName(String displayName) {

    for (Modules module in widget.allowedModules) {
      if (module.getModuleName == displayName) {
        String key = _moduleEnumToKey(module);
        return key;
      }
    }

    return displayName.toLowerCase();
  }

  // ✅ FIXED: Ensure exact match with Firebase naming (EXACT MATCH TO MAIN PAGE)
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

  // ✅ Count ONLY pinned and not cleaned notifications (EXACT MATCH TO MAIN PAGE)
  /// The chip key a stored notification belongs under. Notifications carry the
  /// fine-grained AppModule key (`user_access`, `user_management`,
  /// `role_management`…) while the chips are the drawer's coarser [Modules];
  /// NotificationRouting owns that mapping and collapses the three role-area
  /// keys onto [Modules.roles]. Same helper as notification_page.
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
      // ✅ ONLY count PINNED and NOT CLEANED notifications
      if (!notification.isPinned || notification.isClean) continue;

      counts['all'] = (counts['all'] ?? 0) + 1;

      // Resolved, not string-matched — see [_moduleKeyOf].
      final String? key = _moduleKeyOf(notification.nameOfModule);
      if (key != null && counts.containsKey(key)) {
        counts[key] = counts[key]! + 1;
      }
    }

    return counts;
  }

  // ✅ UPDATED: Properly unpin notification and update Firebase
  /// Unpins a notification.
  ///
  /// `updatePinStatus` returns `false` on failure and catches at the
  /// repository boundary, so the page-level `try/catch` was redundant — and
  /// try is forbidden in presentation/ui/ (§11.2, CR-SKEL-NOTIF-N05).
  Future<void> _handlePinToggle(NotificationModelSystem notification) async {
    // Snackbars removed: the row leaving the pinned list is the confirmation,
    // and a failed unpin is silent. The returned flag is no longer read —
    // updatePinStatus catches at the repository boundary.
    await widget.notificationService.updatePinStatus(notification.id!, false);
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

    List<NotificationModelSystem> filteredNotifications = _getFilteredNotifications();
    Map<String, int> moduleCounts = _getNotificationCountsByModule();

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusChip(
                  moduleCounts['all'].toString(),
                  s.all,
                  isSelected: selectStatus == s.all,
                  onTap: () => setState(() => selectStatus = s.all),
                  labelColor: selectStatus == s.all
                      ? AppColors.text
                      : AppColors.secondaryText,
                ),
                ...() {
                  List<Map<String, dynamic>> moduleData = widget.allowedModules
                      .map((module) {
                    String moduleKey = _moduleEnumToKey(module);
                    int count = moduleCounts[moduleKey] ?? 0;
                    return {
                      'module': module,
                      'moduleKey': moduleKey,
                      'count': count,
                      'displayName': module.getModuleName,
                    };
                  }).toList();

                  // Was `(b['count'] as int)` — a missing or wrongly-typed field threw
                  // during build (CR-SKEL-NOTIF-N11).
                  moduleData.sort((a, b) => ((b['count'] as num?)?.toInt() ?? 0)
                      .compareTo((a['count'] as num?)?.toInt() ?? 0));

                  return moduleData.map<Widget>((data) {
                    return _statusChip(
                      data['count'].toString(),
                      data['displayName'] as String,
                      isSelected: selectStatus == data['displayName'],
                      onTap: () => setState(
                          () => selectStatus = data['displayName']?.toString() ?? ''),
                      labelColor: selectStatus == data['displayName']
                          ? AppColors.text
                          : AppColors.secondaryText,
                    );
                  }).toList();
                }(),
              ],
            ),
          ),
          SizedBox(height: 15.sp),

          // Search and Sort
          Row(
            children: [
              AppSearchTextField(
                controller: searchController,
                onChanged: (val) => setState(() {}),
              ),
              SizedBox(width: 15.w),
              CustomPopupMenuButton(
                title: isMobile ? "" : s.sort,
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
            ],
          ),
          SizedBox(height: 15.sp),

          // Sender Type / By Type / Department / Time — same row as the inbox.
          NotificationFilterRow(
            notifications: _scopedNotifications(),
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

          SizedBox(height: 15.sp),

          // Grid or Empty
          filteredNotifications.isEmpty
              ? Center(
            child: Padding(
              padding: EdgeInsets.all(40.sp),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50.h),
                    Lottie.asset(
                      'assets/lottie_assets/notification_lottie_assets/empty.json',
                      width: 250.w,
                      height: 250.h,
                      fit: BoxFit.fill,
                      repeat: true,
                    ),
                  ],
                ),
              ),
            ),
          )
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              // 185.sp, matching the inbox — the card is shared now, so
              // the tile it sits in has to be too. 180.sp left it 5px short.
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

  /// One card. The layout lives in [NotificationCard], shared with the inbox
  /// and the Cleared page — this only decides what the three buttons do here.
  ///
  /// CHANGED 26/8/2026: this page used to carry its own copy of the card. It
  /// had drifted from the inbox's — no timestamp, no mobile type ramp, a
  /// sender chip that overflowed instead of ellipsising, wider buttons —
  /// because every fix only ever landed on the page someone was looking at.
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
      // Everything on this page is pinned, so this button only ever unpins.
      leadingAction: NotificationCardAction(
        title: s.unpin,
        iconPath: "assets/icons_assets/notification_assets/pushpin.svg",
        background: AppColors.darkGrey,
        foreground: AppColors.white,
        onTap: () => _handlePinToggle(notification),
      ),
      trailingAction: NotificationCardAction(
        title: s.view,
        iconPath: "assets/icons_assets/notification_assets/document_search.svg",
        onTap: () => _handleViewNotification(notification),
      ),
    );
  }

  Widget _statusChip(String count, String label, {required bool isSelected, required Color labelColor, required VoidCallback onTap}) {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light ? (isSelected ? AppColors.primary : AppColors.card) : (isSelected ? AppColors.primary : AppColors.card),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                    color: light
                        ? (isSelected ? AppColors.textButton : AppColors.secondaryText)
                        : (isSelected ? AppColors.textButton : AppColors.text))
                    : StyleText.fontSize20Weight500.copyWith(
                    color: light
                        ? (isSelected ? AppColors.textButton : AppColors.secondaryText)
                        : (isSelected ? AppColors.textButton : AppColors.text)),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            label,
            style: isMobile ? StyleText.fontSize14Weight600.copyWith(color: labelColor) : StyleText.fontSize16Weight600.copyWith(color: labelColor),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}