part of './submissions_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 2 of SubmissionsCubit (kept under 800 LOC, §7).
extension SubmissionsCubitPart2 on SubmissionsCubit {

  /// ✅ COMPLETE STATUS FLOW: Auto-archive published documents when end date has passed
  /// ✅ COMPLETE STATUS FLOW: Auto-archive published documents when end date has passed
  Future<void> _autoArchiveExpiredDocuments() async {
    log('🗄️ [AUTO-ARCHIVE] Starting auto-archive check...');

    try {
      DateTime now = DateTime.now();
      log('⏰ [AUTO-ARCHIVE] Current time: $now');

      List<Map<String, dynamic>> documentsToArchive = []; // ✅ Changed to store document data
      int publishedCount = 0;
      int withEndDateCount = 0;
      int eligibleCount = 0;

      for (var knowledge in allKnowledge) {
        if (knowledge.currentStatus == 'published') {
          publishedCount++;

          log('📄 [AUTO-ARCHIVE] Checking published doc: ${knowledge.currentKnowledgeId}');

          // Only check documents that have end dates
          if (knowledge.currentEndDateTime != null) {
            try {
              DateTime endDate = knowledge.currentEndDateTime!.toDate();
              withEndDateCount++;

              log('   🕐 End date: $endDate');
              log('   ⏱️  Time difference: ${now.difference(endDate).inHours} hours');

              // Remove timezone by comparing dates only
              DateTime nowDate =
              DateTime(now.year, now.month, now.day, now.hour, now.minute);
              DateTime endDateOnly = DateTime(endDate.year, endDate.month,
                  endDate.day, endDate.hour, endDate.minute);

              log('   📆 Now: $nowDate');
              log('   📆 End: $endDateOnly');

              // ✅ SCENARIO 3: If end date has passed, auto-archive
              if (nowDate.isAfter(endDateOnly)) {
                eligibleCount++;

                // ✅ Store document data for notification
                documentsToArchive.add({
                  'knowledgeId': knowledge.currentKnowledgeId,
                  'creatorEmail': knowledge.createdByEmail.isNotEmpty
                      ? knowledge.createdByEmail.first
                      : '',
                  'nameEnglish': knowledge.currentNameEnglish,
                  'nameArabic': knowledge.currentNameArabic,
                  'endDate': endDate,
                });

                log('   ✅ ELIGIBLE for auto-archive! (End date has passed)');
              } else {
                log('   ⏭️  End date is in the future (${endDateOnly.difference(nowDate).inDays} days from now)');
              }
            } catch (e) {
              log('   ⚠️  Error parsing end date: $e');
            }
          } else {
            log('   ⏭️  No end date set - will remain published indefinitely');
          }
        }
      }

      log('📊 [AUTO-ARCHIVE] Summary:');
      log('   • Total published documents: $publishedCount');
      log('   • With end dates: $withEndDateCount');
      log('   • Eligible for auto-archive: $eligibleCount');
      log('   • Will update: ${documentsToArchive.length}');

      // Update all documents that need to be archived
      if (documentsToArchive.isNotEmpty) {
        log('🗄️ [AUTO-ARCHIVE] Archiving ${documentsToArchive.length} documents...');

        for (var docData in documentsToArchive) {
          String knowledgeId = docData['knowledgeId'];
          String creatorEmail = docData['creatorEmail'];
          String nameEnglish = docData['nameEnglish'];
          String nameArabic = docData['nameArabic'];
          DateTime endDate = docData['endDate'];

          log('   📦 Archiving: $knowledgeId', name: 'AUTO-ARCHIVE');

          // ✅ Update status to archived
          await _firebaseServices.updateSubmissionStatus(
            knowledgeId: knowledgeId,
            newStatus: 'archived',
          );

          // ✅ Send notification to document creator
          if (creatorEmail.isNotEmpty) {
            log('   📧 Sending archive notification to: $creatorEmail', name: 'AUTO-ARCHIVE');
            await _sendArchiveNotification(
              recipientEmail: creatorEmail,
              documentNameEnglish: nameEnglish,
              documentNameArabic: nameArabic,
              archivedDate: now,
            );
          } else {
            log('   ⚠️ No creator email found, skipping notification', name: 'AUTO-ARCHIVE');
          }
        }

        log('✅ [AUTO-ARCHIVE] Successfully auto-archived ${documentsToArchive.length} documents');
      } else {
        log('ℹ️ [AUTO-ARCHIVE] No documents need auto-archiving');
      }
    } catch (e) {
      log('❌ [AUTO-ARCHIVE] Error in _autoArchiveExpiredDocuments: $e');
    }
  }


  /// ✅ DEBUG: Check date parsing and comparison
  void _debugDateIssues() {
    log('🔍 [DATE DEBUG] Starting date debug check...');

    for (var knowledge in allKnowledge) {
      if (knowledge.currentStatus == 'published' &&
          knowledge.currentEndDateTime != null) {
        try {
          DateTime endDate = knowledge.currentEndDateTime!.toDate();
          DateTime now = DateTime.now();

          log('📄 Document: ${knowledge.currentKnowledgeId}');
          log('   📍 Status: ${knowledge.currentStatus}');
          log('   📅 End Date (Timestamp): ${knowledge.currentEndDateTime!.millisecondsSinceEpoch}');
          log('   📅 End Date (Parsed): $endDate');
          log('   📅 Current Date: $now');
          log('   ⏱️  Time Difference: ${now.difference(endDate).inHours} hours');
          log('   ❓ Should Archive? ${now.isAfter(endDate)}');
          log('   ---');
        } catch (e) {
          log('   ⚠️ Error parsing dates: $e');
        }
      }
    }
  }


  /// ✅ UPDATED: Update submission status with user validation
  Future<void> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      emit(FetchingSubmissionsLoadingState());

      // ✅ SECURITY: Verify the document belongs to current user
      final userEmail = _getCurrentUserEmail();
      final knowledge = allKnowledge.firstWhere(
        (k) => k.currentKnowledgeId == knowledgeId,
        orElse: () => CreateKnowledgeModel(
          timestamps: [],
          knowledgeId: [],
          nameEnglish: [],
          nameArabic: [],
          startTime: [], // ✅ ADD THIS LINE
          endTime: [],   // ✅ ADD THIS LINE
          descriptionEnglish: [],
          descriptionArabic: [],
          knowledgeDocumentType: [],
          owningDepartment: [],
          limitedDepartments: [],
          schedulePublishing: [],
          startDateTime: [],
          endDateTime: [],
          documentUrl: [],
          documentFileName: [],
          timeStamp: [],
          documentExtension: [],
          documentSize: [],
          status: [],
          createdByEmail: [],
        ),
      );

      // Check if document belongs to current user
      if (userEmail != null &&
          knowledge.createdByEmail.isNotEmpty &&
          knowledge.createdByEmail.first.toLowerCase().trim() != userEmail) {
        log('❌ [SECURITY] User $userEmail attempted to update document owned by ${knowledge.createdByEmail.first}');
        emit(FetchingSubmissionsErrorState(
            'Unauthorized: You can only update your own documents'));
        return;
      }

      String finalStatus = newStatus;

      // ✅ COMPLETE STATUS FLOW LOGIC
      if (newStatus == 'approved') {
        // Check if we should auto-publish immediately (no start date)
        if (knowledge.currentStartDateTime == null) {
          log('🚀 [STATUS FLOW] Approved with no start date - auto-publishing immediately');
          finalStatus = 'published';
        } else {
          // Has start date - remain approved until auto-publish triggers
          log('⏳ [STATUS FLOW] Approved with start date - will auto-publish later');
          finalStatus = 'approved';
        }
      }

      log('🔄 [STATUS UPDATE] Changing $knowledgeId from ${knowledge.currentStatus} to $finalStatus');

      bool success = await _firebaseServices.updateSubmissionStatus(
        knowledgeId: knowledgeId,
        newStatus: finalStatus,
      );

      if (success) {
        // If we published a document, check if it needs immediate archiving
        if (finalStatus == 'published') {
          await _checkImmediateArchiving(knowledgeId, knowledge);
        }

        // Refresh the list to get updated statuses
        await fetchAllSubmissionsEMp();

        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      } else {
        emit(FetchingSubmissionsErrorState('Failed to update status'));
      }
    } catch (e) {
      log('Error in updateSubmissionStatus: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }


  /// ✅ Check if a published document needs immediate archiving
  /// ✅ Check if a published document needs immediate archiving
  Future<void> _checkImmediateArchiving(
      String knowledgeId, CreateKnowledgeModel knowledge) async {
    try {
      if (knowledge.currentEndDateTime != null) {
        DateTime endDate = knowledge.currentEndDateTime!.toDate();
        DateTime now = DateTime.now();

        if (now.isAfter(endDate)) {
          log('📦 [IMMEDIATE ARCHIVE] Document $knowledgeId has passed end date - archiving now');

          // ✅ Update to archived status
          await _firebaseServices.updateSubmissionStatus(
            knowledgeId: knowledgeId,
            newStatus: 'archived',
          );

          // ✅ Send notification to creator
          String creatorEmail = knowledge.createdByEmail.isNotEmpty
              ? knowledge.createdByEmail.first
              : '';

          if (creatorEmail.isNotEmpty) {
            await _sendArchiveNotification(
              recipientEmail: creatorEmail,
              documentNameEnglish: knowledge.currentNameEnglish,
              documentNameArabic: knowledge.currentNameArabic,
              archivedDate: now,
            );
          }
        }
      }
    } catch (e) {
      log('Error in _checkImmediateArchiving: $e');
    }
  }




  /// Calculate status counts from allKnowledge list
  void _calculateStatusCounts() {
    statusCounts = {
      'All': allKnowledge.length,
      'Published': 0,
      'Approved': 0,
      'Pending': 0,
      'Rejected': 0,
      'Removed': 0,
      'Archive': 0,
    };

    for (var knowledge in allKnowledge) {
      String currentStatus = knowledge.currentStatus;

      if (currentStatus == 'published') {
        statusCounts['Published'] = (statusCounts['Published'] ?? 0) + 1;
      } else if (currentStatus == 'approved') {
        statusCounts['Approved'] = (statusCounts['Approved'] ?? 0) + 1;
      } else if (currentStatus == 'pending_approval' ||
          currentStatus == 'scheduled') {
        statusCounts['Pending'] = (statusCounts['Pending'] ?? 0) + 1;
      } else if (currentStatus == 'rejected') {
        statusCounts['Rejected'] = (statusCounts['Rejected'] ?? 0) + 1;
      } else if (currentStatus == 'removed') {
        statusCounts['Removed'] = (statusCounts['Removed'] ?? 0) + 1;
      } else if (currentStatus == 'archived') {
        statusCounts['Archive'] = (statusCounts['Archive'] ?? 0) + 1;
      }
    }

    log('Status counts calculated: $statusCounts');
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


  /// Change inner index (for UI highlighting)
  void chooseInnerIndex(int index) {
    selectedInnerStatusIndex = index;
    emit(ChangeInnerIndexSuccessState(index));
  }


  /// ✅ Filter by status with department consideration
  Future<void> filterByStatus(String status, int index) async {
    try {
      selectedStatusIndex = index;
      selectedStatus = status;
      selectedInnerStatus = null;
      selectedInnerStatusIndex = 0;

      emit(ChangeIndexSuccessState(index));
      emit(ChangeInnerIndexSuccessState(0));
      emit(FetchingSubmissionsLoadingState());

      // Filter locally based on upper category
      if (status == 'All') {
        upperCategoryFiltered = List.from(allKnowledge);
      } else if (status == 'Pending') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'pending_approval' ||
              knowledge.currentStatus == 'scheduled';
        }).toList();
      } else if (status == 'Approved') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'approved';
        }).toList();
      } else if (status == 'Published') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'published';
        }).toList();
      } else {
        String actualStatus = _mapDisplayStatusToActual(status);
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == actualStatus;
        }).toList();
      }

      // Start with upper category results
      filteredKnowledge = List.from(upperCategoryFiltered);

      // ✅ Apply department filter if selected
      if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
        _applyDepartmentFilter();
      }

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Apply date filters if set
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in filterByStatus: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }


  /// ✅ Filter by department
  Future<void> filterByDepartment(String? department) async {
    try {
      selectedDepartment = department;
      emit(FetchingSubmissionsLoadingState());

      // Start from current filtered results (respects status filter)
      filteredKnowledge = List.from(upperCategoryFiltered);

      // Apply department filter
      if (department != null && department.isNotEmpty) {
        _applyDepartmentFilter();
      }

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Apply date filters if set
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in filterByDepartment: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }


  /// ✅ Apply department filter to current filtered list
  void _applyDepartmentFilter() {
    if (selectedDepartment == null || selectedDepartment!.isEmpty) {
      return;
    }

    filteredKnowledge = filteredKnowledge.where((knowledge) {
      String dept = knowledge.owningDepartment.first;
      return dept == selectedDepartment;
    }).toList();

    log('Applied department filter: $selectedDepartment, results: ${filteredKnowledge.length}');
  }


  /// Filter by inner status (works within upper category results)
  Future<void> filterByInnerStatus(String innerStatus, int index) async {
    try {
      selectedInnerStatusIndex = index;
      selectedInnerStatus = innerStatus;

      emit(ChangeInnerIndexSuccessState(index));
      emit(FetchingSubmissionsLoadingState());

      // Start from upper category filtered results
      List<CreateKnowledgeModel> baseList = List.from(upperCategoryFiltered);

      // Apply inner filter
      if (innerStatus == 'All') {
        filteredKnowledge = baseList;
      } else if (innerStatus == 'Published') {
        filteredKnowledge = baseList.where((knowledge) {
          return knowledge.currentStatus == 'published';
        }).toList();
      } else if (innerStatus == 'Scheduled') {
        // Documents with schedulePublishing = true AND start date in the future
        filteredKnowledge = baseList.where((knowledge) {
          if (!knowledge.currentSchedulePublishing) return false;

          DateTime startDate = knowledge.currentStartDateTime!.toDate();
          DateTime now = DateTime.now();

          // Start date hasn't come yet
          return startDate.isAfter(now);
        }).toList();
      } else if (innerStatus == 'ExpiringSoon') {
        // Documents with end date within the next 2 weeks
        filteredKnowledge = baseList.where((knowledge) {
          DateTime endDate = knowledge.currentEndDateTime!.toDate();
          DateTime now = DateTime.now();
          DateTime twoWeeksFromNow = now.add(const Duration(days: 14));

          // End date is in the future but within 2 weeks
          return endDate.isAfter(now) && endDate.isBefore(twoWeeksFromNow);
        }).toList();
      } else if (innerStatus == 'Archive') {
        filteredKnowledge = baseList.where((knowledge) {
          return knowledge.currentStatus == 'archived';
        }).toList();
      }

      // ✅ Apply department filter if selected
      if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
        _applyDepartmentFilter();
      }

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Apply date filters if set
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in filterByInnerStatus: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }


  /// Search knowledge
  Future<void> searchKnowledge(String query) async {
    try {
      searchQuery = query;
      emit(FetchingSubmissionsLoadingState());

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

      // ✅ Apply department filter if selected
      if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
        _applyDepartmentFilter();
      }

      // Apply date filters if set
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in searchKnowledge: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }


  /// Apply search on current filtered list
  void _applySearch() {
    String lowerQuery = searchQuery.toLowerCase();

    // Search within the current filteredKnowledge
    List<CreateKnowledgeModel> searchBase = List.from(filteredKnowledge);

    filteredKnowledge = searchBase.where((knowledge) {
      String nameEn = knowledge.nameEnglish.first.toLowerCase();
      String nameAr = knowledge.nameArabic.first.toLowerCase();
      String descEn = knowledge.descriptionEnglish.first.toLowerCase();
      String descAr = knowledge.descriptionArabic.first.toLowerCase();

      return nameEn.contains(lowerQuery) ||
          nameAr.contains(lowerQuery) ||
          descEn.contains(lowerQuery) ||
          descAr.contains(lowerQuery);
    }).toList();
  }



  /// Filters by EXACT publish date and/or EXACT archive date (not ranges)
  void _applyDateFilters() {
    if (selectedStartDate == null && selectedEndDate == null) {
      return;
    }

    log('═══════════════════════════════════════', name: 'DateFilter');
    log('📅 [DATE FILTER] Starting EXACT date filter', name: 'DateFilter');
    log('   Filter Publish Date: $selectedStartDate', name: 'DateFilter');
    log('   Filter Archive Date: $selectedEndDate', name: 'DateFilter');
    log('═══════════════════════════════════════', name: 'DateFilter');

    int beforeCount = filteredKnowledge.length;
    int matchedCount = 0;
    int noPublishDateCount = 0;
    int noArchiveDateCount = 0;
    int notMatchingCount = 0;

    filteredKnowledge = filteredKnowledge.where((knowledge) {
      log('\n🔍 Checking: ${knowledge.currentNameEnglish}', name: 'DateFilter');

      // ✅ PUBLISH DATE = When document was published (from timestamps)
      DateTime? publishDate;

      if (knowledge.timestamps.isNotEmpty) {
        int publishTimestamp = knowledge.timestamps.first;
        publishDate = DateTime.fromMillisecondsSinceEpoch(publishTimestamp);
        log('   📅 Publish Date: $publishDate', name: 'DateFilter');
      } else {
        noPublishDateCount++;
        log('   ⚠️  No publish date (no timestamps)', name: 'DateFilter');
      }

      // ✅ ARCHIVE/END DATE = currentEndDateTime (expiry date)
      DateTime? archiveDate;

      try {
        if (knowledge.currentEndDateTime != null) {
          archiveDate = knowledge.currentEndDateTime!.toDate();
          log('   📅 Archive Date: $archiveDate', name: 'DateFilter');
        } else {
          noArchiveDateCount++;
          log('   ⚠️  No archive date set', name: 'DateFilter');
        }
      } catch (e) {
        log('   ❌ Error parsing archive date: $e', name: 'DateFilter');
      }

      // Normalize dates to start of day (remove time component)
      DateTime? normalizedPublishDate;
      DateTime? normalizedArchiveDate;
      DateTime? normalizedFilterPublish;
      DateTime? normalizedFilterArchive;

      if (publishDate != null) {
        normalizedPublishDate = DateTime(
          publishDate.year,
          publishDate.month,
          publishDate.day,
        );
      }

      if (archiveDate != null) {
        normalizedArchiveDate = DateTime(
          archiveDate.year,
          archiveDate.month,
          archiveDate.day,
        );
      }

      if (selectedStartDate != null) {
        normalizedFilterPublish = DateTime(
          selectedStartDate!.year,
          selectedStartDate!.month,
          selectedStartDate!.day,
        );
      }

      if (selectedEndDate != null) {
        normalizedFilterArchive = DateTime(
          selectedEndDate!.year,
          selectedEndDate!.month,
          selectedEndDate!.day,
        );
      }

      bool matchesFilter = true;

      // ✅ CASE 1: Filter by PUBLISH DATE only (EXACT match)
      if (selectedStartDate != null && selectedEndDate == null) {
        log('   🔍 Filtering by EXACT PUBLISH date', name: 'DateFilter');

        if (normalizedPublishDate != null) {
          // Must match EXACTLY
          bool exactMatch = normalizedPublishDate.isAtSameMomentAs(normalizedFilterPublish!);

          if (!exactMatch) {
            matchesFilter = false;
            notMatchingCount++;
            log('   ❌ REJECTED: Publish date doesn\'t match exactly', name: 'DateFilter');
            log('      Document: $normalizedPublishDate', name: 'DateFilter');
            log('      Filter: $normalizedFilterPublish', name: 'DateFilter');
          } else {
            log('   ✅ MATCH: Publish date matches exactly!', name: 'DateFilter');
          }
        } else {
          matchesFilter = false;
          log('   ❌ REJECTED: No publish date', name: 'DateFilter');
        }
      }

      // ✅ CASE 2: Filter by ARCHIVE DATE only (EXACT match)
      else if (selectedStartDate == null && selectedEndDate != null) {
        log('   🔍 Filtering by EXACT ARCHIVE date', name: 'DateFilter');

        if (normalizedArchiveDate != null) {
          // Must match EXACTLY
          bool exactMatch = normalizedArchiveDate.isAtSameMomentAs(normalizedFilterArchive!);

          if (!exactMatch) {
            matchesFilter = false;
            notMatchingCount++;
            log('   ❌ REJECTED: Archive date doesn\'t match exactly', name: 'DateFilter');
            log('      Document: $normalizedArchiveDate', name: 'DateFilter');
            log('      Filter: $normalizedFilterArchive', name: 'DateFilter');
          } else {
            log('   ✅ MATCH: Archive date matches exactly!', name: 'DateFilter');
          }
        } else {
          matchesFilter = false;
          log('   ❌ REJECTED: No archive date', name: 'DateFilter');
        }
      }

      // ✅ CASE 3: Filter by BOTH dates (BOTH must match EXACTLY)
      else if (selectedStartDate != null && selectedEndDate != null) {
        log('   🔍 Filtering by BOTH PUBLISH and ARCHIVE dates (exact match)', name: 'DateFilter');

        bool hasPublishDate = normalizedPublishDate != null;
        bool hasArchiveDate = normalizedArchiveDate != null;

        if (!hasPublishDate) {
          matchesFilter = false;
          log('   ❌ REJECTED: No publish date', name: 'DateFilter');
        } else if (!hasArchiveDate) {
          matchesFilter = false;
          log('   ❌ REJECTED: No archive date', name: 'DateFilter');
        } else {
          // Both dates must match EXACTLY
          bool publishMatches = normalizedPublishDate!.isAtSameMomentAs(normalizedFilterPublish!);
          bool archiveMatches = normalizedArchiveDate!.isAtSameMomentAs(normalizedFilterArchive!);

          if (!publishMatches) {
            matchesFilter = false;
            notMatchingCount++;
            log('   ❌ REJECTED: Publish date doesn\'t match', name: 'DateFilter');
            log('      Document: $normalizedPublishDate', name: 'DateFilter');
            log('      Filter: $normalizedFilterPublish', name: 'DateFilter');
          } else if (!archiveMatches) {
            matchesFilter = false;
            notMatchingCount++;
            log('   ❌ REJECTED: Archive date doesn\'t match', name: 'DateFilter');
            log('      Document: $normalizedArchiveDate', name: 'DateFilter');
            log('      Filter: $normalizedFilterArchive', name: 'DateFilter');
          } else {
            log('   ✅ MATCH: Both dates match exactly!', name: 'DateFilter');
            log('      Publish: $normalizedPublishDate = $normalizedFilterPublish', name: 'DateFilter');
            log('      Archive: $normalizedArchiveDate = $normalizedFilterArchive', name: 'DateFilter');
          }
        }
      }

      if (matchesFilter) {
        matchedCount++;
      }

      return matchesFilter;
    }).toList();

    log('\n═══════════════════════════════════════', name: 'DateFilter');
    log('📊 [DATE FILTER] SUMMARY:', name: 'DateFilter');
    log('   • Documents before filter: $beforeCount', name: 'DateFilter');
    log('   • Documents matched: $matchedCount', name: 'DateFilter');
    log('   • Documents without publish date: $noPublishDateCount', name: 'DateFilter');
    log('   • Documents without archive date: $noArchiveDateCount', name: 'DateFilter');
    log('   • Documents not matching: $notMatchingCount', name: 'DateFilter');
    log('   • Documents after filter: ${filteredKnowledge.length}', name: 'DateFilter');
    log('═══════════════════════════════════════\n', name: 'DateFilter');
  }

}
