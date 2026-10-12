/// Module: test / roles / r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: roles_permission_collection_test.dart
/// Purpose: The Roles module's switches live in `roles_module_permissions`
///          (house pattern `<module>_module_permissions`, the collection
///          Knowticed Admin creates) — no client code reads or writes the
///          retired `roles_permissions` any more (9/10/2026).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/services/permission_sync_service.dart';

void main() {
  test('RoleRepository maps roles → roles_module_permissions', () {
    expect(RoleRepository.ROLES_PERMISSIONS, 'roles_module_permissions');
    expect(RoleRepository.permissionCollectionFor('roles'),
        'roles_module_permissions');
    expect(RoleRepository.permissionCollectionFor(' Roles '),
        'roles_module_permissions');
  });

  test('PermissionSyncService syncs roles into roles_module_permissions', () {
    expect(PermissionSyncService.moduleCollectionFor('roles'),
        'roles_module_permissions');
    expect(PermissionSyncService.moduleCollectionFor('ROLES'),
        'roles_module_permissions');
  });

  test('every mapped module follows <module>_module_permissions', () {
    const List<String> modules = <String>[
      'services', 'services_app', 'messages', 'inventory', 'settings',
      'qiyas', 'grc', 'knowledge_hub', 'roles', 'hr', 'crm', 'notification',
      'todo', 'time_tracker',
    ];
    for (final String module in modules) {
      expect(RoleRepository.permissionCollectionFor(module),
          '${module}_module_permissions',
          reason: module);
    }
    // Aliases resolve to the canonical collection.
    expect(RoleRepository.permissionCollectionFor('form_builder'),
        'services_app_module_permissions');
    expect(RoleRepository.permissionCollectionFor('tracking'),
        'time_tracker_module_permissions');
    expect(RoleRepository.permissionCollectionFor('unknown'), '');
  });

  test('no Dart source under lib/ still names the roles_permissions '
      'collection', () {
    final RegExp retired = RegExp('''['"]roles_permissions['"]''');
    final List<String> offenders = <String>[];

    for (final FileSystemEntity entity
        in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (retired.hasMatch(entity.readAsStringSync())) {
        offenders.add(entity.path);
      }
    }

    expect(offenders, isEmpty);
  });
}
