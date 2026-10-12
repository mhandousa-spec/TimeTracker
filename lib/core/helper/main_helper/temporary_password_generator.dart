/// Module: core/helper
///
///*************************** FILE INFO ****************************///
/// File Name: temporary_password_generator.dart
/// Purpose: Generate a one-off temporary password for a newly created account.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// SECURITY
/// --------
/// Replaces a hardcoded `'123456'` default password that was assigned to every
/// employee created through the Active Directory import. Because login falls
/// back to `employeeModel.password ?? employeeModel.defaultPassword`, that one
/// literal was a valid credential for every account that had not yet set its
/// own password.
///
/// This is a mitigation, not a fix. The real fix is to force a password change
/// on first login and stop accepting the temporary value afterwards.

import 'dart:math';

abstract final class TemporaryPasswordGenerator {
  const TemporaryPasswordGenerator._();

  /// Ambiguous glyphs (0/O, 1/l/I) are excluded so the value can be read out
  /// or copied from an email without transcription errors.
  static const String _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _lower = 'abcdefghijkmnopqrstuvwxyz';
  static const String _digits = '23456789';
  static const String _symbols = '!@#%^&*-_=+';

  static const int defaultLength = 12;

  /// Function Name: [generate]
  ///
  /// Purpose: Produce a random temporary password containing at least one
  ///          character from each class.
  ///
  /// Parameters:
  /// - [length]: Total length; clamped to a minimum of 8.
  ///
  /// Returns: [String] the generated password.
  static String generate({int length = defaultLength}) {
    final int size = length < 8 ? 8 : length;

    // Random.secure() is backed by the platform CSPRNG. Random() would be
    // predictable from the seed, which for a credential is not acceptable.
    final Random rng = Random.secure();

    const String all = _upper + _lower + _digits + _symbols;
    final List<String> chars = <String>[
      _upper[rng.nextInt(_upper.length)],
      _lower[rng.nextInt(_lower.length)],
      _digits[rng.nextInt(_digits.length)],
      _symbols[rng.nextInt(_symbols.length)],
      for (int i = 4; i < size; i++) all[rng.nextInt(all.length)],
    ]..shuffle(rng);

    return chars.join();
  }
}
