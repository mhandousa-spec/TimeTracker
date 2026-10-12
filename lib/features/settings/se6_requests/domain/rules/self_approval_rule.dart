/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: self_approval_rule.dart
/// Purpose: A change request is decided by ANOTHER employee — never by the
///          person who raised it (owner decision, 9/10/2026).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// A `Users_Requests` holder could open Roles → User Management → Requests,
/// find their own Health / Personal change and approve it, writing it straight
/// into their own `Employees_Info`. The same holder was also on the
/// "request waiting" notification for their own request.
///
/// The rule is checked in three places, all through this file:
///   1. the review screen hides Approve / Reject on an own request
///      (`umdr_methods2.dart`);
///   2. `RequestsRepository` checks it AGAIN against the STORED request
///      before approving or rejecting, and fails closed;
///   3. `UserRequestsApproversRepository.approverEmails` leaves the requester
///      off the reviewer notification ([withoutRequester]).
///
/// Emails are compared trimmed and lower-cased ([normalizeEmail]). The
/// employee id is compared too when both sides have one, so a requester whose
/// email changed after submitting is still recognised.
library;

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';

/// The outcome of [SelfApprovalRule.check].
enum SelfApprovalVerdict {
  /// Someone other than the requester is deciding.
  allowed,

  /// The decider IS the requester — blocked.
  ownRequest,

  /// Not enough is known to tell the two apart — blocked (fail closed).
  unverifiable;

  bool get isAllowed => this == SelfApprovalVerdict.allowed;
}

/// A decision refused by [SelfApprovalRule] (ADDED 9/10/2026).
///
/// Its [message] is already localized (EN/AR) and safe to show the user, which
/// is how `RequestsCubit` tells it apart from a raw Firestore error.
class SelfApprovalFailure extends FeatureFailure {
  const SelfApprovalFailure(super.message, {required this.verdict});

  final SelfApprovalVerdict verdict;
}

abstract final class SelfApprovalRule {
  /// The comparable form of an email: trimmed and lower-cased.
  static String normalizeEmail(String? email) =>
      (email ?? '').trim().toLowerCase();

  /// Function Name: [check]
  ///
  /// Purpose: May [deciderEmail] approve or reject a request raised by
  ///          [requesterEmail]?
  ///
  /// Fails closed: an unknown decider, or a request whose requester can be
  /// identified by neither email nor id, is [SelfApprovalVerdict.unverifiable].
  ///
  /// Parameters:
  /// - [requesterEmail] / [requesterId]: from the request document
  ///   (`employeeEmail` / `employeeId`).
  /// - [deciderEmail] / [deciderId]: the signed-in reviewer.
  ///
  /// Returns: [SelfApprovalVerdict].
  static SelfApprovalVerdict check({
    required String requesterEmail,
    required String deciderEmail,
    String requesterId = '',
    String deciderId = '',
  }) {
    final String requester = normalizeEmail(requesterEmail);
    final String decider = normalizeEmail(deciderEmail);
    final String requesterKey = requesterId.trim();
    final String deciderKey = deciderId.trim();

    if (decider.isEmpty) return SelfApprovalVerdict.unverifiable;

    if (requester.isNotEmpty && requester == decider) {
      return SelfApprovalVerdict.ownRequest;
    }
    if (requesterKey.isNotEmpty &&
        deciderKey.isNotEmpty &&
        requesterKey == deciderKey) {
      return SelfApprovalVerdict.ownRequest;
    }

    // No requester email to compare against: only an id match can clear it.
    if (requester.isEmpty &&
        (requesterKey.isEmpty || deciderKey.isEmpty)) {
      return SelfApprovalVerdict.unverifiable;
    }

    return SelfApprovalVerdict.allowed;
  }

  /// Whether [requesterEmail] and [currentUserEmail] are the same person —
  /// the review screen's "hide Approve / Reject" test.
  static bool isOwnRequest({
    required String requesterEmail,
    required String currentUserEmail,
  }) {
    final String requester = normalizeEmail(requesterEmail);
    return requester.isNotEmpty &&
        requester == normalizeEmail(currentUserEmail);
  }

  /// Whether moving a request to [status] is a reviewer's DECISION.
  ///
  /// Cancelling is the requester's own action, so it is not checked.
  static bool isDecision(RequestStatus status) =>
      status == RequestStatus.approved || status == RequestStatus.rejected;

  /// Function Name: [withoutRequester]
  ///
  /// Purpose: The reviewer list with the requester taken out — compared
  ///          trimmed and lower-cased, duplicates dropped, order kept.
  ///
  /// Parameters:
  /// - [emails]: every resolved reviewer.
  /// - [requesterEmail]: who raised the request; empty removes nobody.
  ///
  /// Returns: [List<String>] the reviewers to notify.
  static List<String> withoutRequester(
    Iterable<String> emails,
    String requesterEmail,
  ) {
    final String requester = normalizeEmail(requesterEmail);
    final Set<String> seen = <String>{};
    final List<String> kept = <String>[];

    for (final String email in emails) {
      final String key = normalizeEmail(email);
      if (key.isEmpty) continue;
      if (requester.isNotEmpty && key == requester) continue;
      if (!seen.add(key)) continue;
      kept.add(email.trim());
    }

    return kept;
  }
}
