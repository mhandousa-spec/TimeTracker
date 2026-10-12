/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_notification_service.dart
/// Purpose: Notifications raised when a user's access rights change.
/// Author: Knowticed Plus team
/// Created at: 18/8/2026
///
/// ************************* FILE INFO ************************* ///
/// File Name: user_management_notification_service.dart
/// Purpose: ALL notifications raised by the User Management & Permissions
///          module — access granted / updated / revoked, and the scheduled
///          versions of those.
///
/// This is the User Management module's notification service. It has the
/// same shape as ServicesNotificationService and its direct sibling
/// AccountStatusNotificationService (which covers User Access): intent-named
/// static methods, no raw strings, everything delegated to
/// AppNotificationSender.
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// `user_management_events.dart` has carried all eight events from spec
/// §1.5 since the catalog was written, and the Notification Control screen
/// has been listing them and letting admins edit their templates. Nothing
/// ever sent one — there was no service between the catalog and the
/// feature code, so every one of those eight templates was dead weight.
/// This file is that missing layer.
///
/// ⚠️ It does NOT wire itself into r2_user_management. The call sites that
/// grant, revoke and schedule access still have to invoke these methods;
/// until they do, the events remain unsent. Each method notes the action
/// that should trigger it.
///
/// ─── AUDIENCE ────────────────────────────────────────────────────────
/// The spec splits several of these events in two: one addressed to the
/// affected user, one to the administrators. Where both exist, the paired
/// method sends both — the user first, then a fan-out to every Master
/// Admin. `_masterAdminEmails` mirrors AccountStatusNotificationService:
/// `Role` and `Email` are history lists in Employees_Info, so the CURRENT
/// value of each is the last entry.
///
/// ─── LANGUAGE ────────────────────────────────────────────────────────
/// `isArabic` defaults to false so new call sites are explicit about it
/// rather than silently sending Arabic. Pass the RECEIVER's saved
/// preference where you have it. Admin fan-outs send one language to the
/// whole batch.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/user_management_module/user_management_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/user_management_module/user_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class UserManagementNotificationService {
  UserManagementNotificationService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Used when no human triggered the change (a scheduled job applying a
  /// pre-dated access change, for example).
  static const String _systemSender = 'system@company.com';

  // ═══════════════════════════════════════════════════════════
  // Recipients
  // ═══════════════════════════════════════════════════════════

  /// Every Master Admin email, read from Employees_Info.
  static Future<List<String>> _masterAdminEmails() async {
    try {
      final snapshot =
          await _firestore.collection(getBaseUrl('Employees_Info')).get();

      final emails = <String>[];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final roles = data['Role'];
        if (roles is! List || roles.isEmpty) continue;
        if (roles.last.toString().toLowerCase() != 'master admin') continue;

        final emailList = data['Email'];
        if (emailList is! List || emailList.isEmpty) continue;
        emails.add(emailList.last.toString());
      }
      return emails;
    } catch (_) {
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Internal senders
  // ═══════════════════════════════════════════════════════════

  /// One notification to one person. Lands on the user's own access screen.
  static Future<bool> _toUser(
    UserManagementNotificationEvent event, {
    required String receiverEmail,
    required String senderEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
  }) {
    return AppNotificationSender.sendEvent(
      event: event,
      pageKey: UserManagementNotificationPage.roleEmployeeDetailsPage.key,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      variables: variables,
    );
  }

  /// The same notification to every Master Admin. Returns how many went out.
  ///
  /// Admins land on the permission toggles rather than the employee card,
  /// because the admin-facing events are all about what changed rather than
  /// who it happened to.
  static Future<int> _toAdmins(
    UserManagementNotificationEvent event, {
    required String senderEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
  }) async {
    return AppNotificationSender.sendEventToAll(
      event: event,
      pageKey: UserManagementNotificationPage.settingsSwitchesPage.key,
      senderEmail: senderEmail,
      receiverEmails: await _masterAdminEmails(),
      isArabic: isArabic,
      variables: variables,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 1. Access granted
  //
  // Trigger: a role is assigned to a user for the first time.
  // The spec defines a user-facing event only.
  // ═══════════════════════════════════════════════════════════
  static Future<bool> sendAccessGrantedNotification({
    required String userEmail,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) {
    return _toUser(
      UserManagementNotificationEvent.accessGrantedUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 2. Access updated
  //
  // Trigger: an existing user's permissions are edited.
  // The spec defines a user-facing event only.
  // ═══════════════════════════════════════════════════════════
  static Future<bool> sendAccessUpdatedNotification({
    required String userEmail,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) {
    return _toUser(
      UserManagementNotificationEvent.accessUpdatedUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3. Access revoked — the user, then the admins
  //
  // Trigger: a user's role assignment is removed.
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendAccessRevokedNotification({
    required String userEmail,
    required String userName,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toUser(
      UserManagementNotificationEvent.accessRevokedUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
    );
    await _toAdmins(
      UserManagementNotificationEvent.accessRevokedAdmin,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 4. Access change scheduled
  //
  // Trigger: a permission change is saved with a future effective date.
  // The spec defines a user-facing event only.
  // ═══════════════════════════════════════════════════════════
  static Future<bool> sendAccessChangeScheduledNotification({
    required String userEmail,
    required String scheduledDate,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) {
    return _toUser(
      UserManagementNotificationEvent.accessChangeScheduledUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.scheduledDate: scheduledDate},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 5. Scheduled access applied — the user, then the admins
  //
  // Trigger: the job that executes pre-dated access changes runs and the
  // change actually lands. Sender defaults to the system for that reason.
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendScheduledAccessAppliedNotification({
    required String userEmail,
    required String userName,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toUser(
      UserManagementNotificationEvent.scheduledAccessAppliedUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
    );
    await _toAdmins(
      UserManagementNotificationEvent.scheduledAccessAppliedAdmin,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 6. Scheduled access cancelled
  //
  // Trigger: a pending pre-dated change is withdrawn before it runs.
  // The spec defines a user-facing event only.
  // ═══════════════════════════════════════════════════════════
  static Future<bool> sendScheduledAccessCancelledNotification({
    required String userEmail,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) {
    return _toUser(
      UserManagementNotificationEvent.scheduledAccessCancelledUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
    );
  }
}
