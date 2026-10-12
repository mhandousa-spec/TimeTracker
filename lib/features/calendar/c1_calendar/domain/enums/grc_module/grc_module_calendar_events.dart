/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: grc_module_calendar_events.dart
/// Module:    GRC / Module
/// Purpose:   Every calendar entry the GRC Module section places on the
///            calendar — all three driven by a module's activation date.
/// Author: Knowticed Plus team
/// Created at: 13/9/2026
///
/// SOURCE: "Knowticed Plus — Notification & Validation", GRC Module rows of
/// the calendar table. The document's own scheduling notes are reproduced in
/// each entry's [schedulingNote].
///
/// SOURCE FIELD: `Module_Activation_Date` on the GRC module document, which is
/// a history list — which is the only reason [activationDateUpdated] can
/// exist. The builder detects a change by comparing the last two entries, the
/// same trick `role_management_calendar_events` uses for its access window.
///
/// The notification module's `grc_events.dart` has its own
/// `activation_date_updated` / `activation_date_today`; these are the calendar
/// twins, not duplicates — one puts a card on a date, the other pushes a
/// message.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum GrcModuleCalendarEvent implements CalendarEventType {
  /// "Calendar entry is created immediately after saving the Activation Date.
  /// Appears on the activation date."
  activationDateDefined(
    key: 'module_activation_date_defined',
    scope: 'GRC Module',
    trigger: 'Module Activation Date Defined',
    titleEn: 'Module Activation Date Defined',
    titleAr: 'تم تحديد تاريخ تفعيل الوحدة',
    descriptionEn: '{{moduleName}} will Activation on {{activationDate}}',
    descriptionAr:
        'سيتم تفعيل الوحدة {{moduleName}} بتاريخ {{activationDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.moduleName, TemplateVariable.activationDate},
    schedulingNote:
        'Placed on the activation date itself. Emitted whenever a module has '
        'an activation date, including retrospectively for modules already '
        'activated — the same unconditional rule as accessGrantedImmediate.',
  ),

  /// "Calendar reminder appears 14 days before the activation date."
  activationIn14Days(
    key: 'module_activation_in_14_days',
    scope: 'GRC Module',
    trigger: 'Module Activation in 14 Days',
    titleEn: 'Module Activation in 14 Days',
    titleAr: 'تفعيل الوحدة خلال ١٤ يوماً',
    descriptionEn: '{{moduleName}} will be activated on {{activationDate}}.',
    descriptionAr:
        'سيتم تفعيل الوحدة {{moduleName}} بتاريخ {{activationDate}}.',
    statusCode: 'Reminder',
    colorValue: 0xFFB5AF3D,
    // NEGATIVE, because dateFor() ADDS this to the source date: the card must
    // land 14 days BEFORE the activation date it is warning about.
    reminderOffsetDays: -14,
    variables: {TemplateVariable.moduleName, TemplateVariable.activationDate},
    schedulingNote:
        'Placed 14 days before the activation date. The builder skips it when '
        'that day has already passed, so a module created inside its own '
        '14-day window does not get a reminder dated in the past.',
  ),

  /// "Existing calendar event is updated automatically to reflect the new
  /// activation date."
  activationDateUpdated(
    key: 'module_activation_date_updated',
    scope: 'GRC Module',
    trigger: 'Module Activation Date Updated',
    titleEn: 'Module Activation Date Updated',
    titleAr: 'تم تحديث موعد تفعيل الوحدة',
    descriptionEn:
        '{{moduleName}} activation date updated from {{oldActivationDate}} to {{newActivationDate}}.',
    descriptionAr:
        'تم تحديث موعد تفعيل الوحدة {{moduleName}} من {{oldActivationDate}} إلى {{newActivationDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.moduleName,
      TemplateVariable.oldActivationDate,
      TemplateVariable.newActivationDate,
    },
    schedulingNote:
        'Placed on the NEW activation date. The document says the existing '
        'entry is "updated automatically" — because this calendar derives '
        'entries from the module document on every read rather than storing '
        'them, that happens by construction: the old date is no longer the '
        'last history entry, so its cards simply stop being produced.',
  );

  const GrcModuleCalendarEvent({
    required this.key,
    required this.scope,
    required this.trigger,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.statusCode,
    required this.colorValue,
    required this.reminderOffsetDays,
    required this.variables,
    required this.schedulingNote,
  });

  @override
  final String key;
  @override
  final String scope;
  @override
  final String trigger;
  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String descriptionEn;
  @override
  final String descriptionAr;
  @override
  final String statusCode;
  @override
  final int colorValue;
  @override
  final int reminderOffsetDays;
  @override
  final Set<TemplateVariable> variables;
  @override
  final String schedulingNote;

  @override
  AppModule get module => AppModule.grc;

  @override
  String get id => '${module.key}_$key';

  static GrcModuleCalendarEvent? fromKey(String key) {
    for (final GrcModuleCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
