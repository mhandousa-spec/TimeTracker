part of './approvals_firebase_services.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 2 of ApprovalsFirebaseServices (kept under 800 LOC, §7).
extension ApprovalsServicesPart2 on ApprovalsFirebaseServices {

  /// Update existing knowledge document
  Future<bool> updateKnowledge({
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
    String? documentExtension,
    int? documentSize,
    String? createdByEmail,
  }) async {
    try {
      _debugPaths('updateKnowledge');

      log('Updating knowledge with knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      // Find the document by knowledgeId
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
      CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(
        existingData,
        doc.id,
      );

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
        createdByEmail: createdByEmail,
      );

      // Update the document
      Map<String, dynamic> updatedData = updatedModel.toJson();
      updatedData['updatedAt'] = FieldValue.serverTimestamp();

      await doc.reference.update(updatedData);

      log('Knowledge document updated successfully');
      return true;
    } catch (e) {
      log('Error updating knowledge: $e');
      return false;
    }
  }

  /// Update submission status (for admin actions)
  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      _debugPaths('updateSubmissionStatus');

      log(
        'Updating submission status for knowledgeId: $knowledgeId to $newStatus',
      );

      // ✅ Use dynamic path
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

      // Get existing model
      Map<String, dynamic> existingData = doc.data() as Map<String, dynamic>;
      CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(
        existingData,
        doc.id,
      );

      // Add new status to the array
      List<String> updatedStatus = List<String>.from(existingModel.status)
        ..add(newStatus);
      List<int> updatedTimestamps = List<int>.from(existingModel.timestamps)
        ..add(DateTime.now().millisecondsSinceEpoch);

      await doc.reference.update({
        'status': updatedStatus,
        'timestamps': updatedTimestamps,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log('Submission status updated successfully');
      return true;
    } catch (e) {
      log('Error updating submission status: $e');
      return false;
    }
  }

  // ==================== APPROVALS MANAGEMENT ====================

  /// Create or update approval document in Approvals collection
  Future<bool> createOrUpdateApproval({
    required String knowledgeId,
    required String status,
    String? rejectionReason,
    String? approvalJustification,
  }) async {
    try {
      _debugPaths('createOrUpdateApproval');

      log(
        'Creating/Updating approval for knowledgeId: $knowledgeId with status: $status',
      );

      // ✅ Use dynamic path
      // Reference to the approval document (using knowledgeId as document ID)
      DocumentReference approvalRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeApprovals))
          .doc(knowledgeId);

      // Check if approval document already exists
      DocumentSnapshot approvalSnapshot = await approvalRef.get();

      if (approvalSnapshot.exists) {
        // Document exists - update it by adding new values to arrays
        log('Approval document exists, updating...');

        Map<String, dynamic> existingData =
        approvalSnapshot.data() as Map<String, dynamic>;
        ApprovalModel existingApproval = ApprovalModel.fromJson(existingData);

        // Create updated model using copyWith
        ApprovalModel updatedApproval = existingApproval.copyWith(
          status: status,
          rejectionReason: rejectionReason ?? '',
          approvalJustification: approvalJustification ?? '',
        );

        // Save updated data
        await approvalRef.update(updatedApproval.toJson());
        log('Approval document updated successfully');
      } else {
        // Document doesn't exist - create new one
        log('Creating new approval document...');

        ApprovalModel newApproval = ApprovalModel.createNew(
          knowledgeId: knowledgeId,
          status: status,
          rejectionReason: rejectionReason,
          approvalJustification: approvalJustification,
        );

        await approvalRef.set(newApproval.toJson());
        log('Approval document created successfully');
      }

      return true;
    } catch (e) {
      log('Error creating/updating approval: $e');
      return false;
    }
  }

  /// Approve knowledge document - updates both Create_Knowledge and Approvals collections
  Future<bool> approveKnowledge({
    required String knowledgeId,
    required String approvalJustification,
  }) async {
    try {
      _debugPaths('approveKnowledge');

      log('🟢 Approving knowledge document: $knowledgeId');

      // ✅ STEP 1: Fetch the document to check scheduling settings
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('knowledgeId', arrayContains: knowledgeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log('❌ Document not found: $knowledgeId');
        return false;
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // ✅ STEP 2: Check if document has scheduled publishing enabled
      List<dynamic> schedulePublishingArray = data['schedulePublishing'] ?? [];
      bool schedulePublishing = schedulePublishingArray.isNotEmpty &&
          schedulePublishingArray.first == true;

      log('📅 schedulePublishing value: $schedulePublishing');

      // ✅ STEP 3: Determine the correct status based on scheduling
      String newStatus;
      if (schedulePublishing) {
        // Scheduling is enabled → set to 'approved' (will become 'published' when scheduled time arrives)
        newStatus = 'approved';
        log('📅 Document has scheduled publishing enabled → Setting status to: approved');
      } else {
        // NO scheduling → set to 'published' immediately
        newStatus = 'published';
        log('✅ Document has NO scheduled publishing → Setting status to: published');
      }

      log('🎯 Final status to be set: $newStatus');

      // ✅ STEP 4: Update status in Create_Knowledge collection
      bool statusUpdated = await updateSubmissionStatus(
        knowledgeId: knowledgeId,
        newStatus: newStatus,  // ✅ Use determined status!
      );

      if (!statusUpdated) {
        log('❌ Failed to update status in Create_Knowledge');
        return false;
      }

      // ✅ STEP 5: Create/Update approval record in Approvals collection
      bool approvalCreated = await createOrUpdateApproval(
        knowledgeId: knowledgeId,
        status: newStatus,  // ✅ Use determined status!
        approvalJustification: approvalJustification,
        rejectionReason: '',
      );

      if (!approvalCreated) {
        log('❌ Failed to create approval record');
        return false;
      }

      log('✅ Knowledge document approved successfully with status: $newStatus');
      return true;
    } catch (e) {
      log('❌ Error approving knowledge: $e');
      return false;
    }
  }

  /// Reject knowledge document - updates both Create_Knowledge and Approvals collections
  Future<bool> rejectKnowledge({
    required String knowledgeId,
    required String rejectionReason,
  }) async {
    try {
      _debugPaths('rejectKnowledge');

      log('🔴 Rejecting knowledge document: $knowledgeId');

      // 1. Update status in Create_Knowledge collection
      bool statusUpdated = await updateSubmissionStatus(
        knowledgeId: knowledgeId,
        newStatus: 'rejected',
      );

      if (!statusUpdated) {
        log('❌ Failed to update status in Create_Knowledge');
        return false;
      }

      // 2. Create/Update approval record in Approvals collection
      bool approvalCreated = await createOrUpdateApproval(
        knowledgeId: knowledgeId,
        status: 'rejected',
        rejectionReason: rejectionReason,
        approvalJustification: '',
      );

      if (!approvalCreated) {
        log('❌ Failed to create approval record');
        return false;
      }

      log('✅ Knowledge document rejected successfully');
      return true;
    } catch (e) {
      log('❌ Error rejecting knowledge: $e');
      return false;
    }
  }

  /// Fetch approval details for a specific knowledge document
  Future<ApprovalModel?> fetchApprovalByKnowledgeId(String knowledgeId) async {
    try {
      _debugPaths('fetchApprovalByKnowledgeId');

      log('Fetching approval for knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      DocumentSnapshot approvalSnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeApprovals))
          .doc(knowledgeId)
          .get();

      if (!approvalSnapshot.exists) {
        log('No approval found for knowledgeId: $knowledgeId');
        return null;
      }

      Map<String, dynamic> data =
      approvalSnapshot.data() as Map<String, dynamic>;
      ApprovalModel approval = ApprovalModel.fromJson(data);

      log('Approval fetched successfully');
      return approval;
    } catch (e) {
      log('Error fetching approval: $e');
      return null;
    }
  }

  // ==================== FILE ACTIONS/UTILIZATION ====================

  /// 13. Record file action (download, view, or export)
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction, // 'download', 'view', or 'export'
    required String userId,
  }) async {
    try {
      _debugPaths('recordFileAction');

      // ✅ Use dynamic path
      // Generate new action document reference
      DocumentReference actionRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))
          .doc();

      // Create formatted timestamp
      final String formattedTimeStamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());

      // Create DocumentUtilizationModel instance
      final DocumentUtilizationModel actionModel =
      DocumentUtilizationModel.createNew(
        timestamp: formattedTimeStamp,
        fileId: knowledgeId,
        typeOfAction: typeOfAction,
        userId: userId,
      );

      // Convert model to JSON
      Map<String, dynamic> actionData = actionModel.toJson();

      // Add server timestamp for querying purposes
      actionData['actionTimestamp'] = FieldValue.serverTimestamp();

      // Save to Firestore
      await actionRef.set(actionData);

      log('File action recorded successfully: $typeOfAction for user: $userId');
      return true;
    } catch (e) {
      log('Error recording file action: $e');
      return false;
    }
  }

  /// 14. Fetch file actions by knowledge/file ID
  Future<List<DocumentUtilizationModel>> fetchFileActionsByKnowledgeId(
      String knowledgeId,
      ) async {
    try {
      _debugPaths('fetchFileActionsByKnowledgeId');

      log('Fetching file actions for knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))
          .where('fileId', arrayContains: knowledgeId)
          .get();

      log('Query returned ${querySnapshot.docs.length} file actions');

      List<DocumentUtilizationModel> actionsList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DocumentUtilizationModel model = DocumentUtilizationModel.fromJson(
            data,
          );
          actionsList.add(model);
        } catch (e) {
          log('Error parsing action ${doc.id}: $e');
        }
      }

      return actionsList;
    } catch (e) {
      log('Error fetching file actions: $e');
      return [];
    }
  }

  /// Stream file actions for real-time updates
  Stream<List<DocumentUtilizationModel>> streamFileActionsByKnowledgeId(
      String knowledgeId,
      ) {
    try {
      _debugPaths('streamFileActionsByKnowledgeId');

      // ✅ Use dynamic path
      return _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))
          .where('fileId', arrayContains: knowledgeId)
          .orderBy('actionTimestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        List<DocumentUtilizationModel> actionsList = [];

        for (var doc in snapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data();
            DocumentUtilizationModel model =
            DocumentUtilizationModel.fromJson(data);
            actionsList.add(model);
          } catch (e) {
            log('Error parsing action ${doc.id}: $e');
          }
        }

        return actionsList;
      });
    } catch (e) {
      log('Error streaming file actions: $e');
      return Stream.value([]);
    }
  }

  // ==================== ADDITIONAL HELPER METHODS ====================

  /// Get comment count for a knowledge document
  Future<int> getCommentCount(String knowledgeId) async {
    try {
      _debugPaths('getCommentCount');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .where('knowledgeId', isEqualTo: knowledgeId)
          .get();

      return querySnapshot.size;
    } catch (e) {
      log('Error getting comment count: $e');
      return 0;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      _debugPaths('deleteComment');

      // ✅ Use dynamic path
      await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .doc(commentId)
          .delete();

      log('Comment deleted successfully: $commentId');
      return true;
    } catch (e) {
      log('Error deleting comment: $e');
      return false;
    }
  }

  /// Delete knowledge document by knowledgeId
  Future<bool> deleteKnowledge(String knowledgeId) async {
    try {
      _debugPaths('deleteKnowledge');

      log('Deleting knowledge with knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      // Find the document by knowledgeId
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
      await doc.reference.delete();

      log('Knowledge document deleted successfully');
      return true;
    } catch (e) {
      log('Error deleting knowledge: $e');
      return false;
    }
  }

  /// Get file action statistics by type
  Future<Map<String, int>> getFileActionStats(String knowledgeId) async {
    try {
      _debugPaths('getFileActionStats');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization))
          .where('fileId', arrayContains: knowledgeId)
          .get();

      Map<String, int> stats = {'view': 0, 'download': 0, 'export': 0};

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DocumentUtilizationModel model = DocumentUtilizationModel.fromJson(
            data,
          );
          String actionType = model.currentTypeOfAction.toLowerCase();

          if (stats.containsKey(actionType)) {
            stats[actionType] = stats[actionType]! + 1;
          }
        } catch (e) {
          log('Error parsing action stats: $e');
        }
      }

      log('File action stats for $knowledgeId: $stats');
      return stats;
    } catch (e) {
      log('Error getting file action stats: $e');
      return {'view': 0, 'download': 0, 'export': 0};
    }
  }

  /// Fetch knowledge documents by status
  Future<List<CreateKnowledgeModel>> fetchKnowledgeByStatus(
      String status,
      ) async {
    try {
      _debugPaths('fetchKnowledgeByStatus');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('status', arrayContains: status)
          .get();

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

      log(
        'Fetched ${knowledgeList.length} knowledge documents with status: $status',
      );
      return knowledgeList;
    } catch (e) {
      log('Error fetching knowledge by status: $e');
      return [];
    }
  }

  /// Fetch knowledge documents by creator email
  Future<List<CreateKnowledgeModel>> fetchKnowledgeByCreator(
      String creatorEmail,
      ) async {
    try {
      _debugPaths('fetchKnowledgeByCreator');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where('createdByEmail', arrayContains: creatorEmail)
          .get();

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

      log(
        'Fetched ${knowledgeList.length} knowledge documents by creator: $creatorEmail',
      );
      return knowledgeList;
    } catch (e) {
      log('Error fetching knowledge by creator: $e');
      return [];
    }
  }

  /// Batch delete multiple knowledge documents
  Future<bool> batchDeleteKnowledge(List<String> knowledgeIds) async {
    try {
      _debugPaths('batchDeleteKnowledge');

      log('Batch deleting ${knowledgeIds.length} knowledge documents');

      WriteBatch batch = _firestore.batch();
      int deleteCount = 0;

      // ✅ Use dynamic path
      for (String knowledgeId in knowledgeIds) {
        QuerySnapshot querySnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .where('knowledgeId', arrayContains: knowledgeId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          batch.delete(querySnapshot.docs.first.reference);
          deleteCount++;
        }
      }

      await batch.commit();
      log('Successfully deleted $deleteCount knowledge documents');
      return true;
    } catch (e) {
      log('Error batch deleting knowledge: $e');
      return false;
    }
  }

  /// Check if user has permission to approve (based on role)
  Future<bool> checkApprovalPermission(String userId) async {
    try {
      _debugPaths('checkApprovalPermission');

      EmployeeData? employee = await fetchUserDataByUserId(userId);

      if (employee == null) {
        return false;
      }

      // Check if user has admin or manager role
      String role = employee.currentemployeeRole.toLowerCase();
      return role.contains('admin') ||
          role.contains('manager') ||
          role.contains('supervisor');
    } catch (e) {
      log('Error checking approval permission: $e');
      return false;
    }
  }

  /// Get total knowledge count
  Future<int> getTotalKnowledgeCount() async {
    try {
      _debugPaths('getTotalKnowledgeCount');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .get();

      return querySnapshot.size;
    } catch (e) {
      log('Error getting total knowledge count: $e');
      return 0;
    }
  }

  /// Get knowledge count by status
  Future<Map<String, int>> getKnowledgeCountByStatus() async {
    try {
      _debugPaths('getKnowledgeCountByStatus');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .get();

      Map<String, int> statusCount = {};

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          CreateKnowledgeModel model = CreateKnowledgeModel.fromJson(
            data,
            doc.id,
          );

          String currentStatus = model.currentStatus;
          statusCount[currentStatus] = (statusCount[currentStatus] ?? 0) + 1;
        } catch (e) {
          log('Error parsing document ${doc.id}: $e');
        }
      }

      log('Knowledge count by status: $statusCount');
      return statusCount;
    } catch (e) {
      log('Error getting knowledge count by status: $e');
      return {};
    }
  }

}
