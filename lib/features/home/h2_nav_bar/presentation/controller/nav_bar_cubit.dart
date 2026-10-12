/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_cubit.dart
/// Purpose: Declares `NavBarCubit`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/data/repository/nav_bar_repository.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/domain/base_repository/nav_bar_base_repository.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

import '../../../../../core/network/api_constants.dart';
import '../../../../../generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';

part './nav_bar_state.dart';

class NavBarCubit extends Cubit<NavBarState> {
  /// Kicks off [_init] immediately, mirroring the GetxController onInit()
  /// behaviour the rest of the app relies on.
  /// The repository is injected so it can be faked in tests; callers keep
  /// using `NavBarCubit()`.
  ///
  /// [_init] still runs from the constructor because `Get.put(NavBarCubit())`
  /// call sites across the app depend on the module list being populated
  /// without an explicit init step.
  NavBarCubit({NavBarBaseRepository? navBarRepository})
      : _navBarRepository = navBarRepository ?? NavBarRepository(),
        super(const NavBarInitial()) {
    _init();
  }

  final NavBarBaseRepository _navBarRepository;

  /// Re-runs the module load. Replaces call sites that used to invoke the
  /// GetxController's `onInit()` by hand to force a refresh.
  Future<void> reload() => _init();

  RoleCubit roleController = roleCubit;
  RoleHistoryModel? roleHistory;
  List<Modules> _allAllowedModules = [];
  List<Modules> moreListModules = [];
  List<Modules> navBarModules = [];

  // ✅ ADD: Company license data (same as AppDrawerCubit)
  Map<String, bool> _companyLicensedModules = {};
  bool isLoadingModules = true;

  List<Widget> get navBarItems =>
      navBarModules.map((module) => module.widget).toList();
  List<String> get navBarTitles =>
      navBarModules.map((module) => module.getModuleName).toList();
  List<String> get navBarIcons =>
      navBarModules.map((module) => module.iconPath).toList();
  bool get isAppBarEventAllowed =>
      _allAllowedModules.contains(Modules.events) &&
          !navBarModules.contains(Modules.events);


  Future<void> _init() async {


    isLoadingModules = true;

    // ✅ CRITICAL: Initialize with minimum viable navbar IMMEDIATELY
    // This prevents UI crashes while Firebase loads
    navBarModules = [Modules.home, Modules.more];
    _publish();

    final currentEmployee = Get.find<MainCoreEmployeeController>().employeeEntity;

    if (currentEmployee == null) {
      _allAllowedModules = [];
      _getNavBarModules();
      isLoadingModules = false;
      _publish();
      return;
    }

    // Is this the COMPANY (subscription) admin?
    //
    // Employee id '1' is the subscription admin account. AppDrawerCubit has
    // checked exactly this since it was written (its line ~117) and hands that
    // account every module, whatever its role says. This cubit never did, so
    // the desktop drawer and the mobile nav bar disagreed for the same signed-
    // in user: the drawer showed GRC, the nav bar and its More page did not.
    //
    // It is an IDENTITY check, not a role-name one, which is why widening on
    // `_isAdminRole` alone did not fix it — the account's role here is
    // "Develper", which is not an admin name, and whose stored
    // Current_Selected_Modules simply has no 'grc' entry.
    final bool isSubscriptionAdmin = (currentEmployee.id == '1');

    // ✅ ADD: Extract company ID and load licensed modules
    String? companyId = _getCompanyId(currentEmployee);

    if (companyId != null && companyId.isNotEmpty) {
      await _loadCompanyLicensedModules(companyId);
    } else {
      _companyLicensedModules = {
        'services': true,
        'tasks': true,
        'tracking': true,
        'inventory': true,
        'messages': true,
        'roles': true,
        'knowledge_hub': true,
        'knowledgehub': true,
        'qiyas': true,
        'grc': true,
        'services_app': true,
        'formbuilder': true,
        'todo': true,
        'employees': true,
        'events': true,
        'notes': true,
        'requests': true,
        'database': true,
        'database_builder': true,
      };
    }

    _log('companyId = $companyId');
    _log('licensed map (${_companyLicensedModules.length} keys) = '
        '$_companyLicensedModules');
    _log("licensed['grc'] = ${_companyLicensedModules['grc']}  "
        "(key present: ${_companyLicensedModules.containsKey('grc')})");

    String? employeeRoleName = _getEmployeeRoleName(currentEmployee);

    final String adminFlag = (employeeRoleName == null)
        ? 'n/a'
        : _isAdminRole(employeeRoleName).toString();
    _log('role name = "$employeeRoleName"   isAdminRole = $adminFlag');
    _log('employee id = "${currentEmployee.id}"   '
        'isSubscriptionAdmin = $isSubscriptionAdmin');

    if (employeeRoleName == null || employeeRoleName.isEmpty) {
      _log('ABORT: role name null/empty -> _allAllowedModules = []');
      _allAllowedModules = [];
      _getNavBarModules();
      isLoadingModules = false;
      _publish();
      return;
    }


    try {
      roleHistory = roleController.roles.firstWhereOrNull(
            (element) => element.currentRoleName.toLowerCase() == employeeRoleName.toLowerCase(),
      );

      if (roleHistory == null) {

        if (isSubscriptionAdmin || _isAdminRole(employeeRoleName)) {
          _allAllowedModules =
              Modules.values.where((m) => m != Modules.more).toList();
        } else {
          _allAllowedModules = [];
        }
        _getNavBarModules();
        isLoadingModules = false;
        _publish();
        return;
      }


      _log('roleHistory found = ${roleHistory != null}');
      if (roleHistory != null) {
        _log('  currentSelectedModules = '
            '${roleHistory!.currentSelectedModules}');
      }

      if (isSubscriptionAdmin || _isAdminRole(employeeRoleName)) {
        // The subscription admin, and admin/master roles, get every module —
        // NOT just the ones stored in Current_Selected_Modules.
        //
        // This mirrors AppDrawerCubit, which has widened the admin role gate
        // this way for a while. The nav bar did not, and only widened when
        // roleHistory was NULL — so an admin whose role record DOES exist fell
        // through to the stored snapshot below. That array is frozen at the
        // moment the role was created, so every module added to the platform
        // afterwards (GRC among them) was missing from it: present in the
        // desktop drawer, absent from the mobile nav bar and its More page,
        // for the same signed-in admin. That is the bug this fixes.
        //
        // Role gate only. Every consumer below still runs the module through
        // _isModuleLicensed, so a company that is not licensed for a module
        // does not get it here.
        _allAllowedModules =
            Modules.values.where((m) => m != Modules.more).toList();
      } else {
        List<String> activeModuleNames = roleHistory!.currentSelectedModules;
        _allAllowedModules = _convertModuleNamesToEnums(activeModuleNames);
      }

      _getNavBarModules();


      isLoadingModules = false;
      _publish();

    } catch (e, stackTrace) {
      _allAllowedModules = [];
      _getNavBarModules();
      isLoadingModules = false;
      _publish();
    }
  }

  // ✅ ADD: Extract company ID (same as AppDrawerCubit)
  String? _getCompanyId(dynamic currentEmployee) {

    if (ApiConstants.baseUri.isNotEmpty) {

      if (ApiConstants.baseUri.contains('/')) {

        List<String> parts = ApiConstants.baseUri.split('/');

        if (parts.length >= 2) {
          String companyId = parts[1];
          return companyId;
        }
      }
    }

    return null;
  }

  /// Function Name: [_loadCompanyLicensedModules]
  ///
  /// Purpose: Load which modules this company is licensed for.
  ///
  /// The Firestore read and the document parsing now live in
  /// [NavBarRepository]; an empty map means "no licence data", which
  /// [_isModuleLicensed] treats as "block every non-system module".
  ///
  /// Parameters:
  /// - [companyId]: Document id of the company's demo-request record.
  Future<void> _loadCompanyLicensedModules(String companyId) async {
    _companyLicensedModules =
        await _navBarRepository.getCompanyLicensedModules(companyId);
  }

  // ✅ ADD: Check if module is licensed (same as AppDrawerCubit)
  bool _isModuleLicensed(Modules module) {
    // ✅ FIX: System modules are always allowed (including roles_module for admin/HR)
    if (module == Modules.home ||
        module == Modules.settings ||
        module == Modules.roles) {  // ✅ Roles is also a system module
      return true;
    }

    // ✅ CRITICAL: "More" is special - it's always allowed for navbar but NOT checked for license
    if (module == Modules.more) {
      return true;
    }

    // If no license data, BLOCK
    if (_companyLicensedModules.isEmpty) {
      return false;
    }

    String moduleName = module.name.toLowerCase();

    // Map grc/qiyas correctly
    if (module == Modules.grc) {
      moduleName = 'grc';
    }
    if (module == Modules.qiyas) {
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
    } else {
    }

    return isLicensed;
  }

  bool _isAdminRole(String roleName) {
    String lowerRoleName = roleName.toLowerCase().trim();
    return lowerRoleName == 'super admin' ||
        lowerRoleName == 'admin_role' ||
        lowerRoleName == 'admin' ||
        lowerRoleName == 'administrator';
  }

  String? _getEmployeeRoleName(dynamic currentEmployee) {
    try {
      dynamic role = currentEmployee.role;

      if (role == null) return null;
      if (role is String) return role;

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
      } else {
      }
    }

    return moduleEnums;
  }

  Modules? _getModuleEnum(String moduleName) {
    String normalizedName = moduleName.toLowerCase().trim();

    switch (normalizedName) {
      case 'employees':
      case 'الموظفين':
        return Modules.employees;
      case 'services':
      case 'الخدمات':
        return Modules.services;
      case 'tasks':
      case 'المهام':
        return Modules.tasks;
      case 'todo':
      case 'قائمة المهام':
        return Modules.todo;
      case 'events':
      case 'الأحداث':
        return Modules.events;
      case 'notes':
      case 'الملاحظات':
        return Modules.notes;
      case 'requests':
      case 'الطلبات':
        return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':
      case 'مركز المعرفة':
        return Modules.knowledgeHub;
      case 'qiyas':
      case 'قياس':
        return Modules.qiyas;
      case 'grc':
      case 'كامل':
        return Modules.grc;
      // 8/10/2026 — owner decision 17: legacy `tracking` IS Time Tracker.
      case 'time_tracker':
      case 'timetracker':
      case 'tracking':
      case 'التتبع':
        return Modules.timeTracker;
      case 'inventory':
      case 'المخزون':
        return Modules.inventory;
      case 'messages':
      case 'الرسائل':
        return Modules.messages;
      case 'database_builder':
      case 'database':
      case 'منشئ قاعدة البيانات':
      case 'قاعدة البيانات':
        return Modules.database;
      case 'services_app':
      case 'formbuilder':
      case 'منشئ النماذج':
        return Modules.formBuilder;
      case 'roles':
      case 'الأدوار':
        return Modules.roles;
      case 'settings':
      case 'الإعدادات':
        return Modules.settings;
      case 'home':
      case 'الرئيسية':
        return Modules.home;
      default:
        return null;
    }
  }

  void _getNavBarModules() {
    final currentEmployee = Get.find<MainCoreEmployeeController>().employeeEntity;

    if (currentEmployee == null) {
      return;
    }

    String? employeeRoleName = _getEmployeeRoleName(currentEmployee);

    if (employeeRoleName == null) {
      return;
    }

    // AppDrawerCubit.isOwner = _isAdminRole(employeeRoleName);
    // AppDrawerCubit.isHr = employeeRoleName.toLowerCase() == 'hr';
    //
    // print('🔧 NavBar: Role: $employeeRoleName');
    // print('🔧 NavBar: AppDrawerCubit.isOwner: ${AppDrawerCubit.isOwner}, AppDrawerCubit.isHr: ${AppDrawerCubit.isHr}');

    // Always add home
    if (!_allAllowedModules.contains(Modules.home)) {
      _allAllowedModules.add(Modules.home);
    }

    // ✅ CRITICAL FIX: Clear navBarModules to remove the initial [home, more]
    navBarModules.clear();

    if (AppDrawerCubit.isOwner) {
      _getNavBarModulesFromReference(
          referenceModulesList: NavBarConstantModules.defaultAdminNavBarModules);
    } else if (AppDrawerCubit.isHr) {
      if (!_allAllowedModules.contains(Modules.roles)) {
        _allAllowedModules.add(Modules.roles);
      }
      _getNavBarModulesFromReference(
          referenceModulesList: NavBarConstantModules.defaultHRNavBarModules);
    } else {
      _getNavBarModulesFromReference(
          referenceModulesList: NavBarConstantModules.defaultUserNavBarModules);
    }

    _addSecondaryModulesIfNeeded();

    // ✅ Only add More once, here at the end
    if (!navBarModules.contains(Modules.more)) {
      navBarModules.add(Modules.more);
    }

    _getMoreListModules();

    _logGrcVerdict();
  }

  // ── Diagnostics ───────────────────────────────────────────────────────────
  // Tagged so they can be filtered:  flutter logs | grep NAVBAR
  // Remove once the GRC-on-mobile question is settled.

  void _log(String message) => debugPrint('[NAVBAR] $message');

  /// Walks GRC through every gate that can drop it, and prints the result of
  /// each one. Whichever line reads false is the reason it is missing.
  void _logGrcVerdict() {
    const Modules grc = Modules.grc;

    final bool inAllAllowed = _allAllowedModules.contains(grc);
    final bool licensed = _isModuleLicensed(grc);
    final bool inNavBar = navBarModules.contains(grc);
    final bool inMoreList = moreListModules.contains(grc);

    _log('--- GRC verdict -------------------------------------------');
    _log('  AppDrawerCubit.isOwner = ${AppDrawerCubit.isOwner}  '
        'isHr = ${AppDrawerCubit.isHr}');
    _log('  in _allAllowedModules  = $inAllAllowed   <- role gate');
    _log('  _isModuleLicensed      = $licensed   <- company license gate');
    _log('  in navBarModules       = $inNavBar');
    _log('  in moreListModules     = $inMoreList   <- what the More page shows');
    _log('  navBarModules  = ${navBarModules.map((m) => m.name).toList()}');
    _log('  moreListModules = ${moreListModules.map((m) => m.name).toList()}');
    _log('  _allAllowedModules = '
        '${_allAllowedModules.map((m) => m.name).toList()}');
    _log('-----------------------------------------------------------');
  }

  // ✅ MODIFIED: Add license check
  void _getNavBarModulesFromReference({
    required List<Modules> referenceModulesList,
  }) {

    for (Modules module in referenceModulesList) {
      bool isAllowed = _allAllowedModules.contains(module);
      bool notInNavBar = !navBarModules.contains(module);
      bool isLicensed = _isModuleLicensed(module); // ✅ ADD LICENSE CHECK


      // ✅ MODIFIED: Only add if licensed
      if (isAllowed && notInNavBar && isLicensed) {
        navBarModules.add(module);
      } else if (!isLicensed && isAllowed) {
      }
    }
  }

  void _addSecondaryModulesIfNeeded() {

    for (int i = 0;
    i < NavBarConstantModules.secondaryNavBarItems.length &&
        navBarModules.length < 4;
    i++) {
      Modules module = NavBarConstantModules.secondaryNavBarItems[i];

      // ✅ ADD: Check license before adding
      if (_allAllowedModules.contains(module) &&
          !navBarModules.contains(module) &&
          _isModuleLicensed(module)) {
        navBarModules.add(module);
      }
    }

    navBarModules.remove(Modules.events);
  }

  // ✅ MODIFIED: Updated to include ALL allowed modules
  void _getMoreListModules() {

    // First add modules from secondaryNavBarItems (maintains order)
    for (Modules module in NavBarConstantModules.secondaryNavBarItems) {
      if (!navBarModules.contains(module) &&
          _allAllowedModules.contains(module) &&
          _isModuleLicensed(module)) { // ✅ ADD LICENSE CHECK
        moreListModules.add(module);
      }
    }

    // ✅ ADD: Then add any remaining allowed AND licensed modules
    for (Modules module in _allAllowedModules) {
      if (!navBarModules.contains(module) &&
          !moreListModules.contains(module) &&
          module != Modules.more &&
          module != Modules.home &&
          _isModuleLicensed(module)) { // ✅ ADD LICENSE CHECK
        moreListModules.add(module);
      }
    }

  }

  /// Emits the current field snapshot so BlocBuilder rebuilds. Replaces the
  /// GetxController `update()` call the original used.
  void _publish() {
    if (isClosed) return;
    emit(NavBarLoaded(
      navBarModules: List.unmodifiable(navBarModules),
      moreListModules: List.unmodifiable(moreListModules),
      isLoadingModules: isLoadingModules,
    ));
  }
}
