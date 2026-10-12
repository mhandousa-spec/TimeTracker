/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: functions.dart
/// Purpose: Helper / stub retained for module boundaries.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'dart:io';

/// Returns whether the device can actually reach the internet.
///
/// Deliberately typed `Future<bool>` with an explicit return on every path.
/// The previous version was untyped and had no return after the try/catch, so
/// a lookup that succeeded but returned an empty address fell through and
/// produced `null`. Callers do `if (await checkInternet())`, which then threw
/// `type 'Null' is not a subtype of type 'bool'` at runtime — the sign-in
/// button appeared to do nothing because the exception fired before login ran.
///
/// It also only caught [SocketException]; a DNS timeout or handshake failure
/// escaped instead of reporting "offline". Everything is caught now, and the
/// lookup is bounded by [timeout] so a black-holed network can't hang sign-in.
Future<bool> checkInternet({
  Duration timeout = const Duration(seconds: 5),
}) async {
  try {
    final List<InternetAddress> result =
        await InternetAddress.lookup('google.com').timeout(timeout);
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    // SocketException, TimeoutException, or anything else -> treat as offline.
    return false;
  }
}
