part of './knowledge_hub_firebase_services.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 2 of KnowledgeHubFirebaseServices (kept under 800 LOC, §7).
extension KnowledgeHubServicesPart2 on KnowledgeHubFirebaseServices {

  /// Update existing knowledge document
Future<bool> updateKnowledgeHub({
  required String knowledgeId,
  String? knowledgeImage,
  String? nameEnglish,
  String? nameArabic,
  String? descriptionEnglish,
  String? descriptionArabic,
  String? knowledgeDocumentType,
  String? owningDepartment,
  List<String>? limitedDepartments,
  bool? schedulePublishing,
  DateTime? startDateTime,
  DateTime? endDateTime,
  String? imageUrl,
  String? documentUrl,
  String? documentFileName,
  String? timeStamp,
  String? status,
  String? startTime,      // ✅ ADD THIS
  String? endTime,        // ✅ ADD THIS
  // String? documentIcon,
  String? documentExtension,
  int? documentSize,
  // DateTime? documentUploadedDate,
  String? createdByEmail,
}) async {
  try {
    log('Updating knowledge with knowledgeId: $knowledgeId');

    // First, find the document by knowledgeId
    QuerySnapshot querySnapshot = await _firestore
        .collection(getBaseUrl(FirebaseCollections.createKnowledge))
        .where('knowledgeId', arrayContains: knowledgeId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) {
      log('No document found with knowledgeId: $knowledgeId');
      return false;
    }

    var doc = querySnapshot.docs.first;
    
    // Get existing data
    Map<String, dynamic> existingData = doc.data() as Map<String, dynamic>;
    CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(existingData, doc.id);

    // Create updated model using copyWith
    CreateKnowledgeModel updatedModel = existingModel.copyWith(
      knowledgeImage: knowledgeImage,
      nameEnglish: nameEnglish,
      nameArabic: nameArabic,
      descriptionEnglish: descriptionEnglish,
      descriptionArabic: descriptionArabic,
      knowledgeDocumentType: knowledgeDocumentType,
      owningDepartment: owningDepartment,
      limitedDepartments: limitedDepartments,
      schedulePublishing: schedulePublishing,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      imageUrl: imageUrl,
      documentUrl: documentUrl,
      documentFileName: documentFileName,
      timeStamp: timeStamp,
      documentExtension: documentExtension,
      documentSize: documentSize,
      status: status,
      startTime: startTime,     // ✅ ADD THIS
      endTime: endTime,         // ✅ ADD THIS
      createdByEmail: createdByEmail,
    );

    // Update the document
    Map<String, dynamic> updatedData = updatedModel.toJson();
    updatedData['updatedAt'] = FieldValue.serverTimestamp();

    await doc.reference.update(updatedData);

    log('Knowledge document updated successfully');
    return true;
  } catch (e) {
    log('Error updating knowledge hub: $e');
    return false;
  }
}


  Future<List<CreateKnowledgeModel>> fetchAllKnowledge() async {
    try {
      CollectionReference knowledgeRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));
      QuerySnapshot querySnapshot = await knowledgeRef.get();

      List<CreateKnowledgeModel> knowledgeList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Add document ID to the data
          data['id'] = doc.id;

          CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(data);
          knowledgeList.add(model);
        } catch (e) {
          log('Error parsing document ${doc.id}: $e');
        }
      }

      log('Fetched ${knowledgeList.length} knowledge documents');
      return knowledgeList;
    } catch (e) {
      log('Error fetching knowledge: $e');
      return [];
    }
  }


  /// Fetch knowledge documents filtered by department
  Future<List<CreateKnowledgeModel>> fetchKnowledgeByDepartment(
    String department,
  ) async {
    try {
      CollectionReference knowledgeRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));

      QuerySnapshot querySnapshot;

      if (department == 'All') {
        querySnapshot = await knowledgeRef.get();
      } else {
        querySnapshot = await knowledgeRef
            .where('owningDepartment.values', arrayContains: department)
            .get();
      }

      List<CreateKnowledgeModel> knowledgeList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(data);
          knowledgeList.add(model);
        } catch (e) {
          log('Error parsing document ${doc.id}: $e');
        }
      }

      log(
        'Fetched ${knowledgeList.length} knowledge documents for department: $department',
      );
      return knowledgeList;
    } catch (e) {
      log('Error fetching knowledge by department: $e');
      return [];
    }
  }


  /// Stream knowledge documents (real-time updates)
  Stream<List<CreateKnowledgeModel>> streamKnowledge() {
    try {
      return _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          // .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            List<CreateKnowledgeModel> knowledgeList = [];

            for (var doc in snapshot.docs) {
              try {
                Map<String, dynamic> data = doc.data();
                data['id'] = doc.id;

                CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(
                  data,
                );
                knowledgeList.add(model);
              } catch (e) {
                log('Error parsing document ${doc.id}: $e');
              }
            }

            return knowledgeList;
          });
    } catch (e) {
      log('Error streaming knowledge: $e');
      return Stream.value([]);
    }
  }


  /// Fetch single knowledge document by ID
  Future<CreateKnowledgeModel?> fetchKnowledgeById(String docId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .doc(docId)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CreateKnowledgeModel.fromJson(data);
      }

      return null;
    } catch (e) {
      log('Error fetching knowledge by ID: $e');
      return null;
    }
  }


  /// Search knowledge by name or description
  Future<List<CreateKnowledgeModel>> searchKnowledge(String searchQuery) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .get();
      List<CreateKnowledgeModel> knowledgeList = [];
      String lowerQuery = searchQuery.toLowerCase();

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(data);

          // Search in nameEnglish, nameArabic, descriptionEnglish, descriptionArabic
          String nameEn = model.nameEnglish.first.toLowerCase();
          String nameAr = model.nameArabic.first.toLowerCase();
          String descEn = model.descriptionEnglish.first.toLowerCase();
          String descAr = model.descriptionArabic.first.toLowerCase();

          if (nameEn.contains(lowerQuery) ||
              nameAr.contains(lowerQuery) ||
              descEn.contains(lowerQuery) ||
              descAr.contains(lowerQuery)) {
            knowledgeList.add(model);
          }
        } catch (e) {
          log('Error parsing document ${doc.id}: $e');
        }
      }

      log(
        'Found ${knowledgeList.length} knowledge documents matching: $searchQuery',
      );
      return knowledgeList;
    } catch (e) {
      log('Error searching knowledge: $e');
      return [];
    }
  }


  /// Filter knowledge by document type and department
  Future<List<CreateKnowledgeModel>> filterKnowledge({
    String? documentType,
    String? owningDepartment,
  }) async {
    try {
      Query query = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));
      // Apply filters if provided
      if (documentType != null && documentType.isNotEmpty) {
        query = query.where(
          'knowledgeDocumentType.values',
          arrayContains: documentType,
        );
      }

      if (owningDepartment != null &&
          owningDepartment.isNotEmpty &&
          owningDepartment != 'All') {
        query = query.where(
          'owningDepartment.values',
          arrayContains: owningDepartment,
        );
      }

      QuerySnapshot querySnapshot = await query.get();

      List<CreateKnowledgeModel> knowledgeList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(data);
          knowledgeList.add(model);
        } catch (e) {
          log('Error parsing document ${doc.id}: $e');
        }
      }

      log('Fetched ${knowledgeList.length} filtered knowledge documents');
      return knowledgeList;
    } catch (e) {
      log('Error filtering knowledge: $e');
      return [];
    }
  }


  Future<List<DepartmentModelPro>> fetchAllDepartments() async {
    try {
      CollectionReference knowledgeRef = _firestore
          .collection(getBaseUrl('Departments'));
      QuerySnapshot querySnapshot = await knowledgeRef.get();

      List<DepartmentModelPro> departmentsList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Add document ID to the data
          data['id'] = doc.id;

          DepartmentModelPro model = DepartmentModelPro.fromMap(data);
          departmentsList.add(model);
        } catch (e) {
          log('Error parsing document ${doc.id}: $e');
        }
      }

      log('Fetched ${departmentsList.length} departments');
      return departmentsList;
    } catch (e) {
      log('Error fetching knowledge: $e');
      return [];
    }
  }


  /// Fetch knowledge document by custom knowledgeId field (stored as array)
  Future<CreateKnowledgeModel?> fetchKnowledgeByKnowledgeId(
    String knowledgeId,
  ) async {
    try {
      log('Searching for knowledgeId: $knowledgeId');

      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          //Create_Knowledge
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .get();

      log('Query returned ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        log('Knowledge document fetched by knowledgeId: $knowledgeId');
        return CreateKnowledgeModel.fromJson(data, doc.id);
      }

      log('No knowledge document found with knowledgeId: $knowledgeId');
      return null;
    } catch (e) {
      log('Error fetching knowledge by knowledgeId: $e');
      return null;
    }
  }


  /// Soft-removes a knowledge document by appending a `removed` status and a
  /// timestamp. Owns all Firestore access + collection paths so the UI layer
  /// stays free of `FirebaseFirestore.instance` and hardcoded collection
  /// names (CR-KP-KH-S303 / S304).
  ///
  /// FIXED 22/9/2026 — "This knowledge document has already been removed or no
  /// longer exists." on EVERY remove from Knowledge Hub > document details.
  ///
  /// This method looked the document up with `.doc(knowledgeId)`, i.e. it
  /// treated `knowledgeId` as the FIRESTORE DOCUMENT ID. It is not. It is a
  /// history ARRAY field inside the document (`CreateKnowledgeModel.knowledgeId`
  /// is a `List<String>`, and the UI passes `currentKnowledgeId`, its last
  /// entry) — which is exactly why `removeKnowledgeWithReason` in part.1
  /// resolves it with `where('knowledgeId', arrayContains: ...)`. The `.doc()`
  /// read therefore never found anything, returned `notFound`, and the caller
  /// showed the "already removed" message on a document that was still there.
  ///
  /// Same lookup as `removeKnowledgeWithReason` now, so the two removal paths
  /// cannot drift apart again.
  Future<RemoveKnowledgeResult> removeKnowledgeById(String knowledgeId) async {
    try {
      final querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return RemoveKnowledgeResult.notFound;
      }

      final docSnapshot = querySnapshot.docs.first;
      final docRef = docSnapshot.reference;
      final data = docSnapshot.data() as Map<String, dynamic>;
      final statusArray = List<dynamic>.from(data['status'] ?? []);
      final timestampsArray = List<dynamic>.from(data['timestamps'] ?? []);

      if (statusArray.contains('removed')) {
        return RemoveKnowledgeResult.alreadyRemoved;
      }

      statusArray.add('removed');
      timestampsArray.add(DateTime.now().millisecondsSinceEpoch);

      await docRef.update({
        'status': statusArray,
        'timestamps': timestampsArray,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return RemoveKnowledgeResult.success;
    } catch (e) {
      log('Error removing knowledge: $e');
      return RemoveKnowledgeResult.error;
    }
  }

}
