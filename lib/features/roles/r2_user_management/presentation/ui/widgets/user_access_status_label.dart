/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_status_label.dart
/// Purpose: Declares `UserAccessStatusLabel`.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Both the status filter chips on the user-management home and the "Status:"
/// line on every user card rendered `FormatHelper.capitalize(status.name)` —
/// the raw Dart enum identifier. An Arabic user read "Active", "Scheduled" and
/// "ExpiringSoon" in English in the middle of an otherwise fully translated
/// screen, and `expiringSoon` did not even survive `capitalize`, which only
/// touches the first letter and leaves the camelCase hump behind.
///
/// WHY IT IS NOT ON THE ENUM
/// -------------------------
/// [UserAccessStatus] was deliberately moved out of `data/` to be free of
/// `package:flutter/material.dart` — see its FILE INFO. A `getLocalizedName`
/// member would need a `BuildContext` and drag the framework straight back into
/// the domain layer. So the label lives in the presentation layer, exactly like
/// the `UserAccessStatusColor` extension already does.
///
/// Every string below is an existing ARB key with an Arabic translation, so
/// this adds no new l10n entries.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';

/// The display name of a [UserAccessStatus] in the app's current language.
extension UserAccessStatusLabel on UserAccessStatus {
  /// Function Name: [label]
  ///
  /// Purpose: The translated, human-readable name of this status.
  ///
  /// Parameters:
  /// - [context]: Any context under the app's `Localizations`.
  ///
  /// Returns: [String] e.g. "Expiring Soon" / "سينتهي قريبًا". Already cased
  /// for display — do NOT pass it through `FormatHelper.capitalize`.
  String label(BuildContext context) {
    switch (this) {
      case UserAccessStatus.all:
        return S.of(context).all;
      case UserAccessStatus.active:
        return S.of(context).active;
      case UserAccessStatus.scheduled:
        return S.of(context).scheduled;
      case UserAccessStatus.inactive:
        return S.of(context).inactive;
      case UserAccessStatus.expiringSoon:
        return S.of(context).expiringSoon;
      case UserAccessStatus.accessGranted:
        return S.of(context).access_granted;
      case UserAccessStatus.accessRevoked:
        return S.of(context).access_revoked;
    }
  }
}
