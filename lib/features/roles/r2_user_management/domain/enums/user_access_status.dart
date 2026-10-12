/// Module: roles / r2_user_management / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_status.dart
/// Purpose: Declares `UserAccessStatus`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Moved here from `data/user_mangment_status.dart`.
///          It is domain vocabulary, and living in `data/` it dragged
///          `package:flutter/material.dart` and `dart:ui` into the data layer
///          to satisfy a `getColor(BuildContext)` member. The enum is now pure
///          data with no framework dependency; the colour mapping lives with
///          its only caller, in the presentation layer.

/// Lifecycle of a user's access grant.
///
/// Originally moved from `features/roles/r3_user_access/data/user_access_status.dart`.
enum UserAccessStatus {
  all,
  active,

  /// Access granted, but the start date is still in the future.
  scheduled,
  inactive,
  expiringSoon,

  /// GROUPING filter (29/8/2026): everyone who currently holds access —
  /// active, scheduled or expiring soon. A view over the other states, never
  /// assigned to a user directly.
  accessGranted,

  /// GROUPING filter (29/8/2026): everyone whose access has ended (inactive).
  /// A view over the other states, never assigned to a user directly.
  accessRevoked,
}
