/// Module: messaging / main_controller / helper
///
///*************************** FILE INFO ****************************///
/// File Name: messages_permissions.dart
/// Purpose: Every Messages permission question, answered in one place.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// ─── WHY THIS SHAPE ──────────────────────────────────────────────────
/// Deliberately the same shape as
/// `knowledge_hub/main_controller/helper/knowledge_hub_permissions.dart`, and
/// for the same reason: that module asked `isHasPermission` in twenty places
/// and ended up with `downloadDocuments` enforced on one screen and ignored on
/// two others. A role switch obeyed in one place out of three looks exactly
/// like a broken switch.
///
/// Messaging starts with no such calls at all, so this file exists BEFORE the
/// first one rather than as a repair afterwards.
///
/// ─── THE MASTER TOGGLES ──────────────────────────────────────────────
/// The design draws each column with a master toggle above it, and those are
/// section-level permissions — asked with `permission: null`. They are not
/// decoration: turning `Messages Permissions` off is meant to remove the whole
/// column's abilities without the admin clearing six switches by hand.
///
/// So every getter below is TWO checks, not one: the section must be on AND
/// the individual switch must be on. [_messages] and [_more] encode that, and
/// it is the single most likely thing to get wrong by calling
/// `isHasPermission` directly at a call site.
///
/// ─── FAIL-CLOSED ─────────────────────────────────────────────────────
/// `isHasPermission` returns false when the module is not accessible, when the
/// key is missing from the Firestore permission document, or when the role
/// could not be loaded. Every getter inherits that, and the `Get.find` is
/// guarded so a call before the controller is registered denies rather than
/// throws — messaging is reachable from a notification deep link, which is
/// exactly that window.

import 'dart:developer';

import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/messages/messages_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/messages/messages_sections_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/messages/more_permissions_enum.dart';

/// Static-only. Nothing here holds state; see the FILE INFO note.
abstract final class MessagesAccess {
  const MessagesAccess._();

  /// Function Name: [_can]
  ///
  /// Purpose: The one call every getter below funnels through.
  ///
  /// Returns: false rather than throwing when
  ///          [MainCoreEmployeeController] is not registered.
  static bool _can({
    required ModulePermissionsSections section,
    required ModulePermissionsSectionsPermission? permission,
  }) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return false;
    return Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.messages,
      section: section,
      permission: permission,
    );
  }

  // ── Section master toggles ────────────────────────────────────────────────

  /// The left column's master toggle. False denies everything in
  /// [MessagesPermissions] regardless of the individual switches.
  static bool get canUseMessagesPermissions =>
      _sectionOn(MessagesPermissionsSections.messagesPermissions);

  /// The right column's master toggle. Same rule for
  /// [MoreMessagesPermissions].
  static bool get canUseMorePermissions =>
      _sectionOn(MessagesPermissionsSections.morePermissions);

  /// FIXED 21/9/2026 — "Create Group does nothing, but it IS on in the role".
  ///
  /// A master toggle now blocks only when the role EXPLICITLY stores it as
  /// false. Roles whose permission document has no `Messages_Permissions` /
  /// `More_Permissions` key at all (saved before the section keys existed,
  /// or built from the module defaults) read as "off" through
  /// `isHasPermission(permission: null)`, which denied every Messages ability
  /// even though Role Management shows the switches on. Turning a section off
  /// in Role Management writes `false` for the section AND clears its
  /// switches (RoleCubit.toggleSectionPermissionState), so the explicit-false
  /// rule keeps the master toggle meaning exactly what the admin set.
  /// The Messages permission map this session holds — for denial logs.
  static Map<String, bool> get storedForDebug =>
      Get.isRegistered<MainCoreEmployeeController>()
          ? Get.find<MainCoreEmployeeController>()
              .getModulePermissions(Modules.messages)
          : const <String, bool>{};

  static bool _sectionOn(MessagesPermissionsSections section) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return false;
    final MainCoreEmployeeController c = Get.find<MainCoreEmployeeController>();
    if (!c.hasModuleAccess(Modules.messages)) return false;
    final Map<String, bool> stored = c.getModulePermissions(Modules.messages);
    final bool? value = stored[section.getDataBaseName];
    if (value == null) {
      log('[MessagesPermissions] section ${section.getDataBaseName} not stored '
          'on this role — treated as on');
      return true;
    }
    return value;
  }

  /// ⚠️ Section AND switch, never just the switch. See the MASTER TOGGLES note.
  static bool _messages(MessagesPermissions permission) =>
      canUseMessagesPermissions &&
      _can(
        section: MessagesPermissionsSections.messagesPermissions,
        permission: permission,
      );

  /// ⚠️ Section AND switch. See [_messages].
  static bool _more(MoreMessagesPermissions permission) =>
      canUseMorePermissions &&
      _can(
        section: MessagesPermissionsSections.morePermissions,
        permission: permission,
      );

  // ── Messages Permissions (left column) ────────────────────────────────────

  /// Whether the "New Group" entry point is offered at all.
  static bool get canCreateGroup =>
      _messages(MessagesPermissions.createGroup);

  /// Read receipts — the double tick and the "Seen by" list.
  ///
  /// A privacy control as much as a permission: off means this member does not
  /// get to see who has read their message.
  static bool get canSeeSeenAndUnseen =>
      _messages(MessagesPermissions.seenAndUnseen);

  /// Editing a message ALREADY SENT. Nothing to do with composing.
  static bool get canEditMessage =>
      _messages(MessagesPermissions.editMessage);

  static bool get canDeleteMessage =>
      _messages(MessagesPermissions.deleteMessage);

  /// Adding an emoji reaction to a message.
  static bool get canReact => _messages(MessagesPermissions.reactions);

  static bool get canForwardMessages =>
      _messages(MessagesPermissions.forwardMessages);

  // ── More Permissions (right column) ───────────────────────────────────────

  /// Sharing a contact card.
  static bool get canSendContact => _more(MoreMessagesPermissions.contact);

  /// Sharing a location pin.
  static bool get canSendLocation => _more(MoreMessagesPermissions.location);

  /// Sending an image, from the camera or the gallery.
  static bool get canSendPhoto => _more(MoreMessagesPermissions.photo);

  /// Sending a file that is not an image.
  static bool get canSendDocuments =>
      _more(MoreMessagesPermissions.documents);

  /// Creating a poll. Voting in someone else's poll is NOT gated by this —
  /// the design offers one switch, and it names creation.
  static bool get canCreatePoll => _more(MoreMessagesPermissions.poll);

  /// Muting a conversation's notifications.
  static bool get canMuteNotifications =>
      _more(MoreMessagesPermissions.muteNotifications);

  /// Turning on disappearing messages for a conversation.
  static bool get canUseDisappearingMessages =>
      _more(MoreMessagesPermissions.disappearingMessages);

  /// Scheduling a message to send later.
  static bool get canScheduleMessages =>
      _more(MoreMessagesPermissions.scheduleMessages);

  // ── Convenience ───────────────────────────────────────────────────────────

  /// Whether ANY attachment type is allowed.
  ///
  /// The attachment menu is a sheet of options; with all four off it would
  /// open empty, which reads as a broken button rather than a withheld
  /// permission. Call sites hide the paperclip entirely instead.
  ///
  /// [canCreatePoll] is deliberately NOT part of this — a poll is composed,
  /// not attached, and the design lists it separately.
  static bool get canSendAnyAttachment =>
      canSendPhoto ||
      canSendDocuments ||
      canSendContact ||
      canSendLocation;
}
