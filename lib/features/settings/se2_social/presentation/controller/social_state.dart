/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_state.dart
/// Purpose: States for SocialController.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026

part of './social_controller.dart';

sealed class SocialState {
  const SocialState();
}

final class SocialInitial extends SocialState {
  const SocialInitial();
}

/// The draft changed.
///
/// FIXED 13/8/2026: this was `const SocialEditing()` with the comment
/// "deliberately not value-equal, so every emit rebuilds". The class has no
/// `==` override, so equality *is* identity — and `const` makes Dart
/// canonicalise every `const SocialEditing()` to one single instance. Bloc
/// drops an emit when `state == nextState`, so the first publish went through
/// and every one after it was silently swallowed. Adding a skill, hobby or
/// academic row updated the draft in the cubit and never rebuilt the page,
/// which is why the "+ المزيد" buttons looked dead.
///
/// [revision] makes each emit a distinct value. The cubit increments it on
/// every publish; nothing reads it.
final class SocialEditing extends SocialState {
  const SocialEditing(this.revision);

  final int revision;

  @override
  bool operator ==(Object other) =>
      other is SocialEditing && other.revision == revision;

  @override
  int get hashCode => revision.hashCode;
}

final class SocialSaving extends SocialState {
  const SocialSaving();
}

/// One-shot: the page shows the success dialog and clears it.
///
/// Replaces `Get.dialog(...)` fired from inside the controller, plus the
/// `Future.delayed(3s)` that closed it (CR-SKEL-SE2-N08, N10).
final class SocialSaved extends SocialState {
  const SocialSaved();
}

/// One-shot: the user pressed save with nothing edited.
final class SocialNoChanges extends SocialState {
  const SocialNoChanges();
}

/// One-shot: the save failed.
///
/// [message] is the raw failure reason and is for logs and support, not for
/// display — the page shows a localized string (CR-SKEL-SE2-N11).
final class SocialError extends SocialState {
  const SocialError(this.message);

  final String message;
}
