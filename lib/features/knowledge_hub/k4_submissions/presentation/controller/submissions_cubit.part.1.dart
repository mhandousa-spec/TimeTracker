part of './submissions_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 1 of SubmissionsCubit (kept under 800 LOC, §7).
extension SubmissionsCubitPart1 on SubmissionsCubit {

  /// ✅ NEW: Set current user email
  void setCurrentUserEmail(String email) {
    _currentUserEmail = email.toLowerCase().trim();
    log('👤 [SUBMISSIONS] Current user set: $_currentUserEmail');
  }



  /// ✅ Check for expiring documents and send notifications
  Future<void> checkAndNotifyExpiringDocuments() async {
    try {
      log('═══════════════════════════════════════', name: 'ExpiringCheck');
      log('🔍 [EXPIRING CHECK] Starting expiring documents check', name: 'ExpiringCheck');
      log('═══════════════════════════════════════', name: 'ExpiringCheck');

      // ✅ Use _getCurrentUserEmail() instead of currentUserEmail
      final userEmail = _getCurrentUserEmail();

      if (userEmail == null || userEmail.isEmpty) {
        log('⚠️ [EXPIRING CHECK] No user email set, skipping check', name: 'ExpiringCheck');
        return;
      }

      log('👤 [EXPIRING CHECK] Checking documents for user: $userEmail', name: 'ExpiringCheck');

      // Get current date
      final now = DateTime.now();
      final twoWeeksFromNow = now.add(Duration(days: 14));

      log('📅 [EXPIRING CHECK] Current date: ${now.toIso8601String()}', name: 'ExpiringCheck');
      log('📅 [EXPIRING CHECK] Two weeks from now: ${twoWeeksFromNow.toIso8601String()}', name: 'ExpiringCheck');

      // ✅ Use allKnowledge from your cubit (it already exists)
      final userDocuments = allKnowledge.where((doc) {
        // Only check documents created by current user
        if (doc.createdByEmail.isEmpty) return false;
        String creatorEmail = doc.createdByEmail.first.toLowerCase().trim();
        return creatorEmail == userEmail;
      }).toList();

      log('📊 [EXPIRING CHECK] Total user documents: ${userDocuments.length}', name: 'ExpiringCheck');

      int expiringCount = 0;
      int notificationsSent = 0;

      for (var doc in userDocuments) {
        try {
          // ✅ Check if document has an end date using your model's getter
          if (doc.currentEndDateTime == null) {
            continue; // Skip if no end date
          }

          // Parse end date
          DateTime? endDate;

          try {
            endDate = doc.currentEndDateTime!.toDate();
          } catch (e) {
            log('⚠️ [EXPIRING CHECK] Could not parse end date for ${doc.currentNameEnglish}: $e', name: 'ExpiringCheck');
            continue;
          }

          if (endDate == null) continue;

          log('📄 [EXPIRING CHECK] Checking: ${doc.currentNameEnglish}', name: 'ExpiringCheck');
          log('   End Date: ${endDate.toIso8601String()}', name: 'ExpiringCheck');
          log('   Status: ${doc.currentStatus}', name: 'ExpiringCheck');

          // ✅ Check if document is expiring within 2 weeks
          bool isPublished = doc.currentStatus == 'published' || doc.currentStatus == 'approved';
          bool isExpiringWithinTwoWeeks = endDate.isAfter(now) && endDate.isBefore(twoWeeksFromNow);

          if (isPublished && isExpiringWithinTwoWeeks) {
            expiringCount++;

            log('⏰ [EXPIRING CHECK] Document expiring soon!', name: 'ExpiringCheck');
            log('   Document: ${doc.currentNameEnglish}', name: 'ExpiringCheck');
            log('   Expires on: ${endDate.toIso8601String()}', name: 'ExpiringCheck');
            log('   Days until expiry: ${endDate.difference(now).inDays}', name: 'ExpiringCheck');

            // ✅ Send notification
            bool sent = await _sendExpiringNotification(
              recipientEmail: userEmail,
              documentNameEnglish: doc.currentNameEnglish,
              documentNameArabic: doc.currentNameArabic,
              endDate: endDate,
            );

            if (sent) {
              notificationsSent++;
            }
          }
        } catch (e) {
          log('❌ [EXPIRING CHECK] Error checking document: $e', name: 'ExpiringCheck');
          continue;
        }
      }

      log('═══════════════════════════════════════', name: 'ExpiringCheck');
      log('📊 [EXPIRING CHECK] Summary:', name: 'ExpiringCheck');
      log('   Total documents checked: ${userDocuments.length}', name: 'ExpiringCheck');
      log('   Documents expiring within 2 weeks: $expiringCount', name: 'ExpiringCheck');
      log('   Notifications sent: $notificationsSent', name: 'ExpiringCheck');
      log('═══════════════════════════════════════', name: 'ExpiringCheck');

    } catch (e, stackTrace) {
      log('❌ [EXPIRING CHECK] Error in checkAndNotifyExpiringDocuments: $e', name: 'ExpiringCheck');
      log('❌ Stack trace: $stackTrace', name: 'ExpiringCheck');
    }
  }



  /// ✅ Send archive notification to document creator
  Future<bool> _sendArchiveNotification({
    required String recipientEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
    required DateTime archivedDate,
  }) async {
    try {
      log('═══════════════════════════════════════', name: 'ArchiveNotification');
      log('📧 [ARCHIVE NOTIFICATION] Starting notification process', name: 'ArchiveNotification');
      log('═══════════════════════════════════════', name: 'ArchiveNotification');

      if (recipientEmail.isEmpty) {
        log('⚠️ [ARCHIVE NOTIFICATION] No recipient email - notification skipped', name: 'ArchiveNotification');
        return false;
      }

      log('✅ [ARCHIVE NOTIFICATION] Recipient: $recipientEmail', name: 'ArchiveNotification');
      log('📄 [ARCHIVE NOTIFICATION] Document: $documentNameEnglish / $documentNameArabic', name: 'ArchiveNotification');
      log('📅 [ARCHIVE NOTIFICATION] Archived Date: ${archivedDate.toIso8601String()}', name: 'ArchiveNotification');

      // ✅ Determine current language from app locale
      bool isArabic = Get.locale?.languageCode == 'ar';
      log('🌐 [ARCHIVE NOTIFICATION] Current language: ${isArabic ? 'Arabic' : 'English'}', name: 'ArchiveNotification');

      // ✅ Format archived date based on language
      String formattedArchivedDate;
      if (isArabic) {
        formattedArchivedDate = '${archivedDate.day}/${archivedDate.month}/${archivedDate.year}';
      } else {
        // English format: Month Day, Year
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        formattedArchivedDate = '${months[archivedDate.month - 1]} ${archivedDate.day}, ${archivedDate.year}';
      }

      log('📅 [ARCHIVE NOTIFICATION] Formatted Archived Date: $formattedArchivedDate', name: 'ArchiveNotification');

      // ✅ Prepare notification content based on language
      String notificationTitle;
      String notificationBody;
      String documentName;

      if (isArabic) {
        // Arabic notification
        notificationTitle = 'تم أرشفة المستند';
        documentName = documentNameArabic;
        notificationBody = 'تم أرشفة المستند $documentName بتاريخ $formattedArchivedDate بسبب انتهاء فترة صلاحيته. يمكنك الوصول إليه من قسم الأرشيف إذا لزم الأمر.';
      } else {
        // English notification
        notificationTitle = 'Document Archived';
        documentName = documentNameEnglish;
        notificationBody = '$documentName has been archived on $formattedArchivedDate due to expiration. You can access it from the Archive section if needed.';
      }

      log('📝 [ARCHIVE NOTIFICATION] Title: $notificationTitle', name: 'ArchiveNotification');
      log('📝 [ARCHIVE NOTIFICATION] Body: $notificationBody', name: 'ArchiveNotification');

      // ✅ STEP 1: Send push notification via FCM
      log('📤 [ARCHIVE NOTIFICATION] Sending push notification...', name: 'ArchiveNotification');
      await NotificationServiceApp.sendNotification(
        notificationTitle,
        notificationBody,
        recipientEmail,
      );

      log('✅ [ARCHIVE NOTIFICATION] Push notification sent successfully', name: 'ArchiveNotification');

      // ✅ STEP 2: Save notification to Firestore Database
      log('💾 [ARCHIVE NOTIFICATION] Saving notification to Firestore database...', name: 'ArchiveNotification');

      try {
        String companyId = ApiConstants.baseUri.split("/").last;

        if (companyId.isEmpty) {
          companyId = 'bayanatz';
          log('⚠️ [ARCHIVE NOTIFICATION] Using default company ID: $companyId', name: 'ArchiveNotification');
        } else {
          log('🏢 [ARCHIVE NOTIFICATION] Company ID: $companyId', name: 'ArchiveNotification');
        }

        final notificationData = {
          'Name_of_module': 'knowledgeHub',
          'Pin': false,
          'Reciver_Email': recipientEmail,
          'Sender_Email': 'system@bayanatz.com', // System notification
          'body': notificationBody,
          'isClean': false,
          'isRead': false,
          'name_of_page': 'ViewKnowledgeHub',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'title': notificationTitle,
        };

        await KnowledgeHubFirebaseServices().saveNotificationRecord(notificationData);

        log('✅ [ARCHIVE NOTIFICATION] Saved to Firestore at path:', name: 'ArchiveNotification');
        log('   📋 Module: knowledgeHub', name: 'ArchiveNotification');
        log('   📋 Language: ${isArabic ? 'Arabic' : 'English'}', name: 'ArchiveNotification');
        log('   📋 Title: $notificationTitle', name: 'ArchiveNotification');

      } catch (firestoreError, stackTrace) {
        log('❌ [ARCHIVE NOTIFICATION] Firestore save error: $firestoreError', name: 'ArchiveNotification');
        log('❌ Stack trace: $stackTrace', name: 'ArchiveNotification');
      }

      log('═══════════════════════════════════════', name: 'ArchiveNotification');
      log('🎉 [ARCHIVE NOTIFICATION] Process completed successfully', name: 'ArchiveNotification');
      log('═══════════════════════════════════════', name: 'ArchiveNotification');

      return true;
    } catch (e, stackTrace) {
      log('❌ [ARCHIVE NOTIFICATION] Error sending notification: $e', name: 'ArchiveNotification');
      log('❌ Stack trace: $stackTrace', name: 'ArchiveNotification');
      return false;
    }
  }


  /// ✅ Send expiring notification to document creator
  Future<bool> _sendExpiringNotification({
    required String recipientEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
    required DateTime endDate,
  }) async {
    try {
      log('═══════════════════════════════════════', name: 'ExpiringNotification');
      log('📧 [EXPIRING NOTIFICATION] Starting notification process', name: 'ExpiringNotification');
      log('═══════════════════════════════════════', name: 'ExpiringNotification');

      if (recipientEmail.isEmpty) {
        log('⚠️ [EXPIRING NOTIFICATION] No recipient email - notification skipped', name: 'ExpiringNotification');
        return false;
      }

      log('✅ [EXPIRING NOTIFICATION] Recipient: $recipientEmail', name: 'ExpiringNotification');
      log('📄 [EXPIRING NOTIFICATION] Document: $documentNameEnglish / $documentNameArabic', name: 'ExpiringNotification');
      log('📅 [EXPIRING NOTIFICATION] End Date: ${endDate.toIso8601String()}', name: 'ExpiringNotification');

      // ✅ Determine current language from app locale
      bool isArabic = Get.locale?.languageCode == 'ar';
      log('🌐 [EXPIRING NOTIFICATION] Current language: ${isArabic ? 'Arabic' : 'English'}', name: 'ExpiringNotification');

      // ✅ Format end date based on language
      String formattedEndDate;
      if (isArabic) {
        formattedEndDate = '${endDate.day}/${endDate.month}/${endDate.year}';
      } else {
        // English format: Month Day, Year
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        formattedEndDate = '${months[endDate.month - 1]} ${endDate.day}, ${endDate.year}';
      }

      log('📅 [EXPIRING NOTIFICATION] Formatted End Date: $formattedEndDate', name: 'ExpiringNotification');

      // ✅ Prepare notification content based on language
      String notificationTitle;
      String notificationBody;
      String documentName;

      if (isArabic) {
        // Arabic notification
        notificationTitle = 'اقتراب انتهاء صلاحية المستند';
        documentName = documentNameArabic;
        notificationBody = 'يقترب المستند $documentName من نهاية فترة صلاحيته، وسيتم أرشفته بتاريخ $formattedEndDate ما لم يتم تحديثه أو تمديده. يرجى اتخاذ الإجراء اللازم للحفاظ على سريانه.';
      } else {
        // English notification
        notificationTitle = 'Document Expiration Approaching';
        documentName = documentNameEnglish;
        notificationBody = '$documentName is approaching the end of its validity period and will be archived on $formattedEndDate unless updated or extended. Please take the necessary action to maintain its applicability.';
      }

      log('📝 [EXPIRING NOTIFICATION] Title: $notificationTitle', name: 'ExpiringNotification');
      log('📝 [EXPIRING NOTIFICATION] Body: $notificationBody', name: 'ExpiringNotification');

      // ✅ STEP 1: Send push notification via FCM
      log('📤 [EXPIRING NOTIFICATION] Sending push notification...', name: 'ExpiringNotification');
      await NotificationServiceApp.sendNotification(
        notificationTitle,
        notificationBody,
        recipientEmail,
      );

      log('✅ [EXPIRING NOTIFICATION] Push notification sent successfully', name: 'ExpiringNotification');

      // ✅ STEP 2: Save notification to Firestore Database
      log('💾 [EXPIRING NOTIFICATION] Saving notification to Firestore database...', name: 'ExpiringNotification');

      try {
        String companyId = ApiConstants.baseUri.split("/").last;

        if (companyId.isEmpty) {
          companyId = 'bayanatz';
          log('⚠️ [EXPIRING NOTIFICATION] Using default company ID: $companyId', name: 'ExpiringNotification');
        } else {
          log('🏢 [EXPIRING NOTIFICATION] Company ID: $companyId', name: 'ExpiringNotification');
        }

        final notificationData = {
          'Name_of_module': 'knowledgeHub',
          'Pin': false,
          'Reciver_Email': recipientEmail,
          'Sender_Email': 'system@bayanatz.com', // System notification
          'body': notificationBody,
          'isClean': false,
          'isRead': false,
          'name_of_page': 'ViewKnowledgeHub',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'title': notificationTitle,
        };

        await KnowledgeHubFirebaseServices().saveNotificationRecord(notificationData);

        log('✅ [EXPIRING NOTIFICATION] Saved to Firestore at path:', name: 'ExpiringNotification');
        log('   📋 Module: knowledgeHub', name: 'ExpiringNotification');
        log('   📋 Language: ${isArabic ? 'Arabic' : 'English'}', name: 'ExpiringNotification');
        log('   📋 Title: $notificationTitle', name: 'ExpiringNotification');

      } catch (firestoreError, stackTrace) {
        log('❌ [EXPIRING NOTIFICATION] Firestore save error: $firestoreError', name: 'ExpiringNotification');
        log('❌ Stack trace: $stackTrace', name: 'ExpiringNotification');
      }

      log('═══════════════════════════════════════', name: 'ExpiringNotification');
      log('🎉 [EXPIRING NOTIFICATION] Process completed successfully', name: 'ExpiringNotification');
      log('═══════════════════════════════════════', name: 'ExpiringNotification');

      return true;
    } catch (e, stackTrace) {
      log('❌ [EXPIRING NOTIFICATION] Error sending notification: $e', name: 'ExpiringNotification');
      log('❌ Stack trace: $stackTrace', name: 'ExpiringNotification');
      return false;
    }
  }


  /// ✅ NEW: Get current user email from various sources
  String? _getCurrentUserEmail() {
    // If already set, return it
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      return _currentUserEmail;
    }

    // Try to get from GetX controller
    try {
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        final employeeController = Get.find<MainCoreEmployeeController>();
        if (employeeController.employeeEntity?.email != null) {
          _currentUserEmail =
              employeeController.employeeEntity!.email!.toLowerCase().trim();
          log('✅ [SUBMISSIONS] Email from MainCoreEmployeeController: $_currentUserEmail');
          return _currentUserEmail;
        }
      }
    } catch (e) {
      log('⚠️ [SUBMISSIONS] Error accessing MainCoreEmployeeController: $e');
    }

    // Try to get from ConstantVar
    try {
      if (ConstantVar.emailUser.isNotEmpty) {
        _currentUserEmail = ConstantVar.emailUser.toLowerCase().trim();
        log('✅ [SUBMISSIONS] Email from ConstantVar: $_currentUserEmail');
        return _currentUserEmail;
      }
    } catch (e) {
      log('⚠️ [SUBMISSIONS] Error accessing ConstantVar: $e');
    }

    log('❌ [SUBMISSIONS] No user email found!');
    return null;
  }


  /// ✅ NEW: Filter documents to only show current user's documents
  List<CreateKnowledgeModel> _filterByCurrentUser(
      List<CreateKnowledgeModel> knowledgeList) {
    final userEmail = _getCurrentUserEmail();

    if (userEmail == null) {
      log('⚠️ [FILTER] No user email - showing ALL documents (insecure!)');
      return knowledgeList;
    }

    log('🔐 [FILTER] Filtering documents for user: $userEmail');
    log('📊 [FILTER] Total documents before filtering: ${knowledgeList.length}');

    final userDocuments = knowledgeList.where((knowledge) {
      if (knowledge.createdByEmail.isEmpty) {
        log('   ⚠️ No creator email for document: ${knowledge.currentKnowledgeId}');
        return false;
      }

      final creatorEmail = knowledge.createdByEmail.first.toLowerCase().trim();
      final isUserDocument = creatorEmail == userEmail;

      if (!isUserDocument) {
        log('   ❌ Filtered out: ${knowledge.currentKnowledgeId} - Creator: $creatorEmail, Current User: $userEmail');
      } else {
        log('   ✅ Keeping: ${knowledge.currentKnowledgeId} - Creator: $creatorEmail');
      }

      return isUserDocument;
    }).toList();

    log('📊 [FILTER] Total documents after filtering: ${userDocuments.length}');
    return userDocuments;
  }


  // ✅ ADD THESE METHODS TO YOUR submissions_cubit.dart

  /// Update a comment's text
  Future<void> updateComment({
    required String knowledgeId,
    required String commentId,
    required String newText,
  }) async {
    try {
      emit(UpdatingCommentLoadingState());

      // Fetch the current comment
      final comment = currentComments.firstWhere(
        (c) => c.currentCommentId == commentId,
        orElse: () => CreateNewCommentModel(
          timestamps: [],
          commentId: [],
          commentText: [],
          createdById: [],
          createdByEmail: [],
          attachmentExtension: [],
          attachmentSize: [],
        ),
      );

      if (comment.commentId.isEmpty) {
        emit(UpdatingCommentErrorState('Comment not found'));
        return;
      }

      // Create updated comment using copyWith
      final updatedComment = comment.copyWith(
        commentText: newText,
      );

      // Update in Firebase
      bool success = await _firebaseServices.updateComment(
        knowledgeId: knowledgeId,
        commentId: commentId,
        updatedComment: updatedComment,
      );

      if (success) {
        emit(UpdatingCommentSuccessState());
        // Refresh comments
        await fetchCommentsByKnowledgeId(knowledgeId);
      } else {
        emit(UpdatingCommentErrorState('Failed to update comment'));
      }
    } catch (e) {
      log('Error in updateComment: $e');
      emit(UpdatingCommentErrorState(e.toString()));
    }
  }


  /// Delete a comment
  Future<void> deleteComment({
    required String knowledgeId,
    required String commentId,
  }) async {
    try {
      emit(DeletingCommentLoadingState());

      bool success = await _firebaseServices.deleteComment(
        knowledgeId: knowledgeId,
        commentId: commentId,
      );

      if (success) {
        emit(DeletingCommentSuccessState());
        // Refresh comments
        await fetchCommentsByKnowledgeId(knowledgeId);
      } else {
        emit(DeletingCommentErrorState('Failed to delete comment'));
      }
    } catch (e) {
      log('Error in deleteComment: $e');
      emit(DeletingCommentErrorState(e.toString()));
    }
  }


  /// ✅ UPDATED: Extract available departments from current user's documents only
  void _extractAvailableDepartments() {
    Set<String> departments = {};

    for (var knowledge in allKnowledge) {
      String dept = knowledge.owningDepartment.first;
      if (dept.isNotEmpty) {
        departments.add(dept);
      }
    }

    availableDepartments = departments.toList()..sort();
    log('Available departments for current user: $availableDepartments');
  }


  /// ✅ UPDATED: Fetch all knowledge documents with user filtering
  Future<void> fetchAllSubmissionsEMp() async {
    try {
      emit(FetchingSubmissionsLoadingState());

      // Get current user email first
      final userEmail = _getCurrentUserEmail();
      if (userEmail == null) {
        log('❌ [FETCH] Cannot fetch submissions - no user email available');
        emit(FetchingSubmissionsErrorState('User not authenticated'));
        return;
      }

      log('👤 [FETCH] Fetching submissions for user: $userEmail');

      // Fetch all documents from Firebase
      List<CreateKnowledgeModel> allDocuments =
          await _firebaseServices.fetchAllSubmissions();
      log('📥 [FETCH] Firebase returned ${allDocuments.length} total documents');

      // ✅ FILTER: Only show current user's documents
      allKnowledge = _filterByCurrentUser(allDocuments);
      debugDocumentTypes();
      log('✅ [FETCH] After user filtering: ${allKnowledge.length} documents');

      // ✅ Run complete status flow checks only on user's documents
      await _autoPublishScheduledDocuments();
      await _autoArchiveExpiredDocuments();
      _debugDateIssues();

      // ✅ Re-fetch after status updates to get current statuses
      allDocuments = await _firebaseServices.fetchAllSubmissions();
      allKnowledge = _filterByCurrentUser(allDocuments);
      log('🔄 [FETCH] After re-fetch and filtering: ${allKnowledge.length} documents');

      filteredKnowledge = List.from(allKnowledge);
      upperCategoryFiltered = List.from(allKnowledge);

      _extractAvailableDepartments();
      _calculateStatusCounts();

      if (filteredKnowledge.isEmpty) {
        log('📭 [FETCH] No submissions found for user: $userEmail');
        emit(FetchingSubmissionsEmptyState());
      } else {
        log('✅ [FETCH] Successfully loaded ${filteredKnowledge.length} submissions for user: $userEmail');
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      log('Error in fetchAllSubmissions: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }


  /// ✅ COMPLETE STATUS FLOW: Auto-publish approved documents based on start date
  Future<void> _autoPublishScheduledDocuments() async {
    log('🔄 [AUTO-PUBLISH] Starting auto-publish check...');

    try {
      DateTime now = DateTime.now();
      log('⏰ [AUTO-PUBLISH] Current time: $now');

      List<String> documentsToUpdate = [];
      int approvedCount = 0;
      int withStartDateCount = 0;
      int noStartDateCount = 0;
      int eligibleCount = 0;

      for (var knowledge in allKnowledge) {
        if (knowledge.currentStatus == 'approved') {
          approvedCount++;

          log('📄 [AUTO-PUBLISH] Checking approved doc: ${knowledge.currentKnowledgeId}');
          log('   📅 schedulePublishing: ${knowledge.currentSchedulePublishing}');

          // ✅ SCENARIO 1: No start date - publish immediately
          if (knowledge.currentStartDateTime == null) {
            noStartDateCount++;
            eligibleCount++;
            documentsToUpdate.add(knowledge.currentKnowledgeId);
            log('   ✅ ELIGIBLE for immediate publish! (No start date)');
          }
          // ✅ SCENARIO 2: Has start date - check if time has come
          else {
            try {
              DateTime startDate = knowledge.currentStartDateTime!.toDate();
              withStartDateCount++;

              log('   🕐 Start date: $startDate');
              log('   ⏱️  Time difference: ${now.difference(startDate).inHours} hours');

              // Remove timezone by comparing dates only
              DateTime nowDate =
                  DateTime(now.year, now.month, now.day, now.hour, now.minute);
              DateTime startDateOnly = DateTime(startDate.year, startDate.month,
                  startDate.day, startDate.hour, startDate.minute);

              log('   📆 Now: $nowDate');
              log('   📆 Start: $startDateOnly');

              // If start date has passed or is now, auto-publish
              if (nowDate.isAfter(startDateOnly) ||
                  nowDate.isAtSameMomentAs(startDateOnly)) {
                eligibleCount++;
                documentsToUpdate.add(knowledge.currentKnowledgeId);
                log('   ✅ ELIGIBLE for auto-publish! (Start date has passed)');
              } else {
                log('   ⏭️  Start date is in the future (${startDateOnly.difference(nowDate).inDays} days from now)');
              }
            } catch (e) {
              log('   ⚠️  Error parsing start date: $e');
            }
          }
        }
      }

      log('📊 [AUTO-PUBLISH] Summary:');
      log('   • Total approved documents: $approvedCount');
      log('   • With start dates: $withStartDateCount');
      log('   • Without start dates: $noStartDateCount');
      log('   • Eligible for auto-publish: $eligibleCount');
      log('   • Will update: ${documentsToUpdate.length}');

      // Update all documents that need to be published
      if (documentsToUpdate.isNotEmpty) {
        log('🚀 [AUTO-PUBLISH] Publishing ${documentsToUpdate.length} documents...');

        for (String knowledgeId in documentsToUpdate) {
          log('   📤 Publishing: $knowledgeId');
          await _firebaseServices.updateSubmissionStatus(
            knowledgeId: knowledgeId,
            newStatus: 'published',
          );
        }

        log('✅ [AUTO-PUBLISH] Successfully auto-published ${documentsToUpdate.length} documents');
      } else {
        log('ℹ️ [AUTO-PUBLISH] No documents need auto-publishing');
      }
    } catch (e) {
      log('❌ [AUTO-PUBLISH] Error in _autoPublishScheduledDocuments: $e');
    }
  }

}
