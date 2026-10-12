/// Module: services_management_module
/// Description: Cubit owning I/O for the approvals list (ApprovalServices)
///              and the approval-request card (ApprovalRequestCard): the
///              per-state request counts scan, and the approve/reject
///              mutation (approval-cycle JSON patch + notification fan-out
///              to requester/provider/next-approver). All Firestore access
///              goes through CreateServicesRepository — the UI only calls
///              these methods and reacts to state.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, CreateServicesRepository, NotificationServiceApp,
///               FirestoreNotificationService, NotificationTemplateService
/// Revision History: Initial version — extracted from approval_request.dart's
///                    _fetchServiceStateCounts() and approval_request_card.dart's
///                    inline approve/reject handlers (audit fix item 2: move
///                    I/O out of s7 UI).
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';

import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/controller/approval_request_state.dart';

class ApprovalRequestCubit extends Cubit<ApprovalRequestState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;
  final NotificationTemplateService _templateService =
      NotificationTemplateService();

  ApprovalRequestCubit({required this.repository})
      : super(const ApprovalRequestCounts());

  /// Mirrors the approvals list's original `_fetchServiceStateCounts()`:
  /// scans every request-service doc where [approverEmail] appears in the
  /// approval cycle and buckets it into a final state, then emits the
  /// per-state counts.
  Future<void> fetchServiceStateCounts(String approverEmail) async {
    final targetEmail = approverEmail.trim().toLowerCase();
    if (targetEmail.isEmpty) {
      emit(const ApprovalRequestCounts());
      return;
    }

    final docs = await repository.getRequestServiceDocsForApprover(targetEmail);

    int total = 0,
        pending = 0,
        approved = 0,
        cancel = 0,
        done = 0,
        rejected = 0,
        inProgress = 0,
        branchSla = 0;

    List<List<String>> extract(dynamic cycle) {
      final states = <String>[];
      final emails = <String>[];

      if (cycle is List) {
        for (final item in cycle) {
          if (item is String) {
            try {
              final decoded = jsonDecode(item);
              if (decoded is List) {
                for (final emp in decoded) {
                  if (emp is Map) {
                    states.add((emp['state'] ?? '').toString().toLowerCase());
                    emails.add((emp['email'] ?? '').toString().toLowerCase());
                  }
                }
              }
            } catch (_) {
              // Malformed entry — skip and continue scanning.
            }
          } else if (item is Map) {
            states.add((item['state'] ?? '').toString().toLowerCase());
            emails.add((item['email'] ?? '').toString().toLowerCase());
          }
        }
      }

      return [states, emails];
    }

    for (final data in docs) {
      final pair = extract(data['approvalCycle']);
      final states = pair[0];
      final emails = pair[1];

      final hasEmail = emails.any((e) => e == targetEmail);
      if (!hasEmail) continue;

      String finalState = '';
      final stateField = (data['state'] ?? '').toString().toLowerCase();

      if (stateField == 'done') finalState = 'done';
      if (finalState.isEmpty && stateField == 'cancel') finalState = 'cancel';
      if (finalState.isEmpty &&
          ['inprogress', 'branchsla', 'breached sla'].contains(stateField)) {
        finalState = stateField;
      }

      if (finalState.isEmpty) {
        final filtered =
            states.where((s) => s.isNotEmpty && s != 'normal').toList();

        if (filtered.contains('cancel')) {
          finalState = 'cancel';
        } else if (filtered.contains('rejected')) {
          finalState = 'rejected';
        } else if (filtered.isNotEmpty &&
            filtered.every((s) => s == 'approved')) {
          finalState = 'approved';
        } else if (filtered.contains('pending')) {
          finalState = 'pending';
        }

        final idx = emails.indexOf(targetEmail);
        bool includeForMe = false;
        const finalized = [
          'approved',
          'rejected',
          'cancel',
          'inprogress',
          'branchsla',
          'breached sla',
          'done',
        ];

        if (finalized.contains(finalState)) {
          includeForMe = true;
        } else if (idx != -1) {
          includeForMe = true;
          for (int i = 0; i < idx; i++) {
            final prev = states[i];
            if (['rejected', 'cancel', 'pending', 'normal', ''].contains(prev)) {
              includeForMe = false;
              break;
            }
          }
        }

        if (!includeForMe) continue;
      } else {
        const finalized = [
          'approved',
          'rejected',
          'cancel',
          'inprogress',
          'branchsla',
          'breached sla',
          'done',
        ];
        if (!finalized.contains(finalState)) continue;
      }

      switch (finalState) {
        case 'done':
          done++;
          break;
        case 'approved':
          approved++;
          break;
        case 'pending':
          pending++;
          break;
        case 'rejected':
          rejected++;
          break;
        case 'inprogress':
          inProgress++;
          break;
        case 'branchsla':
        case 'breached sla':
          branchSla++;
          break;
        case 'cancel':
          cancel++;
          break;
      }

      if (['approved', 'pending', 'rejected', 'cancel'].contains(finalState)) {
        total++;
      }
    }

    emit(ApprovalRequestCounts(
      total: total,
      pending: pending,
      approved: approved,
      cancel: cancel,
      done: done,
      rejected: rejected,
      inProgress: inProgress,
      branchSla: branchSla,
    ));
  }

  /// Approves [firestoreDocId] on behalf of [approverEmail]. Patches the
  /// approval-cycle JSON blob, marks the doc `approved` if this was the last
  /// approver, then best-effort notifies the requester, the provider (if
  /// this was the last approval) and the next approver in the cycle.
  ///
  /// Returns true if the mutation succeeded (an approver entry was found and
  /// patched), false otherwise. Notification failures never surface as an
  /// error — the mutation itself already succeeded by that point.
  Future<bool> approve({
    required String firestoreDocId,
    required String approverEmail,
    required String comment,
    required String displayServiceName,
    required String displayRequesterName,
    required String? requesterEmail,
    required List<({String email, String? state})> approvalCycle,
  }) async {
    final docData = await repository.getRequestServiceDocById(firestoreDocId);
    if (docData == null) return false;

    final approvalCycleField =
        docData['approvalCycle'] ?? docData['Approval_Cycle'];
    if (approvalCycleField == null) return false;

    final approvalCycleArray =
        approvalCycleField is List ? approvalCycleField : [approvalCycleField];

    final patched = _patchApprovalCycle(
      approvalCycleArray,
      approverEmail: approverEmail,
      newState: 'approved',
    );
    if (!patched.updated) return false;

    final myIndex = approvalCycle.indexWhere(
      (e) => e.email.toLowerCase() == approverEmail.toLowerCase(),
    );
    final isLastApprover = myIndex == approvalCycle.length - 1;

    final Map<String, dynamic> updateData = {
      'approveComment': comment,
      'timestamps': FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
    };
    if (docData.containsKey('approvalCycle')) {
      updateData['approvalCycle'] = patched.array;
    }
    if (docData.containsKey('Approval_Cycle')) {
      updateData['Approval_Cycle'] = patched.array;
    }
    if (isLastApprover) {
      updateData['state'] = FieldValue.arrayUnion(['approved']);
    }

    await repository.updateRequestServiceDoc(firestoreDocId, updateData);

    if (requesterEmail != null && requesterEmail.isNotEmpty) {
      await _sendNotificationToRequester(
        action: 'approved',
        requesterEmail: requesterEmail,
        serviceName: displayServiceName,
        approverEmail: approverEmail,
      );
    }

    if (isLastApprover) {
      final providerEmail = _extractProviderEmail(docData);
      if (providerEmail != null && providerEmail.isNotEmpty) {
        await _sendNotificationToProvider(
          action: 'approved',
          providerEmail: providerEmail,
          serviceName: displayServiceName,
          requesterName: displayRequesterName,
        );
      }
    }

    if (!isLastApprover && myIndex + 1 < approvalCycle.length) {
      final nextApproverEmail = approvalCycle[myIndex + 1].email;
      if (nextApproverEmail.isNotEmpty) {
        await _sendNotificationToNextApprover(
          nextApproverEmail: nextApproverEmail,
          serviceName: displayServiceName,
          requesterName: displayRequesterName,
        );
      }
    }

    return true;
  }

  /// Rejects [firestoreDocId] on behalf of [approverEmail]. Mirrors
  /// [approve] but marks the entry `rejected` and always finalizes the doc
  /// state (rejection ends the cycle regardless of position).
  Future<bool> reject({
    required String firestoreDocId,
    required String approverEmail,
    required String comment,
    required String displayServiceName,
    required String displayRequesterName,
    required String? requesterEmail,
  }) async {
    final docData = await repository.getRequestServiceDocById(firestoreDocId);
    if (docData == null) return false;

    final approvalCycleField =
        docData['approvalCycle'] ?? docData['Approval_Cycle'];
    final approvalCycleArray =
        (approvalCycleField is List ? approvalCycleField : <dynamic>[]);

    final patched = _patchApprovalCycle(
      approvalCycleArray,
      approverEmail: approverEmail,
      newState: 'rejected',
    );
    if (!patched.updated) return false;

    final Map<String, dynamic> updateData = {
      'rejectComment': comment,
      'timestamps': FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
      'state': FieldValue.arrayUnion(['rejected']),
    };
    if (docData.containsKey('approvalCycle')) {
      updateData['approvalCycle'] = patched.array;
    }
    if (docData.containsKey('Approval_Cycle')) {
      updateData['Approval_Cycle'] = patched.array;
    }

    await repository.updateRequestServiceDoc(firestoreDocId, updateData);

    if (requesterEmail != null && requesterEmail.isNotEmpty) {
      await _sendNotificationToRequester(
        action: 'rejected',
        requesterEmail: requesterEmail,
        serviceName: displayServiceName,
        approverEmail: approverEmail,
      );
    }

    final providerEmail = _extractProviderEmail(docData);
    if (providerEmail != null && providerEmail.isNotEmpty) {
      await _sendNotificationToProvider(
        action: 'rejected',
        providerEmail: providerEmail,
        serviceName: displayServiceName,
        requesterName: displayRequesterName,
      );
    }

    return true;
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

  String? _extractProviderEmail(Map<String, dynamic> docData) {
    try {
      final providerServices =
          docData['providerServices'] ?? docData['Provider_Services'];
      if (providerServices == null) return null;
      if (providerServices is List && providerServices.isEmpty) return null;

      final firstProvider =
          providerServices is List ? providerServices.first : providerServices;

      if (firstProvider is String) {
        final decoded = jsonDecode(firstProvider);
        if (decoded is List && decoded.isNotEmpty) {
          final provider = decoded.first;
          if (provider is Map && provider['email'] != null) {
            return provider['email'].toString();
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

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
      if (template == null || !template.isEnabled || !template.hasPush) return;

      String notificationTitle =
          isArabic ? template.subjectArabic : template.subjectEnglish;
      String notificationBody =
          isArabic ? template.bodyArabic : template.bodyEnglish;

      final variables = {
        'serviceName': serviceName,
        'approverName': approverName,
        'rejectionReason': '',
      };
      notificationTitle = _templateService.processTemplate(notificationTitle, variables);
      notificationBody = _templateService.processTemplate(notificationBody, variables);

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

  Future<void> _sendNotificationToProvider({
    required String action,
    required String providerEmail,
    required String serviceName,
    required String requesterName,
  }) async {
    if (providerEmail.isEmpty) return;

    try {
      final isArabic = await _getLanguagePreference(providerEmail);

      final eventType =
          action == 'approved' ? 'request_in_progress' : 'request_rejected';
      final template = await _templateService.getTemplate(
        module: 'services',
        eventType: eventType,
      );
      if (template == null || !template.isEnabled || !template.hasPush) return;

      String notificationTitle =
          isArabic ? template.subjectArabic : template.subjectEnglish;
      String notificationBody =
          isArabic ? template.bodyArabic : template.bodyEnglish;

      final variables = {
        'serviceName': serviceName,
        'requesterName': requesterName,
        'rejectionReason': '',
      };
      notificationTitle = _templateService.processTemplate(notificationTitle, variables);
      notificationBody = _templateService.processTemplate(notificationBody, variables);

      final notificationModel = NotificationModelSystem(
        title: notificationTitle,
        body: notificationBody,
        nameOfModule: 'services',
        senderEmail: '',
        receiverEmail: providerEmail,
        nameOfPage: 'ServiceProviderDashboard',
        isPinned: false,
        isRead: false,
        isClean: false,
      );

      final notificationService = FirestoreNotificationService();
      await notificationService.uploadNotification(notificationModel);

      await NotificationServiceApp.sendNotification(
        notificationTitle,
        notificationBody,
        providerEmail,
      );
    } catch (_) {
      // Best-effort notification.
    }
  }

  Future<void> _sendNotificationToNextApprover({
    required String nextApproverEmail,
    required String serviceName,
    required String requesterName,
  }) async {
    if (nextApproverEmail.isEmpty) return;

    try {
      final isArabic = await _getLanguagePreference(nextApproverEmail);

      final template = await _templateService.getTemplate(
        module: 'services',
        eventType: 'needs_approval',
      );
      if (template == null || !template.isEnabled || !template.hasPush) return;

      String notificationTitle =
          isArabic ? template.subjectArabic : template.subjectEnglish;
      String notificationBody =
          isArabic ? template.bodyArabic : template.bodyEnglish;

      final variables = {
        'serviceName': serviceName,
        'requesterName': requesterName,
      };
      notificationTitle = _templateService.processTemplate(notificationTitle, variables);
      notificationBody = _templateService.processTemplate(notificationBody, variables);

      final notificationModel = NotificationModelSystem(
        title: notificationTitle,
        body: notificationBody,
        nameOfModule: 'services',
        senderEmail: '',
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
}
