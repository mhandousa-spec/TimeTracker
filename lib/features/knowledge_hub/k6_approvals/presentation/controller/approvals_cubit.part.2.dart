part of './approvals_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 2 of ApprovalsCubit (kept under 800 LOC, §7).
extension ApprovalsCubitPart2 on ApprovalsCubit {

  /// Reset all filters
  Future<void> resetFilters() async {
    try {
      selectedDocumentType = null;
      selectedStatus = null;
      selectedInnerStatus = null;
      dialogFilterActive = false;
      selectedStartDate = null;
      selectedEndDate = null;
      searchQuery = '';
      selectedStatusIndex = 0;
      selectedInnerStatusIndex = 0;

      filteredKnowledge = List.from(allKnowledge);
      upperCategoryFiltered = List.from(allKnowledge);

      emit(ChangeIndexSuccessState(0));

      if (filteredKnowledge.isEmpty) {
        emit(FetchingApprovalsEmptyState());
      } else {
        emit(FetchingApprovalsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('❌ Error in resetFilters: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }


  /// Update submission status (admin action)
  Future<void> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      emit(FetchingApprovalsLoadingState());

      bool success = await _firebaseServices.updateSubmissionStatus(
        knowledgeId: knowledgeId,
        newStatus: newStatus,
      );

      if (success) {
        // Refresh the list
        await fetchAllSubmissions();
      } else {
        emit(FetchingApprovalsErrorState('Failed to update status'));
      }
    } catch (e) {
      log('❌ Error in updateSubmissionStatus: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }


  // ==================== APPROVE/REJECT METHODS ====================

  /// Approve a knowledge document
  /// Approve a knowledge document
  /// Approve a knowledge document - FIXED VERSION
  Future<void> approveKnowledge({
    required String knowledgeId,
    required String approvalJustification,
  }) async {
    // GUARD ADDED 2/9/2026. The buttons that call this are now hidden without
    // the permission, but hiding a button is not enforcement: this cubit is
    // also reachable from a deep link into the approvals detail screen and
    // from a widget that was built before a role change landed.
    //
    // Emitting the error state rather than returning silently — the screen
    // listens for it and will say the action failed, which is truer than a tap
    // that appears to do nothing.
    if (!KnowledgeHubAccess.approvalAccess.canApprove) {
      log('⛔ approveKnowledge denied: role lacks approval permission');
      emit(ApprovingKnowledgeErrorState(
          'You do not have permission to approve documents.'));
      return;
    }

    try {
      log('🟢 Approving knowledge document: $knowledgeId');
      emit(ApprovingKnowledgeLoadingState());

      // ✅ FIXED: Find document with multiple fallback methods
      CreateKnowledgeModel? knowledgeDoc;

      // Method 1: Try to find by currentKnowledgeId
      try {
        knowledgeDoc = allKnowledge.firstWhere(
              (doc) => doc.currentKnowledgeId == knowledgeId,
        );
        log('✅ Found document by currentKnowledgeId');
      } catch (e) {
        log('⚠️ Not found by currentKnowledgeId, trying knowledgeId array...');

        // Method 2: Try to find by checking if knowledgeId array contains the ID
        try {
          knowledgeDoc = allKnowledge.firstWhere(
                (doc) => doc.knowledgeId.contains(knowledgeId),
          );
          log('✅ Found document by knowledgeId array');
        } catch (e2) {
          log('⚠️ Not found in allKnowledge, fetching from Firebase...');

          // Method 3: Fetch directly from Firebase as fallback
          try {
            final allDocs = await _firebaseServices.fetchAllKnowledge();
            knowledgeDoc = allDocs.firstWhere(
                  (doc) => doc.currentKnowledgeId == knowledgeId ||
                  doc.knowledgeId.contains(knowledgeId),
            );
            log('✅ Found document by fetching from Firebase');
          } catch (e3) {
            log('❌ Document not found anywhere');
            emit(ApprovingKnowledgeErrorState('Document not found. Please refresh and try again.'));
            return;
          }
        }
      }

      if (knowledgeDoc == null) {
        log('❌ Knowledge document is null');
        emit(ApprovingKnowledgeErrorState('Document not found. Please refresh and try again.'));
        return;
      }

      final creatorEmail = knowledgeDoc.currentCreatedByEmail;
      final documentNameEnglish = knowledgeDoc.currentNameEnglish;
      final documentNameArabic = knowledgeDoc.currentNameArabic;

      log('📄 Document found:');
      log('   Name (EN): $documentNameEnglish');
      log('   Name (AR): $documentNameArabic');
      log('   Creator: $creatorEmail');

      // STEP 2: Perform the approval in Firebase
      bool success = await _firebaseServices.approveKnowledge(
        knowledgeId: knowledgeId,
        approvalJustification: approvalJustification,
      );

      if (success) {
        log('✅ Knowledge approved successfully in Firebase');

        // STEP 3: Send notification
        if (creatorEmail.isNotEmpty) {
          await _sendApprovalNotification(
            recipientEmail: creatorEmail,
            documentNameEnglish: documentNameEnglish,
            documentNameArabic: documentNameArabic,
            isApproved: true,
            knowledgeId: knowledgeId,
          );
          log('✅ Approval notification sent to: $creatorEmail');

          // ADDED 1/9/2026 — §1.1 "Document Published and Effective".
          //
          // `approveKnowledge` publishes immediately when the document has NO
          // scheduled publishing (see the status branch in
          // approvals_firebase_services.part.2), so approval and publication
          // are the same moment for those documents. Only the approval was
          // ever announced; the author was never told the document had gone
          // live and was in effect — which is the half that carries an
          // obligation to its audience.
          //
          // A SCHEDULED document is deliberately excluded: it is approved now
          // and published on its start date, so announcing publication here
          // would be days or weeks early.
          if (!knowledgeDoc.currentSchedulePublishing) {
            await _announcePublication(
              recipientEmail: creatorEmail,
              documentNameEnglish: documentNameEnglish,
              documentNameArabic: documentNameArabic,
              knowledgeId: knowledgeId,
            );
          }
        }

        // STEP 4: Refresh and emit success
        emit(ApprovingKnowledgeSuccessState());
        await fetchAllSubmissions();
      } else {
        emit(ApprovingKnowledgeErrorState('Failed to approve document'));
      }
    } catch (e, stackTrace) {
      log('❌ Error approving knowledge: $e');
      log('❌ Stack trace: $stackTrace');
      emit(ApprovingKnowledgeErrorState(e.toString()));
    }
  }


  /// Reject a knowledge document - FIXED VERSION
  Future<void> rejectKnowledge({
    required String knowledgeId,
    required String rejectionReason,
  }) async {
    // GUARD ADDED 2/9/2026 — see the note on [approveKnowledge].
    //
    // `canReject`, not `canApprove`: rejecting is the higher tier, so the
    // approve-only role reaching this method is exactly the case worth
    // stopping.
    if (!KnowledgeHubAccess.approvalAccess.canReject) {
      log('⛔ rejectKnowledge denied: role lacks reject permission');
      emit(RejectingKnowledgeErrorState(
          'You do not have permission to reject documents.'));
      return;
    }

    try {
      log('🔴 Rejecting knowledge document: $knowledgeId');
      emit(RejectingKnowledgeLoadingState());

      // ✅ FIXED: Find document with multiple fallback methods
      CreateKnowledgeModel? knowledgeDoc;

      // Method 1: Try to find by currentKnowledgeId
      try {
        knowledgeDoc = allKnowledge.firstWhere(
              (doc) => doc.currentKnowledgeId == knowledgeId,
        );
        log('✅ Found document by currentKnowledgeId');
      } catch (e) {
        log('⚠️ Not found by currentKnowledgeId, trying knowledgeId array...');

        // Method 2: Try to find by checking if knowledgeId array contains the ID
        try {
          knowledgeDoc = allKnowledge.firstWhere(
                (doc) => doc.knowledgeId.contains(knowledgeId),
          );
          log('✅ Found document by knowledgeId array');
        } catch (e2) {
          log('⚠️ Not found in allKnowledge, fetching from Firebase...');

          // Method 3: Fetch directly from Firebase as fallback
          try {
            final allDocs = await _firebaseServices.fetchAllKnowledge();
            knowledgeDoc = allDocs.firstWhere(
                  (doc) => doc.currentKnowledgeId == knowledgeId ||
                  doc.knowledgeId.contains(knowledgeId),
            );
            log('✅ Found document by fetching from Firebase');
          } catch (e3) {
            log('❌ Document not found anywhere');
            emit(RejectingKnowledgeErrorState('Document not found. Please refresh and try again.'));
            return;
          }
        }
      }

      if (knowledgeDoc == null) {
        log('❌ Knowledge document is null');
        emit(RejectingKnowledgeErrorState('Document not found. Please refresh and try again.'));
        return;
      }

      final creatorEmail = knowledgeDoc.currentCreatedByEmail;
      final documentNameEnglish = knowledgeDoc.currentNameEnglish;
      final documentNameArabic = knowledgeDoc.currentNameArabic;

      log('📄 Document found:');
      log('   Name (EN): $documentNameEnglish');
      log('   Name (AR): $documentNameArabic');
      log('   Creator: $creatorEmail');

      // STEP 2: Perform the rejection in Firebase
      bool success = await _firebaseServices.rejectKnowledge(
        knowledgeId: knowledgeId,
        rejectionReason: rejectionReason,
      );

      if (success) {
        log('✅ Knowledge rejected successfully in Firebase');

        // STEP 3: Send notification
        if (creatorEmail.isNotEmpty) {
          await _sendApprovalNotification(
            recipientEmail: creatorEmail,
            documentNameEnglish: documentNameEnglish,
            documentNameArabic: documentNameArabic,
            isApproved: false,
            knowledgeId: knowledgeId,
          );
          log('✅ Rejection notification sent to: $creatorEmail');
        }

        // STEP 4: Refresh and emit success
        emit(RejectingKnowledgeSuccessState());
        await fetchAllSubmissions();
      } else {
        emit(RejectingKnowledgeErrorState('Failed to reject document'));
      }
    } catch (e, stackTrace) {
      log('❌ Error rejecting knowledge: $e');
      log('❌ Stack trace: $stackTrace');
      emit(RejectingKnowledgeErrorState(e.toString()));
    }
  }


  /// Map display status names to actual database status values
  String _mapDisplayStatusToActual(String displayStatus) {
    switch (displayStatus) {
      case 'Approved':
        return 'approved';
      case 'Pending':
        return 'pending_approval';
      case 'Rejected':
        return 'rejected';
      case 'Removed':
        return 'removed';
      case 'Archive':
        return 'archived';
      default:
        return displayStatus.toLowerCase();
    }
  }


  /// ✅ Helper: Fetch user data for all comments
  Future<void> _fetchUsersForComments(
      List<CreateNewCommentModel> comments,
      ) async {
    try {
      // Extract unique user IDs that aren't already cached
      final userIds = comments
          .map((c) => c.currentCreatedById)
          .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
          .toSet()
          .toList();

      if (userIds.isEmpty) return;

      // Batch fetch user data
      final newUsers = await _firebaseServices.fetchMultipleUserData(userIds);

      // Add to cache
      _usersCache.addAll(newUsers);

      log('✅ Cached ${newUsers.length} user records for comments');
    } catch (e) {
      log('❌ Error fetching users for comments: $e');
    }
  }


  /// Get user data for a specific userId (from cache or fetch)
  Future<EmployeeData?> getUserData(String userId) async {
    // Check cache first
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId];
    }

    // Fetch if not in cache
    try {
      final userData = await _firebaseServices.fetchUserDataByUserId(userId);
      if (userData != null) {
        _usersCache[userId] = userData;
      }
      return userData;
    } catch (e) {
      log('❌ Error fetching user data for $userId: $e');
      return null;
    }
  }


  /// ✅ Get department name for a specific departmentId (from cache or fetch)
  Future<String> getDepartmentName(String departmentId) async {
    // Check cache first
    if (_departmentsCache.containsKey(departmentId)) {
      return _departmentsCache[departmentId]!;
    }

    // Fetch if not in cache
    try {
      final departmentName = await _firebaseServices.fetchDepartmentNameById(
        departmentId,
      );
      _departmentsCache[departmentId] = departmentName;
      return departmentName;
    } catch (e) {
      log('❌ Error fetching department name for $departmentId: $e');
      return 'Unknown Department';
    }
  }


  /// ✅ Batch fetch department names for multiple knowledge documents
  Future<void> fetchDepartmentsForKnowledge(
      List<CreateKnowledgeModel> knowledgeList,
      ) async {
    try {
      // Extract unique department IDs that aren't already cached
      final departmentIds = knowledgeList
          .map((k) => k.currentOwningDepartment)
          .where((id) => id.isNotEmpty && !_departmentsCache.containsKey(id))
          .toSet()
          .toList();

      if (departmentIds.isEmpty) return;

      // Batch fetch department names
      final newDepartments = await _firebaseServices
          .fetchMultipleDepartmentNames(departmentIds);

      // Add to cache
      _departmentsCache.addAll(newDepartments);

      log('✅ Cached ${newDepartments.length} department names');
    } catch (e) {
      log('❌ Error fetching departments for knowledge: $e');
    }
  }


  /// Fetch comments for a specific knowledge document
  Future<void> fetchCommentsByKnowledgeId(String knowledgeId) async {
    try {
      currentKnowledgeId = knowledgeId;
      emit(FetchingCommentsLoadingState());

      currentComments = await _firebaseServices.fetchCommentsByKnowledgeId(
        knowledgeId,
      );

      // ✅ Fetch user data for all comment creators
      await _fetchUsersForComments(currentComments);

      if (currentComments.isEmpty) {
        emit(FetchingCommentsEmptyState());
      } else {
        emit(FetchingCommentsSuccessState(currentComments));
      }
    } catch (e) {
      log('❌ Error in fetchCommentsByKnowledgeId: $e');
      emit(FetchingCommentsErrorState(e.toString()));
    }
  }


  /// Add a new comment
  Future<void> addComment({
    required String knowledgeId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
  }) async {
    try {
      emit(AddingCommentLoadingState());

      // Generate unique comment ID
      String commentId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create comment model with simplified fields
      CreateNewCommentModel comment = CreateNewCommentModel.createNew(
        commentId: commentId,
        commentText: commentText,
        createdById: createdById,
        createdByEmail: createdByEmail,
        attachmentExtension: attachmentExtension,
        attachmentSize: attachmentSize,
      );

      bool success = await _firebaseServices.addCommentToKnowledge(
        knowledgeId: knowledgeId,
        comment: comment,
      );

      if (success) {
        emit(AddingCommentSuccessState());
        // Refresh comments
        await fetchCommentsByKnowledgeId(knowledgeId);
      } else {
        emit(AddingCommentErrorState('Failed to add comment'));
      }
    } catch (e) {
      log('❌ Error in addComment: $e');
      emit(AddingCommentErrorState(e.toString()));
    }
  }


  /// ✅ Get comment count for a knowledge document
  Future<int> getCommentCount(String knowledgeId) async {
    try {
      final comments = await _firebaseServices.fetchCommentsByKnowledgeId(
        knowledgeId,
      );
      return comments.length;
    } catch (e) {
      log('❌ Error getting comment count: $e');
      return 0;
    }
  }


  /// ✅ Check if current user has approval permission
  Future<bool> checkApprovalPermission(String userId) async {
    try {
      return await _firebaseServices.checkApprovalPermission(userId);
    } catch (e) {
      log('❌ Error checking approval permission: $e');
      return false;
    }
  }


  /// ✅ Get file action statistics
  Future<Map<String, int>> getFileActionStats(String knowledgeId) async {
    try {
      return await _firebaseServices.getFileActionStats(knowledgeId);
    } catch (e) {
      log('❌ Error getting file action stats: $e');
      return {'view': 0, 'download': 0, 'export': 0};
    }
  }


  /// Clear comments (when leaving the screen)
  void clearComments() {
    currentComments = [];
    currentKnowledgeId = null;
    emit(ApprovalsInitial());
  }


  /// Clear the users cache
  void clearUsersCache() {
    _usersCache.clear();
  }


  /// ✅ Clear the departments cache
  void clearDepartmentsCache() {
    _departmentsCache.clear();
  }


  /// ✅ Clear all caches
  void clearAllCaches() {
    _usersCache.clear();
    _departmentsCache.clear();
  }


  /// Get user data by email (from cache or fetch) - FIXED VERSION
  Future<EmployeeData?> getUserDataByEmail(String email) async {
    if (email.isEmpty) return null;

    // Check cache first - search through cached users by email
    for (var user in _usersCache.values) {
      if (user.currentemployeeEmail.toLowerCase() == email.toLowerCase()) {
        log('✅ Found user in cache by email: $email');
        return user;
      }
    }

    // Fetch if not in cache
    try {
      log('🔍 Fetching user from Firebase by email: $email');
      final userData = await _firebaseServices.fetchUserDataByEmail(email);

      if (userData != null) {
        // Cache the user data using their ID as key
        _usersCache[userData.currentemployeeId] = userData;
        log('✅ Cached user data for: ${userData.currentemployeeName}');
      } else {
        log('❌ No user found for email: $email');
        // Try alternative approach - fetch all employees and search locally
        return await _fetchAllEmployeesAndFindByEmail(email);
      }

      return userData;
    } catch (e) {
      log('❌ Error fetching user data by email $email: $e');
      // Fallback: try to fetch all employees and search
      return await _fetchAllEmployeesAndFindByEmail(email);
    }
  }


  /// Fallback method: Fetch all employees and search by email
  Future<EmployeeData?> _fetchAllEmployeesAndFindByEmail(String email) async {
    try {
      log('🔄 Using fallback: fetching all employees to find: $email');

      // Fetch all employees from the main path
      final allEmployees = await _firebaseServices.fetchAllEmployees();

      // Search for the employee by email
      for (var employee in allEmployees) {
        if (employee.currentemployeeEmail.toLowerCase() == email.toLowerCase()) {
          log('✅ Found employee in fallback search: ${employee.currentemployeeName}');
          // Cache the found employee
          _usersCache[employee.currentemployeeId] = employee;
          return employee;
        }
      }

      log('❌ Employee not found even in fallback search: $email');
      return null;
    } catch (e) {
      log('❌ Error in fallback employee search: $e');
      return null;
    }
  }


  /// Record file action (view/download)
  Future<void> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String userId,
  }) async {
    emit(RecordFileActionLoading());
    try {
      final success = await _firebaseServices.recordFileAction(
        knowledgeId: knowledgeId,
        typeOfAction: typeOfAction,
        userId: userId,
      );

      if (success) {
        emit(RecordFileActionSuccess(typeOfAction: typeOfAction));
      } else {
        emit(RecordFileActionFailure('Failed to record $typeOfAction action'));
      }
    } catch (e) {
      log('❌ Error in recordFileAction: $e');
      emit(RecordFileActionFailure(e.toString()));
    }
  }

}
