// ******************* FILE INFO *******************
// File Name: services_remote_data_source
// Description: Remote (Firestore) data source for the services module. Holds the
//              heavier approval/provider/statistics/request Firestore operations
//              so the repository only delegates and maps (R02).
// Module: services_management_module / data / data_source / remote_data_source
// *************************************************

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/helper/main_helper/current_user_context.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/state_model.dart';

class ServicesRemoteDataSource {
  final FirebaseFirestore firestore;

  ServicesRemoteDataSource(this.firestore);

  // R01: current user's email from the data-layer context (no presentation dep).
  String get _email => CurrentUserContext.email ?? '';

  Future<List<ServicesHistoryModel>> getApprovalServices(String email) async {
    final String target = email.trim().toLowerCase();
    final String tenantRoot = getBaseUrl(FirestoreCollections.requestServicesRoot);

    final List<ServicesHistoryModel> servicesList = [];

    try {
      // ✅ Path may be any odd-segment length
      // (e.g. Demo/{id}/Modules/services/RequestServices).
      // Firestore.collection() accepts a full slash-delimited path directly.
      final CollectionReference<Map<String, dynamic>> requestsCollection =
          firestore.collection(tenantRoot);

      // ✅ Get ALL documents
      final querySnapshot = await requestsCollection.get();

      if (querySnapshot.docs.isEmpty) {
        return servicesList;
      }

      int processedCount = 0;
      int foundWithApprovalCycle = 0;
      int matchedEmail = 0;

      for (var doc in querySnapshot.docs) {
        processedCount++;
        final data = doc.data();

        // ✅ Check BOTH field name variations (camelCase and PascalCase with underscore)
        dynamic approvalCycleData = data['Approval_Cycle'] ?? data['Approval_Cycle'];

        if (approvalCycleData == null) {
          continue;
        }

        if (approvalCycleData is! List || approvalCycleData.isEmpty) {
          continue;
        }

        foundWithApprovalCycle++;

        final lastEntry = approvalCycleData.last;

        if (lastEntry is! String) {
          continue;
        }

        try {
          final decoded = jsonDecode(lastEntry) as List;

          // Print all approvers
          for (int i = 0; i < decoded.length; i++) {
            final approver = decoded[i];
            final approverEmail = (approver['email'] ?? '').toString().toLowerCase().trim();
            final approverName = '${approver['firstName'] ?? ''} ${approver['lastName'] ?? ''}'.trim();
            final approverState = approver['state'] ?? 'unknown';

          }

          // Check if target email exists
          bool found = false;
          for (var approver in decoded) {
            final approverEmail = (approver['email'] ?? '').toString().toLowerCase().trim();

            if (approverEmail == target) {
              found = true;
              matchedEmail++;
              break;
            }
          }

          if (found) {
            try {
              final model = ServicesHistoryModel.fromJson(data, doc.id);
              servicesList.add(model);
            } catch (e, stackTrace) {
            }
          }

        } catch (e, stackTrace) {
        }
      }

    } catch (e, stackTrace) {
    }

    return servicesList;
  }

  Future<Map<String, Map<String, dynamic>>> getServiceProviderPerDoc() async {
    final Map<String, int> providerGlobalCount = {};
    final Map<String, Map<String, dynamic>> finalProviders = {};

    final allDocs = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where("Email_Requester",arrayContains: _email)

        .get();

    final docs = allDocs.docs;

    for (var doc in docs) {
      // ✅ UPDATED: Handle list format for providerServices
      final providerData = doc.data()['Provider_Services'];
      List<dynamic>? providerList;

      if (providerData is List && providerData.isNotEmpty) {
        // Get the last entry from history
        final lastEntry = providerData.last;
        if (lastEntry is String) {
          try {
            providerList = jsonDecode(lastEntry) as List;
          } catch (e) {
          }
        }
      }

      if (providerList != null) {
        final Set<String> uniqueEmailsInDoc = {};
        for (var provider in providerList) {
          final email = provider['email'];
          if (email != null) {
            uniqueEmailsInDoc.add(email);
          }
        }
        for (var email in uniqueEmailsInDoc) {
          providerGlobalCount[email] = (providerGlobalCount[email] ?? 0) + 1;
        }
      }
    }

    for (var doc in docs) {
      final docId = doc.id;
      final providerData = doc.data()['Provider_Services'];
      List<dynamic>? providerList;

      if (providerData is List && providerData.isNotEmpty) {
        final lastEntry = providerData.last;
        if (lastEntry is String) {
          try {
            providerList = jsonDecode(lastEntry) as List;
          } catch (e) {
          }
        }
      }

      if (providerList != null && providerList.isNotEmpty) {
        Map<String, dynamic>? selectedProvider;
        int minAppearances = 999999;

        for (var provider in providerList) {
          final email = provider['email'];
          if (email != null) {
            final count = providerGlobalCount[email] ?? 0;
            if (count < minAppearances) {
              selectedProvider = provider;
              minAppearances = count;
            }
          }
        }

        if (selectedProvider != null) {
          finalProviders[docId] = selectedProvider;
        }
      }
    }

    return finalProviders;
  }

  Future<void> updateApprovalState({
    required String docID,
    required String email,
    required String newState,
  }) async {
    final String tenantRoot = getBaseUrl(FirestoreCollections.requestServicesRoot);
    final String target = email.toLowerCase().trim();

    String? _keyEq(Map<String, dynamic> m, String wantLower) {
      for (final k in m.keys) {
        if (k.toLowerCase() == wantLower) return k;
      }
      return null;
    }

    // ✅ FIXED: Query the flat collection directly
    final docPath = '$tenantRoot/$docID';

    final docRef = firestore.doc(docPath);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception('Request "$docID" not found at $docPath');
    }

    final data = docSnapshot.data() as Map<String, dynamic>;

    final cycleKey = _keyEq(data, 'Approval_Cycle') ?? _keyEq(data, 'Approval_Cycle');

    String updatePath;
    List<dynamic> approvalList;

    if (cycleKey != null) {
      final cycleNode = data[cycleKey];
      // Handle list format
      if (cycleNode is List && cycleNode.isNotEmpty) {
        final lastEntry = cycleNode.last;
        if (lastEntry is String) {
          try {
            approvalList = List<Map<String, dynamic>>.from(jsonDecode(lastEntry) as List);
            updatePath = cycleKey;
          } catch (e) {
            throw Exception('Failed to decode approval cycle: $e');
          }
        } else {
          approvalList = List<Map<String, dynamic>>.from(cycleNode);
          updatePath = cycleKey;
        }
      } else {
        throw Exception('Unsupported shape for "$cycleKey".');
      }
    } else if (data.containsKey('Approval_Cycle.value')) {
      final v = data['Approval_Cycle.value'];
      if (v is List) {
        approvalList = List<Map<String, dynamic>>.from(v);
        updatePath = 'Approval_Cycle.value';
      } else {
        throw Exception('Unsupported shape for "Approval_Cycle.value".');
      }
    } else {
      throw Exception('No approval cycle field found.');
    }

    final idx = approvalList.indexWhere((item) {
      if (item is Map) {
        final em = (item['email'] ?? '').toString().toLowerCase().trim();
        return em == target;
      }
      return false;
    });

    if (idx == -1) {
      throw Exception('Target email "$email" not found in approval list.');
    }

    (approvalList[idx] as Map<String, dynamic>)['state'] = newState;

    // Use FieldValue.arrayUnion to add new entry to history
    await docRef.update({
      updatePath: FieldValue.arrayUnion([jsonEncode(approvalList)]),
      'timestamps': FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
    });

  }

  Future<void> addRequestedService({
    required String docId,
    required RequestedServices requestModel,
    required String uidUser
  }) async {
    try {
      // Verify the parent service document exists.
      final parentDocRef = firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(docId);

      final parentDoc = await parentDocRef.get();

      // ✅ FIX ("Error occurred" on Request Service): the guard here was
      //   parentDoc.data()?['Email_Requester'] != _email
      // and it rejected EVERY request, for two independent reasons.
      //
      // 1. Type mismatch. `Email_Requester` is a history ARRAY on these
      //    documents (see ServicesHistoryModel — every field is a list of
      //    revisions, and getRequestedServices below queries it with
      //    `arrayContains`). Comparing a List to a String with `!=` is always
      //    true, so the exception fired even for the document's own owner.
      //
      // 2. Wrong ownership question. `docId` is the parent SERVICE, which is
      //    authored by whoever created the service. The person requesting it
      //    is by definition someone else. Requiring the two to match meant a
      //    user could only request services they had created themselves.
      //
      // The caller on the service card ignored the returned bool, so this
      // failure was invisible there — the request silently never reached the
      // requestServices sub-collection while the UI still showed success. The
      // details page does check it, which is where "Error occurred" surfaced.
      //
      // Existence of the service is the real precondition; per-user access is
      // enforced by the Firestore rules and by the visibility filters that
      // decide which services are listed in the first place.
      if (!parentDoc.exists) {
        throw Exception("Service not found: $docId");
      }

      // Add the requested service
      await parentDocRef
          .collection(FirestoreCollections.requestServices)
          .add({
        "uidUser": uidUser,
        "Email_Requester": _email,
        ...requestModel.toJson(),
      });
    } catch (e) {
      throw Exception("Failed to add requested service: $e");
    }
  }

  Future<List<RequestedServices>> getRequestedServices({
    required String docId,
  }) async
  {
    try {
      final querySnapshot = await firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(docId)
          .collection(FirestoreCollections.requestServices)
          .where("Email_Requester", arrayContains: _email)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RequestedServices.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch requested services: $e");
    }
  }

  Future<StateStatisticsModel> fetchStateStatistics(String parentDocId) async {
    int approved = 0;
    int cancel = 0;
    int pending = 0;
    int rejected = 0;
    int inProgress = 0;
    int branchSla = 0;
    int done = 0;

    final snapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where("Email_Requester",arrayContains: _email)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // ✅ UPDATED: Handle list format for state
      String? outerState;
      if (data['state'] is List && (data['state'] as List).isNotEmpty) {
        outerState = (data['state'] as List).last.toString().toLowerCase();
      } else if (data['state'] is String) {
        outerState = data['state'].toString().toLowerCase();
      }

      // ✅ UPDATED: Handle list format for approvalCycle
      List<dynamic> approvalCycleList = [];
      if (data['approvalCycle'] is List && (data['approvalCycle'] as List).isNotEmpty) {
        final lastEntry = (data['approvalCycle'] as List).last;
        if (lastEntry is String) {
          try {
            approvalCycleList = jsonDecode(lastEntry) as List;
          } catch (e) {
          }
        }
      }

      bool counted = false;

      switch (outerState) {
        case 'inprogress':
          inProgress++;
          counted = true;
          break;
        case 'approved':
          approved++;
          counted = true;
          break;
        case 'done':
          done++;
          counted = true;
          break;
        case 'cancel':
          cancel++;
          counted = true;
          break;
        case 'branchsla':
          branchSla++;
          counted = true;
          break;
      }

      if (!counted && approvalCycleList.isNotEmpty) {
        for (var approver in approvalCycleList) {
          final innerState = approver['state']?.toString().toLowerCase();
          switch (innerState) {
            case 'approved':
              approved++;
              counted = true;
              break;
            case 'rejected':
              rejected++;
              counted = true;
              break;
            case 'pending':
              pending++;
              counted = true;
              break;
          }
          if (counted) break;
        }
      }

      if (data['branchSla'] == true) {
        branchSla++;
      }
    }

    return StateStatisticsModel(
      approvedCount: approved,
      cancelCount: cancel,
      pendingCount: pending,
      rejectedCount: rejected,
      inProgressCount: inProgress,
      branchSlaCount: branchSla,
      doneCount: done,
    );
  }

  Future<Map<String, int>> getDoneServicesCountByParent() async {
    final Map<String, int> doneCounts = {};
    final allRequests = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .get();

    for (final doc in allRequests.docs) {
      final data = doc.data();

      // Parent_Service_Id may be an array — take the first element.
      final rawParentId = data['Parent_Service_Id'];
      String parentId = '';
      if (rawParentId is List && rawParentId.isNotEmpty) {
        parentId = rawParentId.first.toString().trim();
      } else if (rawParentId is String) {
        parentId = rawParentId.trim();
      }
      if (parentId.isEmpty) continue;

      // state may also be an array — take the first element.
      final rawState = data['state'];
      String stateValue = '';
      if (rawState is List && rawState.isNotEmpty) {
        stateValue = rawState.first.toString().toLowerCase().trim();
      } else if (rawState is String) {
        stateValue = rawState.toLowerCase().trim();
      }

      if (stateValue == 'done') {
        doneCounts[parentId] = (doneCounts[parentId] ?? 0) + 1;
      }
    }
    return doneCounts;
  }

  Future<void> editService(String docId, ServicesHistoryModel updatedModel) async {
    final docRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId);

    // ✅ Fetch existing document first
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception("Service not found: $docId");
    }

    // ✅ Parse existing model
    final existingModel = ServicesHistoryModel.fromJson(
      docSnapshot.data()!,
      docId,
    );

    // ✅ FIX (status switch): `status` was never forwarded here, so the
    // Active/Inactive toggle set on the create/edit screen was silently
    // dropped on save and the service stayed under the Active filter.
    // copyWith APPENDS a revision, so only pass it when it actually changed.
    final incomingStatus = updatedModel.currentStatus.trim();
    final statusChanged = incomingStatus.isNotEmpty &&
        incomingStatus.toLowerCase() !=
            existingModel.currentStatus.trim().toLowerCase();

    // ✅ FIX 30/8/2026 (same bug as `updateService` below): `imageUrl` was not
    // in this copyWith, so editing a service to ADD or CHANGE its picture
    // re-wrote whatever image the document already had — usually none. The
    // upload succeeded, the form showed it, and the save silently discarded
    // it. Like `status`, only pass it on a real change: copyWith APPENDS a
    // revision, so passing it every save would grow the history array forever.
    final incomingImageUrl = updatedModel.currentImageUrl.trim();
    final imageChanged = incomingImageUrl != existingModel.currentImageUrl.trim();

    // ✅ Create updated model using copyWith to preserve history
    final newModel = existingModel.copyWith(
      status: statusChanged ? incomingStatus : null,
      imageUrl: imageChanged ? incomingImageUrl : null,
      serviceNameEnglish: updatedModel.currentServiceNameEnglish,
      serviceNameArabic: updatedModel.currentServiceNameArabic,
      serviceDescriptionEnglish: updatedModel.currentServiceDescriptionEnglish,
      serviceDescriptionArabic: updatedModel.currentServiceDescriptionArabic,
      durationOfServices: updatedModel.currentDurationOfServices,
      selectedDurationUnit: updatedModel.currentSelectedDurationUnit,
      providerServices: updatedModel.currentProviderServices,
      approvalCycle: updatedModel.currentApprovalCycle,
      selectDepartment: updatedModel.currentSelectDepartment,
      limitAvailability: updatedModel.currentLimitAvailability,
      requireApproval: updatedModel.currentRequireApproval,
      slaOneControllerEnglish: updatedModel.currentSlaOneControllerEnglish,
      slaTwoControllerEnglish: updatedModel.currentSlaTwoControllerEnglish,
      notifyRequesterChecked: updatedModel.currentNotifyRequesterChecked,
      notifyProviderChecked: updatedModel.currentNotifyProviderChecked,
      notifyManagerChecked: updatedModel.currentNotifyManagerChecked,
      // Add other fields as needed
    );

    // ✅ Save with full data (not just create data)
    await docRef.set(
      newModel.toJson(),  // ✅ Use full toJson() to preserve all fields
      SetOptions(merge: false),  // ✅ Replace entire document
    );
  }

// ==========================================
// ✅ COMPLETE FIXED updateService METHOD
// ==========================================
// Replace your ENTIRE updateService method with this code

// ==========================================
// ✅ COMPLETE FIXED updateService METHOD
// ==========================================
// Replace your ENTIRE updateService method with this code

  Future<void> updateService(String docId, ServicesHistoryModel model) async {

    // ✅ STEP 1: Fetch existing document from CreateServices
    final createServicesRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(docId);

    final docSnapshot = await createServicesRef.get();

    if (!docSnapshot.exists) {
      throw Exception("Service document not found: $docId");
    }

    // ✅ STEP 2: Parse existing model to preserve ALL fields
    final existingModel = ServicesHistoryModel.fromJson(
      docSnapshot.data()!,
      docId,
    );

    // ✅ FIX (status switch): same bug as editService — `status` was not part
    // of this copyWith, so editing a service and flipping the Active/Inactive
    // switch re-wrote the OLD status read back from Firestore. The service
    // therefore never moved into the "Inactive" filter on the home page.
    // copyWith APPENDS to the status history, so only pass it on a real change.
    final incomingStatus = model.currentStatus.trim();
    final statusChanged = incomingStatus.isNotEmpty &&
        incomingStatus.toLowerCase() !=
            existingModel.currentStatus.trim().toLowerCase();

    // ✅ FIX 30/8/2026: `imageUrl` was missing from this copyWith too, so the
    // edit path re-wrote the document's OLD image and threw away the one the
    // user had just uploaded. Only passed on a real change — copyWith appends
    // a revision, so an unchanged URL would be re-appended on every save.
    final incomingImageUrl = model.currentImageUrl.trim();
    final imageChanged = incomingImageUrl != existingModel.currentImageUrl.trim();

    // ✅ STEP 3: Create updated model using copyWith (preserves history)
    final newModel = existingModel.copyWith(
      status: statusChanged ? incomingStatus : null,
      imageUrl: imageChanged ? incomingImageUrl : null,
      serviceNameEnglish: model.currentServiceNameEnglish,
      serviceNameArabic: model.currentServiceNameArabic,
      serviceDescriptionEnglish: model.currentServiceDescriptionEnglish,
      serviceDescriptionArabic: model.currentServiceDescriptionArabic,
      durationOfServices: model.currentDurationOfServices,
      selectedDurationUnit: model.currentSelectedDurationUnit,
      providerServices: model.currentProviderServices,
      approvalCycle: model.currentApprovalCycle,
      selectDepartment: model.currentSelectDepartment,
      limitAvailability: model.currentLimitAvailability,
      requireApproval: model.currentRequireApproval,
      slaOneControllerEnglish: model.currentSlaOneControllerEnglish,
      slaTwoControllerEnglish: model.currentSlaTwoControllerEnglish,
      // slaOneControllerArabic: model.currentSlaOneControllerArabic,
      // slaTwoControllerArabic: model.currentSlaTwoControllerArabic,
      notifyRequesterChecked: model.currentNotifyRequesterChecked,
      notifyProviderChecked: model.currentNotifyProviderChecked,
      notifyManagerChecked: model.currentNotifyManagerChecked,
      notifyRequesterSwitch0: model.currentNotifyRequesterSwitch0,
      notifyManagerSwitch1: model.currentNotifyManagerSwitch1,
      // notificationSwitches: model.currentNotificationSwitches,
      // extraSlaList: model.currentExtraSlaList,
      // extraSlaTwoList: model.currentExtraSlaTwoList,
    );

    // ✅ STEP 4: Convert to JSON using FULL toJson() (NOT toJsonForCreate!)
    final jsonData = newModel.toJson();

    // ✅ STEP 5: Update CreateServices
    await createServicesRef.set(
      jsonData,
      SetOptions(merge: false),  // Complete replacement
    );

    // ✅ STEP 6: Update myCreateRequests (allServices)
    final allServicesRef = firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))  // This is "myCreateRequests"
        .doc(docId);

    try {
      await allServicesRef.set(
        jsonData,
        SetOptions(merge: true),  // Merge in case doc doesn't exist
      );
    } catch (e) {
    }

  }

}
