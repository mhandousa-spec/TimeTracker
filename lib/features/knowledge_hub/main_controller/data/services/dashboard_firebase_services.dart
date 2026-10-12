/// Module: knowledge_hub_module / core/dashboard_firebase_services.dart
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_firebase_services.dart
/// Purpose: Firebase services for Dashboard screen - fetches aggregated data
/// Author: Youssef Khaled
/// Created At: 28/10/2025

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import '../models/approval_model.dart';
import '../models/create_knowledge_new_model.dart';
import '../models/document_utilization_model.dart';

class DashboardFirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all knowledge documents for dashboard analytics
  Future<List<CreateKnowledgeModel>> fetchAllKnowledgeDocuments() async {
    try {
      CollectionReference knowledgeRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));
      QuerySnapshot querySnapshot = await knowledgeRef.get();

      List<CreateKnowledgeModel> knowledgeList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(
            data,
            doc.id,
          );
          knowledgeList.add(model);
        } catch (e) {
          log('Error parsing document ${doc.id}: $e');
        }
      }

      log('✅ [Dashboard] Fetched ${knowledgeList.length} knowledge documents');
      return knowledgeList;
    } catch (e) {
      log('❌ [Dashboard] Error fetching knowledge documents: $e');
      return [];
    }
  }

  Future<Map<String, String>> fetchMultipleDepartmentNamesWithLocale(
      List<String> departmentIds,
      ) async {
    if (departmentIds.isEmpty) return {};

    try {
      // Check if current locale is English
      final isEnglish = Get.locale.toString().contains('en');

      Map<String, String> departmentNames = {};

      // Fetch departments in batches (Firestore allows max 10 items in 'whereIn')
      for (int i = 0; i < departmentIds.length; i += 10) {
        final batch = departmentIds.skip(i).take(10).toList();

        final snapshot = await FirebaseFirestore.instance
            .collection('Departments')
            .where('Department_ID', whereIn: batch)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final deptId = data['Department_ID'] as String?;

          if (deptId != null) {
            // Get name based on locale
            final deptName = isEnglish
                ? (data['Department_Name'] as String? ?? deptId)
                : (data['Department_Name_In_Arabic'] as String? ?? deptId);

            departmentNames[deptId] = deptName;
          }
        }
      }

      log('✅ [DashboardFirebaseServices] Fetched ${departmentNames.length} department names (${isEnglish ? "English" : "Arabic"})');
      return departmentNames;
    } catch (e) {
      log('❌ [DashboardFirebaseServices] Error fetching department names: $e');
      return {};
    }
  }

  /// Fetch all approvals for dashboard analytics
  Future<List<ApprovalModel>> fetchAllApprovals() async {
    try {
      CollectionReference approvalsRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeApprovals));
      QuerySnapshot querySnapshot = await approvalsRef.get();

      List<ApprovalModel> approvalsList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          ApprovalModel model = ApprovalModel.fromJson(data, doc.id);
          approvalsList.add(model);
        } catch (e) {
          log('Error parsing approval ${doc.id}: $e');
        }
      }

      log('✅ [Dashboard] Fetched ${approvalsList.length} approvals');
      return approvalsList;
    } catch (e) {
      log('❌ [Dashboard] Error fetching approvals: $e');
      return [];
    }
  }

  /// Fetch all document utilization records
  Future<List<DocumentUtilizationModel>> fetchAllDocumentUtilization() async {
    try {
      CollectionReference utilizationRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization));


      QuerySnapshot querySnapshot = await utilizationRef.get();

      List<DocumentUtilizationModel> utilizationList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DocumentUtilizationModel model = DocumentUtilizationModel.fromJson(data);
          utilizationList.add(model);
        } catch (e) {
          log('Error parsing utilization ${doc.id}: $e');
        }
      }

      log('✅ [Dashboard] Fetched ${utilizationList.length} utilization records');
      return utilizationList;
    } catch (e) {
      log('❌ [Dashboard] Error fetching utilization: $e');
      return [];
    }
  }

  /// Fetch department name by ID
  Future<String> fetchDepartmentNameById(String departmentId) async {
    try {
      if (departmentId.isEmpty) {
        log('⚠️ Empty department ID provided');
        return 'Unknown Department';
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl('Departments'))
          .where('Department_ID', isEqualTo: departmentId)
          .limit(1)
          .get();

      //Departments
      if (querySnapshot.docs.isEmpty) {
        log('⚠️ No department found with ID: $departmentId');
        return departmentId;
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      String departmentName =
          data['Department_Name'] as String? ?? 'Unknown Department';

      return departmentName;
    } catch (e) {
      log('❌ Error fetching department by ID: $e');
      return departmentId;
    }
  }

  /// Batch fetch department names
  Future<Map<String, String>> fetchMultipleDepartmentNames(
    List<String> departmentIds,
  ) async {
    try {
      if (departmentIds.isEmpty) return {};

      final uniqueIds = departmentIds.toSet().toList();
      Map<String, String> departmentMap = {};

      for (int i = 0; i < uniqueIds.length; i += 10) {
        final batch = uniqueIds.skip(i).take(10).toList();

        QuerySnapshot querySnapshot = await _firestore
            .collection(getBaseUrl('Departments'))
            .where('Department_ID', whereIn: batch)
            .get();
        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            String? deptId = data['Department_ID'] as String?;
            String? deptName = data['Department_Name'] as String?;

            if (deptId != null && deptId.isNotEmpty && deptName != null) {
              departmentMap[deptId] = deptName;
            }
          } catch (e) {
            log('❌ Error parsing department doc ${doc.id}: $e');
          }
        }
      }

      return departmentMap;
    } catch (e) {
      log('❌ Error fetching multiple department names: $e');
      return {};
    }
  }

  /// Stream dashboard data for real-time updates
  Stream<List<CreateKnowledgeModel>> streamKnowledgeDocuments() {
    try {
      return _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .snapshots()
          .map((snapshot) {
            List<CreateKnowledgeModel> knowledgeList = [];

            for (var doc in snapshot.docs) {
              try {
                Map<String, dynamic> data = doc.data();
                CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(
                  data,
                  doc.id,
                );
                knowledgeList.add(model);
              } catch (e) {
                log('Error parsing document ${doc.id}: $e');
              }
            }

            return knowledgeList;
          });
    } catch (e) {
      log('❌ Error streaming knowledge documents: $e');
      return Stream.value([]);
    }
  }

  /// Stream document utilization for real-time updates
  Stream<List<DocumentUtilizationModel>> streamDocumentUtilization() {
    try {
      return _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))
          .snapshots()
          .map((snapshot) {
            List<DocumentUtilizationModel> utilizationList = [];

            for (var doc in snapshot.docs) {
              try {
                Map<String, dynamic> data = doc.data();
                DocumentUtilizationModel model =
                    DocumentUtilizationModel.fromJson(data);
                utilizationList.add(model);
              } catch (e) {
                log('Error parsing utilization ${doc.id}: $e');
              }
            }

            return utilizationList;
          });
    } catch (e) {
      log('❌ Error streaming utilization: $e');
      return Stream.value([]);
    }
  }
}