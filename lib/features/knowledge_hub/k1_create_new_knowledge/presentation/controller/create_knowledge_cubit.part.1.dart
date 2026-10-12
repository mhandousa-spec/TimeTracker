part of './create_knowledge_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 1 of CreateKnowledgeCubit (kept under 800 LOC, §7).
extension CreateKnowledgeCubitPart1 on CreateKnowledgeCubit {

  void setCurrentUser({String? department, String? email}) {
    currentUserDepartment = department?.toLowerCase().trim();
    currentUserEmail = email?.toLowerCase().trim();
    log('👤 [USER] Current user set - Department: $currentUserDepartment, Email: $currentUserEmail');
  }



  /// Fetch supervisor email for the current employee
  Future<String?> getSupervisorEmail() async {
    try {
      // Try to get from MainCoreEmployeeController first
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        final employeeController = Get.find<MainCoreEmployeeController>();
        final employee = employeeController.employeeEntity;

        if (employee?.supervisor != null && employee!.supervisor!.isNotEmpty) {
          log('✅ Supervisor email from controller: ${employee.supervisor}');
          return employee.supervisor;
        }

        // If supervisorEmail is not directly available, resolve via the
        // service (employees / departments reads owned by the data layer, N02).
        if (employee?.id != null || employee?.departmentId != null) {
          final resolved = await _firebaseServices.getSupervisorEmailFromFirestore(
            employeeId: employee?.id,
            departmentId: employee?.departmentId,
          );
          if (resolved != null && resolved.isNotEmpty) {
            log('✅ Supervisor email resolved from Firestore: $resolved');
            return resolved;
          }
        }
      }

      log('⚠️ Supervisor email not found');
      return null;
    } catch (e) {
      log('❌ Error fetching supervisor email: $e');
      return null;
    }
  }


  /// Function Name: [sendNotificationToSupervisor]
  ///
  /// Purpose: Raise the two §1.1 events a submission produces — "Review
  /// Request Assigned to You" for the approver, and "Document Submitted for
  /// Review" back to the author.
  ///
  /// ⚠️ REWRITTEN 1/9/2026. The previous body hand-built a title and body in
  /// Dart ("Review in Progress"), pushed them through
  /// `NotificationServiceApp.sendNotification` and wrote a raw map to the
  /// Notifications collection. It was wrong in the same four ways the
  /// approvals cubit was:
  ///
  ///   • `'Name_of_module': 'knowledgeHub'` — camelCase, so
  ///     `NotificationRouting.moduleForStoredKey` could not resolve it and the
  ///     card showed "Error occurred" when tapped. (The comment above it even
  ///     claimed "Use 'knowledge_hub' to match the module enum key" — the
  ///     value below it never was.)
  ///   • Only the SENDER's language was stored, so an author working in Arabic
  ///     sent Arabic to an English-reading supervisor, permanently.
  ///   • The wording was invented locally and did not match the spec.
  ///   • It bypassed `notification_templates` entirely, so Notification
  ///     Control could neither reword it nor switch it off.
  ///
  /// It also sent ONE notification, to the supervisor. §1.1 defines two
  /// distinct events here, addressed to two different people: the approver is
  /// told a review is assigned TO THEM, and the author gets the confirmation
  /// that their document is under review. The author previously got nothing
  /// at all — they submitted a document and the app went quiet.
  ///
  /// Parameters:
  /// - [documentNameEn] / [documentNameAr]: the document's two names, each
  ///   interpolated into the matching language rendering.
  /// - [employeeEmail]: the author — the sender of the review request, and the
  ///   recipient of the submission confirmation.
  /// - [employeeName]: kept on the signature for the call site; the spec text
  ///   for these two events does not interpolate it.
  ///
  /// Returns: [bool] — true when the approver was notified. False means no
  /// supervisor could be resolved; the author's own confirmation is still
  /// sent, because it does not depend on there being an approver.
  Future<bool> sendNotificationToSupervisor({
    required String documentNameEn,
    required String documentNameAr,
    required String employeeEmail,
    required String employeeName,
  }) async {
    try {
      final bool isArabic = Get.locale?.languageCode == 'ar';

      // 1 — confirm to the author that the document is in the review queue.
      //     Independent of the supervisor lookup on purpose: a missing
      //     supervisor is a configuration gap, not a reason to leave the
      //     author with no feedback at all.
      await KnowledgeHubNotificationService.notifyAuthorOfSubmission(
        senderEmail: employeeEmail,
        authorEmail: employeeEmail,
        documentNameEn: documentNameEn,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

      // 2 — assign the review to the approver.
      final String? supervisorEmail = await getSupervisorEmail();
      if (supervisorEmail == null || supervisorEmail.isEmpty) {
        log('⚠️ [KH-NOTIFY] no supervisor resolved — review request not sent');
        return false;
      }

      final bool sent =
          await KnowledgeHubNotificationService.notifyApproverOfReviewRequest(
        senderEmail: employeeEmail,
        approverEmail: supervisorEmail,
        documentNameEn: documentNameEn,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );

      log('${sent ? '✅' : '⚠️'} [KH-NOTIFY] review request → $supervisorEmail');
      return sent;
    } catch (e, stackTrace) {
      log('❌ [KH-NOTIFY] submission notifications failed: $e\n$stackTrace');
      return false;
    }
  }


  List<String> _parseLimitedDepartments(List<dynamic> limitedDepartments) {
    try {
      if (limitedDepartments.isEmpty) {
        log('   📖 [PARSE] LimitedDepartments is empty - PUBLIC ACCESS');
        return [];
      }

      String jsonString = limitedDepartments.first.toString().trim();

      if (jsonString.isEmpty) {
        log('   📖 [PARSE] LimitedDepartments is empty string - PUBLIC ACCESS');
        return [];
      }

      List<dynamic> parsed = jsonDecode(jsonString);
      List<String> departments = parsed
          .map((e) => e.toString().toLowerCase().trim())
          .toList();

      log('   🔒 [PARSE] Limited to departments: $departments');
      return departments;
    } catch (e) {
      log('   ⚠️ [PARSE] Error parsing limitedDepartments: $e - Defaulting to PUBLIC ACCESS');
      return [];
    }
  }


  /// ✅ DEBUG VERSION: Enhanced with detailed print statements
  List<CreateKnowledgeModel> _filterByPublishedStatusAndAccess(
      List<CreateKnowledgeModel> knowledgeList,
      ) {
    log('═══════════════════════════════════════════════════════');
    log('🔍 [FILTER] Starting filter process - PUBLISHED ONLY');
    log('📊 [FILTER] Total documents from Firebase: ${knowledgeList.length}');
    log('👤 [FILTER] Current user department: "$currentUserDepartment"');
    log('═══════════════════════════════════════════════════════');

    // Debug: print all LATEST statuses found
    final statusCounts = <String, int>{};
    for (var knowledge in knowledgeList) {
      if (knowledge.status.isNotEmpty) {
        final status = knowledge.status.last.toLowerCase().trim();
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      } else {
        statusCounts['<empty>'] = (statusCounts['<empty>'] ?? 0) + 1;
      }
    }

    log('\n📊 [FILTER] LATEST Status distribution:');
    statusCounts.forEach((status, count) {
      log('   • "$status": $count documents');
    });

    int totalProcessed = 0;
    int rejectedByStatus = 0;
    int rejectedByAccess = 0;
    int approved = 0;

    final accessible = knowledgeList.where((knowledge) {
      totalProcessed++;

      log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      log('📄 Document #$totalProcessed');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      log('   Name EN: ${knowledge.nameEnglish.firstOrNull ?? "Unknown"}');
      log('   Name AR: ${knowledge.nameArabic.firstOrNull ?? "Unknown"}');
      log('   All Statuses Array: ${knowledge.status}');
      log('   Owning Department: ${knowledge.owningDepartment.firstOrNull ?? "Unknown"}');
      log('   Limited Departments: ${knowledge.limitedDepartments}');

      // ✅ STEP 1: Check if PUBLISHED (ONLY) - using LATEST status
      String status = '';
      if (knowledge.status.isNotEmpty) {
        status = knowledge.status.last.toLowerCase().trim();
      }
      log('   📍 LATEST Status: "$status"');

      // ✅ Accept ONLY "published" status
      bool isPublished = status == 'published';
      log('   ✓ Is Published? $isPublished');

      if (!isPublished) {
        rejectedByStatus++;
        log('   ❌ REJECTED: Not published (latest status: "$status")');
        log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        return false;
      }

      // ✅ STEP 2: Check department access
      log('   🔐 Checking department access...');
      bool hasAccess = _hasAccessToDocument(knowledge);
      log('   ✓ Has Access? $hasAccess');

      if (!hasAccess) {
        rejectedByAccess++;
        log('   ❌ REJECTED: No department access');
        log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        return false;
      }

      approved++;
      log('   ✅ APPROVED: Published & Accessible');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return true;
    }).toList();

    log('\n═══════════════════════════════════════════════════════');
    log('📊 [FILTER] FINAL RESULTS:');
    log('═══════════════════════════════════════════════════════');
    log('   • Total documents processed: $totalProcessed');
    log('   • ❌ Rejected by status (not published): $rejectedByStatus');
    log('   • ❌ Rejected by access (no permission): $rejectedByAccess');
    log('   • ✅ APPROVED documents: $approved');
    log('═══════════════════════════════════════════════════════\n');

    return accessible;
  }


  Future<void> fetchAllKnowledge() async {
    try {
      log('\n🚀🚀🚀 [FETCH] Starting fetchAllKnowledge - PUBLISHED ONLY 🚀🚀🚀');
      log('═══════════════════════════════════════════════════════');

      emit(FetchingKnowledgeLoadingState());
      log('✓ [FETCH] Emitted loading state');

      log('📡 [FETCH] Calling Firebase to fetch documents...');
      final fetchedKnowledge = await _firebaseServices.fetchAllKnowledge();

      log('✓ [FETCH] Firebase returned ${fetchedKnowledge.length} total documents');

      if (fetchedKnowledge.isEmpty) {
        log('⚠️ [FETCH] WARNING: Firebase returned 0 documents!');
        log('⚠️ [FETCH] Check your Firebase connection and data');
      }

      log('\n📋 [FETCH] Applying filters (PUBLISHED ONLY)...');
      allKnowledge = _filterByPublishedStatusAndAccess(fetchedKnowledge);

      log('✓ [FETCH] After filtering: ${allKnowledge.length} published & accessible documents');

      filteredKnowledge = List.from(allKnowledge);
      log('✓ [FETCH] Copied to filteredKnowledge: ${filteredKnowledge.length} documents');

      if (filteredKnowledge.isEmpty) {
        log('\n⚠️⚠️⚠️ [FETCH] NO PUBLISHED DOCUMENTS FOUND! ⚠️⚠️⚠️');
        log('Possible reasons:');
        log('1. No documents with "published" status');
        log('2. User department not set: $currentUserDepartment');
        log('3. No documents accessible to this department');
        log('═══════════════════════════════════════════════════════\n');

        emit(FetchingKnowledgeEmptyState());
        log('✓ [FETCH] Emitted empty state');
      } else {
        log('\n✅✅✅ [FETCH] SUCCESS! ✅✅✅');
        log('Emitting ${filteredKnowledge.length} PUBLISHED documents');
        log('═══════════════════════════════════════════════════════\n');

        emit(FetchingKnowledgeSuccessState(filteredKnowledge));
        log('✓ [FETCH] Emitted success state with ${filteredKnowledge.length} documents');
      }
    } catch (e, stackTrace) {
      log('\n❌❌❌ [FETCH] ERROR! ❌❌❌');
      log('Error: $e');
      log('Stack trace: $stackTrace');
      log('═══════════════════════════════════════════════════════\n');

      emit(FetchingKnowledgeErrorState(e.toString()));
    }
  }


  bool _hasAccessToDocument(CreateKnowledgeModel knowledge) {
    try {
      log('      🔐 [ACCESS] Checking access for: ${knowledge.nameEnglish.firstOrNull}');

      log('      📋 [ACCESS] Raw limitedDepartments: ${knowledge.limitedDepartments}');
      List<String> limitedDepts = _parseLimitedDepartments(knowledge.limitedDepartments);
      log('      📋 [ACCESS] Parsed departments: $limitedDepts');

      if (limitedDepts.isEmpty) {
        log('      ✅ [ACCESS] PUBLIC ACCESS (no department restrictions)');
        return true;
      }

      if (currentUserDepartment == null || currentUserDepartment!.isEmpty) {
        log('      ❌ [ACCESS] DENIED - No user department set!');
        log('      ⚠️ [ACCESS] User department: $currentUserDepartment');
        return false;
      }

      log('      🔍 [ACCESS] Checking if "$currentUserDepartment" is in $limitedDepts');
      bool hasAccess = limitedDepts.contains(currentUserDepartment);

      if (hasAccess) {
        log('      ✅ [ACCESS] GRANTED - User dept matches!');
      } else {
        log('      ❌ [ACCESS] DENIED - User dept not in allowed list');
        log('      📊 [ACCESS] User dept: "$currentUserDepartment"');
        log('      📊 [ACCESS] Allowed: $limitedDepts');
      }

      return hasAccess;
    } catch (e) {
      log('      ⚠️ [ACCESS] ERROR: $e - DENYING access');
      return false;
    }
  }


  Future<void> filterByDepartment(String department, int index) async {
    try {
      selectedDepartmentIndex = index;
      selectedOwningDepartment = department;

      emit(ChangedIndexSuccessState(index));

      selectedInnerIndex = 0;
      selectedInnerCategory = null;
      emit(ChangedInnerIndexSuccessState(0));

      emit(FetchingKnowledgeLoadingState());

      // ✅ FIX: Handle both 'All' and 'الكل' (and any other translations)
      if (department == 'All' || department == 'الكل' || index == 0) {
        filteredKnowledge = List.from(allKnowledge);
      } else {
        filteredKnowledge = allKnowledge.where((knowledge) {
          String currentDept = knowledge.owningDepartment.first;
          return currentDept == department;
        }).toList();
      }

      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      if (filteredKnowledge.isEmpty) {
        emit(FetchingKnowledgeEmptyState());
      } else {
        emit(FetchingKnowledgeSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in filterByDepartment: $e');
      emit(FetchingKnowledgeErrorState(e.toString()));
    }
  }


  // ✅ FIXED: Handle both 'All' and 'الكل' in count
  int getKnowledgeCountByDepartment(String department) {
    // ✅ FIX: Handle both 'All' and 'الكل'
    if (department == 'All' || department == 'الكل') {
      return allKnowledge.length;
    }

    return allKnowledge.where((knowledge) {
      String currentDept = knowledge.owningDepartment.first;
      return currentDept == department;
    }).length;
  }

}
