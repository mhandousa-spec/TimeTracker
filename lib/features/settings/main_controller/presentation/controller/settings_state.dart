/// Module: settings/main_controller
//
///*************************** FILE INFO ****************************///
/// File Name: settings_state.dart
/// Purpose: States for SettingsController.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026

part of './settings_controller.dart';

sealed class SettingsState {
  const SettingsState();
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Emitted whenever settings data changes. Deliberately not value-equal, so
/// every emit rebuilds — this replaces the GetX `update()` calls.
///
/// ⚠️ The constructor is NOT `const`, and must not become one. Bloc's `emit`
/// skips when `state == newState`; with no `==` override that comparison is
/// identity, and a const constructor with no fields is canonicalised — every
/// `const SettingsLoaded()` in the program is the *same object*. Two
/// consecutive emits would therefore be silently dropped, which is the exact
/// opposite of the "every emit rebuilds" contract above. Each call now
/// allocates a distinct instance, so back-to-back emits always notify.
final class SettingsLoaded extends SettingsState {
  SettingsLoaded();
}

/// Emitted when loading the employee or the directory fails.
///
/// The GetX version had two `catch (e, stack) { }` blocks with every log line
/// commented out, so a failed load was completely invisible.
final class SettingsError extends SettingsState {
  const SettingsError(this.message);

  final String message;
}
