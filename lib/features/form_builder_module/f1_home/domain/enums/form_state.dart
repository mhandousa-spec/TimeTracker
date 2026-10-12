// Date: 21/1/2025
// By: mohamed Mohy
// Last update: 22/1/2025
// Objectives: Enum representing the status of a form

import 'package:knowticed_plus/generated/l10n.dart';

enum FormStatus {
  publish,
  drafts,
  requestedForms,
  submissions,
  deleted,
}

// Extension to get the name of the form status as a string
extension FormStatusExtension on FormStatus {
  /// STABLE identifier — this is the value stored on the form document and the
  /// key the home tabs filter on. NOT translated; see [label].
  String get name {
    switch (this) {
      case FormStatus.publish:
        return 'Publish';
      case FormStatus.drafts:
        return 'Drafts';
      case FormStatus.requestedForms:
        return 'Requested Forms';
      case FormStatus.submissions:
        return 'Submissions';
      case FormStatus.deleted:
        return 'Deleted';
      default:
        return '';
    }
  }

  /// Translated tab label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case FormStatus.publish:
        return s.formStatusPublish;
      case FormStatus.drafts:
        return s.formStatusDrafts;
      case FormStatus.requestedForms:
        return s.formStatusRequestedForms;
      case FormStatus.submissions:
        return s.formStatusSubmissions;
      case FormStatus.deleted:
        return s.formStatusDeleted;
      default:
        return '';
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in FormStatus.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }
}
