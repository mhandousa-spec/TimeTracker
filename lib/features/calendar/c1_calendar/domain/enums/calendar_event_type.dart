/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_event_type.dart
/// Purpose: The kinds of event the calendar can show.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: calendar_event_type.dart
/// Purpose:   The contract every per-module calendar event enum
///            implements, so CalendarCatalog can walk all modules without
///            knowing any of them.
///
/// One file per module in `<module>_module/<module>_calendar_events.dart`,
/// mirroring the notification side
/// (`notification/domain/enums/<module>_module/`). Both reuse the same
/// [AppModule] keys so a calendar entry and the notification it
/// accompanies always agree on which module they belong to.
///
/// Named `CalendarEventType` rather than `CalendarEvent` to avoid colliding
/// with `CalendarEventModel`, which is the runtime *instance* placed on the
/// calendar. This enum is the *kind* of entry; the model is one occurrence
/// of it with a real date and recipient.

import 'dart:ui';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

abstract interface class CalendarEventType {
  /// Stable key, unique inside the module.
  String get key;

  /// `<module>_<key>` — stable identifier for a calendar entry, so an
  /// existing entry can be found and rescheduled instead of duplicated
  /// when the underlying date changes.
  String get id;

  /// Which module owns this entry.
  AppModule get module;

  /// Sub-area inside the module (e.g. 'Policy', 'Control Champion').
  String get scope;

  /// The spec's trigger wording, e.g. 'Policy Expires in 14 Days'.
  String get trigger;

  String get titleEn;
  String get titleAr;

  /// Card body. May contain `{{camelCase}}` placeholders — render it with
  /// `description(isArabic: ..., variables: ...)`, never by hand.
  String get descriptionEn;
  String get descriptionAr;

  /// ⚠️ ENGLISH ONLY, and never translated at the source.
  ///
  /// `CalendarEventModel.status` is compared as a string by the calendar
  /// screen's filter chips (`event.status == englishStatus`, plus
  /// `.toLowerCase() == 'inprogress' / 'done'`), so a localised status
  /// silently breaks filtering in Arabic. Display translation happens in
  /// `_getLocalizedStatusName`. Empty means "not surfaced as a filterable
  /// status yet" — the title is used instead.
  String get statusCode;

  /// Chip / dot colour as an ARGB int, so the enum stays a pure `dart:ui`
  /// value with no Material dependency.
  int get colorValue;

  /// Days relative to the source date the entry should surface on.
  /// `0` = on the date itself, `-14` = the two-week advance reminder.
  int get reminderOffsetDays;

  /// The spec's "Scheduling & Logic Notes" column — kept verbatim so the
  /// rule behind an entry is readable next to the code that implements it.
  String get schedulingNote;

  /// Placeholders used by the title and description.
  Set<TemplateVariable> get variables;
}

extension CalendarEventTypeX on CalendarEventType {
  Color get color => Color(colorValue);

  String title({required bool isArabic}) => isArabic ? titleAr : titleEn;

  /// Rendered card body with `{{placeholders}}` substituted.
  String description({
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
  }) {
    var text = isArabic ? descriptionAr : descriptionEn;
    variables.forEach((v, value) => text = text.replaceAll(v.token, value));
    return text;
  }

  /// The value to put in `CalendarEventModel.status`: the English filter
  /// code when one is defined, otherwise the English title.
  String get status => statusCode.isEmpty ? titleEn : statusCode;

  /// True when this entry is an advance reminder rather than the event day.
  bool get isReminder => reminderOffsetDays != 0;

  /// The date this entry should appear on, given the underlying source date
  /// (the publish date, the SLA deadline, the access start date, ...).
  DateTime dateFor(DateTime sourceDate) =>
      sourceDate.add(Duration(days: reminderOffsetDays));
}
