// ******************* FILE INFO *******************
// File Name: request_services_details_state
// Description: Request services details state.
// Module: services_management_module / presentation/s6_services_requests/controller
// *************************************************

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';

abstract class RequestServicesDetailsState {}

class RequestServicesDetailsInitial extends RequestServicesDetailsState {}

class RequestServicesDetailsLoading extends RequestServicesDetailsState {}

class RequestServicesDetailsLoaded extends RequestServicesDetailsState {
  final Map<String, dynamic> providerData;
  final List<EmployeeEntityModell> approvalCycle;

  RequestServicesDetailsLoaded({
    required this.providerData,
    required this.approvalCycle,
  });
}

class RequestServicesDetailsError extends RequestServicesDetailsState {
  final String message;

  RequestServicesDetailsError(this.message);
}

class RequestServicesDetailsProcessing extends RequestServicesDetailsState {}

class RequestServicesDetailsSuccess extends RequestServicesDetailsState {
  final String message;

  RequestServicesDetailsSuccess(this.message);
}
