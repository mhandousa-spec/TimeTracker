/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: location_form_rules.dart
/// Purpose: Declares `LocationFormError` and `LocationFormRules` — what a
///          location draft (Create / Edit Location form, and every imported
///          row) must satisfy, plus the small parsers the form and the import
///          share (coordinates, "HH:mm", Yes / No, working-day names).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 3 (no-HR companies). Figma `661:39468` / `661:40152` / `661:40322`
/// + the owner-approved additions (decisions 13, 22): Work Start Time · Work
/// End Time · Working Days · Late After (minutes). The Figma "Geofencing
/// Area (m²)" is dropped: the geofence is a circle (decision 5), so only its
/// radius in meters is asked for. Same limits as `LocationRepositoryImpl`
/// (which re-checks on save). Pure Dart, unit-tested.
/// Updated: 9/10/2026 - code review (owner rule): [assignedEmployees] — a
/// location with employees assigned may not be deleted or made inactive
/// until they are reassigned (it used to strand them without a location).

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

enum LocationFormError {
  nameEnRequired,
  nameArRequired,
  latitudeInvalid,
  longitudeInvalid,
  coordinatesRequired,
  radiusRequired,
  workTimesSame,
  workingDaysRequired,
  breakLengthRequired,
  // 13/10/2026 (owner: "validations on everything").
  mapsUrlInvalid,
  lateAfterTooLong,
  pauseTooLong,
  countryRequired,
  stateRequired,
  cityRequired,
  workStartRequired,
  workEndRequired,
}

class LocationFormRules {
  const LocationFormRules._();

  /// Largest geofence radius accepted (50 km — a city, not a country).
  static const double maxRadiusMeters = 50000;

  /// Longest break / grace period accepted (one day).
  static const int maxMinutes = 24 * 60;

  /// Figma chip order: Sunday first (`DateTime.weekday` numbers).
  static const List<int> weekOrder = <int>[7, 1, 2, 3, 4, 5, 6];

  /// Function Name: [validate]
  ///
  /// Purpose: Every problem of [location]; empty = can be saved.
  /// 13/10/2026 (owner): the FORM also asks for the address
  /// ([requireCountry]; [requireState] / [requireCity] when the chosen
  /// country / state has a list to pick from). The import keeps a blank
  /// address (a blank cell = keep the stored value).
  ///
  /// Return type: [Set<LocationFormError>]
  static Set<LocationFormError> validate(
    WorkLocation location, {
    bool requireCountry = false,
    bool requireState = false,
    bool requireCity = false,
  }) {
    final Set<LocationFormError> errors = <LocationFormError>{};
    if (location.nameEn.trim().isEmpty) errors.add(LocationFormError.nameEnRequired);
    if (location.nameAr.trim().isEmpty) errors.add(LocationFormError.nameArRequired);
    final double? lat = location.latitude;
    final double? lng = location.longitude;
    if (lat != null && (lat.isNaN || lat < -90 || lat > 90)) {
      errors.add(LocationFormError.latitudeInvalid);
    }
    if (lng != null && (lng.isNaN || lng < -180 || lng > 180)) {
      errors.add(LocationFormError.longitudeInvalid);
    }
    if (location.isGeofenceEnabled) {
      if (lat == null || lng == null) errors.add(LocationFormError.coordinatesRequired);
      if (location.geofenceRadiusMeters <= 0 ||
          location.geofenceRadiusMeters > maxRadiusMeters) {
        errors.add(LocationFormError.radiusRequired);
      }
    }
    if (location.workStartMinutes == location.workEndMinutes) {
      errors.add(LocationFormError.workTimesSame);
    }
    if (location.workingDays.isEmpty) errors.add(LocationFormError.workingDaysRequired);
    if (location.isBreakAllowed &&
        (location.breakMinutes <= 0 || location.breakMinutes > maxMinutes)) {
      errors.add(LocationFormError.breakLengthRequired);
    }
    // 13/10/2026 (owner): a Maps link must be a real web link to a map.
    if (!isMapsUrl(location.googleMapsUrl)) errors.add(LocationFormError.mapsUrlInvalid);
    // The grace period must end before the work day does.
    final int shift = shiftMinutes(location.workStartMinutes, location.workEndMinutes);
    if (location.lateAfterMinutes < 0 || (shift > 0 && location.lateAfterMinutes >= shift)) {
      errors.add(LocationFormError.lateAfterTooLong);
    }
    if (location.isPauseAllowed && location.pauseMinutes > maxMinutes) {
      errors.add(LocationFormError.pauseTooLong);
    }
    if (requireCountry && location.country.trim().isEmpty) errors.add(LocationFormError.countryRequired);
    if (requireState && location.state.trim().isEmpty) errors.add(LocationFormError.stateRequired);
    if (requireCity && location.city.trim().isEmpty) errors.add(LocationFormError.cityRequired);
    return errors;
  }

  /// Minutes from [start] to [end] (an overnight shift wraps midnight).
  static int shiftMinutes(int start, int end) => (end - start) % (24 * 60);

  /// Function Name: [isMapsUrl]
  ///
  /// Purpose: ADDED 13/10/2026 — [raw] is empty or an http(s) link to a map
  /// (Google Maps, maps.app.goo.gl, goo.gl, Apple Maps).
  ///
  /// Return type: [bool]
  static bool isMapsUrl(String raw) {
    final String text = raw.trim();
    if (text.isEmpty) return true;
    final Uri? uri = Uri.tryParse(text);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) return false;
    final String host = uri.host.toLowerCase();
    return host.contains('google.') || host.endsWith('goo.gl') || host == 'maps.apple.com' || host.contains('maps.');
  }

  /// Function Name: [assignedEmployees]
  ///
  /// Purpose: ADDED 9/10/2026 (code review) — how many employees are
  /// assigned to [locationId] (blocks Delete / Inactive while > 0).
  ///
  /// Return type: [int]
  static int assignedEmployees(String locationId, List<LocationAssignment> assignments) =>
      locationId.trim().isEmpty
          ? 0
          : assignments
              .where((LocationAssignment a) => a.isAssigned && a.locationId == locationId)
              .length;

  /// Function Name: [parseCoordinate]
  ///
  /// Purpose: A typed latitude / longitude ('' → null; Arabic-Indic digits
  /// and an Arabic decimal comma accepted). An unreadable value is NaN so
  /// the form can flag it.
  ///
  /// Return type: [double?]
  static double? parseCoordinate(String raw) {
    final String text = normaliseDigits(raw).trim().replaceAll('٫', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text) ?? double.nan;
  }

  /// Function Name: [parseMinutesOfDay]
  ///
  /// Purpose: "09:00" / "9:30" / "17:45" → minutes since midnight (null when
  /// unreadable).
  ///
  /// Return type: [int?]
  static int? parseMinutesOfDay(String raw) {
    final RegExpMatch? m =
        RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(normaliseDigits(raw).trim());
    if (m == null) return null;
    final int h = int.parse(m.group(1)!);
    final int min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return null;
    return h * 60 + min;
  }

  /// "09:00" for 540 (import template / export).
  static String formatMinutesOfDay(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  /// Function Name: [parseYesNo]
  ///
  /// Purpose: "Yes" / "No" / "true" / "false" / "نعم" / "لا" / "1" / "0" →
  /// bool (null when unreadable).
  ///
  /// Return type: [bool?]
  static bool? parseYesNo(String raw) {
    switch (normaliseDigits(raw).trim().toLowerCase()) {
      case 'yes':
      case 'y':
      case 'true':
      case '1':
      case 'نعم':
        return true;
      case 'no':
      case 'n':
      case 'false':
      case '0':
      case 'لا':
        return false;
    }
    return null;
  }

  static const Map<String, int> _dayNames = <String, int>{
    'mon': 1, 'monday': 1, 'tue': 2, 'tuesday': 2, 'wed': 3, 'wednesday': 3,
    'thu': 4, 'thursday': 4, 'fri': 5, 'friday': 5, 'sat': 6, 'saturday': 6,
    'sun': 7, 'sunday': 7,
  };

  /// Function Name: [parseWorkingDays]
  ///
  /// Purpose: "Sun, Mon, Tue" (or "Sunday;Monday") → [7, 1, 2] in week
  /// order; null when any part is unreadable.
  ///
  /// Return type: [List<int>?]
  static List<int>? parseWorkingDays(String raw) {
    final Set<int> days = <int>{};
    for (final String part in raw.split(RegExp(r'[,;/|]'))) {
      final String key = part.trim().toLowerCase();
      if (key.isEmpty) continue;
      final int? day = _dayNames[key];
      if (day == null) return null;
      days.add(day);
    }
    return <int>[for (final int d in weekOrder) if (days.contains(d)) d];
  }

  /// "Sun, Mon" for [7, 1] (import template / export, English on purpose —
  /// the file is machine-read).
  static String formatWorkingDays(List<int> days) {
    const List<String> names = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return <String>[
      for (final int d in weekOrder)
        if (days.contains(d)) names[d - 1],
    ].join(', ');
  }

  /// Arabic-Indic / Eastern Arabic digits → ASCII.
  static String normaliseDigits(String raw) {
    const String arabic = '٠١٢٣٤٥٦٧٨٩';
    const String persian = '۰۱۲۳۴۵۶۷۸۹';
    final StringBuffer out = StringBuffer();
    for (final int rune in raw.runes) {
      final String ch = String.fromCharCode(rune);
      final int a = arabic.indexOf(ch);
      final int p = persian.indexOf(ch);
      out.write(a >= 0 ? '$a' : (p >= 0 ? '$p' : ch));
    }
    return out.toString();
  }
}
