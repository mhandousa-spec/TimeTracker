/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: phase3_rules_test.dart
/// Purpose: Unit tests of the phase-3 pure rules: location form validation
///          + parsers, the location import planner (create / update / blank
///          keeps / unchanged / skipped / duplicates / never deletes), the
///          Grant Access rules, the employees view (scope, filters, counts),
///          the group → assignments planner and the request-type form rules.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_type_form_rules.dart';

const WorkLocation _valid = WorkLocation(id: 'hq', nameEn: 'Main Office', nameAr: 'المكتب الرئيسي');

void main() {
  group('LocationFormRules', () {
    test('a complete location has no errors', () {
      expect(LocationFormRules.validate(_valid), isEmpty);
    });

    test('names, coordinates, geofence radius, times, days and break are checked', () {
      final WorkLocation bad = _valid.copyWith(
        nameEn: ' ',
        nameAr: '',
        latitude: 95,
        longitude: double.nan,
        isGeofenceEnabled: true,
        geofenceRadiusMeters: 0,
        workStartMinutes: 540,
        workEndMinutes: 540,
        workingDays: const <int>[],
        isBreakAllowed: true,
        breakMinutes: 0,
      );
      expect(LocationFormRules.validate(bad), <LocationFormError>{
        LocationFormError.nameEnRequired,
        LocationFormError.nameArRequired,
        LocationFormError.latitudeInvalid,
        LocationFormError.longitudeInvalid,
        LocationFormError.radiusRequired,
        LocationFormError.workTimesSame,
        LocationFormError.workingDaysRequired,
        LocationFormError.breakLengthRequired,
      });
    });

    test('a geofence without coordinates is refused; an overnight shift is fine', () {
      final WorkLocation g = _valid.copyWith(
        isGeofenceEnabled: true,
        geofenceRadiusMeters: 200,
        workStartMinutes: 22 * 60,
        workEndMinutes: 6 * 60,
      );
      expect(LocationFormRules.validate(g), <LocationFormError>{LocationFormError.coordinatesRequired});
      expect(LocationFormRules.validate(g.copyWith(latitude: 30, longitude: 31)), isEmpty);
    });

    test('parsers: coordinates (Arabic digits), HH:mm, yes / no, working days', () {
      expect(LocationFormRules.parseCoordinate(''), isNull);
      expect(LocationFormRules.parseCoordinate('٣٠٫٥'), 30.5);
      expect(LocationFormRules.parseCoordinate('abc')!.isNaN, isTrue);
      expect(LocationFormRules.parseMinutesOfDay('9:30'), 570);
      expect(LocationFormRules.parseMinutesOfDay('24:00'), isNull);
      expect(LocationFormRules.formatMinutesOfDay(1020), '17:00');
      expect(LocationFormRules.parseYesNo('Yes'), isTrue);
      expect(LocationFormRules.parseYesNo('لا'), isFalse);
      expect(LocationFormRules.parseYesNo('maybe'), isNull);
      expect(LocationFormRules.parseWorkingDays('Mon, Sun; tuesday'), <int>[7, 1, 2]);
      expect(LocationFormRules.parseWorkingDays('Mon, Funday'), isNull);
      expect(LocationFormRules.formatWorkingDays(const <int>[1, 7]), 'Sun, Mon');
    });
  });

  group('LocationImportRules', () {
    List<String> row(Map<LocationImportColumn, String> values) => <String>[
          for (final LocationImportColumn c in LocationImportColumn.values) values[c] ?? '',
        ];

    test('a missing "Location Name" column imports nothing', () {
      final LocationImportPlan plan = LocationImportRules.plan(
        grid: const <List<String>>[<String>['Name'], <String>['x']],
        existing: const <WorkLocation>[],
      );
      expect(plan.missingNameColumn, isTrue);
      expect(plan.writable, isEmpty);
    });

    test('new name → create with defaults (Sun–Thu, Arabic name copied)', () {
      final LocationImportPlan plan = LocationImportRules.plan(
        grid: <List<String>>[
          LocationImportRules.headings,
          row(<LocationImportColumn, String>{
            LocationImportColumn.nameEn: 'Branch 2',
            LocationImportColumn.workStart: '08:00',
            LocationImportColumn.workEnd: '16:00',
          }),
        ],
        existing: const <WorkLocation>[],
      );
      expect(plan.count(LocationImportAction.create), 1);
      final WorkLocation l = plan.writable.single.location!;
      expect(l.nameAr, 'Branch 2');
      expect(l.workingDays, LocationImportRules.defaultWorkingDays);
      expect(l.workStartMinutes, 480);
    });

    test('existing name → update; a blank cell keeps the stored value; same row → unchanged', () {
      final WorkLocation stored = _valid.copyWith(city: 'Cairo', lateAfterMinutes: 10);
      final LocationImportPlan plan = LocationImportRules.plan(
        grid: <List<String>>[
          LocationImportRules.headings,
          row(<LocationImportColumn, String>{
            LocationImportColumn.nameEn: 'main office',
            LocationImportColumn.lateAfter: '15',
          }),
        ],
        existing: <WorkLocation>[stored],
      );
      final LocationImportRow r = plan.rows.single;
      expect(r.action, LocationImportAction.update);
      expect(r.location!.id, 'hq');
      expect(r.location!.city, 'Cairo');
      expect(r.location!.lateAfterMinutes, 15);

      final LocationImportPlan same = LocationImportRules.plan(
        grid: <List<String>>[LocationImportRules.headings, LocationImportRules.rowOf(stored)],
        existing: <WorkLocation>[stored],
      );
      expect(same.rows.single.action, LocationImportAction.unchanged);
      expect(same.writable, isEmpty);
    });

    test('bad values / duplicates are skipped with their column; deleted locations are not matched', () {
      final WorkLocation gone = _valid.copyWith(id: 'old', nameEn: 'Old', status: LocationStatus.deleted);
      final LocationImportPlan plan = LocationImportRules.plan(
        grid: <List<String>>[
          LocationImportRules.headings,
          row(<LocationImportColumn, String>{
            LocationImportColumn.nameEn: 'A',
            LocationImportColumn.latitude: 'north',
          }),
          row(<LocationImportColumn, String>{LocationImportColumn.nameEn: 'B'}),
          row(<LocationImportColumn, String>{LocationImportColumn.nameEn: 'b'}),
          row(<LocationImportColumn, String>{LocationImportColumn.nameEn: 'Old'}),
          row(const <LocationImportColumn, String>{}),
        ],
        existing: <WorkLocation>[gone],
      );
      expect(plan.rows.length, 4); // the blank line is ignored
      expect(plan.rows[0].action, LocationImportAction.skip);
      expect(plan.rows[0].issues.single.column, LocationImportColumn.latitude);
      expect(plan.rows[1].action, LocationImportAction.create);
      expect(plan.rows[2].issues.single, same(LocationImportIssue.duplicateName));
      expect(plan.rows[3].action, LocationImportAction.create);
      expect(plan.rows[3].location!.id, '');
    });
  });

  group('AssignmentRules', () {
    test('location, start date and break length (extra locations are optional — owner T5)', () {
      expect(
        AssignmentRules.validate(
          locationId: '',
          startDate: null,
          rules: const AttendanceRules(isBreakAllowed: true, isDifferentLocationAllowed: true),
        ),
        <AssignmentError>{
          AssignmentError.locationRequired,
          AssignmentError.startDateRequired,
          AssignmentError.breakLengthRequired,
        },
      );
      expect(
        AssignmentRules.validate(locationId: 'hq', startDate: DateTime(2026), rules: const AttendanceRules()),
        isEmpty,
      );
    });
  });

  group('EmployeesView', () {
    const List<TimeTrackerEmployee> people = <TimeTrackerEmployee>[
      TimeTrackerEmployee(email: 'a@co.com', nameEn: 'Ali', departmentId: 'd1'),
      TimeTrackerEmployee(email: 'b@co.com', nameEn: 'Bea', departmentId: 'd1'),
      TimeTrackerEmployee(email: 'c@co.com', nameEn: 'Cy', departmentId: 'd2'),
    ];
    const List<LocationAssignment> stored = <LocationAssignment>[
      LocationAssignment(employeeEmail: 'A@co.com', locationId: 'hq'),
      LocationAssignment(employeeEmail: 'b@co.com'), // removed → unassigned
    ];

    test('scope, join, filters and counts', () {
      final List<EmployeeAssignmentRow> all =
          EmployeesView.rows(employees: people, assignments: stored, covers: (_) => true);
      expect(all.where((EmployeeAssignmentRow r) => r.isAssigned).map((EmployeeAssignmentRow r) => r.employee.email),
          <String>['a@co.com']);
      final List<EmployeeAssignmentRow> own =
          EmployeesView.rows(employees: people, assignments: stored, covers: (String d) => d == 'd1');
      expect(own.length, 2);
      expect(EmployeesView.filter(all, query: 'cy').single.employee.email, 'c@co.com');
      expect(EmployeesView.filter(all, departmentId: 'd1').length, 2);
      expect(EmployeesView.filter(all, locationId: 'hq').single.employee.email, 'a@co.com');
      expect(EmployeesView.countsByLocation(all), <String, int>{'hq': 1});
    });
  });

  group('GroupAssignmentPlanner', () {
    final DateTime start = DateTime(2026, 10, 12);
    const AttendanceRules rules = AttendanceRules(isPauseAllowed: true);

    test('members get the group location + link; a leaver keeps the location, loses the tag', () {
      final EmployeeGroup group = EmployeeGroup(
        id: 'g1',
        name: 'Design',
        memberEmails: const <String>['a@co.com', 'b@co.com'],
        locationId: 'hq',
        startDate: start,
        rules: rules,
      );
      final List<LocationAssignment> stored = <LocationAssignment>[
        LocationAssignment(employeeEmail: 'a@co.com', locationId: 'hq', startDate: start, rules: rules, groupId: 'g1'),
        const LocationAssignment(employeeEmail: 'c@co.com', locationId: 'b2', groupId: 'g1'),
      ];
      final List<LocationAssignment> writes = GroupAssignmentPlanner.plan(
        group: group,
        previousMembers: const <String>['a@co.com', 'c@co.com'],
        stored: stored,
      );
      // a@ already matches → nothing; b@ assigned; c@ left → tag cleared.
      expect(writes.length, 2);
      final LocationAssignment b = writes.firstWhere((LocationAssignment w) => w.employeeEmail == 'b@co.com');
      expect(b.locationId, 'hq');
      expect(b.groupId, 'g1');
      // Decision 33 (9/10/2026): linked, not copied — the group's rules are
      // resolved at read time (effective_rules_test.dart).
      expect(b.rules.isCustom, isFalse);
      expect(b.rules.isPauseAllowed, isFalse);
      final LocationAssignment c = writes.firstWhere((LocationAssignment w) => w.employeeEmail == 'c@co.com');
      expect(c.locationId, 'b2');
      expect(c.groupId, '');
    });

    test('a deleted group clears its members\' tag only', () {
      final List<LocationAssignment> writes = GroupAssignmentPlanner.plan(
        group: const EmployeeGroup(id: 'g1', name: 'x', memberEmails: <String>['a@co.com'], isDeleted: true),
        previousMembers: const <String>['a@co.com'],
        stored: const <LocationAssignment>[
          LocationAssignment(employeeEmail: 'a@co.com', locationId: 'hq', groupId: 'g1'),
        ],
      );
      expect(writes.single.locationId, 'hq');
      expect(writes.single.groupId, '');
    });
  });

  group('RequestTypeFormRules / RequestTypeList', () {
    test('both names required; a limit switched on needs a chip', () {
      expect(
        RequestTypeFormRules.validate(const RequestType(id: '', nameEn: ''),
            limitLocations: true, limitDepartments: true),
        <RequestTypeFormError>{
          RequestTypeFormError.nameEnRequired,
          RequestTypeFormError.nameArRequired,
          RequestTypeFormError.locationsRequired,
          RequestTypeFormError.departmentsRequired,
        },
      );
      expect(
        RequestTypeFormRules.validate(
          const RequestType(id: '', nameEn: 'Sick', nameAr: 'مرضية', locationIds: <String>['hq']),
          limitLocations: true,
          limitDepartments: false,
        ),
        isEmpty,
      );
    });

    test('"All" lists every status (removed too), newest first; search and status filter', () {
      final List<RequestType> types = <RequestType>[
        RequestType(id: '1', nameEn: 'Sick', audit: AuditInfo(createdAt: DateTime(2026, 1, 1))),
        RequestType(
          id: '2',
          nameEn: 'Annual',
          status: RequestTypeStatus.removed,
          audit: AuditInfo(createdAt: DateTime(2026, 2, 1)),
        ),
      ];
      expect(RequestTypeList.filter(types).map((RequestType t) => t.id), <String>['2', '1']);
      expect(RequestTypeList.filter(types, status: RequestTypeStatus.active).single.id, '1');
      expect(RequestTypeList.filter(types, query: 'ann').single.id, '2');
    });
  });
}
