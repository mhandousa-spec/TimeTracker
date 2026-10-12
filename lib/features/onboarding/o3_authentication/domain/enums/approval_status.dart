/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: approval_status.dart
/// Purpose: The states a demo-company access request can be in.
/// Author: Mohamed Ashraf
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N31: `package:flutter/material.dart` and the
///          `color` getter — which returned raw `Colors.green` / `Colors.red`
///          from a domain enum (§3, §12) — are deleted. The getter had **no
///          callers**; nothing in `lib/` read `ApprovalStatus.color`.

enum ApprovalStatus {
  all,
  approved,
  pending,
  rejected,
  canceled,
}

extension GetApprovalStatusName on ApprovalStatus {
  String get getName {
    switch (this) {
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.rejected:
        return 'Rejected';
      case ApprovalStatus.canceled:
        return 'Canceled';
      case ApprovalStatus.all:
        return 'All';
    }
  }

  String get getOrderName {
    switch (this) {
      case ApprovalStatus.approved:
        return 'Approve';
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.rejected:
        return 'Reject';
      case ApprovalStatus.canceled:
        return 'Cancel';
      case ApprovalStatus.all:
        return 'All';
    }
  }
}
