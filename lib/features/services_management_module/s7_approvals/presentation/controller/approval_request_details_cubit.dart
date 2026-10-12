/// Module: services_management_module
/// Description: Cubit owning all I/O for the approval-details page: loading
///              reject/approve/cancel comments, resolving the current doc
///              state, resolving requester info, resolving parent-service
///              name/description/duration/department from CreateServices,
///              and performing the approve/reject mutation (approval-cycle
///              JSON patch + notification fan-out). All Firestore access goes
///              through CreateServicesRepository — the page only calls these
///              methods and reacts to state.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, CreateServicesRepository, NotificationServiceApp,
///               FirestoreNotificationService, NotificationTemplateService,
///               CreateServicesHelper
/// Revision History: Initial version — extracted from ApprovalDetailsScreen
///                    and its logic_a/logic_b/body_actions/body_helpers part
///                    files (audit fix item 1: move I/O out of s7 UI).
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';

import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/controller/approval_request_details_state.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class ApprovalRequestDetailsCubit extends Cubit<ApprovalRequestDetailsState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;
  final ServicesHistoryModel approvalModel;
  final NotificationTemplateService _templateService =
      NotificationTemplateService();

  /// Department lookups are injected; no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  ApprovalRequestDetailsCubit({
    required this.departmentCubit,
    required this.repository,
    required this.approvalModel,
  }) : super(const ApprovalRequestDetailsLoading());

  ApprovalRequestDetailsData get _current {
    final s = state;
    if (s is ApprovalRequestDetailsLoaded) return s.data;
    if (s is ApprovalRequestDetailsSubmitting) return s.data;
    if (s is ApprovalRequestDetailsActionError) return s.data;
    return const ApprovalRequestDetailsData();
  }

  /// Mirrors the original page's `_initialize()` flow: loads reject/approve
  /// comments, cancel reason, current doc state, requester info and the
  /// parent-service details, in that order.
  Future<void> initialize() async {
    emit(const ApprovalRequestDetailsLoading());

    final docId = approvalModel.currentId;

    String rejectComment = '';
    String approveComment = '';
    String? cancelReason;
    String? currentState;

    if (docId != null && docId.isNotEmpty) {
      final docData = await repository.getRequestServiceDocById(docId);

      if (docData != null) {
        final rejectRaw = docData['rejectComment'];
        if (rejectRaw != null && rejectRaw.toString().isNotEmpty) {
          rejectComment = rejectRaw.toString();
        }

        final approveRaw = docData['approveComment'];
        if (approveRaw != null && approveRaw.toString().isNotEmpty) {
          approveComment = approveRaw.toString();
        }

        cancelReason = docData['canselComment']?.toString() ?? '';

        final stateValue = docData['state'];
        if (stateValue is List && stateValue.isNotEmpty) {
          currentState = stateValue.first?.toString().toLowerCase();
        } else if (stateValue is String) {
          currentState = stateValue.toLowerCase();
        } else {
          currentState = stateValue?.toString().toLowerCase();
        }
      }
    }

    emit(ApprovalRequestDetailsLoaded(_current.copyWith(
      rejectCommentText: rejectComment,
      approveCommentText: approveComment,
      cancelReason: cancelReason,
      currentState: currentState,
    )));

    await loadRequesterInfo();
    await loadServiceDataFromCreateServices();
  }

  /// Resolves requester first/last name, job title and department (both
  /// languages) directly from the request doc's stored fields.
  Future<void> loadRequesterInfo() async {
    final docId = approvalModel.currentId;
    if (docId == null || docId.isEmpty) return;

    final data = await repository.getRequestServiceDocById(docId);
    if (data == null) return;

    String extractString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) {
        return value[0]?.toString() ?? '';
      }
      return value.toString();
    }

    emit(ApprovalRequestDetailsLoaded(_current.copyWith(
      requesterFirstNameEn: extractString(data['firstNameRequester']),
      requesterLastNameEn: extractString(data['lastNameRequester']),
      requesterJobTitleEn: extractString(data['jobTitleRequester']),
      requesterDepartment: extractString(data['departmentRequester']),
      requesterFirstNameAr: extractString(data['firstNameRequesterArabic']),
      requesterLastNameAr: extractString(data['lastNameRequesterArabic']),
      requesterJobTitleAr: extractString(data['jobTitleRequesterArabic']),
    )));
  }

  /// Resolves the parent-service name/description/duration/department from
  /// CreateServices via the shared helper (already repository-backed).
  Future<void> loadServiceDataFromCreateServices() async {
    final parentServiceId = approvalModel.currentParentServiceId.isNotEmpty
        ? approvalModel.currentParentServiceId
        : (approvalModel.currentId ?? '');
    final requesterEmail = approvalModel.currentEmailRequester ?? '';

    final serviceData =
        await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
      parentServiceId: parentServiceId,
      emailRequester: requesterEmail,
    );

    emit(ApprovalRequestDetailsLoaded(_current.copyWith(
      serviceNameEnglish: serviceData['serviceNameEnglish'],
      serviceNameArabic: serviceData['serviceNameArabic'],
      serviceDescriptionEnglish: serviceData['serviceDescriptionEnglish'],
      serviceDescriptionArabic: serviceData['serviceDescriptionArabic'],
      serviceDuration: serviceData['duration'],
      serviceDurationUnit: serviceData['unit'],
      owningDepartment: serviceData['owningDepartment'],
    )));
  }

  /// Refreshes `currentState` and the requester-independent doc fields from
  /// Firestore — used after external mutations (e.g. provider assignment).
  Future<ServicesHistoryModel?> refreshModelFromFirestore() async {
    final docId = approvalModel.currentId;
    if (docId == null || docId.isEmpty) return null;

    final data = await repository.getRequestServiceDocById(docId);
    if (data == null) return null;

    return ServicesHistoryModel.fromJson(data, docId);
  }

  /// Approves the request on behalf of [approverEmail]: patches the
  /// approval-cycle JSON blob, marks the doc `approved` if this was the last
  /// approver, then best-effort notifies the requester / provider / next
  /// approver.
  Future<bool> approve({
    required String approverEmail,
    required String comment,
    required String displayServiceName,
    required String displayRequesterName,
  }) async {
    final before = _current;
    emit(ApprovalRequestDetailsSubmitting(before));

    try {
      final docId = approvalModel.currentId;
      if (docId == null || docId.isEmpty) {
        emit(ApprovalRequestDetailsLoaded(before));
        return false; // B2 FIX: signal failure so no false success dialog
      }

      final docData = await repository.getRequestServiceDocById(docId);
      if (docData == null) {
        emit(ApprovalRequestDetailsLoaded(before));
        return false; // B2 FIX: signal failure so no false success dialog
      }

      final approvalCycleField =
          docData['Approval_Cycle'] ?? docData['approvalCycle'];
      if (approvalCycleField == null) {
        emit(ApprovalRequestDetailsLoaded(before));
        return false; // B2 FIX: signal failure so no false success dialog
      }

      final approvalCycleArray =
          approvalCycleField is List ? approvalCycleField : [approvalCycleField];

      final patched = _patchApprovalCycle(
        approvalCycleArray,
        approverEmail: approverEmail,
        newState: 'approved',
      );

      if (!patched.updated) {
        emit(ApprovalRequestDetailsLoaded(before));
        return false; // B2 FIX: signal failure so no false success dialog
      }

      final myIndex = approvalModel.currentApprovalCycle.indexWhere(
        (e) => (e.email ?? '').toLowerCase() == approverEmail.toLowerCase(),
      );
      final isLastApprover =
          myIndex == approvalModel.currentApprovalCycle.length - 1;

      final Map<String, dynamic> updateData = {
        'Approval_Cycle': patched.array,
        'approveComment': comment,
        'timestamps': _timestampArrayUnion(),
      };
      if (isLastApprover) {
        updateData['state'] = ['approved'];
      }

      await repository.updateRequestServiceDoc(docId, updateData);

      final requesterEmail = approvalModel.currentEmailRequester;
      if (requesterEmail != null && requesterEmail.isNotEmpty) {
        await _sendNotificationToRequester(
          action: 'approved',
          requesterEmail: requesterEmail,
          serviceName: displayServiceName,
          approverEmail: approverEmail,
          rejectionReason: '',
        );
      }

      if (!isLastApprover &&
          myIndex + 1 < approvalModel.currentApprovalCycle.length) {
        final nextApprover = approvalModel.currentApprovalCycle[myIndex + 1];
        final nextApproverEmail = nextApprover.email ?? '';
        if (nextApproverEmail.isNotEmpty) {
          await _sendNotificationToNextApprover(
            nextApproverEmail: nextApproverEmail,
            serviceName: displayServiceName,
            requesterName: displayRequesterName,
            approverEmail: approverEmail,
          );
        }
      }

      emit(ApprovalRequestDetailsLoaded(before.copyWith(
        currentState: isLastApprover ? 'approved' : before.currentState,
        approveCommentText: comment,
      )));
      return true;
    } catch (e) {
      emit(ApprovalRequestDetailsActionError(
        before,
        'Error approving request: $e',
      ));
      return false;
    }
  }

  /// Rejects the request on behalf of [approverEmail]: patches the
  /// approval-cycle JSON blob, marks the doc `rejected`, then best-effort
  /// notifies the requester.
  Future<bool> reject({
    required String approverEmail,
    required String comment,
    required String displayServiceName,
  }) async {
    final before = _current;
    emit(ApprovalRequestDetailsSubmitting(before));

    try {
      final docId = approvalModel.currentId;
      if (docId == null || docId.isEmpty) {
        emit(ApprovalRequestDetailsLoaded(before));
        return false; // B2 FIX: signal failure so no false success dialog
      }

      final docData = await repository.getRequestServiceDocById(docId);
      if (docData == null) {
        emit(ApprovalRequestDetailsLoaded(before));
        return false; // B2 FIX: signal failure so no false success dialog
      }

      // FIXED — reject() was reading the wrong field.
      //
      // The request document stores the approval cycle under `Approval_Cycle`
      // (ServicesHistoryModel.kApprovalCycle = 'Approval_Cycle'); every write
      // in the model uses that exact key, and approve() above reads it as
      // `docData['Approval_Cycle'] ?? docData['approvalCycle']`. This branch
      // read the lowercase `approvalCycle`, which never exists, so the array
      // was ALWAYS empty: `_patchApprovalCycle` matched nothing, `patched
      // .updated` was false, reject() returned false, and the rejection was
      // silently dropped — the request stayed `pending`, the doc kept the wrong
      // (lowercase) field, and the requester was never told it was rejected.
      // Now reads the canonical field exactly like approve().
      final approvalCycleField =
          docData['Approval_Cycle'] ?? docData['approvalCycle'];
      final approvalCycleArray = approvalCycleField is List
          ? approvalCycleField
          : (approvalCycleField == null
              ? const <dynamic>[]
              : [approvalCycleField]);

      final patched = _patchApprovalCycle(
        approvalCycleArray,
        approverEmail: approverEmail,
        newState: 'rejected',
      );

      if (!patched.updated) {
        emit(ApprovalRequestDetailsLoaded(before));
        return false; // B2 FIX: signal failure so no false success dialog
      }

      final Map<String, dynamic> updateData = {
        // Was 'approvalCycle' (lowercase) — the patched cycle would have landed
        // on a NEW field while the real `Approval_Cycle` stayed unchanged, so
        // the rejected state never persisted. Writes the canonical key now.
        'Approval_Cycle': patched.array,
        'rejectComment': comment,
        'timestamps': _timestampArrayUnion(),
        'state': _stateArrayUnion('rejected'),
      };

      await repository.updateRequestServiceDoc(docId, updateData);

      final requesterEmail = approvalModel.currentEmailRequester;
      if (requesterEmail != null && requesterEmail.isNotEmpty) {
        await _sendNotificationToRequester(
          action: 'rejected',
          requesterEmail: requesterEmail,
          serviceName: displayServiceName,
          approverEmail: approverEmail,
          rejectionReason: comment,
        );
      }

      emit(ApprovalRequestDetailsLoaded(before.copyWith(
        currentState: 'rejected',
        rejectCommentText: comment,
      )));
      return true;
    } catch (e) {
      emit(ApprovalRequestDetailsActionError(
        before,
        'Error rejecting request: $e',
      ));
      return false;
    }
  }

  ({bool updated, List<dynamic> array}) _patchApprovalCycle(
    List<dynamic> approvalCycleArray, {
    required String approverEmail,
    required String newState,
  }) {
    final array = List<dynamic>.from(approvalCycleArray);
    bool updated = false;

    for (int i = 0; i < array.length; i++) {
      final item = array[i];
      if (item is String) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is List) {
            for (final emp in decoded) {
              if (emp is Map &&
                  (emp['email']?.toString().toLowerCase() ==
                      approverEmail.toLowerCase())) {
                emp['state'] = newState;
                array[i] = jsonEncode(decoded);
                updated = true;
                break;
              }
            }
          }
        } catch (_) {
          // Malformed entry — skip and continue scanning.
        }
      }
      if (updated) break;
    }

    return (updated: updated, array: array);
  }

  FieldValue _timestampArrayUnion() =>
      FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]);

  FieldValue _stateArrayUnion(String value) =>
      FieldValue.arrayUnion([value]);

  Future<bool> _getLanguagePreference(String email) async {
    final data = await repository.getUserByEmail(email);
    final languageCode = data?['languageCode'] ?? 'en';
    return languageCode == 'ar';
  }

  Future<Map<String, String>> _getApproverName(String approverEmail) async {
    final data = await repository.getUserByEmail(approverEmail);
    if (data != null) {
      final firstNameEn = data['firstName'] ?? '';
      final lastNameEn = data['lastName'] ?? '';
      final firstNameAr = data['firstNameInArabic'] ?? firstNameEn;
      final lastNameAr = data['lastNameInArabic'] ?? lastNameEn;
      return {
        'en': '$firstNameEn $lastNameEn',
        'ar': '$firstNameAr $lastNameAr',
      };
    }
    return {'en': 'System', 'ar': 'النظام'};
  }

  Future<void> _sendNotificationToRequester({
    required String action,
    required String requesterEmail,
    required String serviceName,
    required String approverEmail,
    required String rejectionReason,
  }) async {
    if (requesterEmail.isEmpty) return;

    try {
      final isArabic = await _getLanguagePreference(requesterEmail);
      final approverNames = await _getApproverName(approverEmail);
      final approverName = isArabic ? approverNames['ar']! : approverNames['en']!;

      final eventType =
          action == 'approved' ? 'request_approved' : 'request_rejected';
      final template = await _templateService.getTemplate(
        module: 'services',
        eventType: eventType,
      );
      if (template == null || !template.isEnabled || !template.hasPush) {
        return;
      }

      String notificationTitle =
          isArabic ? template.subjectArabic : template.subjectEnglish;
      String notificationBody =
          isArabic ? template.bodyArabic : template.bodyEnglish;

      final variables = {
        'serviceName': serviceName,
        'approverName': approverName,
        'rejectionReason': rejectionReason,
      };
      notificationTitle =
          _templateService.processTemplate(notificationTitle, variables);
      notificationBody =
          _templateService.processTemplate(notificationBody, variables);

      final notificationModel = NotificationModelSystem(
        title: notificationTitle,
        body: notificationBody,
        nameOfModule: 'services',
        senderEmail: approverEmail,
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
      // Best-effort notification — the mutation itself already succeeded.
    }
  }

  Future<void> _sendNotificationToNextApprover({
    required String nextApproverEmail,
    required String serviceName,
    required String requesterName,
    required String approverEmail,
  }) async {
    if (nextApproverEmail.isEmpty) return;

    try {
      final isArabic = await _getLanguagePreference(nextApproverEmail);

      final template = await _templateService.getTemplate(
        module: 'services',
        eventType: 'needs_approval',
      );
      if (template == null || !template.isEnabled || !template.hasPush) {
        return;
      }

      String notificationTitle =
          isArabic ? template.subjectArabic : template.subjectEnglish;
      String notificationBody =
          isArabic ? template.bodyArabic : template.bodyEnglish;

      final variables = {
        'serviceName': serviceName,
        'requesterName': requesterName,
      };
      notificationTitle =
          _templateService.processTemplate(notificationTitle, variables);
      notificationBody =
          _templateService.processTemplate(notificationBody, variables);

      final notificationModel = NotificationModelSystem(
        title: notificationTitle,
        body: notificationBody,
        nameOfModule: 'services',
        senderEmail: approverEmail,
        receiverEmail: nextApproverEmail,
        nameOfPage: 'ApprovalRequestCard',
        isPinned: false,
        isRead: false,
        isClean: false,
      );

      final notificationService = FirestoreNotificationService();
      await notificationService.uploadNotification(notificationModel);

      await NotificationServiceApp.sendNotification(
        notificationTitle,
        notificationBody,
        nextApproverEmail,
      );
    } catch (_) {
      // Best-effort notification.
    }
  }

  /// Fetches the request doc's `RequestedServices` subcollection entry
  /// matching [serviceName] and returns its `id` field, or '' if not found.
  /// Mirrors the original page's `fetchAndPrintStates()` — kept for parity
  /// even though `saveIdUser` is not currently rendered by the page.
  Future<String> fetchRequestedServiceId(String? serviceName) async {
    final docId = approvalModel.currentId;
    if (docId == null || docId.isEmpty) return '';

    final entries = await repository.getRequestedServices(docId: docId);
    for (final entry in entries) {
      if (entry.serviceName == serviceName) {
        return entry.id ?? '';
      }
    }
    return '';
  }
}
