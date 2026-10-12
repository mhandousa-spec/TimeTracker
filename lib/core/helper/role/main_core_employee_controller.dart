/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: main_core_employee_controller.dart
/// Purpose: Declares `MainCoreEmployeeController`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.



import 'package:dartz/dartz.dart';
// ✅ FIX: must import the SAME EmployeeController class that LoginController
// registers with Get.put(). The organization_chart_module copy is a different
// class with the same name, so Get.find<EmployeeController>() threw
// "type 'EmployeeController' is not a subtype of type 'EmployeeController'"
// and employeeEntity was never set (drawer showed only Home + Settings).
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/services/restricted_location/restricted_location_guard.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/core/helper/main_helper/current_user_context.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import'package:knowticed_plus/features/roles/r4_active_directory/data/repository/main_core_employee_repository.dart';
import'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:flutter/foundation.dart';
// ADDED 9/10/2026 — one canonical name per module (Admin licenses Time
// Tracker as `tracking`, the client calls it `time_tracker`).
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';

class MainCoreEmployeeController extends GetxController with StateMixin {
  MainCoreEmployeeRepository employeeRepository = MainCoreEmployeeRepository();
  RoleRepository roleRepository = RoleRepository();





  Future<void> setCurrentEmployeeByEmail(String email) async {
    // print("🔍 Setting current employee by email: $email");

    employeeEntity = mapOfEmployeesWithEmailKey[email];
    if (employeeEntity != null) {
      // print("✅ Current employee set: ${employeeEntity!.firstName} ${employeeEntity!.lastName}");
      // print("📧 Email: ${employeeEntity!.email}");
      // print("🆔 ID: ${employeeEntity!.id}");

      // Update your constants
      Constant.emailUser = employeeEntity!.email!;
      Constant.departmentId = employeeEntity!.departmentId!;
      Constant.roleName = employeeEntity!.role!;
      Constant.idUser = employeeEntity!.id!;

      // Keep the services data layer's user context in sync (see loadData).
      CurrentUserContext.email = employeeEntity!.email;

      // ✅ CRITICAL FIX: Notify GetBuilder to update
      update(['employee_data']); // Target the specific GetBuilder
      // print("✅ Notified GetBuilder of employee data update");
    } else {
      // print("⚠️ Employee not found for email: $email");
      // print("📊 Available employees in map: ${mapOfEmployeesWithEmailKey.length}");
    }
  }

  Map<String, EmployeeEntityPro> mapOfEmployeesWithEmailKey = {};

  // Cached permissions for performance
  Map<String, Map<String, bool>> _modulePermissionsCache = {};

  /// List of all new employees fetched from Firestore (using NewEmployeeModelHistory)
  List<NewEmployeeModelHistory>? allNewEmployees;
  List<EmployeeEntityPro>? allEmployeesEntities = [];

  /// Currently focused employee, used for detailed interactions.
  NewEmployeeModelHistory? currentEmployee;
  EmployeeEntityPro? employeeEntity;

  /// Current role history model for the logged-in employee
  RoleHistoryModel? currentEmployeeRole;

  /// Controller for handling department-related functionalities.
  /// Resolved lazily on first access so construction doesn't depend on
  /// MainCoreDepartmentCubit already being registered with Get.
  late final MainCoreDepartmentCubit departmentController =
      Get.find<MainCoreDepartmentCubit>();




  Future<void> refreshEmployeeData() async {
    await getAllNewEmployees();
    update(); // notify all GetBuilder listeners
  }


  /// Fetches all employees from a specific Firestore collection and filters them by 'active' status.
  /// Returns a list of [EmployeeEntityPro] for all employees if successful, or an empty list if an error occurs.
  Future<List<EmployeeEntityPro>?> getAllNewEmployees() async {
    // print("🔵 MainCore: Starting getAllNewEmployees...");

    try {
      Either<Failure, List<NewEmployeeModelHistory>> result =
      await employeeRepository.getEmployees();

      if (result.isRight()) {
        allNewEmployees = result.getOrElse(() => []);
        EmployeeEntityController employeeEntityController =
        EmployeeEntityController();

        // print("✓ All employees list count: ${allNewEmployees!.length}");

        // Convert NewEmployeeModelHistory to EmployeeEntity
        allEmployeesEntities =
            employeeEntityController.fromHistoryModelList(allNewEmployees ?? []);

        // ✅ CRITICAL FIX: Get the current logged-in employee from EmployeeController.
        // Guard against it not being registered yet: onInit() runs at app
        // startup, before LoginController registers EmployeeController.
        if (!Get.isRegistered<EmployeeController>()) {
          return allEmployeesEntities;
        }
        final employeeController = Get.find<EmployeeController>();

        // ✅ Check if employee field is initialized
        if (employeeController.employee == null) {
          return allEmployeesEntities;
        }

        String? currentEmployeeEmail = employeeController.employee!.email?.lastOrNull;

        if (currentEmployeeEmail == null || currentEmployeeEmail.isEmpty) {
          return allEmployeesEntities;
        }


        // Populate map and find current employee.
        // ✅ FIX: one bad record (null email, missing role, …) used to throw
        // and abort the WHOLE loop, so employeeEntity was never set and the
        // drawer showed only Home + Settings. Each employee is now isolated.
        for (EmployeeEntityPro employee in allEmployeesEntities!) {
          try {
            if (employee.email == null || employee.email!.isEmpty) continue;

            mapOfEmployeesWithEmailKey[employee.email!] = employee;

            if (employee.email == currentEmployeeEmail) {
              employeeEntity = employee;

              // ✅ FIX: keep global constants in sync so features that read
              // Constant.emailUser (e.g. home calendar) get a real value.
              Constant.emailUser = employee.email ?? '';
              Constant.departmentId = employee.departmentId ?? '';
              Constant.roleName = employee.role ?? '';
              Constant.idUser = employee.id ?? '';

              // ✅ FIX: the services data layer queries Firestore with
              // CurrentUserContext.email. It was never assigned, so every
              // "Email_Requester arrayContains ''" query returned 0 docs
              // (My Requests looked empty while the chips showed counts).
              CurrentUserContext.email = employee.email;

              // Load role and initialize messaging — must not kill the loop.
              try {
                await loadEmployeeRole();
              } catch (e) {
              }

              if (Get.context != null) {
                login(Get.context!, employee.email!);
              }
            }
          } catch (e) {
            continue;
          }
        }

        if (employeeEntity == null) {
        }
      } else {
      }

      return allEmployeesEntities;
    } catch (e, stackTrace) {
      return [];
    }
  }


  /// Retrieves either the first or last name of an employee based on the provided email and a boolean flag.
  String getEmployeeNameFirstOrLast(String email, bool isFirst) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return '';

    return Get.locale.toString().contains('en')
        ? isFirst
        ? employee.firstName ?? ''
        : employee.lastName ?? ''
        : isFirst
        ? employee.firstNameInArabic ?? ''
        : employee.lastNameInArabic ?? '';
  }

  /// Function Name: [isKnownEmployee]
  ///
  /// Purpose: Whether [email] belongs to a real employee record.
  ///
  /// Added 22/8/2026. The notification inbox has to tell a message sent by a
  /// person from one raised by the system, because the two render as different
  /// cards in the design: a person's card carries an avatar chip and a Message
  /// button, the system's carries neither. Callers were inferring it by
  /// string-matching [getEmployeeName] against its "no name" sentinel, which
  /// breaks the moment that copy is translated or reworded.
  ///
  /// Parameters:
  /// - [email]: the sender's email, as stored on the notification.
  ///
  /// Returns: [bool] — false for an empty address, a system address, or any
  /// address with no employee behind it.
  bool isKnownEmployee(String email) {
    if (email.trim().isEmpty) return false;
    return mapOfEmployeesWithEmailKey[email] != null;
  }

  /// Constructs the full name of an employee based on their email.
  String getEmployeeName(String email) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return "no name";

    return Get.locale.toString().contains('en')
        ? "${employee.firstName ?? ''} ${employee.lastName ?? ''}"
        : "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}";
  }

  /// Fetches the full name of an employee in either English or Arabic based on the provided flag.
  String getEmployeeNameEnglishArabic(String email, bool isEnglish) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return '';

    return isEnglish
        ? "${employee.firstName ?? ''} ${employee.lastName ?? ''}"
        : "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}";
  }

  /// Retrieves a list of employees who are designated as 'super admins'.
  List<EmployeeEntityPro> getSuperAdmin() {
    return allEmployeesEntities
        ?.where((element) => element.role == 'super admin')
        .toList() ??
        [];
  }

  /// Retrieves the job title of an employee based on their email.
  String getEmployeeJobTitle(String email) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return "no job";

    return Get.locale.toString().contains('en')
        ? employee.title ?? 'no job'
        : employee.titleInArabic ?? 'no job';
  }

  /// Retrieves the photo URL or default avatar based on the gender of the employee.
  String getEmployeePhoto(String email) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return "assets/icons_assets/main_icons_assets/male_avatar.png";

    return employee.photo == null
        ? employee.gender == 'female'
        ? "assets/icons_assets/main_icons_assets/female_avatar.png"
        : "assets/icons_assets/main_icons_assets/male_avatar.png"
        : employee.photo!;
  }

  /// Returns the employee entity for the given email.
  EmployeeEntityPro? getLocaleEmployee(String email) {
    return mapOfEmployeesWithEmailKey[email];
  }

  /// Fetches a new employee by their email and updates the local data.
  Future<EmployeeEntityPro?> getNewEmployee(String email) async {
    // print("Checking if employee exists: ${mapOfEmployeesWithEmailKey[email].toString()}");
    return mapOfEmployeesWithEmailKey[email];
  }

  /// Retrieves the department name of an employee based on their email.
  String getEmployeeDepartmentName(String email) {
    EmployeeEntityPro? employee = allEmployeesEntities
        ?.firstWhereOrNull((element) => email == element.email);
    final String? departmentId = employee?.departmentId;
    // Missing employee OR missing/empty department id (7/10/2026: a new
    // company admin has Department_Id "" and crashed the Notifications inbox).
    if (employee == null || departmentId == null || departmentId.isEmpty) {
      return "no department";
    }
    return departmentController.getDepartmentName(
        departmentId, Get.locale.toString().contains('en'));
  }

  /// Login method for setting user preferences
  Future<void> login(BuildContext context, String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    if (employeeEntity == null) return;

    // Save to SharedPreferences
    await prefs.setString("emailRequester", employeeEntity!.email ?? '');
    await prefs.setString(
        "firstNameRequester", employeeEntity!.firstName ?? '');
    await prefs.setString("lastNameRequester", employeeEntity!.lastName ?? '');
    await prefs.setString("genderRequester", employeeEntity!.gender ?? '');
    await prefs.setString(
        "phoneRequester", employeeEntity!.mobilePhone?.phone ?? '');

    // Arabic localization
    await prefs.setString("firstNameRequesterArabic",
        employeeEntity!.firstNameInArabic ?? '');
    await prefs.setString(
        "lastNameRequesterArabic", employeeEntity!.lastNameInArabic ?? '');
    await prefs.setString(
        "jobTitleRequesterArabic", employeeEntity!.titleInArabic ?? '');

    await prefs.setString("jobTitleRequester", employeeEntity!.title ?? '');
    await prefs.setString(
        "departmentRequester", employeeEntity!.departmentId ?? '');

    // print("✓ Saved to SharedPreferences!");
    Constant.emailUser = normalizedEmail;
  }

  @override
  Future<void> onInit() async {
    await getAllNewEmployees();
    super.onInit();
  }




  /// Loads the current employee's role and permissions from the new multi-collection structure
  Future<void> loadEmployeeRole() async {
    if (employeeEntity?.role == null) {
      // print("⚠️ Employee role is null, cannot load role");
      return;
    }

    // print("Loading employee role: ${employeeEntity!.role}");

    try {
      // Find role using RoleHistoryModel
      currentEmployeeRole = roleCubit.roles.firstWhere(
            (element) => element.currentRoleName == employeeEntity!.role,
        orElse: () => throw Exception('Role not found: ${employeeEntity!.role}'),
      );

      // print("✓ Found role: ${currentEmployeeRole!.currentRoleName}");
      // print("✓ Selected modules: ${currentEmployeeRole!.currentSelectedModules}");

      // Load permissions for all selected modules
      await _loadModulePermissions();
    } catch (e) {
      // Role lookup failed — usually because roleCubit.roles is momentarily
      // empty (the roles listener fires with 0 documents before refilling).
      //
      // Previously this wiped currentEmployeeRole AND the permission cache,
      // permanently downgrading the user to "no permissions" until the next
      // full restart. A transient lookup miss must not destroy known-good
      // permissions, so we keep whatever we already had.
      if (currentEmployeeRole == null) {
        _modulePermissionsCache.clear();
      }
    }
  }

  /// Loads permissions for all modules from separate collections
  Future<void> _loadModulePermissions() async {
    if (currentEmployeeRole == null) return;

    // ✅ Use the ACTUAL role document ID, not the role name!
    String roleId = currentEmployeeRole!.roleId;
    List<String> selectedModules = currentEmployeeRole!.currentSelectedModules;

    // print("\n=== Loading Module Permissions ===");
    // print("Role Name: ${currentEmployeeRole!.currentRoleName}");
    // print("Role ID (Document ID): $roleId");
    // print("Selected Modules: $selectedModules");

    // ⚠️ Do NOT clear the cache here.
    //
    // This method is invoked several times during startup (initData step 4,
    // step 5, and again from the roles/permissions listeners). Clearing before
    // the await left the cache EMPTY for the whole duration of the Firestore
    // round-trip. Any screen that built during that window saw zero
    // permissions and silently rendered its no-permission fallback — and
    // because nothing rebuilds it afterwards, it stayed that way forever.
    // (This is what made the services page always show the "request" view.)
    //
    // Instead we build a fresh map locally and swap it in atomically once the
    // data is actually in hand, so readers always see either the previous
    // permissions or the new ones — never nothing.

    // Load permissions from each module collection
    Either<FirebaseFailure, Map<String, Map<String, dynamic>>> result =
    await roleRepository.getAllRolePermissions(
      roleId: roleId,
      selectedModules: selectedModules,
    );

    if (result.isRight()) {
      Map<String, Map<String, dynamic>> allPermissions =
      result.getOrElse(() => {});


      // print("✓ Loaded permissions for ${allPermissions.length} modules");

      // Built locally, then swapped in atomically below.
      final Map<String, Map<String, bool>> freshCache = {};

      // Process and cache permissions
      for (String module in selectedModules) {
        if (allPermissions.containsKey(module)) {
          Map<String, dynamic> moduleData = allPermissions[module]!;
          // Cache under the normalised key so lookups via _getModuleName()
          // (always lower-case) match regardless of how the module name was
          // capitalised in Firestore.
          // Canonical (9/10/2026): `tracking` and `time_tracker` share one
          // cache entry, matching the lookups in [_moduleKey].
          final String cacheKey = ModuleNameAliases.canonical(module);
          freshCache[cacheKey] = {};

          // // print("\n--- Processing module: $module ---");
          // // print("Raw module data keys: ${moduleData.keys.toList()}");

          // Extract current permissions (last value in arrays)
          moduleData.forEach((key, value) {
            if (key == 'Role_Id' || key == 'timestamps') {
          //    // print("  Skipping metadata: $key");
              return;
            }

            // Handle array values properly
            bool permissionValue = false;

            if (value is List && value.isNotEmpty) {
              var lastValue = value.last;
              permissionValue = lastValue == true || lastValue == 'true';
           //   // print("  $key: $permissionValue (from array: $value)");
            } else if (value is bool) {
              permissionValue = value;
           //   // print("  $key: $permissionValue (direct boolean)");
            } else {
              // print("  ⚠️ $key: Unexpected type ${value.runtimeType}: $value");
            }

            freshCache[cacheKey]![key] = permissionValue;
          });

          // print("✓ Cached ${freshCache[cacheKey]!.length} permissions for $module");
        } else {
          // print("⚠️ No permissions found for module: $module");
        }
      }

      // Atomic swap — readers never observe a half-built or empty cache.
      _modulePermissionsCache = freshCache;

      // TEMPORARY (13/9/2026) — remove once GRC permissions are confirmed.
      // Prints what actually landed in the cache for GRC, so a "switches are
      // all on but the UI shows nothing" report can be answered from the log
      // instead of guessed at.
      final Map<String, bool>? grcPerms = freshCache['grc'];
      if (grcPerms == null) {
        debugPrint('[grc-perm] no grc entry in cache. selectedModules='
            '$selectedModules');
      } else {
        final List<String> on = grcPerms.entries
            .where((MapEntry<String, bool> e) => e.value)
            .map((MapEntry<String, bool> e) => e.key)
            .toList();
        debugPrint('[grc-perm] ${on.length}/${grcPerms.length} enabled: '
            '${on.join(', ')}');
      }

      // Screens that already built while permissions were still loading show
      // their no-permission fallback. Without this they would never re-run
      // their permission checks. update() rebuilds GetBuilder/Obx listeners.
      update();

      // ADDED 28/9/2026 — apply the role's Restricted Location policy (the
      // switch and country list set on the role editor's third page). Not
      // awaited: the location lookup must not hold up the rest of startup;
      // the block screen appears as soon as it has an answer.
      RestrictedLocationGuard.instance.evaluate(
        roleId: roleId,
        enabled: freshCache['settings']?['Restricted_Location'] ?? false,
      );

      // print("\n=== Permission Loading Complete ===");
      // print("Total modules cached: ${_modulePermissionsCache.length}");
      _modulePermissionsCache.forEach((module, perms) {
        int trueCount = perms.values.where((v) => v == true).length;
        // print("  $module: $trueCount/${perms.length} permissions enabled");
      });
    } else {
      // print("❌ Error loading module permissions: ${result.fold((l) => l.errMessage, (r) => '')}");
    }
  }

  /// Checks if the current employee has access to a specific module
  /// Uses the new selectedModules approach instead of individual module fields
  bool hasModuleAccess(Modules module) {
    if (currentEmployeeRole == null) return false;

    // Check if module is in the role's selected modules list.
    //
    // The stored value is whatever the roles UI wrote to Firestore, which is
    // not guaranteed to be lower-case ('Services' vs 'services'). A raw
    // contains() therefore returned false for roles that clearly had the
    // module enabled — the nav bar showed the icon (it normalises with
    // toLowerCase(), see NavBarCubit._getModuleEnum) while every
    // permission check silently failed. Normalise on both sides.
    // 9/10/2026 — compared by CANONICAL name on both sides: the role stores
    // what Admin licensed (`tracking`), the enum asks for `time_tracker`; a
    // plain compare said "no access" to a company admin who had the module.
    String moduleName = _moduleKey(module);
    bool hasAccess = currentEmployeeRole!.currentSelectedModules
        .any((m) => ModuleNameAliases.canonical(m) == moduleName);

   // // print("Checking module access for ${module.name} ($moduleName): $hasAccess");
    return hasAccess;
  }

  /// ADDED 9/10/2026 — the cache / comparison key for [module]: its
  /// database name, canonicalised by [ModuleNameAliases] (lower-cased, and
  /// every stored spelling of a module mapped to one name).
  String _moduleKey(Modules module) =>
      ModuleNameAliases.canonical(_getModuleName(module));

  /// Helper method to convert Modules enum to string for database lookup
  String _getModuleName(Modules module) {
    switch (module) {
      case Modules.employees:
        return 'employees';
      case Modules.services:
        return 'services';
      case Modules.tasks:
        return 'tasks';
      case Modules.todo:
        return 'todo';
      case Modules.events:
        return 'events';
      case Modules.notes:
        return 'notes';
      case Modules.requests:
        return 'requests';
      case Modules.knowledgeHub:
        return 'knowledge_hub';
      case Modules.qiyas:
        return 'qiyas';
      case Modules.tracking:
        return 'tracking';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.database:
        return 'database_builder';
      case Modules.formBuilder:
        return 'services_app';
      case Modules.roles:
        return 'roles';
      case Modules.notification:  // ← ADD THIS LINE
        return 'notification';    // ← ADD THIS LINE
      case Modules.hr:  // ← ADD THIS LINE
        return 'hr';    // ← ADD THIS LINE
      case Modules.crm:  // ← ADD THIS LINE
        return 'crm';    // ← ADD THIS LINE
      case Modules.settings:
        return 'settings';
      // Missing until 13/9/2026. Without it GRC fell to `default: return ''`,
      // so hasModuleAccess(Modules.grc) compared the role's selected modules
      // against an empty string and always returned false — every GRC
      // permission check answered "no" no matter how the role's switches were
      // set, and the whole module rendered its no-permission fallback.
      case Modules.grc:
        return 'grc';
      // ADDED 8/10/2026 — Time Tracker. Without it every Time Tracker
      // permission check fell to '' and answered "no" (same failure as GRC).
      case Modules.timeTracker:
        return 'time_tracker';
      default:
        // Silent '' is how the GRC bug hid: an unmapped module does not throw,
        // it just loses every permission. Say so.
        debugPrint('_getModuleName: no database name for Modules.${module.name} '
            '— every permission check for it will return false.');
        return '';
    }
  }

  /// Checks if the current employee has a specific permission within a module
  bool hasSpecificPermission(Modules module, String permission) {
    if (!hasModuleAccess(module)) return false;

    String moduleName = _moduleKey(module);
    bool hasPermission = _modulePermissionsCache[moduleName]?[permission] ?? false;

   // // print("Checking permission $permission in module $moduleName: $hasPermission");
    return hasPermission;
  }

  /// Gets all permissions for a specific module
  Map<String, bool> getModulePermissions(Modules module) {
    String moduleName = _moduleKey(module);
    return Map<String, bool>.from(_modulePermissionsCache[moduleName] ?? {});
  }

  /// Async method to reload permissions for a specific module
  Future<bool> hasSpecificPermissionAsync(Modules module, String permission) async {
    if (!hasModuleAccess(module)) {
      // print("⚠️ Module ${module.name} not accessible");
      return false;
    }

    String roleId = currentEmployeeRole!.roleId;
    String moduleName = _moduleKey(module); // canonical (9/10/2026)

    // print("\n--- Checking Async Permission ---");
    // print("Module: $moduleName");
    // print("Permission: $permission");
    // print("Role ID: $roleId");

    // Check cache first
    if (_modulePermissionsCache.containsKey(moduleName)) {
      bool cachedValue = _modulePermissionsCache[moduleName]![permission] ?? false;
      // print("✓ Found in cache: $cachedValue");
      return cachedValue;
    }

    // print("Not in cache, loading from database...");

    // Load from database if not cached
    Either<FirebaseFailure, Map<String, dynamic>?> result =
    await roleRepository.getRolePermissions(
      roleId: roleId,
      module: moduleName,
    );

    if (result.isRight()) {
      Map<String, dynamic>? permissions = result.getOrElse(() => null);

      if (permissions != null) {
        // print("Loaded permissions: ${permissions.keys.toList()}");

        if (permissions.containsKey(permission)) {
          bool hasPermission = false;
          var value = permissions[permission];

          if (value is List && value.isNotEmpty) {
            hasPermission = value.last == true;
            // print("Permission value from array: ${value.last}");
          } else if (value is bool) {
            hasPermission = value;
            // print("Permission value direct: $value");
          }

          // Update cache
          _modulePermissionsCache[moduleName] ??= {};
          _modulePermissionsCache[moduleName]![permission] = hasPermission;

          // print("✓ Result: $hasPermission");
          return hasPermission;
        }

        // Permission key absent from the document -> denied (fail-closed).
        debugPrint("hasSpecificPermissionAsync: '$permission' not present on "
            "$moduleName for role $roleId; denying.");
      } else {
        debugPrint('hasSpecificPermissionAsync: no permission document for '
            '$moduleName / role $roleId; denying.');
      }
    } else {
      // Fail-closed is the right direction, but it used to be *completely*
      // silent — the only diagnostic was a commented-out print (§11.5).
      debugPrint('hasSpecificPermissionAsync: permission load failed for '
          '$moduleName / role $roleId: '
          '${result.fold((l) => l.errMessage, (r) => '')}');
    }

    return false;
  }

  /// UPDATED: Legacy method for backward compatibility - now uses new architecture
  /// This method is kept for existing code that still uses the old permission checking system
  bool isHasPermission({
    required Modules? module,
    required ModulePermissionsSectionsPermission? permission,
    required ModulePermissionsSections? section,
  }) {
    // // print("Legacy permission check - module: ${module?.name}, section: ${section?.getName}, permission: ${permission?.getDataBaseName}");
    //
    // // print("check Data grc - module: ${module?.name}, section: ${section?.getName}, permission: ${permission?.getDataBaseName}");
    if (module == null || section == null) return false;

    // For backward compatibility, we'll map the old permission system to the new one
    if (!hasModuleAccess(module)) return false;

    if (permission == null) {
      // When checking section-level permission (permission is null),
      // we need to check the section permission value in Firebase
      if (section is ModulePermissionsSectionsPermission) {
        ModulePermissionsSectionsPermission permissionInterface =
        section as ModulePermissionsSectionsPermission;

        String sectionPermissionName = permissionInterface.getDataBaseName;
       // // print("Checking section-level permission: $sectionPermissionName");

        bool hasSectionPermission = hasSpecificPermission(module, sectionPermissionName);
      //  // print("Section permission result: $hasSectionPermission");

        return hasSectionPermission;
      } else {
        // Fallback: section doesn't have permission data, just check module access
        // print("⚠️ Section doesn't implement ModulePermissionsSectionsPermission, returning true");
        return true;
      }
    }

    // Map the old permission to new permission name
    String permissionName = permission.getDataBaseName;
    return hasSpecificPermission(module, permissionName);
  }

  /// Checks if the current employee has admin access to a specific module
  bool hasAdminAccess(Modules module) {
    // In the new system, check for specific admin permissions
    return hasSpecificPermission(module, 'Admin_Access') || isSuperAdmin();
  }

  /// Gets the current role name for the logged-in employee
  String? getCurrentRoleName() {
    return currentEmployeeRole?.currentRoleName;
  }

  /// Gets the current role description for the logged-in employee
  String? getCurrentRoleDescription({bool isArabic = false}) {
    if (currentEmployeeRole == null) return null;

    return isArabic
        ? currentEmployeeRole!.currentRoleDescriptionAr
        : currentEmployeeRole!.currentRoleDescription;
  }

  /// Refreshes the employee's role permissions
  Future<void> refreshRolePermissions() async {
    await loadEmployeeRole();
    update(); // Notify listeners about the change
  }

  /// Checks if current employee is super admin
  bool isSuperAdmin() {
    return employeeEntity?.role == 'super admin';
  }

  /// Gets all available modules for the current employee
  List<Modules> getAvailableModules() {
    List<Modules> availableModules = [];

    for (Modules module in Modules.values) {
      if (hasModuleAccess(module)) {
        availableModules.add(module);
      }
    }

    return availableModules;
  }

  /// Gets the list of selected module names for the current employee
  List<String> getSelectedModuleNames() {
    return currentEmployeeRole?.currentSelectedModules ?? [];
  }

  /// Checks if a specific module name is selected for the current employee
  bool isModuleSelected(String moduleName) {
    return currentEmployeeRole?.currentSelectedModules.contains(moduleName) ?? false;
  }

  /// Clears the permission cache (useful when role changes)
  void clearPermissionCache() {
    _modulePermissionsCache.clear();
  }

  /// Gets cached permissions count for debugging
  Map<String, int> getPermissionCacheStatus() {
    Map<String, int> status = {};
    _modulePermissionsCache.forEach((module, permissions) {
      status[module] = permissions.length;
    });
    return status;
  }

  /// Force reload all permissions from database
  Future<void> forceReloadPermissions() async {
    clearPermissionCache();
    await loadEmployeeRole();
    update();
  }

  /// Batch check multiple permissions for better performance
  Future<Map<String, bool>> checkMultiplePermissions(
      Modules module,
      List<String> permissions,
      ) async
  {
    Map<String, bool> results = {};

    if (!hasModuleAccess(module)) {
      // print("⚠️ Module ${module.name} not accessible");
      for (String permission in permissions) {
        results[permission] = false;
      }
      return results;
    }

    String roleId = currentEmployeeRole!.roleId;
    String moduleName = _moduleKey(module); // canonical (9/10/2026)

    // print("\n=== Batch Permission Check ===");
    // print("Module: $moduleName");
    // print("Permissions: $permissions");
    // print("Role ID: $roleId");

    // Check if permissions are cached
    if (_modulePermissionsCache.containsKey(moduleName)) {
      // print("Using cached permissions");
      for (String permission in permissions) {
        results[permission] = _modulePermissionsCache[moduleName]![permission] ?? false;
      }
      // print("Results: $results");
      return results;
    }

    // print("Loading from database...");

    // Load from database if not cached
    Either<FirebaseFailure, Map<String, dynamic>?> result =
    await roleRepository.getRolePermissions(
      roleId: roleId,
      module: moduleName,
    );

    if (result.isRight()) {
      Map<String, dynamic>? modulePermissions = result.getOrElse(() => null);

      if (modulePermissions != null) {
        // print("Loaded module permissions");

        // Update cache
        _modulePermissionsCache[moduleName] = {};

        for (String permission in permissions) {
          if (modulePermissions.containsKey(permission)) {
            bool hasPermission = false;
            var value = modulePermissions[permission];

            if (value is List && value.isNotEmpty) {
              hasPermission = value.last == true;
            } else if (value is bool) {
              hasPermission = value;
            }

            results[permission] = hasPermission;
            _modulePermissionsCache[moduleName]![permission] = hasPermission;
            // print("  $permission: $hasPermission");
          } else {
            results[permission] = false;
            // print("  $permission: false (not found)");
          }
        }
      }
    } else {
      // print("❌ Error loading permissions");
    }

    return results;
  }


  Map<Modules,Map<ModulePermissionsSections, Set<ModulePermissionsSectionsPermission>> >  activeSwitches = {};

  Set<Modules> adminAccessModules = {};
  Map<Modules, Set<ModulePermissionsSections>> moduleSectionsHasFullAccess = {};
  void getActiveSwitches() {
    activeSwitches[Modules.services] = {};
    moduleSectionsHasFullAccess[Modules.services] = {};
    for (
    int sectionIndex = 0;
    sectionIndex < ServicePermissionsSections.values.length;
    sectionIndex++
    ) {
      moduleSectionsHasFullAccess[Modules.services]!.add(
        ServicePermissionsSections.values[sectionIndex],
      );
      for (
      int permissionIndex = 0;
      permissionIndex <
          ServicePermissionsSections
              .values[sectionIndex]
              .sectionPermissions
              .length;
      permissionIndex++
      ) {
        activeSwitches[Modules.services]!.putIfAbsent(
          ServicePermissionsSections.values[sectionIndex],
              () => {},
        );
        activeSwitches[Modules.services]![ServicePermissionsSections
            .values[sectionIndex]]!
            .add(
          ServicePermissionsSections
              .values[sectionIndex]
              .sectionPermissions[permissionIndex]
          as ModulePermissionsSectionsPermission,
        );
      }
    }

    // activeSwitches[Modules.services]![ServicePermissionsSections.requestedServices]!
    //   .remove(ServicePermissions.viewRequesters);

    //activeSwitches[Modules.services]!.remove(ServicePermissionsSections.servicesPermissions);


    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.servicesPermissions);
    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.requestedServices);
    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.requestServicePermissions);
    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.dashboardPermissions);
    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.approvalPermissions);



    /*  activeSwitches[Modules.grc]![QiyasPermissionsSections.champions]!
        .remove(Champions.removeChampion);*/
    /*    moduleSectionsHasFullAccess[Modules.grc]!
        .remove(QiyasPermissionsSections.approvals);
    moduleSectionsHasFullAccess[Modules.grc]!
        .remove(QiyasPermissionsSections.dashboard);
    activeSwitches[Modules.grc]![QiyasPermissionsSections.qiyasPermissions]!
        .remove(QiyasPermissions.bulkUpload);
    activeSwitches[Modules.grc]![QiyasPermissionsSections.qiyasPermissions]!
        .remove(QiyasPermissions.exportTable);
    activeSwitches[Modules.grc]![QiyasPermissionsSections.qiyasPermissions]!
        .remove(QiyasPermissions.assignChampion);
    activeSwitches[Modules.grc]![QiyasPermissionsSections.champions]!
        .remove(Champions.reassignChampion);

    activeSwitches[Modules.grc]![QiyasPermissionsSections.champions]!
        .remove(Champions.editEvidence);

        */
    /* moduleSectionsHasFullAccess[Modules.grc]!
        .remove(QiyasPermissionsSections.assignedEvidence);*/
  }




}

abstract class Constant {
  static String? emailUser;
  static String? departmentId;
  static String? roleName;
  static String? idUser;
}
