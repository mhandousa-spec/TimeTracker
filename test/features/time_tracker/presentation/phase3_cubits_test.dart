/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: phase3_cubits_test.dart
/// Purpose: Tests of the phase-3 cubits over the in-memory fakes, with the
///          permission gating and the company-has-HR refusal: Locations
///          (status, soft delete, import), the Location form (validation,
///          create / edit, "Use my current location"), Employees (department
///          scope, assign / reassign / remove, groups applied to members),
///          the Group form and Request Types (+ form).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/group_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_assignment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_type_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/group_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/location_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/controller/group_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_type_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office', nameAr: 'المكتب الرئيسي');
const WorkLocation _b2 = WorkLocation(id: 'b2', nameEn: 'Branch 2', nameAr: 'الفرع الثاني');

Future<void> _settle() async {
  for (int i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Set<String> _without(Set<String> remove) => allKeys()..removeAll(remove);

WorkLocation _storedLocation(FakeTimeTrackerRemote r, String id) =>
    WorkLocationModel.fromMap(id, r.store[TimeTrackerFirestorePaths.locations]![id]!);

LocationAssignment _storedAssignment(FakeTimeTrackerRemote r, String email) => LocationAssignmentModel.fromMap(
    email, r.store[TimeTrackerFirestorePaths.locationAssignments]![email]!);

class _Env {
  _Env({Set<String>? on, bool hr = false, String departmentId = 'dep-1'})
      : access = accessWith(on ?? allKeys(), departmentId: departmentId) {
    resolver = hr ? hrResolver(remote) : noHrResolver(remote);
  }

  final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
  final TimeTrackerAccess access;
  final FakeLog log = FakeLog();
  late final WorkSetupSourceResolver resolver;

  LocationRepositoryImpl get places => LocationRepositoryImpl(remoteDataSource: remote, access: access);
  LocationAssignmentRepositoryImpl get assignments =>
      LocationAssignmentRepositoryImpl(remoteDataSource: remote, access: access);
  GroupRepositoryImpl get groups => GroupRepositoryImpl(remoteDataSource: remote, access: access);

  LocationsCubit locations() => LocationsCubit(
      locations: places, assignments: assignments, resolver: resolver, access: access, log: log);

  EmployeesCubit employees() => EmployeesCubit(
        directory: FakeDirectory(),
        assignments: assignments,
        groups: groups,
        locations: places,
        groupService: GroupService(groups: groups, assignments: assignments, access: access, log: log),
        resolver: resolver,
        access: access,
        log: log,
      );

  LocationFormCubit form({WorkLocation? original}) => LocationFormCubit(
        locations: places,
        device: FakeLocationReader(const DeviceLocationResult.found(GeoPoint(30.05, 31.23))),
        resolver: resolver,
        access: access,
        log: log,
        original: original,
      );
}

void main() {
  group('LocationsCubit', () {
    test('lists live locations; Active ↔ Inactive and soft delete are logged', () async {
      final _Env e = _Env();
      seedLocations(e.remote, <WorkLocation>[_hq, _b2, _b2.copyWith(id: 'gone', status: LocationStatus.deleted)]);
      final LocationsCubit c = e.locations();
      await c.init();
      await _settle();
      expect(c.state.listed.map((WorkLocation l) => l.id), <String>['b2', 'hq']);
      c.searchChanged('main');
      expect(c.state.visible.single.id, 'hq');
      c.applyFilter(const LocationsFilter(status: LocationStatus.inactive));
      expect(c.state.visible, isEmpty);

      expect(await c.toggleStatus(_hq), isTrue);
      expect(_storedLocation(e.remote, 'hq').status, LocationStatus.inactive);
      expect(await c.delete(_b2), isTrue);
      expect(_storedLocation(e.remote, 'b2').status, LocationStatus.deleted);
      expect(e.log.actions, <String>[
        TimeTrackerLogService.actionChangeLocationStatus,
        TimeTrackerLogService.actionDeleteLocation,
      ]);
      await c.close();
    });

    test('a switch OFF or a company with HR refuses the write (nothing stored)', () async {
      for (final _Env e in <_Env>[
        _Env(on: _without(<String>{'Change_Location_Status', 'Delete_Location', 'Import_Locations'})),
        _Env(hr: true),
      ]) {
        seedLocations(e.remote, <WorkLocation>[_hq]);
        final LocationsCubit c = e.locations();
        await c.init();
        await _settle();
        final int before = e.remote.writes.length;
        expect(await c.toggleStatus(_hq), isFalse);
        expect(c.state.failure, TimeTrackerActionFailure.denied);
        expect(await c.delete(_hq), isFalse);
        expect(await c.applyImport(c.planImport(<List<String>>[
          LocationImportRules.headings,
          <String>['New'],
        ])), isFalse);
        expect(e.remote.writes.length, before);
        await c.close();
      }
    });

    test('import creates new rows and updates matching ones (blank keeps)', () async {
      final _Env e = _Env();
      seedLocations(e.remote, <WorkLocation>[_hq.copyWith(city: 'Cairo')]);
      final LocationsCubit c = e.locations();
      await c.init();
      await _settle();
      final List<String> update = List<String>.filled(LocationImportColumn.values.length, '');
      update[LocationImportColumn.nameEn.index] = 'Main Office';
      update[LocationImportColumn.lateAfter.index] = '20';
      final List<String> create = List<String>.filled(LocationImportColumn.values.length, '');
      create[LocationImportColumn.nameEn.index] = 'Warehouse';
      final LocationImportPlan plan =
          c.planImport(<List<String>>[LocationImportRules.headings, update, create]);
      expect(await c.applyImport(plan), isTrue);
      await _settle();
      expect(_storedLocation(e.remote, 'hq').lateAfterMinutes, 20);
      expect(_storedLocation(e.remote, 'hq').city, 'Cairo');
      expect(c.state.listed.length, 2);
      expect(e.log.actions, <String>[
        TimeTrackerLogService.actionEditLocation,
        TimeTrackerLogService.actionCreateLocation,
      ]);
      await c.close();
    });
  });

  group('LocationFormCubit', () {
    test('create: grey until valid, reveal errors, current location, then saved + logged', () async {
      final _Env e = _Env();
      final LocationFormCubit f = e.form();
      expect(f.state.canSubmit, isFalse);
      expect(f.revealErrors(), isFalse);
      expect(f.state.showErrors, isTrue);
      f.update(f.state.draft.copyWith(nameEn: 'HQ', nameAr: 'المقر', country: 'EG', city: 'Cairo', isGeofenceEnabled: true,
          geofenceRadiusMeters: 150));
      expect(f.state.canSubmit, isFalse); // geofence without coordinates
      expect(await f.useCurrentLocation(), isNotNull);
      f.toggleDay(5); // Friday on
      expect(f.state.canSubmit, isTrue);
      expect(await f.submit(), isTrue);
      final WorkLocation saved = _storedLocation(e.remote, 'auto-1');
      expect(saved.latitude, 30.05);
      expect(saved.country, 'EG');
      expect(saved.city, 'Cairo');
      expect(saved.workingDays, <int>[1, 2, 3, 4, 5, 7]);
      expect(e.log.actions, <String>[TimeTrackerLogService.actionCreateLocation]);
      await f.close();
    });

    test('edit: Save grey until something changed; Edit_Location OFF → denied', () async {
      final _Env e = _Env(on: _without(<String>{'Edit_Location'}));
      seedLocations(e.remote, <WorkLocation>[_hq]);
      final LocationFormCubit f = e.form(original: _hq);
      expect(f.state.isEdit, isTrue);
      expect(f.state.canSubmit, isFalse);
      f.update(f.state.draft.copyWith(lateAfterMinutes: 5));
      expect(f.state.canSubmit, isTrue);
      expect(await f.submit(), isFalse);
      expect(f.state.failure, TimeTrackerActionFailure.denied);
      expect(_storedLocation(e.remote, 'hq').lateAfterMinutes, 0);
      await f.close();
    });
  });

  group('EmployeesCubit', () {
    test('department scope: own department only without Employees_All_Departments', () async {
      final _Env own = _Env(on: _without(<String>{'Employees_All_Departments'}));
      final EmployeesCubit a = own.employees();
      await a.init();
      await _settle();
      expect(a.state.rows.map((EmployeeAssignmentRow r) => r.employee.email).toSet(),
          <String>{'me@co.com', 'amr@co.com'});
      await a.close();
      final EmployeesCubit b = _Env().employees();
      await b.init();
      await _settle();
      expect(b.state.rows.length, 3);
      expect(b.state.unassignedCount, 3);
      await b.close();
    });

    test('assign (Assign_Employee) then reassign needs Reassign_Employee_Location; remove keeps history', () async {
      final _Env e = _Env(on: _without(<String>{'Reassign_Employee_Location'}));
      seedLocations(e.remote, <WorkLocation>[_hq, _b2]);
      final EmployeesCubit c = e.employees();
      await c.init();
      await _settle();
      final bool ok = await c.grantAccess(
        emails: <String>['me@co.com', 'amr@co.com'],
        locationId: 'hq',
        startDate: DateTime(2026, 10, 12),
        rules: const AttendanceRules(isPauseAllowed: true),
      );
      expect(ok, isTrue);
      await _settle();
      expect(c.state.assignedCount, 2);
      expect(_storedAssignment(e.remote, 'me@co.com').rules.isPauseAllowed, isTrue);
      expect(await c.grantAccess(
        emails: <String>['me@co.com'],
        locationId: 'b2',
        startDate: DateTime(2026, 10, 13),
        rules: const AttendanceRules(),
      ), isFalse);
      expect(c.state.failure, TimeTrackerActionFailure.denied);
      expect(await c.removeAssignment('amr@co.com'), isTrue);
      await _settle();
      expect(_storedAssignment(e.remote, 'amr@co.com').isAssigned, isFalse);
      expect(e.log.actions, <String>[
        TimeTrackerLogService.actionAssignEmployee,
        TimeTrackerLogService.actionAssignEmployee,
        TimeTrackerLogService.actionRemoveEmployee,
      ]);
      await c.close();
    });

    test('a saved group assigns its members; deleting it keeps their location', () async {
      final _Env e = _Env();
      seedLocations(e.remote, <WorkLocation>[_hq]);
      final EmployeesCubit c = e.employees();
      await c.init();
      await _settle();
      final EmployeeGroup draft = EmployeeGroup(
        id: '',
        name: 'Design',
        memberEmails: const <String>['me@co.com', 'amr@co.com'],
        locationId: 'hq',
        startDate: DateTime(2026, 10, 12),
        rules: const AttendanceRules(isBreakAllowed: true, breakMinutes: 30),
      );
      expect(await c.saveGroup(draft), isTrue);
      await _settle();
      final EmployeeGroup saved = c.state.liveGroups.single;
      final LocationAssignment me = _storedAssignment(e.remote, 'me@co.com');
      expect(me.locationId, 'hq');
      expect(me.groupId, saved.id);
      // Decision 33 (9/10/2026): the member links to the group (not a copy);
      // the group's custom 30-minute break applies through the resolver.
      expect(me.rules.isCustom, isFalse);
      expect(c.state.effectiveRulesOf('me@co.com')!.source, RulesSource.group);
      expect(c.state.effectiveRulesOf('me@co.com')!.rules.breakMinutes, 30);
      expect(await c.deleteGroup(saved), isTrue);
      await _settle();
      expect(c.state.liveGroups, isEmpty);
      expect(_storedAssignment(e.remote, 'me@co.com').locationId, 'hq');
      expect(_storedAssignment(e.remote, 'me@co.com').groupId, '');
      expect(e.log.actions, <String>[
        TimeTrackerLogService.actionCreateGroup,
        TimeTrackerLogService.actionDeleteGroup,
      ]);
      await c.close();
    });

    test('Create_Group OFF, or a company with HR → refused', () async {
      for (final _Env e in <_Env>[_Env(on: _without(<String>{'Create_Group'})), _Env(hr: true)]) {
        final EmployeesCubit c = e.employees();
        await c.init();
        await _settle();
        expect(await c.saveGroup(const EmployeeGroup(id: '', name: 'x')), isFalse);
        expect(c.state.failure, TimeTrackerActionFailure.denied);
        expect(e.remote.writes, isEmpty);
        await c.close();
      }
    });
  });

  group('GroupFormCubit', () {
    test('names (EN + AR), members and rules required; edit is grey until changed', () async {
      final GroupFormCubit f = GroupFormCubit(
        attachments: FakeGroupUploads(),
        access: accessWith(allKeys()),
        pickImage: () async => null,
      );
      expect(f.revealErrors(), isFalse);
      // Decision 32 (9/10/2026): the Arabic name is required too.
      expect(f.state.groupErrors, <GroupFormError>{
        GroupFormError.nameRequired,
        GroupFormError.nameArRequired,
        GroupFormError.membersRequired,
      });
      // Decision 33: a new group follows its location's rules.
      expect(f.state.draft.rules.isCustom, isFalse);
      f.update(f.state.draft.copyWith(name: 'Ops', locationId: 'hq', startDate: DateTime(2026, 10, 12)));
      expect(f.state.groupErrors, contains(GroupFormError.nameArRequired));
      f.update(f.state.draft.copyWith(nameAr: 'العمليات'));
      f.setMembers(<String>['Me@co.com', 'me@co.com']);
      expect(f.state.draft.memberEmails, <String>['me@co.com']);
      expect(f.state.canSubmit, isTrue);
      await f.close();
      final GroupFormCubit edit = GroupFormCubit(
        attachments: FakeGroupUploads(),
        access: accessWith(allKeys()),
        original: EmployeeGroup(
            id: 'g', name: 'Ops', nameAr: 'العمليات', memberEmails: const <String>['me@co.com'], locationId: 'hq',
            startDate: DateTime(2026, 10, 12)),
        pickImage: () async => null,
      );
      expect(edit.state.canSubmit, isFalse);
      edit.update(edit.state.draft.copyWith(description: 'Night shift'));
      expect(edit.state.canSubmit, isTrue);
      // Turning "Use the location's rules" OFF is a change too.
      edit.update(edit.state.draft.copyWith(description: ''));
      expect(edit.state.canSubmit, isFalse);
      edit.update(edit.state.draft.copyWith(rules: edit.state.draft.rules.copyWith(isCustom: false)));
      expect(edit.state.canSubmit, isTrue);
      await edit.close();
    });
  });

  group('Request types', () {
    test('form: both names required; create logged; nothing seeded', () async {
      final _Env e = _Env();
      final RequestTypesCubit list = RequestTypesCubit(
        types: RequestTypeRepositoryImpl(remoteDataSource: e.remote, access: e.access),
        resolver: e.resolver,
        directory: FakeDirectory(),
        access: e.access,
        log: e.log,
      );
      await list.init();
      await _settle();
      expect(list.state.types, isEmpty);
      final RequestTypeFormCubit f = RequestTypeFormCubit(
        types: RequestTypeRepositoryImpl(remoteDataSource: e.remote, access: e.access),
        access: e.access,
        log: e.log,
      );
      f.update(f.state.draft.copyWith(nameEn: 'Sick Leave'));
      expect(f.state.canSubmit, isFalse);
      f.update(f.state.draft.copyWith(nameAr: 'إجازة مرضية', isDeductedFromVacationBalance: true));
      expect(await f.submit(), isTrue);
      await _settle();
      expect(list.state.types.single.isDeductedFromVacationBalance, isTrue);
      expect(list.state.departments['dep-1'], 'Design');
      expect(await list.toggleStatus(list.state.types.single), isTrue);
      await _settle();
      expect(list.state.types.single.status, RequestTypeStatus.inactive);
      expect(await list.remove(list.state.types.single), isTrue);
      await _settle();
      expect(list.state.types.single.status, RequestTypeStatus.removed);
      expect(e.log.actions, <String>[
        TimeTrackerLogService.actionCreateRequestType,
        TimeTrackerLogService.actionChangeRequestTypeStatus,
        TimeTrackerLogService.actionRemoveRequestType,
      ]);
      await f.close();
      await list.close();
    });

    test('edit: a status change also needs Change_Request_Type_Status', () async {
      final _Env e = _Env(on: _without(<String>{'Change_Request_Type_Status'}));
      const RequestType sick = RequestType(id: 't1', nameEn: 'Sick', nameAr: 'مرضية');
      seedRequestTypes(e.remote, <RequestType>[sick]);
      final RequestTypeFormCubit f = RequestTypeFormCubit(
        types: RequestTypeRepositoryImpl(remoteDataSource: e.remote, access: e.access),
        access: e.access,
        log: e.log,
        original: sick,
      );
      f.update(f.state.draft.copyWith(status: RequestTypeStatus.inactive));
      expect(await f.submit(), isFalse);
      expect(f.state.failure, TimeTrackerActionFailure.denied);
      f.acknowledgeFailure();
      f.update(f.state.draft.copyWith(status: RequestTypeStatus.active, nameEn: 'Sick Leave'));
      expect(await f.submit(), isTrue);
      await f.close();
    });
  });
}
