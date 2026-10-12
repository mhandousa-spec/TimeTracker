/// Module: Policy Management
/// Description: One recorded change to a Policy's weight — reconstructed
///              from PolicyModel's revision history, never persisted on its
///              own.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: None
/// Revision History: 2026-07-19 - Initial creation
library;

/// class name: [PolicyWeightHistoryEntry]
///
/// purpose: represents one revision where a Policy's weight changed from
///          [weightPrevious] to [weightCurrent], saved by [changedByEmail]
///          on [dateOfAction]. Only ever produced for revisions where the
///          weight actually changed — see [PolicyModel.toWeightHistory].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightHistoryEntry {
  final String policyId;
  final String policyNameEn;
  final String policyNameAr;
  final double weightPrevious;
  final double weightCurrent;
  final String changedByEmail;
  final DateTime dateOfAction;

  const PolicyWeightHistoryEntry({
    required this.policyId,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.weightPrevious,
    required this.weightCurrent,
    required this.changedByEmail,
    required this.dateOfAction,
  });
}
