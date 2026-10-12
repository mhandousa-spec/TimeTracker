/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_request_form_rules.dart
/// Purpose: Which Health Insurance edit-form fields are required — the
///          insurance fields and the FIRST emergency contact. The second
///          emergency contact is OPTIONAL (owner decision, 9/10/2026).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// ─── RULE ────────────────────────────────────────────────────────────
///   • Insurance (name, policy number): every field required.
///   • 1st emergency contact (10 fields): every field required.
///   • 2nd emergency contact (10 fields): all-or-nothing. Leave it completely
///     empty and the request is valid; type into ANY of its fields and the
///     contact is "started", so every one of its fields is then required —
///     the same rule as the 1st contact. A half-filled contact is never sent.
///
/// The edit page (`edit_page_request_health.dart`) used to require all 22
/// fields before Preview, so an employee with one emergency contact could not
/// submit a Health request at all.
library;

/// Kept pure (plain strings in, bools out) so the rule is unit-tested without
/// a widget tree.
abstract final class HealthRequestFormRules {
  /// Whether any field of a group holds a value.
  static bool isStarted(Iterable<String> values) =>
      values.any((String v) => v.trim().isNotEmpty);

  /// Whether every field of a group holds a value.
  static bool isComplete(Iterable<String> values) =>
      values.every((String v) => v.trim().isNotEmpty);

  /// An optional group is valid when it is untouched or complete.
  static bool isOptionalGroupValid(Iterable<String> values) =>
      !isStarted(values) || isComplete(values);

  /// Function Name: [canPreview]
  ///
  /// Purpose: Whether the form holds a submittable set of values.
  ///
  /// Parameters:
  /// - [insurance]: insurance name + policy number.
  /// - [firstContact]: the 10 first-contact fields.
  /// - [secondContact]: the 10 second-contact fields.
  ///
  /// Returns: `true` when insurance and the 1st contact are complete and the
  ///          2nd contact is either empty or complete.
  static bool canPreview({
    required List<String> insurance,
    required List<String> firstContact,
    required List<String> secondContact,
  }) =>
      isComplete(insurance) &&
      isComplete(firstContact) &&
      isOptionalGroupValid(secondContact);

  /// Whether the 2nd contact's empty fields should show "required": only once
  /// the user has tried to submit AND the contact has been started.
  static bool showSecondContactErrors({
    required bool submitted,
    required List<String> secondContact,
  }) =>
      submitted && isStarted(secondContact);

  /// Whether the 2nd contact is the reason the form is not submittable — it
  /// was started but left incomplete.
  static bool isSecondContactIncomplete(List<String> secondContact) =>
      !isOptionalGroupValid(secondContact);
}
