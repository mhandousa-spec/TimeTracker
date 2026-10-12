// ******************* FILE INFO *******************
// File Name: services_manager_state
// Description: State definitions for ServicesManagerCubit.
// Module: services_management_module / presentation / controller
// *************************************************

part of 'services_manager_cubit.dart';

@immutable
sealed class ServicesManagerState {}

final class ServicesManagerInitial extends ServicesManagerState {}

////////////////////////////////////////////////////////////////////////////////////////
class ServicesManagerLoading extends ServicesManagerState {}

class ServicesManagerLoaded extends ServicesManagerState {
  final ServicesHistoryModel model;
  ServicesManagerLoaded(this.model);
}


class ServicesManagerSaving extends ServicesManagerState {}

class ServicesManagerSaved extends ServicesManagerState {
  final ServicesHistoryModel model;
  ServicesManagerSaved(this.model);
}

class ServicesManagerError extends ServicesManagerState {
  final String message;
  ServicesManagerError(this.message);
}


///////////////////////////////////////////////////////////////////////////////////////
class GetServiceLoading extends ServicesManagerState {}

class GetServiceLoaded extends ServicesManagerState {
  final List<ServicesHistoryModel> services;
  GetServiceLoaded(this.services);
}

class GetServiceError extends ServicesManagerState {
  final String message;
  GetServiceError(this.message);
}
///////////////////////////////////////////////////////////////////////////////////////
class ServicesManagerDeleting extends ServicesManagerState {}

class ServicesManagerDeleted extends ServicesManagerState {}

////////////////////////////////////////////////////////////////////////////////////////

class GetDocServiceLoading extends ServicesManagerState {}

class GetDocServiceLoaded extends ServicesManagerState {
  final ServicesHistoryModel service;
  GetDocServiceLoaded(this.service);
}

class GetDocServiceError extends ServicesManagerState {
  final String message;
  GetDocServiceError(this.message);
}

////////////////////////////////////////////////////////////////////////////////////////
class UploadServicesLoading extends ServicesManagerState {}

class UploadServicesSuccess extends ServicesManagerState {
  final ServicesHistoryModel model;
  UploadServicesSuccess(this.model);
}

class UploadServicesError extends ServicesManagerState {
  final String message;
  UploadServicesError(this.message);
}
////////////////////////////////////////////////////////////////////////////////////////


class GetMyRequestServicesLoading extends ServicesManagerState {}

class GetMyRequestServicesSuccess extends ServicesManagerState {
  final List<ServicesHistoryModel> model;
  GetMyRequestServicesSuccess(this.model);
}

class GetMyRequestServicesError extends ServicesManagerState {
  final String message;
  GetMyRequestServicesError(this.message);
}
////////////////////////////////////////////////////////////////////////////////////////

class DeleteMyRequestServicesLoading extends ServicesManagerState {}

class DeleteMyRequestServicesSuccess extends ServicesManagerState {}

class DeleteMyRequestServicesError extends ServicesManagerState {}

////////////////////////////////////////////////////////////////////////////////////////

class GetMyApprovalServicesLoading extends ServicesManagerState {}

class GetMyApprovalServicesSuccess extends ServicesManagerState {
  final List<ServicesHistoryModel> model;
  GetMyApprovalServicesSuccess(this.model);
}

class GetMyApprovalServicesError extends ServicesManagerState {
  final String message;
  GetMyApprovalServicesError(this.message);
}

////////////////////////////////////////////////////////////////////////////////////////

class StateApprovalLoading extends ServicesManagerState {}
class StateApprovalSuccess extends ServicesManagerState {
  final String message;
  StateApprovalSuccess(this.message);
}
class StateApprovalError extends ServicesManagerState {
  final String message;
  StateApprovalError(this.message);
}





////////////////////////////////////////////////////////////////////////////////////////


class ProviderServicesLoading extends ServicesManagerState {}

class ProviderServicesLoaded extends ServicesManagerState {
  final Map<String, Map<String, dynamic>> providers;
  ProviderServicesLoaded(this.providers);
}
class ProviderServicesError extends ServicesManagerState {
  final String message;

  ProviderServicesError(this.message);
}







////////////////////////////////////////////////////////////////////////////////////////



class RequestServiceLoading extends ServicesManagerState {}

class RequestServiceSuccess extends ServicesManagerState {}

class RequestServiceError extends ServicesManagerState {
  final String message;
  RequestServiceError(this.message);
}
////////////////////////////////////////////////////////////////////////////////////////

class GetRequestServiceLoading extends ServicesManagerState {}

class GetRequestServiceSuccess extends ServicesManagerState {}

class GetRequestServiceError extends ServicesManagerState {
  final String message;
  GetRequestServiceError(this.message);
}

////////////////////////////////////////////////////////////////////////////////////////


class StateStatisticsLoading extends ServicesManagerState {}

class StateStatisticsLoaded extends ServicesManagerState {
  final StateStatisticsModel statistics;

  StateStatisticsLoaded(this.statistics);
}

class StateStatisticsError extends ServicesManagerState {
  final String message;

  StateStatisticsError(this.message);
}
////////////////////////////////////////////////////////////////////////////////////////

class ServicesInitial extends ServicesManagerState {}

class ServicesLoading extends ServicesManagerState {}

class ServicesLoaded extends ServicesManagerState {}

class ServicesFiltered extends ServicesManagerState {
  final List<ServicesHistoryModel> filteredList;
  ServicesFiltered(this.filteredList);
}

class ServicesError extends ServicesManagerState {
  final String message;
  ServicesError(this.message);
}


// ✅ When duplicate service name is found
class ServiceNameDuplicate extends ServicesManagerState {}

// ✅ When data is saved to local SharedPreferences
class ServiceSavedToPrefs extends ServicesManagerState {}

// ✅ When status is fetched from Firestore (active/inactive)
class ServiceStatusFetched extends ServicesManagerState {
  final bool isActive;
  ServiceStatusFetched(this.isActive);
}

// ✅ When status is successfully updated
class ServiceStatusUpdated extends ServicesManagerState {}

// ✅ Loading specific service status (before toggling)
class ServiceStatusLoading extends ServicesManagerState {}

// ✅ Employee Loading Screen ( 3 )
class EmployeeLoading extends ServicesManagerState {}
// ✅ Employee Success Screen ( 3 )
class EmployeeLoaded extends ServicesManagerState {
  final List<EmployeeEntityPro> employees;

  EmployeeLoaded(this.employees);
}
// ✅ Employee Error Screen ( 3 )
class EmployeeError extends ServicesManagerState {
  final String message;

  EmployeeError(this.message);
}


class SlaDataLoaded extends ServicesManagerState {}
class SlaSavedToPrefs extends ServicesManagerState {}
class SlaDraftSaved extends ServicesManagerState {}
class SlaServiceSubmitted extends ServicesManagerState {}


class SlaSaving extends ServicesManagerState {}

class SlaSaved extends ServicesManagerState {}

class SlaError extends ServicesManagerState {
  final String message;
  SlaError(this.message);
}


class RequestServicesLoading extends ServicesManagerState {}

class RequestServicesLoaded extends ServicesManagerState {
  final List<ServicesHistoryModel> services;
  final Map<String, int> departmentCounts;

  RequestServicesLoaded({required this.services, required this.departmentCounts});
}

class RequestServicesError extends ServicesManagerState {
  final String message;

  RequestServicesError(this.message);
}