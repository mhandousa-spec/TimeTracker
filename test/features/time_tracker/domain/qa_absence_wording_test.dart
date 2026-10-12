/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: qa_absence_wording_test.dart
/// Purpose: Tests for the QA full-pass bugs fixed on 9/10/2026:
///          KP-TT-013 (the employee dashboard, the Home cards and the HR view
///          count absences with ONE day rule — guessed absences for days
///          the sweep has not written, non-working days excluded, ≤ 31 days,
///          whole-day leave only) and KP-TT-011 ("1 request" / "طلب واحد"
///          in the pending-approvals notification, a seeded old template
///          text read with the new wording).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_events.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/count_wording.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_days.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/personal_dashboard_stats.dart';

const String _salma = 'salma@co.com';

/// Jeddah: every day a working day, 10:00–18:00, late after 10 minutes.
const WorkSchedule _jeddah = WorkSchedule(startMinutes: 10 * 60, endMinutes: 18 * 60, lateAfterMinutes: 10);

/// Head Office: Sun–Thu.
const WorkSchedule _sunThu = WorkSchedule(
  startMinutes: 8 * 60,
  endMinutes: 16 * 60,
  workingDays: <int>[7, 1, 2, 3, 4],
  lateAfterMinutes: 10,
);

AttendanceDay _stored(DateTime date, AttendanceStatus status, {bool session = false}) => AttendanceDay(
      id: '${_salma}_${date.day}',
      employeeEmail: _salma,
      date: date,
      status: status,
      sessions: session ? <AttendanceSession>[AttendanceSession(checkInAt: date.add(const Duration(hours: 10)))] : const <AttendanceSession>[],
    );

TimeTrackerRequest _leave(DateTime start, DateTime end, {bool allDay = true}) => TimeTrackerRequest(
      id: 'l${start.day}${start.hour}',
      requesterEmail: _salma,
      startAt: start,
      endAt: end,
      isAllDay: allDay,
      requestTypeId: 'annual',
      status: RequestStatus.approved,
    );

/// What the HR view says for Salma in [span] (the same book the HR stats use).
Map<HrDayKind, int> _hr({
  required List<AttendanceDay> days,
  required List<TimeTrackerRequest> requests,
  required WorkSchedule schedule,
  required DateTime start,
  required DateTime now,
  required DateSpan span,
}) =>
    HrDayBook.build(
      days: days,
      requests: requests,
      placements: <String, EmployeePlacement>{
        _salma: EmployeePlacement(email: _salma, locationId: 'jeddah', schedule: schedule, startDate: start),
      },
      now: now,
    ).countIn(_salma, span);

/// What Salma's own (employee) dashboard says for [span].
PersonalDashboardStats _mine({
  required List<AttendanceDay> days,
  required List<TimeTrackerRequest> requests,
  required WorkSchedule schedule,
  required DateTime start,
  required DateTime now,
  required DateSpan span,
}) =>
    PersonalDashboardStats.compute(
      days: days,
      requests: requests,
      email: _salma,
      span: span,
      schedule: schedule,
      assignmentStart: start,
      now: now,
    );

void main() {
  group('QA KP-TT-013 — one absence rule for the employee dashboard, Home and HR', () {
    // The QA case: assigned to Jeddah from 05 Oct, no check-ins, Friday 09
    // Oct after 10:10 — the sweep has not written anything (Salma never
    // opened the module).
    final DateTime now = DateTime(2026, 10, 9, 10, 30);
    final DateTime start = DateTime(2026, 10, 5);

    test('Salma: HR "5 absences" = her dashboard Absence 5 (was 0) — Year and Month', () {
      for (final DashboardRange range in <DashboardRange>[DashboardRange.year, DashboardRange.month, DashboardRange.week]) {
        final DateSpan span = DateSpan.of(range, now);
        final int hr = _hr(days: const <AttendanceDay>[], requests: const <TimeTrackerRequest>[], schedule: _jeddah, start: start, now: now, span: span)[HrDayKind.absent]!;
        final PersonalDashboardStats me = _mine(days: const <AttendanceDay>[], requests: const <TimeTrackerRequest>[], schedule: _jeddah, start: start, now: now, span: span);
        expect(me.absent, hr, reason: range.name);
      }
      final DateSpan year = DateSpan.of(DashboardRange.year, now);
      expect(_mine(days: const <AttendanceDay>[], requests: const <TimeTrackerRequest>[], schedule: _jeddah, start: start, now: now, span: year).absent, 5,
          reason: '5, 6, 7, 8 Oct + today after start + Late After');
      // Before 10:10 today is not yet an absence — on both screens.
      final DateTime early = DateTime(2026, 10, 9, 10, 5);
      expect(_mine(days: const <AttendanceDay>[], requests: const <TimeTrackerRequest>[], schedule: _jeddah, start: start, now: early, span: year).absent, 4);
      expect(_hr(days: const <AttendanceDay>[], requests: const <TimeTrackerRequest>[], schedule: _jeddah, start: start, now: early, span: year)[HrDayKind.absent], 4);
    });

    test('stored days + guessed days, non-working days excluded, whole-day leave only — same on both', () {
      // Sun–Thu week; 4 Oct (Sun) … 9 Oct (Fri, day off).
      final DateTime friday = DateTime(2026, 10, 9, 17);
      final List<AttendanceDay> days = <AttendanceDay>[
        _stored(DateTime(2026, 10, 4), AttendanceStatus.present, session: true),
        _stored(DateTime(2026, 10, 5), AttendanceStatus.late, session: true),
        _stored(DateTime(2026, 10, 6), AttendanceStatus.absent), // covered by leave below → leave
        // 7 Oct: nothing stored, a 2-hour leave only → still absent (guessed)
        // 8 Oct: nothing stored, nothing taken → absent (guessed)
        _stored(DateTime(2026, 10, 3), AttendanceStatus.absent), // Saturday: untrusted, ignored
      ];
      final List<TimeTrackerRequest> leaves = <TimeTrackerRequest>[
        _leave(DateTime(2026, 10, 6), DateTime(2026, 10, 6)),
        _leave(DateTime(2026, 10, 7, 9), DateTime(2026, 10, 7, 11), allDay: false),
      ];
      final DateSpan month = DateSpan.of(DashboardRange.month, friday);
      final DateTime from = DateTime(2026, 10, 1);
      final Map<HrDayKind, int> hr = _hr(days: days, requests: leaves, schedule: _sunThu, start: from, now: friday, span: month);
      final PersonalDashboardStats me = _mine(days: days, requests: leaves, schedule: _sunThu, start: from, now: friday, span: month);
      // 1 (Thu) + 7, 8 Oct guessed = 3 absences; 6 Oct = leave; 2, 3, 9, 10 = days off.
      expect(hr[HrDayKind.absent], 3);
      expect(me.absent, 3);
      expect(me.present, (hr[HrDayKind.present] ?? 0) + (hr[HrDayKind.late] ?? 0));
      expect(me.present, 2);
      expect(me.late, hr[HrDayKind.late]);
      expect(me.late, 1);
    });

    test('never further back than 31 days (the sweep\'s own limit) — same on both', () {
      final DateTime later = DateTime(2026, 12, 20, 19);
      final DateTime longAgo = DateTime(2026, 9, 1);
      final DateSpan year = DateSpan.of(DashboardRange.year, later);
      final int hr = _hr(days: const <AttendanceDay>[], requests: const <TimeTrackerRequest>[], schedule: _jeddah, start: longAgo, now: later, span: year)[HrDayKind.absent]!;
      final int mine = _mine(days: const <AttendanceDay>[], requests: const <TimeTrackerRequest>[], schedule: _jeddah, start: longAgo, now: later, span: year).absent;
      expect(mine, hr);
      expect(mine, 32, reason: '19 Nov … 20 Dec (31 days back + today)');
    });

    test('unknown working week (HR shift): nothing guessed, an untrusted stored absence ignored', () {
      const WorkSchedule hrShift = WorkSchedule(startMinutes: 9 * 60, endMinutes: 17 * 60, isWorkingWeekKnown: false);
      final List<AttendanceDay> days = <AttendanceDay>[_stored(DateTime(2026, 10, 2), AttendanceStatus.absent)];
      final DateSpan month = DateSpan.of(DashboardRange.month, now);
      expect(_mine(days: days, requests: const <TimeTrackerRequest>[], schedule: hrShift, start: start, now: now, span: month).absent, 0);
      expect(_hr(days: days, requests: const <TimeTrackerRequest>[], schedule: hrShift, start: start, now: now, span: month)[HrDayKind.absent], 0);
    });

    test('no schedule known yet: only stored days count (nothing guessed)', () {
      final List<AttendanceDay> days = <AttendanceDay>[_stored(DateTime(2026, 10, 6), AttendanceStatus.absent)];
      final PersonalDashboardStats me = PersonalDashboardStats.compute(
        days: days,
        requests: const <TimeTrackerRequest>[],
        email: _salma,
        span: DateSpan.of(DashboardRange.month, now),
        now: now,
      );
      expect(me.absent, 1);
    });

    test('Home "Presence" card counts the month with the same rule', () {
      final TimeTrackerHomeStats home = TimeTrackerHomeStatsRules.compute(
        days: const <AttendanceDay>[],
        requests: const <TimeTrackerRequest>[],
        email: _salma,
        now: now,
        schedule: _jeddah,
        assignmentStart: start,
      );
      expect(home.absent, 5);
    });
  });

  group('QA KP-TT-011 — "1 request" / "طلب واحد"', () {
    test('count wording: EN singular / plural; AR number agreement (no tanween)', () {
      expect(TimeTrackerCountWording.requests(1, arabic: false), '1 request');
      expect(TimeTrackerCountWording.requests(2, arabic: false), '2 requests');
      expect(TimeTrackerCountWording.requests(0, arabic: false), '0 requests');
      String ar(int n) => TimeTrackerCountWording.requests(n, arabic: true);
      expect(ar(1), 'طلب واحد');
      expect(ar(2), 'طلبان');
      expect(ar(3), '3 طلبات');
      expect(ar(10), '10 طلبات');
      expect(ar(11), '11 طلبا');
      expect(ar(99), '99 طلبا');
      expect(ar(100), '100 طلب');
      expect(ar(102), '102 طلب');
      expect(ar(103), '103 طلبات');
      expect(ar(111), '111 طلبا');
      for (final int n in <int>[1, 2, 3, 11, 100]) {
        expect(RegExp('[ً-ْ]').hasMatch(ar(n)), isFalse, reason: 'no tanween / diacritics');
      }
    });

    String render(String text, Map<TemplateVariable, String> values) {
      String out = text;
      values.forEach((TemplateVariable v, String value) => out = out.replaceAll(v.token, value));
      return out;
    }

    test('the pending-approvals notification reads correctly for 1, 2, 3 and 11 requests (EN + AR)', () {
      const TimeTrackerNotificationEvent e = TimeTrackerNotificationEvent.pendingApprovalsManager;
      final Map<int, (String, String)> expected = <int, (String, String)>{
        1: ('You currently have 1 request pending your review', 'لديك حالياً طلب واحد بانتظار مراجعتك'),
        2: ('You currently have 2 requests pending your review', 'لديك حالياً طلبان بانتظار مراجعتك'),
        3: ('You currently have 3 requests pending your review', 'لديك حالياً 3 طلبات بانتظار مراجعتك'),
        11: ('You currently have 11 requests pending your review', 'لديك حالياً 11 طلبا بانتظار مراجعتك'),
      };
      expected.forEach((int n, (String, String) text) {
        final Map<TemplateVariable, String> en = TimeTrackerNotificationService.pendingCountVariables(n);
        final Map<TemplateVariable, String> ar = <TemplateVariable, String>{
          ...en,
          ...TimeTrackerNotificationService.pendingCountVariables(n, arabic: true),
        };
        final String bodyEn = render(e.bodyEn, en);
        final String bodyAr = render(e.bodyAr, ar);
        expect(bodyEn, startsWith(text.$1));
        expect(bodyAr, startsWith(text.$2));
        expect('$bodyEn $bodyAr', isNot(contains('{{')));
        expect(RegExp(r'(^|\D)1 requests').hasMatch(bodyEn), isFalse);
        expect(RegExp(r'(^|\D)1 طلبات').hasMatch(bodyAr), isFalse);
        expect(en[TemplateVariable.count], '$n', reason: '{{count}} stays the plain number');
      });
      expect(e.variables, containsAll(<TemplateVariable>[TemplateVariable.count, TemplateVariable.countedRequests]));
    });

    NotificationTemplateModel stored({required String en, required String ar, String module = 'time_tracker', String key = 'pending_approvals_manager'}) =>
        NotificationTemplateModel(
          id: '${module}_$key',
          module: module,
          eventType: key,
          isEnabled: false,
          selectedNotificationTypes: const <String>['push'],
          subjectEnglish: 'Subject',
          subjectArabic: 'عنوان',
          bodyEnglish: en,
          bodyArabic: ar,
          createdAt: DateTime(2026, 10, 1),
          updatedAt: DateTime(2026, 10, 1),
        );

    test('a stored template still holding the OLD default is read with the new wording; edits are kept', () {
      final List<String> old = TimeTrackerNotificationEvent.supersededBodies['pending_approvals_manager']!;
      final NotificationTemplateModel seeded = NotificationTemplateService.withoutSupersededText(stored(en: old[0], ar: old[1]));
      expect(seeded.bodyEnglish, TimeTrackerNotificationEvent.pendingApprovalsManager.bodyEn);
      expect(seeded.bodyArabic, TimeTrackerNotificationEvent.pendingApprovalsManager.bodyAr);
      expect(seeded.isEnabled, isFalse, reason: 'the switch is never touched');
      expect(seeded.subjectEnglish, 'Subject');
      expect(seeded.selectedNotificationTypes, <String>['push']);

      final NotificationTemplateModel edited =
          NotificationTemplateService.withoutSupersededText(stored(en: 'Pending: {{count}}', ar: old[1]));
      expect(edited.bodyEnglish, 'Pending: {{count}}', reason: 'an admin edit stays');
      expect(edited.bodyArabic, TimeTrackerNotificationEvent.pendingApprovalsManager.bodyAr);

      final NotificationTemplateModel other =
          NotificationTemplateService.withoutSupersededText(stored(en: old[0], ar: old[1], module: 'todo'));
      expect(other.bodyEnglish, old[0], reason: 'other modules untouched');
    });
  });
}
