/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_formatters.dart
/// Purpose: Declares `TimeTrackerFormat` — the module's localized display
///          of dates ("23 Feb 2023"), times ("09:00 AM"), durations
///          ("7:30 Hrs", "30 Mins"), attendance statuses (label + colour) and
///          work-location types.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner rules (playbook §4b round 2): dates `dd MMM yyyy`, times `hh:mm a`,
/// both through `LocalizedDate` (Arabic month names + Arabic-Indic digits in
/// Arabic). Status colours (brief phase 2): Present green, Late orange,
/// Absent red, Excused grey, Vacation yellow, Sick Leave dark red — all
/// `AppColors` getters, readable in both themes.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class TimeTrackerFormat {
  const TimeTrackerFormat._();

  /// Shown for an empty cell (Figma "-").
  static const String dash = '-';

  /// [value] trimmed, or [dash] when empty (9/10/2026).
  static String orDash(String value) => value.trim().isEmpty ? dash : value.trim();

  /// "23 Feb 2023" (localized).
  static String date(BuildContext context, DateTime? value) => value == null ? dash : LocalizedDate.of(context, value);

  /// "09:00 AM" (localized).
  static String time(BuildContext context, DateTime? value) =>
      value == null ? dash : LocalizedDate.of(context, value, pattern: 'hh:mm a');

  /// "7:30 Hrs" — worked time of a day; [dash] when nothing was worked.
  static String hours(BuildContext context, int minutes) {
    if (minutes <= 0) return dash;
    final String hm = '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';
    return S.of(context).timeTrackerHrsValue(LocalizedNumber.digits(context, hm));
  }

  /// "30 Mins"; [dash] for 0.
  static String mins(BuildContext context, int minutes) =>
      minutes <= 0 ? dash : S.of(context).timeTrackerMinsValue(LocalizedNumber.of(context, minutes));

  /// "00 : 01" — the live timer (hours : minutes).
  static String clock(BuildContext context, int minutes) {
    final int safe = minutes < 0 ? 0 : minutes;
    final String text = '${(safe ~/ 60).toString().padLeft(2, '0')} : '
        '${(safe % 60).toString().padLeft(2, '0')}';
    return LocalizedNumber.digits(context, text);
  }

  /// ADDED 13/10/2026 (owner): "01 : 05 : 09" — hours : minutes : seconds
  /// (localized digits); [short] = "05 : 09" (minutes : seconds).
  static String clockSeconds(BuildContext context, int seconds, {bool short = false}) {
    final int safe = seconds < 0 ? 0 : seconds;
    String two(int v) => v.toString().padLeft(2, '0');
    final String text = short
        ? '${two(safe ~/ 60)} : ${two(safe % 60)}'
        : '${two(safe ~/ 3600)} : ${two((safe % 3600) ~/ 60)} : ${two(safe % 60)}';
    return LocalizedNumber.digits(context, text);
  }

  /// A count with localized digits ("11" / "١١").
  static String count(BuildContext context, num value) => LocalizedNumber.of(context, value);

  /// Function Name: [days] / [absences]
  ///
  /// Purpose: ADDED 9/10/2026 (UI pass) — a count with its noun: "1 Day" /
  /// "3 Days", "1 Absence" / "4 Absences"; Arabic by the CLDR rule (last two
  /// digits) — 1 "يوم واحد", 2 "يومان", 3–10 "٤ أيام", 11–99 "١٥ يوما", else
  /// "١٠٠ يوم" (was "1 Days" / "٤ يوم" / "٣ غياب"). Same rule as
  /// `TimeTrackerCountWording`; no tanween (house rule). The words come from
  /// the ARB (English uses one plural for few / many / other).
  ///
  /// Return type: [String]
  static String days(BuildContext context, int days) {
    final S s = S.of(context);
    return _counted(context, days,
        one: s.timeTrackerOneDay,
        two: s.timeTrackerTwoDays,
        few: s.timeTrackerDaysFew,
        many: s.timeTrackerDaysMany,
        other: s.timeTrackerDaysValue);
  }

  static String absences(BuildContext context, int count) {
    final S s = S.of(context);
    return _counted(context, count,
        one: s.timeTrackerOneAbsence,
        two: s.timeTrackerTwoAbsences,
        few: s.timeTrackerAbsencesFew,
        many: s.timeTrackerAbsencesMany,
        other: s.timeTrackerAbsencesCount);
  }

  static String _counted(
    BuildContext context,
    int value, {
    required String one,
    required String two,
    required String Function(String) few,
    required String Function(String) many,
    required String Function(String) other,
  }) {
    final int n = value < 0 ? 0 : value;
    if (n == 1) return one;
    if (n == 2) return two;
    final String digits = count(context, n);
    final int lastTwo = n % 100;
    if (lastTwo >= 3 && lastTwo <= 10) return few(digits);
    if (lastTwo >= 11 && lastTwo <= 99) return many(digits);
    return other(digits);
  }

  /// Function Name: [statusLabel]
  ///
  /// Purpose: The localized name of [status] ([dash] when undecided).
  ///
  /// Return type: [String]
  static String statusLabel(BuildContext context, AttendanceStatus? status) {
    final S s = S.of(context);
    switch (status) {
      case AttendanceStatus.present:
        return s.timeTrackerPresent;
      case AttendanceStatus.late:
        return s.timeTrackerLate;
      case AttendanceStatus.absent:
        return s.timeTrackerAbsent;
      case AttendanceStatus.vacation:
        return s.timeTrackerVacation;
      case AttendanceStatus.sickLeave:
        return s.timeTrackerSickLeave;
      case AttendanceStatus.excused:
        return s.timeTrackerExcused;
      case null:
        return dash;
    }
  }

  /// Function Name: [statusColor]
  ///
  /// Purpose: The colour [status] is drawn in.
  ///
  /// Return type: [Color]
  static Color statusColor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.lightGreen;
      case AttendanceStatus.late:
        return AppColors.orange;
      case AttendanceStatus.absent:
        return AppColors.red;
      case AttendanceStatus.vacation:
        return AppColors.yellow;
      case AttendanceStatus.sickLeave:
        return AppColors.darkRed;
      case AttendanceStatus.excused:
      case null:
        return AppColors.secondaryText;
    }
  }

  /// Function Name: [placeLabel]
  ///
  /// Purpose: "Remote" / "Client Site" / "Office" (or the location name).
  ///
  /// Parameters:
  ///   [WorkLocationType] type
  ///   [String] officeName: the location name for an office ('' = "Office").
  ///
  /// Return type: [String]
  static String placeLabel(
    BuildContext context,
    WorkLocationType type, {
    String officeName = '',
  }) {
    final S s = S.of(context);
    switch (type) {
      case WorkLocationType.office:
        return officeName.trim().isNotEmpty ? officeName : s.timeTrackerOffice;
      case WorkLocationType.remote:
        return s.timeTrackerRemote;
      case WorkLocationType.clientSite:
        return s.timeTrackerClientSite;
    }
  }

  /// "62 KB" / "1.2 MB".
  static String fileSize(BuildContext context, int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${LocalizedNumber.digits(context, (bytes / (1024 * 1024)).toStringAsFixed(1))} MB';
    }
    return '${LocalizedNumber.of(context, (bytes / 1024).ceil())} KB';
  }
}

/// 13/10/2026 (owner): the usual business abbreviations for a job title, so
/// it fits one line in compact cards ("Director of Administrative Affairs" →
/// "Dir. of Admin. Affairs", "Human Resources Officer" → "HR Officer").
/// Arabic titles are returned unchanged.
class TtJobTitle {
  const TtJobTitle._();

  static const List<(String, String)> _rules = <(String, String)>[
    ('Human Resources', 'HR'),
    ('Information Technology', 'IT'),
    ('Public Relations', 'PR'),
    ('Customer Service', 'CS'),
    ('Vice President', 'VP'),
    ('Chief Executive Officer', 'CEO'),
    ('Chief Operating Officer', 'COO'),
    ('Chief Financial Officer', 'CFO'),
    ('Director', 'Dir.'),
    ('Administrative', 'Admin.'),
    ('Administration', 'Admin.'),
    ('Assistant', 'Asst.'),
    ('Senior', 'Sr.'),
    ('Junior', 'Jr.'),
    ('Department', 'Dept.'),
    ('Coordinator', 'Coord.'),
    ('Representative', 'Rep.'),
    ('Management', 'Mgmt.'),
    ('Manager', 'Mgr.'),
    ('Specialist', 'Spec.'),
    ('Supervisor', 'Supv.'),
    ('Engineer', 'Eng.'),
    ('Executive', 'Exec.'),
    ('Operations', 'Ops.'),
  ];

  static String short(String title) {
    String out = title.trim();
    for (final (String long, String abbr) in _rules) {
      out = out.replaceAll(RegExp('\\b$long\\b', caseSensitive: false), abbr);
    }
    return out;
  }
}
