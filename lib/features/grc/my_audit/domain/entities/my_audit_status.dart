/// Lifecycle status of one My_Audit document (one per control+champion pair
/// — see the design spec's "Building the Owner's list" section). `Overdue`
/// is a list-tab concept, never actually persisted here — see
/// `MyAuditTab`/`computeMyAuditTab` in my_audit_resolver.dart (Task 2).
enum MyAuditStatus {
  pending,
  outstanding,
  scored,
  rejected;

  String get value {
    switch (this) {
      case MyAuditStatus.pending:
        return 'Pending';
      case MyAuditStatus.outstanding:
        return 'Outstanding';
      case MyAuditStatus.scored:
        return 'Scored';
      case MyAuditStatus.rejected:
        return 'Rejected';
    }
  }

  static MyAuditStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'outstanding':
        return MyAuditStatus.outstanding;
      case 'scored':
        return MyAuditStatus.scored;
      case 'rejected':
        return MyAuditStatus.rejected;
      case 'pending':
      default:
        return MyAuditStatus.pending;
    }
  }
}
