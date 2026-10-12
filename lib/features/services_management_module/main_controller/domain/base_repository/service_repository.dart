// ******************* FILE INFO *******************
// File Name: service_repository
// Description: Abstract repository contract for the services module.
// Module: services_management_module / domain / base_repository
// *************************************************

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/sla_data_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/state_model.dart';

abstract class CreateServicesRepository {
  // ✅ UPDATED: All ServicesModel changed to ServicesHistoryModel
 // Future<void> uploadServices(ServicesHistoryModel services, String departmentId);
  Future<List<ServicesHistoryModel>> getAllServices();
  Future<List<ServicesHistoryModel>> getAllRequestServices();
  Future<void> deleteService(String innerDocId);
  Future<ServicesHistoryModel?> getServiceById(String departmentId, String serviceId);
  Future<void> uploadRequest(ServicesHistoryModel services, String departmentId);
  Future<List<ServicesHistoryModel>> getMyRequestServices();
  Future<void> editService(String docId, ServicesHistoryModel updatedModel);
  Future<void> deleteMyRequest(String departmentId, String innerDocId);
  Future<List<ServicesHistoryModel>> getApprovalServices(String departmentId);
  Future<void> updateApprovalState({
    required String docID,
    required String email,
    required String newState,
  });
  Future<Map<String, Map<String, dynamic>>> getServiceProviderPerDoc();
  Future<void> addRequestedService({
    required String docId,
    required RequestedServices requestModel,
    required String uidUser,
  });
  Future<List<RequestedServices>> getRequestedServices({required String docId});
  Future<StateStatisticsModel> fetchStateStatistics(String parentDocId);

  // Firebase services
  Future<List<ServicesHistoryModel>> getFirebaseServices();

  // Local drafts from SharedPreferences
  Future<List<ServicesHistoryModel>> getLocalDrafts();

  // Count done services per status
  Future<Map<String, int>> getDoneServicesCount();

  // All CreateServices docs where the given email is a requester (for duplicate
  // checks / status lookups done in the create flow).
  Future<List<ServicesHistoryModel>> getServicesByRequesterEmail(String email);

  // Raw write helpers used by the bulk/master upload flow (keeps Firestore out
  // of the services_management_module — the page builds the map, the repo persists it).
  Future<void> setRequestServiceDoc(String docId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getRequestServiceDocById(String docId);
  Future<void> updateRequestServiceDoc(String docId, Map<String, dynamic> data);

  /// Updates the assigned provider on a request-service doc and appends a
  /// timestamp entry. Keeps Firestore-specific value types (e.g. array-union)
  /// out of the presentation layer.
  Future<void> updateAssignedProvider({
    required String docId,
    required String providerEmail,
    required String providerJson,
  });

  /// All RequestServices docs as (id -> data) entries (raw, for dashboard
  /// aggregation that needs the document id alongside the data).
  Future<List<MapEntry<String, Map<String, dynamic>>>> getAllRequestServiceDocs();

  /// Most-recent RequestServices docs (ordered by timestamps desc, limited).
  Future<List<MapEntry<String, Map<String, dynamic>>>> getRecentRequestServiceDocs({
    required int limit,
  });
  Future<Map<String, dynamic>?> getCreateServiceDoc(String docId);

  // Services collection (SLA draft docs).
  Future<Map<String, dynamic>?> getServicesDoc(String docId);
  Future<void> setServicesDoc(String docId, Map<String, dynamic> data, {bool merge});
  Future<void> setCreateServiceDoc(String docId, Map<String, dynamic> data);
  Future<void> updateCreateServiceDoc(String docId, Map<String, dynamic> data);
  Future<void> deleteCreateServiceDoc(String docId);

  /// Generates a new (client-side) CreateServices document id without writing.
  String newCreateServiceId();

  // Count 'done' request services grouped by their Parent_Service_Id (handles
  // the array-typed Parent_Service_Id / state fields used by request docs).
  Future<Map<String, int>> getDoneServicesCountByParent();

  // Extract providers' info from services
  Future<Map<String, Map<String, dynamic>>> getSelectedProviders(List<ServicesHistoryModel> services);

  // Check if service name already exists
  Future<bool> checkDuplicateServiceName(String name);

  // Save service form data to SharedPreferences (as draft)
  Future<void> saveServiceToPrefs(ServicesHistoryModel model);

  // Load service model into SharedPrefs (for editing)
  Future<void> loadServiceToFormControllers(ServicesHistoryModel model);

  // Update service status (active/inactive)
  Future<void> updateServiceStatus(String docId, bool isActive);

  // Fetch current service status
  Future<String?> getServiceStatus(String docId);

  // // Fetch all employees
  // Future<List<EmployeeEntityPro>> getAllEmployees();

  // Load SLA and notification values from SharedPreferences
  Future<SlaDataModel> loadFromSharedPrefs();

  // Save draft
  Future<void> saveDraft(ServicesHistoryModel model);

  // Update draft if editing existing one
  Future<void> updateDraft(ServicesHistoryModel oldModel, ServicesHistoryModel newModel);

  // Remove draft after submission
  Future<void> removeDraftById(String id);

  // Submit service to Firestore
  Future<void> saveService(String docId, ServicesHistoryModel model);

  // Update existing submitted service
  Future<void> updateService(String docId, ServicesHistoryModel model);

  // Save SLA configuration to SharedPreferences
  Future<void> saveSlaToPrefs({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required List<String> extraSlaList,
    required List<String> extraSlaTwoList,
    required Map<String, Map<int, bool>> notificationSwitches,
  });

  // Get filtered services for request view
  Future<List<ServicesHistoryModel>> getFilteredServices(
      List<ServicesHistoryModel> cubitServices,
      String userEmail,
      String userDepartment,
      );

  // Get department counts
  Future<Map<String, int>> getDepartmentCounts(
      List<ServicesHistoryModel> cubitServices,
      String userDepartment,
      );

  // Select service provider
  Future<Map<String, dynamic>?> selectServiceProvider(String serviceId);

  // Fetch a raw service document (services collection) by id
  Future<Map<String, dynamic>?> getServiceDocById(String serviceId);

  // Requested services where the given email is a requester (for count aggregation)
  Future<List<ServicesHistoryModel>> getMyRequestServicesByRequester(
      String? email);

  // Append a state + timestamp to the request doc identified by id + requester email
  Future<void> appendRequestState({
    required String serviceId,
    required String? requesterEmail,
    required String newState,
  });

  // Fetch a user document (users collection) by email
  Future<Map<String, dynamic>?> getUserByEmail(String email);

  // Fetch a raw CreateServices doc (Demo/{companyId}/Modules/services/CreateServices/{id}) by id
  Future<Map<String, dynamic>?> getCreateServiceDocById(String serviceId);

  /// Scans the `user` collection-group under the current tenant's
  /// request-services root and returns the raw doc data for every request
  /// where [approverEmail] appears anywhere in the approval cycle. Used by
  /// the approvals list to compute per-state counts without the presentation
  /// layer touching Firestore directly.
  Future<List<Map<String, dynamic>>> getRequestServiceDocsForApprover(
    String approverEmail,
  );

  /// All CreateServices docs (raw), for building the dashboard's service
  /// dropdown and resolving parent-service names by id.
  Future<List<Map<String, dynamic>>> getAllCreateServiceDocs();

  /// A single CreateServices doc (raw) by id, resolved under the tenant's
  /// CreateServices root (`getBaseUrl(FirestoreCollections.createServicesRoot)`).
  /// Used to resolve a request's parent-service name when the request doc
  /// doesn't carry it directly.
  Future<Map<String, dynamic>?> getCreateServiceDocByIdUnderTenantRoot(
    String parentId,
  );
}
