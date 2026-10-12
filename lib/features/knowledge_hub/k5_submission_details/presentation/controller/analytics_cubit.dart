/// Module: knowledge_hub / presentation / cubit / analytics_cubit/analytics_cubit.dart
/// ************************* FILE INFO *************************** ///
/// File Name: analytics_cubit.dart
/// Purpose: Manages analytics data and calculations for published documents
/// Author: Youssef Khaled
/// Created At: 20/10/2025
/// Updated: Fixed user data caching with multiple fallback strategies + Arabic/English department name localization + Arabic numeral fix

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/services/knowledge_hub_firebase_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

import '../../../../../core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import '../../../main_controller/data/services/create_comment_firebase_service.dart';
import '../../../main_controller/data/models/document_utilization_model.dart';
import '../../../main_controller/data/models/employee_data.dart';
import './analytics_states.dart';

class AnalyticsCubit extends Cubit<AnalyticsStates> {
  final CommentsFirebaseServices _commentsServices;

  List<DocumentUtilizationModel> _allActions = [];
  List<EmployeeData> _employees = [];

  // ✅ Cache for user data
  Map<String, EmployeeData> _usersCache = {};

  // ✅ Separate caches for Arabic and English department names
  Map<String, String> _departmentsEnglishCache = {};
  Map<String, String> _departmentsArabicCache = {};

  Map<String, int> _departmentCounts = {};
  Map<String, int> _monthlyDownloads = {};
  Map<String, int> _monthlyViews = {};
  int _totalDownloads = 0;
  int _totalViews = 0;

  List<EmployeeData> get employeesList => _employees;

  AnalyticsCubit(this._commentsServices) : super(AnalyticsInitial());
  List<DocumentUtilizationModel> get allActions => _allActions;

  // Getters
  Map<String, EmployeeData> get usersCache => _usersCache;
  Map<String, String> get departmentsEnglishCache => _departmentsEnglishCache;
  Map<String, String> get departmentsArabicCache => _departmentsArabicCache;
  Map<String, int> get departmentCounts => _departmentCounts;
  Map<String, int> get monthlyDownloads => _monthlyDownloads;
  Map<String, int> get monthlyViews => _monthlyViews;
  int get totalDownloads => _totalDownloads;
  int get totalViews => _totalViews;
  int get totalActions => _totalDownloads + _totalViews;

  /// ✅ NEW: Converts Arabic numerals to English numerals
  String _convertArabicNumeralsToEnglish(String input) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < arabicNumerals.length; i++) {
      result = result.replaceAll(arabicNumerals[i], englishNumerals[i]);
    }
    return result;
  }

  /// Fetch and process analytics data for a specific knowledge document
  Future<void> fetchAnalytics(String knowledgeId) async {
    try {
      log('🔍 [AnalyticsCubit] Starting fetchAnalytics for knowledgeId: $knowledgeId');
      emit(FetchingAnalyticsLoadingState());

      // Fetch all file actions for this document
      log('📡 [AnalyticsCubit] Calling fetchFileActionsByKnowledgeId...');
      _allActions = await _commentsServices.fetchFileActionsByKnowledgeId(knowledgeId);

      log('📊 [AnalyticsCubit] Fetched ${_allActions.length} actions');

      if (_allActions.isEmpty) {
        log('⚠️ [AnalyticsCubit] No actions found - emitting empty state');
        emit(FetchingAnalyticsEmptyState());
        return;
      }

      // ✅ Fetch user data for all actions
      log('👥 [AnalyticsCubit] Fetching user data for actions...');
      await _fetchUsersForActions(_allActions);
      log('✅ [AnalyticsCubit] User data fetching complete. Cache size: ${_usersCache.length}');

      // ✅ Fetch department names (both Arabic and English)
      log('🏢 [AnalyticsCubit] Fetching department names...');
      await _fetchDepartmentsForUsers();
      log('✅ [AnalyticsCubit] Department data fetching complete. EN: ${_departmentsEnglishCache.length}, AR: ${_departmentsArabicCache.length}');

      // Process the data AFTER user data and department data are loaded
      log('⚙️ [AnalyticsCubit] Processing department counts...');
      _processDepartmentCounts();

      log('⚙️ [AnalyticsCubit] Processing monthly data...');
      _processMonthlyData();

      log('⚙️ [AnalyticsCubit] Calculating totals...');
      _calculateTotals();

      log('✅ [AnalyticsCubit] Emitting success state');
      emit(
        FetchingAnalyticsSuccessState(
          departmentCounts: _departmentCounts,
          monthlyDownloads: _monthlyDownloads,
          monthlyViews: _monthlyViews,
          totalDownloads: _totalDownloads,
          totalViews: _totalViews,
        ),
      );

      log('✅ [AnalyticsCubit] Analytics processed successfully: ${_allActions.length} actions, ${_departmentCounts.length} departments');
    } catch (e, stackTrace) {
      log('❌ [AnalyticsCubit] Error in fetchAnalytics: $e');
      log('📚 [AnalyticsCubit] Stack trace: $stackTrace');
      emit(FetchingAnalyticsErrorState(e.toString()));
    }
  }


  /// ✅ FIXED: Delete Knowledge Document Method
  /// Add this to your AnalyticsCubit class

  /// ✅ FIXED: Delete Knowledge Document Method - Using ApiConstants
  /// ✅ FIXED: Delete Knowledge Document Method - Using correct Firestore path
  /// ✅ FINAL FIX: Delete Knowledge Document - Correct Firestore Path
  Future<void> deleteKnowledgeDocument({required String knowledgeId}) async {
    try {
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AnalyticsCubit');
      log('🗑️ STEP 1: Starting deleteKnowledgeDocument', name: 'AnalyticsCubit');
      log('📄 Knowledge ID: $knowledgeId', name: 'AnalyticsCubit');

      // ✅ Delegate the delete to the service (no Firestore in the cubit, N02)
      await KnowledgeHubFirebaseServices().deleteKnowledgeById(knowledgeId);

      log('✅ Knowledge document deleted', name: 'AnalyticsCubit');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AnalyticsCubit');

    } catch (e, stackTrace) {
      log('❌ ERROR in deleteKnowledgeDocument: $e', name: 'AnalyticsCubit');
      log('📚 Stack trace: $stackTrace', name: 'AnalyticsCubit');
      log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AnalyticsCubit');
      rethrow;
    }
  }


  Future<void> _fetchUsersForActions(
      List<DocumentUtilizationModel> actions,
      ) async {
    try {
      // Get the employee controller
      if (!Get.isRegistered<MainCoreEmployeeController>()) {
        log('❌ [AnalyticsCubit] MainCoreEmployeeController not registered!');
        return;
      }

      final controller = Get.find<MainCoreEmployeeController>();

      // Extract unique user IDs (which are now emails)
      final userEmails = actions
          .map((action) => action.currentUserId)
          .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
          .toSet()
          .toList();

      if (userEmails.isEmpty) {
        log('ℹ️ [AnalyticsCubit] No new users to fetch (all cached)');
        return;
      }

      log('👥 [AnalyticsCubit] Fetching data for ${userEmails.length} users');
      log('📋 [AnalyticsCubit] User emails to find: $userEmails');

      // ✅ DEBUG: Print all available email keys in the map
      log('🔍 [AnalyticsCubit] Total employees in controller map: ${controller.mapOfEmployeesWithEmailKey.length}');
      if (controller.mapOfEmployeesWithEmailKey.isNotEmpty) {
        log('🔍 [AnalyticsCubit] Sample email keys from map (first 10):');
        controller.mapOfEmployeesWithEmailKey.keys.take(10).forEach((key) {
          log('     - "$key"');
        });
      } else {
        log('⚠️ [AnalyticsCubit] mapOfEmployeesWithEmailKey is EMPTY!');
        log('⚠️ [AnalyticsCubit] allEmployeesEntities length: ${controller.allEmployeesEntities?.length ?? 0}');
      }

      int successCount = 0;
      int failCount = 0;

      // ✅ Process each email with multiple fallback strategies
      for (String email in userEmails) {
        log('🔎 [AnalyticsCubit] Looking for email: "$email"');

        EmployeeEntityPro? employee;
        String foundVia = '';

        // ✅ STRATEGY 1: Try exact match first
        employee = controller.mapOfEmployeesWithEmailKey[email];
        if (employee != null) {
          foundVia = 'exact match';
        }

        // ✅ STRATEGY 2: Try case-insensitive search in map
        if (employee == null) {
          final emailLower = email.toLowerCase().trim();

          try {
            final matchingEntry = controller.mapOfEmployeesWithEmailKey.entries.firstOrNull!;

            if (matchingEntry != null) {
              employee = matchingEntry.value;
              foundVia = 'case-insensitive match (key: "${matchingEntry.key}")';
            }
          } catch (e) {
            log('⚠️ [AnalyticsCubit] Case-insensitive search error: $e');
          }
        }

        // ✅ STRATEGY 3: Search in the allEmployeesEntities list
        if (employee == null && controller.allEmployeesEntities != null && controller.allEmployeesEntities!.isNotEmpty) {
          final emailLower = email.toLowerCase().trim();

          try {
            employee = controller.allEmployeesEntities!.firstWhereOrNull(
                  (emp) => emp.email?.toLowerCase().trim() == emailLower,
            );

            if (employee != null) {
              foundVia = 'allEmployeesEntities list';
            }
          } catch (e) {
            log('⚠️ [AnalyticsCubit] List search error: $e');
          }
        }

        // ✅ STRATEGY 4: Fallback - fetch from Firebase directly
        if (employee == null) {
          log('⚠️ [AnalyticsCubit] All local searches failed, trying Firebase...');
          try {
            final userData = await _commentsServices.fetchUserDataByUserId(email);
            if (userData != null) {
              _usersCache[email] = userData;
              successCount++;
              log('✅ [AnalyticsCubit] Fetched from Firebase: $email - ${userData.currentemployeeName}');

              // ✅ Also fetch department names if not cached
              final deptId = userData.currentemployeeDepartment;
              if (deptId.isNotEmpty && !_departmentsEnglishCache.containsKey(deptId)) {
                await _fetchDepartmentNamesById(deptId);
              }

              continue; // Skip to next email
            }
          } catch (e) {
            log('❌ [AnalyticsCubit] Firebase fetch also failed: $e');
          }
        }

        // ✅ If we found the employee in local data, cache it
        if (employee != null) {
          _usersCache[email] = EmployeeData.createNew(
            employeeId: employee.id ?? '',
            employeeName: '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
            employeeNameArabic: '${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}'.trim(),
            employeeEmail: employee.email ?? '',
            employeePhoto: employee.photo,
            employeeDepartment: employee.departmentId ?? '',
            employeeRole: employee.title ?? '',
          //  employeeRoleAr: employee.titleInArabic ?? employee.title ?? '',
            employeeJobTitle: employee.title ?? '',
            employeePhone: employee.mobilePhone?.phone,
            employeeSupervisor: employee.supervisor ?? '',
          );

          successCount++;
          log('✅ [AnalyticsCubit] Cached employee via $foundVia: $email - ${_usersCache[email]!.currentemployeeName}');
        } else {
          failCount++;
          log('❌ [AnalyticsCubit] COMPLETELY FAILED to find employee for: "$email"');
          log('   This email does not exist in:');
          log('   1. mapOfEmployeesWithEmailKey (exact or case-insensitive)');
          log('   2. allEmployeesEntities list');
          log('   3. Firebase collection');
        }
      }

      log('═══════════════════════════════════════');
      log('✅ [AnalyticsCubit] User data fetching complete.');
      log('   Successfully cached: $successCount out of ${userEmails.length} users');
      log('   Failed to find: $failCount users');
      log('   Total cache size: ${_usersCache.length}');
      log('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      log('❌ [AnalyticsCubit] Error fetching users for actions: $e');
      log('📚 [AnalyticsCubit] Stack trace: $stackTrace');
    }
  }

  /// ✅ Helper: Fetch department names (both Arabic and English) for all cached users
  Future<void> _fetchDepartmentsForUsers() async {
    try {
      // Extract unique department IDs from cached users
      final departmentIds = _usersCache.values
          .map((user) => user.currentemployeeDepartment)
          .where((id) => id.isNotEmpty && !_departmentsEnglishCache.containsKey(id))
          .toSet()
          .toList();

      if (departmentIds.isEmpty) {
        log('ℹ️ [AnalyticsCubit] No new departments to fetch');
        return;
      }

      log('🏢 [AnalyticsCubit] Fetching names for ${departmentIds.length} departments');

      // ✅ Get department controller
      if (!Get.isRegistered<MainCoreDepartmentCubit>()) {
        log('❌ [AnalyticsCubit] MainCoreDepartmentCubit not registered!');
        return;
      }

      final deptController = Get.find<MainCoreDepartmentCubit>();

      // ✅ Fetch both English and Arabic names for each department
      for (String deptId in departmentIds) {
        await _fetchDepartmentNamesById(deptId);
      }

      log('✅ [AnalyticsCubit] Cached ${_departmentsEnglishCache.length} English department names');
      log('✅ [AnalyticsCubit] Cached ${_departmentsArabicCache.length} Arabic department names');
    } catch (e, stackTrace) {
      log('❌ [AnalyticsCubit] Error fetching departments: $e');
      log('📚 [AnalyticsCubit] Stack trace: $stackTrace');
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
      final userData = await _commentsServices.fetchUserDataByUserId(userId);
      if (userData != null) {
        _usersCache[userId] = userData;

        // ✅ Also fetch department names if not cached
        final deptId = userData.currentemployeeDepartment;
        if (deptId.isNotEmpty && !_departmentsEnglishCache.containsKey(deptId)) {
          await _fetchDepartmentNamesById(deptId);
        }
      }
      return userData;
    } catch (e) {
      log('❌ [AnalyticsCubit] Error fetching user data for $userId: $e');
      return null;
    }
  }

  /// ✅ Get department name for a specific department ID with locale support
  String getDepartmentName(String departmentId, {bool isEnglish = true}) {
    if (departmentId.isEmpty) {
      return isEnglish ? 'Unknown Department' : 'قسم غير معروف';
    }

    if (isEnglish) {
      return _departmentsEnglishCache[departmentId] ?? 'Unknown Department';
    } else {
      return _departmentsArabicCache[departmentId] ?? 'قسم غير معروف';
    }
  }

  /// ✅ Helper to fetch both English and Arabic names for a single department
  Future<void> _fetchDepartmentNamesById(String departmentId) async {
    try {
      if (!Get.isRegistered<MainCoreDepartmentCubit>()) {
        log('❌ [AnalyticsCubit] MainCoreDepartmentCubit not registered!');
        return;
      }

      final deptController = Get.find<MainCoreDepartmentCubit>();

      final englishName = deptController.getEnglishDepartmentNameFromDepartmentId(
        departmentId: departmentId,
      );

      final arabicName = deptController.getArabicDepartmentNameFromDepartmentId(
        departmentId: departmentId,
      );

      if (englishName != null) {
        _departmentsEnglishCache[departmentId] = englishName;
        log('✅ [AnalyticsCubit] Cached English dept: $departmentId → $englishName');
      }

      if (arabicName != null) {
        _departmentsArabicCache[departmentId] = arabicName;
        log('✅ [AnalyticsCubit] Cached Arabic dept: $departmentId → $arabicName');
      }
    } catch (e) {
      log('❌ [AnalyticsCubit] Error fetching department names for $departmentId: $e');
    }
  }

  /// Process department counts
  /// ✅ Uses department NAMES (English) instead of IDs for consistency
  void _processDepartmentCounts() {
    _departmentCounts.clear();

    log('🔍 [AnalyticsCubit] Starting _processDepartmentCounts');
    log('📊 [AnalyticsCubit] Total actions: ${_allActions.length}');
    log('👥 [AnalyticsCubit] Users in cache: ${_usersCache.length}');
    log('🏢 [AnalyticsCubit] Departments in cache: EN=${_departmentsEnglishCache.length}, AR=${_departmentsArabicCache.length}');

    for (var action in _allActions) {
      String userId = action.currentUserId;
      EmployeeData? user = _usersCache[userId];

      if (user != null) {
        String departmentId = user.currentemployeeDepartment;
        // ✅ Get department NAME (English) for counting
        String departmentName = getDepartmentName(departmentId, isEnglish: true);

        log('   ✅ User: ${user.currentemployeeName}, Dept ID: "$departmentId", Dept Name: "$departmentName"');

        _departmentCounts[departmentName] = (_departmentCounts[departmentName] ?? 0) + 1;
        log('   📈 Department "$departmentName" count: ${_departmentCounts[departmentName]}');
      } else {
        log('   ❌ User data NOT FOUND in cache for userId: "$userId"');
      }
    }

    log('📊 [AnalyticsCubit] Final department counts: $_departmentCounts');
    log('📊 [AnalyticsCubit] Total departments: ${_departmentCounts.length}');
  }

  /// ✅ UPDATED: Process monthly downloads and views with Arabic numeral conversion
  void _processMonthlyData() {
    _monthlyDownloads.clear();
    _monthlyViews.clear();

    log('⚙️ [AnalyticsCubit] Starting _processMonthlyData');
    log('📊 [AnalyticsCubit] Total actions to process: ${_allActions.length}');

    for (var action in _allActions) {
      if (action.timestamp.isEmpty) {
        log('   ⚠️ Action has no timestamps, skipping');
        continue;
      }

      try {
        // Get the last timestamp from the list
        String timestampStr = action.timestamp.last;
        log('   📅 Original timestamp: $timestampStr');

        // ✅ CRITICAL FIX: Convert Arabic numerals to English
        String convertedTimestamp = _convertArabicNumeralsToEnglish(timestampStr);
        log('   ✅ Converted timestamp: $convertedTimestamp');

        // Parse the date (format: "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd")
        DateTime date;
        if (convertedTimestamp.contains(' ')) {
          // Has time component
          date = DateTime.parse(convertedTimestamp.split(' ')[0]);
        } else {
          // Date only
          date = DateTime.parse(convertedTimestamp);
        }

        log('   📆 Parsed date: ${date.year}-${date.month}-${date.day}');

        // Create month key (e.g., "Jan", "Feb")
        String monthKey = _getMonthAbbreviation(date.month);
        log('   📅 Month key: $monthKey');

        String actionType = action.currentTypeOfAction.toLowerCase();
        log('   🎯 Action type: $actionType');

        if (actionType == 'download') {
          _monthlyDownloads[monthKey] = (_monthlyDownloads[monthKey] ?? 0) + 1;
          log('   ⬇️ Download count for $monthKey: ${_monthlyDownloads[monthKey]}');
        } else if (actionType == 'view') {
          _monthlyViews[monthKey] = (_monthlyViews[monthKey] ?? 0) + 1;
          log('   👁️ View count for $monthKey: ${_monthlyViews[monthKey]}');
        }
      } catch (e, stackTrace) {
        log('   ❌ Error parsing timestamp: $e');
        log('   📝 Timestamp value: ${action.timestamp.last}');
        log('   📚 Stack trace: $stackTrace');
      }
    }

    log('📥 [AnalyticsCubit] Final monthly downloads: $_monthlyDownloads');
    log('👁️ [AnalyticsCubit] Final monthly views: $_monthlyViews');
  }

  /// Calculate totals
  void _calculateTotals() {
    _totalDownloads = 0;
    _totalViews = 0;

    for (var action in _allActions) {
      String actionType = action.currentTypeOfAction.toLowerCase();
      if (actionType == 'download') {
        _totalDownloads++;
      } else if (actionType == 'view') {
        _totalViews++;
      }
    }

    log('📊 [AnalyticsCubit] Total downloads: $_totalDownloads, Total views: $_totalViews');
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
  Map<String, int> getLastNMonthsDownloads(int n) {
    Map<String, int> result = {};
    DateTime now = DateTime.now();

    for (int i = n - 1; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthKey = _getMonthAbbreviation(month.month);
      result[monthKey] = _monthlyDownloads[monthKey] ?? 0;
    }

    return result;
  }

  /// Get data for last N months (views)
  Map<String, int> getLastNMonthsViews(int n) {
    Map<String, int> result = {};
    DateTime now = DateTime.now();

    for (int i = n - 1; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthKey = _getMonthAbbreviation(month.month);
      result[monthKey] = _monthlyViews[monthKey] ?? 0;
    }

    return result;
  }

  /// Get top N departments by action count
  Map<String, int> getTopDepartments(int n) {
    var sorted = _departmentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Map<String, int> result = {};
    int othersCount = 0;

    for (int i = 0; i < sorted.length; i++) {
      if (i < n - 1) {
        result[sorted[i].key] = sorted[i].value;
      } else {
        othersCount += sorted[i].value;
      }
    }

    if (othersCount > 0) {
      result['Others'] = othersCount;
    }

    return result;
  }

  // ===========================================================================
  // STATISTICS TAB — FILTERS, SEARCH AND EXPORT
  // ---------------------------------------------------------------------------
  // ADDED 22/9/2026. The Statistics tab shipped with three dead controls: the
  // Export button's `onTap` was `() {}`, `FilterStatisticsDialog.applyFilters`
  // was a commented-out body, and the search field's `onSearchChanged` was
  // `(query) {}`. The table always rendered `allActions` whatever the user did.
  //
  // The filter state lives here rather than in the dialog because the table,
  // the search field and the export all have to agree on which rows are in
  // play — the export in particular must write what is on screen, not the
  // unfiltered set.
  // ===========================================================================

  /// `'view'` / `'download'`, or null for no action filter.
  String? statisticsActionFilter;

  /// A department ID (the key used by [getDepartmentName]), or null for all.
  String? statisticsDepartmentFilter;

  /// Free-text query from the search field above the table.
  String statisticsSearchQuery = '';

  /// The rows the Statistics tab should show: [allActions] narrowed by the
  /// action filter, the department filter and the search query.
  List<DocumentUtilizationModel> get filteredActions {
    final String query = statisticsSearchQuery.trim().toLowerCase();

    return _allActions.where((action) {
      final EmployeeData? user = _usersCache[action.currentUserId];

      if (statisticsActionFilter != null &&
          action.currentTypeOfAction.toLowerCase() !=
              statisticsActionFilter!.toLowerCase()) {
        return false;
      }

      if (statisticsDepartmentFilter != null &&
          (user?.currentemployeeDepartment ?? '') !=
              statisticsDepartmentFilter) {
        return false;
      }

      if (query.isEmpty) return true;

      // Searched across everything the table actually displays, so a user
      // typing what they can see always gets a hit.
      final String departmentId = user?.currentemployeeDepartment ?? '';
      final List<String> haystack = <String>[
        user?.currentemployeeName ?? '',
        user?.currentemployeeNameArabic ?? '',
        user?.currentemployeeEmail ?? '',
        user?.currentemployeeRole ?? '',
        if (departmentId.isNotEmpty) getDepartmentName(departmentId),
        if (departmentId.isNotEmpty)
          getDepartmentName(departmentId, isEnglish: false),
        action.currentTypeOfAction,
      ];

      return haystack.any((field) => field.toLowerCase().contains(query));
    }).toList();
  }

  /// The departments that actually appear in this document's statistics, as
  /// `departmentId -> localized name`. Built from the rows rather than from
  /// the full company list so the dropdown cannot offer a department that
  /// would return nothing.
  Map<String, String> statisticsDepartmentOptions({bool isEnglish = true}) {
    final Map<String, String> options = <String, String>{};

    for (final action in _allActions) {
      final EmployeeData? user = _usersCache[action.currentUserId];
      final String departmentId = user?.currentemployeeDepartment ?? '';
      if (departmentId.isEmpty || options.containsKey(departmentId)) continue;
      options[departmentId] = getDepartmentName(departmentId, isEnglish: isEnglish);
    }

    return options;
  }

  void setStatisticsSearch(String query) {
    statisticsSearchQuery = query;
    _emitCurrentAnalytics();
  }

  void applyStatisticsFilters({String? action, String? departmentId}) {
    statisticsActionFilter = action;
    statisticsDepartmentFilter = departmentId;
    _emitCurrentAnalytics();
  }

  void resetStatisticsFilters({bool clearSearch = true}) {
    statisticsActionFilter = null;
    statisticsDepartmentFilter = null;
    if (clearSearch) statisticsSearchQuery = '';
    _emitCurrentAnalytics();
  }

  /// Re-emits the CURRENT data so the tab rebuilds after a filter change.
  ///
  /// It re-emits `FetchingAnalyticsSuccessState` rather than a state of its
  /// own on purpose: the Analytics and Statistics tabs sit in one
  /// `IndexedStack` and both rebuild on every emit, and the Analytics tab
  /// falls through to a spinner for any state it does not recognise. A
  /// filter-specific state would blank that tab out. The state classes are not
  /// value types, so a fresh instance always reaches the listeners.
  void _emitCurrentAnalytics() {
    emit(
      FetchingAnalyticsSuccessState(
        departmentCounts: _departmentCounts,
        monthlyDownloads: _monthlyDownloads,
        monthlyViews: _monthlyViews,
        totalDownloads: _totalDownloads,
        totalViews: _totalViews,
      ),
    );
  }

  /// The statistics table as rows for a CSV export — header row first, then
  /// one row per VISIBLE action ([filteredActions]), in the order and wording
  /// the table shows.
  List<List<dynamic>> buildStatisticsExportRows({
    required List<String> headers,
    required bool isArabic,
  }) {
    final rows = <List<dynamic>>[headers];
    final actions = filteredActions;

    MainCoreEmployeeController? employeeController;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      employeeController = Get.find<MainCoreEmployeeController>();
    }

    for (int i = 0; i < actions.length; i++) {
      final action = actions[i];
      final EmployeeData? user = _usersCache[action.currentUserId];

      final String name = user == null
          ? action.currentUserId
          : (isArabic
              ? (user.currentemployeeNameArabic.isNotEmpty
                  ? user.currentemployeeNameArabic
                  : user.currentemployeeName)
              : user.currentemployeeName);

      final String departmentId = user?.currentemployeeDepartment ?? '';
      final String department = departmentId.isEmpty
          ? ''
          : getDepartmentName(departmentId, isEnglish: !isArabic);

      final String email = user?.currentemployeeEmail ?? '';
      final String jobTitle = (employeeController != null && email.isNotEmpty)
          ? employeeController.getEmployeeJobTitle(email)
          : (user?.currentemployeeRole ?? '');

      final DateTime dateTime = _parseActionTimestamp(action.currentTimestamp);

      rows.add(<dynamic>[
        i + 1,
        name,
        department,
        jobTitle,
        DateFormat('dd MMM yyyy').format(dateTime),
        DateFormat('h:mm a').format(dateTime),
        action.currentTypeOfAction,
      ]);
    }

    return rows;
  }

  /// Same parsing the table does: an ISO string, else epoch millis, else now.
  DateTime _parseActionTimestamp(String raw) {
    if (raw.isEmpty) return DateTime.now();
    final String normalized = _convertArabicNumeralsToEnglish(raw);
    final DateTime? parsed = DateTime.tryParse(normalized);
    if (parsed != null) return parsed;
    final int? millis = int.tryParse(normalized);
    if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
    return DateTime.now();
  }

  /// Listen to real-time updates
  void listenToAnalytics(String knowledgeId) {
    log('👂 [AnalyticsCubit] Setting up real-time listener for: $knowledgeId');

    _commentsServices.streamFileActionsByKnowledgeId(knowledgeId).listen(
          (actions) async {
        log('🔄 [AnalyticsCubit] Real-time update: ${actions.length} actions');
        _allActions = actions;

        if (_allActions.isEmpty) {
          emit(FetchingAnalyticsEmptyState());
          return;
        }

        // ✅ Fetch user data for any new users
        await _fetchUsersForActions(_allActions);

        // ✅ Fetch department names for any new departments
        await _fetchDepartmentsForUsers();

        _processDepartmentCounts();
        _processMonthlyData();
        _calculateTotals();

        emit(
          FetchingAnalyticsSuccessState(
            departmentCounts: _departmentCounts,
            monthlyDownloads: _monthlyDownloads,
            monthlyViews: _monthlyViews,
            totalDownloads: _totalDownloads,
            totalViews: _totalViews,
          ),
        );
      },
      onError: (error) {
        log('❌ [AnalyticsCubit] Error in listenToAnalytics: $error');
        emit(FetchingAnalyticsErrorState(error.toString()));
      },
    );
  }

  /// Clear analytics data
  void clearAnalytics() {
    log('🧹 [AnalyticsCubit] Clearing analytics data');
    _allActions = [];
    _usersCache = {};
    _departmentsEnglishCache = {};
    _departmentsArabicCache = {};
    _departmentCounts = {};
    _monthlyDownloads = {};
    _monthlyViews = {};
    _totalDownloads = 0;
    _totalViews = 0;
    statisticsActionFilter = null;
    statisticsDepartmentFilter = null;
    statisticsSearchQuery = '';
    emit(AnalyticsInitial());
  }

  /// Clear the users cache
  void clearUsersCache() {
    _usersCache.clear();
  }

  /// ✅ Clear both department caches
  void clearDepartmentsCache() {
    _departmentsEnglishCache.clear();
    _departmentsArabicCache.clear();
  }

  /// Fetch employee data for a specific employee ID
  Future<void> fetchEmployees(String employeeId) async {
    emit(EmployeesLoading());
    try {
      log('🔍 [AnalyticsCubit] Fetching employee data for ID: $employeeId');

      final employee = await _commentsServices.fetchUserDataByUserId(employeeId);

      if (employee == null) {
        log('⚠️ [AnalyticsCubit] No employee found with ID: $employeeId');
        _employees = [];
        emit(EmployeesLoadedSuccess([]));
        return;
      }

      // Store in list for compatibility with existing code
      _employees = [employee];

      // ✅ Also fetch department names
      final deptId = employee.currentemployeeDepartment;
      if (deptId.isNotEmpty && !_departmentsEnglishCache.containsKey(deptId)) {
        await _fetchDepartmentNamesById(deptId);
        log('🏢 [AnalyticsCubit] Cached department: $deptId → EN: ${_departmentsEnglishCache[deptId]}, AR: ${_departmentsArabicCache[deptId]}');
      }

      log('✅ [AnalyticsCubit] Successfully fetched employee: ${employee.currentemployeeName}');
      emit(EmployeesLoadedSuccess([employee]));
    } catch (e) {
      log('❌ [AnalyticsCubit] Error in fetchEmployees: $e');
      _employees = [];
      emit(EmployeesLoadingFailure(e.toString()));
    }
  }
}