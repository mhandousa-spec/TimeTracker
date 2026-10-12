/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_rules_test.dart
/// Purpose: Unit tests for `VacationBalanceRules` — deduct on approval only
///          for "deducted" types, refund on cancel after approval, working-day
///          counting, partial days, transactions never deduct.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';

void main() {
  const RequestType annual = RequestType(
    id: 'annual',
    nameEn: 'Annual Vacation',
    isDeductedFromVacationBalance: true,
  );
  const RequestType sick = RequestType(id: 'sick', nameEn: 'Sick Leave');
  const VacationBalance balance = VacationBalance(
    employeeEmail: 'me@co.com',
    year: 2026,
    totalDays: 21,
    usedDays: 5,
  );
  // Sun 4 – Thu 8 Oct 2026 + Fri 9 + Sat 10.
  final TimeTrackerRequest week = TimeTrackerRequest(
    id: 'r',
    requesterEmail: 'me@co.com',
    requestTypeId: 'annual',
    startAt: DateTime(2026, 10, 4),
    endAt: DateTime(2026, 10, 10),
    isAllDay: true,
  );
  const WorkSchedule sunToThu = WorkSchedule(
    startMinutes: 9 * 60,
    endMinutes: 17 * 60,
    workingDays: <int>[7, 1, 2, 3, 4],
  );

  test('remaining = total − used, never below zero', () {
    expect(balance.remainingDays, 16);
    expect(balance.copyWith(usedDays: 30).remainingDays, 0);
  });

  group('requestedDays', () {
    test('all-day counts working days only', () {
      expect(VacationBalanceRules.requestedDays(week, schedule: sunToThu), 5);
      expect(VacationBalanceRules.requestedDays(week), 7);
    });

    test('partial day = minutes ÷ planned shift minutes', () {
      final TimeTrackerRequest twoHours = week.copyWith(
        isAllDay: false,
        totalMinutes: 120,
      );
      expect(VacationBalanceRules.requestedDays(twoHours, schedule: sunToThu), 0.25);
    });
  });

  group('applyStatusChange', () {
    VacationBalance move(
      RequestStatus from,
      RequestStatus to, {
      RequestType? type = annual,
      TimeTrackerRequest? request,
      VacationBalance start = balance,
    }) =>
        VacationBalanceRules.applyStatusChange(
          balance: start,
          request: request ?? week,
          type: type,
          from: from,
          to: to,
          schedule: sunToThu,
        );

    test('pending → approved deducts', () {
      expect(move(RequestStatus.pending, RequestStatus.approved).usedDays, 10);
    });

    test('cancel after approval (requester or HR) refunds', () {
      final VacationBalance taken = balance.copyWith(usedDays: 10);
      expect(move(RequestStatus.underReview, RequestStatus.canceled, start: taken).usedDays, 5);
      expect(move(RequestStatus.approved, RequestStatus.canceledByHr, start: taken).usedDays, 5);
    });

    test('rejected cancellation and other moves change nothing', () {
      expect(move(RequestStatus.underReview, RequestStatus.approved).usedDays, 5);
      expect(move(RequestStatus.pending, RequestStatus.rejected).usedDays, 5);
      expect(move(RequestStatus.pending, RequestStatus.canceled).usedDays, 5);
    });

    test('non-deducted types and transactions never touch the balance', () {
      expect(move(RequestStatus.pending, RequestStatus.approved, type: sick).usedDays, 5);
      expect(move(RequestStatus.pending, RequestStatus.approved, type: null).usedDays, 5);
      final TimeTrackerRequest transaction = TimeTrackerRequest(
        id: 't',
        requesterEmail: 'me@co.com',
        isTransaction: true,
        startAt: DateTime(2026, 10, 4, 9),
        endAt: DateTime(2026, 10, 4, 17),
      );
      expect(
        move(RequestStatus.pending, RequestStatus.approved, request: transaction)
            .usedDays,
        5,
      );
    });

    test('a refund never drives used days below zero', () {
      expect(
        move(RequestStatus.approved, RequestStatus.canceledByHr).usedDays,
        0,
      );
    });
  });

  test('wouldExceed compares with the remaining days', () {
    expect(VacationBalanceRules.wouldExceed(balance, 16), isFalse);
    expect(VacationBalanceRules.wouldExceed(balance, 16.5), isTrue);
  });
}
