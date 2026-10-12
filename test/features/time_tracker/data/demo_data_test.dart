/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: demo_data_test.dart
/// Purpose: The DEBUG-ONLY demo data tool (9/10/2026): what Load writes for
///          the DM-003 company, that every request status / attendance kind
///          / document is there, that nothing real is overwritten, that a
///          second Load writes nothing, and that Remove deletes ONLY the
///          `Is_Demo` documents.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass)

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_request_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_builder.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/name_case.dart';

import '../_support/time_tracker_phase5_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';
import '../_support/tt_demo_seed.dart';

void main() {
  setUpAll(initTimeTrackerTestStorage);

  group('demo plan (pure)', () {
    final TtDemoInput input = TtDemoInput(
      me: kTtPeople.first,
      others: kTtPeople.skip(1).toList(),
      now: DateTime(2026, 10, 8, 14, 30), // a Thursday
      managerOf: kTtManagers,
      hrApprovers: const <String>['mona.elsayed@dm003.test'],
    );
    final TtDemoPlan plan = TimeTrackerDemoBuilder.build(input, isArabic: false);

    test('the signed-in user has a request in EVERY status, plus transactions', () {
      final List<TimeTrackerRequest> mine = <TimeTrackerRequest>[
        for (final TtDemoRequest r in plan.requests)
          if (r.request.requesterEmail == kTtOwner) r.request,
      ];
      for (final RequestStatus s in RequestStatus.values) {
        expect(mine.any((TimeTrackerRequest r) => r.status == s), isTrue, reason: s.name);
      }
      expect(mine.where((TimeTrackerRequest r) => r.isTransaction).map((TimeTrackerRequest r) => r.status).toSet(),
          <RequestStatus>{RequestStatus.pending, RequestStatus.approved});
    });

    test('pending at the manager AND pending at HR exist (Approvals)', () {
      final List<TimeTrackerRequest> pending = <TimeTrackerRequest>[
        for (final TtDemoRequest r in plan.requests)
          if (r.request.status == RequestStatus.pending) r.request,
      ];
      expect(pending.any((TimeTrackerRequest r) => r.currentStep?.name == 'manager'), isTrue);
      expect(pending.any((TimeTrackerRequest r) => r.currentStep?.name == 'hr'), isTrue);
    });

    test('rejected / canceled requests carry their reason; documents are professional PDFs', () {
      for (final TtDemoRequest r in plan.requests) {
        if (r.request.status == RequestStatus.canceled || r.request.status == RequestStatus.canceledByHr) {
          expect(r.request.cancellationReason, isNotEmpty);
        }
      }
      final List<String> files = <String>[
        for (final TtDemoRequest r in plan.requests)
          for (final TtDemoDocument d in r.documents) d.fileName,
      ];
      expect(files, contains('Medical Report — Bayanatz Transformation.pdf'));
      expect(files.any((String f) => f.startsWith('Travel Order')), isTrue);
      expect(files.any((String f) => f.startsWith('Workshop Invitation')), isTrue);
      expect(files.every((String f) => f.endsWith('.pdf')), isTrue);
    });

    test('30 days of attendance per employee: present, late, absent, leave, corrected, auto check-out, alerts', () {
      expect(plan.days.map((TtDemoDay d) => d.day.employeeEmail).toSet().length, kTtPeople.length);
      final Set<AttendanceStatus?> kinds = <AttendanceStatus?>{for (final TtDemoDay d in plan.days) d.day.status};
      expect(kinds, containsAll(<AttendanceStatus>[
        AttendanceStatus.present,
        AttendanceStatus.late,
        AttendanceStatus.absent,
        AttendanceStatus.vacation,
        AttendanceStatus.sickLeave,
        AttendanceStatus.excused,
      ]));
      expect(plan.days.any((TtDemoDay d) => d.day.isCorrectedByTransaction && d.before != null), isTrue);
      expect(plan.days.any((TtDemoDay d) => d.isAutoCheckOut), isTrue);
      expect(plan.days.any((TtDemoDay d) => d.alerts.any((TtDemoAlert a) => a.type == 'late_arrival')), isTrue);
      expect(plan.days.any((TtDemoDay d) => d.day.sessions.any((AttendanceSession s) => s.pauses.isNotEmpty)), isTrue);
      expect(plan.days.any((TtDemoDay d) => d.day.sessions.any((AttendanceSession s) => s.workLocationType.name == 'remote')),
          isTrue);
      // The signed-in user's today is never written (their real check-in).
      expect(
        plan.days.any((TtDemoDay d) =>
            d.day.employeeEmail == kTtOwner && d.day.date == DateTime(2026, 10, 8)),
        isFalse,
      );
    });

    test('balances: 21 days, used = the approved annual days of the year', () {
      expect(plan.balances.length, kTtPeople.length);
      expect(plan.balances.every((b) => b.totalDays == 21 && b.year == 2026), isTrue);
      expect(plan.balances.any((b) => b.usedDays > 0), isTrue);
    });

    test('Arabic free texts in Arabic (no tanween)', () {
      final TtDemoPlan ar = TimeTrackerDemoBuilder.build(input, isArabic: true);
      final String text = ar.requests.map((TtDemoRequest r) => r.request.description).join(' ');
      expect(RegExp(r'[؀-ۿ]').hasMatch(text), isTrue);
      expect(RegExp('[ً-ٍ]').hasMatch(text), isFalse);
    });
  });

  group('demo service over the in-memory store', () {
    testWidgets('Load writes tagged history docs, keeps real ones, a second Load writes nothing, Remove deletes only demo',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = ttDemoHarness();
      // A REAL check-in of a colleague on a day the demo would also write.
      final DateTime now = DateTime.now();
      final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
      seedDays(h.remote, <AttendanceDay>[
        AttendanceDay(
          id: TimeTrackerFirestorePaths.attendanceDocId('omar.farouk@dm003.test', yesterday),
          employeeEmail: 'omar.farouk@dm003.test',
          date: yesterday,
          status: AttendanceStatus.present,
        ),
      ]);
      final String realId = TimeTrackerFirestorePaths.attendanceDocId('omar.farouk@dm003.test', yesterday);
      final TtDemoResult first = await seedTtDemo(tester, h);
      expect(first.documents, greaterThan(100));
      expect(first.files, greaterThan(3));

      final Map<String, Map<String, dynamic>> requests = h.remote.store[TimeTrackerFirestorePaths.requests]!;
      final Map<String, dynamic> one = requests.values.first;
      expect(TimeTrackerHistoryCodec.lastOf(one, TtDemoIds.field), isTrue);
      expect(TimeTrackerHistoryCodec.timestampsOf(one), isNotEmpty);
      expect(TimeTrackerRequestModel.hasKnownStatus(one), isTrue);
      // The real day is untouched (no Is_Demo, still the colleague's own row).
      final Map<String, dynamic> real = h.remote.store[TimeTrackerFirestorePaths.attendance]![realId]!;
      expect(TimeTrackerHistoryCodec.lastOf(real, TtDemoIds.field), isNull);
      // A corrected day has two history rows (as recorded, then corrected).
      expect(
        h.remote.store[TimeTrackerFirestorePaths.attendance]!.values.any((Map<String, dynamic> d) =>
            TimeTrackerHistoryCodec.rowCount(d) == 2 &&
            TimeTrackerHistoryCodec.lastOf(d, AttendanceDayModel.fIsCorrected) == true),
        isTrue,
      );

      TtDemoResult? again;
      await tester.runAsync(() async => again = await ttDemoService(h).load(isArabic: false));
      expect(again!.alreadyLoaded, isTrue);

      TtDemoResult? removed;
      await tester.runAsync(() async => removed = await ttDemoService(h).remove());
      expect(removed!.documents, greaterThanOrEqualTo(first.documents));
      expect(removed!.fileUrls, isNotEmpty);
      for (final String path in TimeTrackerDemoService.collections) {
        for (final Map<String, dynamic> d in (h.remote.store[path] ?? <String, Map<String, dynamic>>{}).values) {
          expect(TimeTrackerHistoryCodec.lastOf(d, TtDemoIds.field), isNot(true), reason: path);
        }
      }
      expect(h.remote.store[TimeTrackerFirestorePaths.attendance]![realId], isNotNull);
    });
  });

  group('NameCase (owner 14:17 #3)', () {
    test('lower-case names / titles in proper case; Arabic, acronyms and mixed case untouched', () {
      expect(NameCase.proper('salma fathy'), 'Salma Fathy');
      expect(NameCase.proper('service center coordinator'), 'Service Center Coordinator');
      expect(NameCase.proper('director of administrative affairs'), 'Director of Administrative Affairs');
      expect(NameCase.proper('Director of Administrative Affairs'), 'Director of Administrative Affairs');
      expect(NameCase.proper('SALMA FATHY'), 'Salma Fathy');
      expect(NameCase.proper('HR Officer'), 'HR Officer');
      expect(NameCase.proper('mohamed al-sayed'), 'Mohamed Al-Sayed');
      expect(NameCase.proper('McDonald'), 'McDonald');
      expect(NameCase.proper('سلمى فتحي'), 'سلمى فتحي');
      expect(NameCase.proper('salma.fathy@dm003.test'), 'salma.fathy@dm003.test');
      expect(NameCase.proper(''), '');
    });
  });
}
