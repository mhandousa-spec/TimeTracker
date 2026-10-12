/// Module: time_tracker / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: approval_step.dart
/// Purpose: Declares `ApprovalStepKind` (who approves a step: the
///          requester's department manager, then HR) and `ApprovalDecision`
///          (what that step decided).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 3 (8/10/2026): the approval cycle is the requester's
/// DEPARTMENT MANAGER first, then HR. FINAL SPEC §2 stores each step inside
/// `Requests.Approval_Steps` as `{Step (manager/hr), Approver_Email, Decision,
/// Decision_Date_Time, Reason}`.
///
/// ⚠️ [storageKey] is what Firestore stores. Never rename a storage key.

enum ApprovalStepKind {
  manager('manager'),
  hr('hr');

  const ApprovalStepKind(this.storageKey);

  /// Value written to `Step` / `Current_Step`.
  final String storageKey;

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown or missing reads as null.
  ///
  /// Parameters:
  ///   [String?] key: the raw Firestore value.
  ///
  /// Return type: [ApprovalStepKind?]
  static ApprovalStepKind? fromStorageKey(String? key) {
    for (final ApprovalStepKind value in ApprovalStepKind.values) {
      if (value.storageKey == key) return value;
    }
    return null;
  }
}

/// Updated: 9/10/2026 - code review findings 5 + 7: [ApprovalDecision.skipped]
/// — a step CLOSED without a decision of its own (the rest of a rejected
/// round; a manager step an HR approver passed because the manager cannot
/// act; an HR step closed because the manager was the only HR approver).
/// It never waits and is never shown in the approval cycle.
enum ApprovalDecision {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  skipped('skipped');

  const ApprovalDecision(this.storageKey);

  /// Value written to `Decision`.
  final String storageKey;

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown or missing reads as [pending].
  ///
  /// Parameters:
  ///   [String?] key: the raw Firestore value.
  ///
  /// Return type: [ApprovalDecision]
  static ApprovalDecision fromStorageKey(String? key) {
    for (final ApprovalDecision value in ApprovalDecision.values) {
      if (value.storageKey == key) return value;
    }
    return ApprovalDecision.pending;
  }
}
