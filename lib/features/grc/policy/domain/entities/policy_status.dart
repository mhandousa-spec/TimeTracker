/// Module: Policy Management
/// Description: Defines the PolicyStatus enum representing all possible
///              lifecycle states a Policy record can be in.
/// Author: Mohamed Elrashidy
/// Date: 2026-07-06
/// Dependencies: None
/// Revision History: 2026-07-06 - Initial creation
///                   2026-07-14 - Added Scheduled and Removed to match the
///                                new Firestore schema (Mohamed Elrashidy)

/// ************************* FILE INFO *************************** ///
/// File Name: policy_status.dart
/// Purpose: Contains the PolicyStatus enum and its serialization helpers
///          used across the Policy model, entity, and cubit.
/// Author: Mohamed Elrashidy
/// Created At: 6/7/2026

/// class name: [PolicyStatus]
///
/// purpose: represent the lifecycle state of a Policy record.
///          - [draft]      → created but not yet published (Save For Later)
///          - [active]     → published and currently in effect
///          - [inactive]   → manually deactivated
///          - [scheduled]  → published but Start Date is still in the future
///          - [expired]    → past the End Date
///          - [removed]    → soft-deleted (replaces the old Is_Deleted flag)
///
/// authors: Mohamed Elrashidy
///
/// created at: 6/7/2026
enum PolicyStatus {
  draft,
  active,
  inactive,
  scheduled,
  expired,
  removed;

  /// function name: [value]
  ///
  /// purpose: return the exact string stored in Firestore for this status.
  ///
  /// parameters: none
  ///
  /// return type: [String] - the Firestore-ready string representation
  String get value {
    switch (this) {
      case PolicyStatus.draft:
        return 'Draft';
      case PolicyStatus.active:
        return 'Active';
      case PolicyStatus.inactive:
        return 'Inactive';
      case PolicyStatus.scheduled:
        return 'Scheduled';
      case PolicyStatus.expired:
        return 'Expired';
      case PolicyStatus.removed:
        return 'Removed';
    }
  }

  /// function name: [fromString]
  ///
  /// purpose: parse a [PolicyStatus] from a raw Firestore string, defaulting
  ///          to [PolicyStatus.draft] for any unrecognised value.
  ///
  /// parameters:
  ///            [String] value: the raw string read from Firestore
  ///
  /// return type: [PolicyStatus] - the matching enum value, or [PolicyStatus.draft] if unknown
  static PolicyStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return PolicyStatus.active;
      case 'inactive':
        return PolicyStatus.inactive;
      case 'scheduled':
        return PolicyStatus.scheduled;
      case 'expired':
        return PolicyStatus.expired;
      case 'removed':
        return PolicyStatus.removed;
      case 'draft':
      default:
        return PolicyStatus.draft;
    }
  }
}