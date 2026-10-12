/// Module: Control Owner Management
/// Description: One completed Control Owner assignment stint on a single
///              {Policy, Control} pair — who held the role, who assigned
///              them, and the date range they held it. Reconstructed from
///              OwnerModel's revision history; never persisted on its own.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: None
/// Revision History: 2026-07-21 - Initial creation
library;

/// class name: [ControlOwnerHistoryEntry]
///
/// purpose: represents a single completed stint of one person being the
///          Owner of a specific Control: they were assigned on [startDate]
///          (by [assignedByEmail]) and stopped being the Owner of that
///          Control on [endDate]. Only ever produced for assignments that
///          have since ended — a currently-active assignment has no
///          [ControlOwnerHistoryEntry].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlOwnerHistoryEntry {
  final String ownerEmail;
  final String assignedByEmail;
  final DateTime startDate;
  final DateTime endDate;

  const ControlOwnerHistoryEntry({
    required this.ownerEmail,
    required this.assignedByEmail,
    required this.startDate,
    required this.endDate,
  });
}
