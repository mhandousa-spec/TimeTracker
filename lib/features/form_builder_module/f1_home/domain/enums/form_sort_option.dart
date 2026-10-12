// Date: 19/8/2026
// Objectives: Stable, language-independent keys for the Home "Sort" menu.
//
// ADDED 19/8/2026 for the localization bug report.
//
// `home_controller.sortForms()` used to `switch` on the sort option as it was
// SPELLED ON SCREEN, with one `case` per language:
//
//     case 'Published Date':
//     case 'تاريخ النشر':
//
// That is why sorting silently stopped working whenever the wording drifted:
// any new locale, or a one-word copy edit to `published_date` in the .arb,
// falls straight through to `default`. The menu now passes one of these
// constants and shows [labelOf] instead, so what the user READS and what the
// controller BRANCHES ON are two different things.

import 'package:knowticed_plus/generated/l10n.dart';

class FormSortOption {
  const FormSortOption._();

  /// Sort by the date the form was published.
  static const String publishedDate = 'Published Date';

  /// Sort by the date the form was last updated.
  static const String lastUpdate = 'Last Update';

  /// Submissions tab: the date the user submitted (bug report #24).
  static const String submissionDate = 'Submission Date';

  /// Submissions tab: the date the form was received / shared.
  static const String receivedDate = 'Received Date';

  /// Every option the Sort menu offers, in display order.
  static const List<String> values = <String>[publishedDate, lastUpdate];

  /// Options of the Submissions tab (bug report #24).
  static const List<String> submissionValues = <String>[
    submissionDate,
    receivedDate,
  ];

  /// The translated text for [option]. Unknown values are echoed back rather
  /// than blanked, so stale stored preferences stay visible instead of
  /// silently rendering as an empty row.
  static String labelOf(String option) {
    switch (option) {
      case publishedDate:
        return S.current.published_date;
      case lastUpdate:
        return S.current.lastUpdate;
      case submissionDate:
        return S.current.submissionDate;
      case receivedDate:
        return S.current.receivedDate;
      default:
        return option;
    }
  }
}
