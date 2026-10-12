/// Module: services_management_module
/// Description: Cubit owning all I/O for the "my request" details page:
///              loading reject/approve/cancel comments, resolving the
///              current doc state, resolving parent-service name/description/
///              duration, cancelling a request (with provider notification),
///              and refreshing service-state counts. All Firestore access
///              goes through CreateServicesRepository (via ServicesManagerCubit)
///              — the page only calls these methods and reacts to state.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, CreateServicesRepository, NotificationServiceApp,
///               FirestoreNotificationService, CreateServicesHelper
/// Revision History: Initial version — extracted from MyRequestDetails
///                    (audit fix #1/#3: split file + move I/O out of UI).

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';

import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/my_request_details_state.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class MyRequestDetailsCubit extends Cubit<MyRequestDetailsState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;
  final ServicesHistoryModel model;
  final String requesterEmail;

  /// Department lookups are injected; no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  MyRequestDetailsCubit({
    required this.departmentCubit,
    required this.repository,
    required this.model,
    required this.requesterEmail,
  }) : super(const MyRequestDetailsLoading());

  MyRequestDetailsData get _current {
    final s = state;
    if (s is MyRequestDetailsLoaded) return s.data;
    if (s is MyRequestDetailsCancelling) return s.data;
    if (s is MyRequestDetailsCancelError) return s.data;
    return const MyRequestDetailsData();
  }

  /// Loads reject/approve comments, cancel reason, and the doc's current
  /// state — mirrors the original page's `_initialize()` flow.
  Future<void> initialize() async {
    emit(const MyRequestDetailsLoading());

    final docData = await repository.getRequestServiceDocById(model.currentId);

    String? currentState;
    String? cancelReason;
    String rejectComment = '';
    String approveComment = '';

    if (docData != null) {
      final stateData = docData['state'];
      if (stateData is List && stateData.isNotEmpty) {
        currentState = stateData.last?.toString().toLowerCase();
      } else if (stateData is String) {
        currentState = stateData.toLowerCase();
      } else {
        currentState = stateData?.toString().toLowerCase();
      }

      cancelReason = docData['canselComment']?.toString() ?? '';

      final rejectRaw = docData['rejectComment'];
      if (rejectRaw != null && rejectRaw.toString().isNotEmpty) {
        rejectComment = rejectRaw.toString();
      }

      final approveRaw = docData['approveComment'];
      if (approveRaw != null && approveRaw.toString().isNotEmpty) {
        approveComment = approveRaw.toString();
      }
    }

    emit(MyRequestDetailsLoaded(_current.copyWith(
      currentState: currentState,
      cancelReason: cancelReason,
      rejectCommentText: rejectComment,
      approveCommentText: approveComment,
    )));

    await loadServiceDetailsFromCreateServices();
  }

  /// Resolves the parent-service name/description/duration, falling back to
  /// the request model's own fields when the parent service can't be found.
  Future<void> loadServiceDetailsFromCreateServices({bool isArabic = false}) async {
    final emailRequester = model.currentEmailRequester.isNotEmpty
        ? model.currentEmailRequester
        : '';
    final parentServiceId = model.currentParentServiceId;

    if (parentServiceId.isEmpty || emailRequester.isEmpty) {
      _emitFallbackServiceDetails(isArabic);
      return;
    }

    try {
      final result = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
        parentServiceId: parentServiceId,
        emailRequester: emailRequester,
      );

      final name = isArabic
          ? (result['Service_Name_Arabic'] != '-'
              ? result['Service_Name_Arabic']!
              : model.currentServiceNameArabic)
          : (result['Service_Name_English'] != '-'
              ? result['Service_Name_English']!
              : model.currentServiceNameEnglish);

      final description = isArabic
          ? (result['Service_Description_Arabic'] != '-'
              ? result['Service_Description_Arabic']!
              : (model.currentServiceDescriptionArabic ?? ''))
          : (result['Service_Description_English'] != '-'
              ? result['Service_Description_English']!
              : (model.currentServiceDescriptionEnglish ?? ''));

      final duration = result['duration']!;
      final unit = result['unit']!;
      final durationDisplay = (duration != '-' && unit != '-')
          ? '$duration $unit'
          : '${model.currentDurationOfServices} ${model.currentSelectedDurationUnit}';

      emit(MyRequestDetailsLoaded(_current.copyWith(
        serviceNameToDisplay: name,
        serviceDescriptionToDisplay: description,
        durationToDisplay: durationDisplay,
        isLoadingServiceDetails: false,
      )));
    } catch (e) {
      _emitFallbackServiceDetails(isArabic);
    }
  }

  void _emitFallbackServiceDetails(bool isArabic) {
    emit(MyRequestDetailsLoaded(_current.copyWith(
      serviceNameToDisplay: isArabic
          ? model.currentServiceNameArabic
          : model.currentServiceNameEnglish,
      serviceDescriptionToDisplay: isArabic
          ? (model.currentServiceDescriptionArabic ?? '')
          : (model.currentServiceDescriptionEnglish ?? ''),
      durationToDisplay:
          '${model.currentDurationOfServices} ${model.currentSelectedDurationUnit}',
      isLoadingServiceDetails: false,
    )));
  }

  Future<void> refreshServiceStateCounts() async {
    final counts = await repository.getMyRequestServicesByRequester(requesterEmail);

    int total = 0, pending = 0, approved = 0, cancel = 0, done = 0, rejected = 0, inProgress = 0, branchSla = 0;

    for (final m in counts) {
      total++;
      final s = m.currentState.toLowerCase().trim();
      switch (s) {
        case 'pending':
          pending++;
          break;
        case 'approved':
          approved++;
          break;
        case 'cancel':
          cancel++;
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
        case 'done':
          done++;
          break;
      }
    }

    emit(MyRequestDetailsLoaded(_current.copyWith(
      totalServices: total,
      pendingCount: pending,
      approvedCount: approved,
      cancelCount: cancel,
      rejectedCount: rejected,
      inProgressCount: inProgress,
      branchSlaCount: branchSla,
      doneCount: done,
    )));
  }

  /// Cancels the request: updates state/timestamps/comment, best-effort
  /// notifies the assigned provider, then refreshes counts.
  Future<bool> cancelRequest({
    required String cancellationReason,
    required String? providerEmail,
    required String serviceName,
    required String requesterName,
  }) async {
    final before = _current;
    emit(MyRequestDetailsCancelling(before));

    try {
      await repository.appendRequestState(
        serviceId: model.currentId,
        requesterEmail: requesterEmail,
        newState: 'cancel',
      );

      await repository.updateRequestServiceDoc(model.currentId, {
        'state': [ 'cancel' ],
        'canselComment': cancellationReason,
      });

      if (providerEmail != null && providerEmail.isNotEmpty) {
        await _sendCancellationNotificationToProvider(
          providerEmail: providerEmail,
          serviceName: serviceName,
          requesterName: requesterName,
          cancellationReason: cancellationReason,
        );
      }

      emit(MyRequestDetailsLoaded(before.copyWith(
        currentState: 'cancel',
        cancelReason: cancellationReason,
      )));

      await refreshServiceStateCounts();
      return true;
    } catch (e) {
      emit(MyRequestDetailsCancelError(before, 'Error cancelling request: $e'));
      return false;
    }
  }

  Future<bool> _getProviderLanguagePreference(String providerEmail) async {
    final data = await repository.getUserByEmail(providerEmail);
    final languageCode = data?['languageCode'] ?? 'en';
    return languageCode == 'ar';
  }

  Future<void> _sendCancellationNotificationToProvider({
    required String providerEmail,
    required String serviceName,
    required String requesterName,
    required String cancellationReason,
  }) async {
    try {
      final isArabic = await _getProviderLanguagePreference(providerEmail);

      final notificationTitle =
          isArabic ? 'تم إلغاء طلب الخدمة' : 'Service Request Cancelled';
      final notificationBody = isArabic
          ? "تم إلغاء طلب الخدمة '$serviceName' من قبل $requesterName.\nسبب الإلغاء: $cancellationReason"
          : "Service request '$serviceName' from $requesterName has been cancelled.\nReason: $cancellationReason";

      final notificationModel = NotificationModelSystem(
        title: notificationTitle,
        body: notificationBody,
        nameOfModule: 'services',
        senderEmail: requesterEmail,
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
    } catch (e) {
      // Best-effort notification — cancellation itself already succeeded.
    }
  }
}
