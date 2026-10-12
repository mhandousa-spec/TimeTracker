part of './submissions_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 3 of SubmissionsCubit (kept under 800 LOC, §7).
extension SubmissionsCubitPart3 on SubmissionsCubit {

  /// ✅ Apply filters from dialog with department support
  /*Future<void> applyFilters({
    String? documentType,
    String? status,
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      emit(FetchingSubmissionsLoadingState());

      selectedDocumentType = documentType;
      selectedStatus = status;
      selectedDepartment = department;
      selectedStartDate = startDate;
      selectedEndDate = endDate;

      // Start with all knowledge
      filteredKnowledge = List.from(allKnowledge);

      // Filter by status
      if (status != null && status.isNotEmpty && status != 'Status') {
        if (status == 'All') {
          filteredKnowledge = List.from(allKnowledge);
        } else if (status == 'Pending') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'pending_approval' ||
                knowledge.currentStatus == 'scheduled';
          }).toList();
        } else if (status == 'Approved') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'approved';
          }).toList();
        } else if (status == 'Published') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'published';
          }).toList();
        } else {
          String actualStatus = _mapDisplayStatusToActual(status);
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == actualStatus;
          }).toList();
        }
      }

      // ✅ Filter by department
      if (department != null && department.isNotEmpty && department != 'Department') {
        filteredKnowledge = filteredKnowledge.where((knowledge) {
          String dept = knowledge.owningDepartment.first;
          return dept == department;
        }).toList();
      }

      // Filter by document type
      if (documentType != null &&
          documentType.isNotEmpty &&
          documentType != 'Document Type') {
        filteredKnowledge = filteredKnowledge.where((knowledge) {
          String currentType = knowledge.knowledgeDocumentType.first;
          return currentType == documentType;
        }).toList();
      }

      // Apply search if exists
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Apply date filters
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in applyFilters: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }*/

  Future<void> applyFilters({
    String? documentType,
    String? status,
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      emit(FetchingSubmissionsLoadingState());

      selectedDocumentType = documentType;
      selectedStatus = status;
      selectedDepartment = department;
      selectedStartDate = startDate;
      selectedEndDate = endDate;

      // Start with all knowledge
      filteredKnowledge = List.from(allKnowledge);

      log('=== FILTER DEBUG ===');
      log('Document Type Filter: $documentType');
      log('Status Filter: $status');
      log('Department Filter: $department');
      log('Total knowledge before filter: ${filteredKnowledge.length}');

      // ✅ Filter by status
      if (status != null && status.isNotEmpty) {
        if (status == 'Pending') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'pending_approval' ||
                knowledge.currentStatus == 'scheduled';
          }).toList();
        } else if (status == 'Approved') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'approved';
          }).toList();
        } else if (status == 'Published') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'published';
          }).toList();
        } else if (status == 'Rejected') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'rejected';
          }).toList();
        } else if (status == 'Removed') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'removed';
          }).toList();
        } else if (status == 'Archive') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'archived';
          }).toList();
        }

        log('After status filter ($status): ${filteredKnowledge.length}');
      }

      // ✅ Filter by department
      if (department != null && department.isNotEmpty) {
        filteredKnowledge = filteredKnowledge.where((knowledge) {
          String dept = knowledge.owningDepartment.first;
          return dept == department;
        }).toList();

        log('After department filter ($department): ${filteredKnowledge.length}');
      }

      // ✅ COMPLETE FIX: Document type filter - match exact categories
      if (documentType != null && documentType.isNotEmpty) {
        log('📄 Filtering by document type: $documentType');

        // First, let's see what we have in the data
        log('📋 Sample document types in data:');
        for (var knowledge in filteredKnowledge.take(5)) {
          log('   - ${knowledge.nameEnglish.first}: "${knowledge.knowledgeDocumentType.first}"');
        }

        filteredKnowledge = filteredKnowledge.where((knowledge) {
          if (knowledge.knowledgeDocumentType.isEmpty) {
            log('   ⚠️ Empty document type for: ${knowledge.nameEnglish.first}');
            return false;
          }

          String storedType = knowledge.knowledgeDocumentType.first.trim();
          String filterType = documentType.trim();

          log('   Checking: ${knowledge.nameEnglish.first}');
          log('   Stored: "$storedType", Filter: "$filterType"');

          // ✅ Direct exact match (case-insensitive)
          bool matches = storedType.toLowerCase() == filterType.toLowerCase();

          if (matches) {
            log('   ✅ MATCH');
          } else {
            log('   ❌ NO MATCH');
          }

          return matches;
        }).toList();

        log('After document type filter ($documentType): ${filteredKnowledge.length}');

        // ✅ If no results, show what document types exist
        if (filteredKnowledge.isEmpty) {
          log('⚠️ NO RESULTS - Available document types in all data:');
          Set<String> availableTypes = {};
          for (var knowledge in allKnowledge) {
            if (knowledge.knowledgeDocumentType.isNotEmpty) {
              availableTypes.add(knowledge.knowledgeDocumentType.first);
            }
          }
          log('   Available: ${availableTypes.join(', ')}');
        }
      }

      // Apply search if exists
      if (searchQuery.isNotEmpty) {
        _applySearch();
        log('After search filter: ${filteredKnowledge.length}');
      }

      // Apply date filters
      _applyDateFilters();
      log('After date filters: ${filteredKnowledge.length}');

      log('=== FILTER COMPLETE - Final Count: ${filteredKnowledge.length} ===');

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('❌ Error in applyFilters: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ ADD THIS DEBUG METHOD to your SubmissionsCubit
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Debug: Show all unique document types in the database
  void debugDocumentTypes() {
    log('🔍 [DEBUG] All document types in submissions:');

    Map<String, int> typeCounts = {};

    for (var knowledge in allKnowledge) {
      if (knowledge.knowledgeDocumentType.isNotEmpty) {
        String type = knowledge.knowledgeDocumentType.first;
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      } else {
        typeCounts['<empty>'] = (typeCounts['<empty>'] ?? 0) + 1;
      }
    }

    log('📊 Document type distribution:');
    typeCounts.forEach((type, count) {
      log('   • "$type": $count documents');
    });
  }


  /// ✅ Helper method to add to your cubit for debugging
  void debugAvailableDocumentTypes() {
    log('🔍 [DEBUG] All document types in submissions:');

    Map<String, int> extensionCounts = {};
    Map<String, int> typeCounts = {};

    for (var knowledge in allKnowledge) {
      String ext = knowledge.currentDocumentExtension;
      String type = knowledge.knowledgeDocumentType.isNotEmpty
          ? knowledge.knowledgeDocumentType.first
          : 'empty';

      extensionCounts[ext] = (extensionCounts[ext] ?? 0) + 1;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    log('📊 Extensions found:');
    extensionCounts.forEach((ext, count) {
      log('   - "$ext": $count documents');
    });

    log('📊 Document types found:');
    typeCounts.forEach((type, count) {
      log('   - "$type": $count documents');
    });
  }


  /// ✅ Reset all filters including department
  Future<void> resetFilters() async {
    try {
      selectedDocumentType = null;
      selectedStatus = null;
      selectedInnerStatus = null;
      selectedDepartment = null;
      selectedStartDate = null;
      selectedEndDate = null;
      searchQuery = '';
      selectedStatusIndex = 0;
      selectedInnerStatusIndex = 0;

      filteredKnowledge = List.from(allKnowledge);
      upperCategoryFiltered = List.from(allKnowledge);

      emit(ChangeIndexSuccessState(0));
      emit(ChangeInnerIndexSuccessState(0));

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in resetFilters: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }


  /// Map display status names to actual database status values
  String _mapDisplayStatusToActual(String displayStatus) {
    switch (displayStatus) {
      case 'Published':
        return 'published';
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
      final userIds = comments
          .map((c) => c.currentCreatedById)
          .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
          .toSet()
          .toList();

      if (userIds.isEmpty) return;

      final newUsers = await _firebaseServices.fetchMultipleUserData(userIds);
      _usersCache.addAll(newUsers);

      log('Cached ${newUsers.length} user records for comments');
    } catch (e) {
      log('Error fetching users for comments: $e');
    }
  }


  /// Get user data for a specific userId (from cache or fetch)
  Future<EmployeeData?> getUserData(String userId) async {
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId];
    }

    try {
      final userData = await _firebaseServices.fetchUserDataByUserId(userId);
      if (userData != null) {
        _usersCache[userId] = userData;
      }
      return userData;
    } catch (e) {
      log('Error fetching user data for $userId: $e');
      return null;
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

      await _fetchUsersForComments(currentComments);

      if (currentComments.isEmpty) {
        emit(FetchingCommentsEmptyState());
      } else {
        emit(FetchingCommentsSuccessState(currentComments));
      }
    } catch (e) {
      log('Error in fetchCommentsByKnowledgeId: $e');
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

      String commentId = DateTime.now().millisecondsSinceEpoch.toString();

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
        await fetchCommentsByKnowledgeId(knowledgeId);
      } else {
        emit(AddingCommentErrorState('Failed to add comment'));
      }
    } catch (e) {
      log('Error in addComment: $e');
      emit(AddingCommentErrorState(e.toString()));
    }
  }


  /// Clear comments (when leaving the screen)
  void clearComments() {
    currentComments = [];
    currentKnowledgeId = null;
    emit(SubmissionsInitial());
  }


  /// Clear the users cache
  void clearUsersCache() {
    _usersCache.clear();
  }


  /// Record file action (download or view)
  Future<void> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String userId,
  }) async {
    try {
      log('📝 Recording file action:', name: 'SubmissionsCubit');
      log('   Knowledge ID: $knowledgeId', name: 'SubmissionsCubit');
      log('   Action Type: $typeOfAction', name: 'SubmissionsCubit');
      log('   User ID: $userId', name: 'SubmissionsCubit'); // ✅ DEBUG: Check what ID is being saved

      final controller = Get.find<MainCoreEmployeeController>();
      final employeeEntity = controller.employeeEntity!;

      // ✅ CRITICAL: Make sure you're using the CORRECT user ID
      // The ID should match what's stored in your employee collection
      log('   Employee Entity ID: ${employeeEntity.id}', name: 'SubmissionsCubit');
      log('   Employee Email: ${employeeEntity.email}', name: 'SubmissionsCubit');

      // Continue with your implementation...
    } catch (e) {
      log('❌ Error recording file action: $e', name: 'SubmissionsCubit');
    }
  }

}
