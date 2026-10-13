/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: phase4_screens_test.dart
/// Purpose: Widget tests for the phase-4 screens: the Requests tab
///          (counters, cards / table, Send Reminder, Export / + Request
///          gates), the request form (grey Submit reveals errors, All Day
///          off shows the times), the requester's details per status, the
///          Approvals tab and approver details (Approve / Reject only for
///          the current step's approver), the "not available" guard, phone
///          and Arabic (RTL).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/controller/request_form_cubit.dart';

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/pages/request_details_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office', nameAr: 'المكتب الرئيسي');
const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick Leave', nameAr: 'إجازة مرضية');

Finder _tab(String label) => find.descendant(of: find.byType(CustomTabs), matching: find.text(label));
Finder _key(String k) => find.byKey(ValueKey<String>(k));

Future<void> _open(WidgetTester tester, TimeTrackerHarness h, String label) async {
  await tester.ensureVisible(_tab(label));
  await tester.pump();
  await tester.tap(_tab(label));
  await h.settle(tester);
}

TimeTrackerRequest _req(
  String id,
  RequestStatus status, {
  String who = 'me@co.com',
  String manager = 'boss@co.com',
  bool tx = false,
  String reason = '',
}) =>
    TimeTrackerRequest(
      id: id,
      requesterEmail: who,
      requesterDepartmentId: 'dep-1',
      requestTypeId: tx ? '' : 'sick',
      isTransaction: tx,
      startAt: DateTime(2026, 10, 12, tx ? 9 : 0),
      endAt: tx ? DateTime(2026, 10, 12, 17) : DateTime(2026, 10, 14, 23, 59),
      isAllDay: !tx,
      totalMinutes: tx ? 480 : 3 * 1440,
      status: status,
      approvalSteps: <RequestApprovalStep>[
        RequestApprovalStep(
          step: ApprovalStepKind.manager,
          approverEmail: manager,
          decision: status == RequestStatus.rejected
              ? ApprovalDecision.rejected
              : (status == RequestStatus.pending ? ApprovalDecision.pending : ApprovalDecision.approved),
          reason: reason,
        ),
      ],
      currentStep: status == RequestStatus.pending ? ApprovalStepKind.manager : null,
    );

TimeTrackerHarness _harness({Set<String>? on}) {
  final TimeTrackerHarness h = TimeTrackerHarness(on: on);
  seedAssignment(h.remote, location: _hq);
  seedRequestTypes(h.remote, <RequestType>[_sick]);
  seedRequests(h.remote, <TimeTrackerRequest>[
    _req('p1', RequestStatus.pending),
    _req('ok', RequestStatus.approved),
    _req('no', RequestStatus.rejected, reason: 'Short staffed'),
    _req('tx', RequestStatus.pending, tx: true),
    _req('amr', RequestStatus.pending, who: 'amr@co.com', manager: 'me@co.com'),
  ]);
  return h;
}

void main() {
  setUpAll(initTimeTrackerTestStorage);

  group('Requests tab', () {
    testWidgets('counters, my cards (transactions too), Send Reminder only when pending', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabRequests);
      expect(_key('requestsCounters'), findsOneWidget);
      expect(find.text(S.current.timeTrackerUnderReview), findsWidgets);
      for (final String id in <String>['p1', 'ok', 'no', 'tx']) {
        expect(_key('requestCard_$id'), findsOneWidget, reason: id);
      }
      expect(_key('requestCard_amr'), findsNothing, reason: 'not my request');
      expect(_key('requestCardReminder_p1'), findsOneWidget);
      expect(_key('requestCardReminder_ok'), findsNothing);
      expect(find.text(S.current.timeTrackerTransactionButton), findsWidgets);
      expect(_key('requestsExportButton'), findsOneWidget);
      expect(_key('requestsAddButton'), findsOneWidget);
      await tester.tap(_key('requestsTableToggle'));
      await h.settle(tester);
      expect(_key('requestsTable'), findsOneWidget);
      expect(_key('requestRow_p1'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('Export / + Request / Send Reminder follow their switches', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness(
        on: allKeys()
          ..removeAll(<String>['Export_Time_Tracker_Requests', 'Create_Time_Tracker_Request', 'Send_Request_Reminder']),
      );
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabRequests);
      expect(_key('requestsExportButton'), findsNothing);
      expect(_key('requestsAddButton'), findsNothing);
      expect(_key('requestCardReminder_p1'), findsNothing);
      await h.dispose(tester);
    });

    testWidgets('+ Request form: Submit grey, tap reveals errors; All Day off shows the times',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabRequests);
      await tester.tap(_key('requestsAddButton'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerCreatingNewRequest), findsWidgets);
      expect(find.text(S.current.timeTrackerRequestTypeRequired), findsNothing);
      expect(_key('requestStartTime'), findsNothing);
      await tester.ensureVisible(_key('requestSubmitButton'));
      await tester.tap(_key('requestSubmitButton'));
      await h.settle(tester);
      expect(find.text(S.current.timeTrackerRequestTypeRequired), findsOneWidget);
      // 13/10/2026 (owner P2): only the type picker until a type is chosen.
      expect(_key('requestDescription'), findsNothing);
      final RequestFormCubit form = tester.element(_key('requestTypeDropdown')).read<RequestFormCubit>();
      form.typeChanged(const RequestType(id: 'plain', nameEn: 'Plain'));
      await h.settle(tester);
      expect(find.text('${S.current.timeTrackerRequestDescription} (${S.current.timeTrackerOptional})', findRichText: true), findsOneWidget);
      expect(_key('requestUploadBox'), findsNothing);
      expect(find.text(S.current.timeTrackerEndDateRequired), findsOneWidget);
      await tester.tap(find.descendant(of: _key('requestAllDaySwitch'), matching: find.byType(GestureDetector)).last);
      await h.settle(tester);
      expect(_key('requestStartTime'), findsOneWidget);
      expect(_key('requestEndTime'), findsOneWidget);
      await h.dispose(tester);
    });
  });

  group('Request details (requester)', () {
    Future<void> details(WidgetTester tester, TimeTrackerHarness h, String id) async {
      await h.pump(tester, RequestDetailsPage(requestId: id));
    }

    testWidgets('pending: Cancel + Send Reminder; comments can be written', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await details(tester, h, 'p1');
      expect(_key('requestDetails_p1'), findsOneWidget);
      expect(_key('requestCancelButton'), findsOneWidget);
      expect(_key('requestReminderButton'), findsOneWidget);
      expect(_key('requestApprovalCycle'), findsOneWidget);
      await tester.tap(_key('requestCommentsToggle'));
      await h.settle(tester);
      expect(_key('requestCommentInput'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('approved: Cancel only (asks to cancel); rejected: status + reason', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await details(tester, h, 'ok');
      expect(_key('requestCancelButton'), findsOneWidget);
      expect(_key('requestReminderButton'), findsNothing);
      await h.dispose(tester);

      final TimeTrackerHarness h2 = _harness();
      await details(tester, h2, 'no');
      expect(_key('requestCancelButton'), findsNothing);
      expect(_key('requestStatusPill_rejected'), findsOneWidget);
      expect(_key('requestRejectionReason'), findsOneWidget);
      expect(find.text('Short staffed'), findsOneWidget);
      await h2.dispose(tester);
    });

    testWidgets('a pending transaction is canceled with Cancel_Transaction only', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness(on: allKeys()..remove('Cancel_Transaction'));
      await details(tester, h, 'tx');
      expect(_key('requestCancelButton'), findsNothing);
      // 9/10/2026 (UI pass): info lines are one rich paragraph "Label: value".
      expect(find.textContaining(S.current.timeTrackerTransactionButton, findRichText: true), findsWidgets);
      await h.dispose(tester);
    });

    testWidgets('someone else\'s request is not available as the requester', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await details(tester, h, 'amr');
      expect(_key('requestNotAvailable'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('Cancel on a pending request opens the confirm dialog', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await details(tester, h, 'p1');
      await tester.tap(_key('requestCancelButton'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(S.current.timeTrackerRequestToCancellation), findsOneWidget);
      expect(find.text(S.current.timeTrackerCancelRequestConfirm), findsOneWidget);
      await tester.tap(find.text(S.current.no));
      await tester.pump(const Duration(milliseconds: 300));
      await h.dispose(tester);
    });
  });

  group('Approvals', () {
    testWidgets('the manager sees the request with Reject / Approve; details too', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness();
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabApprovals);
      expect(_key('approvalsCounters'), findsOneWidget);
      expect(_key('approvalCard_amr'), findsOneWidget);
      expect(_key('approvalCard_p1'), findsNothing, reason: 'own requests never');
      expect(_key('approvalCardApprove_amr'), findsOneWidget);
      expect(_key('approvalCardReject_amr'), findsOneWidget);
      await tester.tap(_key('approvalCard_amr'));
      await h.settle(tester);
      expect(_key('requestDetails_amr'), findsOneWidget);
      expect(_key('approvalApproveButton'), findsOneWidget);
      expect(_key('approvalRejectButton'), findsOneWidget);
      await tester.tap(_key('approvalApproveButton'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(S.current.timeTrackerApproveRequestConfirm), findsOneWidget);
      await tester.tap(find.text(S.current.no));
      await tester.pump(const Duration(milliseconds: 300));
      await h.dispose(tester);
    });

    testWidgets('without Approve_And_Reject: a status bar instead of the buttons', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness(on: allKeys()..remove('Approve_And_Reject'));
      await h.pump(tester, const TimeTrackerHomePage());
      await _open(tester, h, S.current.timeTrackerTabApprovals);
      expect(_key('approvalCard_amr'), findsOneWidget);
      expect(_key('approvalCardApprove_amr'), findsNothing);
      expect(_key('requestStatusPill_pending'), findsOneWidget);
      await h.dispose(tester);
    });

    testWidgets('View_Approvals OFF → no Approvals tab', (WidgetTester tester) async {
      final TimeTrackerHarness h = _harness(on: allKeys()..remove('View_Approvals'));
      await h.pump(tester, const TimeTrackerHomePage());
      expect(_tab(S.current.timeTrackerTabApprovals), findsNothing);
      await h.dispose(tester);
    });
  });

  testWidgets('phone: requests cards, approvals cards and the details lay out', (WidgetTester tester) async {
    final TimeTrackerHarness h = _harness();
    await h.pump(tester, const TimeTrackerHomePage(), size: kTimeTrackerPhone);
    await _open(tester, h, S.current.timeTrackerTabRequests);
    expect(_key('requestCard_p1'), findsOneWidget);
    await _open(tester, h, S.current.timeTrackerTabApprovals);
    expect(_key('approvalCard_amr'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
    final TimeTrackerHarness h2 = _harness();
    await h2.pump(tester, const RequestDetailsPage(requestId: 'amr', asApprover: true), size: kTimeTrackerPhone);
    expect(_key('approvalApproveButton'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await h2.dispose(tester);
  });

  testWidgets('Arabic (RTL): Requests, Approvals and details build cleanly', (WidgetTester tester) async {
    final TimeTrackerHarness h = _harness();
    await h.pump(tester, const TimeTrackerHomePage(), locale: const Locale('ar'));
    await S.load(const Locale('ar'));
    await _open(tester, h, S.current.timeTrackerTabRequests);
    expect(_key('requestCard_p1'), findsOneWidget);
    expect(find.text(S.current.timeTrackerUnderReview), findsWidgets);
    await _open(tester, h, S.current.timeTrackerTabApprovals);
    expect(_key('approvalCard_amr'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
    final TimeTrackerHarness h2 = _harness();
    await h2.pump(tester, const RequestDetailsPage(requestId: 'no'), locale: const Locale('ar'));
    expect(_key('requestRejectionReason'), findsOneWidget);
    expect(Directionality.of(tester.element(_key('requestDetails_no'))), TextDirection.rtl);
    await h2.dispose(tester);
    await S.load(const Locale('en'));
  });
}
