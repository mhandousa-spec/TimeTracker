/// Module: time_tracker / tt5_locations / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: location_text.dart
/// Purpose: Declares `LocationText` — the localized values of one location
///          shared by the table, the phone cards, the details page and
///          Export — and `LocationStatusText` (Active green / Inactive red).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Inventory §H4 columns (Figma `661:37368`) with the owner additions (work
/// hours, working days) and the radius instead of "Geofencing Area".
/// Numbers / dates / times localized (`LocalizedNumber`, `TimeTrackerFormat`).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/main_helper/location_data_service.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationText {
  const LocationText._();

  static bool _ar(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// The name in the app language.
  static String name(BuildContext context, WorkLocation l) =>
      l.name(isArabic: _ar(context));

  // ── Address (9/10/2026: dropdown codes → label in the app language) ───────

  static String _labelOf(BuildContext context, List<LocationOption> options,
      bool Function(LocationOption o) match, String stored) {
    if (stored.trim().isEmpty) return TimeTrackerFormat.dash;
    for (final LocationOption o in options) {
      if (match(o)) return o.label(_ar(context));
    }
    // Unknown code / data not loaded yet: show what is stored, never blank.
    return stored.trim();
  }

  /// The country (stored as ISO-2) in the app language.
  static String country(BuildContext context, WorkLocation l) => _labelOf(
        context,
        LocationDataService.instance.countries(context),
        (LocationOption o) => o.code.toUpperCase() == l.country.trim().toUpperCase(),
        l.country,
      );

  /// The state (stored as its code) in the app language.
  static String state(BuildContext context, WorkLocation l) => _labelOf(
        context,
        LocationDataService.instance.statesOf(l.country),
        (LocationOption o) => o.code == l.state.trim(),
        l.state,
      );

  /// The city (stored as its English name) in the app language.
  static String city(BuildContext context, WorkLocation l) => _labelOf(
        context,
        LocationDataService.instance.citiesOf(l.country, l.state),
        (LocationOption o) => o.matches(l.city),
        l.city,
      );

  static String yesNo(BuildContext context, bool v) =>
      v ? S.of(context).yes : S.of(context).no;

  static String _coordinate(BuildContext context, double? v) =>
      v == null ? TimeTrackerFormat.dash : LocalizedNumber.digits(context, v.toStringAsFixed(4));

  /// "09:00 AM – 05:00 PM".
  static String hours(BuildContext context, WorkLocation l) {
    DateTime at(int m) => DateTime(2000, 1, 1, m ~/ 60, m % 60);
    return '${TimeTrackerFormat.time(context, at(l.workStartMinutes))} – '
        '${TimeTrackerFormat.time(context, at(l.workEndMinutes))}';
  }

  /// "Sun, Mon, Tue" in the app language.
  static String days(BuildContext context, WorkLocation l) {
    final String locale = Localizations.localeOf(context).languageCode;
    return <String>[
      for (final int d in LocationFormRules.weekOrder)
        if (l.workingDays.contains(d)) DateFormat('EEE', locale).format(DateTime(2024, 1, d)),
    ].join(_ar(context) ? '، ' : ', ');
  }

  static String radius(BuildContext context, WorkLocation l) => l.isGeofenceEnabled
      ? S.of(context).timeTrackerMetersValue(LocalizedNumber.of(context, l.geofenceRadiusMeters.round()))
      : TimeTrackerFormat.dash;

  static String breakLength(BuildContext context, WorkLocation l) =>
      l.isBreakAllowed ? TimeTrackerFormat.mins(context, l.breakMinutes) : TimeTrackerFormat.dash;

  static String status(BuildContext context, LocationStatus status) {
    final S s = S.of(context);
    switch (status) {
      case LocationStatus.active:
        return s.timeTrackerActive;
      case LocationStatus.inactive:
        return s.timeTrackerInactive;
      case LocationStatus.deleted:
        return s.timeTrackerRemoved;
    }
  }

  /// Column titles, in table order.
  static List<String> headers(BuildContext context) {
    final S s = S.of(context);
    return <String>[
      s.timeTrackerLocationName,
      s.timeTrackerGoogleMap,
      s.timeTrackerLatitude,
      s.timeTrackerLongitude,
      s.timeTrackerGeofencing,
      s.timeTrackerGeofenceRadiusColumn,
      s.timeTrackerCountry,
      s.timeTrackerStateOrProvince,
      s.timeTrackerCity,
      s.timeTrackerPostalCode,
      s.timeTrackerWorkSchedule,
      s.timeTrackerWorkingDays,
      s.timeTrackerAllowBreaks,
      s.timeTrackerAllowPause,
      s.timeTrackerBreak,
      s.timeTrackerStatus,
    ];
  }

  static const List<double> _widths = <double>[
    150, 170, 100, 100, 100, 140, 110, 140, 110, 110, 190, 190, 170, 110, 100, 100,
  ];

  /// The table columns (titles + widths).
  static List<TtColumn> columns(BuildContext context) {
    final List<String> h = headers(context);
    return <TtColumn>[for (int i = 0; i < h.length; i++) TtColumn(h[i], _widths[i])];
  }

  /// Function Name: [cells]
  ///
  /// Purpose: The row's values (Export + search), in [headers] order.
  ///
  /// Return type: [List<String>]
  static List<String> cells(BuildContext context, WorkLocation l) => <String>[
        name(context, l),
        l.googleMapsUrl.trim().isEmpty ? TimeTrackerFormat.dash : l.googleMapsUrl.trim(),
        _coordinate(context, l.latitude),
        _coordinate(context, l.longitude),
        yesNo(context, l.isGeofenceEnabled),
        radius(context, l),
        country(context, l),
        state(context, l),
        city(context, l),
        l.postalCode.trim().isEmpty ? TimeTrackerFormat.dash : l.postalCode.trim(),
        hours(context, l),
        days(context, l),
        yesNo(context, l.isBreakAllowed),
        yesNo(context, l.isPauseAllowed),
        breakLength(context, l),
        status(context, l.status),
      ];

  /// [cells] as table cells (link blue, status coloured).
  static List<TtCell> tableCells(BuildContext context, WorkLocation l) {
    final List<String> c = cells(context, l);
    return <TtCell>[
      for (int i = 0; i < c.length; i++)
        TtCell(
          c[i],
          color: i == 1 && c[i] != TimeTrackerFormat.dash
              ? AppColors.blue
              : (i == c.length - 1 ? LocationStatusText.colorOf(l.status) : null),
        ),
    ];
  }
}

/// "Active" (green) / "Inactive" (red).
class LocationStatusText extends StatelessWidget {
  const LocationStatusText({super.key, required this.status});

  final LocationStatus status;

  static Color colorOf(LocationStatus status) {
    switch (status) {
      case LocationStatus.active:
        return AppColors.lightGreen;
      case LocationStatus.inactive:
        return AppColors.red;
      case LocationStatus.deleted:
        return AppColors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) => Text(
        LocationText.status(context, status),
        style: StyleText.fontSize14Weight500.copyWith(color: colorOf(status)),
      );
}
