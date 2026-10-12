/// Module: GRC Module Management
/// Description: One completed owner-assignment stint for a GRC Module —
///              who held the "owner" role, who assigned them, and the date
///              range they held it. Reconstructed from GRCModuleModel's
///              revision history; never persisted on its own.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: None
/// Revision History: 2026-07-13 - Initial creation
library;

/// class name: [GRCModuleOwnerHistoryEntry]
///
/// purpose: represents a single completed stint of one person being an
///          owner of a GRC Module: they were assigned on [startDate] (by
///          [assignedByEmail]) and stopped being an owner on [endDate].
///          Only ever produced for owners who have since been removed —
///          a currently-active owner has no [GRCModuleOwnerHistoryEntry].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 13/7/2026
class GRCModuleOwnerHistoryEntry {
  final String ownerEmail;
  final String assignedByEmail;
  final DateTime startDate;
  final DateTime endDate;

  const GRCModuleOwnerHistoryEntry({
    required this.ownerEmail,
    required this.assignedByEmail,
    required this.startDate,
    required this.endDate,
  });
}
