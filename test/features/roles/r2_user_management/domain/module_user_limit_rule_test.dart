/// Module: test / roles / r2_user_management / domain
///
///*************************** FILE INFO ****************************///
/// File Name: module_user_limit_rule_test.dart
/// Purpose: The per-module / total user-limit rule (Knowticed Admin limits)
///          — aliases, history-list fields, revoked / inactive excluded,
///          missing limit = unlimited, total limit, multi-module roles.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Shapes are the live ones read from knowticed-v2-scheme on 9/10/2026:
///   Demo_Requests/DM-002.Demo_Details = {Modules_User_Limits: {services: 20,
///     knowledge_hub: 10}, Number_Of_Users: {Values: [20], Timestamps: [...]}}
///   Roles: {Name: 'Employee', Selected_Modules: [...], Status: 'active'};
///     the seeded Master Admin: {roleName: [...], selectedModules: [...]}
///   User_Management: {Role: ['Employee'], From_Date: ['Oct 09, 2026'],
///     To_Date: ['Apr 07, 2027'], ...}
///   Users_Access (Admin seed): {Role: {Values: ['Master Admin'], ...}, ...}

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';

final DateTime now = DateTime(2026, 10, 9, 12);
final DateTime nextYear = DateTime(2027, 4, 7);
final DateTime lastMonth = DateTime(2026, 9, 1);

/// [count] active holders of [role], ids `prefix0..`.
List<SeatRecord> holders(String role, int count, {String prefix = 'u'}) =>
    <SeatRecord>[
      for (int i = 0; i < count; i++)
        SeatRecord(employeeId: '$prefix$i', role: role, accessEnd: nextYear),
    ];

List<ProposedAssignment> assign(String role, List<String> ids) =>
    <ProposedAssignment>[
      for (final String id in ids) ProposedAssignment(employeeId: id, role: role),
    ];

LicenceLimits limitsOf(Map<String, Object?> modules, {Object? total}) =>
    LicenceLimits.fromDemoRequest(<String, dynamic>{
      'Demo_Details': <String, dynamic>{
        'Modules_User_Limits': modules,
        if (total != null) 'Number_Of_Users': total,
      },
    });

void main() {
  group('StoredValue — every field may be a history list', () {
    test('currentString takes the LAST value of a list or a {Values} map', () {
      expect(StoredValue.currentString(<String>['employee', 'Employee']),
          'Employee');
      expect(
          StoredValue.currentString(<String, dynamic>{
            'Values': <String>['Master Admin'],
            'Timestamps': <String>['2026-10-07T09:53:00Z'],
          }),
          'Master Admin');
      expect(StoredValue.currentString('  HR Officer '), 'HR Officer');
      expect(StoredValue.currentString(<String>[]), isNull);
      expect(StoredValue.currentString(null), isNull);
    });

    test('currentInt reads ints, numbers, strings, lists and {Values} maps', () {
      expect(StoredValue.currentInt(10), 10);
      expect(StoredValue.currentInt(10.0), 10);
      expect(StoredValue.currentInt(' 12 '), 12);
      expect(StoredValue.currentInt(<int>[5, 20]), 20);
      expect(
          StoredValue.currentInt(<String, dynamic>{
            'Values': <int>[20],
            'Timestamps': <String>['x'],
          }),
          20);
      expect(StoredValue.currentInt('ten'), isNull);
    });

    test('currentModules: a flat list IS the value; a list of lists is history',
        () {
      expect(StoredValue.currentModules(<String>['settings', 'time_tracker']),
          <String>['settings', 'time_tracker']);
      expect(
          StoredValue.currentModules(<List<String>>[
            <String>['settings'],
            <String>['settings', 'services'],
          ]),
          <String>['settings', 'services']);
      expect(StoredValue.currentModules(null), isEmpty);
    });
  });

  group('LicenceLimits.fromDemoRequest', () {
    test('reads the live DM-002 shape', () {
      final LicenceLimits limits = LicenceLimits.fromDemoRequest(
          <String, dynamic>{
        'Request_Status': 'approved',
        'Demo_Details': <String, dynamic>{
          'Modules_User_Limits': <String, dynamic>{
            'services': 20,
            'knowledge_hub': 10,
          },
          'Number_Of_Users': <String, dynamic>{
            'Values': <int>[20],
            'Timestamps': <String>['2026-09-24T15:03:54Z'],
          },
        },
      });
      expect(limits.moduleLimits,
          <String, int>{'services': 20, 'knowledge_hub': 10});
      expect(limits.totalUsers, 20);
      expect(limits.isEmpty, isFalse);
    });

    test('Admin licence keys are canonicalised (tracking, database, form_builder)',
        () {
      final LicenceLimits limits = limitsOf(<String, Object?>{
        'tracking': 10,
        'database': 5,
        'form_builder': 3,
      });
      expect(limits.moduleLimits, <String, int>{
        'time_tracker': 10,
        'database_builder': 5,
        'services_app': 3,
      });
    });

    test('two spellings of one module: the stricter limit wins', () {
      final LicenceLimits limits =
          limitsOf(<String, Object?>{'database': 8, 'database_builder': 5});
      expect(limits.moduleLimits['database_builder'], 5);
    });

    test('settings is never limited; a null entry is "no limit"', () {
      final LicenceLimits limits =
          limitsOf(<String, Object?>{'settings': 1, 'services': null});
      expect(limits.moduleLimits, isEmpty);
      expect(limits.invalidModules, isEmpty);
    });

    test('an unreadable value is recorded, not dropped', () {
      final LicenceLimits limits =
          limitsOf(<String, Object?>{'services': 'lots', 'todo': -1},
              total: 'many');
      expect(limits.invalidModules, <String>{'services', 'todo'});
      expect(limits.totalInvalid, isTrue);
      expect(limits.totalUsers, isNull);
    });

    test('no document / no Demo_Details → nothing to enforce', () {
      expect(LicenceLimits.fromDemoRequest(null).isEmpty, isTrue);
      expect(LicenceLimits.fromDemoRequest(<String, dynamic>{}).isEmpty, isTrue);
    });

    test('Modules_User_Limits that is not a map at all is unreadable', () {
      expect(limitsOf(<String, Object?>{}).limitsUnreadable, isFalse);
      final LicenceLimits limits = LicenceLimits.fromDemoRequest(
          <String, dynamic>{
        'Demo_Details': <String, dynamic>{'Modules_User_Limits': 'broken'},
      });
      expect(limits.limitsUnreadable, isTrue);
    });
  });

  group('RoleModulesIndex.fromRoleDocs', () {
    final RoleModulesIndex roles = RoleModulesIndex.fromRoleDocs(
        <MapEntry<String, Map<String, dynamic>>>[
      // The format every role saved from the app has (role_model.dart toMap).
      const MapEntry<String, Map<String, dynamic>>('1791366780667',
          <String, dynamic>{
        'Name': <String>['Staff', 'Employee'],
        'Selected_Modules': <String>['settings', 'time_tracker', 'notification'],
        'Status': <String>['active'],
      }),
      // The seeded Master Admin (Roles + Subscription_Admin): camelCase, and
      // `Selected_Modules` wins over `selectedModules` like RoleHistoryModel.
      const MapEntry<String, Map<String, dynamic>>('1791366780666',
          <String, dynamic>{
        'roleName': 'Master Admin',
        'Selected_Modules': <String>['services', 'tracking', 'database_builder'],
        'selectedModules': <String>['services'],
      }),
      const MapEntry<String, Map<String, dynamic>>('sub-1', <String, dynamic>{
        'roleName': <String>['Master Admin'],
        'selectedModules': <String>['knowledge_hub'],
      }),
      const MapEntry<String, Map<String, dynamic>>('gone', <String, dynamic>{
        'Name': 'Retired Role',
        'Selected_Modules': <String>['services'],
        'Status': <String>['active', 'deleted'],
      }),
    ]);

    test('reads Name / Selected_Modules (the bug: only roleName was read)', () {
      expect(roles.modulesOf('Employee'),
          <String>{'settings', 'time_tracker', 'notification'});
    });

    test('role lookup ignores case and spacing (User_Management stores "employee")',
        () {
      expect(roles.modulesOf('employee'), isNotNull);
      expect(roles.modulesOf('  EMPLOYEE '), isNotNull);
    });

    test('module aliases are canonicalised (tracking → time_tracker)', () {
      expect(roles.modulesOf('Master Admin'), contains('time_tracker'));
    });

    test('a role in both collections merges its modules', () {
      expect(roles.modulesOf('master admin'),
          <String>{'services', 'time_tracker', 'database_builder', 'knowledge_hub'});
    });

    test('an earlier name of a renamed role still resolves', () {
      expect(roles.modulesOf('Staff'), roles.modulesOf('Employee'));
    });

    test('a deleted role grants nothing', () {
      expect(roles.modulesOf('Retired Role'), isNull);
    });
  });

  group('SeatRecord.fromAccessDoc', () {
    test('User_Management lists — the LAST value is current', () {
      final SeatRecord record = SeatRecord.fromAccessDoc('1001', <String, dynamic>{
        'Employee_Id': '1001',
        'Role': <String>['Employee', 'department manager'],
        'From_Date': <String>['Oct 09, 2026', 'Oct 09, 2026'],
        'To_Date': <String>['Oct 10, 2026', 'Apr 07, 2027'],
      });
      expect(record.role, 'department manager');
      expect(record.accessEnd, DateTime(2027, 4, 7));
    });

    test('Users_Access {Values} maps', () {
      final SeatRecord record = SeatRecord.fromAccessDoc('1', <String, dynamic>{
        'Role': <String, dynamic>{
          'Values': <String>['Master Admin'],
          'Timestamps': <String>['x'],
        },
        'To_Date': <String, dynamic>{
          'Values': <String>['Apr 05, 2027'],
          'Timestamps': <String>['x'],
        },
      });
      expect(record.role, 'Master Admin');
      expect(record.accessEnd, DateTime(2027, 4, 5));
    });

    test('an unreadable end date is kept as null (still active)', () {
      final SeatRecord record = SeatRecord.fromAccessDoc('9', <String, dynamic>{
        'Role': <String>['Employee'],
        'To_Date': <String>['someday'],
      });
      expect(record.accessEnd, isNull);
    });
  });

  group('seatHolders — revoked / inactive are excluded', () {
    test('the revoked marker matches Constants.removedEmployeePermission', () {
      expect(ModuleUserLimitRule.revokedRole,
          Constants.removedEmployeePermission);
    });

    test('revoked, expired and deactivated users hold no seat', () {
      final Map<String, String> seats = ModuleUserLimitRule.seatHolders(
        <SeatRecord>[
          SeatRecord(employeeId: 'a', role: 'Employee', accessEnd: nextYear),
          SeatRecord(employeeId: 'b', role: 'removed', accessEnd: nextYear),
          SeatRecord(employeeId: 'c', role: 'Employee', accessEnd: lastMonth),
          SeatRecord(employeeId: 'd', role: 'Employee', accessEnd: nextYear),
          const SeatRecord(employeeId: 'e', role: ''),
          const SeatRecord(employeeId: 'f', role: 'Employee'), // no end date
        ],
        now,
        deactivatedOn: <String, DateTime?>{'d': lastMonth},
      );
      expect(seats.keys, unorderedEquals(<String>['a', 'f']));
    });

    test('the later record for one employee wins, even an inactive one', () {
      final Map<String, String> seats = ModuleUserLimitRule.seatHolders(
        <SeatRecord>[
          // fallback (Users_Access) first, User_Management last
          SeatRecord(employeeId: '1', role: 'Master Admin', accessEnd: nextYear),
          SeatRecord(employeeId: '1', role: 'removed', accessEnd: nextYear),
        ],
        now,
      );
      expect(seats, isEmpty);
    });
  });

  group('ModuleUserLimitRule.evaluate', () {
    final RoleModulesIndex roles = RoleModulesIndex.of(<String, List<String>>{
      'Employee': <String>['settings', 'time_tracker', 'notification'],
      'Analyst': <String>['settings', 'services', 'knowledge_hub'],
      'Viewer': <String>['settings'],
      'Tracker Lead': <String>['settings', 'tracking'],
    });

    LimitVerdict check(
      LicenceLimits limits,
      List<SeatRecord> records,
      List<ProposedAssignment> proposed,
    ) =>
        ModuleUserLimitRule.evaluate(
          limits: limits,
          roles: roles,
          records: records,
          proposed: proposed,
          now: now,
        );

    test('owner example: Time Tracker 10 of 10 → the 11th is refused', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{'tracking': 10}),
        holders('Employee', 10),
        assign('employee', <String>['new']),
      );
      expect(verdict.allowed, isFalse);
      final LimitViolation v = verdict.violations.single;
      expect(v.kind, LimitViolationKind.module);
      expect(v.module, 'time_tracker');
      expect(v.limit, 10);
      expect(v.assigned, 10);
      expect(v.requested, 11);
      expect(v.remaining, 0);
    });

    test('aliases on BOTH sides: limit key `time_tracker`, role module `tracking`', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{'time_tracker': 1}),
        holders('Employee', 1),
        assign('Tracker Lead', <String>['new']),
      );
      expect(verdict.violations.single.module, 'time_tracker');
    });

    test('multi-select: 8 of 10 used, 3 selected is refused, 2 is allowed', () {
      final LicenceLimits limits = limitsOf(<String, Object?>{'tracking': 10});
      final LimitVerdict three = check(limits, holders('Employee', 8),
          assign('Employee', <String>['x', 'y', 'z']));
      expect(three.allowed, isFalse);
      expect(three.violations.single.remaining, 2);
      expect(three.violations.single.requested, 11);

      final LimitVerdict two = check(
          limits, holders('Employee', 8), assign('Employee', <String>['x', 'y']));
      expect(two.allowed, isTrue);
    });

    test('a module with no entry is unlimited', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{'knowledge_hub': 1}),
        holders('Employee', 500),
        assign('Employee', <String>['new']),
      );
      expect(verdict.allowed, isTrue);
    });

    test('no limits at all → always allowed', () {
      final LimitVerdict verdict = check(const LicenceLimits(),
          holders('Employee', 500), assign('Unknown Role', <String>['n']));
      expect(verdict.allowed, isTrue);
    });

    test('multi-module role: blocked by the ONE full module, named', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{'services': 20, 'knowledge_hub': 10}),
        holders('Analyst', 10),
        assign('Analyst', <String>['new']),
      );
      expect(verdict.violations.map((LimitViolation v) => v.module),
          <String?>['knowledge_hub']);
    });

    test('multi-module role: every full module is reported', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{'services': 3, 'knowledge_hub': 3}),
        holders('Analyst', 3),
        assign('Analyst', <String>['new']),
      );
      expect(verdict.violations.map((LimitViolation v) => v.module),
          unorderedEquals(<String>['services', 'knowledge_hub']));
    });

    test('total Number_Of_Users: the 21st user is refused', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{}, total: <String, dynamic>{
          'Values': <int>[20],
          'Timestamps': <String>['x'],
        }),
        holders('Viewer', 20),
        assign('Viewer', <String>['new']),
      );
      final LimitViolation v = verdict.violations.single;
      expect(v.kind, LimitViolationKind.totalUsers);
      expect(v.limit, 20);
      expect(v.assigned, 20);
    });

    test('total: changing an existing user\'s role adds no user', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{}, total: 20),
        holders('Viewer', 20),
        assign('Employee', <String>['u0']),
      );
      expect(verdict.allowed, isTrue);
    });

    test('revoked and expired users free their seat', () {
      final List<SeatRecord> records = <SeatRecord>[
        ...holders('Employee', 8),
        SeatRecord(employeeId: 'r', role: 'removed', accessEnd: nextYear),
        SeatRecord(employeeId: 'x', role: 'Employee', accessEnd: lastMonth),
      ];
      final LimitVerdict verdict = check(
          limitsOf(<String, Object?>{'tracking': 10}),
          records,
          assign('Employee', <String>['n1', 'n2']));
      expect(verdict.allowed, isTrue);
    });

    test('re-saving a user who already holds the seat is never blocked, even over a lowered limit',
        () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{'tracking': 5}),
        holders('Employee', 8),
        assign('Employee', <String>['u3']),
      );
      expect(verdict.allowed, isTrue);
    });

    test('moving a user between two roles that both carry the module adds no seat',
        () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{'tracking': 2}),
        holders('Employee', 2),
        assign('Tracker Lead', <String>['u0']),
      );
      expect(verdict.allowed, isTrue);
    });

    test('re-activating an EXPIRED user takes a seat again', () {
      final List<SeatRecord> records = <SeatRecord>[
        ...holders('Employee', 10),
        SeatRecord(employeeId: 'old', role: 'Employee', accessEnd: lastMonth),
      ];
      final LimitVerdict verdict = check(
          limitsOf(<String, Object?>{'tracking': 10}),
          records,
          assign('Employee', <String>['old']));
      expect(verdict.allowed, isFalse);
    });

    test('a scheduled (future-start) grant already holds its seat', () {
      // From_Date is not read: a record counts from the moment it is saved.
      final SeatRecord scheduled = SeatRecord.fromAccessDoc('s', <String, dynamic>{
        'Role': <String>['Employee'],
        'From_Date': <String>['Dec 01, 2026'],
        'To_Date': <String>['Jun 01, 2027'],
      });
      final LimitVerdict verdict = check(
          limitsOf(<String, Object?>{'tracking': 1}),
          <SeatRecord>[scheduled],
          assign('Employee', <String>['n']));
      expect(verdict.allowed, isFalse);
    });

    test('an unknown role fails closed while module limits are set', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{'services': 5}),
        const <SeatRecord>[],
        assign('Ghost Role', <String>['n']),
      );
      expect(verdict.violations.single.kind, LimitViolationKind.unknownRole);
      expect(verdict.violations.single.role, 'Ghost Role');
    });

    test('an unreadable module limit fails closed only when a seat is added to it',
        () {
      final LicenceLimits limits = limitsOf(<String, Object?>{'services': 'x'});
      expect(
          check(limits, const <SeatRecord>[], assign('Analyst', <String>['n']))
              .violations
              .single
              .kind,
          LimitViolationKind.moduleUnverifiable);
      expect(
          check(limits, const <SeatRecord>[], assign('Viewer', <String>['n']))
              .allowed,
          isTrue);
    });

    test('an unreadable Number_Of_Users fails closed when a user is added', () {
      final LimitVerdict verdict = check(
        limitsOf(<String, Object?>{}, total: 'twenty'),
        const <SeatRecord>[],
        assign('Viewer', <String>['n']),
      );
      expect(verdict.violations.single.kind,
          LimitViolationKind.totalUnverifiable);
    });

    test('unreadable Modules_User_Limits fails closed', () {
      final LicenceLimits limits = LicenceLimits.fromDemoRequest(
          <String, dynamic>{
        'Demo_Details': <String, dynamic>{'Modules_User_Limits': 7},
      });
      final LimitVerdict verdict = check(
          limits, const <SeatRecord>[], assign('Viewer', <String>['n']));
      expect(verdict.violations.single.kind,
          LimitViolationKind.limitsUnverifiable);
    });
  });

  group('usage lines', () {
    final RoleModulesIndex roles = RoleModulesIndex.of(<String, List<String>>{
      'Employee': <String>['settings', 'tracking', 'services'],
      'Viewer': <String>['settings'],
    });
    final LicenceUsageSnapshot snapshot = LicenceUsageSnapshot(
      limits: limitsOf(<String, Object?>{'tracking': 10, 'knowledge_hub': 4},
          total: 20),
      roles: roles,
      records: <SeatRecord>[
        ...holders('Employee', 8),
        ...holders('Viewer', 10, prefix: 'v'),
        SeatRecord(employeeId: 'gone', role: 'removed', accessEnd: nextYear),
      ],
    );

    test('only the LIMITED modules of the role, then the company total', () {
      final List<ModuleUsage> usage = snapshot.usageForRole('employee', now: now);
      expect(usage.single.module, 'time_tracker');
      expect(usage.single.assigned, 8);
      expect(usage.single.limit, 10);

      final ModuleUsage total = snapshot.totalUsage(now: now)!;
      expect(total.module, isNull);
      expect(total.assigned, 18);
      expect(total.limit, 20);
    });

    test('a role with no limited module has no module lines', () {
      expect(snapshot.usageForRole('Viewer', now: now), isEmpty);
    });

    test('the snapshot pre-check agrees with the rule', () {
      expect(
          snapshot
              .check(assign('Employee', <String>['a', 'b']), now: now)
              .allowed,
          isTrue);
      expect(
          snapshot
              .check(assign('Employee', <String>['a', 'b', 'c']), now: now)
              .allowed,
          isFalse);
    });
  });
}
