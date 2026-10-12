/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: audit_info.dart
/// Purpose: Declares `AuditInfo` — who created / last changed a Time Tracker
///          record and when.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Playbook §3b: every document carries `Created_By`, `Creation_Date`,
/// `Modified_By` and `timestamps`. Read-only on the entity — the repository
/// fills the stored values on every write (the creator never changes; the
/// modifier is the signed-in user). [updatedAt] is the last `timestamps` entry.

class AuditInfo {
  const AuditInfo({
    this.createdBy = '',
    this.createdAt,
    this.modifiedBy = '',
    this.updatedAt,
  });

  /// Lower-cased email of whoever created the record ('' before the first save).
  final String createdBy;
  final DateTime? createdAt;

  /// Lower-cased email of whoever wrote the latest history row.
  final String modifiedBy;
  final DateTime? updatedAt;

  /// Nothing stored yet — a draft.
  static const AuditInfo none = AuditInfo();
}
