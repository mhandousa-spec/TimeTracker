/// Module: test / settings / se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: self_approval_rule_test.dart
/// Purpose: A change request is decided by ANOTHER employee, never by the
///          requester (owner decision 9/10/2026): the pure rule, the
///          repository's second check (fails closed, nothing written), the
///          cubit's EN/AR message, and the requester left off the reviewer
///          notification list.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/data_source/remote_data_source/requests_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/repository/requests_repository.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/rules/self_approval_rule.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Never touched: every Firestore call the repository makes is overridden in
/// [_FakeRemote]. Only here so the data source can be constructed without
/// `Firebase.initializeApp`.
class _UnusedFirestore extends Fake implements FirebaseFirestore {}

class _FakeRemote extends RequestsRemoteDataSource {
  _FakeRemote({this.stored, this.throwOnRead = false})
      : super(firestore: _UnusedFirestore());

  final ChangeRequest? stored;
  final bool throwOnRead;
  final List<String> writes = <String>[];

  @override
  Future<ChangeRequest?> read(String requestId) async {
    if (throwOnRead) throw StateError('offline');
    return stored;
  }

  @override
  Future<List<String>> applyChangesToEmployee({
    required String employeeId,
    required List<FieldChange> changes,
  }) async {
    writes.add('profile:$employeeId');
    return <String>[];
  }

  @override
  Future<void> updateStatus(String requestId, RequestStatus status,
      {String reason = ''}) async {
    writes.add('status:${status.wireValue}');
  }
}

const ChangeRequest _request = ChangeRequest(
  id: 'req-1',
  section: 'Health Insurance',
  employeeId: 'emp-7',
  employeeEmail: '  Mona@Knowticed.com ',
  employeeName: 'mona',
  changes: <FieldChange>[
    FieldChange(fieldName: 'insuranceName', oldValue: 'A', newValue: 'B'),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SelfApprovalRule.check', () {
    test('another reviewer may decide', () {
      expect(
        SelfApprovalRule.check(
          requesterEmail: 'mona@knowticed.com',
          deciderEmail: 'amr@knowticed.com',
        ),
        SelfApprovalVerdict.allowed,
      );
    });

    test('the requester is blocked — emails compared trimmed + lower-cased',
        () {
      expect(
        SelfApprovalRule.check(
          requesterEmail: '  Mona@Knowticed.COM ',
          deciderEmail: 'mona@knowticed.com',
        ),
        SelfApprovalVerdict.ownRequest,
      );
    });

    test('same employee id is blocked even when the email changed', () {
      expect(
        SelfApprovalRule.check(
          requesterEmail: 'old-mona@knowticed.com',
          requesterId: 'emp-7',
          deciderEmail: 'mona@knowticed.com',
          deciderId: 'emp-7',
        ),
        SelfApprovalVerdict.ownRequest,
      );
    });

    test('unknown decider fails closed', () {
      expect(
        SelfApprovalRule.check(
          requesterEmail: 'mona@knowticed.com',
          deciderEmail: '   ',
        ),
        SelfApprovalVerdict.unverifiable,
      );
    });

    test('requester with neither email nor comparable id fails closed', () {
      expect(
        SelfApprovalRule.check(
          requesterEmail: '',
          deciderEmail: 'amr@knowticed.com',
        ),
        SelfApprovalVerdict.unverifiable,
      );
      // …but an id comparison can clear a legacy request without an email.
      expect(
        SelfApprovalRule.check(
          requesterEmail: '',
          requesterId: 'emp-7',
          deciderEmail: 'amr@knowticed.com',
          deciderId: 'emp-1',
        ),
        SelfApprovalVerdict.allowed,
      );
    });

    test('isOwnRequest / isDecision', () {
      expect(
        SelfApprovalRule.isOwnRequest(
          requesterEmail: 'Mona@knowticed.com ',
          currentUserEmail: ' mona@KNOWTICED.com',
        ),
        isTrue,
      );
      expect(
        SelfApprovalRule.isOwnRequest(
            requesterEmail: '', currentUserEmail: ''),
        isFalse,
      );
      expect(SelfApprovalRule.isDecision(RequestStatus.approved), isTrue);
      expect(SelfApprovalRule.isDecision(RequestStatus.rejected), isTrue);
      expect(SelfApprovalRule.isDecision(RequestStatus.cancelled), isFalse);
    });
  });

  group('reviewer notification list', () {
    test('the requester is left out (case/space-insensitive), order kept', () {
      expect(
        SelfApprovalRule.withoutRequester(
          <String>[
            'amr@knowticed.com',
            ' MONA@knowticed.com',
            'sara@knowticed.com',
            'Amr@Knowticed.com', // duplicate, other case
          ],
          'mona@knowticed.com ',
        ),
        <String>['amr@knowticed.com', 'sara@knowticed.com'],
      );
    });

    test('no requester given → nobody removed (blanks dropped)', () {
      expect(
        SelfApprovalRule.withoutRequester(
            <String>['a@x.com', '', 'b@x.com'], ''),
        <String>['a@x.com', 'b@x.com'],
      );
    });

    test('requester was the only reviewer → empty', () {
      expect(
        SelfApprovalRule.withoutRequester(
            <String>['mona@knowticed.com'], 'Mona@knowticed.com'),
        isEmpty,
      );
    });
  });

  group('RequestsRepository checks again (EN)', () {
    setUpAll(() => S.load(const Locale('en')));

    test('requester approving their own request: refused, nothing written',
        () async {
      final _FakeRemote remote = _FakeRemote(stored: _request);
      final Either<Failure, void> result =
          await RequestsRepository(remoteDataSource: remote).approveRequest(
        request: _request,
        employeeId: 'emp-7',
        approverEmail: 'mona@knowticed.com',
      );

      expect(result.isLeft(), isTrue);
      final Failure failure = result.fold((Failure f) => f, (_) => throw 'x');
      expect(failure, isA<SelfApprovalFailure>());
      expect(failure.message, S.current.selfApprovalBlocked);
      expect(remote.writes, isEmpty);
    });

    test('the STORED requester is checked, not the caller\'s copy', () async {
      // The caller passes a tampered/stale copy naming someone else.
      final _FakeRemote remote = _FakeRemote(stored: _request);
      final Either<Failure, void> result =
          await RequestsRepository(remoteDataSource: remote).approveRequest(
        request: _request.copyWith(employeeEmail: 'someone@else.com'),
        employeeId: 'emp-7',
        approverEmail: 'MONA@knowticed.com',
      );
      expect(result.isLeft(), isTrue);
      expect(remote.writes, isEmpty);
    });

    test('another reviewer approves: profile then status written', () async {
      final _FakeRemote remote = _FakeRemote(stored: _request);
      final Either<Failure, void> result =
          await RequestsRepository(remoteDataSource: remote).approveRequest(
        request: _request,
        employeeId: 'emp-7',
        approverEmail: 'amr@knowticed.com',
        approverEmployeeId: 'emp-1',
      );
      expect(result.isRight(), isTrue);
      expect(remote.writes, <String>['profile:emp-7', 'status:approved']);
    });

    test('no approver email: fails closed with the unverifiable message',
        () async {
      final _FakeRemote remote = _FakeRemote(stored: _request);
      final Either<Failure, void> result =
          await RequestsRepository(remoteDataSource: remote).approveRequest(
        request: _request,
        employeeId: 'emp-7',
        approverEmail: '',
      );
      final Failure failure = result.fold((Failure f) => f, (_) => throw 'x');
      expect(failure, isA<SelfApprovalFailure>());
      expect(failure.message, S.current.requestDecisionUnverifiable);
      expect(remote.writes, isEmpty);
    });

    test('request unreadable or gone: fails closed', () async {
      for (final _FakeRemote remote in <_FakeRemote>[
        _FakeRemote(throwOnRead: true),
        _FakeRemote(),
      ]) {
        final Either<Failure, void> result =
            await RequestsRepository(remoteDataSource: remote).approveRequest(
          request: _request,
          employeeId: 'emp-7',
          approverEmail: 'amr@knowticed.com',
        );
        expect(result.isLeft(), isTrue);
        expect(remote.writes, isEmpty);
      }
    });

    test('reject is a decision too; cancel is the requester\'s own action',
        () async {
      final _FakeRemote remote = _FakeRemote(stored: _request);
      final RequestsRepository repository =
          RequestsRepository(remoteDataSource: remote);

      final Either<Failure, void> reject = await repository.setRequestStatus(
        requestId: 'req-1',
        status: RequestStatus.rejected,
        deciderEmail: 'mona@knowticed.com',
      );
      expect(reject.isLeft(), isTrue);
      expect(remote.writes, isEmpty);

      final Either<Failure, void> cancel = await repository.setRequestStatus(
        requestId: 'req-1',
        status: RequestStatus.cancelled,
      );
      expect(cancel.isRight(), isTrue);
      expect(remote.writes, <String>['status:cancelled']);
    });
  });

  group('RequestsCubit surfaces the localized reason', () {
    test('Arabic message on a blocked self-approval', () async {
      await S.load(const Locale('ar'));
      final RequestsCubit cubit = RequestsCubit(
        repository: RequestsRepository(
            remoteDataSource: _FakeRemote(stored: _request)),
      );

      final bool ok = await cubit.approve(
        request: _request,
        employeeId: 'emp-7',
        approverEmail: 'mona@knowticed.com',
      );

      expect(ok, isFalse);
      expect(cubit.state.userMessage, S.current.selfApprovalBlocked);
      expect(cubit.state.userMessage, contains('لا يمكنك'));

      cubit.clearMessages();
      expect(cubit.state.userMessage, isNull);
      await cubit.close();
      await S.load(const Locale('en'));
    });
  });
}
