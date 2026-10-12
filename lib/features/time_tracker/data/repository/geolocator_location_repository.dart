/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: geolocator_location_repository.dart
/// Purpose: Declares `GeolocatorLocationRepository` — `DeviceLocationReader`
///          backed by the `geolocator` plugin (already in pubspec).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Unlike core `GelocatorRepository` (which collapses every failure into
/// null), this reports WHY there is no position, so the check-in screen can
/// say "turn location on" vs "allow location in Settings" (owner brief:
/// handle permission denied gracefully with a clear message). iOS uses the
/// existing `NSLocationWhenInUseUsageDescription` (ios/Runner/Info.plist).
/// A plugin exception is caught here (repository layer) and reported as
/// `unavailable` — the check-in is then blocked by `CheckInGate`
/// (`positionRequired`), never silently allowed.
/// Updated: 9/10/2026 - code review: `Position.isMocked` → refused
/// ([DeviceLocationIssue.mocked]); accuracy worse than `maxAccuracyMeters`
/// → unavailable.
/// Updated: 9/10/2026 - QA (geofence testing on the simulator): the iOS
/// Simulator reports EVERY position as mocked, so right / wrong location
/// could not be tested. In a DEBUG build only ([kDebugMode]; never in
/// profile / release) a mocked position is treated as real — logged once —
/// so QA can test the geofence with the simulator's location. Release
/// behaviour is unchanged: the decision is the pure [judge], and the flag
/// is injectable so a test proves a release build still refuses it.

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';

class GeolocatorLocationRepository implements DeviceLocationReader {
  const GeolocatorLocationRepository({this.allowMockedPositions = kDebugMode});

  /// How long to wait for a fix before giving up.
  static const Duration timeLimit = Duration(seconds: 15);

  /// DEBUG-ONLY simulator allowance (default [kDebugMode]: false in every
  /// profile / release build). Tests inject `false` to check the release
  /// rule.
  final bool allowMockedPositions;

  /// The one-time debug log was written.
  static bool _mockNoticeLogged = false;

  /// Function Name: [judge]
  ///
  /// Purpose: Whether a reading can be used for a geofence: a mocked one is
  /// refused unless [allowMocked] (debug builds only); one vaguer than
  /// [maxAccuracyMeters] is "unavailable".
  ///
  /// Parameters:
  ///   [bool] isMocked / [double] accuracy: from the reading.
  ///   [bool] allowMocked: the debug allowance.
  ///
  /// Return type: [DeviceLocationIssue?] — null = usable.
  static DeviceLocationIssue? judge({
    required bool isMocked,
    required double accuracy,
    required bool allowMocked,
  }) {
    if (isMocked && !allowMocked) return DeviceLocationIssue.mocked;
    if (accuracy > maxAccuracyMeters) return DeviceLocationIssue.unavailable;
    return null;
  }

  @override
  Future<DeviceLocationResult> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const DeviceLocationResult.failed(
          DeviceLocationIssue.serviceDisabled,
        );
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const DeviceLocationResult.failed(
          DeviceLocationIssue.deniedForever,
        );
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const DeviceLocationResult.failed(DeviceLocationIssue.denied);
      }
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );
      // 9/10/2026 (code review): a mock-location position is refused, and
      // one too vague for a geofence counts as "no position" — except the
      // DEBUG-ONLY simulator allowance (QA, 9/10/2026).
      final DeviceLocationIssue? issue = judge(
        isMocked: position.isMocked,
        accuracy: position.accuracy,
        allowMocked: allowMockedPositions,
      );
      if (issue != null) return DeviceLocationResult.failed(issue);
      if (position.isMocked && !_mockNoticeLogged) {
        _mockNoticeLogged = true;
        debugPrint(
          '[time_tracker] DEBUG build: a mocked (simulator) position is '
          'accepted for check-in / geofence testing. Profile and release '
          'builds refuse mocked positions.',
        );
      }
      return DeviceLocationResult.found(
        GeoPoint(position.latitude, position.longitude),
      );
    } catch (error) {
      // Plugin / timeout failure → "could not read your location".
      return DeviceLocationResult.failed(
        error is PermissionDeniedException
            ? DeviceLocationIssue.denied
            : DeviceLocationIssue.unavailable,
      );
    }
  }
}
