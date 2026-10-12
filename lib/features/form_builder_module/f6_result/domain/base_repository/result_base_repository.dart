/// Module: services_app_module/result
///
/// FILE INFO
/// File Name   : result_base_repository.dart
/// Objective   : Domain contract for the result feature. Presentation depends
///               on this interface (via DI) instead of the concrete
///               data/repository implementation (§3, §4.3).
library;

abstract class ResultBaseRepository {
  /// Fetches all responses submitted to [formId].
  Future<dynamic> getFormResponses({required String formId});

  /// Sends a reminder to [userId] for the given [formId].
  Future<dynamic> remindUser({required String userId, required String formId});

  /// Loads the privacy configuration for [formId].
  /// Return type is `dynamic` to accommodate the shared CommonRepository mixin
  /// implementation whose inferred return type is not explicitly `Future`.
  dynamic getFormPrivacy(String formId);
}
