/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_models_test.dart
/// Purpose: Round-trip tests for every Time Tracker model (entity → history
///          row → stored document → entity) with the FINAL SPEC §2 field
///          names, wrapped list entries, `Timestamp` dates and the audit trio.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/employee_group_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_type_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_request_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/vacation_balance_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 8, 12);
  final TimeTrackerAudit audit = TimeTrackerAudit.next(
    null,
    actor: 'me@co.com',
    now: now,
  );

  /// Writes [row] as a stored document (one history row).
  Map<String, dynamic> store(Map<String, Object?> row) =>
      TimeTrackerHistoryCodec.append(old: null, values: row, now: now);

  test('AttendanceDay: sessions with pauses survive the round trip', () {
    final AttendanceDay day = AttendanceDay(
      id: 'me@co.com_2026-10-08',
      employeeEmail: 'Me@Co.com',
      date: DateTime(2026, 10, 8),
      sessions: <AttendanceSession>[
        AttendanceSession(
          checkInAt: DateTime(2026, 10, 8, 9),
          checkOutAt: DateTime(2026, 10, 8, 17),
          workLocationId: 'hq',
          latitude: 30.1,
          longitude: 31.2,
          pauses: <AttendancePause>[
            AttendancePause(
              startAt: DateTime(2026, 10, 8, 12),
              endAt: DateTime(2026, 10, 8, 12, 30),
            ),
          ],
        ),
        AttendanceSession(
          checkInAt: DateTime(2026, 10, 8, 18),
          workLocationType: WorkLocationType.remote,
        ),
      ],
      status: AttendanceStatus.late,
      lateMinutes: 5,
      breakMinutes: 30,
      totalWorkMinutes: 450,
    );
    final Map<String, dynamic> doc =
        store(AttendanceDayModel.row(day, id: day.id, audit: audit));
    expect(doc['Employee_Email'], <Object?>['me@co.com']);
    expect(doc['Attendance_Status'], <Object?>['late']);
    expect((doc['Sessions'] as List<Object?>).single, isA<Map<String, Object?>>());
    expect(doc['Created_By'], <Object?>['me@co.com']);
    expect(doc['timestamps'], hasLength(1));

    final AttendanceDay back = AttendanceDayModel.fromMap(day.id, doc);
    expect(back.sessions, hasLength(2));
    expect(back.sessions.first.pauses.single.endAt, DateTime(2026, 10, 8, 12, 30));
    expect(back.sessions.first.latitude, 30.1);
    expect(back.sessions.last.isOpen, isTrue);
    expect(back.sessions.last.workLocationType, WorkLocationType.remote);
    expect(back.status, AttendanceStatus.late);
    expect(back.totalWorkMinutes, 450);
    expect(back.audit.createdBy, 'me@co.com');
    expect(back.audit.updatedAt, now);
  });

  test('TimeTrackerRequest: steps, comments, attachments, status', () {
    final TimeTrackerRequest request = TimeTrackerRequest(
      id: 'r1',
      requesterEmail: 'me@co.com',
      requesterDepartmentId: 'dep-1',
      requestTypeId: 'annual',
      startAt: DateTime(2026, 10, 11),
      endAt: DateTime(2026, 10, 13),
      isAllDay: true,
      status: RequestStatus.underReview,
      approvalSteps: <RequestApprovalStep>[
        RequestApprovalStep(
          step: ApprovalStepKind.manager,
          approverEmail: 'boss@co.com',
          decision: ApprovalDecision.approved,
          decidedAt: DateTime(2026, 10, 9),
        ),
        const RequestApprovalStep(step: ApprovalStepKind.hr),
      ],
      currentStep: ApprovalStepKind.hr,
      cancellationReason: 'Plans changed',
      attachments: <RequestAttachment>[
        RequestAttachment(name: 'a.pdf', url: 'https://x', sizeBytes: 62, uploadedAt: now),
      ],
    );
    final Map<String, dynamic> doc =
        store(TimeTrackerRequestModel.row(request, id: 'r1', audit: audit));
    expect(doc['Request_Status'], <Object?>['under_review']);
    expect(doc['Current_Step'], <Object?>['hr']);
    expect(doc['Start_Date_Time'], <Object?>[Timestamp.fromDate(DateTime(2026, 10, 11))]);

    final TimeTrackerRequest back = TimeTrackerRequestModel.fromMap('r1', doc);
    expect(back.status, RequestStatus.underReview);
    expect(back.approvalSteps.first.decision, ApprovalDecision.approved);
    expect(back.approvalSteps.last.isPending, isTrue);
    expect(back.currentStep, ApprovalStepKind.hr);
    // 9/10/2026 (data model): comments are documents of Requests/{id}/Comments.
    expect(doc.containsKey('Comments'), isFalse);
    expect(back.legacyComments, isEmpty);
    expect(back.attachments.single.sizeBytes, 62);
    expect(back.cancellationReason, 'Plans changed');
    expect(back.isAllDay, isTrue);
  });

  test('RequestType: limits and switches', () {
    const RequestType type = RequestType(
      id: 't1',
      nameEn: 'Sick Leave',
      nameAr: 'إجازة مرضية',
      isHrApprovalRequired: true,
      isManagerApprovalRequired: false,
      isDeductedFromVacationBalance: true,
      locationIds: <String>['hq'],
      status: RequestTypeStatus.removed,
    );
    final Map<String, dynamic> doc =
        store(RequestTypeModel.row(type, id: 't1', audit: audit));
    expect(doc['Location_Ids'], <Object?>[
      <String, Object?>{'Values': <Object?>['hq']},
    ]);
    final RequestType back = RequestTypeModel.fromMap('t1', doc);
    expect(back.nameAr, 'إجازة مرضية');
    expect(back.isManagerApprovalRequired, isFalse);
    expect(back.isDeductedFromVacationBalance, isTrue);
    expect(back.locationIds, <String>['hq']);
    expect(back.status, RequestTypeStatus.removed);
    expect(back.isAvailableFor(locationId: 'hq', departmentId: 'd'), isFalse);
    expect(
      back.copyWith(status: RequestTypeStatus.active)
          .isAvailableFor(locationId: 'hq', departmentId: 'd'),
      isTrue,
    );
    expect(
      back.copyWith(status: RequestTypeStatus.active)
          .isAvailableFor(locationId: 'b2', departmentId: 'd'),
      isFalse,
    );
  });

  test('WorkLocation: working hours, days and geofence', () {
    const WorkLocation location = WorkLocation(
      id: 'hq',
      nameEn: 'Main Office',
      latitude: 30,
      longitude: 31,
      isGeofenceEnabled: true,
      geofenceRadiusMeters: 500,
      workStartMinutes: 8 * 60,
      workEndMinutes: 16 * 60,
      workingDays: <int>[7, 1, 2, 3, 4],
      isBreakAllowed: true,
      breakMinutes: 30,
      status: LocationStatus.deleted,
    );
    final Map<String, dynamic> doc =
        store(WorkLocationModel.row(location, id: 'hq', audit: audit));
    expect(doc['Work_Start_Time'], <Object?>[480]);
    expect(doc['Location_Status'], <Object?>['deleted']);
    final WorkLocation back = WorkLocationModel.fromMap('hq', doc);
    expect(back.schedule.workingDays, <int>[7, 1, 2, 3, 4]);
    expect(back.geofenceRadiusMeters, 500);
    expect(back.breakMinutes, 30);
    expect(back.isActive, isFalse);
  });

  test('LocationAssignment / EmployeeGroup share the rule columns', () {
    const AttendanceRules rules = AttendanceRules(
      isPauseAllowed: true,
      isDifferentLocationAllowed: true,
      allowedLocationIds: <String>['b2'],
    );
    const LocationAssignment assignment = LocationAssignment(
      employeeEmail: 'Me@co.com',
      locationId: 'hq',
      rules: rules,
      groupId: 'g1',
    );
    final Map<String, dynamic> aDoc = store(
      LocationAssignmentModel.row(assignment, id: 'me@co.com', audit: audit),
    );
    expect(aDoc['Location_Assignment_Id'], <Object?>['me@co.com']);
    final LocationAssignment aBack = LocationAssignmentModel.fromMap('me@co.com', aDoc);
    expect(aBack.employeeEmail, 'me@co.com');
    expect(aBack.rules.allowedLocationIds, <String>['b2']);
    expect(aBack.groupId, 'g1');
    expect(aBack.copyWith(locationId: '').isAssigned, isFalse);

    const EmployeeGroup group = EmployeeGroup(
      id: 'g1',
      name: 'UI Team',
      memberEmails: <String>['A@co.com', 'a@co.com ', 'b@co.com', ''],
      rules: rules,
    );
    final Map<String, dynamic> gDoc =
        store(EmployeeGroupModel.row(group, id: 'g1', audit: audit));
    final EmployeeGroup gBack = EmployeeGroupModel.fromMap('g1', gDoc);
    expect(gBack.memberEmails, <String>['a@co.com', 'b@co.com']);
    expect(gBack.rules.isPauseAllowed, isTrue);
    expect(gBack.isDeleted, isFalse);
  });

  test('rules without a different-location grant store no allowed ids', () {
    final Map<String, Object?> cols = AttendanceRulesFields.to(
      const AttendanceRules(allowedLocationIds: <String>['x']),
    );
    expect(cols['Allowed_Location_Ids'], <String, Object?>{'Values': <Object?>[]});
  });

  test('VacationBalance: remaining is computed, never stored (9/10/2026)', () {
    const VacationBalance balance = VacationBalance(
      employeeEmail: 'me@co.com',
      year: 2026,
      totalDays: 21,
      usedDays: 3.5,
    );
    final Map<String, dynamic> doc =
        store(VacationBalanceModel.row(balance, id: 'me@co.com_2026', audit: audit));
    expect(doc.containsKey('Remaining_Days'), isFalse);
    expect(doc.containsKey('Vacation_Balance_Id'), isFalse, reason: 'no self-id inside a document');
    doc['Remaining_Days'] = <Object?>[999]; // an old stored value is ignored
    final VacationBalance back = VacationBalanceModel.fromMap('me@co.com_2026', doc);
    expect(back.remainingDays, 17.5);
    expect(back.year, 2026);
  });

  test('a missing or junk document reads as safe defaults', () {
    final TimeTrackerRequest request =
        TimeTrackerRequestModel.fromMap('x', <String, dynamic>{'Request_Status': 5});
    expect(request.status, RequestStatus.pending);
    expect(request.approvalSteps, isEmpty);
    final WorkLocation location = WorkLocationModel.fromMap('l', <String, dynamic>{});
    expect(location.status, LocationStatus.inactive);
    expect(location.workingDays, WorkSchedule.allDays);
  });
}
