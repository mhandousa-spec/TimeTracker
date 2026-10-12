/// Module: test / roles / r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: subscription_permission_admin_builder_test.dart
/// Purpose: A NEW role now gets its
///          `Demo/{cid}/Subscription_Permission_Admin/{roleId}` document at
///          creation (9/10/2026) — same shape as the edit path, built by the
///          shared `RoleRepository.buildSubscriptionPermissionAdminData`, with
///          every switch capped by Demo_Permissions (the company ceiling).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';

/// `Demo_Permissions/{cid}` — what the company is licensed for.
final Map<String, dynamic> _ceiling = <String, dynamic>{
  'roles': <String, dynamic>{
    'Users_Requests': true,
    'Add_Role': false,
  },
  // Stored under the legacy spelling; the role asks for `services_app`.
  'form_builder': <String, dynamic>{'Create_Form': true},
  'Role_Id': 'x', // non-map keys are ignored
};

void main() {
  group('capToCompanyCeiling', () {
    test('keeps granted switches, forces the rest false (default-deny)', () {
      final Map<String, Map<String, bool>> capped =
          RoleRepository.capToCompanyCeiling(
        requestedPermissions: <String, Map<String, bool>>{
          'roles': <String, bool>{
            'Users_Requests': true,
            'Add_Role': true, // ceiling says no
            'Not_In_Ceiling': true, // ceiling does not list it
          },
          'services_app': <String, bool>{'Create_Form': true},
          'grc': <String, bool>{'View': true}, // module not licensed at all
        },
        demoPermissions: _ceiling,
      );

      expect(capped['roles'], <String, bool>{
        'Users_Requests': true,
        'Add_Role': false,
        'Not_In_Ceiling': false,
      });
      // Alias spelling in the ceiling still grants it.
      expect(capped['services_app'], <String, bool>{'Create_Form': true});
      expect(capped['grc'], <String, bool>{'View': false});
    });

    test('a requested OFF stays off even where the ceiling allows it', () {
      final Map<String, Map<String, bool>> capped =
          RoleRepository.capToCompanyCeiling(
        requestedPermissions: <String, Map<String, bool>>{
          'roles': <String, bool>{'Users_Requests': false},
        },
        demoPermissions: _ceiling,
      );
      expect(capped['roles'], <String, bool>{'Users_Requests': false});
    });
  });

  group('buildSubscriptionPermissionAdminData (creation)', () {
    test('companyId, roleId, timestamps + {module: {switch: bool}}', () {
      final Map<String, Map<String, bool>> validated =
          RoleRepository.capToCompanyCeiling(
        requestedPermissions: <String, Map<String, bool>>{
          'roles': <String, bool>{'Users_Requests': true, 'Add_Role': true},
        },
        demoPermissions: _ceiling,
      );

      final Map<String, dynamic> doc =
          RoleRepository.buildSubscriptionPermissionAdminData(
        companyId: '75440689',
        roleId: '12',
        selectedModules: <String>['roles'],
        validatedPermissions: validated,
        timestamps: <int>[1760000000000],
      );

      expect(doc, <String, dynamic>{
        'companyId': '75440689',
        'roleId': '12',
        'timestamps': <int>[1760000000000],
        'roles': <String, bool>{'Users_Requests': true, 'Add_Role': false},
      });
    });

    test('only SELECTED modules that have validated permissions are written',
        () {
      final Map<String, dynamic> doc =
          RoleRepository.buildSubscriptionPermissionAdminData(
        companyId: 'c',
        roleId: 'r',
        selectedModules: <String>['roles', 'hr'], // hr has no validated map
        validatedPermissions: <String, Map<String, bool>>{
          'roles': <String, bool>{'Users_Requests': true},
          'crm': <String, bool>{'View': true}, // not selected
        },
        timestamps: <int>[1],
      );

      expect(doc.keys.toSet(),
          <String>{'companyId', 'roleId', 'timestamps', 'roles'});
    });

    test('a role with no modules still gets the document (sync no longer '
        'skips it)', () {
      final Map<String, dynamic> doc =
          RoleRepository.buildSubscriptionPermissionAdminData(
        companyId: 'c',
        roleId: 'r',
        selectedModules: const <String>[],
        validatedPermissions: const <String, Map<String, bool>>{},
        timestamps: <int>[1],
      );
      expect(doc, <String, dynamic>{
        'companyId': 'c',
        'roleId': 'r',
        'timestamps': <int>[1],
      });
    });

    test('the edit path passes its own timestamps value through untouched',
        () {
      const Object editTimestamps = 'arrayUnion-sentinel';
      final Map<String, dynamic> doc =
          RoleRepository.buildSubscriptionPermissionAdminData(
        companyId: 'c',
        roleId: 'r',
        selectedModules: const <String>[],
        validatedPermissions: const <String, Map<String, bool>>{},
        timestamps: editTimestamps,
      );
      expect(identical(doc['timestamps'], editTimestamps), isTrue);
    });
  });
}
