/// Module: Policy Management
/// Description: Defines the ControlStatus enum representing all possible
///              lifecycle states a Control record can be in. Separate from
///              [PolicyStatus] because Controls do not have a "Removed"
///              state but instead have "Unassigned".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: None
/// Revision History: 2026-07-14 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_status.dart
/// Purpose: Contains the ControlStatus enum and its serialization helpers
///          used across the Control model and entity.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 14/7/2026

/// class name: [ControlStatus]
///
/// purpose: represent the lifecycle state of a Control record.
///          - [draft]      → created but not yet published
///          - [scheduled]  → published but the Start Date hasn't arrived yet
///          - [active]     → published and currently in effect
///          - [inactive]   → manually deactivated
///          - [expired]    → past the End Date
///          - [unassigned] → not yet assigned to a responsible owner
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 14/7/2026
enum ControlStatus {
  draft,
  scheduled,
  active,
  inactive,
  expired,
  unassigned;

  /// function name: [value]
  ///
  /// purpose: return the exact string stored in Firestore for this status.
  ///
  /// parameters: none
  ///
  /// return type: [String] - the Firestore-ready string representation
  String get value {
    switch (this) {
      case ControlStatus.draft:
        return 'Draft';
      case ControlStatus.scheduled:
        return 'Scheduled';
      case ControlStatus.active:
        return 'Active';
      case ControlStatus.inactive:
        return 'Inactive';
      case ControlStatus.expired:
        return 'Expired';
      case ControlStatus.unassigned:
        return 'Unassigned';
    }
  }

  /// function name: [fromString]
  ///
  /// purpose: parse a [ControlStatus] from a raw Firestore string, defaulting
  ///          to [ControlStatus.unassigned] for any unrecognised value.
  ///
  /// parameters:
  ///            [String] value: the raw string read from Firestore
  ///
  /// return type: [ControlStatus] - the matching enum value, or [ControlStatus.unassigned] if unknown
  static ControlStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return ControlStatus.draft;
      case 'scheduled':
        return ControlStatus.scheduled;
      case 'active':
        return ControlStatus.active;
      case 'inactive':
        return ControlStatus.inactive;
      case 'expired':
        return ControlStatus.expired;
      case 'unassigned':
      default:
        return ControlStatus.unassigned;
    }
  }

  /// function name: [computeDateBased]
  ///
  /// purpose: date-based "would-be" status before any assignee/manual
  ///          override: Scheduled if [effectiveStartDate] hasn't arrived yet
  ///          (strictly after the start of today), otherwise Active.
  ///
  /// parameters:
  ///            [DateTime] effectiveStartDate: the control's effective start date
  ///
  /// return type: [ControlStatus] - scheduled or active
  static ControlStatus computeDateBased(DateTime effectiveStartDate) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return effectiveStartDate.isAfter(startOfToday)
        ? ControlStatus.scheduled
        : ControlStatus.active;
  }

  /// function name: [resolve]
  ///
  /// purpose: applies the manual-Inactive and assignee-based overrides on
  ///          top of [requested]: Draft (Save For Later) always wins as-is.
  ///          Otherwise, if the user flipped the "Status" switch to Inactive
  ///          ([manualInactive]), that wins next. Failing both, any other
  ///          status becomes Unassigned unless at least one Champion or
  ///          Owner is currently assigned ([hasAnyAssignee]), in which case
  ///          [requested] (the date-computed Scheduled/Active) stands.
  ///
  /// parameters:
  ///            [ControlStatus] requested: the status requested before overrides
  ///            [bool] manualInactive: whether the user manually set Inactive
  ///            [bool] hasAnyAssignee: whether at least one Champion/Owner is assigned
  ///
  /// return type: [ControlStatus] - the final resolved status
  static ControlStatus resolve({
    required ControlStatus requested,
    required bool manualInactive,
    required bool hasAnyAssignee,
  }) {
    if (requested == ControlStatus.draft) return requested;
    if (manualInactive) return ControlStatus.inactive;
    return hasAnyAssignee ? requested : ControlStatus.unassigned;
  }
}
