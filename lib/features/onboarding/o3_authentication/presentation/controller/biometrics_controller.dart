/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: biometrics_controller.dart
/// Purpose: Wraps the platform biometric prompt.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N04: renamed from the misspelled `biometrics_contoller.dart`.
/// Updated: 27/9/2026 - DIAGNOSTIC: every step logs under `[bio]`. Both
///          functions used to `catch (e) { return false; }` silently, so a
///          platform error (not enrolled, locked out, missing Info.plist key,
///          user cancel, app backgrounded…) looked exactly like "no
///          biometrics" and the reason was lost. Search the console for `[bio]`.

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

void _bioLog(String message) => debugPrint('[bio] $message');

Future<bool> checkBiometrics() async {
  var localAuth = LocalAuthentication();
  try {
    final bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    final bool isDeviceSupported = await localAuth.isDeviceSupported();
    _bioLog('checkBiometrics → canCheckBiometrics=$canCheckBiometrics, '
        'isDeviceSupported=$isDeviceSupported, '
        'platform=${defaultTargetPlatform.name}');
    return canCheckBiometrics;
  } catch (e, stackTrace) {
    _bioLog('checkBiometrics THREW ${e.runtimeType}: $e\n$stackTrace');
    return false;
  }
}

Future<bool> authenticate() async {
  var localAuth = LocalAuthentication();
  final Stopwatch watch = Stopwatch()..start();
  try {
    bool canCheckBiometrics = await checkBiometrics();
    List<BiometricType> availableBiometrics =
        await localAuth.getAvailableBiometrics();
    _bioLog('authenticate → available=$availableBiometrics, '
        'canCheck=$canCheckBiometrics');

    if (availableBiometrics.isEmpty || !canCheckBiometrics) {
      _bioLog('authenticate → NO PROMPT: '
          '${availableBiometrics.isEmpty ? "no biometrics enrolled on the device" : "canCheckBiometrics is false"}'
          ' → returning false');
      return false;
    }

    final bool faceBranch = availableBiometrics.contains(BiometricType.face);
    _bioLog('authenticate → showing prompt '
        '(${faceBranch ? "face, biometricOnly=true" : "fingerprint/other, device PIN allowed"})');

    final bool result = faceBranch
        ? await localAuth.authenticate(
            localizedReason: 'Authenticate to access the app',
            // local_auth 3: stickyAuth -> persistAcrossBackgrounding.
            biometricOnly: true,
            persistAcrossBackgrounding: true,
          )
        : await localAuth.authenticate(
            localizedReason: 'Authenticate to access the app',
            persistAcrossBackgrounding: true,
          );

    _bioLog('authenticate → prompt closed after ${watch.elapsedMilliseconds} ms, '
        'result=$result'
        '${result ? "" : " (user cancelled / failed / system dismissed it)"}');
    return result;
  } catch (e, stackTrace) {
    // In local_auth 3 this is usually a LocalAuthException — its toString()
    // carries the code (e.g. noBiometricsEnrolled, temporaryLockout,
    // biometricLockout, userCanceled, systemCanceled, uiUnavailable).
    _bioLog('authenticate THREW after ${watch.elapsedMilliseconds} ms '
        '${e.runtimeType}: $e\n$stackTrace');
    return false;
  }
}
