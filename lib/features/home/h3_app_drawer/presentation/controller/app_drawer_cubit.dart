/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: app_drawer_cubit.dart
/// Purpose: Declares `AppDrawerCubit`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/data/repository/app_drawer_repository.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/domain/base_repository/app_drawer_base_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/main.dart';

import 'package:knowticed_plus/core/helper/main_helper/biometric_controller.dart';
import '../../../../../core/network/api_constants.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/data/utils/app_drawer_constant_modules.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/data/utils/app_drawer_update_ids.dart';

part './app_drawer_state.dart';

class AppDrawerCubit extends Cubit<AppDrawerState> {
  /// Kicks off [_init] immediately, mirroring the GetxController onInit()
  /// behaviour the rest of the app relies on.
  /// The repository is injected so it can be faked in tests; callers keep
  /// using `AppDrawerCubit()`.
  ///
  /// [_init] still runs from the constructor because `Get.put(AppDrawerCubit())`
  /// call sites across the app depend on the module list being populated
  /// without an explicit init step.
  AppDrawerCubit({AppDrawerBaseRepository? appDrawerRepository})
      : _appDrawerRepository = appDrawerRepository ?? AppDrawerRepository(),
        super(const AppDrawerInitial()) {
    _init();
  }

  final AppDrawerBaseRepository _appDrawerRepository;

  /// Re-runs the module load. Replaces call sites that used to invoke the
  /// GetxController's `onInit()` by hand to force a refresh.
  Future<void> reload() => _init();

  /// Role flags, formerly `Mode.owner` / `Mode.hr`.
  /// Static so they survive `Get.delete<AppDrawerCubit>()` on mobile
  /// layouts, where widgets read them without the controller registered.
  static bool isOwner = false;
  static bool isHr = false;

  RoleCubit roleController = roleCubit;
  RoleHistoryModel? roleHistory;
  List<Modules> _allDrawerModules = [];
  List<Modules> allowedDrawerModules = [];

  // Company license data
  Map<String, bool> _companyLicensedModules = {};

  List<Widget> get drawerItems =>
      allowedDrawerModules.map((module) => module.widget).toList();
  List<String> get drawerTitles =>
      allowedDrawerModules.map((module) => module.getModuleName).toList();
  List<String> get drawerIcons =>
      allowedDrawerModules.map((module) => module.iconPath).toList();

  int selectedIndex = 0;

  // Storage key for custom order
  static const String _orderStorageKey = 'drawer_custom_order';

  bool isLoadingModules = true;






  // ✅ UPDATE onInit() in app_drawer_controller.dart

  Future<void> _init() async {

    isLoadingModules = true;
    _publish();

    // ✅ FIX: employeeEntity may not be ready yet (MainCoreEmployeeController
    // loads it asynchronously during login). Previously we bailed out
    // immediately, leaving the drawer with only Home + Settings forever.
    // Now we wait up to ~10 seconds for it to become available.
    final mainCoreController = Get.find<MainCoreEmployeeController>();
    var currentEmployee = mainCoreController.employeeEntity;

    int retries = 0;
    while (currentEmployee == null && retries < 20) {
      if (retries == 0) {
      }
      await Future.delayed(const Duration(milliseconds: 500));
      currentEmployee = mainCoreController.employeeEntity;
      retries++;
    }
    if (currentEmployee != null && retries > 0) {
    }

    if (currentEmployee == null) {
      _allDrawerModules = [];
      _getAllowedDrawerModules();
      isLoadingModules = false;
      _publish();
      return;
    }

    // ✅ CHECK: Is user company admin?
    bool isAdmin = (currentEmployee.id == '1');

    String? companyId = _getCompanyId(currentEmployee);

    if (companyId != null && companyId.isNotEmpty) {
      await _loadCompanyLicensedModules(companyId);
    }

    String? employeeRoleName = _getEmployeeRoleName(currentEmployee);

    if (employeeRoleName == null || employeeRoleName.isEmpty) {
      _allDrawerModules = [];
      _getAllowedDrawerModules();
      isLoadingModules = false;
      _publish();
      return;
    }

    AppDrawerCubit.isOwner = _isAdminRole(employeeRoleName);
    AppDrawerCubit.isHr = employeeRoleName.toLowerCase() == 'hr';

    selectedIndex = 0;
    allowedDrawerModules = [];

    try {
      // ✅ UPDATED: Load role from appropriate collection
      if (isAdmin) {

        // Load from Subscription_Admin
        roleHistory = roleController.roles.firstWhereOrNull(
              (element) => element.currentRoleName.toLowerCase() == employeeRoleName.toLowerCase(),
        );

        if (roleHistory == null) {
          _allDrawerModules = Modules.values.where((m) => m != Modules.more).toList();
        } else {
          // Admin/master roles get every module, NOT just the ones stored in
          // Current_Selected_Modules. That stored array is a snapshot from when
          // the role was created, so modules added to the platform later (hr,
          // crm, ...) are missing from it and would never reach the drawer.
          // The company-license filter in _getDrawerModulesFromReference still
          // applies, so this widens the role gate only — not the license gate.
          _allDrawerModules =
              Modules.values.where((m) => m != Modules.more).toList();
        }
      } else {

        // Load from Roles (existing code)
        roleHistory = roleController.roles.firstWhereOrNull(
              (element) => element.currentRoleName.toLowerCase() == employeeRoleName.toLowerCase(),
        );

        if (roleHistory == null) {
          if (_isAdminRole(employeeRoleName)) {
            _allDrawerModules = Modules.values.where((m) => m != Modules.more).toList();
          } else {
            _allDrawerModules = [];
          }
        } else if (_isAdminRole(employeeRoleName)) {
          // Same reasoning as the admin branch above: an admin role's stored
          // Current_Selected_Modules predates newer modules, so widen to all.
          _allDrawerModules =
              Modules.values.where((m) => m != Modules.more).toList();
        } else {
          List<String> activeModuleNames = roleHistory!.currentSelectedModules;
          _allDrawerModules = _convertModuleNamesToEnums(activeModuleNames);
        }
      }

      _getAllowedDrawerModules();
      isLoadingModules = false;
      _publish();

    } catch (e, stackTrace) {
      _allDrawerModules = [];
      _getAllowedDrawerModules();
      isLoadingModules = false;
      _publish();
    }
  }


  /// Extract company ID from ApiConstants.baseUri
  String? _getCompanyId(dynamic currentEmployee) {
    // print('🔍 Drawer: Attempting to extract company ID');
    // print('🔍 Drawer: ApiConstants.baseUri = "${ApiConstants.baseUri}"');

    // Method 1: Extract from ApiConstants.baseUri (PRIMARY - MOST RELIABLE)
    if (ApiConstants.baseUri.isNotEmpty) {
      // print('✅ Drawer: baseUri is not empty');

      if (ApiConstants.baseUri.contains('/')) {
        // print('✅ Drawer: baseUri contains "/"');

        List<String> parts = ApiConstants.baseUri.split('/');
        // print('🔍 Drawer: Split into ${parts.length} parts: $parts');

        if (parts.length >= 2) {
          String companyId = parts[1];
          // print('✅✅✅ Drawer: Successfully extracted company ID: $companyId');
          return companyId;
        } else {
          // print('❌ Drawer: Not enough parts (need 2+, got ${parts.length})');
        }
      } else {
        // print('❌ Drawer: baseUri does NOT contain "/"');
      }
    } else {
      // print('❌ Drawer: baseUri is EMPTY');
    }

    // print('❌ Drawer: Extraction failed, returning null');
    return null;
  }

  /// Function Name: [_loadCompanyLicensedModules]
  ///
  /// Purpose: Load which modules this company is licensed for.
  ///
  /// The Firestore read and the document parsing now live in
  /// [AppDrawerRepository]; an empty map means "no licence data", which
  /// [_isModuleLicensed] treats as "block every non-system module".
  ///
  /// Parameters:
  /// - [companyId]: Document id of the company's demo-request record.
  Future<void> _loadCompanyLicensedModules(String companyId) async {
    _companyLicensedModules =
        await _appDrawerRepository.getCompanyLicensedModules(companyId);
  }

  /// Function Name: [isModuleLicensed]
  ///
  /// Purpose: Public read-out of the COMPANY licence layer — "did this company
  ///          buy [module]?", with no role filtering applied.
  ///
  /// ADDED 30/8/2026. The licence map was private and the only public surface
  /// was [allowedDrawerModules], which is already role ∩ licence: a screen
  /// asking a question about the COMPANY got an answer about the current USER,
  /// and read "this company has no HR" whenever the signed-in role simply did
  /// not include HR. Callers should go through `CompanyModules`
  /// (core/helper/role/company_modules.dart), which owns the
  /// not-registered / not-yet-loaded cases.
  ///
  /// Parameters:
  /// - [module]: The module being asked about.
  ///
  /// Returns: [bool] — false while the licence read is still in flight, since
  /// [_isModuleLicensed] fails closed on an empty map.
  bool isModuleLicensed(Modules module) => _isModuleLicensed(module);

  /// Check if a module is licensed by the company
  bool _isModuleLicensed(Modules module) {
    // System modules (home, settings) are always allowed
    if (module == Modules.home || module == Modules.settings) {
      return true;
    }

    // If no license data, BLOCK (fail-closed security)
    if (_companyLicensedModules.isEmpty) {
      // print('❌ Drawer: No license data loaded, blocking ${module.name}');
      return false;
    }

    String moduleName = module.name.toLowerCase();

    // ✅ FIX: Map grc enum back to "grc" Firebase key
    if (module == Modules.grc) {
      moduleName = 'grc';
    }

    // ✅ FIX: If qiyas module exists separately, map it too
    if (module == Modules.qiyas) {
      // Check if you have a separate qiyas key in Firebase
      // If not, use grc key
      moduleName = _companyLicensedModules.containsKey('qiyas') ? 'qiyas' : 'grc';
    }

    // 8/10/2026 — Time Tracker: `Modules.timeTracker.name` lower-cases to
    // 'timetracker', but the licence is stored as `time_tracker` (spec) or
    // `tracking` (Knowticed Admin today, owner decision 17). Any spelling
    // from `ModuleNameAliases` that is licensed counts.
    if (module == Modules.timeTracker) {
      return ModuleNameAliases.spellingsOf('time_tracker')
          .any((String key) => _companyLicensedModules[key] == true);
    }

    final isLicensed = _companyLicensedModules[moduleName] ?? false;

    if (isLicensed) {
      // print('✅ Drawer: Module ${module.name} IS licensed');
    } else {
      // print('❌ Drawer: Module ${module.name} NOT licensed by company');
    }

    return isLicensed;
  }

  /// Save custom drawer order
  void saveCustomOrder(List<Modules> newOrder) {
    try {
      List<String> orderStrings = newOrder.map((m) => m.getModuleName).toList();
      storage.write(_orderStorageKey, orderStrings);

      allowedDrawerModules = newOrder;
      _publish();

      // print('✅ Drawer: Custom order saved: ${orderStrings.join(', ')}');
    } catch (e) {
      // print('❌ Drawer: Error saving custom order: $e');
    }
  }

  /// Load custom drawer order
  List<Modules>? _loadCustomOrder() {
    try {
      List<dynamic>? orderStrings = storage.read(_orderStorageKey);
      if (orderStrings == null || orderStrings.isEmpty) {
        return null;
      }

      List<Modules> customOrder = [];
      Set<Modules> addedModules = {};

      for (var moduleName in orderStrings) {
        Modules? module = _getModuleFromDisplayName(moduleName.toString());
        if (module != null && _allDrawerModules.contains(module)) {
          if (!addedModules.contains(module)) {
            customOrder.add(module);
            addedModules.add(module);
          } else {
            // print('⚠️ Drawer: Skipped duplicate module in custom order: ${module.getModuleName}');
          }
        }
      }

      for (var module in allowedDrawerModules) {
        if (!addedModules.contains(module)) {
          customOrder.add(module);
          addedModules.add(module);
        }
      }

      // print('✅ Drawer: Loaded custom order: ${customOrder.map((m) => m.getModuleName).join(', ')}');
      return customOrder;
    } catch (e) {
      // print('❌ Drawer: Error loading custom order: $e');
      return null;
    }
  }

  /// Get module from display name
  Modules? _getModuleFromDisplayName(String displayName) {
    for (var module in Modules.values) {
      if (module.getModuleName.toLowerCase() == displayName.toLowerCase()) {
        return module;
      }
    }

    return _getModuleEnum(displayName);
  }

  /// Reset to default order
  void resetToDefaultOrder() {
    try {
      storage.remove(_orderStorageKey);
      allowedDrawerModules.clear();
      _getAllowedDrawerModules();
      _publish();
      // print('✅ Drawer: Reset to default order');
    } catch (e) {
      // print('❌ Drawer: Error resetting order: $e');
    }
  }

  bool _isAdminRole(String roleName) {
    String lowerRoleName = roleName.toLowerCase().trim();
    return lowerRoleName == 'super admin' ||
        lowerRoleName == 'master admin' ||
        lowerRoleName == 'admin_role' ||
        lowerRoleName == 'admin' ||
        lowerRoleName == 'administrator';
  }

  String? _getEmployeeRoleName(dynamic currentEmployee) {
    try {
      dynamic role = currentEmployee.role;

      if (role == null) {
        return null;
      }

      if (role is String) {
        return role;
      }

      if (role.role != null) {
        if (role.role is List && (role.role as List).isNotEmpty) {
          return (role.role as List).last?.toString();
        }
        if (role.role is String) {
          return role.role as String;
        }
      }

      return role.toString();
    } catch (e) {
      // print('⚠️ Drawer: Error extracting role name: $e');
      return null;
    }
  }

  List<Modules> _convertModuleNamesToEnums(List<String> moduleNames) {
    List<Modules> moduleEnums = [];

    for (String moduleName in moduleNames) {
      Modules? moduleEnum = _getModuleEnum(moduleName);
      // `!contains` (8/10/2026): `time_tracker` and legacy `tracking` both
      // map to Modules.timeTracker — list it once.
      if (moduleEnum != null && !moduleEnums.contains(moduleEnum)) {
        moduleEnums.add(moduleEnum);
     //   // print('  ✓ Drawer: Added module: $moduleName -> ${moduleEnum.getModuleName}');
      } else {
        // print('  ✗ Drawer: Unknown module: $moduleName');
      }
    }

    return moduleEnums;
  }

  Modules? _getModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase().trim()) {
      case 'employees':
        return Modules.employees;
      case 'services':
        return Modules.services;
      case 'tasks':
        return Modules.tasks;
      case 'todo':
        return Modules.todo;
      case 'events':
        return Modules.events;
      case 'notes':
        return Modules.notes;
      case 'requests':
        return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':
        return Modules.knowledgeHub;
      case 'qiyas':
        return Modules.qiyas;
      case 'grc':
        return Modules.grc;
      // 8/10/2026 — owner decision 17: legacy `tracking` IS Time Tracker.
      case 'time_tracker':
      case 'timetracker':
      case 'tracking':
        return Modules.timeTracker;
      case 'inventory':
        return Modules.inventory;
      case 'messages':
        return Modules.messages;
      case 'database_builder':
      case 'database':
        return Modules.database;
      case 'services_app':
      case 'formbuilder':
        return Modules.formBuilder;
      case 'roles':
        return Modules.roles;
      case 'settings':
        return Modules.settings;
      case 'home':
        return Modules.home;
      case 'hr':  // ✅ Add this
        return Modules.hr;
      case 'crm':  // ✅ Add this
        return Modules.crm;
      case 'notification':  // ✅ Add this
        return Modules.notification;
      default:
        // print('⚠️ Drawer: Unknown module name: $moduleName');
        return null;
    }
  }

  void _getAllowedDrawerModules() {
    // print('🔍 Drawer: Building allowed modules list');
    // print('🔍 Drawer: _allDrawerModules (from role): ${_allDrawerModules.map((m) => m.getModuleName).join(', ')}');
    // print('🔍 Drawer: _companyLicensedModules: $_companyLicensedModules');

    if (!_allDrawerModules.contains(Modules.home)) {
      _allDrawerModules.add(Modules.home);
      // print('  ✓ Drawer: Added home module to _allDrawerModules');
    }
    if (!_allDrawerModules.contains(Modules.settings)) {
      _allDrawerModules.add(Modules.settings);
      // print('  ✓ Drawer: Added settings module to _allDrawerModules');
    }

    if (!allowedDrawerModules.contains(Modules.home)) {
      allowedDrawerModules.add(Modules.home);
      // print('  ✅ Drawer: Added home to allowedDrawerModules (system module)');
    }
    if (!allowedDrawerModules.contains(Modules.settings)) {
      allowedDrawerModules.add(Modules.settings);
      // print('  ✅ Drawer: Added settings to allowedDrawerModules (system module)');
    }

    // print("🔧 Drawer: AppDrawerCubit.isOwner: ${AppDrawerCubit.isOwner}, AppDrawerCubit.isHr: ${AppDrawerCubit.isHr}");

    if (AppDrawerCubit.isOwner || AppDrawerCubit.isHr) {
      if (!_allDrawerModules.contains(Modules.roles)) {
        _allDrawerModules.add(Modules.roles);
        // print('  ✓ Drawer: Added roles_module module to _allDrawerModules (admin/HR)');
      }
      if (!allowedDrawerModules.contains(Modules.roles)) {
        allowedDrawerModules.add(Modules.roles);
        // print('  ✅ Drawer: Added roles_module to allowedDrawerModules (admin/HR)');
      }
    }

    // print('🔍 Drawer: Filtering modules by company license...');
    _getDrawerModulesFromReference(
        referenceModulesList: AppDrawerConstantModules.drawerModules
    );

    // print('🔍 Drawer: After reference filtering, allowed modules: ${allowedDrawerModules.map((m) => m.getModuleName).join(', ')}');

    List<Modules>? customOrder = _loadCustomOrder();
    if (customOrder != null && customOrder.isNotEmpty) {
      // print('🔄 Drawer: Custom order found, but checking if it has all modules...');

      List<Modules> missingFromCustomOrder = [];
      for (var module in allowedDrawerModules) {
        if (!customOrder.contains(module)) {
          missingFromCustomOrder.add(module);
          // print('  ⚠️ Drawer: Custom order missing: ${module.getModuleName}');
        }
      }

      if (missingFromCustomOrder.isEmpty) {
        allowedDrawerModules = customOrder;
        // print('✅ Drawer: Applied custom order (complete)');
      } else {
        // print('❌ Drawer: Custom order incomplete (missing ${missingFromCustomOrder.length} modules), ignoring it');
        // print('❌ Drawer: Clearing corrupted custom order storage');
        storage.remove(_orderStorageKey);
      }
    }

    // print('📱 Drawer: Final allowed modules (${allowedDrawerModules.length}): ${allowedDrawerModules.map((m) => m.getModuleName).join(', ')}');
  }

  void _getDrawerModulesFromReference({
    required List<Modules> referenceModulesList,
  }) {
    // print('🔍 Drawer: Checking reference modules: ${referenceModulesList.map((m) => m.getModuleName).join(', ')}');

    for (Modules module in referenceModulesList) {
      if (module == Modules.home || module == Modules.settings) {
        // print('  ℹ️ Drawer: ${module.name} is system module (already added)');
        continue;
      }

      bool isInRole = _allDrawerModules.contains(module);
      bool notInAllowed = !allowedDrawerModules.contains(module);
      bool isLicensed = _isModuleLicensed(module);

      // print('  🔎 Module ${module.getModuleName}: inRole=$isInRole, notInAllowed=$notInAllowed, isLicensed=$isLicensed');

      if (isInRole && notInAllowed && isLicensed) {
        allowedDrawerModules.add(module);
        // print('  ✅ Drawer: Added ${module.getModuleName} (in role + licensed + not duplicate)');
      } else {
        if (!isInRole) {
          // print('  ❌ Drawer: Skipped ${module.getModuleName} (not in role)');
        } else if (!notInAllowed) {
          // print('  ⚠️ Drawer: Skipped ${module.getModuleName} (already in allowed)');
        } else if (!isLicensed) {
          // print('  ❌ Drawer: Skipped ${module.getModuleName} (not licensed by company)');
        }
      }
    }
  }

  updateSelectedIndex(int index, {bool isOnlyDrawer = false}) {
    selectedIndex = index;
    if (isOnlyDrawer) {
      _publish();
    } else {
      _publish();
    }
  }

  /// Emits the current field snapshot so BlocBuilder rebuilds. Replaces the
  /// GetxController `update()` / `update([id])` calls the original used —
  /// Bloc has no per-id rebuilds, so every listener rebuilds.
  void _publish() {
    if (isClosed) return;
    emit(AppDrawerLoaded(
      allowedDrawerModules: List.unmodifiable(allowedDrawerModules),
      selectedIndex: selectedIndex,
      isLoadingModules: isLoadingModules,
      isReorderingActive: isReorderingActive,
    ));
  }

  /// Whether drawer reordering mode is on.
  ///
  /// Replaces the module-global `RxBool isDrawerReorderingActive` that used to
  /// live in `custom_drawer.dart` and was toggled from the home-layout editor
  /// in a different feature.
  bool isReorderingActive = false;

  /// Function Name: [setReorderingActive]
  ///
  /// Purpose: Turn drawer reordering mode on or off.
  ///
  /// Parameters:
  /// - [value]: The new mode.
  void setReorderingActive(bool value) {
    if (isReorderingActive == value) return;
    isReorderingActive = value;
    _publish();
  }

  /// Function Name: [toggleReorderingActive]
  ///
  /// Purpose: Flip drawer reordering mode.
  void toggleReorderingActive() => setReorderingActive(!isReorderingActive);

  /// Display version string shown at the bottom of the drawer, e.g. `v1.0.0`.
  /// Empty when the platform lookup failed.
  String appVersion = '';

  /// Function Name: [loadAppVersion]
  ///
  /// Purpose: Read the package version for the drawer footer.
  ///
  /// This lived in `custom_drawer.dart` wrapped in a try/catch, which §11.2
  /// forbids in `presentation/ui/`. The catch belongs here in the cubit: a
  /// failed platform lookup just means no version label.
  Future<void> loadAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = 'v${packageInfo.version}';
    } catch (_) {
      appVersion = '';
    }
    _publish();
  }
}
