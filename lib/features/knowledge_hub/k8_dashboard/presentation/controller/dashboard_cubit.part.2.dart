part of './dashboard_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 2 of DashboardCubit (kept under 800 LOC, §7).
extension DashboardCubitPart2 on DashboardCubit {

  /// Calculate department distribution
  /// ✅ Uses PUBLISHED documents only
  Map<String, int> _calculateDepartmentCounts() {
    Map<String, int> counts = {};

    for (var doc in _publishedDocuments) {
      String deptId = doc.currentOwningDepartment;
      if (deptId.isEmpty) continue;

      // Use department name instead of ID
      String deptName = _departmentNames[deptId] ?? deptId;
      counts[deptName] = (counts[deptName] ?? 0) + 1;
    }

    log('📊 [DashboardCubit] Department counts (published only): $counts');
    return counts;
  }


  /// Calculate total views and downloads
  /// ✅ Uses PUBLISHED documents only
  Map<String, int> _calculateUtilizationData() {
    int totalViews = 0;
    int totalDownloads = 0;

    // ✅ Create a set of published document knowledge IDs for quick lookup
    final publishedDocIds = _publishedDocuments
        .map((doc) => doc.currentKnowledgeId)
        .where((id) => id.isNotEmpty)
        .toSet();

    log('📊 [DashboardCubit] Published document IDs: ${publishedDocIds.length}');

    for (var util in _allUtilization) {
      // ✅ Only count utilization for published documents (using currentFileId)
      if (!publishedDocIds.contains(util.currentFileId)) {
        continue;
      }

      String actionType = util.currentTypeOfAction.toLowerCase();

      if (actionType == 'view') {
        totalViews++;
      } else if (actionType == 'download') {
        totalDownloads++;
      }
    }

    log('📊 [DashboardCubit] Views (published only): $totalViews, Downloads (published only): $totalDownloads');
    return {'views': totalViews, 'downloads': totalDownloads};
  }


  /// Calculate monthly data (uploaded, published, removed, downloads, views)
  /// ✅ Uses PUBLISHED documents only for uploaded/published
  Map<String, Map<String, int>> _calculateMonthlyData() {
    log('📊 [DashboardCubit] Calculating monthly data...');
    log('📊 Total documents: ${_allDocuments.length}');
    log('📊 Published documents: ${_publishedDocuments.length}');
    log('📊 Total utilization records: ${_allUtilization.length}');

    Map<String, int> monthlyUploaded = {};
    Map<String, int> monthlyPublished = {};
    Map<String, int> monthlyRemoved = {};
    Map<String, int> monthlyDownloads = {};
    Map<String, int> monthlyViews = {};

    // ✅ Process PUBLISHED documents for uploaded/published
    for (var doc in _publishedDocuments) {
      if (doc.timestamps.isEmpty) continue;

      try {
        // Uploaded = first timestamp (creation)
        int uploadedTimestamp = doc.timestamps.first;
        DateTime uploadedDate = DateTime.fromMillisecondsSinceEpoch(uploadedTimestamp);
        String uploadedMonth = _getMonthAbbreviation(uploadedDate.month);
        monthlyUploaded[uploadedMonth] = (monthlyUploaded[uploadedMonth] ?? 0) + 1;

        // Published = find when it was published
        for (int i = 0; i < doc.status.length; i++) {
          if (doc.status[i].toLowerCase() == 'published' && i < doc.timestamps.length) {
            int publishedTimestamp = doc.timestamps[i];
            DateTime publishedDate = DateTime.fromMillisecondsSinceEpoch(publishedTimestamp);
            String publishedMonth = _getMonthAbbreviation(publishedDate.month);
            monthlyPublished[publishedMonth] = (monthlyPublished[publishedMonth] ?? 0) + 1;
            break; // Count only first publish
          }
        }
      } catch (e) {
        log('⚠️ Error processing document timestamps: $e');
      }
    }

    // ✅ Process ALL documents for removed
    // ✅ CRITICAL: Only count if document was PUBLISHED first, then removed
    int totalRemovedChecked = 0;
    int totalRemovedCounted = 0;
    int totalRemovedSkipped = 0;

    for (var doc in _allDocuments) {
      if (doc.status.isEmpty || doc.timestamps.isEmpty) continue;

      try {
        String currentStatus = doc.status.last.toLowerCase();

        // Check if current status is 'removed'
        if (currentStatus == 'removed') {
          totalRemovedChecked++;

          // ✅ CRITICAL CHECK: Was this document ever published?
          if (!_wasEverPublished(doc)) {
            log('⚠️ Skipping removed document that was NEVER published: ${doc.currentKnowledgeId}');
            totalRemovedSkipped++;
            continue;
          }

          // Find when it was removed (first occurrence of 'removed' status)
          for (int i = 0; i < doc.status.length; i++) {
            if (doc.status[i].toLowerCase() == 'removed' && i < doc.timestamps.length) {
              int removedTimestamp = doc.timestamps[i];
              DateTime removedDate = DateTime.fromMillisecondsSinceEpoch(removedTimestamp);
              String removedMonth = _getMonthAbbreviation(removedDate.month);
              monthlyRemoved[removedMonth] = (monthlyRemoved[removedMonth] ?? 0) + 1;
              totalRemovedCounted++;
              log('✅ Counted removed document (was published): ${doc.currentKnowledgeId}');
              break; // Count only first removal
            }
          }
        }
      } catch (e) {
        log('⚠️ Error processing removed document timestamps: $e');
      }
    }

    log('📊 [DashboardCubit] Removed documents checked: $totalRemovedChecked');
    log('📊 [DashboardCubit] Removed documents counted (were published): $totalRemovedCounted');
    log('📊 [DashboardCubit] Removed documents skipped (never published): $totalRemovedSkipped');

    // ✅ Create a set of published document knowledge IDs for filtering utilization
    final publishedDocIds = _publishedDocuments
        .map((doc) => doc.currentKnowledgeId)
        .where((id) => id.isNotEmpty)
        .toSet();

    // Process utilization for downloads/views (PUBLISHED documents only)
    int processedCount = 0;
    int errorCount = 0;
    int filteredCount = 0;

    for (var util in _allUtilization) {
      // ✅ Only count utilization for published documents (using currentFileId)
      if (!publishedDocIds.contains(util.currentFileId)) {
        filteredCount++;
        continue;
      }

      if (util.timestamp.isEmpty) {
        log('⚠️ Utilization has empty timestamp array');
        continue;
      }

      try {
        String timestampStr = util.timestamp.last;
        timestampStr = _convertArabicNumerals(timestampStr);

        DateTime date;

        try {
          date = DateTime.parse(timestampStr);
        } catch (e) {
          int? milliseconds = int.tryParse(timestampStr);
          if (milliseconds != null) {
            date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
          } else {
            log('❌ Could not parse timestamp: $timestampStr (original: ${util.timestamp.last})');
            errorCount++;
            continue;
          }
        }

        String monthKey = _getMonthAbbreviation(date.month);
        String actionType = util.currentTypeOfAction.toLowerCase();

        if (actionType == 'download') {
          monthlyDownloads[monthKey] = (monthlyDownloads[monthKey] ?? 0) + 1;
          processedCount++;
        } else if (actionType == 'view') {
          monthlyViews[monthKey] = (monthlyViews[monthKey] ?? 0) + 1;
          processedCount++;
        }
      } catch (e) {
        log('⚠️ Error processing utilization timestamp: $e');
        errorCount++;
      }
    }

    log('✅ Processed $processedCount utilization records (published only), filtered $filteredCount, $errorCount errors');
    log('📊 [DashboardCubit] Monthly uploaded: $monthlyUploaded');
    log('📊 [DashboardCubit] Monthly published: $monthlyPublished');
    log('📊 [DashboardCubit] Monthly removed: $monthlyRemoved');
    log('📊 [DashboardCubit] Monthly downloads: $monthlyDownloads');
    log('📊 [DashboardCubit] Monthly views: $monthlyViews');

    return {
      'uploaded': monthlyUploaded,
      'published': monthlyPublished,
      'removed': monthlyRemoved,
      'downloads': monthlyDownloads,
      'views': monthlyViews,
    };
  }


  /// Calculate file extension distribution
  /// ✅ Uses PUBLISHED documents only
  /// Calculate file extension distribution
  /// ✅ Uses ONLY PUBLISHED documents (current status = "published")
  Map<String, int> _calculateExtensionCounts() {
    Map<String, int> counts = {};

    // ✅ Only count documents where CURRENT status = "published"
    for (var doc in _publishedDocuments) {
      // ✅ Double-check: Ensure current status is "published"
      if (doc.status.isEmpty) continue;

      String currentStatus = doc.status.last.toLowerCase();
      if (currentStatus != 'published') {
        log('⚠️ [Extension] Skipping document not currently published: ${doc.currentKnowledgeId}, status: $currentStatus');
        continue;
      }

      String extension = doc.currentDocumentExtension.toLowerCase();
      if (extension.isEmpty) continue;

      // Remove dot if present
      if (extension.startsWith('.')) {
        extension = extension.substring(1);
      }

      counts[extension] = (counts[extension] ?? 0) + 1;
    }

    log('📊 [DashboardCubit] Extension counts (currently published only): $counts');
    return counts;
  }


  /// Get month abbreviation from month number
  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }


  /// Get data for last N months
  Map<String, int> getLastNMonths(Map<String, int> monthlyData, int n) {
    Map<String, int> result = {};
    DateTime now = DateTime.now();

    for (int i = n - 1; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthKey = _getMonthAbbreviation(month.month);
      result[monthKey] = monthlyData[monthKey] ?? 0;
    }

    return result;
  }


  /// Listen to real-time updates
  void listenToDashboardUpdates() {
    log('👂 [DashboardCubit] Setting up real-time listeners');

    // Listen to knowledge documents
    _dashboardServices.streamKnowledgeDocuments().listen(
          (documents) async {
        log('🔄 [DashboardCubit] Real-time update: ${documents.length} documents');
        _allDocuments = documents;

        if (_allDocuments.isEmpty) {
          emit(DashboardEmpty());
          return;
        }

        // ✅ Filter published documents
        _publishedDocuments = _allDocuments.where((doc) {
          if (doc.status.isEmpty) return false;
          return doc.status.last.toLowerCase() == 'published';
        }).toList();

        log('📊 [DashboardCubit] Published documents: ${_publishedDocuments.length}');

        // Refresh department names if needed
        await _fetchDepartmentNames();

        // Recalculate and emit
        final statusCounts = _calculateStatusCounts();
        final departmentCounts = _calculateDepartmentCounts();
        final utilizationData = _calculateUtilizationData();
        final monthlyData = _calculateMonthlyData();
        final extensionCounts = _calculateExtensionCounts();

        emit(DashboardLoaded(
          statusCounts: statusCounts,
          departmentCounts: departmentCounts,
          totalViews: utilizationData['views']!,
          totalDownloads: utilizationData['downloads']!,
          monthlyUploaded: monthlyData['uploaded']!,
          monthlyPublished: monthlyData['published']!,
          monthlyRemoved: monthlyData['removed']!,
          monthlyDownloads: monthlyData['downloads']!,
          monthlyViews: monthlyData['views']!,
          extensionCounts: extensionCounts,
          departmentNames: _departmentNames,
          totalRemovedCount: statusCounts['removed'] ?? 0,
          totalPublishedCount: statusCounts['published'] ?? 0,
        ));
      },
      onError: (error) {
        log('❌ [DashboardCubit] Error in real-time updates: $error');
        emit(DashboardError(error.toString()));
      },
    );

    // Listen to utilization updates
    _dashboardServices.streamDocumentUtilization().listen(
          (utilization) {
        log('🔄 [DashboardCubit] Utilization update: ${utilization.length} records');
        _allUtilization = utilization;

        // Recalculate utilization-dependent data
        if (_allDocuments.isNotEmpty) {
          final utilizationData = _calculateUtilizationData();
          final monthlyData = _calculateMonthlyData();

          // Re-emit with updated data
          if (state is DashboardLoaded) {
            final currentState = state as DashboardLoaded;
            emit(DashboardLoaded(
              statusCounts: currentState.statusCounts,
              departmentCounts: currentState.departmentCounts,
              totalViews: utilizationData['views']!,
              totalDownloads: utilizationData['downloads']!,
              monthlyUploaded: monthlyData['uploaded']!,
              monthlyPublished: monthlyData['published']!,
              monthlyRemoved: monthlyData['removed']!,
              monthlyDownloads: monthlyData['downloads']!,
              monthlyViews: monthlyData['views']!,
              extensionCounts: currentState.extensionCounts,
              departmentNames: currentState.departmentNames,
              totalRemovedCount: currentState.statusCounts['removed'] ?? 0,
              totalPublishedCount: currentState.statusCounts['published'] ?? 0,
            ));
          }
        }
      },
    );
  }




  /// Add this method to your existing DashboardCubit class

  /// ✅ NEW: Public getter to access all documents for filtering
  List<CreateKnowledgeModel> getAllDocuments() {
    return _allDocuments;
  }


  /// ✅ NEW: Public getter to access published documents only
  List<CreateKnowledgeModel> getPublishedDocuments() {
    return _publishedDocuments;
  }


  /// ✅ NEW: Filter documents by user email
  List<CreateKnowledgeModel> getDocumentsByUser(String userEmail) {
    return _allDocuments.where((doc) {
      return doc.currentCreatedByEmail.toLowerCase().trim() == userEmail.toLowerCase().trim();
    }).toList();
  }


  /// ✅ NEW: Get user-specific status counts
  Map<String, int> getUserStatusCounts(String userEmail) {
    Map<String, int> userCounts = {
      'published': 0,
      'approved': 0,
      'pending_approval': 0,
      'rejected': 0,
      'removed': 0,
      'archived': 0,
    };

    final userDocuments = getDocumentsByUser(userEmail);

    for (var doc in userDocuments) {
      // Skip if no status history
      if (doc.status.isEmpty) continue;

      // Get the LAST status (current status)
      String currentStatus = doc.status.last.toLowerCase();

      // Count based on the exact last status
      if (currentStatus == 'published') {
        userCounts['published'] = (userCounts['published'] ?? 0) + 1;
      } else if (currentStatus == 'approved') {
        userCounts['approved'] = (userCounts['approved'] ?? 0) + 1;
      } else if (currentStatus == 'pending_approval') {
        userCounts['pending_approval'] = (userCounts['pending_approval'] ?? 0) + 1;
      } else if (currentStatus == 'rejected') {
        userCounts['rejected'] = (userCounts['rejected'] ?? 0) + 1;
      } else if (currentStatus == 'removed') {
        // Only count if document was published first
        if (_wasEverPublished(doc)) {
          userCounts['removed'] = (userCounts['removed'] ?? 0) + 1;
        }
      } else if (currentStatus == 'archived') {
        userCounts['archived'] = (userCounts['archived'] ?? 0) + 1;
      }
    }

    log('📊 [DashboardCubit] User status counts for $userEmail: $userCounts');
    return userCounts;
  }


  /// Clear dashboard data
  void clearDashboard() {
    log('🧹 [DashboardCubit] Clearing dashboard data');
    _allDocuments = [];
    _publishedDocuments = [];
    _allUtilization = [];
    _departmentNames = {};
    emit(DashboardInitial());
  }

}
