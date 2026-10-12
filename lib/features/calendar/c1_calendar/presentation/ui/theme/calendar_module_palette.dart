/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_module_palette.dart
/// Purpose: The colour that identifies each module in the calendar.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Added for CR-SKEL-CAL-N11. `getModuleColor` was duplicated verbatim in
/// `home_calendar_page.dart` and `calendar_screen.dart`, each with sixteen
/// inline `Color(0xFF…)` literals — thirty-two literals for sixteen colours,
/// which is how the two copies could drift without anyone noticing.
///
/// These are theme-independent on purpose: a module's colour is its identity,
/// the same in light and dark, and it has to match the legend and the dots.

import 'dart:ui';

import 'package:knowticed_plus/core/theme/app_colors.dart';

abstract final class CalendarModulePalette {
  const CalendarModulePalette._();

  static const Color approvals = Color(0xFFFF814A);
  static const Color services = Color(0xFF0095FF);
  static const Color formBuilder = Color(0xFF4BB609);
  static const Color inventory = Color(0xFFDF1C1C);
  static const Color qiyas = AppColors.calendarEventQiyas;
  static const Color timeTracker = Color(0xFFFF814A);
  static const Color database = Color(0xFFBE8F3D);
  static const Color events = Color(0xFF586E73);
  static const Color riskRegister = Color(0xFF3DA282);
  static const Color tasks = Color(0xFFFFCD00);
  static const Color grc = Color(0xFFB5AF3D);
  static const Color hr = Color(0xFF405162);
  static const Color knowledgeHub = AppColors.calendarEventServices;
  /// DARKENED 26/8/2026: was 0xFF7B68EE, a light blue-violet that read as a
  /// near-twin of [settings] on the chip row. Indigo 800 — dark, and far
  /// enough from [services] (bright blue) to survive at dot size.
  static const Color messages = Color(0xFF283593);
  static const Color roles = Color(0xFFE91E63);

  /// ADDED 25/8/2026 with the settings change-request entries. Violet, chosen
  /// because it is the one hue not already spoken for — the nearest neighbours
  /// are [messages] and [roles] (0xFFE91E63, pink), and a change-request dot
  /// has to be told apart from both at dot size.
  ///
  /// DARKENED 26/8/2026: was 0xFF8E5BD6. Deep purple 800 — still the same hue
  /// family, so the dots and the legend keep their meaning, just dark enough
  /// to sit apart from [messages] rather than beside it.
  ///
  /// ⚠️ Must match `SettingsCalendarEvent.colorValue`, which is a separate
  /// literal in settings_calendar_events.dart — change one and the chip and
  /// the event card disagree.
  static const Color settings = Color(0xFF4527A0);
  static const Color todo = Color(0xFF00BCD4);

  /// Shown for the "All" filter and for any module with no colour of its own.
  static const Color fallback = services;

  /// Module keys, English and Arabic, mapped to their colour. The names are
  /// matched lowercased and trimmed, exactly as the two `switch` statements did.
  static const Map<String, Color> _byName = <String, Color>{
    'approval': approvals,
    'approvals': approvals,
    'الموافقات': approvals,

    'service': services,
    'services': services,
    'الخدمات': services,
    // ADDED 30/8/2026. Services events arrive under AppModule.services.labelEn
    // ('Service Management'), which none of the three keys above matched — the
    // module fell through to [fallback]. Harmless only by accident, because
    // [fallback] IS the services blue; any change to [fallback] would have
    // silently recoloured every service card.
    'service management': services,
    'إدارة الخدمات': services,

    'form': formBuilder,
    'services_app': formBuilder,
    'form builder': formBuilder,
    'منشئ النماذج': formBuilder,

    'inventory': inventory,
    'المخزون': inventory,

    'qiyas': qiyas,
    'قياس': qiyas,

    'time_tracker': timeTracker,
    'time tracker': timeTracker,
    'tracking': timeTracker,
    'التتبع': timeTracker,
    // AppModule.timeTracker.labelEn / labelAr — what the phase-6 Time
    // Tracker cards carry. ADDED 9/10/2026.
    'time tracker & attendance': timeTracker,
    'تتبع الوقت والحضور': timeTracker,

    'database': database,
    // AppModule.database.labelEn. ADDED 30/8/2026.
    'database management': database,
    'قاعدة البيانات': database,

    'events': events,
    'event': events,
    'الأحداث': events,

    'risk_register': riskRegister,
    'risk register': riskRegister,

    'task': tasks,
    'tasks': tasks,
    'المهام': tasks,

    'grc': grc,
    ' الحوكمة و المخاطر و الآلتزام': grc,

    'hr': hr,
    'employees': hr,
    'org chart': hr,
    'الموظفين': hr,

    'knowledge_hub': knowledgeHub,
    'knowledge hub': knowledgeHub,
    'مركز المعرفة': knowledgeHub,

    'messages': messages,
    'الرسائل': messages,

    'roles': roles,
    'الصلاحيات': roles,

    // The three role-area modules — Role Management, User Access and User
    // Management — share one drawer entry, one glyph and one identity colour
    // (see event_card._moduleFor, which maps all three to Modules.roles).
    // Their calendar events arrive here under AppModule.labelEn ('Role
    // Management', 'User Access', 'User Management & Permissions'), none of
    // which the two keys above match — so before this they fell through to
    // [fallback] (services blue) while their icon drew in [roles] pink. Keyed
    // by the lowercased labelEn (what actually arrives), plus the snake_case
    // key and the Arabic label for parity with every other entry. ADDED
    // 28/8/2026.
    'role management': roles,
    'role_management': roles,
    'إدارة الأدوار': roles,

    'user access': roles,
    'user_access': roles,
    'وصول المستخدمين': roles,

    'user management & permissions': roles,
    'user_management': roles,
    'إدارة المستخدمين والصلاحيات': roles,

    'todo': todo,
    'to do': todo,
    // AppModule.todo.labelEn. ADDED 30/8/2026, same reason as
    // 'service management' above.
    'to-do list': todo,
    'قائمة المهام': todo,

    // `CalendarEventModel.fromType` names the module from
    // `AppModule.settings.labelEn`, so the lookup arrives as 'settings'. The
    // Arabic label is here for the same reason every other entry has one: the
    // module chips are built in the active language and matched back through
    // this map.
    'settings': settings,
    'الإعدادات': settings,
  };

  /// Function Name: [colorOf]
  ///
  /// Purpose: The colour for a module name, in either language.
  ///
  /// Returns [fallback] for an unknown module — which is what both copies of
  /// `getModuleColor` did in their `default` branch.
  static Color colorOf(String moduleName) {
    final String key = moduleName.toLowerCase().trim();
    // "All" is not a module — it is the chip that clears the filter, so it
    // wears the app's own primary rather than a colour from the module set.
    // CHANGED 26/8/2026: was AppColors.blue, which is a fixed blue and read as
    // just another module colour next to Services.
    if (key == 'all' || key == 'الكل') return AppColors.primary;
    return _byName[key] ?? fallback;
  }
}
