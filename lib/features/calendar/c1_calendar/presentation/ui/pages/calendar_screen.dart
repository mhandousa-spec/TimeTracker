/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_screen.dart
/// Purpose: The full calendar screen — month, week and day views with filters.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N06/N07/N08/N09/N11: the data service and fetch moved into
///          `CalendarCubit` (which also fixes this screen fetching only five of
///          the seven event sources); `Get.find<AppDrawerCubit>()` became
///          `context.read`; the module palette is shared.
/// Updated: 7/10/2026 - To-Do chip reads "To-Do List"; the status chips come
///          from the one `statusTypes` getter (adds the missing "Frequency").
/// Updated: 7/10/2026 - To-Do "Task Due" (statusCode 'Due') files under the
///          existing "Due" chip; month-view To-Do cards open the to-do.
///
/// REMAINING (CR-SKEL-CAL-N07): still over the 800-LOC gate.

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/theme/calendar_module_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/calendar_package/controller.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/calendar_package/widget.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/controller/calendar_cubit.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'dart:convert';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/event_card.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/day_timeline_view.dart';

class CalendarTestScreen extends StatefulWidget {
  const CalendarTestScreen({super.key, this.currentUserEmail});

  /// The signed-in user's email. Passed in rather than resolved with
  /// `Get.find<MainCoreEmployeeController>()` inside the load (§16,
  /// CR-SKEL-CAL-N09).
  final String? currentUserEmail;

  @override
  State<CalendarTestScreen> createState() => _CalendarTestScreenState();
}

class _CalendarTestScreenState extends State<CalendarTestScreen> {
  late AdvancedCalendarController _calendarController;
  String selectedModule = 'All';
  String selectedStatus = 'All';
  CalendarViewMode currentViewMode = CalendarViewMode.month;
  DateTime displayedMonth = DateTime.now();
  Key _calendarKey = UniqueKey();

  /// The fetch orchestration lives in the cubit now (CR-SKEL-CAL-N06).
  late final CalendarCubit _calendarCubit;

  List<CalendarEventModel> get eventDetails => _calendarCubit.state.events;
  bool get _isLoading => _calendarCubit.state.isLoading;

  Locale? _currentLocale;

  /// FIXED 22/8/2026 — this is what made the Calendar button open a blank
  /// grey page.
  ///
  /// It read `context.read<AppDrawerCubit>()`. `AppDrawerCubit` is never put
  /// into the widget tree: `main.dart`'s MultiBlocProvider provides
  /// ThemeAndLocalizationsCubit, CompanyCubit, AppHomeCubit and
  /// MainCoreDepartmentCubit — and nothing else — while every AppDrawerCubit
  /// registration in the app goes through GetX (`Get.put` in
  /// custom_drawer.dart, home_responsive_page.dart, main_responsive.dart).
  /// So `context.read` found no provider and threw ProviderNotFoundException
  /// out of `getUniqueModulesWithMapping()` during build. In a release build
  /// Flutter's default ErrorWidget is a plain grey rectangle — exactly what
  /// the screen showed.
  ///
  /// Resolved from the registry that actually owns it, with the same
  /// register-if-missing guard custom_drawer.dart uses, so opening the
  /// calendar directly (deep link, mobile layout where the drawer cubit was
  /// deleted) cannot crash the page.
  AppDrawerCubit get _drawerController => Get.isRegistered<AppDrawerCubit>()
      ? Get.find<AppDrawerCubit>()
      : Get.put(AppDrawerCubit());

  @override
  void initState() {
    super.initState();
    _calendarCubit = CalendarCubit(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
    );


    _calendarController = AdvancedCalendarController(displayedMonth);


    _loadCalendarData();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);

    if (_currentLocale != locale) {
      _currentLocale = locale;

      if (mounted) {
        setState(() {
          _calendarKey = UniqueKey();
        });
      }
    }
  }

  String _toArabicNumber(int number) {
    if (_currentLocale?.languageCode != 'ar') return number.toString();

    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return int.tryParse(digit) != null ? arabicNumbers[int.parse(digit)] : digit;
    }).join();
  }

// In _CalendarTestScreenState class

// 1. ✅ ADD TODO COLOR to getModuleColor method (around line 220)
  /// Delegates to the shared palette. The sixteen inline `Color(0xFF…)`
  /// literals this held — duplicated in the other calendar page — moved to
  /// `presentation/ui/theme/calendar_module_palette.dart` (CR-SKEL-CAL-N11).
  Color getModuleColor(String moduleName) =>
      CalendarModulePalette.colorOf(moduleName);

  /// Function Name: [_loadCalendarData]
  ///
  /// Purpose: Ask the cubit to refresh.
  ///
  /// The fetches, the `Get.find<MainCoreEmployeeController>()` and the `try`
  /// moved into `CalendarCubit` (CR-SKEL-CAL-N06/N08/N09). This screen used to
  /// fetch only five of the seven sources — role-management and user-access
  /// events were missing here but present on the home card. The cubit fetches
  /// all seven for both.
  Future<void> _loadCalendarData() async {
    await _calendarCubit.load(
      currentUserEmail: widget.currentUserEmail ?? '',
    );
  }

  List<String> get statusTypes {
    final isArabic = _currentLocale?.languageCode == 'ar';
    return [
      isArabic ? 'الكل' : 'All',
      isArabic ? 'مجدول' : 'Scheduled',
      isArabic ? 'معين' : 'Assigned',
      // 'Due' also carries the To-Do "Task Due" entry (statusCode 'Due').
      isArabic ? 'مستحق' : 'Due',
      isArabic ? 'متأخر' : 'Overdue',
      isArabic ? 'تذكيرات' : 'Reminders',
      'SLA',
      isArabic ? 'معلم' : 'Milestone',
      isArabic ? 'منتهي الصلاحية' : 'Expiring',
      isArabic ? 'تجديد' : 'Renewal',
      isArabic ? 'إصدار' : 'Release',
      isArabic ? 'المدة' : 'Duration',
      isArabic ? 'دورات الفوترة' : 'Billing Cycles',
      isArabic ? 'الموافقة المعلقة' : 'Pending Approval',
      isArabic ? 'التكرار' : 'Frequency',
    ];
  }

// 4. ✅ UPDATE _getEnglishStatusName to handle Frequency (around line 360)
  String _getEnglishStatusName(String displayStatus) {
    final isArabic = _currentLocale?.languageCode == 'ar';
    if (!isArabic) return displayStatus;

    final statusMap = {
      'الكل': 'All',
      'مجدول': 'Scheduled',
      'معين': 'Assigned',
      'مستحق': 'Due',
      'متأخر': 'Overdue',
      'تذكيرات': 'Reminders',
      'معلم': 'Milestone',
      'منتهي الصلاحية': 'Expiring',
      'تجديد': 'Renewal',
      'إصدار': 'Release',
      'المدة': 'Duration',
      'دورات الفوترة': 'Billing Cycles',
      'الطلبات المعلقة': 'Pending Requests',
      // The chip itself is built as 'الموافقة المعلقة' / 'Pending Approval'
      // (see [statusTypes]), but only 'Pending Requests' was mapped — so in
      // Arabic the round trip fell through to the English string and no event
      // ever matched the chip. Both spellings are mapped rather than renaming
      // the chip, because 'Pending Requests' may already be persisted.
      'الموافقة المعلقة': 'Pending Approval',
      'التكرار': 'Frequency', // ✅ ADD THIS
    };

    return statusMap[displayStatus] ?? displayStatus;
  }

// 5. ✅ UPDATE _getLocalizedStatusName to handle Frequency (around line 380)
  String _getLocalizedStatusName(String englishStatus) {
    final isArabic = _currentLocale?.languageCode == 'ar';
    if (!isArabic) return englishStatus;

    final statusMap = {
      'All': 'الكل',
      'Scheduled': 'مجدول',
      'Assigned': 'معين',
      'Due': 'مستحق',
      'Overdue': 'متأخر',
      'Reminders': 'تذكيرات',
      'Milestone': 'معلم',
      'Expiring': 'منتهي الصلاحية',
      'Renewal': 'تجديد',
      'Release': 'إصدار',
      'Duration': 'المدة',
      'Billing Cycles': 'دورات الفوترة',
      'Pending Requests': 'الطلبات المعلقة',
      // Mirror of the addition in [_getEnglishStatusName]. This is the
      // direction that matters for the new catalog: ServicesCalendarEvent
      // .pendingApproval sets statusCode 'Pending Approval', and without this
      // pair the card is dropped from every chip in Arabic.
      'Pending Approval': 'الموافقة المعلقة',
      'Frequency': 'التكرار', // ✅ ADD THIS
    };

    return statusMap[englishStatus] ?? englishStatus;
  }

  List<Map<String, dynamic>> get events {
    Map<DateTime, Map<String, Color>> eventsByDate = {};


    for (var event in eventDetails) {
      final dateKey = DateTime(event.date.year, event.date.month, event.date.day);

      if (!eventsByDate.containsKey(dateKey)) {
        eventsByDate[dateKey] = {};
      }

      final moduleKey = event.moduleName.toLowerCase();

      if (!eventsByDate[dateKey]!.containsKey(moduleKey)) {
        final standardColor = getModuleColor(event.moduleName);
        eventsByDate[dateKey]![moduleKey] = standardColor;
      } else {
      }
    }

    List<Map<String, dynamic>> calendarEvents = [];

    eventsByDate.forEach((date, modulesMap) {
      modulesMap.forEach((moduleName, color) {
        calendarEvents.add({
          'date': date,
          'color': color,
        });
      });
    });

    eventsByDate.forEach((date, modules) {
    });

    return calendarEvents;
  }

  List<CalendarEventModel> getEventsForDate(DateTime date) {
    var filtered = eventDetails.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();

    if (selectedModule != 'All' && selectedModule != 'الكل') {
      final englishModuleName = _getEnglishModuleName(selectedModule);
      final Set<String> wanted = _moduleNamesForChip(englishModuleName);
      filtered = filtered
          .where((event) =>
              wanted.contains(event.moduleName.toLowerCase().trim()))
          .toList();
    }

    if (selectedStatus != 'All' && selectedStatus != 'الكل') {
      final englishStatus = _getEnglishStatusName(selectedStatus);

      if (englishStatus == 'Duration') {
        filtered = filtered.where((event) =>
        event.status.toLowerCase() == 'inprogress' ||
            event.status.toLowerCase() == 'done'
        ).toList();
      } else {
        filtered = filtered.where((event) => event.status == englishStatus).toList();
      }
    }

    return filtered;
  }

  List<Map<String, String>> getUniqueModulesWithMapping() {
    final isArabic = _currentLocale?.languageCode == 'ar';

    final allowedModules = _drawerController.allowedDrawerModules;


    final eventModules = eventDetails.map((e) => e.moduleName.toLowerCase()).toSet();


    List<Map<String, String>> modulesList = [
      {'display': isArabic ? 'الكل' : 'All', 'english': 'All'},
    ];

    final allModulesMap = {
      // 'english' MUST equal AppModule.services.labelEn — see [_chipModuleNames].
      'services': {'display': isArabic ? 'إدارة الخدمات' : 'Service Management', 'english': 'Service Management'},
      'services_app': {'display': isArabic ? 'منشئ النماذج' : 'Form Builder', 'english': 'Form Builder'},
      'formbuilder': {'display': isArabic ? 'منشئ النماذج' : 'Form Builder', 'english': 'Form Builder'},
      'inventory': {'display': isArabic ? 'المخزون' : 'Inventory', 'english': 'Inventory'},
      'database': {'display': isArabic ? 'قاعدة البيانات' : 'Database', 'english': 'Database Management'},
      'events': {'display': isArabic ? 'الأحداث' : 'Events', 'english': 'Events'},
      'tracking': {'display': isArabic ? 'التتبع' : 'Tracking', 'english': 'Tracking'},
      // ADDED 9/10/2026 — Time Tracker phase 6 (`Modules.timeTracker`, which
      // took the legacy tracking slot). 'english' MUST equal
      // AppModule.timeTracker.labelEn — the filter compares it with
      // `event.moduleName`, which `CalendarEventModel.fromType` fills from it.
      'timetracker': {'display': isArabic ? 'تتبع الوقت والحضور' : 'Time Tracker & Attendance', 'english': 'Time Tracker & Attendance'},
      'employees': {'display': isArabic ? 'الموظفين' : 'Org Chart', 'english': 'HR'},
      'knowledgehub': {'display': isArabic ? 'مركز المعرفة' : 'Knowledge Hub', 'english': 'Knowledge Hub'},
      'tasks': {'display': isArabic ? 'المهام' : 'Tasks', 'english': 'Tasks'},
      'todo': {'display': isArabic ? 'قائمة المهام' : 'To-Do List', 'english': 'To-Do List'},
      'grc': {'display': isArabic ? ' الحوكمة و المخاطر و الآلتزام' : 'GRC', 'english': 'GRC'},
      'qiyas': {'display': isArabic ? 'قياس' : 'Qiyas', 'english': 'Qiyas'},
      'messages': {'display': isArabic ? 'الرسائل' : 'Messages', 'english': 'Messages'},
      // One chip, three AppModules — [_chipModuleNames] widens it to all three.
      'roles': {'display': isArabic ? 'إدارة الأدوار' : 'Role Management', 'english': 'Role Management'},
      // ADDED 25/8/2026. `english` must equal `AppModule.settings.labelEn`,
      // because the filter below compares it against `event.moduleName`, which
      // `CalendarEventModel.fromType` fills from exactly that.
      'settings': {'display': isArabic ? 'الإعدادات' : 'Settings', 'english': 'Settings'},
    };

    for (var module in allowedModules) {
      // Home is a drawer destination, not an event source, so it never gets a
      // chip.
      //
      // CHANGED 25/8/2026: Settings used to be skipped alongside it, for the
      // same reason — it raised no calendar entries. It does now (change
      // requests awaiting review, and the requester's own lifecycle), so
      // excluding it left those cards visible under "All" with no way to
      // filter to them.
      //
      // REMOVED 26/8/2026: Modules.employees — the "Org Chart" chip — for the
      // reason Settings used to be skipped. Dropping it here is enough: the
      // chip and the filter it drives are built from this one list. Any Org
      // Chart entry still shows under "All"; it just has no chip of its own.
      if (module == Modules.home || module == Modules.employees) {
        continue;
      }

      String moduleName = module.name.toLowerCase();

      if (allModulesMap.containsKey(moduleName)) {
        modulesList.add(allModulesMap[moduleName]!);
      } else {
      }
    }


    return modulesList;
  }

  Map<String, int> getStatusCounts() {
    Map<String, int> counts = {};

    for (var event in eventDetails) {
      String statusKey;

      if (event.status.toLowerCase() == 'inprogress' ||
          event.status.toLowerCase() == 'done') {
        statusKey = _getLocalizedStatusName('Duration');
      } else {
        statusKey = _getLocalizedStatusName(event.status);
      }

      counts[statusKey] = (counts[statusKey] ?? 0) + 1;
    }

    return counts;
  }

  void _navigateToPreviousMonth() {
    final previousMonth = DateTime(displayedMonth.year, displayedMonth.month - 1, displayedMonth.day);
    setState(() {
      displayedMonth = previousMonth;
      _calendarController.dispose();
      _calendarController = AdvancedCalendarController(previousMonth);
      _calendarKey = UniqueKey();
    });
  }

  void _navigateToNextMonth() {
    final nextMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, displayedMonth.day);
    setState(() {
      displayedMonth = nextMonth;
      _calendarController.dispose();
      _calendarController = AdvancedCalendarController(nextMonth);
      _calendarKey = UniqueKey();
    });
  }

  Widget _statusChip(String count, String status, BuildContext context) {
    bool isSelected = selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: context.isPhone ? 35.sp : 45.sp,
            height: context.isPhone ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: context.isPhone ?
                StyleText.fontSize16Weight500.copyWith(
                  color: isSelected ? AppColors.textButton : AppColors.secondaryText,
                ):

                StyleText.fontSize20Weight500.copyWith(
                  color: isSelected ? AppColors.textButton : AppColors.secondaryText,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            status,
            // REVERTED 21/9/2026 — Settings bug report p.8 ("why the selected
            // disappear?"). The 13/9/2026 change used `AppColors.textButton`
            // here to match the count box, but that colour is for text ON a
            // primary (yellow) fill. This label sits beside the box, on the
            // page background, so in dark mode the selected label was drawn
            // dark-on-dark and vanished. Selected = full-strength text.
            style:
            context.isPhone ?
            StyleText.fontSize14Weight500.copyWith(
              color: isSelected ? AppColors.text : AppColors.secondaryText,
            ):

            StyleText.fontSize16Weight600.copyWith(
              color: isSelected ? AppColors.text : AppColors.secondaryText,
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  MODULE CHIP → EVENT MODULE NAMES        FIXED 30/8/2026
  ///
  ///  `getEventsForDate` filtered with
  ///      `event.moduleName.toLowerCase() == englishModuleName.toLowerCase()`
  ///  where `englishModuleName` is the `'english'` value out of
  ///  [getUniqueModulesWithMapping] and `event.moduleName` is written by
  ///  `CalendarEventModel.fromType` from `AppModule.labelEn`. Those two lists
  ///  were never reconciled — only the entries that happened to spell the
  ///  label identically ever matched:
  ///
  ///      chip 'english'      AppModule.labelEn            matched?
  ///      'Services'          'Service Management'         ✗
  ///      'Roles'             'Role Management'            ✗
  ///      'To Do'             'To-Do List'                 ✗
  ///      'Database'          'Database Management'        ✗
  ///      'Settings'          'Settings'                   ✓
  ///      'Knowledge Hub'     'Knowledge Hub'              ✓
  ///
  ///  which is why picking the Services or the Roles chip emptied the day —
  ///  the events were loaded and sitting under "All", and no chip could
  ///  reach them. (The Settings entry added 25/8/2026 carries a comment
  ///  saying `english` must equal the labelEn; that rule was right and was
  ///  simply never applied to the entries that predate it.)
  ///
  ///  The role area additionally needs a SET rather than a string: Role
  ///  Management, User Access and User Management & Permissions are three
  ///  `AppModule`s sharing one drawer entry and therefore one chip (the same
  ///  grouping `CalendarModulePalette` and `event_card._moduleFor` already
  ///  make), so one chip has to match three labels.
  /// ══════════════════════════════════════════════════════════════════
  static const Map<String, Set<String>> _chipModuleNames =
      <String, Set<String>>{
    // AppModule.roleManagement / userAccess / userManagement.
    'role management': <String>{
      'role management',
      'user access',
      'user management & permissions',
    },
  };

  /// Function Name: [_moduleNamesForChip]
  ///
  /// Purpose: The `event.moduleName` values one chip should show, lowercased.
  ///
  /// Defaults to the chip's own English name, so a chip that maps 1:1 onto an
  /// `AppModule.labelEn` needs no entry in [_chipModuleNames].
  Set<String> _moduleNamesForChip(String englishModuleName) {
    final String key = englishModuleName.toLowerCase().trim();
    return _chipModuleNames[key] ?? <String>{key};
  }

  String _getEnglishModuleName(String localizedName) {
    final moduleMapping = getUniqueModulesWithMapping();

    for (var module in moduleMapping) {
      if (module['display'] == localizedName) {
        return module['english']!;
      }
    }

    return localizedName;
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the cubit publishes: `eventDetails` and `_isLoading` read
    // straight off its state now.
    return BlocBuilder<CalendarCubit, CalendarState>(
      bloc: _calendarCubit,
      builder: (BuildContext context, CalendarState state) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final statusCounts = getStatusCounts();
    final totalEvents = eventDetails.length;
    final isArabic = _currentLocale?.languageCode == 'ar';

    // Same test `SideFrameMasterServices` uses to pick its own branch. It
    // matters here because that branch decides whether this page is handed a
    // bounded height — see the note on the view switch at the end of this
    // method.
    final bool isMobile = MediaQuery.sizeOf(context).width < 600;

    // FIXED 7/10/2026: this used to be a local copy of the [statusTypes]
    // getter WITHOUT 'Frequency', shadowing it — so the recurring To-Do
    // entries (statusCode 'Frequency') had no status chip and showed only
    // under "All". The getter is the single list now.
    final List<String> statusTypes = this.statusTypes;

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).home,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).calendar,
          // FIXED 12/9/2026 — the spinner sat at the TOP of the page while
          // the calendar loaded, instead of in the middle of it.
          //
          // `Center` only centres inside the space it is given, and on mobile
          // `SideFrameMasterServices` puts its child in a
          // `SingleChildScrollView` (see the note on the view switch below).
          // That hands the child an infinite height, so the Center shrink-
          // wrapped to the spinner and landed wherever the content started —
          // the top. Nothing was wrong with the Center; it simply had no
          // height to centre within.
          //
          // The bounded box is what gives it one. 70% of the screen is very
          // close to the frame's actual scroll viewport once its fixed
          // breadcrumb header and the bottom nav bar are taken out, so the
          // spinner reads as centred without this file having to measure a
          // viewport it cannot see from in here.
          //
          // Tablet and desktop get a bounded height from the frame already,
          // so they keep the plain Center. The Column wrapper is gone either
          // way — one child, and `Center` was already doing its job.
          child: _isLoading
              ? (isMobile
                  ? SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.7,
                      child: Center(child: CircleProgressMaster()),
                    )
                  : Center(child: CircleProgressMaster()))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                height: 55.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statusTypes.map((status) {
                      final count = status == (isArabic ? 'الكل' : 'All')
                          ? _toArabicNumber(totalEvents)
                          : _toArabicNumber(statusCounts[status] ?? 0);

                      return _statusChip(count, status, context);
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 38.h,

                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: getUniqueModulesWithMapping().map((moduleMap) {
                      final displayName = moduleMap['display']!;
                      final englishName = moduleMap['english']!;

                      final isSelected = selectedModule == displayName || selectedModule == englishName;
                      final moduleColor = getModuleColor(englishName);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedModule = displayName;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: moduleColor,
                                borderRadius: BorderRadius.circular(4.r),
                                // ADDED 13/9/2026 — selection was signalled by
                                // the LABEL going bold, which reflows the chip
                                // (bold is wider), so picking a filter nudged
                                // every chip after it sideways. The border is
                                // always present and always the same width; it
                                // only changes colour, so nothing moves.
                                //
                                // Unselected it is the chip's own fill, so it
                                // is invisible and the chip looks exactly as
                                // it does today. Selected it is
                                // AppColors.secondaryText, which reads against
                                // every colour in CalendarModulePalette.
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secondaryText
                                      : moduleColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.sp),
                        // FIXED 12/9/2026 — "RenderFlex overflowed by 114
                        // pixels on the right".
                        //
                        // The month name was a bare `Text` — no flex, no
                        // ellipsis — so this Row's minimum width was the full
                        // "September 2026" plus both chevrons, whatever the
                        // Expanded above could actually spare. On a phone that
                        // share is about 200pt and the content wanted ~315.
                        //
                        // `Expanded` on the Text does the job the `Spacer` was
                        // doing (push the chevrons to the trailing edge) AND
                        // makes the label the part that yields, so a long
                        // month in either language ellipsises rather than
                        // pushing the arrows off-screen. `mainAxisSize.min`
                        // went with the Spacer — it never applied, since a
                        // flex child makes the Row take all the width anyway.
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('MMMM yyyy', _currentLocale?.languageCode).format(displayedMonth),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.sp),
                            GestureDetector(
                              onTap: _navigateToPreviousMonth,
                              child: SizedBox(
                                child: CustomSvgImage(
                                  assetPath: isArabic
                                      ? "assets/icons_assets/calendar_assets/chevron_right.svg"
                                      : "assets/icons_assets/calendar_assets/chevron_left.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            GestureDetector(
                              onTap: _navigateToNextMonth,
                              child: SizedBox(
                                child: CustomSvgImage(
                                  assetPath: isArabic
                                      ? "assets/icons_assets/calendar_assets/chevron_left.svg"
                                      : "assets/icons_assets/calendar_assets/chevron_right.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: isMobile ? 8.sp : 15.sp),

                  // CHANGED 24/8/2026: was the bespoke `CalendarViewToggle`.
                  // The shared `CustomSegmentedTabs` does the same job and is
                  // what the rest of the app uses, so the switch here now
                  // matches every other tab strip in the product.
                  //
                  // Index 0 is Day and index 1 is Month, in that order. The
                  // Row inside CustomSegmentedTabs is direction-aware, so in
                  // Arabic the framework mirrors it — no manual RTL flip like
                  // the old widget carried.
                  SizedBox(
                    // 240 is a desktop measurement: on a 402pt phone it is
                    // ~257pt of the ~372 this row has, leaving the month label
                    // beside it too little to render. "Day" and "Month" are
                    // short enough to stay legible at 150.
                    width: isMobile ? 150.w : 240.w,
                    height: 40.h,
                    child: CustomSegmentedTabs(
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color:  AppColors.textButton
                      ),
                      tabs: [
                        isArabic ? 'يوم' : 'Day',
                        isArabic ? 'شهر' : 'Month',
                      ],
                      selectedIndex:
                          currentViewMode == CalendarViewMode.month ? 1 : 0,
                      onTabSelected: (index) {
                        setState(() {
                          currentViewMode = index == 1
                              ? CalendarViewMode.month
                              : CalendarViewMode.day;
                        });
                      },
                      equalWidth: true,
                      containerColor: AppColors.card,
                      unselectedColor: AppColors.card,
                      selectedColor: AppColors.primary,
                      selectedTextColor: AppColors.textButton,
                      unselectedTextColor: AppColors.secondaryText,
                      borderRadius: 8.r,
                      // ADDED 13/9/2026 — "Day" / "Month" rendered smaller
                      // than the 14.sp asked for above, on mobile only.
                      //
                      // CustomSegmentedTabs wraps each label in a FittedBox,
                      // which SHRINKS the text to whatever the tab box allows.
                      // The binding constraint was vertical, not horizontal:
                      // 40.h minus the container padding top and bottom minus
                      // the tab's own default 6.sp pair left about 12pt of
                      // line box, and 14.sp needs 14 — so the FittedBox scaled
                      // it down by roughly 15%.
                      //
                      // Trimming the TAB's own padding on mobile gives the
                      // line the room it needs and the FittedBox then leaves
                      // the size alone. Null on desktop keeps the widget's
                      // 6.sp default; containerPadding below is untouched.
                      tabVerticalPadding: isMobile ? 2.sp : null,
                      containerPadding: EdgeInsets.symmetric(horizontal: 8.sp,vertical: 8.sp),
                      spacing: 4.sp,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // FIXED 12/9/2026 — "RenderFlex children have non-zero flex
              // but incoming height constraints are unbounded", thrown the
              // moment this screen opened on a phone.
              //
              // `SideFrameMasterServices` lays its child out differently by
              // form factor: on tablet and desktop the child sits in a
              // bounded box, but its MOBILE branch puts it inside a
              // `SingleChildScrollView` (50-custom_side_frame_master.dart),
              // which hands its child an INFINITE height. `Expanded` means
              // "fill the space left over", and there is no such thing inside
              // a scroll view — so the whole page failed to lay out, which is
              // why the second assertion ("RenderBox was not laid out") came
              // straight after.
              //
              // The two layouts below are therefore genuinely different, not
              // just narrower: the desktop pair fill a bounded parent, the
              // mobile pair size themselves so the frame's scroll view has
              // something finite to scroll.
              if (isMobile)
                currentViewMode == CalendarViewMode.month
                    ? _buildMonthViewMobile()
                    : _buildDayViewMobile()
              else
                Expanded(
                  child: currentViewMode == CalendarViewMode.month
                      ? _buildMonthView()
                      : _buildDayView(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// The calendar card's inner padding — 15 on all four sides.
  ///
  /// REPLACED the measured inset of 24/8/2026. That version matched the top and
  /// bottom to the gap the seven centred day columns already create at the
  /// sides (~60px on a desktop window). It was symmetric, and far too tall: the
  /// day view in particular became a thin week strip floating in a deep empty
  /// band.
  ///
  /// A flat 15 is what the rest of the app's cards use. The side gap is still
  /// wider than 15 because the columns centre their contents — that is the grid
  /// working as intended, not padding to be compensated for.
  static const double _calendarPadding = 15.0;

  /// The month / day grid itself.
  ///
  /// EXTRACTED 12/9/2026. Four call sites now need it — month and day, each in
  /// a bounded and a self-sizing flavour — and it was already duplicated
  /// verbatim between the first two but for `viewMode`. `_calendarKey` being
  /// shared is safe: exactly one of the four is built at a time.
  Widget _advancedCalendar(CalendarViewMode mode) {
    return AdvancedCalendar(
      backgroundColorCalender: AppColors.card,
      key: _calendarKey,
      controller: _calendarController,
      events: events,
      showNavigationArrows: false,
      startWeekDay: 1,
      weekLineHeight: 48.0,
      // ADDED 13/9/2026 — the DAY strip only. 48 is a month-grid row
      // height: it has to separate six stacked weeks. A single strip
      // holds a 24px date box plus one 8px dot row, so at 48 a third of
      // it was empty card under the numbers. The month grid keeps 48.
      dayStripLineHeight: 36.0,
      innerDot: false,
      viewMode: mode,
      // `.sp` on both axes: `15.w` and `15.h` are different pixel counts, so a
      // symmetric() built from them is not square.
      contentPadding: EdgeInsets.all(_calendarPadding.sp),
      onHorizontalDrag: (DateTime date) {
        setState(() {
          displayedMonth = date;
        });
      },
    );
  }

  /// The selected day's events.
  ///
  /// [shrinkWrap] is what separates the two parents: inside a bounded box the
  /// list scrolls itself, and inside the mobile frame's scroll view it must
  /// size to its content and let the PAGE scroll — two scrollables on one axis
  /// would fight, and an unbounded self-scrolling list cannot lay out at all.
  Widget _dayEventsList({required bool shrinkWrap}) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _calendarController,
      builder: (context, selectedDate, _) {
        final dayEvents = getEventsForDate(selectedDate);

        if (dayEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                CustomSvgImage(
                  assetPath:
                      "assets/icons_assets/calendar_assets/calendar_desk_illustration.svg",
                  width: 250.w,
                  height: 250.h,
                  fit: BoxFit.fill,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          itemCount: dayEvents.length,
          itemBuilder: (context, index) {
            return EventCard(event: dayEvents[index]);
          },
        );
      },
    );
  }

  /// Month view, tablet and desktop: grid on the left, the day's events in a
  /// fixed 400 column on the right. Needs a bounded height from its parent.
  Widget _buildMonthView() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _advancedCalendar(CalendarViewMode.month),
            ],
          ),
        ),

        SizedBox(width: 10.sp),

        Container(
          width: 400.w,
          decoration: BoxDecoration(
            color: AppColors.background,
          ),
          child: _dayEventsList(shrinkWrap: false),
        ),
      ],
    );
  }

  /// Month view, phone: the same two pieces STACKED.
  ///
  /// Not merely a narrower version of [_buildMonthView] — that one is a Row
  /// whose right-hand column is a hard `400.w`, which on a 402pt phone is
  /// wider than the screen on its own, before the grid beside it. Stacking is
  /// the only arrangement that fits, and it makes the whole thing
  /// intrinsic-height, which is what the frame's scroll view needs.
  Widget _buildMonthViewMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _advancedCalendar(CalendarViewMode.month),
        SizedBox(height: 16.h),
        _dayEventsList(shrinkWrap: true),
      ],
    );
  }

  /// Day view, tablet and desktop: week strip above, timeline filling the rest.
  Widget _buildDayView() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _calendarController,
      builder: (context, selectedDate, _) {
        final dayEvents = getEventsForDate(selectedDate);

        return Column(
          children: [
            _advancedCalendar(CalendarViewMode.day),

            SizedBox(height: 16.h),

            Expanded(
              child: DayTimelineView(
                selectedDate: selectedDate,
                events: dayEvents,
                // The phone already shows a screen title, the Day/Month
                // toggle and the week strip above this; a fourth header bar
                // is chrome between the user and the schedule.
                showHeader: false,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Day view, phone.
  ///
  /// `DayTimelineView` puts its own list in an `Expanded`, so it only lays out
  /// inside a bounded height — the exact constraint this page could not give
  /// it on mobile. It gets a window of its own here and scrolls within it.
  /// A fixed window rather than a shrink-wrap on purpose: the timeline is
  /// forty-eight half-hour rows whatever the day holds, so letting it size to
  /// its content would bury the calendar under a screen and a half of empty
  /// slots.
  Widget _buildDayViewMobile() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _calendarController,
      builder: (context, selectedDate, _) {
        final dayEvents = getEventsForDate(selectedDate);

        return Column(
          children: [
            _advancedCalendar(CalendarViewMode.day),

            SizedBox(height: 16.h),

            SizedBox(
              height: 420.h,
              child: DayTimelineView(
                selectedDate: selectedDate,
                events: dayEvents,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _calendarCubit.close();
    _calendarController.dispose();
    super.dispose();
  }
}

