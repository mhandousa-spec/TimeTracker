/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: event_card.dart
/// Purpose: One event row in the calendar lists.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N13: `package:get` removed; the module palette is shared.
/// Updated: 26/8/2026 - Title + time lifted out of the card into a header row;
///          module glyphs now come from `Modules.iconPathRole`; an event that
///          names an account shows that person's FULL name.
/// Updated: 7/10/2026 - To-Do cards are tappable (open that to-do's details)
///          through the shared `CalendarEventTap`. This is the card of the
///          month view — the view the calendar opens in — which had no tap.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/theme/calendar_module_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/calendar_event_tap.dart';

// `package:get` re-added 26/8/2026, after CR-SKEL-CAL-N13 removed it. The full
// account name has to be looked up by email, and MainCoreEmployeeController is
// a GetX singleton put in main.dart — there is no injected route into this
// widget. The lookup is guarded by Get.isRegistered, so nothing here breaks if
// it is ever unregistered.
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

/// Single calendar event card, extracted from calendar_screen.dart.
class EventCard extends StatelessWidget {
  final CalendarEventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  /// Delegates to the shared palette (CR-SKEL-CAL-N11).
  Color _getModuleColor(String moduleName) =>
      CalendarModulePalette.colorOf(moduleName);

  @override
  Widget build(BuildContext context) {
    final moduleColor = _getModuleColor(event.moduleName);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ Extract bilingual task name
    String displayTaskName = event.taskName;
    if (event.taskName.contains(' / ')) {
      final parts = event.taskName.split(' / ');
      displayTaskName = isArabic && parts.length > 1 ? parts[1] : parts[0];
    }
    displayTaskName = _resolveTitle(displayTaskName);

    // ✅ Extract bilingual description
    String displayDescription = event.description;
    if (event.description.contains(' / ')) {
      final parts = event.description.split(' / ');
      displayDescription = isArabic && parts.length > 1 ? parts[1] : parts[0];
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.sp),
      // Inside the margin, so the 10 gap between two cards is not a tap target.
      child: CalendarEventTap(
        event: event,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header: title + time, OUTSIDE the card ───────────────────────
            // CHANGED 26/8/2026. The title used to sit inside the card sharing a
            // line with the status chip, and the time was a Stack child pinned
            // to the card's bottom-right — floating, so it took no space of its
            // own and could land on top of a two-line description. Both now sit
            // on one row above the card, which is why the Stack is gone.
            Padding(
              padding: EdgeInsets.only(left: 4.sp, right: 4.sp, bottom: 6.sp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      displayTaskName,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    event.time,
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // ── The card ─────────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: moduleColor, width: 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: moduleColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CustomSvgImage(
                            assetPath: _moduleIconPath(event.moduleName),
                            width: 24,
                            height: 24,
                            color: moduleColor,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 5.sp),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Show description
                        Expanded(
                          child: Text(
                            displayDescription,
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.sp, vertical: 4.sp),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            event.status,
                            style: StyleText.fontSize10Weight500.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Function Name: [_resolveTitle]
  ///
  /// Purpose: The header title, with an account event resolved to the person's
  /// FULL name.
  ///
  /// ADDED 26/8/2026. Account events — User Access activations and
  /// deactivations, the account-status alerts — arrive with
  /// [CalendarEventModel.taskName] set to whatever short label the builder had
  /// to hand, which for those is the first name alone ("demo").
  /// [CalendarEventModel.userEmail] rides on the same record, so the full
  /// "first last" is one lookup away.
  ///
  /// Falls back to [fallback] whenever there is no email on the event, no
  /// employee behind that email, or the controller is not registered — a card
  /// must never blank its own title over a failed lookup.
  ///
  /// [FormatHelper.capitalize] is applied either way, so a name stored
  /// lower-case renders as "Demo Company" rather than "demo company".
  String _resolveTitle(String fallback) {
    // Opt-in (13/9/2026). This used to fire for ANY event carrying a
    // userEmail, and nearly every event carries one — it is the owner of the
    // record, not the subject of the title. So a GRC module card and a Role
    // Management card both showed the signed-in user's name instead of the
    // module / role they are about. Only events that set
    // [titleIsPersonName] have a person's name as their title.
    if (!event.titleIsPersonName) return FormatHelper.capitalize(fallback);

    final String email = event.userEmail?.trim() ?? '';
    if (email.isEmpty) return FormatHelper.capitalize(fallback);

    if (!Get.isRegistered<MainCoreEmployeeController>()) {
      return FormatHelper.capitalize(fallback);
    }

    final String fullName =
        Get.find<MainCoreEmployeeController>().getEmployeeName(email).trim();

    // "no name" is the controller's sentinel for an address with no employee
    // behind it.
    if (fullName.isEmpty || fullName == 'no name') {
      return FormatHelper.capitalize(fallback);
    }
    return FormatHelper.capitalize(fullName);
  }

  /// Function Name: [_moduleIconPath]
  ///
  /// Purpose: The glyph for the module this event belongs to.
  ///
  /// CHANGED 26/8/2026: reads [Modules.iconPathRole], not `iconPath`. That is
  /// the set the rest of the app draws module glyphs from, so the calendar now
  /// shows the same picture for a module as the sidebar and the role screens
  /// do, and a new module needs no change here.
  String _moduleIconPath(String moduleName) =>
      _moduleFor(moduleName).iconPathRole;

  /// Function Name: [_moduleFor]
  ///
  /// Purpose: Resolve the module behind [moduleName].
  ///
  /// [moduleName] is not one vocabulary: depending on which builder produced
  /// the event it is either a DISPLAY label ("Org Chart", "Knowledge Hub") or
  /// a snake_case key ("time_tracker", "user_access").
  ///
  /// Order matters. The alias table comes FIRST because it records choices the
  /// calendar makes deliberately and the enum would otherwise override —
  /// 'hr' and 'events' both name real [Modules] values, but this module has
  /// always filed them under Org Chart and Qiyas, and an enum-first lookup
  /// would silently repoint them. Everything the aliases do not claim is then
  /// asked of the enum itself, so adding a module to [Modules] needs no change
  /// here at all.
  ///
  /// REPLACED 26/8/2026 a hand-written switch that listed every module by
  /// hand, sent everything unknown to [Modules.services], and had no case at
  /// all for Settings, User Access or Org Chart — which is why those events
  /// drew the support-headset glyph.
  Modules _moduleFor(String moduleName) {
    final String key = moduleName.trim().toLowerCase().replaceAll(' ', '_');
    if (key.isEmpty) return Modules.services;

    switch (key) {
      case 'approval':
      case 'approvals':
      case 'service':
        return Modules.services;
      case 'form':
      case 'services_app':
        return Modules.formBuilder;
      case 'event':
      case 'events':
        return Modules.qiyas;
      case 'time_tracker':
        return Modules.tracking;
      // AppModule.timeTracker.labelEn ('Time Tracker & Attendance') — what
      // CalendarEventModel.fromType writes. ADDED 9/10/2026 (phase 6).
      case 'time_tracker_&_attendance':
        return Modules.timeTracker;
      case 'hr':
      case 'org_chart':
      case 'organization_chart':
        return Modules.employees;
      case 'task':
        return Modules.tasks;
      // AppModule.todo.labelEn ('To-Do List') — neither the enum id ('todo')
      // nor its display name ('Todo') matches it. ADDED 7/10/2026.
      case 'to-do_list':
      case 'to_do_list':
      case 'to_do':
        return Modules.todo;
      case 'risk_register':
        return Modules.grc;
      // The three role-area vocabularies all live under one drawer module.
      case 'user_access':
      case 'user_management':
      case 'role_management':
        return Modules.roles;
    }

    // The enum's own identifier. Underscores are stripped from the key so
    // 'form_builder' meets `Modules.formBuilder`.
    final String squashed = key.replaceAll('_', '');
    for (final Modules module in Modules.values) {
      if (module.name.toLowerCase() == squashed) return module;
    }

    // The enum's display name, which is what most builders pass. It is
    // locale-dependent, so this can miss in an Arabic session; the alias table
    // above is what catches the ones that matter.
    for (final Modules module in Modules.values) {
      if (module.getModuleName.trim().toLowerCase().replaceAll(' ', '_') ==
          key) {
        return module;
      }
    }

    return Modules.services;
  }
}
