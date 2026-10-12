/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: debug_test_employee_switch.dart
/// Purpose: DEBUG-ONLY "Switch to test employee" sign-in — the build guard,
///          the test-domain allow-list, the eligibility rule and the
///          in-memory session flag that drives the header badge.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 - DEBUG-ONLY (owner-approved option B): lets QA walk
///            the Time Tracker approval cycle as the `@dm003.test` accounts
///            without anyone typing (or reading) a password.
///
/// HOW IT IS KEPT OUT OF CLIENT BUILDS (9/10/2026 DEBUG-ONLY)
/// ----------------------------------------------------------
/// 1. Every entry point (Sign In screen button, header avatar menu, mobile
///    More page item, header badge) is built behind
///    `if (kDebugTestEmployeeSwitchBuild)` — a compile-time constant made of
///    `kDebugMode && !kReleaseMode && !kProfileMode`. In a release or profile
///    build the branch is constant-false, so the widgets, the picker screen and
///    everything only they call are tree-shaken out of the binary.
/// 2. Every code path (LoginController / DemoLoginRepository /
///    DemoRemoteDataSource debug methods, [DebugTestEmployeeSession.start])
///    re-checks [isDebugTestEmployeeSwitchEnabled] at run time and refuses
///    when it is false — a second lock in case a call site is ever added
///    without the constant.
///
/// WHO CAN BE CHOSEN (9/10/2026 DEBUG-ONLY)
/// ----------------------------------------
/// Only employees of the chosen company whose email ends with one of
/// [kDebugTestEmailDomains]; never the company admin (the demo-request contact
/// email), whatever its domain. Everything else — demo approved and in date,
/// the seat limit, the employee status and the `Users_Access` date window — is
/// checked by the SAME repository code a normal sign-in runs; only the
/// password comparison and the lockout counter are skipped.
/// CHANGED 9/10/2026 (DEBUG-ONLY, coordinator follow-up): a test account with
/// `Is_Activated == false` (every Active Directory upload) is signed in as if
/// activated, without writing the flag; the picker shows it as a grey note.

import 'package:flutter/foundation.dart';

/// DEBUG-ONLY 9/10/2026 — compile-time switch for every entry point. Use it as
/// `if (kDebugTestEmployeeSwitchBuild)` so the branch is removed from release
/// and profile builds.
const bool kDebugTestEmployeeSwitchBuild =
    kDebugMode && !kReleaseMode && !kProfileMode;

/// DEBUG-ONLY 9/10/2026 — an email whose domain ends with one of these is a
/// test account (e.g. `omar.farouk@dm003.test`). An entry may be a suffix
/// (`.test`) or a full domain (`dm003.test`, `@dm003.test`).
const List<String> kDebugTestEmailDomains = <String>['.test'];

/// DEBUG-ONLY 9/10/2026 — company id prefilled in the picker when the app has
/// no last-used company yet (the owner's test company).
const String kDebugDefaultTestCompanyId = 'DM-003';

/// DEBUG-ONLY 9/10/2026 — log tag for every line this feature prints.
const String kDebugSwitchLogTag = '[debug-switch]';

/// Function Name: [isDebugTestEmployeeSwitchEnabled]
///
/// Purpose: The run-time guard. True only in a debug build.
///
/// DEBUG-ONLY 9/10/2026. The three flags are parameters (defaulting to the
/// framework constants) so the unit test can prove the answer is `false` for a
/// release or profile build.
///
/// Parameters:
/// - [debugMode]: `kDebugMode` unless injected.
/// - [releaseMode]: `kReleaseMode` unless injected.
/// - [profileMode]: `kProfileMode` unless injected.
///
/// Returns: [bool]
bool isDebugTestEmployeeSwitchEnabled({
  bool debugMode = kDebugMode,
  bool releaseMode = kReleaseMode,
  bool profileMode = kProfileMode,
}) =>
    debugMode && !releaseMode && !profileMode;

/// Function Name: [isDebugTestEmail]
///
/// Purpose: Whether [email] belongs to one of the test [domains].
///
/// DEBUG-ONLY 9/10/2026. Case-insensitive; only the part after the last `@`
/// is compared, so `admin.test@company.com` is NOT a test account.
///
/// Parameters:
/// - [email]: the address to check.
/// - [domains]: the allow-list, [kDebugTestEmailDomains] by default.
///
/// Returns: [bool]
bool isDebugTestEmail(String email,
    {List<String> domains = kDebugTestEmailDomains}) {
  final String normalized = email.trim().toLowerCase();
  final int at = normalized.lastIndexOf('@');
  if (at <= 0 || at == normalized.length - 1) return false;
  final String domain = normalized.substring(at + 1);
  for (final String raw in domains) {
    String entry = raw.trim().toLowerCase();
    if (entry.startsWith('@')) entry = entry.substring(1);
    if (entry.isEmpty || entry == '.') continue;
    if (entry.startsWith('.')) {
      if (domain.endsWith(entry)) return true;
    } else if (domain == entry || domain.endsWith('.$entry')) {
      return true;
    }
  }
  return false;
}

/// DEBUG-ONLY 9/10/2026 — why a debug switch was refused. The picker shows a
/// localized sentence for each one.
enum DebugSwitchRefusal {
  /// Not a debug build.
  disabled,

  /// The email does not end with a test domain.
  notTestEmail,

  /// The email is the company admin (demo-request contact).
  companyAdmin,

  /// The account belongs to another company than the one chosen.
  otherCompany,

  /// `Demo_Users_Accounts/{email}.Is_Activated` is false: the first sign-in
  /// (password change) has not happened yet.
  notActivated,

  /// The employee status is not `active` (locked, deactivated, reset…).
  statusBlocked,
}

/// Function Name: [debugTestEmployeeRefusal]
///
/// Purpose: The eligibility rule of the debug switch, as a pure function.
///
/// DEBUG-ONLY 9/10/2026. The checks that need Firestore are optional: pass
/// `null` for what is not known yet, and only the known ones are applied. The
/// repository calls it once before reading anything (guard + domain) and
/// again with the account and company it read.
///
/// Parameters:
/// - [email]: the account to switch to.
/// - [selectedCompanyId]: the company typed in the picker.
/// - [accountCompanyId]: `Demo_Users_Accounts/{email}.Company_Id`, if read.
/// - [companyAdminEmail]: the demo-request contact email, if read.
/// - [isActivated]: `Demo_Users_Accounts/{email}.Is_Activated`, if read.
/// - [enabled]: the build guard ([isDebugTestEmployeeSwitchEnabled]).
/// - [domains]: the test-domain allow-list.
///
/// Returns: [DebugSwitchRefusal?] — `null` when allowed.
DebugSwitchRefusal? debugTestEmployeeRefusal({
  required String email,
  required String selectedCompanyId,
  String? accountCompanyId,
  String? companyAdminEmail,
  bool? isActivated,
  bool? enabled,
  List<String> domains = kDebugTestEmailDomains,
}) {
  if (!(enabled ?? isDebugTestEmployeeSwitchEnabled())) {
    return DebugSwitchRefusal.disabled;
  }
  final String normalized = email.trim().toLowerCase();
  if (!isDebugTestEmail(normalized, domains: domains)) {
    return DebugSwitchRefusal.notTestEmail;
  }
  if (companyAdminEmail != null &&
      companyAdminEmail.trim().toLowerCase() == normalized) {
    return DebugSwitchRefusal.companyAdmin;
  }
  if (accountCompanyId != null &&
      accountCompanyId.trim().toLowerCase() !=
          selectedCompanyId.trim().toLowerCase()) {
    return DebugSwitchRefusal.otherCompany;
  }
  // CHANGED 9/10/2026 (coordinator follow-up) — DEBUG-ONLY: accounts made by
  // the Active Directory upload stay `Is_Activated == false` until a first
  // password sign-in + reset, which blocked every test account. A TEST-domain
  // account is now signed in as if activated (nothing is written — the flag
  // stays false in Firestore); only a non-test account is refused here, and
  // the domain check above already refuses those first.
  if (isActivated == false && !isDebugTestEmail(normalized, domains: domains)) {
    return DebugSwitchRefusal.notActivated;
  }
  return null;
}

/// DEBUG-ONLY 9/10/2026 — the reason a switch was refused, carried through the
/// repository's `Either` so the controller can show the right sentence.
///
/// [detail] is the value the sentence names (the other company id, or the
/// blocking status); never a credential.
class DebugSwitchFailure {
  const DebugSwitchFailure(this.refusal, {this.detail = ''});

  final DebugSwitchRefusal refusal;
  final String detail;

  @override
  String toString() => 'DebugSwitchFailure(${refusal.name}, $detail)';
}

/// DEBUG-ONLY 9/10/2026 — the in-memory "signed in through the debug switch"
/// flag. The header badge listens to [activeEmail]. Never persisted, so it
/// cannot outlive the process, and [start] is a no-op outside a debug build.
class DebugTestEmployeeSession {
  DebugTestEmployeeSession._();

  /// The test account signed in through the switch, or `null`.
  static final ValueNotifier<String?> activeEmail =
      ValueNotifier<String?>(null);

  /// Whether the current session came from the debug switch.
  static bool get isActive => activeEmail.value != null;

  /// Function Name: [start]
  ///
  /// Purpose: Mark the session as a debug test-employee session.
  ///
  /// Parameters:
  /// - [email]: the test account.
  /// - [enabled]: the build guard (injectable for tests).
  ///
  /// Returns: [void]
  static void start(String email, {bool? enabled}) {
    if (!(enabled ?? isDebugTestEmployeeSwitchEnabled())) return;
    activeEmail.value = email.trim().toLowerCase();
  }

  /// Function Name: [end]
  ///
  /// Purpose: Clear the flag (a normal sign-in, or a failed switch).
  ///
  /// Returns: [void]
  static void end() {
    if (activeEmail.value != null) activeEmail.value = null;
  }
}
