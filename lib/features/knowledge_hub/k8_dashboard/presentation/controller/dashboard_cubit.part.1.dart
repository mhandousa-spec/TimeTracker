part of './dashboard_cubit.dart';
// ignore_for_file: invalid_use_of_protected_member
/// Module: split extension 1 of DashboardCubit (kept under 800 LOC, §7).
extension DashboardCubitPart1 on DashboardCubit {

  bool _wasEverPublished(CreateKnowledgeModel doc) {
    if (doc.status.isEmpty) return false;

    // Check if 'published' exists anywhere in the status history
    for (var status in doc.status) {
      if (status.toLowerCase() == 'published') {
        return true;
      }
    }
    return false;
  }







    /// Fetch and process all dashboard data
  Future<void> fetchDashboardData() async {
    try {
      log('📊 [DashboardCubit] Starting dashboard data fetch');
      emit(DashboardLoading());

      // Fetch all required data
      _allDocuments = await _dashboardServices.fetchAllKnowledgeDocuments();
      _allUtilization = await _dashboardServices.fetchAllDocumentUtilization();

      if (_allDocuments.isEmpty) {
        emit(DashboardEmpty());
        return;
      }

      // ✅ Filter only published documents for charts
      _publishedDocuments = _allDocuments.where((doc) {
        if (doc.status.isEmpty) return false;
        return doc.status.last.toLowerCase() == 'published';
      }).toList();

      log('📊 [DashboardCubit] Total documents: ${_allDocuments.length}');
      log('📊 [DashboardCubit] Published documents: ${_publishedDocuments.length}');

      // Fetch department names
      await _fetchDepartmentNames();

      // Process all analytics
      final statusCounts = _calculateStatusCounts(); // Uses ALL documents
      final departmentCounts = _calculateDepartmentCounts(); // ✅ Uses PUBLISHED only
      final utilizationData = _calculateUtilizationData(); // ✅ Uses PUBLISHED only
      final monthlyData = _calculateMonthlyData(); // ✅ Uses PUBLISHED only
      final extensionCounts = _calculateExtensionCounts(); // ✅ Uses PUBLISHED only

      log('✅ [DashboardCubit] Dashboard data processed successfully');

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
    } catch (e, stackTrace) {
      log('❌ [DashboardCubit] Error fetching dashboard data: $e');
      log('📚 Stack trace: $stackTrace');
      emit(DashboardError(e.toString()));
    }
  }


  /// ✅ Filter dashboard data by selected department
  /// ✅ Filter dashboard data by selected department
  /// ✅ Filter dashboard data by selected department
  /// ✅ Filter dashboard data by selected department
  /// ✅ Filter dashboard data by selected departments (MULTI-SELECT)
  DashboardLoaded filterDashboardByDepartment(
      DashboardLoaded state,
      List<String>? selectedDepartmentIds, // ✅ Changed to List<String>?
      MainCoreDepartmentCubit deptController,
      ) {
    // If null, empty, or contains "all", return original state
    if (selectedDepartmentIds == null ||
        selectedDepartmentIds.isEmpty ||
        selectedDepartmentIds.contains('all')) {
      return state;
    }

    log('🔍 [DashboardCubit] Filtering by departments: $selectedDepartmentIds');

    // Get the department names for the selected IDs
    final isEnglish = Get.locale.toString().contains('en');
    Set<String> selectedDeptNames = {};
    Set<String> selectedDeptIds = {};

    for (var selectedId in selectedDepartmentIds) {
      String? selectedDeptName;
      String? matchedDeptId;

      // Search by ID first
      for (var dept in deptController.departmentModels) {
        if (dept.departmentID == selectedId) {
          selectedDeptName = isEnglish ? dept.departmentName : dept.departmentNameInArabic;
          matchedDeptId = dept.departmentID;
          break;
        }
      }

      // If not found by ID, try to find by name (for legacy data)
      if (selectedDeptName == null) {
        for (var dept in deptController.departmentModels) {
          if (dept.departmentName?.toLowerCase() == selectedId?.toLowerCase() ||
              dept.departmentNameInArabic?.toLowerCase() == selectedId?.toLowerCase()) {
            selectedDeptName = isEnglish ? dept.departmentName : dept.departmentNameInArabic;
            matchedDeptId = dept.departmentID ?? selectedId;
            break;
          }
        }
      }

      if (selectedDeptName != null && matchedDeptId != null) {
        selectedDeptNames.add(selectedDeptName);
        selectedDeptIds.add(matchedDeptId);
        log('✅ [DashboardCubit] Added filter: $selectedDeptName (ID: $matchedDeptId)');
      } else {
        log('⚠️ [DashboardCubit] Department not found: $selectedId');
      }
    }

    if (selectedDeptNames.isEmpty) {
      log('⚠️ [DashboardCubit] No valid departments found for filtering');
      return state;
    }

    log('✅ [DashboardCubit] Filtering by departments: $selectedDeptNames');

    // ✅ Filter ALL documents by selected departments
    final filteredAllDocs = _allDocuments.where((doc) {
      final docDeptId = doc.currentOwningDepartment;
      return selectedDeptIds.contains(docDeptId) ||
          selectedDeptNames.contains(_departmentNames[docDeptId]);
    }).toList();

    // Filter published documents by selected departments
    final filteredPublishedDocs = _publishedDocuments.where((doc) {
      final docDeptId = doc.currentOwningDepartment;
      return selectedDeptIds.contains(docDeptId) ||
          selectedDeptNames.contains(_departmentNames[docDeptId]);
    }).toList();

    log('📊 [DashboardCubit] Filtered all documents: ${filteredAllDocs.length}');
    log('📊 [DashboardCubit] Filtered published documents: ${filteredPublishedDocs.length}');

    // ✅ Recalculate STATUS COUNTS for filtered documents
    Map<String, int> filteredStatusCounts = {
      'published': 0,
      'approved': 0,
      'pending_approval': 0,
      'rejected': 0,
      'removed': 0,
      'archived': 0,
    };

    for (var doc in filteredAllDocs) {
      if (doc.status.isEmpty) continue;

      String currentStatus = doc.status.last.toLowerCase();

      if (currentStatus == 'published') {
        filteredStatusCounts['published'] = (filteredStatusCounts['published'] ?? 0) + 1;
      } else if (currentStatus == 'approved') {
        filteredStatusCounts['approved'] = (filteredStatusCounts['approved'] ?? 0) + 1;
      } else if (currentStatus == 'pending_approval') {
        filteredStatusCounts['pending_approval'] = (filteredStatusCounts['pending_approval'] ?? 0) + 1;
      } else if (currentStatus == 'rejected') {
        filteredStatusCounts['rejected'] = (filteredStatusCounts['rejected'] ?? 0) + 1;
      } else if (currentStatus == 'removed') {
        // ✅ Only count if document was published first
        if (_wasEverPublished(doc)) {
          filteredStatusCounts['removed'] = (filteredStatusCounts['removed'] ?? 0) + 1;
        }
      } else if (currentStatus == 'archived') {
        filteredStatusCounts['archived'] = (filteredStatusCounts['archived'] ?? 0) + 1;
      }
    }

    log('📊 [DashboardCubit] Filtered status counts: $filteredStatusCounts');

    // ✅ Recalculate department counts (show counts per selected department)
    Map<String, int> filteredDepartmentCounts = {};

    for (var doc in filteredPublishedDocs) {
      String deptId = doc.currentOwningDepartment;
      if (deptId.isEmpty) continue;

      String deptName = _departmentNames[deptId] ?? deptId;
      filteredDepartmentCounts[deptName] = (filteredDepartmentCounts[deptName] ?? 0) + 1;
    }

    // Filter utilization data
    final filteredDocIds = filteredPublishedDocs
        .map((doc) => doc.currentKnowledgeId)
        .where((id) => id.isNotEmpty)
        .toSet();

    int filteredViews = 0;
    int filteredDownloads = 0;
    Map<String, int> filteredMonthlyDownloads = {};
    Map<String, int> filteredMonthlyViews = {};

    for (var util in _allUtilization) {
      if (!filteredDocIds.contains(util.currentFileId)) continue;

      String actionType = util.currentTypeOfAction.toLowerCase();

      if (actionType == 'view') {
        filteredViews++;

        if (util.timestamp.isNotEmpty) {
          try {
            String timestampStr = _convertArabicNumerals(util.timestamp.last);
            DateTime date;
            try {
              date = DateTime.parse(timestampStr);
            } catch (e) {
              int? milliseconds = int.tryParse(timestampStr);
              if (milliseconds != null) {
                date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
              } else {
                continue;
              }
            }
            String monthKey = _getMonthAbbreviation(date.month);
            filteredMonthlyViews[monthKey] = (filteredMonthlyViews[monthKey] ?? 0) + 1;
          } catch (e) {
            log('⚠️ Error processing view timestamp: $e');
          }
        }
      } else if (actionType == 'download') {
        filteredDownloads++;

        if (util.timestamp.isNotEmpty) {
          try {
            String timestampStr = _convertArabicNumerals(util.timestamp.last);
            DateTime date;
            try {
              date = DateTime.parse(timestampStr);
            } catch (e) {
              int? milliseconds = int.tryParse(timestampStr);
              if (milliseconds != null) {
                date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
              } else {
                continue;
              }
            }
            String monthKey = _getMonthAbbreviation(date.month);
            filteredMonthlyDownloads[monthKey] = (filteredMonthlyDownloads[monthKey] ?? 0) + 1;
          } catch (e) {
            log('⚠️ Error processing download timestamp: $e');
          }
        }
      }
    }

    // Filter monthly uploaded/published/removed
    Map<String, int> filteredMonthlyUploaded = {};
    Map<String, int> filteredMonthlyPublished = {};
    Map<String, int> filteredMonthlyRemoved = {};

    for (var doc in filteredPublishedDocs) {
      if (doc.timestamps.isEmpty) continue;

      try {
        // Uploaded
        int uploadedTimestamp = doc.timestamps.first;
        DateTime uploadedDate = DateTime.fromMillisecondsSinceEpoch(uploadedTimestamp);
        String uploadedMonth = _getMonthAbbreviation(uploadedDate.month);
        filteredMonthlyUploaded[uploadedMonth] = (filteredMonthlyUploaded[uploadedMonth] ?? 0) + 1;

        // Published
        for (int i = 0; i < doc.status.length; i++) {
          if (doc.status[i].toLowerCase() == 'published' && i < doc.timestamps.length) {
            int publishedTimestamp = doc.timestamps[i];
            DateTime publishedDate = DateTime.fromMillisecondsSinceEpoch(publishedTimestamp);
            String publishedMonth = _getMonthAbbreviation(publishedDate.month);
            filteredMonthlyPublished[publishedMonth] = (filteredMonthlyPublished[publishedMonth] ?? 0) + 1;
            break;
          }
        }
      } catch (e) {
        log('⚠️ Error processing filtered document timestamps: $e');
      }
    }

    // ✅ Process removed documents from filtered ALL documents
    int filteredRemovedCounted = 0;

    for (var doc in filteredAllDocs) {
      if (doc.status.isEmpty || doc.timestamps.isEmpty) continue;

      try {
        String currentStatus = doc.status.last.toLowerCase();

        if (currentStatus == 'removed') {
          if (!_wasEverPublished(doc)) continue;

          for (int i = 0; i < doc.status.length; i++) {
            if (doc.status[i].toLowerCase() == 'removed' && i < doc.timestamps.length) {
              int removedTimestamp = doc.timestamps[i];
              DateTime removedDate = DateTime.fromMillisecondsSinceEpoch(removedTimestamp);
              String removedMonth = _getMonthAbbreviation(removedDate.month);
              filteredMonthlyRemoved[removedMonth] = (filteredMonthlyRemoved[removedMonth] ?? 0) + 1;
              filteredRemovedCounted++;
              break;
            }
          }
        }
      } catch (e) {
        log('⚠️ Error processing removed document timestamps: $e');
      }
    }

    // ✅ Filter extensions - ONLY currently published documents
    Map<String, int> filteredExtensions = {};

    for (var doc in filteredPublishedDocs) {
      if (doc.status.isEmpty) continue;

      String currentStatus = doc.status.last.toLowerCase();
      if (currentStatus != 'published') continue;

      String extension = doc.currentDocumentExtension.toLowerCase();
      if (extension.isEmpty) continue;

      if (extension.startsWith('.')) {
        extension = extension.substring(1);
      }

      filteredExtensions[extension] = (filteredExtensions[extension] ?? 0) + 1;
    }

    log('📊 [DashboardCubit] Filtered stats - Views: $filteredViews, Downloads: $filteredDownloads');

    return DashboardLoaded(
      statusCounts: filteredStatusCounts,
      departmentCounts: filteredDepartmentCounts,
      totalViews: filteredViews,
      totalDownloads: filteredDownloads,
      monthlyUploaded: filteredMonthlyUploaded,
      monthlyPublished: filteredMonthlyPublished,
      monthlyRemoved: filteredMonthlyRemoved,
      monthlyDownloads: filteredMonthlyDownloads,
      monthlyViews: filteredMonthlyViews,
      extensionCounts: filteredExtensions,
      departmentNames: state.departmentNames,
      totalRemovedCount: filteredRemovedCounted,
      totalPublishedCount: filteredPublishedDocs.length,
    );
  }


  /// Convert Arabic/Hindi numerals to Western numerals
  String _convertArabicNumerals(String input) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const westernNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < arabicNumerals.length; i++) {
      result = result.replaceAll(arabicNumerals[i], westernNumerals[i]);
    }
    return result;
  }


  /// Fetch department names for all departments in documents
  Future<void> _fetchDepartmentNames() async {
    try {
      // Get or initialize the department controller
      MainCoreDepartmentCubit deptController;
      try {
        deptController = Get.find<MainCoreDepartmentCubit>();
      } catch (e) {
        log('⚠️ [DashboardCubit] Department controller not found, creating new one');
        deptController = Get.put(MainCoreDepartmentCubit());
      }

      // ✅ CRITICAL: ALWAYS reload departments to ensure fresh data
      log('⏳ [DashboardCubit] Loading departments...');
      await deptController.getAllDepartments();
      log('✅ [DashboardCubit] Departments loaded: ${deptController.departmentModels.length}');

      // Check current locale
      final isEnglish = Get.locale.toString().contains('en');
      log('🌍 [DashboardCubit] Current locale: ${Get.locale}, isEnglish: $isEnglish');

      // ✅ Extract unique department IDs from PUBLISHED documents only
      final departmentIds = _publishedDocuments
          .map((doc) => doc.currentOwningDepartment)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      log('📋 [DashboardCubit] Department IDs from published documents: $departmentIds');

      if (departmentIds.isEmpty) {
        log('⚠️ [DashboardCubit] No department IDs found in published documents');
        return;
      }

      _departmentNames = {};

      // Get department names based on locale
      for (String deptId in departmentIds) {
        // ✅ Search by ID first, then by name (for legacy data)
        DepartmentModelPro? dept;

        // Try to find by ID
        for (var d in deptController.departmentModels) {
          if (d.departmentID == deptId) {
            dept = d;
            log('✅ [DashboardCubit] Found department by ID: $deptId');
            break;
          }
        }

        // ✅ If not found by ID, try to find by English or Arabic name
        if (dept == null) {
          log('⚠️ [DashboardCubit] Department ID "$deptId" not found, searching by name...');
          for (var d in deptController.departmentModels) {
            if (d.departmentName?.toLowerCase() == deptId.toLowerCase() ||
                d.departmentNameInArabic?.toLowerCase() == deptId.toLowerCase()) {
              dept = d;
              log('✅ [DashboardCubit] Found department by name: $deptId -> ID: ${d.departmentID}');
              break;
            }
          }
        }

        String deptName;

        if (dept != null) {
          deptName = isEnglish
              ? (dept.departmentName ?? deptId)
              : (dept.departmentNameInArabic ?? deptId);
          log('✅ [DashboardCubit] Using name for $deptId: $deptName (${isEnglish ? "EN" : "AR"})');
        } else {
          log('❌ [DashboardCubit] Department $deptId not found anywhere, using as-is');
          deptName = deptId;
        }

        _departmentNames[deptId] = deptName;
      }

      log('✅ [DashboardCubit] Fetched ${_departmentNames.length} department names in ${isEnglish ? "English" : "Arabic"}');
      log('📋 [DashboardCubit] Final department names: $_departmentNames');
    } catch (e, stackTrace) {
      log('❌ [DashboardCubit] Error fetching department names: $e');
      log('📚 Stack trace: $stackTrace');
    }
  }


  /// Calculate status counts (Approved, Pending, Rejected, Removed)
  /// ✅ Uses ALL documents to show status cards
  /// Calculate status counts (Approved, Pending, Rejected, Removed)
  /// ✅ Uses ALL documents to show status cards
  Map<String, int> _calculateStatusCounts() {
    Map<String, int> counts = {
      'published': 0,
      'approved': 0,
      'pending_approval': 0,
      'rejected': 0,
      'removed': 0,
      'archived': 0,
    };

    int skippedDocs = 0;
    int removedSkipped = 0; // ✅ Track skipped removed docs

    for (var doc in _allDocuments) {
      // Skip if no status history
      if (doc.status.isEmpty) {
        log('⚠️ Document skipped: empty status array');
        skippedDocs++;
        continue;
      }

      // Get the LAST status (current status)
      String currentStatus = doc.status.last.toLowerCase();

      // Count based on the exact last status
      if (currentStatus == 'published') {
        counts['published'] = (counts['published'] ?? 0) + 1;
      } else if (currentStatus == 'approved') {
        counts['approved'] = (counts['approved'] ?? 0) + 1;
      } else if (currentStatus == 'pending_approval') {
        counts['pending_approval'] = (counts['pending_approval'] ?? 0) + 1;
      } else if (currentStatus == 'rejected') {
        counts['rejected'] = (counts['rejected'] ?? 0) + 1;
      } else if (currentStatus == 'removed') {
        // ✅ CRITICAL: Only count if document was PUBLISHED first
        if (_wasEverPublished(doc)) {
          counts['removed'] = (counts['removed'] ?? 0) + 1;
          log('✅ Counted removed document (was published): ${doc.currentKnowledgeId}');
        } else {
          removedSkipped++;
          log('⚠️ Skipping removed document (never published): ${doc.currentKnowledgeId}');
        }
      } else if (currentStatus == 'archived') {
        counts['archived'] = (counts['archived'] ?? 0) + 1;
      } else {
        log('⚠️ Unknown status found: "$currentStatus"');
        skippedDocs++;
      }
    }

    if (skippedDocs > 0) {
      log('⚠️ [DashboardCubit] Skipped $skippedDocs documents with empty or unknown status');
    }

    if (removedSkipped > 0) {
      log('⚠️ [DashboardCubit] Skipped $removedSkipped removed documents that were never published');
    }

    log('📊 [DashboardCubit] Status counts: $counts');
    return counts;
  }

}
