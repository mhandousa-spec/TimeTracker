// ******************* FILE INFO *******************
// File Name: service_display_status
// Description: Enum for the displayed availability status of a service row.
// Module: services_management_module / domain / enums
// *************************************************

/// Fixed set of statuses shown in the services table (§8 — use enums for
/// fixed value sets instead of comparing raw strings like 'active'/'inactive').
enum ServiceDisplayStatus {
  active,
  inactive,
  draft;

  /// The persisted `state` value that marks a service as an unfinished draft.
  static const String draftState = 'draft';

  /// Function Name: [of]
  ///
  /// Purpose: Classify a service from BOTH of its persisted fields — the only
  /// correct way to ask "what is this service".
  ///
  /// ADDED 26/8/2026, and every caller that used to reach for one field alone
  /// should use this instead.
  ///
  /// ─── WHY BOTH FIELDS ─────────────────────────────────────────────────
  /// The two are not alternatives, they answer different questions:
  ///
  ///   * `state`  — the LIFECYCLE. 'draft' while the wizard is unfinished,
  ///                'submitted' once it has been published.
  ///   * `status` — the AVAILABILITY the service has, or WILL have once it is
  ///                published: 'active' / 'inactive'.
  ///
  /// A draft therefore carries a perfectly real `status`, and it is almost
  /// always 'active', because the create form's availability switch defaults to
  /// on and `SlaNotificationCubit.updateAndSaveModel` writes that value on
  /// every save — Save For Later included. That is correct storage: the draft
  /// is remembering the availability it is destined for.
  ///
  /// Reading `status` alone therefore reports EVERY draft as Active. That is
  /// exactly what the home page did: the table row said Active, the Active chip
  /// counted it, and the Draft chip did not.
  ///
  /// ─── THE RULE ────────────────────────────────────────────────────────
  /// Draft wins. An unfinished service is a draft whatever availability it is
  /// holding for later; `status` only becomes the answer once `state` says the
  /// service is real.
  ///
  /// Parameters:
  /// - [state]: the service's `currentState`.
  /// - [status]: the service's `currentStatus`.
  ///
  /// Returns: [ServiceDisplayStatus]
  static ServiceDisplayStatus of({String? state, String? status}) {
    if ((state ?? '').toLowerCase().trim() == draftState) {
      return ServiceDisplayStatus.draft;
    }
    final String raw = (status ?? '').trim();
    return fromRaw(raw.isEmpty ? state : raw);
  }

  /// Maps a single raw `state`/`status` string to a [ServiceDisplayStatus].
  /// Anything that is not explicitly active/inactive is treated as a draft.
  ///
  /// ⚠️ Prefer [of] when both fields are available. Passing only `status` here
  /// cannot see that a service is a draft; passing only `state` cannot see
  /// whether it is active or inactive. [of] is the one that gets both right.
  static ServiceDisplayStatus fromRaw(String? raw) {
    switch ((raw ?? '').toLowerCase().trim()) {
      case 'active':
        return ServiceDisplayStatus.active;
      case 'inactive':
        return ServiceDisplayStatus.inactive;
      default:
        return ServiceDisplayStatus.draft;
    }
  }
}
