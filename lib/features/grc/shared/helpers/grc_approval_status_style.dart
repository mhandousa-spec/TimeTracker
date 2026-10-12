// lib/features/grc/shared/helpers/grc_approval_status_style.dart
/// Module: GRC / shared
///
///*************************** FILE INFO ****************************///
/// File Name: grc_approval_status_style.dart
/// Purpose: Presentation-layer colour mapping for the onboarding
///          [ApprovalStatus] enum used by the GRC Requests screens.
///
/// Why this exists: CR-SKEL-O3-N31 deleted the `color` getter from
/// `features/onboarding/o3_authentication/domain/enums/approval_status.dart`
/// on the basis that it had no callers and that a domain enum should not
/// return `package:flutter` colours (§3, §12). The GRC Requests list and
/// details pages *were* callers, so the mapping is restored here instead —
/// in the presentation layer, where it belongs, and using theme-aware
/// [AppColors] so it follows light/dark mode.
///
/// The palette matches the sibling GRC status styles
/// (`AssignmentControlTabStyle`, `MyAuditTabStyle`, `ApprovalStatusStyle`)
/// so a Pending/Approved/Rejected pill reads the same on every GRC screen.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';

extension GrcApprovalStatusColor on ApprovalStatus {
  /// Colour used for this status's pill border, chip label and banner.
  Color get color {
    switch (this) {
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return Colors.red;
      case ApprovalStatus.pending:
        return AppColors.warning;
      case ApprovalStatus.canceled:
        return AppColors.grey;
      case ApprovalStatus.all:
        return AppColors.grey;
    }
  }
}
