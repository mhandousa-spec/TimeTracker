part of './approvals_firebase_services.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 1 of ApprovalsFirebaseServices (kept under 800 LOC, §7).
extension ApprovalsServicesPart1 on ApprovalsFirebaseServices {

  /// ✅ HELPER: Get dynamic company ID from ApiConstants
  String _getCompanyId() {
    String companyId = ApiConstants.baseUri.split("/").last;
    if (companyId.isEmpty) {
      companyId = 'bayanatz'; // Fallback
      log('⚠️ Company ID was empty, using fallback: $companyId');
    }
    return companyId;
  }

  /// ✅ DEBUG: Log current company ID and paths
  void _debugPaths(String methodName) {
    String companyId = _getCompanyId();
    log('📂 [$methodName] Company ID: $companyId');
    log('📂 [$methodName] Base URI: ${ApiConstants.baseUri}');
  }

  // ==================== KNOWLEDGE DOCUMENTS ====================

  /// 1. Fetch all knowledge documents
  Future<List<CreateKnowledgeModel>> fetchAllKnowledge() async {
    try {
      _debugPaths('fetchAllKnowledge');

      CollectionReference knowledgeRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));

      log('📥 Fetching from: ${getBaseUrl(FirebaseCollections.createKnowledge)}');

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

      log('Fetched ${knowledgeList.length} knowledge documents');
      return knowledgeList;
    } catch (e) {
      log('Error fetching knowledge: $e');
      return [];
    }
  }

  /// Stream all knowledge documents (real-time updates)
  Stream<List<CreateKnowledgeModel>> streamAllKnowledge() {
    try {
      _debugPaths('streamAllKnowledge');

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
      log('Error streaming knowledge: $e');
      return Stream.value([]);
    }
  }

  /// 9. Fetch single knowledge document by knowledgeId
  Future<CreateKnowledgeModel?> fetchKnowledgeById(String knowledgeId) async {
    try {
      _debugPaths('fetchKnowledgeById');

      log('Searching for knowledgeId: $knowledgeId');

      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .get();
      log('Query returned ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

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

  /// 10. Search knowledge by name or description
  Future<List<CreateKnowledgeModel>> searchKnowledge(String searchQuery) async {
    try {
      _debugPaths('searchKnowledge');

      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .get();
      List<CreateKnowledgeModel> knowledgeList = [];
      String lowerQuery = searchQuery.toLowerCase();

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(
            data,
            doc.id,
          );

          String nameEn = model.currentNameEnglish.toLowerCase();
          String nameAr = model.currentNameArabic.toLowerCase();
          String descEn = model.currentDescriptionEnglish.toLowerCase();
          String descAr = model.currentDescriptionArabic.toLowerCase();

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

  /// 11. Filter knowledge by document type and/or department
  Future<List<CreateKnowledgeModel>> filterKnowledge({
    String? documentType,
    String? owningDepartment,
  }) async {
    try {
      _debugPaths('filterKnowledge');

      Query query = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));

      // Apply filters if provided
      if (documentType != null && documentType.isNotEmpty) {
        query = query.where(
          'knowledgeDocumentType',
          arrayContains: documentType,
        );
      }

      if (owningDepartment != null &&
          owningDepartment.isNotEmpty &&
          owningDepartment != 'All') {
        query = query.where(
          'owningDepartment',
          arrayContains: owningDepartment,
        );
      }

      QuerySnapshot querySnapshot = await query.get();

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

      log('Fetched ${knowledgeList.length} filtered knowledge documents');
      return knowledgeList;
    } catch (e) {
      log('Error filtering knowledge: $e');
      return [];
    }
  }

  // ==================== DEPARTMENTS ====================

  /// 2. Fetch department name by department ID
  Future<String> fetchDepartmentNameById(String departmentId) async {
    try {
      _debugPaths('fetchDepartmentNameById');

      if (departmentId.isEmpty) {
        log('⚠️ Empty department ID provided');
        return 'Unknown Department';
      }

      log('🔍 [Firebase] Fetching department for ID: $departmentId');

      // ✅ Use dynamic path
      String departmentsPath = getBaseUrl('Departments');
      log('📂 Using path: $departmentsPath');

      // First, try matching by Department_ID
      QuerySnapshot querySnapshot = await _firestore
          .collection(departmentsPath)
          .where('Department_ID', isEqualTo: departmentId)
          .limit(1)
          .get();

      // 🔥 FALLBACK: If not found, try matching by Department_Name (case-insensitive)
      if (querySnapshot.docs.isEmpty) {
        log('⚠️ No department found by ID, trying by name: $departmentId');

        // Try lowercase match
        querySnapshot = await _firestore
            .collection(departmentsPath)
            .where('Department_Name', isEqualTo: departmentId.toLowerCase())
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isEmpty) {
        log('⚠️ No department found with ID or Name: $departmentId');
        return departmentId; // ← Return the original value as fallback
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      String departmentName =
          data['Department_Name'] as String? ?? 'Unknown Department';

      log('✅ Found department: $departmentName for ID/Name: $departmentId');
      return departmentName;
    } catch (e) {
      log('❌ Error fetching department by ID: $e');
      return departmentId; // ← Return the original value as fallback
    }
  }

  /// 3. Batch fetch department names for multiple department IDs
  Future<Map<String, String>> fetchMultipleDepartmentNames(
      List<String> departmentIds,
      ) async {
    try {
      _debugPaths('fetchMultipleDepartmentNames');

      if (departmentIds.isEmpty) {
        log(
          '⚠️ [Firebase] fetchMultipleDepartmentNames called with empty list',
        );
        return {};
      }

      log(
        '🏢 [Firebase] Fetching ${departmentIds.length} departments: $departmentIds',
      );

      // ✅ Use dynamic path
      String departmentsPath = getBaseUrl('Departments');
      log('📂 Using path: $departmentsPath');

      // Remove duplicates
      final uniqueIds = departmentIds.toSet().toList();
      log('🏢 [Firebase] Unique department IDs: ${uniqueIds.length}');

      Map<String, String> departmentMap = {};

      // Firestore 'in' queries are limited to 10 items
      for (int i = 0; i < uniqueIds.length; i += 10) {
        final batch = uniqueIds.skip(i).take(10).toList();
        log('📦 [Firebase] Fetching department batch ${(i ~/ 10) + 1}: $batch');

        QuerySnapshot querySnapshot = await _firestore
            .collection(departmentsPath)
            .where('Department_ID', whereIn: batch)
            .get();

        log(
          '📥 [Firebase] Department batch query returned ${querySnapshot.docs.length} documents',
        );

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            String? deptId = data['Department_ID'] as String?;
            String? deptName = data['Department_Name'] as String?;

            if (deptId != null && deptId.isNotEmpty && deptName != null) {
              departmentMap[deptId] = deptName;
              log(
                '✅ [Firebase] Mapped department: ID="$deptId" → Name="$deptName"',
              );
            }
          } catch (e) {
            log('❌ [Firebase] Error parsing department doc ${doc.id}: $e');
          }
        }
      }

      log(
        '✅ [Firebase] Successfully fetched ${departmentMap.length} department names',
      );
      log(
        '🗂️ [Firebase] Department IDs in result: ${departmentMap.keys.toList()}',
      );

      return departmentMap;
    } catch (e) {
      log('❌ [Firebase] Error fetching multiple department names: $e');
      return {};
    }
  }

  // ==================== USERS/EMPLOYEES ====================

  /// 4. Fetch user data by userId - returns single employee or null
  Future<EmployeeData?> fetchUserDataByUserId(String userId) async {
    try {
      _debugPaths('fetchUserDataByUserId');

      // ✅ Use dynamic path
      String employeesPath = getBaseUrl('Employees_Info');
      log('📂 Using path: $employeesPath');

      QuerySnapshot querySnapshot = await _firestore
          .collection(employeesPath)
          .where('Id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('No employee found with userId: $userId');
        return null;
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      EmployeeData employee = EmployeeData.fromJson(data);

      log('Successfully fetched employee data for userId: $userId');
      return employee;
    } catch (e) {
      log('Error fetching user data: $e');
      return null;
    }
  }

  /// Batch fetch user data for multiple user IDs
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
      List<String> userIds,
      ) async {
    try {
      _debugPaths('fetchMultipleUserData');

      if (userIds.isEmpty) {
        log(
          '⚠️ [Firebase] fetchMultipleUserData called with empty userIds list',
        );
        return {};
      }

      log('👥 [Firebase] Fetching data for ${userIds.length} users: $userIds');

      // ✅ Use dynamic path
      String employeesPath = getBaseUrl('Employees_Info');
      log('📂 Using path: $employeesPath');

      // Remove duplicates
      final uniqueUserIds = userIds.toSet().toList();
      log('👥 [Firebase] Unique user IDs: ${uniqueUserIds.length}');

      Map<String, EmployeeData> usersMap = {};

      // Firestore 'in' queries are limited to 10 items
      for (int i = 0; i < uniqueUserIds.length; i += 10) {
        final batch = uniqueUserIds.skip(i).take(10).toList();
        log('📦 [Firebase] Fetching batch ${(i ~/ 10) + 1}: $batch');

        QuerySnapshot querySnapshot = await _firestore
            .collection(employeesPath)
            .where('Id', whereIn: batch)
            .get();

        log(
          '📥 [Firebase] Batch query returned ${querySnapshot.docs.length} documents',
        );

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            EmployeeData employee = EmployeeData.fromJson(data);
            usersMap[employee.currentemployeeId] = employee;

            log(
              '✅ [Firebase] Parsed employee: id="${employee.currentemployeeId}", name="${employee.currentemployeeName}"',
            );
          } catch (e) {
            log(
              '❌ [Firebase] Error parsing employee data from doc ${doc.id}: $e',
            );
          }
        }
      }

      log('✅ [Firebase] Successfully fetched ${usersMap.length} user records');
      return usersMap;
    } catch (e) {
      log('❌ [Firebase] Error fetching multiple user data: $e');
      return {};
    }
  }

  /// ✅ FIXED: Fetch all employees using dynamic path
  Future<List<EmployeeData>> fetchAllEmployees() async {
    try {
      String companyId = _getCompanyId();
      String employeesPath = getBaseUrl('Employees_Info');

      log('📥 Fetching all employees from: $employeesPath');
      log('🏢 Company ID: $companyId');

      final snapshot = await _firestore
          .collection(employeesPath)
          .get();

      List<EmployeeData> employees = [];

      for (var doc in snapshot.docs) {
        try {
          final employee = EmployeeData.fromJson(doc.data());
          employees.add(employee);
          log('✅ Added employee: ${employee.currentemployeeName} - ${employee.currentemployeeEmail}');
        } catch (e) {
          log('❌ Error parsing employee ${doc.id}: $e');
        }
      }

      log('✅ Successfully fetched ${employees.length} employees');
      return employees;
    } catch (e) {
      log('❌ Error fetching all employees: $e');
      return [];
    }
  }

  /// ✅ FIXED: Enhanced version to handle different email field structures using dynamic path
  Future<EmployeeData?> fetchUserDataByEmail(String email) async {
    try {
      String companyId = _getCompanyId();
      String employeesPath = getBaseUrl('Employees_Info');

      log('🔍 [Firebase] Fetching user for email: $email');
      log('📂 Using path: $employeesPath');
      log('🏢 Company ID: $companyId');

      // Try multiple query approaches since email field structure varies
      final snapshot = await _firestore
          .collection(employeesPath)
          .where('currentemployeeEmail', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        log('✅ Found user with direct email query');
        return EmployeeData.fromJson(snapshot.docs.first.data());
      }

      // If not found, try array contains query
      final snapshot2 = await _firestore
          .collection(employeesPath)
          .where('currentemployeeEmail', arrayContains: email)
          .get();

      if (snapshot2.docs.isNotEmpty) {
        log('✅ Found user with array contains query');
        return EmployeeData.fromJson(snapshot2.docs.first.data());
      }

      // If still not found, try the nested Email field structure
      final snapshot3 = await _firestore
          .collection(employeesPath)
          .where('Email', arrayContains: email)
          .get();

      if (snapshot3.docs.isNotEmpty) {
        log('✅ Found user with nested Email field query');
        return EmployeeData.fromJson(snapshot3.docs.first.data());
      }

      log('📥 Query returned 0 documents for email: $email');

      // Log sample data for debugging
      final sampleSnapshot = await _firestore
          .collection(employeesPath)
          .limit(5)
          .get();

      log('📊 Sample employees in collection:');
      for (var doc in sampleSnapshot.docs) {
        final data = doc.data();
        final emailField = data['currentemployeeEmail'] ?? data['Email'] ?? 'No email field';
        log('  - Doc ID: ${doc.id}');
        log('    Email field: $emailField');
      }

      return null;
    } catch (e) {
      log('❌ Error in fetchUserDataByEmail: $e');
      return null;
    }
  }

  // ==================== COMMENTS ====================

  /// 5. Fetch comments for a specific knowledge document
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
      String knowledgeId,
      ) async {
    try {
      _debugPaths('fetchCommentsByKnowledgeId');

      log('Fetching comments for knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      String commentsPath = getBaseUrl(FirebaseCollections.knowledgeComments);
      log('📂 Using path: $commentsPath');

      // Query the Comments collection directly using knowledgeId field
      QuerySnapshot commentsSnapshot = await _firestore
          .collection(commentsPath)
          .where('knowledgeId', isEqualTo: knowledgeId)
          .get();

      List<CreateNewCommentModel> commentsList = [];

      for (var doc in commentsSnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          CreateNewCommentModel model = CreateNewCommentModel.fromJson(data);
          commentsList.add(model);
        } catch (e) {
          log('Error parsing comment ${doc.id}: $e');
        }
      }

      // Sort by timestamp
      commentsList.sort((a, b) {
        try {
          int timestampA = int.parse(a.timestamps.first);
          int timestampB = int.parse(b.timestamps.first);
          return timestampA.compareTo(timestampB);
        } catch (e) {
          log('Error parsing timestamps for sorting: $e');
          return 0;
        }
      });

      log(
        'Fetched ${commentsList.length} comments for knowledgeId: $knowledgeId',
      );
      return commentsList;
    } catch (e) {
      log('Error fetching comments: $e');
      return [];
    }
  }

  /// Stream comments for real-time updates
  Stream<List<CreateNewCommentModel>> streamCommentsByKnowledgeId(
      String knowledgeId,
      ) {
    try {
      _debugPaths('streamCommentsByKnowledgeId');

      // ✅ Use dynamic path
      String commentsPath = getBaseUrl(FirebaseCollections.knowledgeComments);

      return _firestore
          .collection(commentsPath)
          .where('knowledgeId', isEqualTo: knowledgeId)
          .snapshots()
          .map((snapshot) {
        List<CreateNewCommentModel> commentsList = [];

        for (var doc in snapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data();
            CreateNewCommentModel model = CreateNewCommentModel.fromJson(
              data,
            );
            commentsList.add(model);
          } catch (e) {
            log('Error parsing comment ${doc.id}: $e');
          }
        }

        // Sort by timestamp
        commentsList.sort((a, b) {
          try {
            int timestampA = int.parse(a.timestamps.first);
            int timestampB = int.parse(b.timestamps.first);
            return timestampA.compareTo(timestampB);
          } catch (e) {
            return 0;
          }
        });

        return commentsList;
      });
    } catch (e) {
      log('Error streaming comments: $e');
      return Stream.value([]);
    }
  }

  /// 6. Add a new comment to a knowledge document
  Future<bool> addCommentToKnowledge({
    required String knowledgeId,
    required CreateNewCommentModel comment,
  }) async {
    try {
      _debugPaths('addCommentToKnowledge');

      log('Adding comment to knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      String commentsPath = getBaseUrl(FirebaseCollections.knowledgeComments);
      log('📂 Using path: $commentsPath');

      // Generate new comment document reference
      DocumentReference commentRef = _firestore
          .collection(commentsPath)
          .doc();

      // Convert comment to JSON and add knowledgeId reference
      Map<String, dynamic> commentData = comment.toJson();
      commentData['knowledgeId'] = knowledgeId;

      // Save to Firestore
      await commentRef.set(commentData);

      log('Comment added successfully');
      return true;
    } catch (e) {
      log('Error adding comment: $e');
      return false;
    }
  }

  /// 12. Upload comment attachment to Firebase Storage
  Future<Map<String, dynamic>?> uploadCommentAttachment(File file) async {
    try {
      String fileName = file.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();
      int fileSize = await file.length();

      String filePath =
          'comment_attachments/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference storageRef = _storage.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      log('Comment attachment uploaded successfully');

      return {
        'url': downloadUrl,
        'name': fileName,
        'extension': fileExtension,
        'size': fileSize,
      };
    } catch (e) {
      log('Error uploading comment attachment: $e');
      return null;
    }
  }

  // ==================== MEDIA UPLOADS ====================

  /// 7. Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName =
          'knowledge_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      log('Image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  /// Upload video to Firebase Storage
  Future<String?> uploadVideo(File videoFile) async {
    try {
      String fileName =
          'knowledge_videos/${DateTime.now().millisecondsSinceEpoch}.mp4';
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(videoFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      log('Video uploaded successfully');
      return downloadUrl;
    } catch (e) {
      log('Error uploading video: $e');
      return null;
    }
  }

  /// Upload document to Firebase Storage
  Future<String?> uploadDocument(File documentFile, String fileName) async {
    try {
      String filePath =
          'knowledge_documents/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference storageRef = _storage.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(documentFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      log('Document uploaded successfully');
      return downloadUrl;
    } catch (e) {
      log('Error uploading document: $e');
      return null;
    }
  }

  // ==================== CREATE/UPDATE KNOWLEDGE ====================

  /// 8. Create new knowledge document
  Future<bool> createKnowledge(CreateKnowledgeModel model) async {
    try {
      _debugPaths('createKnowledge');

      // ✅ Use dynamic path
      CollectionReference knowledgeRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge));
      Map<String, dynamic> knowledgeData = model.toJson();

      log('Creating knowledge document: ${model.currentKnowledgeId}');

      await knowledgeRef.add(knowledgeData);

      log('Knowledge document created successfully');
      return true;
    } catch (e) {
      log('Error creating knowledge: $e');
      return false;
    }
  }

}
