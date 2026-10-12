/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: role_management_notification_service.dart
/// Purpose: Notifications raised when a role is created, edited, deleted or
///          has its status changed.
/// Author: Knowticed Plus team
/// Created at: 18/8/2026
///
/// ************************* FILE INFO ************************* ///
/// File Name: role_management_notification_service.dart
/// Purpose: ALL notifications raised by the Role Management module.
///          Intent-named static methods, no raw strings, everything
///          delegated to AppNotificationSender — the same shape as
///          ServicesNotificationService and AccountStatusNotificationService.
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// `services_notification_service.dart` has named this file in its header
/// as the pattern it matches since it was written. The file did not
/// actually exist. `role_management_events.dart` and
/// `role_management_notification_pages.dart` were both there, the
/// Notification Control screen has been listing all four events, and
/// nothing could send any of them.
///
/// ⚠️ It does NOT wire itself into r1_role_management. `role_cubit.dart`
/// and `role_repository.dart` still have to invoke these methods at the
/// point they persist a role change; until they do, the events remain
/// unsent. Each method notes the action that should trigger it.
///
/// ─── AUDIENCE ────────────────────────────────────────────────────────
/// Every event here is worded as a peer notice — "has been created by
/// {{userName}}. Please review the role details." — so all four fan out to
/// the Master Admins rather than to any one user, and the person who made
/// the change is filtered out. Telling someone what they just did is noise;
/// this mirrors how `database_notification_dispatcher` excludes the actor.
///
/// ─── LANGUAGE ────────────────────────────────────────────────────────
/// `isArabic` defaults to false so new call sites are explicit about it.
/// A fan-out sends one language to the whole batch.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/role_management_module/role_management_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/role_management_module/role_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

class RoleManagementNotificationService {
  RoleManagementNotificationService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════
  // Recipients
  // ═══════════════════════════════════════════════════════════

  /// Every Master Admin email except [excluding], read from Employees_Info.
  ///
  /// Both `Role` and `Email` are history lists in this collection, so the
  /// CURRENT value of each is the last entry.
  static Future<List<String>> _masterAdminEmails({
    required String excluding,
  }) async {
    final actor = excluding.trim().toLowerCase();
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

        final email = emailList.last.toString();
        if (email.trim().toLowerCase() == actor) continue;
        emails.add(email);
      }
      return emails;
    } catch (_) {
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Internal sender
  // ═══════════════════════════════════════════════════════════

  /// Fan one event out to every Master Admin except the actor.
  /// Returns how many notifications went out.
  static Future<int> _toAdmins(
    RoleManagementNotificationEvent event, {
    required String actorEmail,
    required String pageKey,
    required bool isArabic,
    required Map<TemplateVariable, String> variables,
  }) async {
    return AppNotificationSender.sendEventToAll(
      event: event,
      pageKey: pageKey,
      senderEmail: actorEmail,
      receiverEmails: await _masterAdminEmails(excluding: actorEmail),
      isArabic: isArabic,
      variables: variables,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 1. Role created
  //
  // Trigger: a new role document is written from the "Add New Role" flow.
  // Lands on the new role's own detail page.
  // ═══════════════════════════════════════════════════════════
  static Future<int> sendRoleCreatedNotification({
    required String actorEmail,
    required String actorName,
    required String roleName,
    bool isArabic = false,
  }) {
    return _toAdmins(
      RoleManagementNotificationEvent.roleCreated,
      actorEmail: actorEmail,
      pageKey: RoleManagementNotificationPage.roleDetailsPage.key,
      isArabic: isArabic,
      variables: {
        TemplateVariable.roleName: roleName,
        TemplateVariable.userName: actorName,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 2. Role updated
  //
  // Trigger: an existing role's permissions or details are saved.
  // Lands on the editing screen so the reviewer sees the configuration
  // that changed, not just the summary.
  // ═══════════════════════════════════════════════════════════
  static Future<int> sendRoleUpdatedNotification({
    required String actorEmail,
    required String actorName,
    required String roleName,
    bool isArabic = false,
  }) {
    return _toAdmins(
      RoleManagementNotificationEvent.roleUpdated,
      actorEmail: actorEmail,
      pageKey: RoleManagementNotificationPage.editingRolePage.key,
      isArabic: isArabic,
      variables: {
        TemplateVariable.roleName: roleName,
        TemplateVariable.userName: actorName,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3. Role deleted
  //
  // Trigger: a role is removed. Lands on the role list rather than the
  // role's own page, which no longer exists.
  // ═══════════════════════════════════════════════════════════
  static Future<int> sendRoleDeletedNotification({
    required String actorEmail,
    required String actorName,
    required String roleName,
    bool isArabic = false,
  }) {
    return _toAdmins(
      RoleManagementNotificationEvent.roleDeleted,
      actorEmail: actorEmail,
      pageKey: RoleManagementNotificationPage.roleScreen.key,
      isArabic: isArabic,
      variables: {
        TemplateVariable.roleName: roleName,
        TemplateVariable.userName: actorName,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 4. Role status changed
  //
  // Trigger: a role is activated / deactivated. Both the old and the new
  // status are required — the template prints the transition, so passing
  // only the new one would render "from  to Active".
  // ═══════════════════════════════════════════════════════════
  static Future<int> sendRoleStatusChangedNotification({
    required String actorEmail,
    required String actorName,
    required String roleName,
    required String oldStatus,
    required String newStatus,
    bool isArabic = false,
  }) {
    return _toAdmins(
      RoleManagementNotificationEvent.roleStatusChanged,
      actorEmail: actorEmail,
      pageKey: RoleManagementNotificationPage.roleDetailsPage.key,
      isArabic: isArabic,
      variables: {
        TemplateVariable.roleName: roleName,
        TemplateVariable.oldStatus: oldStatus,
        TemplateVariable.newStatus: newStatus,
        TemplateVariable.userName: actorName,
      },
    );
  }
}
