/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: phase4_cubits_test.dart
/// Purpose: Unit tests for the phase-4 cubits: `RequestsCubit` (my
///          requests vs my approvals, counters, search / filter / employee),
///          `RequestFormCubit` (available types, errors revealed, uploads,
///          submit, permission refusal) and `RequestActionsCubit` (failure
///          kinds, reminder too soon).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/controller/request_form_cubit.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office');
const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick Leave', nameAr: 'إجازة مرضية');
const RequestType _doc = RequestType(id: 'doc', nameEn: 'Training', isAttachmentRequired: true);

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Moataz H', departmentId: 'dep-1'),
  TimeTrackerEmployee(email: 'amr@co.com', nameEn: 'Amr M', departmentId: 'dep-1'),
  TimeTrackerEmployee(email: 'sara@co.com', nameEn: 'Sara A', departmentId: 'dep-2'),
];

TimeTrackerRequest _req(String id, String who, RequestStatus s, {String manager = 'me@co.com', String dep = 'dep-1'}) =>
    TimeTrackerRequest(
      id: id,
      requesterEmail: who,
      requesterDepartmentId: dep,
      requestTypeId: 'sick',
      startAt: DateTime(2026, 10, 12),
      endAt: DateTime(2026, 10, 12, 23, 59),
      isAllDay: true,
      totalMinutes: 1440,
      status: s,
      approvalSteps: <RequestApprovalStep>[RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: manager)],
      currentStep: s == RequestStatus.pending ? ApprovalStepKind.manager : null,
    );

void main() {
  group('RequestsCubit', () {
    test('my requests vs the ones I approve; counters; search; employee; filter', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedRequestTypes(remote, <RequestType>[_sick]);
      seedRequests(remote, <TimeTrackerRequest>[
        _req('m1', 'me@co.com', RequestStatus.pending, manager: 'boss@co.com'),
        _req('m2', 'me@co.com', RequestStatus.canceledByHr, manager: 'boss@co.com'),
        _req('a1', 'amr@co.com', RequestStatus.pending),
        _req('a2', 'sara@co.com', RequestStatus.underReview, dep: 'dep-2'),
        _req('x', 'sara@co.com', RequestStatus.pending, manager: 'someone@co.com', dep: 'dep-2'),
      ]);
      final Phase4Kit kit = Phase4Kit(remote: remote, access: accessWith(allKeys()), people: _people);
      final RequestsCubit cubit = RequestsCubit(
        requests: kit.requests,
        types: kit.types,
        directory: kit.directory,
        access: kit.access,
      );
      await cubit.init();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final RequestsState s = cubit.state;
      expect(s.status, RequestsLoadStatus.loaded);
      expect(s.myRequests.map((TimeTrackerRequest r) => r.id).toSet(), <String>{'m1', 'm2'});
      expect(s.myCounts[RequestBucket.canceled], 1);
      expect(s.approvalRequests.map((TimeTrackerRequest r) => r.id).toSet(), <String>{'a1', 'a2'});
      expect(s.approvalCounts[RequestBucket.pending], 2, reason: 'under review counts as pending here');
      expect(s.typeOf(s.byId('a1')!)?.nameEn, 'Sick Leave');

      cubit.setBucket(RequestScope.mine, RequestBucket.pending);
      expect(cubit.state.visibleMine.single.id, 'm1');
      cubit.search(RequestScope.approvals, 'sara');
      expect(cubit.state.visibleApprovals.single.id, 'a2');
      cubit.search(RequestScope.approvals, '');
      cubit.setEmployee('amr@co.com');
      expect(cubit.state.visibleApprovals.single.id, 'a1');
      cubit.setEmployee('');
      cubit.setFilter(RequestScope.approvals, const RequestFilter(kind: RequestKind.transaction));
      expect(cubit.state.visibleApprovals, isEmpty);
      cubit.setGrid(RequestScope.mine, false);
      expect(cubit.state.mine.isGrid, isFalse);
      expect(cubit.state.approvals.isGrid, isTrue);
      expect(cubit.state.approvalRequesters.map((TimeTrackerEmployee e) => e.email).toSet(),
          <String>{'amr@co.com', 'sara@co.com'});
      await cubit.close();
    });
  });

  group('RequestFormCubit', () {
    Future<(RequestFormCubit, Phase4Kit)> build({Set<String>? on}) async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedAssignment(remote, location: _hq);
      seedRequestTypes(remote, <RequestType>[_sick, _doc]);
      final Phase4Kit kit = Phase4Kit(remote: remote, access: accessWith(on ?? allKeys()), people: _people, manager: 'boss@co.com');
      final RequestFormCubit cubit = RequestFormCubit(
        service: kit.requestService,
        attachments: FakeGroupUploads(),
        access: kit.access,
        pickFile: () async => null,
      );
      await cubit.init();
      return (cubit, kit);
    }

    test('loads the types; Submit grey until valid; a tap reveals the errors', () async {
      final (RequestFormCubit cubit, Phase4Kit _) = await build();
      expect(cubit.state.setup.types.map((RequestType t) => t.id), <String>['sick', 'doc']);
      expect(cubit.state.canSubmit, isFalse);
      expect(cubit.state.shows(RequestFormError.typeRequired), isFalse);
      expect(cubit.revealErrors(), isFalse);
      expect(cubit.state.shows(RequestFormError.typeRequired), isTrue);
      cubit.typeChanged(cubit.state.setup.types.last);
      cubit.startDateChanged(DateTime(2026, 10, 12));
      cubit.endDateChanged(DateTime(2026, 10, 13));
      expect(cubit.state.errors, <RequestFormError>{RequestFormError.attachmentsRequired});
      await cubit.uploadAttachment('cert.pdf', <int>[1, 2, 3]);
      expect(cubit.state.draft.attachments.single.name, 'cert.pdf');
      expect(cubit.state.canSubmit, isTrue);
      cubit.removeAttachment(0);
      expect(cubit.state.canSubmit, isFalse);
      cubit.allDayChanged(false);
      expect(cubit.state.errors, contains(RequestFormError.startTimeRequired));
      await cubit.close();
    });

    test('a too-large file is refused before upload', () async {
      final (RequestFormCubit cubit, Phase4Kit _) = await build();
      await cubit.uploadAttachment('big.bin', List<int>.filled(10 * 1024 * 1024 + 1, 0));
      expect(cubit.state.fileTooLarge, isTrue);
      expect(cubit.state.draft.attachments, isEmpty);
      await cubit.close();
    });

    test('submit stores the request; without the switch → denied failure', () async {
      final (RequestFormCubit cubit, Phase4Kit kit) = await build();
      cubit.typeChanged(cubit.state.setup.types.first);
      cubit.startDateChanged(DateTime(2026, 10, 12));
      cubit.endDateChanged(DateTime(2026, 10, 12));
      expect(await cubit.submit(isArabic: false), isTrue);
      expect(cubit.state.status, RequestFormStatus.success);
      expect((await kit.requests.watchRequests().first).single.status, RequestStatus.pending);
      await cubit.close();

      final (RequestFormCubit denied, Phase4Kit _) =
          await build(on: allKeys()..remove('Create_Time_Tracker_Request'));
      denied.typeChanged(denied.state.setup.types.first);
      denied.startDateChanged(DateTime(2026, 10, 12));
      denied.endDateChanged(DateTime(2026, 10, 12));
      expect(await denied.submit(isArabic: false), isFalse);
      expect(denied.state.status, RequestFormStatus.failure);
      expect(denied.state.permissionDenied, isTrue);
      denied.acknowledgeFailure();
      expect(denied.state.status, RequestFormStatus.editing);
      await denied.close();
    });
  });

  group('RequestActionsCubit', () {
    test('failures are classified; a reminder too soon keeps the earlier date', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedRequestTypes(remote, <RequestType>[_sick]);
      final DateTime last = DateTime.now().subtract(const Duration(hours: 3));
      seedRequests(remote, <TimeTrackerRequest>[
        _req('m1', 'me@co.com', RequestStatus.pending, manager: 'boss@co.com').copyWith(lastReminderAt: last),
        _req('a1', 'amr@co.com', RequestStatus.pending),
      ]);
      final Phase4Kit kit = Phase4Kit(remote: remote, access: accessWith(allKeys()), people: _people);
      final RequestActionsCubit cubit = RequestActionsCubit(requests: kit.requestService, approvals: kit.approvalService);
      final TimeTrackerRequest mine = (await kit.requests.fetchRequest(id: 'm1'))!;
      final TimeTrackerRequest theirs = (await kit.requests.fetchRequest(id: 'a1'))!;

      expect(await cubit.sendReminder(mine, isArabic: false), isFalse);
      expect(cubit.state.reminderTooSoon, isTrue);
      expect(cubit.state.reminderSentAt!.difference(last).inSeconds.abs() < 2, isTrue);

      expect(cubit.mayDecide(theirs), isTrue);
      expect(cubit.mayDecide(mine), isFalse);
      expect(await cubit.approve(mine, typeName: const TimeTrackerTypeName(en: 'Sick Leave'), isArabic: false), isFalse);
      expect(cubit.state.failure, TimeTrackerActionFailure.denied);
      cubit.acknowledgeFailure();
      expect(cubit.state.failure, TimeTrackerActionFailure.none);

      expect(await cubit.approve(theirs, typeName: const TimeTrackerTypeName(en: 'Sick Leave'), isArabic: false), isTrue);
      expect((await kit.requests.fetchRequest(id: 'a1'))!.status, RequestStatus.approved);
      expect(await cubit.addComment(theirs, 'Enjoy', asApprover: true), isTrue);
      await cubit.close();
    });
  });
}
