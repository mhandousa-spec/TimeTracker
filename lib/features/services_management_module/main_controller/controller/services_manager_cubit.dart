// ******************* FILE INFO *******************
// File Name: services_manager_cubit
// Description: Cubit orchestrating services list/form/request flows.
//              Pure-logic blocks live in data/helper/* (provider selection,
//              filtered-list building, doc fetching) — this file owns state.
// Module: services_management_module / presentation / controller
// *************************************************

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/state_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/draft_session_service.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/service_draft_manager.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/remote_data_source/service_provider_selector.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/remote_data_source/services_filter_loader.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/remote_data_source/service_doc_fetcher.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/firebase_draft_repository.dart';

part 'services_manager_state.dart';

part 'services_manager_cubit_ext.dart';

class ServicesManagerCubit extends Cubit<ServicesManagerState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;

  // C03/C05: draft persistence + transient draft-tracking session are owned by
  // a dedicated manager (kept injectable so the DI container / tests can supply
  // fakes; the draftRepository/draftSession params preserve existing call sites).
  final ServiceDraftManager _draftManager;

  // Pure-logic collaborators extracted from this cubit (kept injectable for
  // tests). They hold no UI state and never call emit().
  final ServiceProviderSelector _providerSelector;
  final ServicesFilterLoader _filterLoader;
  final ServiceDocFetcher _docFetcher;

  ServicesManagerCubit(
    this.repository, {
    FirebaseDraftRepository? draftRepository,
    DraftSessionService? draftSession,
    ServiceDraftManager? draftManager,
    ServiceProviderSelector? providerSelector,
    ServicesFilterLoader? filterLoader,
    ServiceDocFetcher? docFetcher,
    EmployeeEntityPro? employeeEntity,
  })  : _draftManager = draftManager ??
            ServiceDraftManager(
              draftRepository: draftRepository,
              draftSession: draftSession,
            ),
        _providerSelector = providerSelector ?? ServiceProviderSelector(),
        _filterLoader = filterLoader ?? ServicesFilterLoader(),
        _docFetcher = docFetcher ?? ServiceDocFetcher(),
        _employeeEntity = employeeEntity,
        super(ServicesManagerInitial());

  static ServicesManagerCubit get(BuildContext context) => BlocProvider.of(context);

  // ✅ UPDATED: Changed all to ServicesHistoryModel
  ServicesHistoryModel? servicesModel;
  ServicesHistoryModel? docService;
  List<ServicesHistoryModel> services = [];
  List<ServicesHistoryModel> servicesRequest = [];
  List<ServicesHistoryModel> myRequestModel = [];
  List<ServicesHistoryModel> myApproval = [];
  Map<String, Map<String, dynamic>>? providerSelector;

  List<RequestedServices> requestedServices = [];
  StateStatisticsModel? stateStatisticsModel;

  // C08: no GetX inside the cubit. The employee entity is injected via the
  // constructor (or via [setEmployeeEntity]) by the composition root
  // (see main.dart, where MainCoreEmployeeController is resolved) instead of
  // the cubit reaching into Get.find() itself.
  EmployeeEntityPro? _employeeEntity;

  EmployeeEntityPro get employeeEntity {
    final entity = _employeeEntity;
    if (entity == null) {
      throw StateError(
        'ServicesManagerCubit.employeeEntity was accessed before it was set. '
        'Pass employeeEntity to the constructor or call setEmployeeEntity(...) first.',
      );
    }
    return entity;
  }

  /// Allows the composition root (or tests) to (re)inject the current
  /// employee entity after construction, e.g. once auth/session data becomes
  /// available.
  void setEmployeeEntity(EmployeeEntityPro entity) {
    _employeeEntity = entity;
  }

  // ---------------------------------------------------------------------------
  // Drafts (logic in ServiceDraftManager)
  // ---------------------------------------------------------------------------

  // Draft-tracking session state is delegated to the draft manager (C05).
  String? get currentDraftId => _draftManager.currentDraftId;
  int? get currentDraftPage => _draftManager.currentDraftPage;

  void setCurrentDraft(String? draftId, int page) =>
      _draftManager.setCurrentDraft(draftId, page);

  /// Save draft to Firebase from any page
  Future<String> saveDraftToFirebase({
    required ServicesHistoryModel model,
    required int currentPage,
  }) {
    return _draftManager.saveDraftToFirebase(model: model, currentPage: currentPage);
  }

  /// Update existing draft page
  Future<void> updateDraftPage({
    required String draftId,
    required int currentPage,
    required ServicesHistoryModel model,
  }) {
    return _draftManager.updateDraftPage(
      draftId: draftId,
      currentPage: currentPage,
      model: model,
    );
  }

  /// Refresh drafts list after publishing - removes published draft from list
  Future<void> refreshDraftsAfterPublish(String publishedDraftId) {
    return _draftManager.refreshDraftsAfterPublish(
      publishedDraftId,
      employeeEntity.email ?? '',
    );
  }

  /// Get all user drafts from Firebase
  Future<List<ServicesHistoryModel>> getFirebaseDrafts() {
    return _draftManager.getFirebaseDrafts(employeeEntity.email ?? '');
  }

  /// Get draft with page info for resuming
  Future<DraftWithPage?> getDraftWithPage(String draftId) {
    return _draftManager.getDraftWithPage(draftId);
  }

  /// Delete draft when done
  Future<void> deleteDraft(String draftId) {
    return _draftManager.deleteDraft(draftId);
  }

  /// Remove a draft that has just been published as a live service, so it
  /// stops appearing in the Drafts list (draft bug #2).
  Future<void> discardPublishedDraft(String draftId) {
    return _draftManager.discardPublishedDraft(draftId);
  }

  /// Clear current draft tracking
  void clearCurrentDraft() {
    _draftManager.clearCurrentDraft();
  }

  // ---------------------------------------------------------------------------
  // Service CRUD
  // ---------------------------------------------------------------------------

  /// Returns true only if the write succeeded. B3 FIX: callers must gate draft
  /// deletion + success dialog on this (ServicesManagerError has no listeners).
  Future<bool> saveService(String innerDoc, ServicesHistoryModel model) async {
    emit(ServicesManagerSaving());
    try {
      // C02: persist via the repository instead of touching Firestore directly.
      await repository.saveService(innerDoc, model);

      servicesModel = model;
      if (!isClosed) emit(ServicesManagerSaved(model));
      return true;
    } catch (e) {
      if (!isClosed) emit(ServicesManagerError("Failed to save: $e"));
      return false;
    }
  }

  Future<void> saveRequestService(String innerDoc, ServicesHistoryModel model) async {
    emit(ServicesManagerSaving());
    try {
      // C02: persist via the repository instead of touching Firestore directly.
      await repository.saveService(innerDoc, model);

      servicesModel = model;
      emit(ServicesManagerSaved(model));
    } catch (e) {
      emit(ServicesManagerError("Failed to save: $e"));
    }
  }

  /// Returns true only if the update succeeded. B3 FIX: was rethrow (which the
  /// UI could not catch under §11.2); now returns a success flag so callers can
  /// gate the success dialog and draft cleanup.
  Future<bool> updateService(String serviceDocId, ServicesHistoryModel model) async {
    try {
      // ✅ Call the repository method - it handles EVERYTHING:
      //    - Fetches existing document
      //    - Preserves ALL fields with copyWith
      //    - Uses full toJson() (not toJsonForCreate)
      //    - Updates CreateServices
      //    - Updates myCreateRequests
      await repository.updateService(serviceDocId, model);

      // Refresh the services list
      await getAllServices();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> getAllServices() async {
    emit(GetServiceLoading());
    try {
      // Soft-deleted services are hidden from every list (EDIT 25/9/2026).
      services = (await repository.getAllServices())
          .where((s) => !s.isDeleted)
          .toList();
      emit(GetServiceLoaded(services));
    } catch (e) {
      emit(GetServiceError('Failed to load services: $e'));
    }
  }

  Future<void> getAllRequestServices() async {
    emit(GetServiceLoading());
    try {
      // Get raw services from repository
      // Soft-deleted services are hidden from every list (EDIT 25/9/2026).
      List<ServicesHistoryModel> rawServices =
          (await repository.getAllRequestServices())
              .where((s) => !s.isDeleted)
              .toList();

      // ✅ CRITICAL FIX: Repair drafts with missing emails
      servicesRequest = rawServices.map((service) {
        final email = service.currentEmailRequester ?? '';
        final state = service.currentState ?? '';

        // If draft has no email but ID contains email pattern, repair it
        if (email.isEmpty && state.toLowerCase() == 'draft') {
          final docId = service.currentId;

          // Extract email from draft ID format: draft_timestamp_email@gmail.com
          if (docId.contains('draft_')) {
            final parts = docId.split('_');
            if (parts.length >= 3) {
              // Reconstruct email (parts[2] onwards, joined by _ in case email has underscores)
              final extractedEmail = parts.sublist(2).join('_');

              // ✅ FIXED: Use correct parameter name 'emailRequester' (not 'currentEmailRequester')
              // bumpTimestamp: false — recovering a value already implied by the
              // doc id is a read-time repair, not an edit, so it must not
              // re-date the record. See ServicesHistoryModel.copyWith.
              return service.copyWith(
                emailRequester: extractedEmail,
                bumpTimestamp: false,
              );
            }
          }
        }
        return service;
      }).toList();

      emit(GetServiceLoaded(servicesRequest));
    } catch (e, stackTrace) {
      emit(GetServiceError('Failed to load services: $e'));
    }
  }

  Future<void> deleteService(String innerDocId) async {
    emit(ServicesManagerDeleting());
    try {
      await repository.deleteService(innerDocId);
      emit(ServicesManagerDeleted());
      await getAllServices();
    } catch (e) {
      emit(ServicesManagerError("Failed to delete: $e"));
    }
  }

  // ---------------------------------------------------------------------------
  // Fetch document to edit (delegates Firestore reads to ServiceDocFetcher)
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? docServiceRawJson;

  Future<void> debugCreateServicesStructure(String serviceId) {
    return _docFetcher.debugCreateServicesStructure(serviceId);
  }

  Future<ServicesHistoryModel?> getDocToEdit(String serviceId) async {
    emit(GetDocServiceLoading());
    final result = await _docFetcher.fetchDocToEdit(serviceId);
    if (!result.isSuccess) {
      emit(GetDocServiceError(result.error ?? 'Service not found'));
      return null;
    }
    docServiceRawJson = result.rawJson;
    docService = result.model;
    emit(GetDocServiceLoaded(result.model!));
    return result.model;
  }

  /// Fetches document for editing WITHOUT emitting states
  Future<ServicesHistoryModel?> getDocToEditSilent(String serviceId) async {
    final result = await _docFetcher.fetchDocToEditSilent(serviceId);
    if (result == null) return null;
    docServiceRawJson = result.rawJson;
    docService = result.model;
    return result.model;
  }

  /// Fetches from AllServices WITHOUT emitting states
  Future<ServicesHistoryModel?> getDocAllToEditSilent(String serviceId) async {
    final result = await _docFetcher.fetchDocAllToEditSilent(serviceId);
    if (result == null) return null;
    docServiceRawJson = result.rawJson;
    docService = result.model;
    return result.model;
  }

  Future<ServicesHistoryModel?> getDocAllToEdit(String serviceId) async {
    emit(GetDocServiceLoading());
    final result = await _docFetcher.fetchDocAllToEdit(serviceId);
    if (!result.isSuccess) {
      emit(GetDocServiceError(result.error ?? 'Service not found'));
      return null;
    }
    docServiceRawJson = result.rawJson;
    docService = result.model;
    emit(GetDocServiceLoaded(result.model!));
    return result.model;
  }

  // ---------------------------------------------------------------------------
  // Upload request + provider assignment
  // ---------------------------------------------------------------------------

  /// Returns true only if the provider-assignment write succeeded. B1 FIX.
  Future<bool> uploadRequestServices(String innerDoc, ServicesHistoryModel model) async {
    emit(UploadServicesLoading());
    try {
      String? assignedProviderEmail;

      final currentProviderServices = model.currentProviderServices;

      if (currentProviderServices.isNotEmpty) {
        final selectedProvider = await _providerSelector.selectProviderForNewRequest(
          providers: currentProviderServices,
          parentServiceId: model.currentParentServiceId,
        );

        if (selectedProvider != null) {
          assignedProviderEmail = selectedProvider['email']?.toString().toLowerCase();
        }
      }

      if (assignedProviderEmail != null && assignedProviderEmail.isNotEmpty) {
        final updatedModel = model.copyWith(assignedProviderEmail: assignedProviderEmail);

        // C02: persist via the repository instead of touching Firestore directly.
        await repository.setRequestServiceDoc(innerDoc, updatedModel.toJsonMinimal());

        servicesModel = updatedModel;
        if (isClosed) return true;
        emit(UploadServicesSuccess(updatedModel));
      } else {
        // C02: persist via the repository instead of touching Firestore directly.
        await repository.setRequestServiceDoc(innerDoc, model.toJsonMinimal());

        servicesModel = model;
        if (isClosed) return true;
        emit(UploadServicesSuccess(model));
      }
      return true;
    } catch (e) {
      if (!isClosed) emit(UploadServicesError("Failed to save: $e"));
      return false;
    }
  }

  /// Workload-balanced provider pick (algorithm in ServiceProviderSelector).
  Future<Map<String, dynamic>?> computeProvider({
    required List<EmployeeEntityModell> providerServices,
  }) {
    return _providerSelector.computeProvider(providerServices: providerServices);
  }

  Future<Map<String, dynamic>?> getProviderForService(String id) {
    return repository.selectServiceProvider(id);
  }

  // ---------------------------------------------------------------------------
  // Requests / approvals
  // ---------------------------------------------------------------------------

  Future<void> getMyRequestServices() async {
    emit(GetMyRequestServicesLoading());
    try {
      myRequestModel = await repository.getMyRequestServices();
      emit(GetMyRequestServicesSuccess(myRequestModel));
    } catch (e) {
      emit(GetMyRequestServicesError('Failed to load services: $e'));
    }
  }

  Future<void> updateApprovalState({
    required String docID,
    required String email,
    required String newState,
  }) async {
    try {
      // C02: delegate the Firestore read/update to the repository instead of
      // touching FirebaseFirestore.instance directly from the cubit.
      await repository.updateApprovalState(
        docID: docID,
        email: email,
        newState: newState,
      );

      await getMyApprovalServices(email);
      emit(state);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMyRequest(String departmentId, String innerDocId) async {
    emit(ServicesManagerDeleting());
    try {
      await repository.deleteMyRequest(departmentId, innerDocId);
      emit(ServicesManagerDeleted());
      await getAllServices();
    } catch (e) {
      emit(ServicesManagerError("Failed to delete: $e"));
    }
  }

  final Map<String, String> serviceIdToFirestoreDocId = {};
  final Map<String, String> serviceIdToRequesterEmail = {};

  Future<void> getMyApprovalServices(String? email) async {
    if (email == null || email.isEmpty) {
      emit(GetMyApprovalServicesError('Email is null or empty'));
      return;
    }

    serviceIdToFirestoreDocId.clear();
    serviceIdToRequesterEmail.clear();

    try {
      // ✅ CALL THE REPOSITORY METHOD
      final approvalList = await repository.getApprovalServices(email);

      // ✅ CRITICAL: Populate the serviceIdToFirestoreDocId map
      for (final service in approvalList) {
        final serviceId = service.currentId;

        // ✅ The Firestore document ID is the same as the service ID
        // because documents are stored directly in RequestServices collection
        serviceIdToFirestoreDocId[serviceId] = serviceId;

        // Also store requester email for reference
        serviceIdToRequesterEmail[serviceId] = service.currentEmailRequester ?? '';
      }

      myApproval = approvalList;
      emit(GetMyApprovalServicesSuccess(approvalList));
    } catch (e, stackTrace) {
      emit(GetMyApprovalServicesError(e.toString()));
    }
  }

  Map<String, Map<String, dynamic>> providerPerDoc = {};

  Future<void> loadProviderPerDocument() async {
    emit(ProviderServicesLoading());
    try {
      final result = await repository.getServiceProviderPerDoc();

      providerSelector = result;
      emit(ProviderServicesLoaded(result));
    } catch (e) {
      emit(ProviderServicesError(e.toString()));
    }
  }

  /// Returns true only if the write actually succeeded. B1 FIX: callers must
  /// check this before showing a success dialog (error states have no listeners).
  Future<bool> addRequestedService({
    required String docId,
    required String uidUser,
    required RequestedServices requestModel,
  }) async
  {
    emit(RequestServiceLoading());
    try {
      await repository.addRequestedService(
        uidUser: uidUser,
        docId: docId,
        requestModel: requestModel,
      );
      if (isClosed) return true;
      emit(RequestServiceSuccess());
      return true;
    } catch (e) {
      if (!isClosed) emit(RequestServiceError(e.toString()));
      return false;
    }
  }

  Future<void> getRequestedServices(String docId) async {
    emit(RequestServiceLoading());
    try {
      requestedServices = await repository.getRequestedServices(docId: docId);
      emit(RequestServiceSuccess());
    } catch (e) {
      emit(RequestServiceError(e.toString()));
    }
  }

  Future<void> getStatistics(String parentDocId) async {
    emit(StateStatisticsLoading());
    try {
      final result = await repository.fetchStateStatistics(parentDocId);
      stateStatisticsModel = result;
      emit(StateStatisticsLoaded(result));
    } catch (e) {
      emit(StateStatisticsError(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Services list / SLA / settings
  // ---------------------------------------------------------------------------

  String userEmail = '';
  String userDepartment = '';

  // ✅ UPDATED: All list types changed to ServicesHistoryModel
  List<ServicesHistoryModel> allServices = [];
  List<ServicesHistoryModel> firebaseServices = [];
  List<ServicesHistoryModel> draftServices = [];
  List<ServicesHistoryModel> activeServices = [];
  List<ServicesHistoryModel> inactiveServices = [];
  Map<String, int> doneServicesCount = {};
  Map<String, Map<String, dynamic>> selectedProviders = {};

  String slaOne = '';
  String slaTwo = '';

  List<String> extraSlaOneList = [];
  List<String> extraSlaTwoList = [];

  bool notifyRequesterChecked = true;
  bool notifyProviderChecked = true;
  bool notifyManagerChecked = true;

  bool notifyRequesterSwitch0 = false;
  bool notifyManagerSwitch1 = false;

  Map<String, Map<int, bool>> notificationSwitches = {};

  Future loadServices() async {
    emit(ServicesLoading());
    try {
      firebaseServices = await repository.getFirebaseServices();
      draftServices = await repository.getLocalDrafts();

      allServices = [...firebaseServices, ...draftServices];

      // ✅ UPDATED: Access current values
      activeServices = firebaseServices
          .where((e) => e.currentStatus.toLowerCase() == 'active')
          .toList();
      inactiveServices = firebaseServices
          .where((e) => e.currentStatus.toLowerCase() == 'inactive')
          .toList();

      selectedProviders = await repository.getSelectedProviders(firebaseServices);
      doneServicesCount = await repository.getDoneServicesCount();

      emit(ServicesLoaded());
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  void search(String query) {
    final lowerQuery = query.toLowerCase();
    final results = allServices.where((item) {
      // ✅ UPDATED: Access current values
      return item.currentServiceNameEnglish.toLowerCase().contains(lowerQuery) ||
          item.currentServiceNameArabic.toLowerCase().contains(lowerQuery);
    }).toList();

    emit(ServicesFiltered(results));
  }

  Future<void> checkDuplicateNameAndProceed(String name, ServicesHistoryModel model) async {
    emit(ServicesLoading());
    final isDuplicate = await repository.checkDuplicateServiceName(name);
    if (isDuplicate) {
      emit(ServiceNameDuplicate());
    } else {
      await repository.saveServiceToPrefs(model);
      emit(ServiceSavedToPrefs());
    }
  }

  Future<void> saveServiceDraft(ServicesHistoryModel model) async {
    await repository.saveServiceToPrefs(model);
    emit(ServiceSavedToPrefs());
  }

  Future<void> fetchServiceStatus(String docId) async {
    emit(ServiceStatusLoading());
    final status = await repository.getServiceStatus(docId);
    emit(ServiceStatusFetched(status == "active"));
  }

  Future<void> updateServiceStatus(String docId, bool isActive) async {
    await repository.updateServiceStatus(docId, isActive);
    emit(ServiceStatusUpdated());
  }

}
