/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: work_location.dart
/// Purpose: Declares `WorkLocation` (a company location, incl. its working
///          hours) and `WorkSchedule` (start / end minutes + working days).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 13 (8/10/2026): a company WITHOUT HR has no shifts — the
/// "shift" is part of the location (Work_Start_Time, Work_End_Time,
/// Working_Days, breaks, pause) and applies to everyone there. With HR the
/// same `WorkLocation` / `WorkSchedule` shapes are filled from HR data (see
/// `WorkSetupSource`), so the rest of the module never cares who owns them.
///
/// Times are minutes since local midnight; working days use `DateTime.weekday`
/// numbering (1 = Monday … 7 = Sunday). Plain immutable Dart.
///
/// Updated: 8/10/2026 - owner decision 22: `lateAfterMinutes` (grace period,
/// default 0) on the location and its schedule — a check-in is late only
/// when it is AFTER start + grace.
/// Updated: 9/10/2026 - phase 3: Arabic twins of Country / State / City (the
/// Figma location form `661:39468` has an Arabic field beside each) and a
/// full [WorkLocation.copyWith] for the Create / Edit form and the import.
/// Updated: 9/10/2026 - code review: [WorkSchedule.isWorkingWeekKnown]
/// (finding 1 — HR shifts carry no working days, so weekend-sensitive
/// automation is skipped for them) and calendar arithmetic in
/// [WorkSchedule.startOn] / [WorkSchedule.endOn] (a DST change no longer
/// shifts the shift by an hour).

import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

/// When an employee is expected to work.
class WorkSchedule {
  const WorkSchedule({
    required this.startMinutes,
    required this.endMinutes,
    this.workingDays = allDays,
    this.lateAfterMinutes = 0,
    this.isWorkingWeekKnown = true,
  });

  /// Every day of the week (1..7).
  static const List<int> allDays = <int>[1, 2, 3, 4, 5, 6, 7];

  /// Sunday → Thursday — the SAFE default week used ONLY to count vacation
  /// days when a schedule's working week is unknown (code review finding 1,
  /// 9/10/2026). Never used for absences or reminders.
  static const List<int> sundayToThursday = <int>[7, 1, 2, 3, 4];

  final int startMinutes;
  final int endMinutes;
  final List<int> workingDays;

  /// Grace period: a check-in up to this many minutes after the start is
  /// still on time (owner decision 22, 8/10/2026). Never negative.
  final int lateAfterMinutes;

  /// ADDED 9/10/2026 (code review finding 1): false when [workingDays] is a
  /// placeholder — an HR shift stores no working days, so "every day" there
  /// only means "unknown". Absent sweep, missed-check-in reminder and
  /// guessed absences are skipped for such a schedule; a stored absent day
  /// on it is not trusted (`AbsenceRules`).
  final bool isWorkingWeekKnown;

  /// The latest on-time check-in on [day] (start + grace).
  DateTime lateThresholdOn(DateTime day) => DateTime(
        day.year,
        day.month,
        day.day,
        0,
        startMinutes + (lateAfterMinutes < 0 ? 0 : lateAfterMinutes),
      );

  /// The shift ends after midnight (e.g. 22:00 → 06:00).
  bool get isOvernight => endMinutes <= startMinutes;

  bool isWorkingDay(DateTime day) => workingDays.contains(day.weekday);

  /// Shift start on [day] (local). Calendar arithmetic (9/10/2026): on a DST
  /// day `midnight + Duration(minutes:)` landed an hour off.
  DateTime startOn(DateTime day) =>
      DateTime(day.year, day.month, day.day, 0, startMinutes);

  /// Shift end for the shift that STARTS on [day] — the next day when
  /// [isOvernight].
  DateTime endOn(DateTime day) =>
      DateTime(day.year, day.month, day.day + (isOvernight ? 1 : 0), 0, endMinutes);

  /// Function Name: [withWorkingDays]
  ///
  /// Purpose: The same hours over [days] (still flagged with
  /// [isWorkingWeekKnown] as given — used for the vacation-day count only).
  ///
  /// Return type: [WorkSchedule]
  WorkSchedule withWorkingDays(List<int> days, {bool? known}) => WorkSchedule(
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        workingDays: List<int>.unmodifiable(days),
        lateAfterMinutes: lateAfterMinutes,
        isWorkingWeekKnown: known ?? isWorkingWeekKnown,
      );

  /// Planned working minutes of one shift.
  int get shiftMinutes {
    final int span = endMinutes - startMinutes;
    return span <= 0 ? span + 24 * 60 : span;
  }
}

class WorkLocation {
  const WorkLocation({
    required this.id,
    required this.nameEn,
    this.nameAr = '',
    this.googleMapsUrl = '',
    this.latitude,
    this.longitude,
    this.isGeofenceEnabled = false,
    this.geofenceRadiusMeters = 0,
    this.country = '',
    this.state = '',
    this.city = '',
    this.postalCode = '',
    this.workStartMinutes = 9 * 60,
    this.workEndMinutes = 17 * 60,
    this.workingDays = WorkSchedule.allDays,
    this.lateAfterMinutes = 0,
    this.isBreakAllowed = false,
    this.breakMinutes = 0,
    this.isPauseAllowed = false,
    this.pauseMinutes = 0,
    this.status = LocationStatus.active,
    this.audit = AuditInfo.none,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String googleMapsUrl;
  final double? latitude;
  final double? longitude;
  final bool isGeofenceEnabled;

  /// Geofence = a circle of this radius around (latitude, longitude).
  final double geofenceRadiusMeters;
  /// Address = three DROPDOWN values (owner, 9/10/2026 — no Arabic twin
  /// fields): [country] is the ISO-2 code (e.g. `EG`), [state] the state
  /// code from `LocationDataService.statesOf`, [city] the city's ENGLISH name
  /// (cities have no code). Labels are shown in the app language by looking
  /// them up in `LocationDataService` (`LocationAddressText`).
  final String country;
  final String state;
  final String city;
  final String postalCode;
  final int workStartMinutes;
  final int workEndMinutes;
  final List<int> workingDays;

  /// "Late After (minutes)" — grace period before a check-in counts as late.
  final int lateAfterMinutes;
  final bool isBreakAllowed;
  final int breakMinutes;
  final bool isPauseAllowed;

  /// ADDED 9/10/2026 (approved schema `Allowed_Pause_Minutes`): the longest
  /// pause allowed here (0 = no limit). Passing it is reported by the Cloud
  /// Functions (`pause_duration_exceeded`); the pause keeps running.
  final int pauseMinutes;
  final LocationStatus status;
  final AuditInfo audit;

  bool get hasCoordinates => latitude != null && longitude != null;

  /// Employees can check in here (not inactive, not deleted).
  bool get isActive => status == LocationStatus.active;

  /// The location's working hours as a schedule.
  WorkSchedule get schedule => WorkSchedule(
        startMinutes: workStartMinutes,
        endMinutes: workEndMinutes,
        workingDays: workingDays,
        lateAfterMinutes: lateAfterMinutes,
      );

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update of the editable fields. [clearCoordinates]
  /// empties latitude / longitude (a blank field in the form).
  ///
  /// Return type: [WorkLocation]
  WorkLocation copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? googleMapsUrl,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
    bool? isGeofenceEnabled,
    double? geofenceRadiusMeters,
    String? country,
    String? state,
    String? city,
    String? postalCode,
    int? workStartMinutes,
    int? workEndMinutes,
    List<int>? workingDays,
    int? lateAfterMinutes,
    bool? isBreakAllowed,
    int? breakMinutes,
    bool? isPauseAllowed,
    int? pauseMinutes,
    LocationStatus? status,
  }) =>
      WorkLocation(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
        latitude: clearCoordinates ? null : (latitude ?? this.latitude),
        longitude: clearCoordinates ? null : (longitude ?? this.longitude),
        isGeofenceEnabled: isGeofenceEnabled ?? this.isGeofenceEnabled,
        geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
        country: country ?? this.country,
        state: state ?? this.state,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        workStartMinutes: workStartMinutes ?? this.workStartMinutes,
        workEndMinutes: workEndMinutes ?? this.workEndMinutes,
        workingDays: workingDays ?? this.workingDays,
        lateAfterMinutes: lateAfterMinutes ?? this.lateAfterMinutes,
        isBreakAllowed: isBreakAllowed ?? this.isBreakAllowed,
        breakMinutes: breakMinutes ?? this.breakMinutes,
        isPauseAllowed: isPauseAllowed ?? this.isPauseAllowed,
        pauseMinutes: pauseMinutes ?? this.pauseMinutes,
        status: status ?? this.status,
        audit: audit,
      );

  /// Function Name: [name]
  ///
  /// Purpose: The name in the app language, falling back to the other one.
  ///
  /// Return type: [String]
  String name({required bool isArabic}) {
    final String first = (isArabic ? nameAr : nameEn).trim();
    return first.isNotEmpty ? first : (isArabic ? nameEn : nameAr).trim();
  }
}
