/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_collection_paths.dart
/// Purpose: Resolve the tenant-aware path the feedback flow writes to.
/// Author: Knowticed Plus team
/// Created at: 13/8/2026
///
/// Added while fixing the dead submit button on the comments-and-feedback
/// screen. Follows the shape of `RequestCollectionPaths`: the module document
/// is resolved through `getBaseUrl` so the company id is never hardcoded, and
/// the submissions hang off it as a sub-collection.

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

abstract final class FeedbackCollectionPaths {
  const FeedbackCollectionPaths._();

  static const String _settingsDocName = 'settings';

  /// `{baseUri}/Modules/settings` — the settings module document.
  ///
  /// Resolves to `Demo/{companyId}/Modules/settings`.
  static String get settingsDoc =>
      '${getBaseUrl(FirebaseCollections.modulesKey)}/$_settingsDocName';

  /// The sub-collection of [settingsDoc] holding one document per submission.
  static String get feedbackCollection => FirebaseCollections.appFeedback;
}
