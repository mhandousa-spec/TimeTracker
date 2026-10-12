// ******************* FILE INFO *******************
// File Name: service_doc_fetcher
// Description: Firestore reads for fetching a service document to edit
//              (CreateServices / myCreateRequests / AllServices) plus the
//              diagnostic structure dump. Extracted from ServicesManagerCubit.
// Module: services_management_module / data / helper
// *************************************************

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

/// Result of a fetch-to-edit operation. [error] is null on success.
class FetchedServiceDoc {
  final Map<String, dynamic>? rawJson;
  final ServicesHistoryModel? model;
  final String? error;

  const FetchedServiceDoc({this.rawJson, this.model, this.error});

  bool get isSuccess => error == null && model != null;
}

class ServiceDocFetcher {
  ServiceDocFetcher({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Resolves the creator email from AllServices, then loads the editable doc
  /// from CreateServices (falling back to myCreateRequests).
  Future<FetchedServiceDoc> fetchDocToEdit(String serviceId) async {
    try {
      // ✅ First, get from AllServices to find the email
      final allServicesDoc = await _firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(serviceId)
          .get();

      if (!allServicesDoc.exists) {
        return const FetchedServiceDoc(error: 'Service not found');
      }

      final allServicesData = allServicesDoc.data()!;

      String? emailFromAllServices;
      if (allServicesData['Email_Requester'] is List) {
        emailFromAllServices = (allServicesData['Email_Requester'] as List).last?.toString();
      } else {
        emailFromAllServices = allServicesData['Email_Requester']?.toString();
      }

      if (emailFromAllServices == null || emailFromAllServices.isEmpty) {
        return const FetchedServiceDoc(error: 'Creator email not found');
      }

      emailFromAllServices = emailFromAllServices.trim().toLowerCase();

      DocumentSnapshot<Map<String, dynamic>>? doc;

      // ✅ Try to get from CreateServices using query
      try {
        final querySnapshot = await _firestore
            .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
            .where("Email_Requester", arrayContains: emailFromAllServices)
            .get();

        // Find the specific document by serviceId
        final foundDoc = querySnapshot.docs.firstWhere(
              (d) => d.id == serviceId,
          orElse: () => throw Exception("Document not found"),
        );

        if (foundDoc.exists) {
          doc = foundDoc;
        }
      } catch (e) {
      }

      // 24/9/2026: removed the legacy fallback that read
      // Demo/36898316/myCreateRequests — a hardcoded company outside the
      // services module root. All services live under Modules/services now.

      if (doc != null && doc.exists) {
        final raw = doc.data();
        final model = ServicesHistoryModel.fromJson(doc.data()!, doc.id);
        return FetchedServiceDoc(rawJson: raw, model: model);
      } else {
        return const FetchedServiceDoc(error: 'Service not found');
      }
    } catch (e) {
      return FetchedServiceDoc(error: 'Error: $e');
    }
  }

  /// Same as [fetchDocToEdit] but returns null on any failure (no error text).
  Future<FetchedServiceDoc?> fetchDocToEditSilent(String serviceId) async {
    try {
      final allServicesDoc = await _firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(serviceId)
          .get();

      if (!allServicesDoc.exists) {
        return null;
      }

      final allServicesData = allServicesDoc.data()!;

      // ✅ Extract and normalize email
      String? creatorEmail;
      if (allServicesData['Email_Requester'] is List) {
        creatorEmail = (allServicesData['Email_Requester'] as List).last?.toString();
      } else {
        creatorEmail = allServicesData['Email_Requester']?.toString();
      }

      if (creatorEmail == null || creatorEmail.isEmpty) {
        return null;
      }

      // ✅ CRITICAL FIX: Normalize to lowercase and trim
      creatorEmail = creatorEmail.trim().toLowerCase();

      // ✅ Query documents where emailRequester contains the creator's email
      final querySnapshot = await _firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .where("Email_Requester", arrayContains: creatorEmail)
          .get();

      // ✅ Find the specific document by serviceId
      final doc = querySnapshot.docs.firstWhere(
            (doc) => doc.id == serviceId,
        orElse: () => throw Exception("Document not found"),
      );

      if (doc.exists) {
        final raw = doc.data();
        final model = ServicesHistoryModel.fromJson(doc.data(), doc.id);
        return FetchedServiceDoc(rawJson: raw, model: model);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Loads a doc directly from AllServices (no email indirection), null on fail.
  Future<FetchedServiceDoc?> fetchDocAllToEditSilent(String serviceId) async {
    try {
      final doc = await _firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(serviceId)
          .get();

      if (doc.exists) {
        final raw = doc.data();
        final model = ServicesHistoryModel.fromJson(doc.data()!, doc.id);
        return FetchedServiceDoc(rawJson: raw, model: model);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Loads a doc directly from AllServices, returning an error string on fail.
  Future<FetchedServiceDoc> fetchDocAllToEdit(String serviceId) async {
    try {
      final doc = await _firestore
          .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
          .doc(serviceId)
          .get();

      if (doc.exists) {
        final raw = doc.data();
        final model = ServicesHistoryModel.fromJson(doc.data()!, doc.id);
        return FetchedServiceDoc(rawJson: raw, model: model);
      } else {
        return const FetchedServiceDoc(error: 'Service not found');
      }
    } catch (e) {
      return FetchedServiceDoc(error: 'Error fetching document: $e');
    }
  }

  /// Diagnostic: walks CreateServices/AllServices for the given service id.
  /// Side-effect free (read-only); retained for parity with the original cubit.
  Future<void> debugCreateServicesStructure(String serviceId) async {
    try {
      final createServicesPath = getBaseUrl(FirestoreCollections.createServicesRoot);

      // Path may be any odd-segment length
      // (e.g. Demo/{id}/Modules/services/CreateServices).
      // Firestore.collection() accepts a full slash-delimited path directly.
      final CollectionReference<Map<String, dynamic>> createServicesCollection =
          _firestore.collection(createServicesPath);

      final snapshot = await createServicesCollection.get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (int i = 0; i < min(5, snapshot.docs.length); i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        String serviceName = 'N/A';
        if (data['serviceNameEnglish'] is List && (data['serviceNameEnglish'] as List).isNotEmpty) {
          serviceName = (data['serviceNameEnglish'] as List).last.toString();
        } else if (data['serviceNameEnglish'] is String) {
          serviceName = data['serviceNameEnglish'].toString();
        }

        String email = 'N/A';
        if (data['emailRequester'] is List && (data['emailRequester'] as List).isNotEmpty) {
          email = (data['emailRequester'] as List).last.toString();
        } else if (data['emailRequester'] is String) {
          email = data['emailRequester'].toString();
        }
      }

      final serviceDoc = await createServicesCollection.doc(serviceId).get();

      if (serviceDoc.exists) {
        final data = serviceDoc.data();
        if (data != null) {
          if (data.containsKey('emailRequester')) {
            final emailReq = data['emailRequester'];
          }
          if (data.containsKey('serviceNameEnglish')) {
            final serviceName = data['serviceNameEnglish'];
          }
          if (data.containsKey('status')) {
            final status = data['status'];
          }
        }
      }

      final allServicesPath = getBaseUrl(FirestoreCollections.createServicesRoot);

      final DocumentReference<Map<String, dynamic>> allServicesDoc =
          _firestore.collection(allServicesPath).doc(serviceId);

      final allServicesSnapshot = await allServicesDoc.get();

      if (allServicesSnapshot.exists) {
        final data = allServicesSnapshot.data();
        if (data != null && data.containsKey('emailRequester')) {
          final emailReq = data['emailRequester'];
          String extractedEmail = '';
          if (emailReq is List && emailReq.isNotEmpty) {
            extractedEmail = emailReq.last.toString();
          } else if (emailReq is String) {
            extractedEmail = emailReq;
          }
        }
      }

      if (serviceDoc.exists) {
        final data = serviceDoc.data();
        if (data != null && data.containsKey('emailRequester')) {
          String testEmail = '';
          if (data['emailRequester'] is List && (data['emailRequester'] as List).isNotEmpty) {
            testEmail = (data['emailRequester'] as List).last.toString().trim().toLowerCase();
          } else if (data['emailRequester'] is String) {
            testEmail = data['emailRequester'].toString().trim().toLowerCase();
          }

          if (testEmail.isNotEmpty) {
            final querySnapshot = await createServicesCollection
                .where("emailRequester", arrayContains: testEmail)
                .get();

            final foundInQuery = querySnapshot.docs.any((doc) => doc.id == serviceId);
          }
        }
      }
    } catch (e, stackTrace) {
    }
  }
}
