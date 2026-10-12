/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: geolocator_repository.dart
/// Purpose: Declares `GelocatorRepository`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/9/2026  - Location is now BEST-EFFORT: every failure path returns
///                      null instead of throwing. See the note on
///                      [getCurrentLocation].

/// **************************** FILE INFO ******************** ///
/// FILE NAME: gelocator_repository.dart
/// Purpose: provide location services to the app.
/// Author: Amr Mesbah
/// Created at: 2/2/2025

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

abstract class GelocatorRepository {
  /// Method Name: [getCurrentLocation]
  ///
  /// Description: this method will return the current location of the user.
  ///
  /// BEST-EFFORT BY CONTRACT (9/9/2026). Every caller already treats a null
  /// position as "log it without coordinates" — `addActivityLog` writes
  /// `currentPosition?.latitude.toString() ?? ''` — so a location this device
  /// will not give up is a normal outcome, not an error, and this method now
  /// returns null for ALL of them rather than only for the three it used to
  /// check.
  ///
  /// WHAT WENT WRONG. Missing Info.plist keys make
  /// `Geolocator.requestPermission` throw
  /// `PermissionDefinitionsNotFoundException`, which this method let escape.
  /// Its only caller, `SystemLogsController.systemLogsAction`, is a
  /// fire-and-forget `void ... async` — nobody awaits it and nobody can catch
  /// it — so the throw surfaced as an uncaught async error in
  /// `runZonedGuarded` AND skipped `addActivityLog` entirely, silently losing
  /// the activity log it was called to write.
  ///
  /// The plist keys and the macOS location entitlement are now declared, so
  /// that particular exception should not recur. This catch is the belt to
  /// that braces: the same shape of failure is reachable from a revoked
  /// permission, a device with the location service switched off mid-call, a
  /// platform channel that is not available (Windows/Linux/web), or a
  /// `getCurrentPosition` that times out. None of those should be able to take
  /// down an activity log or an unrelated caller.
  ///
  /// Return Value: [Future<Position?>] the current location, or null when the
  /// device cannot or will not provide one.
  static Future<Position?> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e, stackTrace) {
      // debugPrint, not rethrow: see the contract above. The message names the
      // repository so a missing platform permission is still findable in the
      // console rather than disappearing.
      debugPrint('GelocatorRepository.getCurrentLocation failed: $e\n$stackTrace');
      return null;
    }
  }
}
