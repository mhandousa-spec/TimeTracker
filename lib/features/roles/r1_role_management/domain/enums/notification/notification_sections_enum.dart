/// Module: roles / r1_role_management / domain / enums / notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_sections_enum.dart
/// Purpose: Declares `NotificationPermissionsSections` — the single switch
///          group the Notification Control block is built from.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// Figma: MESBAH → ROLE MANAGEMENT → Adding New Role → Permissions Control →
/// Notification Control. One headed card, a master toggle, five switches.
///
/// ─── WHY A SECTION ENUM FOR A SINGLE SECTION ─────────────────────────
/// The master toggle is the whole reason this file exists. The block is not a
/// bare list of five switches — it has a "Notification Control" switch ABOVE
/// them that turns the group off wholesale. That is only expressible if the
/// section implements BOTH [ModulePermissionsSections] (so it can own a list
/// of permissions) and [ModulePermissionsSectionsPermission] (so it can be
/// asked about ITSELF with `permission: null`). `MessagesPermissionsSections`
/// and `KnowledgeHubPermissionsSections` use the same double-implement.
///
/// So: a one-value enum here is not overhead, and flattening it into
/// `NotificationPermissions` would cost the master toggle.
///
/// ─── ONE COLUMN, NOT TWO ─────────────────────────────────────────────
/// [firstColumnValues] carries the only section; [lastColumnValues] is
/// deliberately empty because the design leaves the right-hand column of this
/// row blank. It is NOT an oversight — returning an empty list is what makes
/// `Modules.moduleLastColumnPermissions` draw nothing there. If a second
/// group is ever designed, add it to [lastColumnValues] rather than widening
/// the first column.
///
/// ⚠️ [getDataBaseName] is stored in Firestore. Renaming it orphans every role
/// document already written with it.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'notification_permissions_enum.dart';

enum NotificationPermissionsSections
    implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  notificationControl;

  @override
  String get getName {
    switch (this) {
      case NotificationPermissionsSections.notificationControl:
        return S.current.notificationControl;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case NotificationPermissionsSections.notificationControl:
        return 'Notification_Control';
    }
  }

  @override
  String get getUiName => getName;

  @override
  bool get isChild {
    return false;
  }

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case NotificationPermissionsSections.notificationControl:
        return NotificationPermissions.values;
    }
  }

  /// Left column in the design — the only column this block has.
  static List<Enum> get firstColumnValues {
    return <Enum>[
      NotificationPermissionsSections.notificationControl,
    ];
  }

  /// Right column in the design. Empty on purpose — see the header.
  static List<Enum> get lastColumnValues {
    return <Enum>[];
  }
}
