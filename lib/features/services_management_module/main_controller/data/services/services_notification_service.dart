/// ************************* FILE INFO ************************* ///
/// File Name: services_notification_service.dart
/// Purpose: ALL notifications sent by the Services Management module
///          live here, as intent-named methods. UI pages, widgets and
///          cubits must NOT build NotificationModelSystem or call
///          FirestoreNotificationService / NotificationServiceApp
///          directly — they call this service.
/// Pattern: One `<module>_notification_service.dart` per module
///          (matches role_management_notification_service.dart).
///          All methods delegate to the shared AppNotificationSender.
///
/// ⚠️ REFERENCE IMPLEMENTATION — copy this shape for other modules.
/// Nothing here is a raw string: the event comes from the module's event
/// enum, the landing page from its page enum, and every placeholder from
/// TemplateVariable. `sendEvent` asserts in debug builds that no
/// placeholder the template needs was forgotten.

import 'package:knowticed_plus/features/notification/domain/enums/services_module/services_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/services_module/services_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

class ServicesNotificationService {
  ServicesNotificationService._();

  /// A new request needs the approver's action.
  /// Template: services_needs_approval → page: ApprovalRequestCard
  static Future<bool> notifyApproverOfNewRequest({
    required String senderEmail,
    required String approverEmail,
    required String serviceName,
    required String requesterName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: ServicesNotificationEvent.needsApproval,
      pageKey: ServicesNotificationPage.approvalRequestCard.key,
      senderEmail: senderEmail,
      receiverEmail: approverEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
        TemplateVariable.requesterName: requesterName,
      },
    );
  }

  /// Confirmation to the requester that their request was submitted.
  /// Template: services_request_submitted → page: RequestServicesToggle
  static Future<bool> notifyRequesterOfSubmission({
    required String senderEmail,
    required String requesterEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: ServicesNotificationEvent.requestSubmitted,
      pageKey: ServicesNotificationPage.requestServicesToggle.key,
      senderEmail: senderEmail,
      receiverEmail: requesterEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
      },
    );
  }

  /// Tell the requester their request was approved or rejected.
  /// Template: services_request_approved / services_request_rejected
  static Future<bool> notifyRequesterOfDecision({
    required bool approved,
    required String approverEmail,
    required String requesterEmail,
    required String serviceName,
    required String approverName,
    required bool isArabic,
    String rejectionReason = '',
  }) {
    return AppNotificationSender.sendEvent(
      event: approved
          ? ServicesNotificationEvent.requestApproved
          : ServicesNotificationEvent.requestRejected,
      pageKey: ServicesNotificationPage.requestServicesToggle.key,
      senderEmail: approverEmail,
      receiverEmail: requesterEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
        TemplateVariable.approverName: approverName,
        TemplateVariable.rejectionReason: rejectionReason,
      },
    );
  }

  /// Tell the requester the request status changed by the employee
  /// (in progress / done).
  /// Template: services_request_in_progress / services_request_done
  static Future<bool> notifyRequesterOfProgress({
    required bool isDone,
    required String senderEmail,
    required String requesterEmail,
    required String serviceName,
    required bool isArabic,
    Map<TemplateVariable, String> extraVariables = const {},
  }) {
    return AppNotificationSender.sendEvent(
      event: isDone
          ? ServicesNotificationEvent.requestDone
          : ServicesNotificationEvent.requestInProgress,
      pageKey: ServicesNotificationPage.requestServicesToggle.key,
      senderEmail: senderEmail,
      receiverEmail: requesterEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
        ...extraVariables,
      },
    );
  }

  /// Tell the assigned provider a new request landed in their queue.
  /// Template: services_new_assignment_provider
  static Future<bool> notifyProviderOfAssignment({
    required String senderEmail,
    required String providerEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: ServicesNotificationEvent.newAssignmentProvider,
      pageKey: ServicesNotificationPage.serviceProviderDashboard.key,
      senderEmail: senderEmail,
      receiverEmail: providerEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
      },
    );
  }

  /// SLA escalation. `event` picks who is being warned and how urgently:
  /// requester (exceeded), manager (approaching / breached) or the
  /// provider (reminder).
  static Future<bool> notifyOfSla({
    required ServicesNotificationEvent event,
    required String senderEmail,
    required String receiverEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    assert(
      const {
        ServicesNotificationEvent.requestSlaExceed,
        ServicesNotificationEvent.slaApproachingManager,
        ServicesNotificationEvent.slaBreachedManager,
        ServicesNotificationEvent.slaReminderProvider,
      }.contains(event),
      '${event.key} is not an SLA event',
    );
    return AppNotificationSender.sendEvent(
      event: event,
      pageKey: ServicesNotificationPage.requestServicesToggle.key,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
      },
    );
  }

  /// Nudge the approver that a request is still sitting unreviewed.
  ///
  /// Distinct from [notifyOfSla]: this fires on the review clock (the
  /// request has not been looked at), whereas the SLA events fire on the
  /// fulfilment clock (the request has not been finished).
  /// Template: services_review_reminder_manager → page: ApprovalRequestCard
  static Future<bool> notifyManagerOfPendingReview({
    required String senderEmail,
    required String managerEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: ServicesNotificationEvent.reviewReminderManager,
      pageKey: ServicesNotificationPage.approvalRequestCard.key,
      senderEmail: senderEmail,
      receiverEmail: managerEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
      },
    );
  }

  /// Tell the assigned provider a request was cancelled and can be dropped
  /// from their queue.
  /// Template: services_request_cancelled → page: ServiceProviderDashboard
  static Future<bool> notifyProviderOfCancellation({
    required String senderEmail,
    required String providerEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: ServicesNotificationEvent.requestCancelled,
      pageKey: ServicesNotificationPage.serviceProviderDashboard.key,
      senderEmail: senderEmail,
      receiverEmail: providerEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
      },
    );
  }

  /// Ask the provider to close a request out once the work is done.
  ///
  /// The requester-facing counterpart is [notifyRequesterOfProgress] with
  /// `isDone: true`; this one is addressed to the provider and asks for a
  /// status update rather than announcing the outcome.
  /// Template: services_completion_confirmed_provider
  ///           → page: ServiceProviderDashboard
  static Future<bool> notifyProviderOfCompletion({
    required String senderEmail,
    required String providerEmail,
    required String serviceName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: ServicesNotificationEvent.completionConfirmedProvider,
      pageKey: ServicesNotificationPage.serviceProviderDashboard.key,
      senderEmail: senderEmail,
      receiverEmail: providerEmail,
      isArabic: isArabic,
      variables: {
        TemplateVariable.serviceName: serviceName,
      },
    );
  }
}
