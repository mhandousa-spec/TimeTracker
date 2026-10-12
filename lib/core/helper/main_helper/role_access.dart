/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: role_access.dart
/// Purpose: Declares `RoleAccess`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

/// Shared UI state formerly held by `Mode` in mode_changer.dart.
abstract class RoleAccess {
  /// Controller for the persistent bottom nav bar.
  static PersistentTabController controller =
      PersistentTabController(initialIndex: 0);

  /// Current step in the multi-page "add new employee" flow.
  static int addNewEmployeeIndex = 0;
}
