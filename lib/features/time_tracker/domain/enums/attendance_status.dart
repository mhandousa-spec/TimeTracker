/// Module: time_tracker / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_status.dart
/// Purpose: Declares `AttendanceStatus` (the status of one attendance day)
///          and `WorkLocationType` (where one check-in session happened).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// FINAL SPEC §2 `Attendance`: `Attendance_Status` is one of present / late /
/// absent / vacation / sick_leave / excused; `Work_Location_Type` (inside each
/// session) is office / remote / client_site.
///
/// ⚠️ [storageKey] is what Firestore stores. Renaming a constant is free;
/// renaming its storage key orphans every document already written with it.

enum AttendanceStatus {
  present('present'),
  late('late'),
  absent('absent'),
  vacation('vacation'),
  sickLeave('sick_leave'),
  excused('excused');

  const AttendanceStatus(this.storageKey);

  /// Value written to `Attendance_Status`.
  final String storageKey;

  /// True for the statuses an approved leave request writes (the day is
  /// explained, so it is never counted as absent or late).
  bool get isLeave =>
      this == AttendanceStatus.vacation ||
      this == AttendanceStatus.sickLeave ||
      this == AttendanceStatus.excused;

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown or missing reads as null (the day
  /// has no decided status yet).
  ///
  /// Parameters:
  ///   [String?] key: the raw Firestore value.
  ///
  /// Return type: [AttendanceStatus?]
  static AttendanceStatus? fromStorageKey(String? key) {
    for (final AttendanceStatus value in AttendanceStatus.values) {
      if (value.storageKey == key) return value;
    }
    return null;
  }
}

enum WorkLocationType {
  office('office'),
  remote('remote'),
  clientSite('client_site');

  const WorkLocationType(this.storageKey);

  /// Value written to `Work_Location_Type`.
  final String storageKey;

  /// Remote and client-site sessions happen away from a company location,
  /// so no geofence applies to them (owner decision 5, 8/10/2026).
  bool get isAwayFromCompanyLocation => this != WorkLocationType.office;

  /// Function Name: [fromStorageKey]
  ///
  /// Purpose: Parse a stored value; unknown or missing reads as [office].
  ///
  /// Parameters:
  ///   [String?] key: the raw Firestore value.
  ///
  /// Return type: [WorkLocationType]
  static WorkLocationType fromStorageKey(String? key) {
    for (final WorkLocationType value in WorkLocationType.values) {
      if (value.storageKey == key) return value;
    }
    return WorkLocationType.office;
  }
}
