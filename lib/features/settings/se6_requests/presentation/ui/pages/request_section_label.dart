/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_section_label.dart
/// Purpose: Render a request's stored `section` as localized display text.
/// Author: Knowticed Plus team
/// Created at: 13/8/2026
///
/// Added while fixing the untranslated "Personal Information" / "Health
/// Insurance" chips on the request cards.
///
/// `ChangeRequest.section` is stored as free English text in Firestore
/// (`ChangeRequest.defaultSection` is the literal `'Personal Information'`),
/// so it can never be shown raw. Two pages had their own private
/// `_translateTitle` for this and they had drifted: `details_request.dart`
/// handled Personal Information, Emergency Contact and Health Insurance, while
/// `request_page.dart` — the list the user actually looks at — was missing the
/// Personal Information case entirely, which is why that one chip stayed in
/// English next to a correctly translated التأمين الصحي.
///
/// Both copies also hardcoded the Arabic strings inline rather than using the
/// `personalInformation` / `healthInsurance` / `emergencyContact` keys that
/// already existed in both .arb files.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';

abstract final class RequestSectionLabel {
  const RequestSectionLabel._();

  /// Function Name: [of]
  ///
  /// Purpose: The display name for a stored section value, in the active
  ///          locale.
  ///
  /// Falls back to the stored text for a section this build does not know
  /// about — the previous behaviour, and better than showing a blank chip.
  static String of(BuildContext context, String? section) {
    final String raw = section?.trim() ?? '';
    if (raw.isEmpty) return '';

    switch (_normalize(raw)) {
      case 'personal information':
        return S.of(context).personalInformation;
      case 'health insurance':
        return S.of(context).healthInsurance;
      case 'emergency contact':
        return S.of(context).emergencyContact;
      default:
        return raw;
    }
  }

  /// Function Name: [_normalize]
  ///
  /// Purpose: Reduce a stored section value to a stable lookup form.
  ///
  /// HARDENED 13/8/2026: the switch matched the exact string
  /// `'Personal Information'`. `section` is free text written by whichever
  /// screen raised the request — `ChangeRequest.defaultSection` supplies that
  /// exact spelling, but nothing enforces it, and a document holding
  /// `personal_information`, `Personal information` or a double space fell
  /// straight through to `default` and rendered in English with no error
  /// anywhere. Casing, underscores and repeated spaces are now all folded away,
  /// so only a genuinely unknown section falls back.
  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('_', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
