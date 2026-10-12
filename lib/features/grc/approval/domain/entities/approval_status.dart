// lib/features/grc/approval/domain/entities/approval_status.dart
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

/// Lifecycle status of one Approval document (one per control+champion
/// pair — see the design spec's "Approval doc lifecycle" section).
enum ApprovalStatus {
  pending,
  approved,
  rejected;

  String get value {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  static ApprovalStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }
}

/// Visual identity (color + icon) for one [ApprovalStatus], shared by the
/// status pill on `ApprovalCard` and the tab bar on `ApprovalsListPage` —
/// same convention as `AssignmentControlTabStyle`/`MyAuditTabStyle`, which
/// keep the styling out of the enum itself so the domain layer stays free
/// of `package:flutter` colour decisions at the value level.
class ApprovalStatusStyle {
  final Color color;
  final IconData icon;

  const ApprovalStatusStyle({required this.color, required this.icon});

  static ApprovalStatusStyle of(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return ApprovalStatusStyle(
            color: AppColors.warning, icon: Icons.schedule);
      case ApprovalStatus.approved:
        return const ApprovalStatusStyle(
            color: Colors.green, icon: Icons.check_circle);
      case ApprovalStatus.rejected:
        return const ApprovalStatusStyle(
            color: Colors.red, icon: Icons.block);
    }
  }
}
