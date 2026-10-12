/// Module: roles / r1_role_management / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: role_status.dart
/// Purpose: Declares `RoleStatus`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum RoleStatus {
  all,
  active,
  inactive,
  draft,
  deleted;

  static List<RoleStatus> get filterStatus => [
    all,
    active,
    inactive,
    draft,
  ];

  Color get color {
    switch (this) {
      case RoleStatus.all:
        return AppColors.text;
      case RoleStatus.active:
        return AppColors.green;
      case RoleStatus.inactive:
        return AppColors.red;
      case RoleStatus.draft:
        return AppColors.secondaryText;
      case RoleStatus.deleted:
        return AppColors.greyDark;
    }
  }

  /// Localized display name, resolved from the app's ARB strings.
  String getLocalizedName(BuildContext context) {
    switch (this) {
      case RoleStatus.all:
        return S.of(context).all;
      case RoleStatus.active:
        return S.of(context).active;
      case RoleStatus.inactive:
        return S.of(context).inactive;
      case RoleStatus.draft:
        return S.of(context).draft;
      case RoleStatus.deleted:
        return S.of(context).deleted;
    }
  }

  /// Alias kept so call sites can read `status.localizedName(context)`.
  String localizedName(BuildContext context) => getLocalizedName(context);
}