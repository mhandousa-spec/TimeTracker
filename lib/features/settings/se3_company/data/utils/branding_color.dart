/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: branding_color.dart
/// Purpose: Convert between a stored branding colour string and a [Color].
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE3-N11. `employee_branding_screen.dart` had four
/// `try { Color(int.parse(...)) } catch (e) {}` blocks — try/catch is forbidden
/// in presentation/ui/ (§20/§21), and all four catches were empty, so a
/// malformed colour left the field silently unset with no way to tell that from
/// "not configured". `int.tryParse` removes the need to throw at all.

import 'package:flutter/material.dart';

abstract class BrandingColor {
  /// Function Name: [parse]
  ///
  /// Purpose: Read a stored colour.
  ///
  /// Parameters:
  /// - [raw]: an `0xAARRGGBB` string as written by the branding save paths.
  ///
  /// Returns: [Color?] — `null` when [raw] is absent, empty or unparseable.
  static Color? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final int? value = int.tryParse(raw.trim());
    return value == null ? null : Color(value);
  }

  /// Function Name: [format]
  ///
  /// Purpose: Write a colour in the shape [parse] reads.
  ///
  /// Returns: [String?] — `null` for a null colour, so "not set" round-trips.
  static String? format(Color? color) => color == null
      ? null
      : '0x${color.value.toRadixString(16).padLeft(8, '0')}';
}
