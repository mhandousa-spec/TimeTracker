/// Module: time_tracker / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: setup_status.dart
/// Purpose: Declares the status enums of the set-up records —
///          `RequestTypeStatus`, `LocationStatus` — and `WorkSetupOwner`
///          (which module owns locations / shift hours / assignments).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// FINAL SPEC §2: `Request_Type_Status` active / inactive / removed;
/// `Location_Status` active / inactive. `deleted` is added to
/// `LocationStatus` because the spec has a Delete_Location switch but no
/// deletion field, and the house rule is soft delete (history kept) —
/// see STATUS.md, assumption A4.
///
/// ⚠️ [storageKey] is what Firestore stores. Never rename a storage key.

enum RequestTypeStatus {
  active('active'),
  inactive('inactive'),
  removed('removed');

  const RequestTypeStatus(this.storageKey);

  /// Value written to `Request_Type_Status`.
  final String storageKey;

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown or missing reads as [inactive]
  /// (fail-closed: an unreadable type is never offered to employees).
  ///
  /// Parameters:
  ///   [String?] key: the raw Firestore value.
  ///
  /// Return type: [RequestTypeStatus]
  static RequestTypeStatus fromStorageKey(String? key) {
    for (final RequestTypeStatus value in RequestTypeStatus.values) {
      if (value.storageKey == key) return value;
    }
    return RequestTypeStatus.inactive;
  }
}

enum LocationStatus {
  active('active'),
  inactive('inactive'),
  deleted('deleted');

  const LocationStatus(this.storageKey);

  /// Value written to `Location_Status`.
  final String storageKey;

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown or missing reads as [inactive]
  /// (fail-closed: nobody can check in at an unreadable location).
  ///
  /// Parameters:
  ///   [String?] key: the raw Firestore value.
  ///
  /// Return type: [LocationStatus]
  static LocationStatus fromStorageKey(String? key) {
    for (final LocationStatus value in LocationStatus.values) {
      if (value.storageKey == key) return value;
    }
    return LocationStatus.inactive;
  }
}

/// Who owns locations, shift hours and employee assignments (owner decisions
/// 7, 12–14, 8/10/2026): the HR module when the company has HR, otherwise
/// Time Tracker itself.
enum WorkSetupOwner { timeTracker, hr }
