/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: effective_rules_test.dart
/// Purpose: Owner decisions 32–33 (round 6, 9/10/2026) — the LOCATION is
///          the source of the attendance rules: `EffectiveRulesResolver`
///          precedence (employee custom → group custom → location), a
///          location edit applies at once, saving a group never overwrites
///          an employee's own custom rules, a leaving member goes back to the
///          location, the approved-schema `Custom_Rules` map +
///          `Allowed_Break_Minutes` / `Allowed_Pause_Minutes` (legacy rows
///          still read) and the
///          bilingual group name / description.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/employee_group_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';

const WorkLocation _hq = WorkLocation(
  id: 'hq',
  nameEn: 'Main Office',
  workStartMinutes: 8 * 60,
  workEndMinutes: 16 * 60,
  lateAfterMinutes: 10,
  isBreakAllowed: true,
  breakMinutes: 30,
  isPauseAllowed: true,
);

const AttendanceRules _groupCustom = AttendanceRules(
  isBreakAllowed: true,
  breakMinutes: 45,
  isPauseAllowed: false,
  isDifferentLocationAllowed: true,
  allowedLocationIds: <String>['branch'],
);

const AttendanceRules _ownCustom = AttendanceRules(isBreakAllowed: true, breakMinutes: 15, isPauseAllowed: true);

LocationAssignment _a({AttendanceRules rules = AttendanceRules.fromLocation, String groupId = ''}) =>
    LocationAssignment(employeeEmail: 'me@co.com', locationId: 'hq', rules: rules, groupId: groupId);

EmployeeGroup _g({AttendanceRules rules = AttendanceRules.fromLocation, bool deleted = false}) => EmployeeGroup(
      id: 'g1',
      name: 'Field team',
      locationId: 'hq',
      memberEmails: const <String>['me@co.com'],
      rules: rules,
      isDeleted: deleted,
    );

void main() {
  group('EffectiveRulesResolver (decision 33)', () {
    test('no assignment rules of its own and no group → the location\'s rules', () {
      final EffectiveRules r = EffectiveRulesResolver.resolve(location: _hq, assignment: _a());
      expect(r.source, RulesSource.location);
      expect(r.isFromLocation, isTrue);
      expect(r.rules.isBreakAllowed, isTrue);
      expect(r.rules.breakMinutes, 30);
      expect(r.rules.isPauseAllowed, isTrue);
      expect(r.rules.isCustom, isFalse);
    });

    test('a location edit applies at once (nothing was copied)', () {
      const WorkLocation edited = WorkLocation(
        id: 'hq',
        nameEn: 'Main Office',
        isBreakAllowed: true,
        breakMinutes: 60,
        isPauseAllowed: false,
      );
      final EffectiveRules before = EffectiveRulesResolver.resolve(location: _hq, assignment: _a(groupId: 'g1'), group: _g());
      final EffectiveRules after =
          EffectiveRulesResolver.resolve(location: edited, assignment: _a(groupId: 'g1'), group: _g());
      expect(before.rules.breakMinutes, 30);
      expect(after.rules.breakMinutes, 60);
      expect(after.rules.isPauseAllowed, isFalse);
      expect(after.source, RulesSource.location);
    });

    test('group custom rules override the location for its members', () {
      final EffectiveRules r =
          EffectiveRulesResolver.resolve(location: _hq, assignment: _a(groupId: 'g1'), group: _g(rules: _groupCustom));
      expect(r.source, RulesSource.group);
      expect(r.rules.breakMinutes, 45);
      expect(r.rules.isPauseAllowed, isFalse);
      // "Allow Different Work Location" stays the group's.
      expect(r.rules.isDifferentLocationAllowed, isTrue);
      expect(r.rules.allowedLocationIds, <String>['branch']);
    });

    test('employee custom rules win over the group and the location', () {
      final EffectiveRules r = EffectiveRulesResolver.resolve(
        location: _hq,
        assignment: _a(rules: _ownCustom, groupId: 'g1'),
        group: _g(rules: _groupCustom),
      );
      expect(r.source, RulesSource.employee);
      expect(r.rules.breakMinutes, 15);
      expect(r.rules.isPauseAllowed, isTrue);
      // The employee's own different-location setting (custom) applies.
      expect(r.rules.isDifferentLocationAllowed, isFalse);
    });

    test('a group the employee is not linked to (or a deleted group) is ignored', () {
      final EffectiveRules other =
          EffectiveRulesResolver.resolve(location: _hq, assignment: _a(), group: _g(rules: _groupCustom));
      expect(other.source, RulesSource.location);
      final EffectiveRules deleted = EffectiveRulesResolver.resolve(
        location: _hq,
        assignment: _a(groupId: 'g1'),
        group: _g(rules: _groupCustom, deleted: true),
      );
      expect(deleted.source, RulesSource.location);
      expect(deleted.rules.breakMinutes, 30);
    });

    test('a location without breaks gives no break minutes', () {
      const WorkLocation noBreaks = WorkLocation(id: 'hq', nameEn: 'HQ', breakMinutes: 30);
      final AttendanceRules r = EffectiveRulesResolver.locationRules(noBreaks);
      expect(r.isBreakAllowed, isFalse);
      expect(r.breakMinutes, 0);
    });
  });

  group('GroupAssignmentPlanner (decision 33)', () {
    test('saving a group with custom rules links members without copying the rules', () {
      final List<LocationAssignment> out = GroupAssignmentPlanner.plan(
        group: _g(rules: _groupCustom),
        previousMembers: const <String>[],
        stored: const <LocationAssignment>[],
      );
      expect(out, hasLength(1));
      expect(out.single.groupId, 'g1');
      expect(out.single.locationId, 'hq');
      expect(out.single.rules.isCustom, isFalse);
      expect(out.single.rules.breakMinutes, 0);
      // …and the member resolves to the group's custom rules.
      expect(
        EffectiveRulesResolver.resolve(location: _hq, assignment: out.single, group: _g(rules: _groupCustom)).source,
        RulesSource.group,
      );
    });

    test('an employee\'s own custom rules are never overwritten by a group save', () {
      final List<LocationAssignment> out = GroupAssignmentPlanner.plan(
        group: _g(rules: _groupCustom),
        previousMembers: const <String>[],
        stored: <LocationAssignment>[_a(rules: _ownCustom)],
      );
      expect(out.single.groupId, 'g1');
      expect(out.single.rules.isCustom, isTrue);
      expect(out.single.rules.breakMinutes, 15);
    });

    test('a member removed from the group goes back to the location\'s rules', () {
      final List<LocationAssignment> out = GroupAssignmentPlanner.plan(
        group: _g(rules: _groupCustom).copyWith(memberEmails: const <String>[]),
        previousMembers: const <String>['me@co.com'],
        stored: <LocationAssignment>[_a(groupId: 'g1')],
      );
      expect(out.single.groupId, '');
      expect(out.single.locationId, 'hq');
      expect(out.single.rules.isCustom, isFalse);
      expect(EffectiveRulesResolver.resolve(location: _hq, assignment: out.single).source, RulesSource.location);
    });

    test('an unchanged member is not rewritten', () {
      final List<LocationAssignment> out = GroupAssignmentPlanner.plan(
        group: _g(),
        previousMembers: const <String>['me@co.com'],
        stored: <LocationAssignment>[_a(groupId: 'g1')],
      );
      expect(out, isEmpty);
    });

    test('"Use the location\'s rules" needs no break length; custom rules do', () {
      expect(
        AssignmentRules.validate(
          locationId: 'hq',
          startDate: DateTime(2026, 10, 9),
          rules: AttendanceRules.fromLocation.copyWith(isBreakAllowed: true),
        ),
        isEmpty,
      );
      expect(
        AssignmentRules.validate(
          locationId: 'hq',
          startDate: DateTime(2026, 10, 9),
          rules: const AttendanceRules(isBreakAllowed: true),
        ),
        isNotEmpty,
      );
    });
  });

  group('approved schema: Custom_Rules map + location defaults', () {
    Map<String, dynamic> row(Map<String, Object?> fields) => <String, dynamic>{
          for (final MapEntry<String, Object?> e in fields.entries) e.key: <Object?>[e.value],
          'timestamps': <Object?>[DateTime(2026, 10, 1)],
        };

    test('Custom_Rules is written as ONE map (Is_Custom false = follow the next level)', () {
      final Map<String, Object?> follow = AttendanceRulesFields.to(AttendanceRules.fromLocation);
      expect(follow[AttendanceRulesFields.fCustomRules], <String, Object?>{
        'Is_Custom': false,
        'Is_Break_Allowed': false,
        'Allowed_Break_Minutes': 0,
        'Is_Pause_Allowed': false,
        'Allowed_Pause_Minutes': 0,
      });
      expect(follow.containsKey('Break_Minutes'), isFalse, reason: 'the old flat fields are never written');
      expect(follow.containsKey('Is_Custom_Rules'), isFalse);
      expect(AttendanceRulesFields.from(row(follow)).isCustom, isFalse);
      const AttendanceRules mine = AttendanceRules(
        isBreakAllowed: true,
        breakMinutes: 15,
        isPauseAllowed: true,
        pauseMinutes: 10,
        isDifferentLocationAllowed: true,
        allowedLocationIds: <String>['branch'],
      );
      final Map<String, Object?> custom = AttendanceRulesFields.to(mine);
      expect(custom[AttendanceRulesFields.fCustomRules], <String, Object?>{
        'Is_Custom': true,
        'Is_Break_Allowed': true,
        'Allowed_Break_Minutes': 15,
        'Is_Pause_Allowed': true,
        'Allowed_Pause_Minutes': 10,
      });
      expect(custom[AttendanceRulesFields.fIsDifferentLocation], isTrue, reason: 'stays a separate field');
      final AttendanceRules back = AttendanceRulesFields.from(row(custom));
      expect(<Object>[back.isCustom, back.breakMinutes, back.pauseMinutes, back.isDifferentLocationAllowed],
          <Object>[true, 15, 10, true]);
      expect(back.allowedLocationIds, <String>['branch']);
    });

    test('a plain (non-history) Custom_Rules map, as the Cloud Functions write it, reads too', () {
      final AttendanceRules r = AttendanceRulesFields.from(<String, dynamic>{
        'Custom_Rules': <String, dynamic>{
          'Is_Custom': true,
          'Is_Break_Allowed': false,
          'Allowed_Break_Minutes': 30,
          'Is_Pause_Allowed': true,
          'Allowed_Pause_Minutes': 15,
        },
      });
      expect(<Object>[r.isCustom, r.isBreakAllowed, r.breakMinutes, r.isPauseAllowed, r.pauseMinutes],
          <Object>[true, false, 0, true, 15]);
    });

    test('Custom_Rules wins over old flat fields still carried on the document', () {
      final AttendanceRules r = AttendanceRulesFields.from(row(<String, Object?>{
        'Is_Break_Allowed': true,
        'Break_Minutes': 45,
        'Custom_Rules': <String, Object?>{'Is_Custom': false},
      }));
      expect(r.isCustom, isFalse);
      expect(r.breakMinutes, 0);
    });

    test('location: Allowed_Break_Minutes + Allowed_Pause_Minutes; old Break_Minutes still read', () {
      final Map<String, Object?> written = WorkLocationModel.row(
        _hq.copyWith(pauseMinutes: 20),
        id: 'hq',
        audit: TimeTrackerAudit(createdBy: 'hr@co.com', createdAt: Timestamp(0, 0), modifiedBy: 'hr@co.com'),
      );
      expect(written['Allowed_Break_Minutes'], 30);
      expect(written['Allowed_Pause_Minutes'], 20);
      expect(written.containsKey('Break_Minutes'), isFalse);
      final WorkLocation back = WorkLocationModel.fromMap('hq', row(written));
      expect(<int>[back.breakMinutes, back.pauseMinutes], <int>[30, 20]);
      final WorkLocation legacy = WorkLocationModel.fromMap('old', row(<String, Object?>{
        'Is_Break_Allowed': true,
        'Break_Minutes': 25,
        'Is_Pause_Allowed': true,
      }));
      expect(legacy.breakMinutes, 25);
      expect(legacy.pauseMinutes, 0, reason: 'no limit');
    });

    test('the pause limit resolves like the other rules (employee → group → location)', () {
      const WorkLocation limited = WorkLocation(
        id: 'hq', nameEn: 'HQ', isPauseAllowed: true, pauseMinutes: 30, isBreakAllowed: true, breakMinutes: 30);
      expect(EffectiveRulesResolver.resolve(location: limited, assignment: _a()).rules.pauseMinutes, 30);
      expect(
        EffectiveRulesResolver.resolve(
          location: limited,
          assignment: _a(groupId: 'g1'),
          group: _g(rules: const AttendanceRules(isPauseAllowed: true, pauseMinutes: 10)),
        ).rules.pauseMinutes,
        10,
      );
      expect(
        EffectiveRulesResolver.resolve(
          location: limited,
          assignment: _a(rules: const AttendanceRules(isPauseAllowed: true, pauseMinutes: 5), groupId: 'g1'),
          group: _g(rules: const AttendanceRules(isPauseAllowed: true, pauseMinutes: 10)),
        ).rules.pauseMinutes,
        5,
      );
      // Pause not allowed at the location → no limit to speak of.
      expect(EffectiveRulesResolver.locationRules(limited.copyWith(isPauseAllowed: false)).pauseMinutes, 0);
    });

    test('a legacy personal assignment keeps its explicit values (custom)', () {
      final LocationAssignment a = LocationAssignmentModel.fromMap('me@co.com', row(<String, Object?>{
        LocationAssignmentModel.fEmployeeEmail: 'me@co.com',
        LocationAssignmentModel.fLocationId: 'hq',
        AttendanceRulesFields.fIsBreakAllowed: true,
        AttendanceRulesFields.fBreakMinutes: 20,
        LocationAssignmentModel.fGroupId: '',
      }));
      expect(a.rules.isCustom, isTrue);
      expect(a.rules.breakMinutes, 20);
    });

    test('a legacy group-linked assignment (a copy of the group) follows its group', () {
      final LocationAssignment a = LocationAssignmentModel.fromMap('me@co.com', row(<String, Object?>{
        LocationAssignmentModel.fEmployeeEmail: 'me@co.com',
        LocationAssignmentModel.fLocationId: 'hq',
        AttendanceRulesFields.fIsBreakAllowed: true,
        AttendanceRulesFields.fBreakMinutes: 45,
        LocationAssignmentModel.fGroupId: 'g1',
      }));
      expect(a.rules.isCustom, isFalse);
      expect(
        EffectiveRulesResolver.resolve(location: _hq, assignment: a, group: _g(rules: _groupCustom)).rules.breakMinutes,
        45,
      );
    });
  });

  group('bilingual group (decision 32)', () {
    const EmployeeGroup g = EmployeeGroup(
      id: 'g1',
      name: 'Field team',
      nameAr: 'فريق الميدان',
      description: 'Site visits',
    );

    test('label / about pick the app language, falling back to the other', () {
      expect(g.label(isArabic: false), 'Field team');
      expect(g.label(isArabic: true), 'فريق الميدان');
      expect(g.about(isArabic: false), 'Site visits');
      expect(g.about(isArabic: true), 'Site visits');
      expect(const EmployeeGroup(id: 'x', name: '', nameAr: 'عربي').label(isArabic: false), 'عربي');
    });

    test('Group_Name_Ar / Description_Ar round-trip', () {
      final Map<String, dynamic> stored = <String, dynamic>{
        for (final MapEntry<String, Object?> e in EmployeeGroupModel.row(
          g.copyWith(descriptionAr: 'زيارات المواقع'),
          id: 'g1',
          audit: TimeTrackerAudit(createdBy: 'hr@co.com', createdAt: Timestamp(0, 0), modifiedBy: 'hr@co.com'),
        ).entries)
          e.key: <Object?>[e.value],
        'timestamps': <Object?>[DateTime(2026, 10, 1)],
      };
      final EmployeeGroup back = EmployeeGroupModel.fromMap('g1', stored);
      expect(back.nameAr, 'فريق الميدان');
      expect(back.descriptionAr, 'زيارات المواقع');
    });
  });
}
