/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: location_import_rules.dart
/// Purpose: Declares `LocationImportRules` (the template columns and the
///          planner that turns an uploaded sheet into a preview) and its
///          result types `LocationImportPlan` / `LocationImportRow`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Import Locations (`Import_Locations`, phase 3). Brief rules:
///   * a row whose "Location Name" matches an existing (not deleted)
///     location UPDATES it — a blank cell keeps the stored value;
///   * any other row CREATES a location;
///   * nothing is ever deleted, and a row with a problem is skipped (the
///     preview lists the problem per column) — the rest still import.
/// Headings are matched case-insensitively; unknown columns are ignored.
/// Pure Dart (the file reading lives in the data layer), unit-tested.

import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';

typedef _R = LocationFormRules;

/// The template columns, in file order. English on purpose: the file is
/// machine-read in both languages.
enum LocationImportColumn {
  nameEn('Location Name'),
  nameAr('Location Name (Arabic)'),
  googleMapsUrl('Google Maps URL'),
  latitude('Latitude'),
  longitude('Longitude'),
  geofence('Geofence (Yes/No)'),
  radius('Geofence Radius (m)'),
  // 9/10/2026 — codes, matching the form's dropdowns (no Arabic columns).
  country('Country Code (e.g. EG, SA, AE)'),
  state('State Code'),
  city('City (English name)'),
  postalCode('Postal Code'),
  workStart('Work Start (HH:mm)'),
  workEnd('Work End (HH:mm)'),
  workingDays('Working Days'),
  lateAfter('Late After (minutes)'),
  breaks('Allow Breaks (Yes/No)'),
  breakMinutes('Break (minutes)'),
  pause('Allow Pause (Yes/No)'),
  status('Status (Active/Inactive)');

  const LocationImportColumn(this.heading);

  /// The heading written in the template and expected in the file.
  final String heading;
}

enum LocationImportAction { create, update, unchanged, skip }

/// One problem of one row: the column (null = the whole row) + what is wrong.
class LocationImportIssue {
  const LocationImportIssue(this.column, this.error);

  final LocationImportColumn? column;

  /// A form error, or null for "unreadable value in [column]".
  final LocationFormError? error;

  /// Two rows of the file share this name.
  static const LocationImportIssue duplicateName =
      LocationImportIssue(LocationImportColumn.nameEn, null);
}

class LocationImportRow {
  const LocationImportRow({
    required this.line,
    required this.name,
    required this.action,
    this.location,
    this.issues = const <LocationImportIssue>[],
  });

  /// 1-based line in the file (the heading row is line 1).
  final int line;
  final String name;
  final LocationImportAction action;

  /// What will be saved (create / update only).
  final WorkLocation? location;
  final List<LocationImportIssue> issues;
}

class LocationImportPlan {
  const LocationImportPlan({this.rows = const <LocationImportRow>[], this.missingNameColumn = false});

  final List<LocationImportRow> rows;

  /// The file has no "Location Name" heading — nothing can be imported.
  final bool missingNameColumn;

  int count(LocationImportAction action) =>
      rows.where((LocationImportRow r) => r.action == action).length;

  /// The rows that will be written.
  List<LocationImportRow> get writable => <LocationImportRow>[
        for (final LocationImportRow r in rows)
          if (r.action == LocationImportAction.create ||
              r.action == LocationImportAction.update)
            r,
      ];
}

class LocationImportRules {
  const LocationImportRules._();

  /// Default working days of a NEW location: Sunday – Thursday.
  static const List<int> defaultWorkingDays = <int>[7, 1, 2, 3, 4];

  /// The template heading row.
  static List<String> get headings => <String>[
        for (final LocationImportColumn c in LocationImportColumn.values) c.heading,
      ];

  /// Function Name: [plan]
  ///
  /// Purpose: Build the preview of importing [grid] (first row = headings)
  /// against the [existing] locations.
  ///
  /// Return type: [LocationImportPlan]
  static LocationImportPlan plan({
    required List<List<String>> grid,
    required List<WorkLocation> existing,
  }) {
    if (grid.isEmpty) return const LocationImportPlan(missingNameColumn: true);
    final Map<LocationImportColumn, int> at = <LocationImportColumn, int>{};
    for (int i = 0; i < grid.first.length; i++) {
      final String h = grid.first[i].trim().toLowerCase();
      for (final LocationImportColumn c in LocationImportColumn.values) {
        if (c.heading.toLowerCase() == h) at[c] = i;
      }
    }
    if (!at.containsKey(LocationImportColumn.nameEn)) {
      return const LocationImportPlan(missingNameColumn: true);
    }
    final Map<String, WorkLocation> byName = <String, WorkLocation>{
      for (final WorkLocation l in existing)
        if (l.status != LocationStatus.deleted) l.nameEn.trim().toLowerCase(): l,
    };
    final Set<String> seen = <String>{};
    final List<LocationImportRow> rows = <LocationImportRow>[];
    for (int r = 1; r < grid.length; r++) {
      String cell(LocationImportColumn c) {
        final int? i = at[c];
        return i == null || i >= grid[r].length ? '' : grid[r][i].trim();
      }

      if (grid[r].every((String v) => v.trim().isEmpty)) continue;
      final String name = cell(LocationImportColumn.nameEn);
      final String key = name.toLowerCase();
      if (name.isNotEmpty && !seen.add(key)) {
        rows.add(LocationImportRow(
          line: r + 1,
          name: name,
          action: LocationImportAction.skip,
          issues: const <LocationImportIssue>[LocationImportIssue.duplicateName],
        ));
        continue;
      }
      rows.add(_row(line: r + 1, name: name, stored: byName[key], cell: cell));
    }
    return LocationImportPlan(rows: List<LocationImportRow>.unmodifiable(rows));
  }

  static LocationImportRow _row({
    required int line,
    required String name,
    required WorkLocation? stored,
    required String Function(LocationImportColumn) cell,
  }) {
    final List<LocationImportIssue> issues = <LocationImportIssue>[];
    final WorkLocation base = stored ??
        WorkLocation(id: '', nameEn: name, workingDays: defaultWorkingDays);
    String text(LocationImportColumn c, String keep) {
      final String v = cell(c);
      return v.isEmpty ? keep : v;
    }

    T? parsed<T>(LocationImportColumn c, T? Function(String) parse) {
      final String v = cell(c);
      if (v.isEmpty) return null;
      final T? value = parse(v);
      if (value == null || (value is double && value.isNaN)) {
        issues.add(LocationImportIssue(c, null));
        return null;
      }
      return value;
    }

    int? whole(String v) => int.tryParse(_R.normaliseDigits(v));
    LocationStatus? status(String v) {
      switch (v.toLowerCase()) {
        case 'active':
        case 'نشط':
          return LocationStatus.active;
        case 'inactive':
        case 'غير نشط':
          return LocationStatus.inactive;
      }
      return null;
    }

    final String nameAr = text(LocationImportColumn.nameAr, base.nameAr);
    final WorkLocation next = base.copyWith(
      nameEn: name,
      // A new row without an Arabic name reuses the English one.
      nameAr: nameAr.isEmpty ? name : nameAr,
      googleMapsUrl: text(LocationImportColumn.googleMapsUrl, base.googleMapsUrl),
      latitude: parsed(LocationImportColumn.latitude, _R.parseCoordinate),
      longitude: parsed(LocationImportColumn.longitude, _R.parseCoordinate),
      isGeofenceEnabled: parsed(LocationImportColumn.geofence, _R.parseYesNo),
      geofenceRadiusMeters:
          parsed(LocationImportColumn.radius, whole)?.toDouble(),
      country: text(LocationImportColumn.country, base.country).toUpperCase(),
      state: text(LocationImportColumn.state, base.state),
      city: text(LocationImportColumn.city, base.city),
      postalCode: text(LocationImportColumn.postalCode, base.postalCode),
      workStartMinutes: parsed(LocationImportColumn.workStart, _R.parseMinutesOfDay),
      workEndMinutes: parsed(LocationImportColumn.workEnd, _R.parseMinutesOfDay),
      workingDays: parsed(LocationImportColumn.workingDays, _R.parseWorkingDays),
      lateAfterMinutes: parsed(LocationImportColumn.lateAfter, whole),
      isBreakAllowed: parsed(LocationImportColumn.breaks, _R.parseYesNo),
      breakMinutes: parsed(LocationImportColumn.breakMinutes, whole),
      isPauseAllowed: parsed(LocationImportColumn.pause, _R.parseYesNo),
      status: parsed(LocationImportColumn.status, status),
    );
    for (final LocationFormError e in LocationFormRules.validate(next)) {
      issues.add(LocationImportIssue(_columnOf(e), e));
    }
    if (next.lateAfterMinutes < 0 || next.lateAfterMinutes > LocationFormRules.maxMinutes) {
      issues.add(const LocationImportIssue(LocationImportColumn.lateAfter, null));
    }
    if (issues.isNotEmpty) {
      return LocationImportRow(
        line: line,
        name: name,
        action: LocationImportAction.skip,
        issues: List<LocationImportIssue>.unmodifiable(issues),
      );
    }
    final LocationImportAction action = stored == null
        ? LocationImportAction.create
        : (_same(stored, next) ? LocationImportAction.unchanged : LocationImportAction.update);
    return LocationImportRow(line: line, name: name, action: action, location: next);
  }

  static LocationImportColumn? _columnOf(LocationFormError e) {
    switch (e) {
      case LocationFormError.nameEnRequired:
        return LocationImportColumn.nameEn;
      case LocationFormError.nameArRequired:
        return LocationImportColumn.nameAr;
      case LocationFormError.latitudeInvalid:
        return LocationImportColumn.latitude;
      case LocationFormError.longitudeInvalid:
        return LocationImportColumn.longitude;
      case LocationFormError.coordinatesRequired:
        return LocationImportColumn.geofence;
      case LocationFormError.radiusRequired:
        return LocationImportColumn.radius;
      case LocationFormError.workTimesSame:
        return LocationImportColumn.workEnd;
      case LocationFormError.workingDaysRequired:
        return LocationImportColumn.workingDays;
      case LocationFormError.breakLengthRequired:
        return LocationImportColumn.breakMinutes;
    }
  }

  /// Function Name: [rowOf]
  ///
  /// Purpose: One location as a template / export row (column order).
  ///
  /// Return type: [List<String>]
  static List<String> rowOf(WorkLocation l) {
    String yesNo(bool v) => v ? 'Yes' : 'No';
    String num(double? v) => v == null ? '' : '$v';
    return <String>[
      l.nameEn,
      l.nameAr,
      l.googleMapsUrl,
      num(l.latitude),
      num(l.longitude),
      yesNo(l.isGeofenceEnabled),
      l.isGeofenceEnabled ? '${l.geofenceRadiusMeters.round()}' : '',
      l.country,
      l.state,
      l.city,
      l.postalCode,
      _R.formatMinutesOfDay(l.workStartMinutes),
      _R.formatMinutesOfDay(l.workEndMinutes),
      _R.formatWorkingDays(l.workingDays),
      '${l.lateAfterMinutes}',
      yesNo(l.isBreakAllowed),
      l.isBreakAllowed ? '${l.breakMinutes}' : '',
      yesNo(l.isPauseAllowed),
      l.status == LocationStatus.active ? 'Active' : 'Inactive',
    ];
  }

  static bool _same(WorkLocation a, WorkLocation b) {
    final List<String> x = rowOf(a);
    final List<String> y = rowOf(b);
    for (int i = 0; i < x.length; i++) {
      if (x[i] != y[i]) return false;
    }
    return true;
  }
}
