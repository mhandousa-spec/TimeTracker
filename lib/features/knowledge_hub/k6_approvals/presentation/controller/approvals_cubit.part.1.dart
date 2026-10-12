part of './approvals_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 1 of ApprovalsCubit (kept under 800 LOC, §7).
extension ApprovalsCubitPart1 on ApprovalsCubit {

  /// ✅ SET CURRENT USER EMAIL (Call this when user logs in)
  void setCurrentUserEmail(String email) {
    currentUserEmail = email;
    log('🔐 Current user email set: $currentUserEmail');
  }




  int getStatusCountByKey(String statusKey) {
    switch (statusKey) {
      case 'all':
        return allKnowledge.length;
      case 'approved':
        return allKnowledge.where((k) =>
        k.currentStatus == 'approved' || k.currentStatus == 'published'
        ).length;
      case 'pending':
        return allKnowledge.where((k) =>
        k.currentStatus == 'pending_approval' || k.currentStatus == 'scheduled'
        ).length;
      case 'rejected':
        return allKnowledge.where((k) => k.currentStatus == 'rejected').length;
      case 'removed':
        return allKnowledge.where((k) => k.currentStatus == 'removed').length;
      default:
        return 0;
    }
  }


  /// Function Name: [_sendApprovalNotification]
  ///
  /// Purpose: Tell the document's author that their submission was approved
  /// or declined.
  ///
  /// ⚠️ REWRITTEN 1/9/2026. This method used to be ~110 lines that built a
  /// title and body in Dart, pushed them through
  /// `NotificationServiceApp.sendNotification`, then wrote a hand-rolled map
  /// to Firestore. Everything it produced was wrong in a way nothing would
  /// flag:
  ///
  ///   • `'Name_of_module': 'knowledgeHub'` — camelCase. Every AppModule key
  ///     is snake_case, and `NotificationRouting.moduleForStoredKey` resolves
  ///     the module from that string, so tapping the card produced
  ///     "Error occurred" instead of opening Knowledge Hub.
  ///   • ONE language was stored, picked from the APPROVER's locale. An
  ///     approver working in Arabic sent Arabic to an English author with no
  ///     other language in the document to fall back to.
  ///   • The wording ("Approval Granted" / "Approval Declined") was invented
  ///     here and did not match §1.1 of the notification spec.
  ///   • It never touched `notification_templates`, so an admin editing the
  ///     Knowledge Hub text — or switching the notification OFF — in
  ///     Notification Control had no effect on it at all.
  ///
  /// It is now one call into [KnowledgeHubNotificationService], which is the
  /// same route Services and Role Management take: spec wording, both
  /// languages stored, admin template + master switch respected, FCM push
  /// handled.
  ///
  /// The signature is unchanged so the two call sites in part 2 did not have
  /// to move.
  ///
  /// Parameters:
  /// - [recipientEmail]: the document's author.
  /// - [documentNameEnglish] / [documentNameArabic]: interpolated into the
  ///   matching language — no more 'English / عربي' in both bodies.
  /// - [isApproved]: which of the two spec events to raise.
  /// - [knowledgeId]: kept for logging and for future deep-linking.
  ///
  /// Returns: [bool] — true when the in-app notification was written.
  Future<bool> _sendApprovalNotification({
    required String recipientEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
    required bool isApproved,
    required String knowledgeId,
  }) async {
    if (recipientEmail.isEmpty) {
      log('⚠️ [KH-NOTIFY] decision on $knowledgeId — no recipient, skipped');
      return false;
    }

    final bool sent =
        await KnowledgeHubNotificationService.notifyAuthorOfDecision(
      approved: isApproved,
      approverEmail: currentUserEmail ?? '',
      authorEmail: recipientEmail,
      documentNameEn: documentNameEnglish,
      documentNameAr: documentNameArabic,
      isArabic: Get.locale?.languageCode == 'ar',
    );

    log('${sent ? '✅' : '⚠️'} [KH-NOTIFY] '
        '${isApproved ? 'approved' : 'rejected'} → $recipientEmail '
        '($knowledgeId)');
    return sent;
  }

  /// Function Name: [_announcePublication]
  ///
  /// Purpose: Raise §1.1 "Document Published and Effective".
  ///
  /// ADDED 1/9/2026. Approving a document without scheduled publishing makes
  /// it live immediately — `ApprovalsFirebaseServices.approveKnowledge` sets
  /// the status straight to `published` in that case. The spec lists that as
  /// its own notification, separate from the approval, and nothing raised it:
  /// the author was told "approved" and never told "your document is now
  /// public and in effect", which is the part that carries an obligation.
  ///
  /// Only fires for the immediate case. A SCHEDULED document is approved
  /// today and published later, at which point the publication is announced
  /// by whatever flips it — not here, where it would be a fortnight early.
  ///
  /// Returns: [bool] — true when the notification was written.
  Future<bool> _announcePublication({
    required String recipientEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
    required String knowledgeId,
  }) async {
    if (recipientEmail.isEmpty) return false;

    final bool sent = await KnowledgeHubNotificationService.notifyOfPublication(
      senderEmail: currentUserEmail ?? '',
      receiverEmail: recipientEmail,
      documentNameEn: documentNameEnglish,
      documentNameAr: documentNameArabic,
      isArabic: Get.locale?.languageCode == 'ar',
    );

    log('${sent ? '✅' : '⚠️'} [KH-NOTIFY] published → $recipientEmail '
        '($knowledgeId)');
    return sent;
  }

  /// Function Name: [returnForRevision]
  ///
  /// Purpose: Raise §1.1 "Document Returned for Revision" — the reviewer wants
  /// changes and expects the SAME document back, which is a different outcome
  /// from a rejection (that one ends the request).
  ///
  /// ADDED 1/9/2026. The spec defines the event, the template exists in
  /// Notification Control, and no code path could raise it because the
  /// approvals screen only offers Approve and Reject. This is the wiring for
  /// the button: it records the reviewer's notes on the approval record and
  /// tells the author what to change.
  ///
  /// The document's workflow status is deliberately left at
  /// `pending_approval`. A revision request is not an outcome — the same
  /// document is coming back — so it must stay in the approver's queue and
  /// out of the Rejected bucket, which is where routing it through
  /// [rejectKnowledge] would have put it.
  ///
  /// Parameters:
  /// - [knowledgeId]: the document being returned.
  /// - [revisionNotes]: the reviewer's comments, stored on the approval record
  ///   the same way a rejection reason is.
  ///
  /// Returns: [bool] — true when the notes were recorded and the author
  /// notified.
  Future<bool> returnForRevision({
    required String knowledgeId,
    required String revisionNotes,
  }) async {
    try {
      CreateKnowledgeModel? knowledgeDoc;
      try {
        knowledgeDoc = allKnowledge.firstWhere(
          (CreateKnowledgeModel doc) =>
              doc.currentKnowledgeId == knowledgeId ||
              doc.knowledgeId.contains(knowledgeId),
        );
      } catch (_) {
        log('❌ [KH-NOTIFY] returnForRevision: $knowledgeId not found');
        return false;
      }

      final bool recorded = await _firebaseServices.createOrUpdateApproval(
        knowledgeId: knowledgeId,
        status: 'pending_approval',
        rejectionReason: revisionNotes,
        approvalJustification: '',
      );
      if (!recorded) return false;

      final String authorEmail = knowledgeDoc.createdByEmail.isNotEmpty
          ? knowledgeDoc.createdByEmail.first
          : knowledgeDoc.currentCreatedByEmail;

      return KnowledgeHubNotificationService.notifyAuthorOfRevisionRequest(
        senderEmail: currentUserEmail ?? '',
        authorEmail: authorEmail,
        documentNameEn: knowledgeDoc.currentNameEnglish,
        documentNameAr: knowledgeDoc.currentNameArabic,
        isArabic: Get.locale?.languageCode == 'ar',
      );
    } catch (e) {
      log('❌ [KH-NOTIFY] returnForRevision failed: $e');
      return false;
    }
  }

  /// Filter by status using language-independent key
  Future<void> filterByStatusKey(String statusKey, int index) async {
    try {
      selectedStatusIndex = index;
      selectedInnerStatus = null;
      selectedInnerStatusIndex = 0;

      emit(ChangeIndexSuccessState(index));
      emit(FetchingApprovalsLoadingState());

      // Filter locally based on status key
      if (statusKey == 'all') {
        upperCategoryFiltered = List.from(allKnowledge);
        selectedStatus = 'All'; // Keep for backward compatibility
      } else if (statusKey == 'approved') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'published' ||
              knowledge.currentStatus == 'approved';
        }).toList();
        selectedStatus = 'Approved';
      } else if (statusKey == 'pending') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'pending_approval' ||
              knowledge.currentStatus == 'scheduled';
        }).toList();
        selectedStatus = 'Pending';
      } else if (statusKey == 'rejected') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'rejected';
        }).toList();
        selectedStatus = 'Rejected';
      } else if (statusKey == 'removed') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'removed';
        }).toList();
        selectedStatus = 'Removed';
      }

      // Start with upper category results
      filteredKnowledge = List.from(upperCategoryFiltered);

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // ✅ ONLY apply date filters if they are actually set
      if (selectedStartDate != null || selectedEndDate != null) {
        _applyDateFilters();
      }

      if (filteredKnowledge.isEmpty) {
        emit(FetchingApprovalsEmptyState());
      } else {
        emit(FetchingApprovalsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('❌ Error in filterByStatusKey: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }


  /// Filter by department
  Future<void> filterByDepartment(String? departmentId) async {
    try {
      emit(FetchingApprovalsLoadingState());

      List<CreateKnowledgeModel> baseList = List.from(allKnowledge);

      if (departmentId == null || departmentId == "all") {
        filteredKnowledge = baseList;
        log('✅ Showing all departments');
      } else {
        try {
          final departmentController = Get.find<MainCoreDepartmentCubit>();
          String? departmentName = departmentController.getEnglishDepartmentNameFromDepartmentId(
              departmentId: departmentId
          );

          log('🔍 Department ID received: $departmentId');
          log('🔍 Department Name from Controller: $departmentName');

          if (departmentName == null || departmentName.isEmpty) {
            log('❌ Could not find department name for ID: $departmentId');
            filteredKnowledge = [];
          } else {
            String departmentNameLower = departmentName.toLowerCase();

            filteredKnowledge = baseList.where((knowledge) {
              String docDepartment = knowledge.currentOwningDepartment.toLowerCase();

              log('🔍 Document: ${knowledge.currentNameEnglish} - Dept: "$docDepartment" vs "$departmentNameLower" = ${docDepartment == departmentNameLower}');

              return docDepartment == departmentNameLower;
            }).toList();

            log('🏢 Found ${filteredKnowledge.length} documents in department "$departmentName"');
          }
        } catch (e) {
          log('❌ Error getting department: $e');
          filteredKnowledge = [];
        }
      }

      // Apply status filter
      if (selectedStatus != null && selectedStatus != 'All') {
        log('✅ Applying status filter: $selectedStatus');
        if (selectedStatus == 'Approved') {
          filteredKnowledge = filteredKnowledge.where((k) =>
          k.currentStatus == 'published' || k.currentStatus == 'approved'
          ).toList();
        } else if (selectedStatus == 'Pending') {
          filteredKnowledge = filteredKnowledge.where((k) =>
          k.currentStatus == 'pending_approval' || k.currentStatus == 'scheduled'
          ).toList();
        } else {
          String actualStatus = _mapDisplayStatusToActual(selectedStatus!);
          filteredKnowledge = filteredKnowledge.where((k) =>
          k.currentStatus == actualStatus
          ).toList();
        }
        log('📊 After status filter: ${filteredKnowledge.length} documents');
      }

      // Apply search
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // ✅ ONLY apply date filters if they are actually set
      if (selectedStartDate != null || selectedEndDate != null) {
        _applyDateFilters();
      }

      if (filteredKnowledge.isEmpty) {
        emit(FetchingApprovalsEmptyState());
      } else {
        emit(FetchingApprovalsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('❌ Error in filterByDepartment: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }


  /// ✅ Fetch all knowledge documents that current user supervises (ALL STATUSES)
  Future<void> fetchAllSubmissions() async {
    try {
      emit(FetchingApprovalsLoadingState());

      // ✅ Check if current user email is set
      if (currentUserEmail == null || currentUserEmail!.isEmpty) {
        log('❌ Current user email not set!');
        emit(FetchingApprovalsErrorState('User email not found. Please log in again.'));
        return;
      }

      log('📥 Fetching all knowledge documents...');
      log('👤 Current logged-in user (Supervisor): $currentUserEmail');

      // Fetch ALL knowledge documents from Firebase
      List<CreateKnowledgeModel> allDocs = await _firebaseServices.fetchAllKnowledge();
      log('📊 Total documents fetched: ${allDocs.length}');

      // ✅ NEW LOGIC: Show ALL documents where current user is the approver
      List<CreateKnowledgeModel> approvalDocs = [];

      for (var doc in allDocs) {
        try {
          // ✅ REMOVED: No longer skip approved/rejected documents
          // We want to show ALL documents supervised by current user

          // Get the email of the person who created this document
          String createdByEmail = doc.createdByEmail.isNotEmpty
              ? doc.createdByEmail.first
              : '';

          if (createdByEmail.isEmpty) {
            log('⚠️ Document ${doc.knowledgeId.first} has no creator email, skipping');
            continue;
          }

          log('🔍 Checking document: ${doc.nameEnglish.first}');
          log('   Created by: $createdByEmail');
          log('   Current status: ${doc.currentStatus}');

          // ✅ Fetch the creator's employee data to get their supervisor
          EmployeeData? creatorData = await getUserDataByEmail(createdByEmail);

          if (creatorData == null) {
            log('⚠️ Could not find employee data for creator: $createdByEmail');
            continue;
          }

          String creatorSupervisor = creatorData.currentemployeeSupervisor;
          log('   Creator supervisor from DB: $creatorSupervisor');
          log('   Current user (Potential approver): $currentUserEmail');

          // ✅ Check if current user is the supervisor (regardless of status)
          if (creatorSupervisor.isNotEmpty &&
              creatorSupervisor.toLowerCase() == currentUserEmail!.toLowerCase()) {
            approvalDocs.add(doc);
            log('✅ ADDED - Current user is the supervisor (Status: ${doc.currentStatus})');
          } else {
            log('❌ EXCLUDED - Current user is NOT the supervisor');
          }
        } catch (e) {
          log('❌ Error processing document ${doc.knowledgeId.first}: $e');
          continue;
        }
      }

      log('📋 Final documents supervised by current user: ${approvalDocs.length}');

      allKnowledge = approvalDocs;
      filteredKnowledge = List.from(allKnowledge);
      upperCategoryFiltered = List.from(allKnowledge);

      // Calculate status counts locally
      _calculateStatusCounts();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingApprovalsEmptyState());
      } else {
        emit(FetchingApprovalsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('❌ Error in fetchAllSubmissions: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }



  /// ✅ DEBUG: Check current user's supervisor relationships
  Future<void> debugCurrentUserSupervisorRelationships() async {
    log('🔍 DEBUG: Checking supervisor relationships for current user');

    try {
      // Get current user data
      EmployeeData? currentUser = await getUserDataByEmail(currentUserEmail!);

      if (currentUser != null) {
        log('👤 CURRENT USER DETAILS:');
        log('   Name: ${currentUser.currentemployeeName}');
        log('   Email: ${currentUser.currentemployeeEmail}');
        log('   Supervisor: ${currentUser.currentemployeeSupervisor}');
        log('   Role: ${currentUser.currentemployeeRole}');
        log('   Department: ${currentUser.currentemployeeDepartment}');
      }

      // Check who reports to current user
      List<EmployeeData> allEmployees = await _firebaseServices.fetchAllEmployees();
      List<EmployeeData> directReports = allEmployees.where((employee) {
        return employee.currentemployeeSupervisor.toLowerCase() == currentUserEmail!.toLowerCase();
      }).toList();

      log('📊 DIRECT REPORTS to current user: ${directReports.length}');
      for (var employee in directReports) {
        log('   - ${employee.currentemployeeName} (${employee.currentemployeeEmail})');
      }

      // Check knowledge documents from direct reports
      List<CreateKnowledgeModel> allDocs = await _firebaseServices.fetchAllKnowledge();
      List<CreateKnowledgeModel> teamDocs = allDocs.where((doc) {
        String createdByEmail = doc.createdByEmail.isNotEmpty ? doc.createdByEmail.first : '';
        return directReports.any((emp) => emp.currentemployeeEmail == createdByEmail);
      }).toList();

      log('📝 KNOWLEDGE DOCUMENTS from direct reports: ${teamDocs.length}');
      for (var doc in teamDocs) {
        log('   - ${doc.nameEnglish.first} by ${doc.createdByEmail.first}');
      }

    } catch (e) {
      log('❌ Debug error: $e');
    }
  }


  /// Calculate status counts from allKnowledge list
  void _calculateStatusCounts() {
    statusCounts = {
      'All': allKnowledge.length,
      'Approved': 0,
      'Pending': 0,
      'Rejected': 0,
      'Removed': 0,
      'Archive': 0,
    };

    // ✅ Add this to see what statuses actually exist
    Set<String> uniqueStatuses = {};

    for (var knowledge in allKnowledge) {
      String currentStatus = knowledge.currentStatus;

      // ✅ Track unique statuses for debugging
      uniqueStatuses.add(currentStatus);

      if (currentStatus == 'approved' || currentStatus == 'published') {
        statusCounts['Approved'] = (statusCounts['Approved'] ?? 0) + 1;
      } else if (currentStatus == 'pending_approval' || currentStatus == 'scheduled') {
        statusCounts['Pending'] = (statusCounts['Pending'] ?? 0) + 1;
      } else if (currentStatus == 'rejected') {
        statusCounts['Rejected'] = (statusCounts['Rejected'] ?? 0) + 1;
      } else if (currentStatus == 'removed') {
        statusCounts['Removed'] = (statusCounts['Removed'] ?? 0) + 1;
      } else if (currentStatus == 'archived') {
        statusCounts['Archive'] = (statusCounts['Archive'] ?? 0) + 1;
      }
    }

    log('📊 Status counts calculated: $statusCounts');
    log('🔍 Unique statuses found in data: $uniqueStatuses');
  }


  /// Get count for specific status
  int getStatusCount(String status) {
    return statusCounts[status] ?? 0;
  }


  /// Change selected index (for UI highlighting)
  void chooseIndex(int index) {
    selectedStatusIndex = index;
    emit(ChangeIndexSuccessState(index));
  }


  /// Filter by status (upper category)
  Future<void> filterByStatus(String status, int index) async {
    try {
      selectedStatusIndex = index;
      selectedStatus = status;
      selectedInnerStatus = null;
      selectedInnerStatusIndex = 0;

      emit(ChangeIndexSuccessState(index));
      emit(FetchingApprovalsLoadingState());

      // Filter locally based on upper category
      if (status == 'All') {
        upperCategoryFiltered = List.from(allKnowledge);
      } else if (status == 'Approved') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'published' ||
              knowledge.currentStatus == 'approved';
        }).toList();
      } else if (status == 'Pending') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'pending_approval' ||
              knowledge.currentStatus == 'scheduled';
        }).toList();
      } else {
        String actualStatus = _mapDisplayStatusToActual(status);
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == actualStatus;
        }).toList();
      }

      // Start with upper category results
      filteredKnowledge = List.from(upperCategoryFiltered);

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // ✅ ONLY apply date filters if they are actually set
      if (selectedStartDate != null || selectedEndDate != null) {
        _applyDateFilters();
      }

      if (filteredKnowledge.isEmpty) {
        emit(FetchingApprovalsEmptyState());
      } else {
        emit(FetchingApprovalsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('❌ Error in filterByStatus: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }


  /// Search knowledge
  Future<void> searchKnowledge(String query) async {
    try {
      searchQuery = query;
      emit(FetchingApprovalsLoadingState());

      if (query.isEmpty) {
        // Reset to filtered by status only
        if (selectedStatus == null || selectedStatus == 'All') {
          filteredKnowledge = List.from(allKnowledge);
        } else {
          // Reapply status filter
          await filterByStatus(selectedStatus!, selectedStatusIndex);
          return;
        }
      } else {
        _applySearch();
      }

      // ✅ ONLY apply date filters if they are actually set
      if (selectedStartDate != null || selectedEndDate != null) {
        _applyDateFilters();
      }

      if (filteredKnowledge.isEmpty) {
        emit(FetchingApprovalsEmptyState());
      } else {
        emit(FetchingApprovalsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('❌ Error in searchKnowledge: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }


  /// Apply search on current filtered list
  void _applySearch() {
    String lowerQuery = searchQuery.toLowerCase();

    List<CreateKnowledgeModel> searchBase = List.from(filteredKnowledge);

    filteredKnowledge = searchBase.where((knowledge) {
      // ✅ Search in both languages
      String nameEn = knowledge.currentNameEnglish.toLowerCase();
      String nameAr = knowledge.currentNameArabic.toLowerCase();
      String descEn = knowledge.currentDescriptionEnglish.toLowerCase();
      String descAr = knowledge.currentDescriptionArabic.toLowerCase();

      return nameEn.contains(lowerQuery) ||
          nameAr.contains(lowerQuery) ||
          descEn.contains(lowerQuery) ||
          descAr.contains(lowerQuery);
    }).toList();

    log('🔍 Search results: ${filteredKnowledge.length} documents found');
  }


  /// Apply date filters to the current filtered list
  void _applyDateFilters() {
    // ✅ ONLY apply if dates are actually set
    if (selectedStartDate == null && selectedEndDate == null) {
      return; // No date filters to apply
    }

    filteredKnowledge = filteredKnowledge.where((knowledge) {
      // ✅ FIXED: Don't filter out documents with empty timestamps
      if (knowledge.timestamps.isEmpty) {
        // If no timestamps, use current time as fallback
        // This ensures newly created/approved documents still appear
        DateTime docDate = DateTime.now();

        bool matchesStartDate =
            selectedStartDate == null ||
                docDate.isAfter(selectedStartDate!) ||
                docDate.isAtSameMomentAs(selectedStartDate!);

        bool matchesEndDate =
            selectedEndDate == null ||
                docDate.isBefore(selectedEndDate!.add(const Duration(days: 1))) ||
                docDate.isAtSameMomentAs(selectedEndDate!);

        return matchesStartDate && matchesEndDate;
      }

      // Get the latest timestamp (most recent status update)
      int latestTimestamp = knowledge.timestamps.last;
      DateTime docDate = DateTime.fromMillisecondsSinceEpoch(latestTimestamp);

      bool matchesStartDate =
          selectedStartDate == null ||
              docDate.isAfter(selectedStartDate!) ||
              docDate.isAtSameMomentAs(selectedStartDate!);

      bool matchesEndDate =
          selectedEndDate == null ||
              docDate.isBefore(selectedEndDate!.add(const Duration(days: 1))) ||
              docDate.isAtSameMomentAs(selectedEndDate!);

      return matchesStartDate && matchesEndDate;
    }).toList();

    log('📅 After date filtering: ${filteredKnowledge.length} documents');
  }


  /// Apply filters from dialog
  Future<void> applyFilters({
    String? documentType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      emit(FetchingApprovalsLoadingState());

      selectedDocumentType = documentType;
      selectedStatus = status;
      selectedStartDate = startDate;
      selectedEndDate = endDate;

      // See [ApprovalsCubit.dialogFilterActive]. 'All' is the status dropdown's
      // show-everything option and the two placeholder strings are what an
      // untouched dropdown reports, so none of them count as a filter — applying
      // the dialog with nothing chosen leaves the button plain.
      dialogFilterActive = (documentType != null &&
              documentType.isNotEmpty &&
              documentType != 'Document Type') ||
          (status != null &&
              status.isNotEmpty &&
              status != 'Status' &&
              status != 'All') ||
          startDate != null ||
          endDate != null;

      // Start with all knowledge
      filteredKnowledge = List.from(allKnowledge);

      // Filter by status
      if (status != null && status.isNotEmpty && status != 'Status') {
        if (status == 'All') {
          filteredKnowledge = List.from(allKnowledge);
        } else if (status == 'Approved') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'published' ||
                knowledge.currentStatus == 'approved';
          }).toList();
        } else if (status == 'Pending') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'pending_approval' ||
                knowledge.currentStatus == 'scheduled';
          }).toList();
        } else {
          String actualStatus = _mapDisplayStatusToActual(status);
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == actualStatus;
          }).toList();
        }
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

      // ✅ ONLY apply date filters if they are actually set
      if (selectedStartDate != null || selectedEndDate != null) {
        _applyDateFilters();
      }

      if (filteredKnowledge.isEmpty) {
        emit(FetchingApprovalsEmptyState());
      } else {
        emit(FetchingApprovalsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('❌ Error in applyFilters: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }

}
