/// Module: time_tracker / data / services / demo
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_plan.dart
/// Purpose: Declares the DEBUG-ONLY demo data model: `TtDemoInput` (who and
///          what exists), `TtDemoPlan` (every document the demo writes) and
///          its parts `TtDemoDay` / `TtDemoAlert` / `TtDemoRequest`, plus
///          `TtDemoCalendar` (working days of a schedule) and `TtDemoDice`
///          (stable pseudo-random numbers, so a reload looks the same).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — demo data)
///
/// Pure Dart, no I/O. Built by `TimeTrackerDemoBuilder`, written by
/// `TimeTrackerDemoService`. Every demo document id starts with
/// [TtDemoIds.prefix] where the house allows a free id; documents whose id
/// is fixed by the schema (`Attendance/{email}_{date}`,
/// `Vacation_Balances/{email}`, `Location_Assignments/{email}`) carry the
/// `Is_Demo` history field instead — "Remove demo data" deletes ONLY
/// documents with that tag.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

/// The demo document ids.
abstract final class TtDemoIds {
  static const String prefix = 'demo_';
  static const String headquarters = 'demo_location_headquarters';
  static const String serviceCenter = 'demo_location_service_center';
  static const String archive = 'demo_location_archive';
  static const String group = 'demo_group_records_digitisation';
  static const String annual = 'demo_request_type_annual';
  static const String sick = 'demo_request_type_sick';
  static const String mission = 'demo_request_type_mission';
  static const String workshop = 'demo_request_type_workshop';
  static const String emergency = 'demo_request_type_emergency';

  /// The `Is_Demo` history field every demo document carries.
  static const String field = 'Is_Demo';

  /// Request id number [n].
  static String request(int n) => 'demo_request_${n.toString().padLeft(3, '0')}';
}

/// What the demo is built from.
class TtDemoInput {
  const TtDemoInput({
    required this.me,
    required this.others,
    required this.now,
    this.managerOf = const <String, String>{},
    this.hrApprovers = const <String>[],
    this.existingLocations = const <WorkLocation>[],
    this.companyHasHr = false,
  });

  /// The signed-in user (gets every request status on their own Requests tab).
  final TimeTrackerEmployee me;

  /// The company's other employees (Employees_Info).
  final List<TimeTrackerEmployee> others;
  final DateTime now;

  /// E-mail → direct manager e-mail (org chart; '' = none).
  final Map<String, String> managerOf;

  /// E-mails of the HR-step approvers.
  final List<String> hrApprovers;

  /// The company's real ACTIVE locations (demo locations are only created
  /// when fewer than two exist).
  final List<WorkLocation> existingLocations;

  /// With HR the locations / assignments / groups belong to HR → not written.
  final bool companyHasHr;

  /// Everyone, the signed-in user first.
  List<TimeTrackerEmployee> get everyone => <TimeTrackerEmployee>[me, ...others];
}

/// One alert of an attendance day (approved schema `Alerts[]`).
class TtDemoAlert {
  const TtDemoAlert({required this.type, required this.at, this.minutesOver = 0});

  /// `late_arrival`, `break_exceeded`, `pause_exceeded`, `auto_check_out`,
  /// `missed_check_out`.
  final String type;
  final DateTime at;
  final int minutesOver;
}

/// One attendance day + what the app model has no field for.
class TtDemoDay {
  const TtDemoDay({
    required this.day,
    this.alerts = const <TtDemoAlert>[],
    this.isAutoCheckOut = false,
    this.before,
  });

  final AttendanceDay day;
  final List<TtDemoAlert> alerts;

  /// The last session was closed by the system (`Is_Auto_Check_Out`).
  final bool isAutoCheckOut;

  /// The day as first recorded (a transaction then corrected it → two
  /// history rows); null = one row.
  final AttendanceDay? before;
}

/// The kind of a generated PDF attachment.
enum TtDemoDocumentKind { medicalReport, workshopInvitation, travelOrder, meetingMinutes }

/// A PDF the demo generates and uploads for a request (owner, 9/10/2026:
/// tapping an attachment must open a real file).
class TtDemoDocument {
  const TtDemoDocument({
    required this.kind,
    required this.fileName,
    required this.employee,
    required this.from,
    required this.to,
    required this.issuedAt,
  });

  final TtDemoDocumentKind kind;

  /// "Medical Report — Salma Fathy.pdf".
  final String fileName;

  /// Whose document it is.
  final TimeTrackerEmployee employee;
  final DateTime from;
  final DateTime to;
  final DateTime issuedAt;
}

/// One request / transaction and when it was submitted.
class TtDemoRequest {
  const TtDemoRequest({
    required this.request,
    required this.submittedAt,
    this.documents = const <TtDemoDocument>[],
    this.comments = const <RequestComment>[],
  });

  final TimeTrackerRequest request;
  final DateTime submittedAt;

  /// 9/10/2026 (data model): written as documents of
  /// `Requests/{id}/Comments/{commentId}` (no longer inside the request).
  final List<RequestComment> comments;

  /// Generated + uploaded as the request's attachments when written.
  final List<TtDemoDocument> documents;
}

/// Every document the demo writes.
class TtDemoPlan {
  const TtDemoPlan({
    this.locations = const <WorkLocation>[],
    this.groups = const <EmployeeGroup>[],
    this.assignments = const <LocationAssignment>[],
    this.requestTypes = const <RequestType>[],
    this.balances = const <VacationBalance>[],
    this.days = const <TtDemoDay>[],
    this.requests = const <TtDemoRequest>[],
    this.typesCreatedAt,
  });

  final List<WorkLocation> locations;
  final List<EmployeeGroup> groups;
  final List<LocationAssignment> assignments;
  final List<RequestType> requestTypes;
  final List<VacationBalance> balances;
  final List<TtDemoDay> days;
  final List<TtDemoRequest> requests;

  /// The set-up documents' creation date (two months back).
  final DateTime? typesCreatedAt;

  int get documentCount =>
      locations.length +
      groups.length +
      assignments.length +
      requestTypes.length +
      balances.length +
      days.length +
      requests.length;
}

/// Working days of one schedule, counted back / forward from a day.
class TtDemoCalendar {
  const TtDemoCalendar(this.schedule);

  final WorkSchedule schedule;

  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Calendar arithmetic (DST-safe).
  static DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

  /// Function Name: [back]
  ///
  /// Purpose: The [n]-th working day before [from] (n ≥ 1).
  ///
  /// Return type: [DateTime]
  DateTime back(DateTime from, int n) {
    DateTime d = dayOf(from);
    int left = n;
    while (left > 0) {
      d = addDays(d, -1);
      if (schedule.isWorkingDay(d)) left--;
    }
    return d;
  }

  /// Function Name: [ahead]
  ///
  /// Purpose: The [n]-th working day after [from] (n ≥ 1).
  ///
  /// Return type: [DateTime]
  DateTime ahead(DateTime from, int n) {
    DateTime d = dayOf(from);
    int left = n;
    while (left > 0) {
      d = addDays(d, 1);
      if (schedule.isWorkingDay(d)) left--;
    }
    return d;
  }

  /// Function Name: [spanEnd]
  ///
  /// Purpose: The last day of a run of [workingDays] working days starting
  /// on [start] (weekends inside the run included, like a real leave).
  ///
  /// Return type: [DateTime]
  DateTime spanEnd(DateTime start, int workingDays) {
    DateTime d = dayOf(start);
    int counted = schedule.isWorkingDay(d) ? 1 : 0;
    while (counted < workingDays) {
      d = addDays(d, 1);
      if (schedule.isWorkingDay(d)) counted++;
    }
    return d;
  }
}

/// Stable pseudo-random numbers (FNV-1a over a text key).
abstract final class TtDemoDice {
  /// Function Name: [roll]
  ///
  /// Purpose: 0 … [sides] − 1 for [key] (same key → same number).
  ///
  /// Return type: [int]
  static int roll(String key, int sides) {
    int hash = 0x811c9dc5;
    for (final int unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return sides <= 0 ? 0 : hash % sides;
  }
}
