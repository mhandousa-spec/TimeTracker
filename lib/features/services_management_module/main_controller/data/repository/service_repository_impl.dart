// ******************* FILE INFO *******************
// File Name: service_repository_impl
// Description: Concrete repository implementation for the services module.
// Module: services_management_module / data / repository
// *************************************************

import 'dart:convert';

// cloud_firestore 6 exports its own Constant (pipeline API); ours is the user context.
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/current_user_context.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/remote_data_source/parent_service_details_fetcher.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/services_local_data_source.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/remote_data_source/services_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/sla_data_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/state_model.dart';

class GetServiceRepositoryImpl implements CreateServicesRepository {
  final FirebaseFirestore firestore;

  GetServiceRepositoryImpl({required this.firestore});

  // R01: read the current user's email from the data-layer context instead of
  // importing a presentation controller.
  // Falls back to Constant.emailUser: CurrentUserContext is populated when the
  // employee loads, and a repository call can fire before that lands.
  String get _currentEmail {
    final ctx = CurrentUserContext.email;
    if (ctx != null && ctx.isNotEmpty) return ctx;
    return Constant.emailUser ?? '';
  }

  // R01/R02: parent-service lookup extracted into a data-layer helper.
  late final ParentServiceDetailsFetcher _parentDetailsFetcher =
      ParentServiceDetailsFetcher(firestore);

  // R02: SharedPreferences/draft/SLA persistence lives in the local data source.
  final ServicesLocalDataSource _local = ServicesLocalDataSource();

  // R02: heavier Firestore operations live in the remote data source.
  late final ServicesRemoteDataSource _remote = ServicesRemoteDataSource(firestore);

 // @override
  // Future<void> uploadServices(
  //     ServicesHistoryModel services,
  //     String departmentId,
  //     ) async
  // {
  //   // final servicesMap = services.toJson();
  //   // await firestore
  //   //     .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
  //   //     .doc('services_list')
  //   //     .set(servicesMap);
  // }
  //CreateServices

  @override
  Future<List<ServicesHistoryModel>> getAllServices() async {
    List<ServicesHistoryModel> servicesList = [];

    try {

      // R01: the current email comes from the data-layer context. If it isn't
      // populated yet, wait briefly (the presentation layer sets it at login).
      if (_currentEmail.isEmpty) {
        await Future.delayed(Duration(milliseconds: 500));
      }

      final userEmail = _currentEmail;
      if (userEmail.isEmpty) {
        return servicesList;
      }

      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          // B4 FIX: was `.where('Email_Requester', isEqualTo: "Email_Requester")`
          // — compared the field to the literal column name (never matched) and
          // used isEqualTo against a field written as an array. Email_Requester
          // is stored as an array, so match the current user's email with
          // arrayContains (consistent with every other query in this file).
          .where('Email_Requester', arrayContains: userEmail)
          .get();

      final prefs = await SharedPreferences.getInstance();

      for (var doc in querySnapshot.docs) {

        final model = ServicesHistoryModel.fromJson(doc.data(), doc.id);

        servicesList.add(model);

        // ✅ UPDATED: Use current getters
        await prefs.setString('firstNameRequester', model.currentFirstNameRequester);
        await prefs.setString('lastNameRequester', model.currentLastNameRequester);
        await prefs.setString('jobTitleRequester', model.currentJobTitleRequester);
        await prefs.setString('departmentRequester', model.currentDepartmentRequester);
        await prefs.setString('emailRequester', userEmail);
        await prefs.setString('firstNameRequesterArabic', model.currentFirstNameRequesterArabic);
        await prefs.setString('lastNameRequesterArabic', model.currentLastNameRequesterArabic);
        await prefs.setString('jobTitleRequesterArabic', model.currentJobTitleRequesterArabic);
      }
    } catch (e, stack) {
      // Never swallow silently (§11): surface the failure so the cubit can emit
      // an error state instead of an empty "loaded" list.
      if (kDebugMode) debugPrint('getAllServices failed: $e\n$stack');
      rethrow;
    }

    return servicesList;
  }

  @override
  Future<List<ServicesHistoryModel>> getAllRequestServices() async {
    final List<ServicesHistoryModel> servicesList = [];

    try {

      final String tenantRoot = getBaseUrl(FirestoreCollections.createServicesRoot);

      // ✅ Query the CreateServices collection directly
      final querySnapshot = await firestore
          .collection(tenantRoot)
          .get();

      int processedCount = 0;

      for (var doc in querySnapshot.docs) {
        processedCount++;

        try {
          final model = ServicesHistoryModel.fromJson(doc.data(), doc.id);
          servicesList.add(model);

        } catch (e) {
          // Tolerate a single malformed document, but do not fail silently.
          if (kDebugMode) debugPrint('Skipping malformed service doc ${doc.id}: $e');
        }
      }

    } catch (e, stack) {
      if (kDebugMode) debugPrint('getAllRequestServices failed: $e\n$stack');
      rethrow;
    }

    return servicesList;
  }

  @override
  Future<void> deleteService(String innerDocId) async {
    // EDIT 25/9/2026: SOFT delete. The document stays so every request made
    // before the delete still shows the service name, duration and image
    // (Approvals, My Requests, dashboards). The service lists filter it out
    // via ServicesHistoryModel.isDeleted.
    await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(innerDocId)
        .update({
      ServicesHistoryModel.kIsDeleted: true,
      ServicesHistoryModel.kDeletedAt: FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<ServicesHistoryModel?> getServiceById(
      String departmentId,
      String serviceId,
      ) async {
    try {
      final doc = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(serviceId)
          .get();

      //Document_Utilization
      if (doc.exists) {
        return ServicesHistoryModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> uploadRequest(
      ServicesHistoryModel services,
      String departmentId,
      ) async {
    final servicesMap = services.toJson();
    await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc('services_list')
        .set(servicesMap);
  }

  @override
  Future<List<ServicesHistoryModel>> getMyRequestServices() async {
    List<ServicesHistoryModel> servicesList = [];

    try {

      // §11.5: never log user email in release builds.
      if (kDebugMode) {
        debugPrint('🔎 getMyRequestServices → email="$_currentEmail" '
            '(CurrentUserContext="${CurrentUserContext.email}", '
            'Constant.emailUser="${Constant.emailUser}") '
            'path=${getBaseUrl(FirestoreCollections.requestServicesRoot)}');
      }

      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .where("Email_Requester", arrayContains: _currentEmail)
          .get();

      if (kDebugMode) {
        debugPrint('🔎 getMyRequestServices → ${querySnapshot.docs.length} docs');
      }

      // ✅ Process each document and enrich with service names
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        // B6 FIX: guard the per-doc parse so one legacy/cross-platform doc with
        // a mixed int/Timestamp field can't throw and drop the whole screen.
        ServicesHistoryModel service;
        try {
          service = ServicesHistoryModel.fromJson(data, doc.id);
        } catch (e) {
          if (kDebugMode) debugPrint('Skipping malformed request doc ${doc.id}: $e');
          continue;
        }

        // ✅ If service names are empty, fetch from parent CreateServices
        if ((service.currentServiceNameEnglish.isEmpty || service.currentServiceNameArabic.isEmpty)
            && service.currentParentServiceId.isNotEmpty) {

          try {
            final serviceDetails = await _parentDetailsFetcher.fetch(
              parentServiceId: service.currentParentServiceId,
              emailRequester: _currentEmail,
            );

            // ✅ Update the service with fetched names using copyWith
            //
            // ✅ FIX: bumpTimestamp: false. This is a read-time display repair,
            // not an edit of the request. copyWith used to append DateTime.now()
            // to `timestamps` unconditionally, and because
            // ServicesHistoryModel.createMinimalRequest never sets a service
            // name, EVERY request took this branch on EVERY load of this list —
            // inside one loop, so every doc's `timestamps.last` became the same
            // millisecond. my_request.dart renders that as "Last Update", which
            // is why creating one request appeared to re-date all the others.
            service = service.copyWith(
              serviceNameEnglish: serviceDetails['serviceNameEnglish'],
              serviceNameArabic: serviceDetails['serviceNameArabic'],
              serviceDescriptionEnglish: serviceDetails['serviceDescriptionEnglish'],
              serviceDescriptionArabic: serviceDetails['serviceDescriptionArabic'],
              durationOfServices: serviceDetails['duration'],
              selectedDurationUnit: serviceDetails['unit'],
              bumpTimestamp: false,
            );

          } catch (e) {
            // Continue with empty service name if parent fetch fails
          }
        }

        servicesList.add(service);
      }

    } catch (e, s) {
      // B8 FIX: was swallowed + returned [] (MyRequestError could never fire,
      // so failures looked like an empty list and users re-submitted → dupes).
      // Surface the failure so MyRequestCubit can emit its error state.
      if (kDebugMode) {
        debugPrint('❌ getMyRequestServices FAILED: $e');
        debugPrintStack(stackTrace: s);
      }
      rethrow;
    }

    return servicesList;
  }

  @override
  Future<void> deleteMyRequest(String departmentId, String innerDocId) async {
    // Query directly in RequestServices collection
    final querySnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where("Email_Requester", arrayContains: _currentEmail)
        .get();

    // Find and delete the matching document by ID
    for (var doc in querySnapshot.docs) {
      if (doc.id == innerDocId) {
        await doc.reference.delete();
        return;
      }
    }

  }

  @override
  Future<List<ServicesHistoryModel>> getApprovalServices(String email) =>
      _remote.getApprovalServices(email);

  @override
  Future<Map<String, Map<String, dynamic>>> getServiceProviderPerDoc() =>
      _remote.getServiceProviderPerDoc();

  @override
  Future<void> updateApprovalState({
    required String docID,
    required String email,
    required String newState,
  }) =>
      _remote.updateApprovalState(docID: docID, email: email, newState: newState);

  @override
  Future<void> addRequestedService({
    required String docId,
    required RequestedServices requestModel,
    required String uidUser,
  }) =>
      _remote.addRequestedService(
        docId: docId,
        requestModel: requestModel,
        uidUser: uidUser,
      );

  @override
  Future<List<RequestedServices>> getRequestedServices({required String docId}) =>
      _remote.getRequestedServices(docId: docId);

  @override
  Future<StateStatisticsModel> fetchStateStatistics(String parentDocId) =>
      _remote.fetchStateStatistics(parentDocId);

  @override
  Future<List<ServicesHistoryModel>> getFirebaseServices() async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .where("Email_Requester",arrayContains: _currentEmail)

        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ServicesHistoryModel.fromJson(data, doc.id);
    }).toList();
  }

  @override
  Future<List<ServicesHistoryModel>> getLocalDrafts() => _local.getLocalDrafts();

  @override
  Future<Map<String, int>> getDoneServicesCount() async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where("state", isEqualTo: "done")
        .get();

    Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      final serviceId = doc["serviceId"];
      if (serviceId != null) {
        counts[serviceId] = (counts[serviceId] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getSelectedProviders(
      List<ServicesHistoryModel> services) async {
    Map<String, Map<String, dynamic>> result = {};
    for (var service in services) {
      // ✅ UPDATED: Use current getter
      final serviceId = service.currentId;
      if (serviceId.isNotEmpty) {
        final provider = await selectServiceProvider(serviceId);
        if (provider != null) {
          result[serviceId] = provider;
        }
      }
    }
    return result;
  }

  @override
  Future<bool> checkDuplicateServiceName(String name) async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .where("Email_Requester",arrayContains: _currentEmail)

        .get();

    return snapshot.docs.any((doc) {
      final data = doc.data();
      // ✅ UPDATED: Handle list format
      final nameData = data['Service_Name_English'];
      if (nameData is List && nameData.isNotEmpty) {
        return nameData.last.toString().toLowerCase() == name.toLowerCase();
      } else if (nameData is String) {
        return nameData.toLowerCase() == name.toLowerCase();
      }
      return false;
    });
  }

  @override
  Future<void> saveServiceToPrefs(ServicesHistoryModel model) =>
      _local.saveServiceToPrefs(model);

  @override
  Future<void> loadServiceToFormControllers(ServicesHistoryModel model) =>
      _local.loadServiceToFormControllers(model);

  @override
  Future<void> updateServiceStatus(String docId, bool isActive) async {
    try {
      // Query to find the document
      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .where("Email_Requester", arrayContains: _currentEmail)
          .get();

      // Find the specific document by docId
      final doc = querySnapshot.docs.firstWhere(
            (doc) => doc.id == docId,
        orElse: () => throw Exception("Document not found"),
      );

      // Update the found document
      await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(doc.id)
          .update({
        "status": FieldValue.arrayUnion([isActive ? "active" : "inactive"]),
        "timestamps": FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getServiceStatus(String docId) async {
    try {
      // Query all documents where the emailRequester array contains this user's email
      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .where("Email_Requester", arrayContains: _currentEmail)
          .get();

      // Find the specific document by docId
      final doc = querySnapshot.docs.firstWhere(
            (doc) => doc.id == docId,
        orElse: () => throw Exception("Document not found"),
      );

      if (doc.exists && doc.data() != null) {
        final statusData = doc.data()["status"];
        if (statusData is List && statusData.isNotEmpty) {
          return statusData.last as String?;
        } else if (statusData is String) {
          return statusData;
        }
      }
      return null;
    } catch (e) {
      // B7 FIX: was `return null` on error, which the caller coerced to
      // 'active' (?? 'active') and persisted — silent status corruption.
      // Rethrow so a read failure is distinguishable from "no status found".
      rethrow;
    }
  }

  // @override
  // Future<List<EmployeeEntityPro>> getAllEmployees() async {
  //   final snapshot = await firestore
  //       .collection(getBaseUrl('Employees'))
  //       .get();
  //
  //   final models = snapshot.docs.map((doc) {
  //     final data = doc.data();
  //     data['id'] = doc.id;
  //     return NewEmployeeModel.fromMap(data);
  //   }).toList();
  //
  //   return controller.fromModelList(models);
  // }

  @override
  Future<void> saveToSharedPrefs({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required Map<String, Map<int, bool>> notificationSwitches,
    required List<String> extraSlaValues,
    required List<String> extraSlaTwoValues,
  }) =>
      _local.saveToSharedPrefs(
        slaOne: slaOne,
        slaTwo: slaTwo,
        notifyRequesterChecked: notifyRequesterChecked,
        notifyProviderChecked: notifyProviderChecked,
        notifyManagerChecked: notifyManagerChecked,
        notifyRequesterSwitch0: notifyRequesterSwitch0,
        notifyManagerSwitch1: notifyManagerSwitch1,
        notificationSwitches: notificationSwitches,
        extraSlaValues: extraSlaValues,
        extraSlaTwoValues: extraSlaTwoValues,
      );

  @override
  Future<SlaDataModel> loadFromSharedPrefs() => _local.loadFromSharedPrefs();

  @override
  Future<void> saveDraft(ServicesHistoryModel model) => _local.saveDraft(model);

  @override
  Future<void> updateDraft(ServicesHistoryModel oldModel, ServicesHistoryModel newModel) =>
      _local.updateDraft(oldModel, newModel);

  @override
  Future<void> removeDraftById(String id) => _local.removeDraftById(id);

  @override
  Future<void> saveService(String docId, ServicesHistoryModel model) async {
    final docRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId);

    // ✅ Use set with merge to create or update
    await docRef.set(
      model.toJsonForCreate(),
      SetOptions(merge: true),  // ✅ This will merge with existing data
    );
  }

  @override
  Future<void> setRequestServiceDoc(String docId, Map<String, dynamic> data) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId)
        .set(data);
  }

  @override
  Future<Map<String, dynamic>?> getRequestServiceDocById(String docId) async {
    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId)
        .get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Future<void> updateRequestServiceDoc(String docId, Map<String, dynamic> data) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId)
        .update(data);
  }

  @override
  Future<void> updateAssignedProvider({
    required String docId,
    required String providerEmail,
    required String providerJson,
  }) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId)
        .update({
      ServicesHistoryModel.kAssignedProviderEmail: [providerEmail],
      ServicesHistoryModel.kProviderServices: [providerJson],
      ServicesHistoryModel.kTimestamps: FieldValue.arrayUnion([
        DateTime.now().millisecondsSinceEpoch,
      ]),
    });
  }

  @override
  Future<List<MapEntry<String, Map<String, dynamic>>>> getAllRequestServiceDocs() async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();
    return snapshot.docs.map((d) => MapEntry(d.id, d.data())).toList();
  }

  @override
  Future<List<MapEntry<String, Map<String, dynamic>>>> getRecentRequestServiceDocs({
    required int limit,
  }) async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .orderBy('timestamps', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => MapEntry(d.id, d.data())).toList();
  }

  @override
  Future<Map<String, dynamic>?> getServicesDoc(String docId) async {
    final doc =
        await firestore.collection(getBaseUrl(FirestoreCollections.servicesRoot)).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Future<void> setServicesDoc(String docId, Map<String, dynamic> data,
      {bool merge = true}) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.servicesRoot))
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  @override
  Future<Map<String, dynamic>?> getCreateServiceDoc(String docId) async {
    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId)
        .get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Future<void> setCreateServiceDoc(String docId, Map<String, dynamic> data) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId)
        .set(data);
  }

  @override
  Future<void> updateCreateServiceDoc(String docId, Map<String, dynamic> data) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId)
        .update(data);
  }

  @override
  Future<void> deleteCreateServiceDoc(String docId) async {
    await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId)
        .delete();
  }

  @override
  String newCreateServiceId() => firestore
      .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
      .doc()
      .id;

  @override
  Future<List<ServicesHistoryModel>> getServicesByRequesterEmail(String email) async {
    final querySnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .where("Email_Requester", arrayContains: email)
        .get();
    return querySnapshot.docs
        .map((doc) => ServicesHistoryModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Map<String, int>> getDoneServicesCountByParent() =>
      _remote.getDoneServicesCountByParent();

  @override
  Future<void> editService(String docId, ServicesHistoryModel updatedModel) =>
      _remote.editService(docId, updatedModel);

  @override
  Future<void> updateService(String docId, ServicesHistoryModel model) =>
      _remote.updateService(docId, model);
  @override
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
  }) =>
      _local.saveSlaToPrefs(
        slaOne: slaOne,
        slaTwo: slaTwo,
        notifyRequesterChecked: notifyRequesterChecked,
        notifyProviderChecked: notifyProviderChecked,
        notifyManagerChecked: notifyManagerChecked,
        notifyRequesterSwitch0: notifyRequesterSwitch0,
        notifyManagerSwitch1: notifyManagerSwitch1,
        extraSlaList: extraSlaList,
        extraSlaTwoList: extraSlaTwoList,
        notificationSwitches: notificationSwitches,
      );

  @override
  Future<List<ServicesHistoryModel>> getFilteredServices(
      List<ServicesHistoryModel> cubitServices, String userEmail, String userDepartment) async {
    return cubitServices.where((service) {
      // ✅ UPDATED: Use current getters
      final isLimited = service.currentLimitAvailability;
      final serviceDept = service.currentDepartmentRequester.toLowerCase().trim();
      final userDept = userDepartment.toLowerCase().trim();
      final sameDepartment = serviceDept == userDept;
      return isLimited ? sameDepartment : true;
    }).toList();
  }

  @override
  Future<Map<String, int>> getDepartmentCounts(
      List<ServicesHistoryModel> cubitServices, String userDepartment) async {
    final model = cubitServices;

    final departments = [
      "Executive",
      "Customer Support",
      "Operations",
      "Finance",
      "Information Technology",
      "Human Resources",
      "Marketing",
      "Sales",
      "Data Management",
      "Compliance & Legal",
      "Software"
    ];

    final departmentCounts = {for (var dept in departments) dept: 0};

    for (var service in model) {
      // ✅ UPDATED: Use current getters
      final isLimited = service.currentLimitAvailability;
      final serviceDept = service.currentDepartmentRequester.toLowerCase().trim();
      final userDept = userDepartment.toLowerCase().trim();
      final sameDepartment = serviceDept == userDept;

      if (!isLimited || sameDepartment) {
        final dept = service.currentDepartmentRequester;
        if (departmentCounts.containsKey(dept)) {
          departmentCounts[dept] = departmentCounts[dept]! + 1;
        }
      }
    }
    return departmentCounts;
  }

  @override
  Future<Map<String, dynamic>?> selectServiceProvider(String serviceId) async {
    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(serviceId)
        .get();
    if (doc.exists && doc.data() != null) {
      final providerData = doc.data()!['Provider_Services'];

      // ✅ UPDATED: Handle list format
      if (providerData is List && providerData.isNotEmpty) {
        final lastEntry = providerData.last;
        if (lastEntry is String) {
          try {
            final decoded = jsonDecode(lastEntry) as List;
            if (decoded.isNotEmpty) {
              return decoded[0] as Map<String, dynamic>;
            }
          } catch (e) {
          }
        }
      }
    }

    return null;
  }

  @override
  Future<Map<String, dynamic>?> getServiceDocById(String serviceId) async {
    // 24/9/2026: was the top-level `services` collection; services live
    // under the tenant: Demo/{companyId}/Modules/services/CreateServices.
    if (serviceId.isEmpty) return null;
    final doc = await firestore
        .collection(getBaseUrl('Modules/services/CreateServices'))
        .doc(serviceId)
        .get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  @override
  Future<List<ServicesHistoryModel>> getMyRequestServicesByRequester(
      String? email) async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where('Email_Requester', arrayContains: email)
        .get();
    return snapshot.docs
        .map((doc) => ServicesHistoryModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> appendRequestState({
    required String serviceId,
    required String? requesterEmail,
    required String newState,
  }) async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where('Email_Requester', arrayContains: requesterEmail)
        .get();
    final doc = snapshot.docs.firstWhere(
      (d) => d.id == serviceId,
      orElse: () => throw Exception('Document not found'),
    );
    await doc.reference.update({
      'state': FieldValue.arrayUnion([newState]),
      'timestamps':
          FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
    });
  }

  @override
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final doc = await firestore
        .collection(FirestoreCollections.users)
        .doc(email.toLowerCase())
        .get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getCreateServiceDocById(String serviceId) async {
    if (serviceId.isEmpty) return null;
    // 24/9/2026: resolved through the signed-in tenant (ApiConstants.baseUri)
    // instead of a SharedPreferences id with a hard-coded company fallback.
    final doc = await firestore
        .collection(getBaseUrl('Modules/services/CreateServices'))
        .doc(serviceId)
        .get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getRequestServiceDocsForApprover(
    String approverEmail,
  ) async {
    final tenantRoot = getBaseUrl(FirestoreCollections.requestServicesRoot);
    final userDocs = await firestore.collectionGroup('user').get();

    final result = <Map<String, dynamic>>[];
    for (final d in userDocs.docs) {
      if (!d.reference.path.startsWith('$tenantRoot/')) continue;
      result.add(d.data());
    }
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCreateServiceDocs() async {
    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getCreateServiceDocByIdUnderTenantRoot(
    String parentId,
  ) async {
    final doc = await firestore
        .doc('${getBaseUrl(FirestoreCollections.createServicesRoot)}/$parentId')
        .get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}
