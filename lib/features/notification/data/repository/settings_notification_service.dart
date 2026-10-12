/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: settings_notification_service.dart
/// Purpose: Notifications raised by the Settings change-request flow —
///          Personal Information, Health Insurance and Emergency Contact
///          submitted / approved / rejected.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
/// Updated: 24/8/2026 - `changeRequestSubmitted` now resolves its own audience
///          and fans out; Emergency Contact became a kind of its own.
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// `settings_events.dart` has carried the change-request events since the
/// catalog was written, with bilingual titles and bodies, and the Notification
/// Control screen has been listing them for admins to edit. Nothing ever sent
/// one: there was no service between the catalog and `se6_requests`, so
/// approving or rejecting a request silently notified nobody. Same gap, same
/// shape of fix, as `UserManagementNotificationService`.
///
/// ─── AUDIENCE ────────────────────────────────────────────────────────
/// The submitted event addresses the REVIEWERS: every employee whose role
/// carries the Roles module and the `Users_Requests` permission — the same
/// three facts that decide whether the Requests button appears in
/// `user_management_home.dart`. [UserRequestsApproversRepository] answers that
/// question and falls back to the Master Admins when no role grants it, so a
/// pending request is never left with nobody to see it.
///
/// The approved and rejected events address the employee who raised the
/// request.
///
/// UPDATED 24/8/2026: `changeRequestSubmitted` used to take a single
/// `approverEmail`. No call site could supply one — nothing in the app knew who
/// the approver was — so the method had zero callers and the whole
/// submitted-to-reviewer half of the flow did not exist. The audience is now
/// resolved here rather than demanded from the caller.
///
/// ─── LANGUAGE ────────────────────────────────────────────────────────
/// `isArabic` defaults to false so call sites are explicit rather than
/// silently sending Arabic. Pass the RECEIVER's preference where you have it.
/// The reviewer fan-out sends one language to the whole batch, matching
/// `UserManagementNotificationService._toAdmins`.
library;

import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/settings_module/settings_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/settings_module/settings_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_requests_approvers_repository.dart';

/// Which settings section a change request came from.
///
/// The request document stores this as free text (`'Personal Information'`,
/// `'Health Insurance'`, `'Emergency Contact'`), so [fromSection] does the
/// matching in one place rather than leaving string comparisons at every call
/// site.
enum SettingsRequestKind {
  personalInformation,
  healthInsurance,
  emergencyContact;

  /// Function Name: [fromSection]
  ///
  /// Purpose: Map a stored `ChangeRequest.section` onto a kind.
  ///
  /// ADDED 24/8/2026: the emergency-contact branch. Before it, an
  /// `Emergency Contact` request fell through to [personalInformation] and the
  /// employee was told their *personal information* had been approved.
  ///
  /// Parameters:
  /// - [section]: The section string as written on the request.
  ///
  /// Returns: [SettingsRequestKind] — emergency contact or health insurance
  ///          when the text says so, personal information otherwise, which is
  ///          what every other section of the settings request flow is.
  static SettingsRequestKind fromSection(String section) {
    final String value = section.toLowerCase();
    if (value.contains('emergency')) {
      return SettingsRequestKind.emergencyContact;
    }
    if (value.contains('health') || value.contains('insurance')) {
      return SettingsRequestKind.healthInsurance;
    }
    return SettingsRequestKind.personalInformation;
  }

  /// The section string a new request of this kind is stored under.
  String get sectionName {
    switch (this) {
      case SettingsRequestKind.healthInsurance:
        return 'Health Insurance';
      case SettingsRequestKind.emergencyContact:
        return 'Emergency Contact';
      case SettingsRequestKind.personalInformation:
        return 'Personal Information';
    }
  }
}

class SettingsNotificationService {
  SettingsNotificationService._();

  static final UserRequestsApproversRepository _approvers =
      UserRequestsApproversRepository();

  /// Function Name: [changeRequestSubmitted]
  ///
  /// Purpose: Tell everyone who may review change requests that one is waiting.
  ///
  /// Trigger: raising a request from any settings edit flow.
  ///
  /// The audience is resolved here — see the AUDIENCE note at the top of this
  /// file. A submission must not fail because its notification did, so this
  /// never throws: an unresolvable audience simply sends nothing and returns 0.
  ///
  /// Parameters:
  /// - [section]: The request's section, as stored.
  /// - [employeeEmail]: Who raised it — the sender of this notification.
  /// - [employeeName]: Shown in the body.
  /// - [isArabic]: Language to send the batch in.
  ///
  /// Returns: [Future<int>] how many reviewers were notified.
  static Future<int> changeRequestSubmitted({
    required String section,
    required String employeeEmail,
    required String employeeName,
    bool isArabic = false,
  }) async {
    try {
      // CHANGED 9/10/2026 (owner decision) — every eligible reviewer EXCEPT
      // the submitter.
      //
      // The 25/8/2026 note that used to stand here kept the submitter on the
      // list because "whether someone needs to see a request is decided by
      // whether they have to act on it" — and at the time a reviewer could
      // approve their own request. That is now blocked (SelfApprovalRule: the
      // review screen hides Approve / Reject and RequestsRepository refuses
      // it), so the submitter no longer has anything to act on and the
      // "needs your action" notification would be wrong. The same test still
      // decides it; only the answer changed. The exclusion lives in
      // UserRequestsApproversRepository.approverEmails(requesterEmail:).
      final List<String> reviewers =
          await _approvers.approverEmails(requesterEmail: employeeEmail);

      if (reviewers.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[settings-notify] no reviewer resolved for "$section" — nobody '
            'holds Users_Requests and no Master Admin was found, so no '
            'submitted notification was sent.',
          );
        }
        return 0;
      }

      if (kDebugMode) {
        debugPrint(
          '[settings-notify] "$section" submitted by $employeeEmail → '
          'notifying ${reviewers.length} reviewer(s): ${reviewers.join(', ')}',
        );
      }

      final SettingsRequestKind kind = SettingsRequestKind.fromSection(section);

      return AppNotificationSender.sendEventToAll(
        event: _submittedEventFor(kind),
        pageKey: _reviewPageFor(kind),
        senderEmail: employeeEmail,
        receiverEmails: reviewers,
        isArabic: isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.employeeName: employeeName,
        },
      );
    } catch (e, stackTrace) {
      // Never rethrown — a submission must not fail because its notification
      // did. Recorded rather than swallowed silently: a fan-out that quietly
      // returns 0 is exactly the failure that is impossible to diagnose from
      // the UI, because the request itself still saves correctly.
      if (kDebugMode) {
        debugPrint('[settings-notify] fan-out failed: $e\n$stackTrace');
      }
      return 0;
    }
  }

  /// Function Name: [changeRequestApproved]
  ///
  /// Purpose: Tell the employee their change request was approved and applied.
  ///
  /// Trigger: the approve action on either request details screen.
  ///
  /// Parameters:
  /// - [section]: The request's section, as stored.
  /// - [employeeEmail]: Who raised the request — the receiver.
  /// - [approverEmail]: Who approved it — the sender.
  /// - [isArabic]: Language to send in.
  ///
  /// Returns: [Future<bool>] true when the notification was sent.
  static Future<bool> changeRequestApproved({
    required String section,
    required String employeeEmail,
    required String approverEmail,
    bool isArabic = false,
  }) {
    final SettingsRequestKind kind = SettingsRequestKind.fromSection(section);

    return AppNotificationSender.sendEvent(
      event: _approvedEventFor(kind),
      pageKey: SettingsNotificationPage.myRequestPage.key,
      senderEmail: approverEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
    );
  }

  /// Function Name: [changeRequestRejected]
  ///
  /// Purpose: Tell the employee their change request was rejected, and why.
  ///
  /// Trigger: the reject action on either request details screen.
  ///
  /// Every rejected template carries a `{{rejectionReason}}` placeholder, which
  /// `AppNotificationSender.sendEvent` asserts on — so [reason] is always
  /// supplied. Since 24/8/2026 the reject dialog collects a real reason; a
  /// caller with nothing to say still passes a placeholder rather than an empty
  /// string, so the sentence never trails off.
  ///
  /// Parameters:
  /// - [section]: The request's section, as stored.
  /// - [employeeEmail]: Who raised the request — the receiver.
  /// - [approverEmail]: Who rejected it — the sender.
  /// - [reason]: Why it was rejected.
  /// - [isArabic]: Language to send in.
  ///
  /// Returns: [Future<bool>] true when the notification was sent.
  static Future<bool> changeRequestRejected({
    required String section,
    required String employeeEmail,
    required String approverEmail,
    required String reason,
    bool isArabic = false,
  }) {
    final SettingsRequestKind kind = SettingsRequestKind.fromSection(section);
    final String trimmed = reason.trim();

    return AppNotificationSender.sendEvent(
      event: _rejectedEventFor(kind),
      pageKey: SettingsNotificationPage.myRequestPage.key,
      senderEmail: approverEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
      variables: <TemplateVariable, String>{
        TemplateVariable.rejectionReason: trimmed.isEmpty ? '-' : trimmed,
      },
    );
  }

  static SettingsNotificationEvent _submittedEventFor(SettingsRequestKind kind) {
    switch (kind) {
      case SettingsRequestKind.healthInsurance:
        return SettingsNotificationEvent
            .healthInsuranceChangeRequestSubmittedManager;
      case SettingsRequestKind.emergencyContact:
        return SettingsNotificationEvent
            .emergencyContactChangeRequestSubmittedManager;
      case SettingsRequestKind.personalInformation:
        return SettingsNotificationEvent
            .personalInformationChangeRequestSubmittedManager;
    }
  }

  static SettingsNotificationEvent _approvedEventFor(SettingsRequestKind kind) {
    switch (kind) {
      case SettingsRequestKind.healthInsurance:
        return SettingsNotificationEvent
            .healthInsuranceChangeRequestApprovedEmployee;
      case SettingsRequestKind.emergencyContact:
        return SettingsNotificationEvent
            .emergencyContactChangeRequestApprovedEmployee;
      case SettingsRequestKind.personalInformation:
        return SettingsNotificationEvent
            .personalInformationChangeRequestApprovedEmployee;
    }
  }

  static SettingsNotificationEvent _rejectedEventFor(SettingsRequestKind kind) {
    switch (kind) {
      case SettingsRequestKind.healthInsurance:
        return SettingsNotificationEvent
            .healthInsuranceChangeRequestRejectedEmployee;
      case SettingsRequestKind.emergencyContact:
        return SettingsNotificationEvent
            .emergencyContactChangeRequestRejectedEmployee;
      case SettingsRequestKind.personalInformation:
        return SettingsNotificationEvent
            .personalInformationChangeRequestRejectedEmployee;
    }
  }

  /// The reviewer-facing screen for a kind of request.
  ///
  /// Emergency contact shares the health-insurance preview screen: that is
  /// genuinely where its fields are edited and reviewed
  /// (`preview_health_changes_page.dart` owns the firstContact / secondContact
  /// controllers), so pointing it anywhere else would name a screen that does
  /// not show those fields.
  static String _reviewPageFor(SettingsRequestKind kind) {
    switch (kind) {
      case SettingsRequestKind.healthInsurance:
      case SettingsRequestKind.emergencyContact:
        return SettingsNotificationPage.previewHealthInsuranceChangesPage.key;
      case SettingsRequestKind.personalInformation:
        return SettingsNotificationPage.previewChangesPage.key;
    }
  }
}
