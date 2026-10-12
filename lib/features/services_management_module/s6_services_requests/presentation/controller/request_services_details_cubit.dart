// ******************* FILE INFO *******************
// File Name: request_services_details_cubit
// Description: Loads a service-request's provider details and submits the request.
// Module: services_management_module / s6_services_requests / controller
// *************************************************

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/request_services_details_state.dart';

class RequestServicesDetailsCubit extends Cubit<RequestServicesDetailsState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;

  RequestServicesDetailsCubit(this.repository)
      : super(RequestServicesDetailsInitial());

  static RequestServicesDetailsCubit get(context) => BlocProvider.of(context);

  Future<void> loadServiceDetails(String serviceId, List<EmployeeEntityModell> approvalCycle) async {

    try {
      emit(RequestServicesDetailsLoading());

      final providerData = await _fetchServiceProvider(serviceId);

      if (providerData != null) {

        // Check for provider services field

        // Check for provider field

        emit(RequestServicesDetailsLoaded(
          providerData: providerData,
          approvalCycle: approvalCycle,
        ));
      } else {
        emit(RequestServicesDetailsError('No provider data found'));
      }

    } catch (e, stackTrace) {
      emit(RequestServicesDetailsError(e.toString()));
    }
  }

  // Delegates to the repository — the cubit never touches Firestore directly.
  Future<Map<String, dynamic>?> _fetchServiceProvider(String serviceId) {
    return repository.getServiceDocById(serviceId);
  }

  Future<List<EmployeeEntityModell>> fetchAndProcessApprovalCycle(
      String serviceId, List<EmployeeEntityModell> currentApprovalCycle) async {

    if (currentApprovalCycle.isNotEmpty) {
      for (var i = 0; i < currentApprovalCycle.length; i++) {
        final approver = currentApprovalCycle[i];
      }
    }

    return currentApprovalCycle;
  }

  ServicesHistoryModel buildUpdatedRequestModel(
      ServicesHistoryModel requestModel,
      List<EmployeeEntityModell> approvalList,
      SharedPreferences prefs) {
    final initialState = approvalList.isEmpty ? 'approved' : 'pending';

    return ServicesHistoryModel.createNew(
      parentServiceId: requestModel.currentId,
      id: requestModel.currentId,
      imageUrl: requestModel.currentImageUrl,
      serviceNameEnglish: requestModel.currentServiceNameEnglish,
      serviceNameArabic: requestModel.currentServiceNameArabic,
      serviceDescriptionEnglish: requestModel.currentServiceDescriptionEnglish,
      serviceDescriptionArabic: requestModel.currentServiceDescriptionArabic,
      durationOfServices: requestModel.currentDurationOfServices,
      selectedDurationUnit: requestModel.currentSelectedDurationUnit,
      durationOfServicesTimestamp: requestModel.currentDurationOfServicesTimestamp,
      providerServices: requestModel.currentProviderServices,
      selectDepartment: requestModel.currentSelectDepartment,
      approvalCycle: approvalList,
      slaOneControllerEnglish: requestModel.currentSlaOneControllerEnglish,
      slaTwoControllerEnglish: requestModel.currentSlaTwoControllerEnglish,
      notifyRequesterChecked: requestModel.currentNotifyRequesterChecked,
      notifyProviderChecked: requestModel.currentNotifyProviderChecked,
      notifyManagerChecked: requestModel.currentNotifyManagerChecked,
      notifyRequesterSwitch0: requestModel.currentNotifyRequesterSwitch0,
      notifyManagerSwitch1: requestModel.currentNotifyManagerSwitch1,
      departmentRequester: prefs.getString("departmentRequester") ?? '',
      emailRequester: prefs.getString("emailRequester") ?? '',
      firstNameRequester: prefs.getString("firstNameRequester") ?? '',
      lastNameRequester: prefs.getString("lastNameRequester") ?? '',
      genderRequester: prefs.getString("genderRequester") ?? '',
      phoneRequester: prefs.getString("phoneRequester") ?? '',
      jobTitleRequester: prefs.getString("jobTitleRequester") ?? '',
      firstNameRequesterArabic: prefs.getString("firstNameRequesterArabic") ?? '',
      lastNameRequesterArabic: prefs.getString("lastNameRequesterArabic") ?? '',
      jobTitleRequesterArabic: prefs.getString("jobTitleRequesterArabic") ?? '',
      departmentRequesterArabic: prefs.getString("departmentRequesterArabic") ?? '',
      state: initialState,
      status: 'active',
      limitAvailability: requestModel.currentLimitAvailability,
      requireApproval: requestModel.currentRequireApproval,
    );
  }

  RequestedServices buildServicesRequestedModel(ServicesHistoryModel updatedRequest, String formatDate) {
    return RequestedServices(
      department: updatedRequest.currentSelectDepartment,
      id: updatedRequest.currentId,
      requestDate: formatDate,
      duration: updatedRequest.currentDurationOfServices,
      selectedDurationUnit: updatedRequest.currentSelectedDurationUnit,
      serviceName: updatedRequest.currentServiceNameEnglish,
      serviceProvider: updatedRequest.currentProviderServices,
      serviceRequester: "Amro Handousa",
      status: "Active",
      state: "pending",
    );
  }

  Future<void> processServiceRequest({
    required context,
    required String docId,
    required ServicesHistoryModel requestModel,
    required String employeeEmail,
    required bool isArabic,
  }) async {
    try {
      emit(RequestServicesDetailsProcessing());

      final approvalList = await fetchAndProcessApprovalCycle(
          requestModel.currentId, requestModel.currentApprovalCycle);
      final prefs = await SharedPreferences.getInstance();

      final updatedRequest = buildUpdatedRequestModel(requestModel, approvalList, prefs);

      final dateTime = Timestamp.now().toDate();
      final formatDate = DateFormat("MMMdd_yyyy").format(dateTime);
      final servicesRequestedModel = buildServicesRequestedModel(updatedRequest, formatDate);

      await ServicesManagerCubit.get(context).uploadRequestServices(docId, updatedRequest);

      await ServicesManagerCubit.get(context).getMyRequestServices();
      await ServicesManagerCubit.get(context).getMyApprovalServices(employeeEmail);

      await _sendNotificationToRequester(
        prefs: prefs,
        requestModel: requestModel,
        isArabic: isArabic,
        employeeEmail: employeeEmail,
      );

      emit(RequestServicesDetailsSuccess('Request submitted successfully'));
    } catch (e, st) {
      emit(RequestServicesDetailsError(e.toString()));
    }
  }

  Future<void> _sendNotificationToRequester({
    required SharedPreferences prefs,
    required ServicesHistoryModel requestModel,
    required bool isArabic,
    required String employeeEmail,
  }) async {
    final requesterEmail = prefs.getString("emailRequester") ?? '';

    final serviceNameForNotification = isArabic
        ? requestModel.currentServiceNameArabic
        : requestModel.currentServiceNameEnglish;

    if (requesterEmail.isNotEmpty) {
      try {
        final notificationTitle = isArabic
            ? "تم إرسال طلب الخدمة"
            : "Service Request Submitted";

        final notificationBody = isArabic
            ? "تم إرسال طلب الخدمة $serviceNameForNotification بنجاح، وهو قيد المعالجة حالياً."
            : "Your service request $serviceNameForNotification has been submitted successfully and is now being processed.";

        await NotificationServiceApp.sendNotification(
          notificationTitle,
          notificationBody,
          requesterEmail,
        );

        final notificationModel = NotificationModelSystem(
          title: notificationTitle,
          body: notificationBody,
          nameOfModule: 'services',
          senderEmail: employeeEmail,
          receiverEmail: requesterEmail,
          nameOfPage: 'RequestServicesToggle',
          isPinned: false,
          isRead: false,
          isClean: false,
        );

        final notificationService = FirestoreNotificationService();
        await notificationService.uploadNotification(notificationModel);

      } catch (notificationError) {
      }
    }
  }

  String generateDocId() {
    final random = Random().nextInt(100);
    final dateTime = Timestamp.now().toDate();
    final formatted = DateFormat("MMMdd_yyyy").format(dateTime);
    return "Request$random$formatted";
  }
}
