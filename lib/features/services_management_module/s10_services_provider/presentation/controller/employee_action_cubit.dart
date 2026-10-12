/// Module: services_management_module
/// Description: Cubit owning Firestore I/O for the s10 employee-action
///              screens: ensuring an auto-approved synthetic approval cycle
///              exists, updating a request's state (with requester
///              notification fan-out), and re-fetching the latest state
///              after a mutation. Mirrors s7's ApprovalRequestCubit pattern
///              of a cubit doing direct Firestore access where the shared
///              CreateServicesRepository doesn't already expose a matching
///              method (this screen resolves the parent request doc by
///              scanning `Email_Requester` array-contains + doc-id match,
///              same lookup shape as s10's ChatCubit).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, cloud_firestore, NotificationServiceApp,
///               FirestoreNotificationService, NotificationTemplateService,
///               employeeFunctionHelper (data/helper/csv_helper.dart)
/// Revision History: Initial version — extracted from
///                    s10_services_provider/ui/services_management_module/employee_details_services.dart
///                    (audit fix 1b): _ensureApprovalCycleExists,
///                    _fetchLatestStateFromFirestore, _updateStateInFirestore,
///                    _sendStatusChangeNotification.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/helper/csv_helper.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/employee_action_state.dart';

class EmployeeActionCubit extends Cubit<EmployeeActionState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final FirebaseFirestore firestore;
  final NotificationTemplateService templateService;

  EmployeeActionCubit({
    FirebaseFirestore? firestore,
    NotificationTemplateService? templateService,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        templateService = templateService ?? NotificationTemplateService(),
        super(const EmployeeActionIdle());

  CollectionReference<Map<String, dynamic>> get _requestServices => firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot));

  /// D02/D03/D01: read the requester's user doc via the shared repository
  /// (no Firestore, no 'users' literal, no try/catch in the page).
  Future<bool> getRequesterLanguagePreferenceIsArabic(
    ServicesManagerCubit servicesManagerCubit,
    String requesterEmail,
  ) async {
    final data =
        await servicesManagerCubit.repository.getUserByEmail(requesterEmail);
    return (data?['languageCode'] ?? 'en') == 'ar';
  }

  /// Ensures a synthetic auto-approved approval cycle exists on the request
  /// doc when it doesn't already have one and is approved/empty/pending.
  /// Returns the new state string ('approved') on success, or null if no
  /// update was needed / the lookup failed.
  Future<String?> ensureApprovalCycleExists({
    required String requestId,
    required String requesterEmail,
  }) async {
    emit(const EmployeeActionBusy());
    try {
      final syntheticApproval = EmployeeEntityModell(
        id: 'auto-approved',
        email: 'system@auto.approved',
        firstName: 'System',
        lastName: 'Auto Approval',
        title: 'System Process',
        state: 'approved',
        gender: 'system',
      );

      final querySnapshot = await _requestServices
          .where("Email_Requester", arrayContains: requesterEmail)
          .get();

      final doc = querySnapshot.docs.firstWhere(
        (doc) => doc.id == requestId,
        orElse: () => throw Exception("Document not found"),
      );

      await doc.reference.update({
        'approvalCycle': [syntheticApproval.toJson()],
        'state': ['approved'],
        'timestamps': [DateTime.now().millisecondsSinceEpoch],
      });

      emit(const EmployeeActionSuccess());
      return 'approved';
    } catch (e) {
      emit(EmployeeActionError('Error ensuring approval cycle: $e'));
      return null;
    }
  }

  /// Re-fetches the latest `state` field for [requestId] scoped to
  /// [requesterEmail]. Returns the lowercase state string, or null on
  /// failure / not found.
  Future<String?> fetchLatestState({
    required String requestId,
    required String requesterEmail,
  }) async {
    try {
      final querySnapshot = await _requestServices
          .where("Email_Requester", arrayContains: requesterEmail)
          .get();

      final docSnapshot = querySnapshot.docs.firstWhere(
        (doc) => doc.id == requestId,
        orElse: () => throw Exception("Document not found"),
      );

      final data = docSnapshot.data();
      final stateField = data['state'];

      if (stateField is List && stateField.isNotEmpty) {
        return stateField.last.toString().toLowerCase();
      } else if (stateField is String) {
        return stateField.toLowerCase();
      }
      return null;
    } catch (e) {
      emit(EmployeeActionError('Error fetching latest state: $e'));
      return null;
    }
  }

  /// Appends [newState] to the request doc's state/timestamps history,
  /// notifies the requester (if a template exists for the transition), and
  /// re-fetches the latest state. Returns the refreshed state string on
  /// success, or throws on failure (mirrors the original page's rethrow so
  /// the caller's confirmation-dialog flow can show its own error snackbar).
  Future<String?> updateStateInFirestore({
    required String requestId,
    required String requesterEmail,
    required String newState,
    required String serviceName,
    required bool isArabicRequester,
  }) async {
    emit(const EmployeeActionBusy());
    try {
      final querySnapshot = await _requestServices
          .where("Email_Requester", arrayContains: requesterEmail)
          .get();

      final docSnapshot = querySnapshot.docs.firstWhere(
        (doc) => doc.id == requestId,
        orElse: () => throw Exception("Document not found"),
      );

      final data = docSnapshot.data();
      final stateField = data['state'];

      Map<String, dynamic> updateData;
      if (stateField is List) {
        final currentStates = List<String>.from(stateField);
        final currentTimestamps = List<int>.from(data['timestamps'] ?? []);

        currentStates.add(newState.toLowerCase());
        currentTimestamps.add(DateTime.now().millisecondsSinceEpoch);

        updateData = {
          "state": currentStates,
          "timestamps": currentTimestamps,
        };
      } else {
        updateData = {
          "state": [newState.toLowerCase()],
          "timestamps": [DateTime.now().millisecondsSinceEpoch],
        };
      }

      await docSnapshot.reference.update(updateData);

      if (requesterEmail.isNotEmpty) {
        await _sendStatusChangeNotification(
          newState: newState.toLowerCase(),
          requesterEmail: requesterEmail,
          serviceName: serviceName,
          isArabicRequester: isArabicRequester,
        );
      }

      final refreshed = await fetchLatestState(
        requestId: requestId,
        requesterEmail: requesterEmail,
      );
      emit(const EmployeeActionSuccess());
      return refreshed;
    } catch (e) {
      emit(EmployeeActionError('Error updating state: $e'));
      rethrow;
    }
  }

  /// Sends a push notification (+ persists it) to the requester when the
  /// state transitions to in-progress/done and a matching template is
  /// enabled with push notifications on. Silently no-ops on any failure —
  /// notification delivery must never block the state-change flow.
  Future<void> _sendStatusChangeNotification({
    required String newState,
    required String requesterEmail,
    required String serviceName,
    required bool isArabicRequester,
  }) async {
    if (requesterEmail.isEmpty) return;

    try {
      String eventType;
      if (newState == 'inprogress') {
        eventType = 'request_in_progress';
      } else if (newState == 'done') {
        eventType = 'request_done';
      } else {
        return;
      }

      final template = await templateService.getTemplate(
        module: 'services',
        eventType: eventType,
      );

      if (template == null || !template.isEnabled || !template.hasPush) {
        return;
      }

      String notificationTitle =
          isArabicRequester ? template.subjectArabic : template.subjectEnglish;
      String notificationBody =
          isArabicRequester ? template.bodyArabic : template.bodyEnglish;

      final variables = {'serviceName': serviceName};
      notificationTitle =
          templateService.processTemplate(notificationTitle, variables);
      notificationBody =
          templateService.processTemplate(notificationBody, variables);

      final notificationModel = NotificationModelSystem(
        title: notificationTitle,
        body: notificationBody,
        nameOfModule: 'services',
        senderEmail: employeeFunctionHelper.email ?? '',
        receiverEmail: requesterEmail,
        nameOfPage: 'RequestServicesToggle',
        isPinned: false,
        isRead: false,
        isClean: false,
      );

      final notificationService = FirestoreNotificationService();
      await notificationService.uploadNotification(notificationModel);

      await NotificationServiceApp.sendNotification(
        notificationTitle,
        notificationBody,
        requesterEmail,
      );
    } catch (_) {
      // Don't stop the flow if notification fails.
    }
  }
}
