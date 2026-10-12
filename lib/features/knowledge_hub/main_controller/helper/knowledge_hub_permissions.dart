/// Module: knowledge_hub / main_controller / helper
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_permissions.dart
/// Purpose: Every Knowledge Hub permission question, answered in one place.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// WHY THIS EXISTS. The module asked `isHasPermission` in about twenty places,
/// each restating the same five-line block with its own module / section /
/// permission triple. Two problems came out of that, and both were live bugs:
///
///   1. A PERMISSION ENFORCED IN ONE PLACE AND NOT ANOTHER.
///      `downloadDocuments` gated the Download button on k3 and nothing else,
///      so the same file downloaded fine from k5 and k7. `viewDocuments` gated
///      k3 and k5 but not k7. A role with Download switched OFF still
///      downloaded documents; the switch looked broken because it WAS broken.
///   2. TIERS CHECKED AS IF THEY WERE FLAGS. `approvedAndRejected` /
///      `approvedOnly` and `editDocumentWithApproval` /
///      `editDocumentWithoutApproval` are ORDERED PAIRS in the role editor,
///      not independent switches. Asking about one without the other is how
///      you end up offering Reject to someone who cannot Approve.
///
/// Everything here is a plain static getter over
/// [MainCoreEmployeeController.isHasPermission], which stays the single source
/// of truth — this file adds no caching and no state of its own, so it cannot
/// go stale against a role change the controller has already picked up.
///
/// FAIL-CLOSED, like the controller underneath it. `isHasPermission` returns
/// false when the module is not accessible, when the section key is missing
/// from the Firestore permission document, or when the role could not be
/// loaded at all. Every getter below inherits that, and the `Get.find` is
/// guarded so a call before the controller is registered denies rather than
/// throws.

import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/approval_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/submissions_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

/// How much a role may do with the approval queue.
///
/// The role editor draws these as an ordered pair, not two checkboxes, which
/// is why they are one enum here: "may reject but not approve" is a state the
/// editor cannot produce and this module should not invent.
enum ApprovalAccess {
  /// No approval actions at all. The buttons are not built.
  none,

  /// Approve only. Reject is not offered.
  approveOnly,

  /// Both Approve and Reject.
  approveAndReject;

  bool get canApprove => this != ApprovalAccess.none;

  bool get canReject => this == ApprovalAccess.approveAndReject;
}

/// How much a role may do with editing a document.
///
/// Same ordered-pair reasoning as [ApprovalAccess]. Note that
/// `editDocumentWithoutApproval` is the STRONGER of the two: it lets an edit
/// go live without a supervisor, and it therefore implies the weaker right to
/// edit at all. `creating_knowledge_hub.actions.dart` already relied on that
/// implication when it picked the resulting document status — this enum makes
/// it explicit rather than leaving it as a coincidence of two `if`s.
enum EditAccess {
  /// May not edit. The Edit button is not built.
  none,

  /// May edit; the result goes to `pending_approval` for a supervisor.
  withApproval,

  /// May edit; the result is published directly as `approved`.
  withoutApproval;

  bool get canEdit => this != EditAccess.none;

  /// True when a submission from this role skips the approval queue.
  ///
  /// This is the value `_getKnowledgeStatus` turns into `approved` vs
  /// `pending_approval`.
  bool get publishesDirectly => this == EditAccess.withoutApproval;
}

/// Static-only. Nothing here holds state; see the FILE INFO note.
abstract final class KnowledgeHubAccess {
  const KnowledgeHubAccess._();

  /// Function Name: [_can]
  ///
  /// Purpose: The one call every getter below funnels through.
  ///
  /// Parameters:
  /// - [section]: which block of the role editor the switch lives in.
  /// - [permission]: the switch itself, or null to test the SECTION toggle —
  ///   the section must implement `ModulePermissionsSectionsPermission` for
  ///   that to mean anything, which every section in this module does.
  ///
  /// Returns: false rather than throwing when [MainCoreEmployeeController] is
  ///          not registered. That happens on a deep link that lands in the
  ///          module before the shell has built, and a permission helper that
  ///          throws in that window would take down a screen instead of
  ///          hiding a button.
  static bool _can({
    required ModulePermissionsSections section,
    required ModulePermissionsSectionsPermission? permission,
  }) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return false;
    return Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.knowledgeHub,
      section: section,
      permission: permission,
    );
  }

  static bool _hubPermission(KnowledgeHubPermissions permission) => _can(
        section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
        permission: permission,
      );

  static bool _submissionsPermission(SubmissionsPermissions permission) => _can(
        section: KnowledgeHubPermissionsSections.submissions,
        permission: permission,
      );

  // CHANGED 28/9/2026 (Knowledge Hub bug report p.11 — "in pending status
  // where is approve or reject buttons"). `ApprovalPermissions.getDataBaseName`
  // is the SPACED name ("Approved And Rejected"), but the role editor writes
  // every switch through `_convertToDbFormat`, i.e. UNDERSCORED
  // ("Approved_And_Rejected") — the form every other knowledge-hub permission
  // enum already uses. The spaced lookup never matched, so `approvalAccess`
  // was always `none` and the Approve / Reject row never drew, whatever the
  // role said. Both spellings are accepted, so roles saved either way work.
  static bool _approvalPermission(ApprovalPermissions permission) {
    if (_can(
      section: KnowledgeHubPermissionsSections.approval,
      permission: permission,
    )) {
      return true;
    }
    if (!Get.isRegistered<MainCoreEmployeeController>()) return false;
    return Get.find<MainCoreEmployeeController>().hasSpecificPermission(
      Modules.knowledgeHub,
      permission.getDataBaseName.trim().replaceAll(RegExp(r'\s+'), '_'),
    );
  }

  // ── Section-level toggles ─────────────────────────────────────────────────
  //
  // `permission: null` asks about the section's own switch rather than one of
  // the permissions inside it. k2 uses these to decide which nav buttons to
  // draw.

  /// The module's main section. False hides the document list entirely.
  static bool get canUseKnowledgeHub => _can(
        section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
        permission: null,
      );

  static bool get canOpenSubmissions => _can(
        section: KnowledgeHubPermissionsSections.submissions,
        permission: null,
      );

  static bool get canOpenApprovals => _can(
        section: KnowledgeHubPermissionsSections.approval,
        permission: null,
      );

  static bool get canOpenDashboard => _can(
        section: KnowledgeHubPermissionsSections.dashboard,
        permission: null,
      );

  // ── Knowledge Hub permissions ─────────────────────────────────────────────

  static bool get canCreate =>
      _hubPermission(KnowledgeHubPermissions.createKnowledgeHub);

  static bool get canSelectOwningDepartment =>
      _hubPermission(KnowledgeHubPermissions.selectOwningDepartment);

  static bool get canDownload =>
      _hubPermission(KnowledgeHubPermissions.downloadDocuments);

  static bool get canView =>
      _hubPermission(KnowledgeHubPermissions.viewDocuments);

  static bool get canSeeAnalytics =>
      _hubPermission(KnowledgeHubPermissions.analytics);

  static bool get canSeeStatistics =>
      _hubPermission(KnowledgeHubPermissions.statistics);

  static bool get canUseComments =>
      _hubPermission(KnowledgeHubPermissions.inquiriesAndComments);

  // ── Submissions permissions ───────────────────────────────────────────────

  static bool get canRemoveDocuments =>
      _submissionsPermission(SubmissionsPermissions.removeDocuments);

  static bool get canExportStatistics =>
      _submissionsPermission(SubmissionsPermissions.exportStatisticsTable);

  // ── Removing someone else's document ──────────────────────────────────────

  /// Whether this role may remove a document it does not own.
  ///
  /// ⚠️ This is a CONDITION ON another permission, not a control of its own.
  /// It never shows a button by itself — [canRemove] is what call sites want.
  ///
  /// NOTE the section. `allowsRemovingDocumentsOwnedByAnyone` exists BOTH as a
  /// `KnowledgeHubPermissions` value and as a `KnowledgeHubPermissionsSections`
  /// value, and both carry the same database name
  /// (`Allows_Removing_Documents_Owned_By_Anyone`), so both resolve to the same
  /// Firestore key. This asks the SECTION form because that is what
  /// `k3/.../build_action_buttons.dart` already asked — matching it keeps one
  /// behaviour rather than two spellings of the same question.
  static bool get canRemoveAnyonesDocument => _can(
        section:
            KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone,
        permission: null,
      );

  /// Function Name: [canRemove]
  ///
  /// Purpose: Whether the Remove button should be built for one document.
  ///
  /// Parameters:
  /// - [isCreator]: whether the signed-in employee created this document.
  ///
  /// A creator may always remove their own work. Removing someone ELSE'S needs
  /// [canRemoveAnyonesDocument] as well as [canRemoveDocuments] — the first
  /// says "not only your own", the second says "removing is a thing you do".
  static bool canRemove({required bool isCreator}) {
    if (!canRemoveDocuments) return false;
    return isCreator || canRemoveAnyonesDocument;
  }

  // ── Ordered pairs ─────────────────────────────────────────────────────────

  /// How much of the approval queue this role may act on.
  ///
  /// `approvedAndRejected` WINS over `approvedOnly`: it is the higher tier, so
  /// a role holding both gets both buttons rather than the narrower answer.
  static ApprovalAccess get approvalAccess {
    if (_approvalPermission(ApprovalPermissions.approvedAndRejected)) {
      return ApprovalAccess.approveAndReject;
    }
    if (_approvalPermission(ApprovalPermissions.approvedOnly)) {
      return ApprovalAccess.approveOnly;
    }
    return ApprovalAccess.none;
  }

  /// Whether a NEW document this role creates skips the approval queue.
  ///
  /// ADDED 22/9/2026. Creation had no permission of its own, so
  /// `_getKnowledgeStatus` answered this question with
  /// `editDocumentWithoutApproval` — the EDIT switch. Any role allowed to
  /// re-publish its own edits therefore also had every new document it created
  /// land in the supervisor's queue already marked `approved`, with no
  /// notification sent. `Create_Without_Need_Approval` is now the only switch
  /// that answers it.
  ///
  /// Deliberately NOT tiered with [editAccess]: they are independent rights,
  /// not an ordered pair, so holding one says nothing about the other.
  static bool get createsWithoutApproval => _submissionsPermission(
        SubmissionsPermissions.createWithoutNeedApproval,
      );

  /// How much this role may edit.
  ///
  /// `editDocumentWithoutApproval` WINS, for the reason on [EditAccess]: it is
  /// the stronger right and implies the weaker one.
  ///
  /// NOTE: this governs EDITING ONLY. For a new document see
  /// [createsWithoutApproval].
  static EditAccess get editAccess {
    if (_submissionsPermission(
        SubmissionsPermissions.editDocumentWithoutApproval)) {
      return EditAccess.withoutApproval;
    }
    if (_submissionsPermission(
        SubmissionsPermissions.editDocumentWithApproval)) {
      return EditAccess.withApproval;
    }
    return EditAccess.none;
  }
}
