/// Module: test / calendar / time_tracker
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_calendar_entries_test.dart
/// Purpose: Unit tests for `CalendarDataService.timeTrackerCalendarEntries`
///          (→ `TimeTrackerCalendarSource.entries`), the pure half of the
///          Time Tracker calendar loader (phase 6): approved leaves on every
///          day, pending requests, transactions, late / absent days, approvals
///          waiting for me, the gates, the window — plus the catalogue, the
///          module chip / palette / status codes the screen filters on, and
///          where a tap leads (`CalendarEventTap.destinationOf`).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/data_source/calendar_data_service.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_catalog.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/time_tracker_module/time_tracker_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/theme/calendar_module_palette.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/calendar_event_tap.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_module_entry.dart';

const String _me = 'me@co.com';

TimeTrackerRequest _req(
  String id, {
  String who = _me,
  RequestStatus status = RequestStatus.pending,
  required DateTime start,
  DateTime? end,
  bool tx = false,
}) =>
    TimeTrackerRequest(
      id: id,
      requesterEmail: who,
      requestTypeId: tx ? '' : 'annual',
      isTransaction: tx,
      startAt: start,
      endAt: end ?? start,
      status: status,
    );

void main() {
  // Monday 12 Oct 2026, 10:00.
  final DateTime now = DateTime(2026, 10, 12, 10);
  setUpAll(() => initializeDateFormatting('en'));

  List<CalendarEventModel> run(
    List<TimeTrackerRequest> requests, {
    List<AttendanceDay> days = const <AttendanceDay>[],
    bool showRequests = true,
    bool showAttendance = true,
    bool Function(TimeTrackerRequest)? waits,
    bool isArabic = false,
  }) =>
      CalendarDataService.timeTrackerCalendarEntries(
        requests: requests,
        days: days,
        userEmail: _me,
        now: now,
        isArabic: isArabic,
        showRequests: showRequests,
        showAttendance: showAttendance,
        waitsForMe: waits,
        typeNameOf: (TimeTrackerRequest r) => r.isTransaction ? '' : 'Annual Vacation',
        personNameOf: (String e) => e == 'a@co.com' ? 'Amal S' : e,
      );

  Iterable<TimeTrackerCalendarEventLike> typesOf(List<CalendarEventModel> e) =>
      e.map((CalendarEventModel m) => TimeTrackerCalendarEventLike(m.type! as TimeTrackerCalendarEvent, m));

  test('an approved leave: one "Approved Leave" card per day, titled with the type, Scheduled', () {
    final List<CalendarEventModel> e = run(<TimeTrackerRequest>[
      _req('a', status: RequestStatus.approved, start: DateTime(2026, 10, 14), end: DateTime(2026, 10, 16)),
    ]);
    expect(e, hasLength(3));
    expect(e.map((CalendarEventModel m) => m.date.day), <int>[14, 15, 16]);
    for (final CalendarEventModel m in e) {
      expect(m.type, TimeTrackerCalendarEvent.leaveApproved);
      expect(m.taskName, 'Annual Vacation');
      expect(m.status, 'Scheduled');
      expect(m.requestId, 'a');
      expect(m.moduleName, AppModule.timeTracker.labelEn);
      expect(m.time, isNotEmpty, reason: 'the day timeline places a card by its time');
    }
  });

  test('under review counts as approved leave; pending → "Request Pending Approval"; rejected / canceled → nothing', () {
    final List<CalendarEventModel> e = run(<TimeTrackerRequest>[
      _req('r', status: RequestStatus.underReview, start: DateTime(2026, 10, 20)),
      _req('p', start: DateTime(2026, 10, 21), end: DateTime(2026, 10, 22)),
      _req('x', status: RequestStatus.rejected, start: DateTime(2026, 10, 23)),
      _req('c', status: RequestStatus.canceledByHr, start: DateTime(2026, 10, 24)),
    ]);
    expect(typesOf(e).map((TimeTrackerCalendarEventLike t) => t.type), <TimeTrackerCalendarEvent>[
      TimeTrackerCalendarEvent.leaveApproved,
      TimeTrackerCalendarEvent.requestPending,
      TimeTrackerCalendarEvent.requestPending,
    ]);
    expect(e.last.status, 'Pending Approval');
  });

  test('transactions: pending / approved on the corrected day (enum title), rejected → nothing', () {
    final List<CalendarEventModel> e = run(<TimeTrackerRequest>[
      _req('t1', tx: true, start: DateTime(2026, 10, 5, 9), end: DateTime(2026, 10, 5, 17)),
      _req('t2', tx: true, status: RequestStatus.approved, start: DateTime(2026, 10, 6, 9), end: DateTime(2026, 10, 6, 17)),
      _req('t3', tx: true, status: RequestStatus.rejected, start: DateTime(2026, 10, 7, 9)),
    ]);
    expect(e.map((CalendarEventModel m) => m.type), <TimeTrackerCalendarEvent>[
      TimeTrackerCalendarEvent.transactionPending,
      TimeTrackerCalendarEvent.transactionApproved,
    ]);
    expect(e.first.taskName, 'Attendance Correction Pending');
    expect(e.first.time, '09:00 AM');
    expect(e.last.status, 'Attendance Corrected', reason: 'no chip: status = the English title');
  });

  test('late and absent days from Attendance (late carries the minutes)', () {
    final List<CalendarEventModel> e = run(const <TimeTrackerRequest>[], days: <AttendanceDay>[
      AttendanceDay(
        id: 'd1',
        employeeEmail: _me,
        date: DateTime(2026, 10, 6),
        status: AttendanceStatus.late,
        lateMinutes: 25,
        sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 6, 9, 25))],
      ),
      AttendanceDay(id: 'd2', employeeEmail: _me, date: DateTime(2026, 10, 7), status: AttendanceStatus.absent),
      AttendanceDay(id: 'd3', employeeEmail: _me, date: DateTime(2026, 10, 8), status: AttendanceStatus.present),
    ]);
    expect(e.map((CalendarEventModel m) => m.type),
        <TimeTrackerCalendarEvent>[TimeTrackerCalendarEvent.lateArrival, TimeTrackerCalendarEvent.absentDay]);
    expect(e.first.description, contains('25 minutes'));
    expect(e.first.time, '09:25 AM');
    expect(e.first.requestId, isNull);
  });

  test('approvals waiting for me: every requested day, "Requester · Type", never my own', () {
    final List<CalendarEventModel> e = run(
      <TimeTrackerRequest>[
        _req('w', who: 'a@co.com', start: DateTime(2026, 10, 19), end: DateTime(2026, 10, 20)),
        _req('n', who: 'b@co.com', start: DateTime(2026, 10, 19)),
        _req('mine', start: DateTime(2026, 10, 25)),
      ],
      waits: (TimeTrackerRequest r) => r.id != 'n',
    );
    final List<CalendarEventModel> approvals =
        e.where((CalendarEventModel m) => m.type == TimeTrackerCalendarEvent.approvalPending).toList();
    expect(approvals, hasLength(2));
    expect(approvals.first.taskName, 'Amal S · Annual Vacation');
    expect(approvals.first.requestId, 'w');
    expect(approvals.first.status, 'Pending Approval');
  });

  test('gates: no requests / no attendance switches → only what is allowed', () {
    final List<TimeTrackerRequest> reqs = <TimeTrackerRequest>[
      _req('a', status: RequestStatus.approved, start: DateTime(2026, 10, 14)),
      _req('t', tx: true, start: DateTime(2026, 10, 5, 9)),
    ];
    final List<AttendanceDay> days = <AttendanceDay>[
      AttendanceDay(id: 'd2', employeeEmail: _me, date: DateTime(2026, 10, 7), status: AttendanceStatus.absent),
    ];
    expect(run(reqs, days: days, showRequests: false, showAttendance: false), isEmpty);
    expect(run(reqs, days: days, showRequests: false).map((CalendarEventModel m) => m.type),
        <TimeTrackerCalendarEvent>[TimeTrackerCalendarEvent.transactionPending, TimeTrackerCalendarEvent.absentDay]);
  });

  test('window: 60 days back, 180 ahead', () {
    final List<CalendarEventModel> e = run(<TimeTrackerRequest>[
      _req('old', status: RequestStatus.approved, start: DateTime(2026, 7, 1)),
      _req('far', status: RequestStatus.approved, start: DateTime(2027, 6, 1)),
      _req('long', status: RequestStatus.approved, start: DateTime(2026, 8, 12), end: DateTime(2026, 8, 15)),
    ]);
    expect(e.map((CalendarEventModel m) => '${m.date.month}/${m.date.day}'), <String>['8/13', '8/14', '8/15']);
  });

  test('Arabic: enum titles / descriptions in Arabic', () {
    final List<CalendarEventModel> e = run(<TimeTrackerRequest>[
      _req('t', tx: true, start: DateTime(2026, 10, 5, 9)),
    ], isArabic: true);
    expect(e.single.taskName, 'تصحيح حضور بانتظار الموافقة');
  });

  group('catalogue, chip, palette, tap', () {
    test('registered in CalendarCatalog under Time Tracker; ids resolve', () {
      expect(CalendarCatalog.eventsOf(AppModule.timeTracker), TimeTrackerCalendarEvent.values);
      for (final TimeTrackerCalendarEvent t in TimeTrackerCalendarEvent.values) {
        expect(CalendarCatalog.findById(t.id), t);
        expect(t.colorValue, CalendarModulePalette.timeTracker.toARGB32());
        expect(RegExp('[ً-ْ]').hasMatch('${t.titleAr}${t.descriptionAr}'), isFalse, reason: 'no tanween');
      }
    });

    test('the module name every card carries maps to the Time Tracker colour', () {
      expect(CalendarModulePalette.colorOf(AppModule.timeTracker.labelEn), CalendarModulePalette.timeTracker);
      expect(CalendarModulePalette.colorOf(AppModule.timeTracker.labelAr), CalendarModulePalette.timeTracker);
    });

    test('tap: a request card opens it (approver details for an approval), a late / absent card the day', () {
      CalendarEventModel card(TimeTrackerCalendarEvent t, {String? id}) =>
          CalendarEventModel.fromType(t, sourceDate: DateTime(2026, 10, 7), isArabic: false, requestId: id,
              variables: t.variables.isEmpty ? const {} : {t.variables.first: '5'});
      final TimeTrackerModuleEntry leave =
          CalendarEventTap.destinationOf(card(TimeTrackerCalendarEvent.leaveApproved, id: 'r1'))! as TimeTrackerModuleEntry;
      expect(leave.initialRequestId, 'r1');
      expect(leave.initialAsApproval, isFalse);
      final TimeTrackerModuleEntry approval =
          CalendarEventTap.destinationOf(card(TimeTrackerCalendarEvent.approvalPending, id: 'r2'))! as TimeTrackerModuleEntry;
      expect(approval.initialAsApproval, isTrue);
      final TimeTrackerModuleEntry absent =
          CalendarEventTap.destinationOf(card(TimeTrackerCalendarEvent.absentDay))! as TimeTrackerModuleEntry;
      expect(absent.initialAttendanceDate, DateTime(2026, 10, 7));
      expect(absent.initialRequestId, isNull);
      final TimeTrackerModuleEntry seeded =
          CalendarEventTap.destinationOf(card(TimeTrackerCalendarEvent.requestPending))! as TimeTrackerModuleEntry;
      expect(seeded.initialRequestId, isNull, reason: 'no id → the module');
    });
  });
}

/// Pairs a card with its enum (readable expectations).
class TimeTrackerCalendarEventLike {
  const TimeTrackerCalendarEventLike(this.type, this.model);

  final TimeTrackerCalendarEvent type;
  final CalendarEventModel model;
}
