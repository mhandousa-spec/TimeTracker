/// Module: core/services
///
///*************************** FILE INFO ****************************///
/// File Name: secure_credential_store.dart
/// Purpose: Encrypted storage for the credentials the biometric login needs.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// SECURITY
/// --------
/// `login_controller` used to call `storage.write('password', password)` on
/// GetStorage, which is a plaintext JSON file in the app's documents
/// directory — readable from a device backup or any rooted/jailbroken device.
///
/// This wrapper stores the password in the iOS Keychain / Android
/// EncryptedSharedPreferences instead, and migrates any value left behind by
/// the old code on first read so existing users do not lose biometric login.

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

class SecureCredentialStore {
  SecureCredentialStore({FlutterSecureStorage? storage, GetStorage? legacy})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
              // ADDED 27/9/2026 — macOS uses the file-based login keychain
              // instead of the data-protection keychain (the plugin default).
              // The data-protection keychain needs the keychain-access-groups
              // entitlement, which an ad-hoc-signed debug build cannot carry
              // (see DebugProfile.entitlements), so every write/read failed,
              // no password was ever saved, and fingerprint login had nothing
              // to unlock. The login keychain needs no entitlement.
              mOptions: MacOsOptions(usesDataProtectionKeychain: false),
            ),
        _legacy = legacy ?? GetStorage();

  final FlutterSecureStorage _storage;
  final GetStorage _legacy;

  static const String _passwordKey = 'password';

  /// Whether this build has already reported that secure storage is
  /// unavailable, so the notice is logged once instead of on every call.
  static bool _unavailableReported = false;

  /// Function Name: [_reportUnavailable]
  ///
  /// Purpose: Log a one-line notice when the platform keychain refuses us.
  ///
  /// The common case is macOS: the Runner signs ad-hoc
  /// (`CODE_SIGN_IDENTITY = "-"`, no DEVELOPMENT_TEAM), so
  /// `$(AppIdentifierPrefix)` in `keychain-access-groups` resolves to nothing
  /// and every call fails with errSecMissingEntitlement (-34018). That is a
  /// desktop signing limitation, not a bug in this class — iOS and Android are
  /// unaffected. Biometric login degrades to normal sign-in, so this is a
  /// notice rather than a stack trace.
  ///
  /// Parameters:
  /// - [operation]: The call that was refused, for the log line.
  /// - [error]: The platform error.
  ///
  /// Returns: [void]
  static void _reportUnavailable(String operation, Object error) {
    if (_unavailableReported) return;
    _unavailableReported = true;
    debugPrint(
      'SecureCredentialStore: platform secure storage unavailable '
      '($operation: $error). Falling back to normal sign-in; stored '
      'credentials are not used on this platform/build.',
    );
  }

  /// Function Name: [writePassword]
  ///
  /// Purpose: Persist the password to encrypted storage.
  ///
  /// Parameters:
  /// - [password]: The plaintext password to store.
  ///
  /// Returns: [Future<bool>] `true` when the value reached secure storage.
  ///
  /// The platform keychain can refuse the write — on macOS a missing
  /// `keychain-access-groups` entitlement fails every call with
  /// errSecMissingEntitlement (-34018). That used to escape as an uncaught
  /// async error and take down the biometric-login flow, so it is reported
  /// rather than thrown; the caller falls back to normal sign-in.
  Future<bool> writePassword(String password) async {
    try {
      await _storage.write(key: _passwordKey, value: password);
    } catch (e) {
      _reportUnavailable('write', e);
      return false;
    }
    debugPrint('[bio] SecureCredentialStore: password saved to secure storage');
    // Clear any copy the previous plaintext implementation left on disk.
    await _legacy.remove(_passwordKey);
    return true;
  }

  /// Function Name: [readPassword]
  ///
  /// Purpose: Read the stored password, migrating the legacy plaintext value
  ///          if this is the first run after the change.
  ///
  /// Returns: [Future<String?>] the password, or `null` if none is stored or
  /// secure storage is unavailable on this platform/build.
  Future<String?> readPassword() async {
    try {
      final String? secure = await _storage.read(key: _passwordKey);
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (e) {
      _reportUnavailable('read', e);
      return null;
    }

    final dynamic legacyValue = _legacy.read(_passwordKey);
    if (legacyValue is String && legacyValue.isNotEmpty) {
      // Only drop the plaintext copy once the secure write actually succeeded,
      // otherwise a keychain failure would delete the user's only credential.
      if (!_unavailableReported) await writePassword(legacyValue);
      return legacyValue;
    }
    return null;
  }

  /// Function Name: [clear]
  ///
  /// Purpose: Remove the stored credential, e.g. on sign-out.
  Future<void> clear() async {
    try {
      await _storage.delete(key: _passwordKey);
    } catch (e) {
      _reportUnavailable('delete', e);
    }
    await _legacy.remove(_passwordKey);
  }
}

/// Shared instance. The login controller is a GetX singleton, so a plain
/// top-level instance matches how the rest of that file resolves services.
final SecureCredentialStore secureCredentialStore = SecureCredentialStore();
