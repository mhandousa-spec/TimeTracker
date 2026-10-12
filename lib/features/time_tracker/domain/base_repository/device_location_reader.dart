/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: device_location_reader.dart
/// Purpose: Declares `DeviceLocationReader` (the device's current position
///          for the check-in geofence), `DeviceLocationResult` and
///          `DeviceLocationIssue`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// A check-in at an office whose geofence is ON needs the device position
/// (owner decision 5 + Figma 661:17251 "Wrong Location"). Reading it can
/// fail in ways the employee must understand (permission denied, location
/// services off), so the reader never throws: it returns a result that is
/// either a position or a precise issue the UI turns into a clear message.
/// The implementation is `GeolocatorLocationRepository`.
/// Updated: 9/10/2026 - code review: [DeviceLocationIssue.mocked] (a fake
/// "mock location" position is refused) and [maxAccuracyMeters] (a reading
/// vaguer than that is "unavailable", not a pass / fail of the geofence).

import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';

/// Why no position could be read.
enum DeviceLocationIssue {
  /// Location services are switched off on the device.
  serviceDisabled,

  /// The user refused the permission (it can be asked again).
  denied,

  /// The permission is refused for good — only the device Settings help.
  deniedForever,

  /// Permission granted, but no position came back (timeout, no fix) — or
  /// (9/10/2026) one too imprecise to judge the geofence.
  unavailable,

  /// ADDED 9/10/2026 (code review): the position comes from a mock-location
  /// app / developer setting — never accepted for a check-in.
  mocked,
}

/// A reading whose accuracy radius is wider than this (metres) cannot say
/// whether the employee is inside a geofence (code review, 9/10/2026).
const double maxAccuracyMeters = 100;

class DeviceLocationResult {
  const DeviceLocationResult.found(GeoPoint this.position) : issue = null;

  const DeviceLocationResult.failed(DeviceLocationIssue this.issue)
      : position = null;

  final GeoPoint? position;
  final DeviceLocationIssue? issue;

  bool get hasPosition => position != null;
}

abstract class DeviceLocationReader {
  /// Function Name: [currentPosition]
  ///
  /// Purpose: Ask for permission when needed, then read the position.
  ///
  /// Return type: [Future<DeviceLocationResult>] — never throws.
  Future<DeviceLocationResult> currentPosition();
}
