/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: account_status_notification_service.dart
/// Purpose: Notifications raised when an account status changes.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO ************************* ///
/// File Name: account_status_notification_service.dart
/// Purpose: ALL notifications raised by the User Access module - account
///          activated / deactivated / locked / unlocked, and the scheduled
///          versions of those.
///
/// This is the User Access module's notification service. It has the same
/// shape as ServicesNotificationService: intent-named static methods, no
/// raw strings, everything delegated to AppNotificationSender.
///
/// ─── WHAT CHANGED ────────────────────────────────────────────────────
/// This file used to build every notification by hand: ~400 lines of
/// hardcoded message text, its own FCM call and its own Firestore write.
/// Three consequences, all now fixed:
///
///   1. The text was ENGLISH ONLY. The old header claimed bilingual
///      support, but no Arabic string existed anywhere in the file, so
///      Arabic-speaking users received English notifications.
///   2. Admins could NOT edit any of it. Nothing went through
///      NotificationTemplateService, so the Notification Control screen
///      had no effect on these notifications.
///   3. It wrote `module: "Roles"` (and in one place "Account Status").
///      Neither is a valid AppModule key - the correct key is
///      `user_access` - so its templates could never be matched.
///
/// Every message now comes from UserAccessNotificationEvent, which carries
/// the spec's bilingual text and is admin-editable like everything else.
///
/// ─── LANGUAGE ────────────────────────────────────────────────────────
/// `isArabic` defaults to false so the ten existing call sites keep
/// compiling with their current English behaviour. Pass the RECEIVER's
/// saved preference where you have it. Admin broadcasts send one language
/// to the whole batch.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/user_access_module/user_access_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/user_access_module/user_access_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class AccountStatusNotificationService {
  AccountStatusNotificationService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Used when no human triggered the change.
  static const String _systemSender = 'system@company.com';

  // ═══════════════════════════════════════════════════════════
  // Recipients
  // ═══════════════════════════════════════════════════════════

  /// Every Master Admin email, read from Employees_Info.
  ///
  /// Both `Role` and `Email` are history lists in this collection, so the
  /// CURRENT value of each is the last entry.
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

  /// One notification to one person.
  static Future<bool> _toUser(
    UserAccessNotificationEvent event, {
    required String receiverEmail,
    required String senderEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
  }) {
    return AppNotificationSender.sendEvent(
      event: event,
      pageKey: UserAccessNotificationPage.accountStatusPage.key,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      variables: variables,
    );
  }

  /// The same notification to every Master Admin. Returns how many went out.
  static Future<int> _toAdmins(
    UserAccessNotificationEvent event, {
    required String senderEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
  }) async {
    return AppNotificationSender.sendEventToAll(
      event: event,
      pageKey: UserAccessNotificationPage.accountStatusPage.key,
      senderEmail: senderEmail,
      receiverEmails: await _masterAdminEmails(),
      isArabic: isArabic,
      variables: variables,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 1. Account activated - the user, then the admins
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendAccountActivatedNotification({
    required String userEmail,
    required String userName,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toUser(
      UserAccessNotificationEvent.accountActivatedUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
    );
    await _toAdmins(
      UserAccessNotificationEvent.accountActivatedAdmin,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 2. Account deactivated
  //
  // The spec defines an admin-facing event only, so that is what goes out.
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendAccountDeactivatedNotification({
    required String userEmail,
    required String userName,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toAdmins(
      UserAccessNotificationEvent.accountDeactivatedAdmin,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3. Account unlocked - the user, then the admins
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendAccountUnlockedNotification({
    required String userEmail,
    required String userName,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toUser(
      UserAccessNotificationEvent.accountUnlockedUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
    );
    await _toAdmins(
      UserAccessNotificationEvent.accountUnlockedAdmin,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 4. Activation scheduled
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendActivationScheduledNotification({
    required String userEmail,
    required String userName,
    required String scheduledDate,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toUser(
      UserAccessNotificationEvent.activationScheduledUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.scheduledDate: scheduledDate},
    );
    await _toAdmins(
      UserAccessNotificationEvent.activationScheduledAdmin,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 5. Deactivation scheduled
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendDeactivationScheduledNotification({
    required String userEmail,
    required String userName,
    required String scheduledDate,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toUser(
      UserAccessNotificationEvent.deactivationScheduledUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.scheduledDate: scheduledDate},
    );
    await _toAdmins(
      UserAccessNotificationEvent.deactivationScheduledAdmin,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 6. A scheduled activation or deactivation was moved
  //
  // [scheduleType] ("activation" / "deactivation") is kept so the existing
  // call sites compile. The spec defines ONE event for a revised access
  // schedule, so both types resolve to it.
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendScheduleEditedNotification({
    required String userEmail,
    required String userName,
    required String newScheduledDate,
    required String scheduleType,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toUser(
      UserAccessNotificationEvent.accessScheduleUpdatedUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.scheduledDate: newScheduledDate},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 7. A scheduled change was cancelled
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendScheduleCanceledNotification({
    required String userEmail,
    required String userName,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toUser(
      UserAccessNotificationEvent.scheduledActionCancelledUser,
      receiverEmail: userEmail,
      senderEmail: senderEmail,
      isArabic: isArabic,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 8. Locked after three failed attempts - admins only
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendAccountLockedNotification({
    required String userEmail,
    required String userName,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toAdmins(
      UserAccessNotificationEvent.accountLockedFailedAttempts,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 9. The user asked to be unlocked - admins only
  // ═══════════════════════════════════════════════════════════
  static Future<void> sendUnlockRequestNotification({
    required String userEmail,
    required String userName,
    String senderEmail = _systemSender,
    bool isArabic = false,
  }) async {
    await _toAdmins(
      UserAccessNotificationEvent.accountUnlockRequestedAdmin,
      senderEmail: senderEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: userName},
    );
  }
}
