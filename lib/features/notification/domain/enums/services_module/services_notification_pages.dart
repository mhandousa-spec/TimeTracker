/// ************************* FILE INFO ************************* ///
/// File Name: services_notification_pages.dart
/// Purpose: Target services_management_module a notification can navigate to inside the
///          Services Management module (Firestore field `name_of_page`).
/// Pattern: One `<module>_module/` folder per module holding every enum
///          that module owns (events + pages),
///          same idea as role permission enums in
///          lib/features/roles/r1_role_management/domain/enums/.
///
/// ⚠️ RULE: Never write page names as raw strings
/// ('ApprovalRequestCard', ...). Always use this enum.

enum ServicesNotificationPage {
  approvalRequestCard('ApprovalRequestCard'),
  requestServicesToggle('RequestServicesToggle'),
  serviceProviderDashboard('ServiceProviderDashboard');

  const ServicesNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;
}
