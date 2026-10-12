/// Module: form_builder_module
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_shortcut.dart
/// Purpose: One-shot "open Form Builder AT …" request from outside the module.
/// Created at: 29/9/2026 — bug report p.2: the Home "Forms" card buttons
///          (Create Form / View Draft Form / View Requested Form) had empty
///          onTap handlers, so they did nothing.
library;

/// Where the Form Builder home should land when it next opens.
enum FormBuilderShortcut {
  createForm,
  publish,
  drafts,
  requestedForms,
  submissions,
}

/// Holder for a pending [FormBuilderShortcut]. The Home card sets it and then
/// switches to the module; FormBuilderHomeScreen consumes (and clears) it once
/// its data is loaded, the same pattern as
/// `FormResponsivePageLayout.pendingResultForm`.
class FormBuilderShortcuts {
  FormBuilderShortcuts._();

  static FormBuilderShortcut? pending;

  /// Returns the pending shortcut and clears it.
  static FormBuilderShortcut? take() {
    final FormBuilderShortcut? value = pending;
    pending = null;
    return value;
  }

  /// Home tab index for a tab shortcut, or null for [FormBuilderShortcut.createForm].
  static int? tabIndexOf(FormBuilderShortcut shortcut) {
    switch (shortcut) {
      case FormBuilderShortcut.publish:
        return 0;
      case FormBuilderShortcut.drafts:
        return 1;
      case FormBuilderShortcut.requestedForms:
        return 2;
      case FormBuilderShortcut.submissions:
        return 3;
      case FormBuilderShortcut.createForm:
        return null;
    }
  }
}
