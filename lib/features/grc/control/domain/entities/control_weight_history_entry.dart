/// Module: Policy Management
/// Description: One recorded change to a Control's weight — reconstructed
///              from ControlModel's revision history, never persisted on
///              its own.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: None
/// Revision History: 2026-07-20 - Initial creation
library;

/// class name: [ControlWeightHistoryEntry]
///
/// purpose: represents one revision where a Control's weight changed from
///          [weightPrevious] to [weightCurrent], saved by [changedByEmail]
///          on [dateOfAction]. Only ever produced for revisions where the
///          weight actually changed — see [ControlModel.toWeightHistory].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightHistoryEntry {
  final String controlId;
  final String policyId;
  final String controlsNameEn;
  final String controlsNameAr;
  final double weightPrevious;
  final double weightCurrent;
  final String changedByEmail;
  final DateTime dateOfAction;

  const ControlWeightHistoryEntry({
    required this.controlId,
    required this.policyId,
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.weightPrevious,
    required this.weightCurrent,
    required this.changedByEmail,
    required this.dateOfAction,
  });
}
