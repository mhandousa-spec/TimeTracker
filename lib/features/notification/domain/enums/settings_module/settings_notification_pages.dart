/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: settings_notification_pages.dart
/// Purpose: Notification event catalog: settings notification pages.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO ************************* ///
/// File Name: settings_notification_pages.dart
/// Purpose: Target pages a notification from the Settings module can
///          navigate to (Firestore field `name_of_page`).
/// Pattern: One `<module>_notification_pages.dart` per module folder,
///          beside that module's event enum.
///
/// Values are the real screen widget names in the feature, so a key can
/// always be traced to a class that exists.
///
/// ⚠️ KNOWN GAP: the notification tap handlers
/// (notification_page / clear_page_notification / pin_notification)
/// currently route by MODULE only - they read `nameOfModule` and ignore
/// `nameOfPage`. These keys are stored correctly but not yet acted on.
/// They are what a future deep-link router will switch over.
///
/// ⚠️ RULE: Never write page names as raw strings. Always use this enum.

enum SettingsNotificationPage {
  /// Personal information section.
  personalInfoScreen('PersonalInfoScreen'),
  /// Approver view of a submitted personal-information change.
  previewChangesPage('PreviewChangesPage'),
  /// Approver view of a submitted health-insurance change.
  previewHealthInsuranceChangesPage('PreviewHealthInsuranceChangesPage'),
  /// Social information section.
  socialScreen('SocialScreen'),
  /// Company information.
  companyInfoScreen('CompanyInfoScreen'),
  /// Comments & feedback thread list.
  commentsAndFeedbackScreen('CommentsAndFeedbackScreen'),
  /// The employee's own submitted requests.
  myRequestPage('MyRequestPage'),
  /// About this app.
  aboutThisAppScreen('AboutThisAppScreen'),
  /// Privacy policy and terms & conditions.
  privacyStatementPage('PrivacyStatementPage'),
  ;

  const SettingsNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;

  static SettingsNotificationPage? fromKey(String key) {
    for (final p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}
