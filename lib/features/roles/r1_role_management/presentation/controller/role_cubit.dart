/// Module: roles / r1_role_management / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: role_cubit.dart
/// Purpose: Declares `RoleCubit`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - Time Tracker QA KP-TT-001: [RoleCubit.newRoleDefaults]
/// — a new role starts with every Time Tracker switch OFF.

import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
// REPLACED 30/8/2026: path_provider — the only call was the
// getApplicationDocumentsDirectory() in exportRolesToCsv, now behind
// ExportDirectory.
// RE-ADDED 8/9/2026: getTemporaryDirectory(), where the phone export stages the
// CSV before handing it to the system save sheet. The user-visible destination
// is still ExportDirectory's business, not path_provider's.
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/export_directory.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';

import 'package:knowticed_plus/core/network/api_constants.dart' hide FirebaseCollections;
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'dart:ui' as ui;
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
part './role_state.dart';

/// App-wide shared RoleCubit instance.
///
/// Moved here from role_responsive_page.dart so the many non-UI callers
/// (login, drawer, nav bar, active directory, system logs, user management…)
/// depend on the controller library instead of a UI page. Top-level variables
/// are lazily initialised in Dart, so this is only constructed on first use.
RoleCubit roleCubit = RoleCubit();

class RoleCubit extends Cubit<RoleState> {
  RoleCubit() : super(RoleInitial()) {
  }

  /// Function Name: [emitSafely]
  ///
  /// Purpose: Publish [state] only while this cubit is still open.
  ///
  /// Lifecycle note: this cubit drives long `async` flows (role add / select /
  /// delete, permission preload, image pick) that `await` Firestore. Navigating
  /// away mid-flight closes the cubit while those futures are still in the air,
  /// and the completion path then called `emit` on a closed cubit — a thrown
  /// `StateError`. Every emit in this feature (cubit, its extensions and the
  /// widgets that used to call `controller.emit` directly) goes through here,
  /// so the guard cannot be forgotten at a new call site.
  ///
  /// Parameters:
  /// - [state]: The state to publish.
  ///
  /// Returns: [void]
  void emitSafely(RoleState state) {
    if (isClosed) return;
    emit(state);
  }

  Map<String, Map<String, bool>> modulePermissions = {};
  bool isActive = true;
  /// Cache for role permissions to avoid reloading
  final Map<String, Map<String, List<String>>> _rolePermissionsCache = {};

  void toggleActiveStatus(bool value) {
    isActive = value;
    emitSafely(RoleModuleSelected());
  }

  RoleRepository roleRepository = RoleRepository();

  /// Single owner of the picker plugins (§16/§20) — the cubit never touches
  /// `ImagePicker` / `FilePicker` directly.
  final MediaPickerService mediaPickerService = MediaPickerService();

  File? roleImage;
  TextEditingController roleNameController = TextEditingController();
  TextEditingController roleNameControllerAr = TextEditingController();
  TextEditingController roleDescriptionController = TextEditingController();
  TextEditingController roleDescriptionControllerAr = TextEditingController();

  List<String> selectedModules = [];

  RoleStatus selectedRoleStatus = RoleStatus.all;
  List<RoleHistoryModel> roles = [];
  List<RoleHistoryModel> filteredRoles = [];
  RoleHistoryModel? selectedRole;
  TextEditingController searchController = TextEditingController();
  ModulesCubit modulesCubit = ModulesCubit();
  bool isEditing = false;

  /// ADDED 28/9/2026 — the Restricted Location allow-list being edited for
  /// this role: ISO country codes, picked on the third page of the role editor
  /// under the Restricted Location switch (`settings_switches_page.dart`).
  /// Saved with the role (see `RoleRepository.ROLE_RESTRICTED_LOCATIONS`) and
  /// enforced for its employees by `RestrictedLocationGuard`.
  List<String> restrictedCountryCodes = <String>[];

  /// Ticks / unticks one country in [restrictedCountryCodes].
  void toggleRestrictedCountry(String code) {
    if (!restrictedCountryCodes.remove(code)) {
      restrictedCountryCodes.add(code);
    }
    emitSafely(RoleSwitchToggled());
  }

  final List<String> availableModules = [
    'services',
    'services_app',
    'messages',
    'inventory',
    'settings',
    'qiyas',
    'knowledge_hub',
    'employees',
    'tasks',
    'events',
    'notes',
    'requests',
    'tracking',
    'database_builder',
    'roles',
    'hr',           // ✅ ADDED
    'crm',          // ✅ ADDED
    'notification', // ✅ ADDED
    // 'grc' was missing here while the module-selection UI offered it from
    // getDemoActiveModules(). _loadAdminRestrictions() only walks THIS list, so
    // no GRC template was ever fetched, isPermissionAllowedByAdmin('grc', …)
    // default-denied every key, and updateRole() reported every enabled GRC
    // permission as "restricted by administrator" with no switch able to clear
    // it. Same failure mode as `form_builder` — see [ModuleNameAliases].
    'grc',
    // ADDED 7/10/2026 — To-Do. Same failure mode as 'grc' above: absent from
    // this list, its `Demo_Permissions` template was never loaded and every
    // To-Do switch was default-denied.
    'todo',
    // ADDED 8/10/2026 — Time Tracker, same reason as 'todo' above.
    'time_tracker',
  ];

  /// The one name this class uses for a module, whatever spelling it arrived
  /// in. See [ModuleNameAliases] for why the spellings differ at all.
  static String canonicalModuleName(String moduleName) =>
      ModuleNameAliases.canonical(moduleName);

  Map<String, Map<String, bool>> _adminRestrictions = {};

  String _getCompanyId() {
    try {
      String baseUrl = getBaseUrl('');
      String companyId = baseUrl
          .replaceAll('Demo/', '')
          .replaceAll('/', '')
          .trim();

      return companyId.isNotEmpty ? companyId : '';
    } catch (e) {
      return '';
    }
  }

  Future<void> getUnDeletedRoles() async {
    emitSafely(RoleLoading()); // Show loading state

    Either<FirebaseFailure, dynamic> result =
    await roleRepository.getUnDeletedRoles();

    if (result.isLeft()) {
      emitSafely(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
      return;
    }

    roles = result.getOrElse(() => []);
    searchController.clear();
    filterRoles(); // This filters but doesn't emit yet

    // RoleLoading must never be the last state this method leaves behind: the
    // roles home renders a spinner for it, so a throw between here and the
    // final emit used to strand that page on a spinner forever (reported after
    // "save for later" returned to the home). The two enrichment steps below
    // are best-effort — the roles themselves are already in hand.
    try {
      await _loadAdminRestrictions();

      // ✅ Preload ALL permissions before showing roles
      await preloadAllRolePermissions();
    } catch (e, stackTrace) {
      debugPrint('getUnDeletedRoles: enrichment failed: $e\n$stackTrace');
    }

    // ✅ NOW emit fetched after everything is ready
    emitSafely(RoleFetched());
  }

  /// Preload permissions for all filtered roles
  Future<void> preloadAllRolePermissions() async {
    if (filteredRoles.isEmpty) {
      return;
    }

    await Future.wait(
        filteredRoles.map((role) => _preloadRolePermissions(role))
    );

  }

  Future<void> _preloadRolePermissions(RoleHistoryModel role) async {
    if (_rolePermissionsCache.containsKey(role.roleId)) return;

    // Join a load already running for this role instead of starting another.
    final Future<void>? running = _preloadsInFlight[role.roleId];
    if (running != null) return running;

    // BLOCK BODY ON PURPOSE (fixed 21/9/2026): `Map.remove` returns the value
    // it removed — this very future — and `whenComplete` waits on a Future its
    // callback returns. The arrow form `() => _preloadsInFlight.remove(...)`
    // therefore made `load` wait on itself forever, which hung
    // `getUnDeletedRoles` and with it sign-in (`LoginController.getRoles`).
    final Future<void> load =
        _fetchRolePermissionsIntoCache(role).whenComplete(() {
      _preloadsInFlight.remove(role.roleId);
    });
    _preloadsInFlight[role.roleId] = load;
    return load;
  }

  Future<void> _fetchRolePermissionsIntoCache(RoleHistoryModel role) async {

    // Inside the try as well: this runs under a Future.wait, so anything that
    // escapes here fails the whole batch and aborts getUnDeletedRoles before
    // it can emit RoleFetched. One unreadable role must not cost the list.
    try {
      final activeModuleStrings = modulesCubit.getRoleActiveModules(role);

      if (activeModuleStrings.isEmpty) {
        _rolePermissionsCache[role.roleId] = {};
        return;
      }

      var result = await roleRepository.getAllRolePermissions(
        roleId: role.roleId,
        selectedModules: activeModuleStrings,
      );

      if (result.isRight()) {
        Map<String, Map<String, dynamic>> allPermissions = result.getOrElse(() => {});
        Map<String, List<String>> rolePermissions = {};

        for (String moduleName in activeModuleStrings) {
          List<String> activePermissions = [];

          if (allPermissions.containsKey(moduleName)) {
            Map<String, dynamic> moduleData = allPermissions[moduleName]!;

            moduleData.forEach((key, value) {
              if (key != 'Role_Id' && key != 'timestamps') {
                bool isActive = false;

                if (value is List && value.isNotEmpty) {
                  var lastValue = value.last;
                  isActive = (lastValue == true || lastValue == 1 || lastValue == '1');
                } else if (value is bool) {
                  isActive = value;
                }

                if (isActive) {
                  activePermissions.add(_formatPermissionNameForDisplay(key));
                }
              }
            });
          }

          rolePermissions[moduleName] = activePermissions;
        }

        _rolePermissionsCache[role.roleId] = rolePermissions;
      } else {
        _rolePermissionsCache[role.roleId] = {};
      }
    } catch (e) {
      _rolePermissionsCache[role.roleId] = {};
    }
  }

  Map<String, List<String>>? getRolePermissions(String roleId) {
    return _rolePermissionsCache[roleId];
  }

  void clearPermissionsCache() {
    if (_rolePermissionsCache.isNotEmpty) {
      _rolePermissionsCache.clear();
    }
  }

  String _formatPermissionNameForDisplay(String permissionKey) {
    return permissionKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  /// Function Name: [_modulesNeedingAdminTemplate]
  ///
  /// Purpose: Every module an admin template must be loaded for.
  ///
  /// WHY NOT JUST [availableModules]: that list is hand-maintained, while the
  /// module-selection UI offers whatever `getDemoActiveModules()` returns. When
  /// the two drift — as they did for `grc` — the missing module gets no
  /// template, `isPermissionAllowedByAdmin` default-denies every one of its
  /// keys, and the role becomes unsaveable with an error no switch can clear.
  /// Taking the union means enabling a module in the admin dashboard is enough;
  /// nobody has to remember to edit a second list here.
  ///
  /// Returns: [List<String>] canonical module names, de-duplicated.
  List<String> _modulesNeedingAdminTemplate() {
    final Set<String> names = <String>{};

    for (final String m in availableModules) {
      names.add(canonicalModuleName(m));
    }

    // Best-effort: this reads `roles`, which is already populated by the time
    // [_loadAdminRestrictions] runs, but a throw here must not cost us the
    // hand-maintained list above.
    try {
      for (final String m in getDemoActiveModules()) {
        names.add(canonicalModuleName(m));
      }
    } catch (e) {
      debugPrint('_modulesNeedingAdminTemplate: demo-active modules unavailable: $e');
    }

    return names.toList();
  }

  Future<void> _loadAdminRestrictions() async {
    // Reset before each load so a previously failed attempt does not leave the
    // gate permanently closed after a successful retry, and a previously
    // successful one does not mask a new failure.
    _adminRestrictionsLoaded = true;
    adminRestrictionsError = null;

    try {
      String companyId = _getCompanyId();

      for (String moduleName in _modulesNeedingAdminTemplate()) {
        // Every spelling this module is known by, canonical first. The
        // `Demo_Permissions` document is keyed by whatever the company wrote,
        // so a template stored under `form_builder` has to be found when we
        // ask for `services_app` — otherwise the module reads as having no
        // template at all and default-deny blocks every one of its
        // permissions. See [ModuleNameAliases].
        final List<String> spellings = ModuleNameAliases.spellingsOf(moduleName);

        Either<FirebaseFailure, Map<String, bool>>? result;
        for (final String spelling in spellings) {
          result = await roleRepository.getAdminRestrictionsForModule(
            companyId: companyId,
            moduleName: spelling,
          );

          // Stop at the first spelling that actually returned a template; a
          // Right({}) means "this key is not in the document", so keep looking.
          if (result.isRight() &&
              result.getOrElse(() => <String, bool>{}).isNotEmpty) {
            break;
          }
        }

        if (result!.isRight()) {
          Map<String, bool> restrictions = result.getOrElse(() => {});

          if (restrictions.isNotEmpty) {
            // Stored under the CANONICAL name whichever spelling found it.
            _adminRestrictions[moduleName] = restrictions;
          }
        } else {
          // A per-module read failure means we do not know what this company
          // is allowed to grant, so the whole load is treated as failed rather
          // than leaving the module silently unrestricted.
          _adminRestrictionsLoaded = false;
          adminRestrictionsError =
              result.fold((FirebaseFailure l) => l.errMessage, (_) => null);
        }
      }
    } catch (e) {
      // Previously this catch was empty with every log commented out, so a
      // failed load left _adminRestrictions empty and the gate below allowed
      // everything.
      _adminRestrictionsLoaded = false;
      adminRestrictionsError = e.toString();
    }

    if (!_adminRestrictionsLoaded) {
      // Surface it: the permission UI is now default-deny, and without this
      // the user would just see every toggle blocked with no explanation.
      emitSafely(RoleError(
        'Could not load the administrator permission template'
        '${adminRestrictionsError == null ? '' : ': $adminRestrictionsError'}. '
        'Permission editing is restricted until it loads.',
      ));
    }
  }

  /// Whether the admin permission template loaded successfully.
  ///
  /// When `false`, [isPermissionAllowedByAdmin] denies everything — see the
  /// comment there.
  bool _adminRestrictionsLoaded = true;

  /// Message from the last failed admin-restrictions load, if any.
  String? adminRestrictionsError;

  /// Function Name: [isPermissionAllowedByAdmin]
  ///
  /// Purpose: Gate a single permission against the company's admin template.
  ///
  /// SECURITY (default-deny): every branch here used to `return true` —
  /// an unloaded template, an unknown module and an unknown permission key all
  /// granted the permission. Combined with the swallowed load error above, a
  /// Firestore hiccup silently unlocked every permission in the editor. All
  /// three now deny.
  ///
  /// Operational note: this makes the editor strict. A company whose
  /// `Demo_Permissions` template is missing entries will see those permissions
  /// blocked rather than open.
  ///
  /// Parameters:
  /// - [moduleName]: Module the permission belongs to.
  /// - [permissionKey]: The permission being checked.
  ///
  /// Returns: [bool] `true` only when the template explicitly allows it.
  bool isPermissionAllowedByAdmin(String moduleName, String permissionKey) {
    if (!_adminRestrictionsLoaded) return false;

    // Canonical first, raw second: the template is stored under the canonical
    // name by [_loadAdminRestrictions], but a caller may still hand us the
    // stored spelling (`form_builder`) — see [_moduleNameAliases].
    final Map<String, bool>? moduleRestrictions =
        _adminRestrictions[canonicalModuleName(moduleName)] ??
            _adminRestrictions[moduleName];
    if (moduleRestrictions == null) return false;

    return moduleRestrictions[permissionKey] == true;
  }

  List<String> getBlockedPermissionsForModule(String moduleName) {
    if (!_adminRestrictions.containsKey(moduleName)) {
      return [];
    }

    Map<String, bool> moduleRestrictions = _adminRestrictions[moduleName]!;

    return moduleRestrictions.entries
        .where((entry) => entry.value == false)
        .map((entry) => entry.key)
        .toList();
  }

  /// Fills [modulePermissions] for every module a saved role has selected.
  ///
  /// REWRITTEN 29/8/2026 — a resumed DRAFT opened its permission page with no
  /// switches at all. Two faults, both of which this rewrite removes:
  ///
  ///  1. DESTRUCTIVE. The old body cleared `modulePermissions` on entry and
  ///     then went to Firestore. If any of those awaits threw or never came
  ///     back, the map stayed empty for the rest of the session — every
  ///     ModuleSwitchesBuilder short-circuits to SizedBox.shrink() when its
  ///     module has no bucket, so the page rendered blank. It is now built in
  ///     a LOCAL map and published in one assignment at the end, so a failure
  ///     leaves the previous contents alone instead of wiping them.
  ///  2. NOT GUARANTEED. Only the admin branch backfilled missing modules with
  ///     their defaults. The non-admin branch seeds `{}` for a module and then
  ///     adds only admin-allowed keys, so a module could finish EMPTY — a
  ///     present-but-empty bucket hides the switches exactly like a missing
  ///     one. The backfill is now a single pass at the end, after every branch,
  ///     so no selected module can end up without permissions.
  ///
  /// This is why picking a fresh module in the grid always worked while the
  /// draft's own modules did not: [selectModule] fills that one module from
  /// [_getDefaultPermissionsForModule] directly and never went through here.
  Future<void> _loadAllModulePermissions(RoleHistoryModel role) async {
    String roleId = role.roleId;
    // Normalised on the way in (23/8/2026): a document listing `form_builder`
    // used to land in a `modulePermissions` bucket no switch page could reach,
    // because the pages key themselves by [moduleEnumToString]. See
    // [ModuleNameAliases].
    final Set<String> modulesToLoadSet = role.currentSelectedModules
        .map(canonicalModuleName)
        .toSet();
    // ADDED 29/8/2026: settings is mandatory and its switches live on their own
    // page; guarantee it is always loaded so those switches render for a
    // resumed draft even if the saved document omitted it from the module list.
    modulesToLoadSet.add('settings');
    List<String> modulesToLoad = modulesToLoadSet.toList();

    // Built up here, assigned to the field only once at the very end.
    final Map<String, Map<String, bool>> loaded = <String, Map<String, bool>>{};

    String? currentUserEmail;
    try {
      currentUserEmail = AppControllers.employee.employeeEntity?.email;
    } catch (e, stackTrace) {
      // Not fatal — the backfill below covers every module with its defaults
      // when the email is unavailable. Recorded rather than swallowed (§11.5).
      debugPrint('_loadAllModulePermissions: employee lookup failed: $e\n$stackTrace');
    }

    if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
      final bool isCurrentUserAdmin =
          roleRepository.isCompanyAdminByEmail(currentUserEmail);

      if (isCurrentUserAdmin) {
        Either<FirebaseFailure, Map<String, Map<String, bool>>> adminResult =
            await roleRepository.getAdminPermissions(roleId);

        if (adminResult.isRight()) {
          // A missing or empty admin document — the usual case for a DRAFT —
          // simply contributes nothing here; the backfill supplies defaults.
          loaded.addAll(adminResult.getOrElse(() => {}));
        }
      } else {
        Either<FirebaseFailure, Map<String, Map<String, dynamic>>> result =
            await roleRepository.getAllRolePermissions(
          roleId: roleId,
          selectedModules: modulesToLoad,
        );

        if (result.isRight()) {
          Map<String, Map<String, dynamic>> allPermissions =
              result.getOrElse(() => {});

          for (String moduleName in modulesToLoad) {
            if (!allPermissions.containsKey(moduleName)) continue;

            Map<String, dynamic> moduleData = allPermissions[moduleName]!;
            Map<String, bool> stored = <String, bool>{};

            moduleData.forEach((key, value) {
              if (key == 'Role_Id' || key == 'timestamps') return;
              if (!isPermissionAllowedByAdmin(moduleName, key)) return;

              if (value is List && value.isNotEmpty) {
                var lastValue = value.last;
                bool boolValue = false;

                if (lastValue is bool) {
                  boolValue = lastValue;
                } else if (lastValue == true ||
                    lastValue == 'true' ||
                    lastValue == 1) {
                  boolValue = true;
                }

                stored[key] = boolValue;
              } else if (value is bool) {
                stored[key] = value;
              }
            });

            // An empty result is dropped rather than stored: a bucket that
            // exists but holds nothing hides the module's switches, so it is
            // left for the backfill to fill with defaults.
            if (stored.isNotEmpty) {
              loaded[moduleName] = stored;
            }
          }
        }
      }
    }

    // ── THE GUARANTEE ───────────────────────────────────────────────────
    // Whatever happened above — admin or not, document found, missing, empty
    // or refused — every selected module ends with a real set of switches,
    // the same defaults the create flow uses.
    for (String moduleName in modulesToLoad) {
      final Map<String, bool>? existing = loaded[moduleName];
      if (existing == null || existing.isEmpty) {
        loaded[moduleName] = await _getDefaultPermissionsForModule(moduleName);
      } else {
        // ADDED 26/9/2026 (form bug report #28): a role saved BEFORE a
        // permission was added to the template (e.g. Form Builder's
        // "Create Group Permissions") never has that key in its stored
        // document, so ModuleSwitchesBuilder had nothing to bind a switch to
        // and the row vanished. Backfill every key the admin template allows
        // but the role is missing, defaulted to `false` — this grants nothing,
        // it only makes the switch appear so the admin can turn it on.
        final Map<String, bool> defaults =
            await _getDefaultPermissionsForModule(moduleName);
        defaults.forEach((key, _) {
          existing.putIfAbsent(key, () => false);
        });
      }
    }

    modulePermissions = loaded;
    emitSafely(RolePermissionLoaded());
  }

  Future<void> ensureSettingsSelected() async {
    if (!selectedModules.contains('settings')) {
      selectedModules.add('settings');
      if (!modulePermissions.containsKey('settings')) {
        modulePermissions['settings'] = await _getDefaultPermissionsForModule('settings');
      }
      emitSafely(RoleModuleSelected());
    } else {
    }
  }

  Future<void> fixQiyasPermissions(String roleId) async {

    var result = await roleRepository.fixCorruptedQiyasDocument(roleId);

    result.fold(
          (failure) {
        emitSafely(RoleError(failure.errMessage));
      },
          (success) {
        getUnDeletedRoles();
        if (selectedRole != null) {
          var updatedRole = roles.firstWhere((r) => r.roleId == roleId);
          selectRole(updatedRole);
        }
        emitSafely(RolePermissionUpdated());
      },
    );
  }

  Future<void> initAddingRoleController() async {
    isEditing = false;
    isActive = true;
    roleImage = null;
    roleNameController.clear();
    roleNameControllerAr.clear();

    roleDescriptionController.clear();
    roleDescriptionControllerAr.clear();
    selectedModules = [];
    modulePermissions = {};
    restrictedCountryCodes = <String>[];

    await ensureSettingsSelected();
  }

  /// Function Name: [pruneRetiredPermissions]
  ///
  /// Purpose: Force every permission key the admin template does not know about
  ///          to `false`, so a save cannot be blocked by a key no switch shows.
  ///
  /// WHY: a module's permission set changes over time. A role saved under the
  /// old set keeps those keys in its permission document, and
  /// [loadAllModulePermissions] reads them straight back into
  /// [modulePermissions] — still `true`. The editor renders the NEW set, so
  /// those stale keys are invisible, yet the violation scan below sees them as
  /// `true` and not allowed, and reports them as "restricted by administrator".
  /// The user then cannot clear the error: every switch they can reach belongs
  /// to a different key. GRC hit exactly this when its 4 placeholder keys were
  /// replaced by the real 32.
  ///
  /// A key ABSENT from the template is retired, not restricted — drop it. A key
  /// PRESENT and `false` is a real restriction and still blocks the save.
  ///
  /// Only prunes modules whose template actually loaded and is non-empty;
  /// otherwise a failed read would silently wipe every permission.
  ///
  /// Returns: [List<String>] the "module.key" pairs that were dropped.
  List<String> pruneRetiredPermissions() {
    if (!_adminRestrictionsLoaded) return const <String>[];

    final List<String> dropped = <String>[];

    for (final String moduleName in selectedModules) {
      final Map<String, bool>? perms = modulePermissions[moduleName];
      if (perms == null) continue;

      final Map<String, bool>? template =
          _adminRestrictions[canonicalModuleName(moduleName)] ??
              _adminRestrictions[moduleName];
      if (template == null || template.isEmpty) continue;

      for (final String permKey in perms.keys.toList()) {
        if (!template.containsKey(permKey) && perms[permKey] == true) {
          perms[permKey] = false;
          dropped.add('$moduleName.$permKey');
        }
      }
    }

    if (dropped.isNotEmpty) {
      debugPrint('pruneRetiredPermissions: dropped ${dropped.length} retired '
          'permission(s): ${dropped.join(', ')}');
    }

    return dropped;
  }

  Future<void> addNewRole() async {

    // Retired keys first: they are invisible in the editor, so letting them
    // reach the scan below produces an error the user cannot clear.
    pruneRetiredPermissions();

    bool hasViolations = false;
    List<String> violations = [];

    for (String moduleName in selectedModules) {
      if (modulePermissions.containsKey(moduleName)) {
        Map<String, bool> modulePerms = modulePermissions[moduleName]!;

        modulePerms.forEach((permKey, permValue) {
          if (permValue == true && !isPermissionAllowedByAdmin(moduleName, permKey)) {
            hasViolations = true;
            violations.add("$moduleName.$permKey");
          }
        });
      }
    }

    if (hasViolations) {
      for (String violation in violations) {
      }

      emitSafely(RoleError(
          "Cannot create role: The following permissions are restricted by administrator:\n${violations.join('\n')}"
      ));
      return;
    }

    Either<Failure, dynamic> result = await roleRepository.addNewRole(
      selectedModules: selectedModules,
      roleName: roleNameController.text,
      roleNameAr: roleNameControllerAr.text,
      status: isActive ? RoleStatus.active : RoleStatus.inactive,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      createdBy: AppControllers.employee.employeeEntity!.email!,
      roleImage: roleImage?.path,
      modulePermissions: modulePermissions,
      restrictedCountryCodes: restrictedCountryCodes,
    );

    if (result.isRight()) {

      // CLEAR SEARCH TEXT HERE
      searchController.clear();

      await initAddingRoleController();
      await getUnDeletedRoles();
      emitSafely(RoleAdded());
    } else {
      emitSafely(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
    }
  }

  Future<Map<String, bool>> _getDefaultPermissionsForModule(String moduleName) async {

    Map<String, bool> permissions = await modulesCubit.getFilteredDefaultPermissionsForModule(moduleName);

    return newRoleDefaults(moduleName, permissions);
  }

  /// Function Name: [newRoleDefaults]
  ///
  /// Purpose: ADDED 9/10/2026 (Time Tracker QA KP-TT-001, least privilege) —
  /// the switches a module starts with on a new role, from the admin
  /// [ceiling] (every allowed key = true). Time Tracker starts every allowed
  /// switch OFF (phase-1 spec "all OFF" — it used to start ALL ON, Approvals
  /// "All Departments" and Delete Location included); the admin turns on
  /// what the role needs. Other modules keep their behaviour (owner to
  /// decide — Notification shows the same pattern).
  ///
  /// Return type: [Map<String, bool>]
  static Map<String, bool> newRoleDefaults(String moduleName, Map<String, bool> ceiling) {
    if (ModuleNameAliases.canonical(moduleName) == 'time_tracker') {
      return <String, bool>{for (final String key in ceiling.keys) key: false};
    }
    return ceiling;
  }

  Future<void> selectModule(String moduleName) async {

    if (moduleName == 'settings') {
      if (!selectedModules.contains(moduleName)) {
        selectedModules.add(moduleName);
        modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
        emitSafely(RoleModuleSelected());
      } else {
      }
      return;
    }

    if (selectedModules.contains(moduleName)) {
      selectedModules.remove(moduleName);
      modulePermissions.remove(moduleName);
    } else {
      selectedModules.add(moduleName);

      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);

      if (modulePermissions[moduleName] != null && modulePermissions[moduleName]!.isNotEmpty) {
      }
    }

    await ensureSettingsSelected();

    emitSafely(RoleModuleSelected());
  }

  void updateModulePermission(String moduleName, String permission, bool value) {

    if (!modulePermissions.containsKey(moduleName)) {
      return;
    }

    if (value == true && !isPermissionAllowedByAdmin(moduleName, permission)) {
      emitSafely(RoleError(
          "Cannot enable '$permission' in module '$moduleName': This permission is restricted by the administrator."
      ));
      return;
    }

    modulePermissions[moduleName]![permission] = value;
    emitSafely(RolePermissionUpdated());
  }

  /// Function Name: [pickRoleImage]
  ///
  /// Purpose: Pick and validate the avatar attached to a role.
  ///
  /// Layering note: the picker plugin used to be instantiated here
  /// (`ImagePicker()` inside the cubit), which §16/§20 forbid. The cubit now
  /// depends on [MediaPickerService] — the single owner of `ImagePicker` /
  /// `FilePicker` — and only validates and stores the result.
  ///
  /// Parameters:
  /// - [camera]: `true` to open the camera, `false` for the gallery.
  ///
  /// Returns: [Future<void>]; the picked file lands on [roleImage] and
  /// `RoleImagePicked` is emitted, or `RoleError` carries the reason.
  Future<void> pickRoleImage({required bool camera}) async {
    try {
      final PickedFileData? picked = await mediaPickerService.pickImage(
        fromCamera: camera,
        imageQuality: 85,
      );

      // User cancelled the picker.
      if (picked == null || picked.path == null) return;

      final String extension = picked.path!.split('.').last.toLowerCase();
      const List<String> validFormats = <String>[
        'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic',
      ];
      if (!validFormats.contains(extension)) {
        if (isClosed) return;
        emitSafely(RoleError("Invalid format. Please use JPG, PNG, or WEBP"));
        return;
      }

      final File file = File(picked.path!);
      if (!await file.exists()) {
        if (isClosed) return;
        emitSafely(RoleError("Image file not found"));
        return;
      }

      final Uint8List bytes = Uint8List.fromList(picked.bytes);

      // Decode once to prove the bytes really are an image.
      try {
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        frameInfo.image.dispose();
        codec.dispose();
      } catch (_) {
        if (isClosed) return;
        emitSafely(RoleError("Invalid or corrupted image file"));
        return;
      }

      if (bytes.length > 10 * 1024 * 1024) {
        if (isClosed) return;
        emitSafely(RoleError("Image too large. Please use an image under 10MB"));
        return;
      }

      roleImage = file;
      if (isClosed) return;
      emitSafely(RoleImagePicked());
    } catch (e) {
      if (isClosed) return;
      emitSafely(RoleError("Failed to load image: $e"));
    }
  }

  updateSelectedRoleStatus(RoleStatus roleStatus) {
    selectedRoleStatus = roleStatus;
    filterRoles();
  }

  void filterRoles() {
    // REMOVE emit(RoleLoading()) from here if roles are already loaded

    filteredRoles = [];
    String searchText = searchController.text.toLowerCase().trim();

    for (var role in roles) {
      bool matchesStatus = (role.currentStatus == selectedRoleStatus ||
          selectedRoleStatus == RoleStatus.all);

      bool matchesSearch = searchText.isEmpty ||
          role.currentRoleName.toLowerCase().contains(searchText) ||
          role.currentRoleNameAr.contains(searchController.text.trim());

      if (matchesStatus && matchesSearch) {
        filteredRoles.add(role);
      }
    }

    emitSafely(RoleFiltered());

    // ADDED 21/9/2026 — a role card spins until its permissions are in
    // `_rolePermissionsCache`, but the cache was only ever filled for the roles
    // visible when `getUnDeletedRoles` ran. Change a role's status (e.g.
    // Inactive -> Active) while a status chip hides it, switch chips, and the
    // card that appears has no cache entry and nothing to load one: it spun
    // forever (bug report p.3). Load whatever the new filter reveals.
    _preloadMissingRolePermissions();
  }

  /// Role ids whose permission preload is already running, so `filterRoles`
  /// and `preloadAllRolePermissions` never fetch the same role twice.
  final Map<String, Future<void>> _preloadsInFlight = <String, Future<void>>{};

  /// Loads the permission summary for every visible role that has none yet,
  /// then rebuilds the list once. Best-effort: [_preloadRolePermissions]
  /// already caches `{}` on failure, so a card can never be left spinning.
  Future<void> _preloadMissingRolePermissions() async {
    final List<RoleHistoryModel> missing = filteredRoles
        .where((role) => !_rolePermissionsCache.containsKey(role.roleId))
        .toList();
    if (missing.isEmpty) return;

    await Future.wait(missing.map(_preloadRolePermissions));
    emitSafely(RoleFiltered());
  }

  void clearFilters() {
    searchController.clear();
    selectedRoleStatus = RoleStatus.all;
    filterRoles();
  }

  Future<void> selectRole(RoleHistoryModel role) async {
    selectedRole = role;

    // Canonicalised (23/8/2026): `updateRole` walks `selectedModules` and looks
    // each name up in `modulePermissions`, which `_loadAllModulePermissions`
    // keys canonically. A stored `form_builder` here would miss that bucket —
    // or, worse, match a stale one. See [ModuleNameAliases].
    selectedModules = role.currentSelectedModules
        .map(canonicalModuleName)
        .toSet()
        .toList();

    roleNameController.text = role.currentRoleName;
    roleNameControllerAr.text = role.currentRoleNameAr;
    roleDescriptionController.text = role.currentRoleDescription;
    roleDescriptionControllerAr.text = role.currentRoleDescriptionAr;

    roleImage = null;

    isEditing = (role.currentStatus != RoleStatus.draft);
    isActive = role.currentStatus == RoleStatus.active;

    await ensureSettingsSelected();

    await _loadAllModulePermissions(role);

    restrictedCountryCodes =
        await roleRepository.getRestrictedCountryCodes(role.roleId);

    emitSafely(RoleSelected());
  }

  String moduleEnumToString(Modules module) {
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
      case Modules.settings:
        return 'settings';
      case Modules.hr:  // ✅ ADDED
        return 'hr';
      case Modules.crm:  // ✅ ADDED
        return 'crm';
      case Modules.notification:  // ✅ ADDED
        return 'notification';
      // ADDED 13/9/2026. Without this case GRC fell through to the default
      // and answered 'employees' — so the GRC block would have read and
      // WRITTEN the employees permission document. The silent-default shape of
      // this switch is why that would never have thrown; it would just have
      // corrupted a neighbouring module's permissions.
      //
      // 'grc' matches the key the admin dashboard writes
      // (_getDefaultPermissionsForModule('grc')) and the one
      // _isModuleLicensed / _getModuleEnum already use elsewhere.
      case Modules.grc:
        return 'grc';
      case Modules.timeTracker: // ADDED 8/10/2026 — Time Tracker
        return 'time_tracker';
      default:
        return 'employees';
    }
  }

  String _moduleEnumToString(Modules module) {
    return moduleEnumToString(module);
  }

  // ───────────────────────────────────────────────────────────────────────
  // ROLE CREATION LOGIC
  //
  // Moved here from adding_new_role_methods1.dart so the "Add new role" page
  // only builds widgets. Covers text-direction detection, company licence
  // lookup (Firestore) and the module name <-> enum mapping used while
  // picking modules for a new role.
  // ───────────────────────────────────────────────────────────────────────

  /// True when [text] contains any Arabic character.
  bool containsArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  /// True when [text] contains any Latin character.
  bool containsEnglish(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);

  /// Company id parsed out of [ApiConstants.baseUri] (format: "Demo/<id>").
  String? extractCompanyId() {
    if (ApiConstants.baseUri.isEmpty) return null;
    if (ApiConstants.baseUri.contains('/')) {
      final List<String> parts = ApiConstants.baseUri.split('/');
      if (parts.length >= 2) return parts[1];
    }
    return null;
  }

  /// Modules the current company is licensed for, keyed by lowercase name.
  ///
  /// Falls back to "everything enabled" when no company id is resolvable, which
  /// preserves the previous behaviour for local/demo sessions.
  Future<Map<String, bool>> loadCompanyLicensedModules() async {
    try {
      final String? companyId = extractCompanyId();

      if (companyId == null || companyId.isEmpty) {
        return {
          'services': true, 'tasks': true, 'tracking': true,
          'inventory': true, 'messages': true, 'roles': true,
          'knowledge_hub': true, 'knowledgehub': true, 'qiyas': true,
          'grc': true, 'services_app': true, 'formbuilder': true,
          'todo': true, 'employees': true, 'events': true,
          'notes': true, 'requests': true, 'database': true,
          'notification': true, 'hr': true, 'crm': true, 'database_builder': true,
          'time_tracker': true, // ADDED 8/10/2026 — Time Tracker
        };
      }

      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.demoRequests)
          .doc(companyId)
          .get();

      if (!snapshot.exists) return {};

      final data = snapshot.data();
      if (data == null) return {};

      Map? modulesData;
      if (data['Demo_Details'] is Map &&
          (data['Demo_Details'] as Map)['Modules'] is Map) {
        modulesData = (data['Demo_Details'] as Map)['Modules'] as Map;
      } else if (data['Modules'] is Map) {
        modulesData = data['Modules'] as Map;
      }

      if (modulesData == null) return {};

      final Map<String, bool> licensedModules = {};
      for (final entry in modulesData.entries) {
        final moduleName = entry.key.toString().toLowerCase();
        final moduleData = entry.value;
        bool isLicensed = false;

        if (moduleData is Map) {
          final values = moduleData['Values'];
          if (values is List && values.isNotEmpty) {
            isLicensed = values.last == true;
          }
        } else if (moduleData is bool) {
          isLicensed = moduleData;
        } else if (moduleData is List && moduleData.isNotEmpty) {
          isLicensed = moduleData.last == true;
        }

        licensedModules[moduleName] = isLicensed;
      }

      return licensedModules;
    } catch (e) {
      return {};
    }
  }

  /// Module names selectable when creating a role.
  Future<List<String>> getAllowedModulesForRoleCreation() async {
    try {
      // Was `Get.find<ModulesCubit>()`. GetX is banned, and the lookup was
      // fragile besides: nothing registers a ModulesCubit in the locator, so
      // this threw and the whole method fell through to its catch. This cubit
      // already owns an instance — use it.
      final List<String> masterAdminModules =
          this.modulesCubit.getDemoActiveModules();
      masterAdminModules.removeWhere((m) => m == 'home' || m == 'settings');

      final Map<String, bool> companyLicensedModules =
          await loadCompanyLicensedModules();

      final List<String> allowedModules = [];
      for (final entry in companyLicensedModules.entries) {
        if (entry.value) allowedModules.add(entry.key);
      }
      return allowedModules;
    } catch (e) {
      return [];
    }
  }

  /// Maps a stored module name to its [Modules] enum.
  ///
  /// Throws for unknown names so callers can skip modules they don't render.
  /// Paired with [moduleEnumToSelectionString] — use the two together so the
  /// name -> enum -> name round trip stays consistent. Note this is
  /// deliberately NOT the inverse of [moduleEnumToString], which serialises
  /// `database` as `database_builder` for the permissions payload.
  Modules stringToModuleEnum(String moduleName) {
    // Canonical first (23/8/2026): this used to throw on `form_builder` and
    // `database_builder`, and `moduleEnumsFor` swallows the throw — so a role
    // storing either name lost the module from the editor entirely, switches
    // and all. See [ModuleNameAliases].
    switch (canonicalModuleName(moduleName)) {
      case 'services': return Modules.services;
      case 'employees': return Modules.employees;
      case 'tasks': return Modules.tasks;
      case 'todo': return Modules.todo;
      case 'notes': return Modules.notes;
      case 'events': return Modules.events;
      case 'requests': return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub': return Modules.knowledgeHub;
      case 'qiyas': return Modules.qiyas;
      case 'inventory': return Modules.inventory;
      case 'tracking': return Modules.tracking;
      case 'grc': return Modules.grc;
      case 'database_builder': return Modules.database;
      case 'messages': return Modules.messages;
      case 'services_app': return Modules.formBuilder;
      case 'roles': return Modules.roles;
      case 'settings': return Modules.settings;
      case 'notification': return Modules.notification;
      case 'crm': return Modules.crm;
      case 'time_tracker': return Modules.timeTracker; // ADDED 8/10/2026
      case 'hr': return Modules.hr;  // ✅ ADDED — was missing, so 'hr' threw and
      // the module grid in adding_new_role.dart silently skipped it.
      default: throw Exception("Unknown module: $moduleName");
    }
  }

  /// Function Name: [creatorEmployeeFor]
  ///
  /// Purpose: Resolve the employee record behind a role's `Created_By` email.
  ///
  /// Why this exists: `role_overview.dart` did this lookup inside a widget,
  /// wrapped in `try/catch` because the employee controller may not be
  /// registered yet — both forbidden in the UI layer (§11.2/§16). Callers get
  /// `null` and fall back to the raw email; no exception escapes.
  ///
  /// Parameters:
  /// - [createdBy]: The stored creator email.
  ///
  /// Returns: The matching employee entity, or `null` when unresolvable.
  dynamic creatorEmployeeFor(String createdBy) {
    if (createdBy.isEmpty) return null;
    try {
      return AppControllers.employee.getLocaleEmployee(createdBy);
    } catch (e) {
      debugPrint('creatorEmployeeFor: employee lookup failed for "$createdBy": $e');
      return null;
    }
  }

  /// Function Name: [modulePermissionsSnapshotFor]
  ///
  /// Purpose: Read the on/off state of every permission of every module a role
  /// currently holds.
  ///
  /// Why this exists: `module_permissions_widget.dart` reached through the
  /// cubit into `controller.roleRepository` and ran the query itself — a widget
  /// talking to the data layer (§16). It now awaits this instead.
  ///
  /// Parameters:
  /// - [role]: The role whose permissions to read.
  ///
  /// Returns: [Future<Map<String, Map<String, bool>>>] keyed by module name;
  /// empty on failure.
  Future<Map<String, Map<String, bool>>> modulePermissionsSnapshotFor(
    RoleHistoryModel role,
  ) async {
    final List<String> moduleNames = role.currentSelectedModules
        .map(canonicalModuleName)
        .toSet()
        .toList();
    if (moduleNames.isEmpty) return <String, Map<String, bool>>{};

    final result = await roleRepository.getAllRolePermissions(
      roleId: role.roleId,
      selectedModules: moduleNames,
    );
    if (result.isLeft()) return <String, Map<String, bool>>{};

    final Map<String, Map<String, dynamic>> allPermissions =
        result.getOrElse(() => {});
    final Map<String, Map<String, bool>> snapshot = <String, Map<String, bool>>{};

    for (final String moduleName in moduleNames) {
      final Map<String, dynamic>? moduleData = allPermissions[moduleName];
      if (moduleData == null) continue;

      final Map<String, bool> permissions = <String, bool>{};
      moduleData.forEach((key, value) {
        if (key == 'Role_Id' || key == 'timestamps') return;
        if (value is List && value.isNotEmpty) {
          final last = value.last;
          permissions[key] = (last == true || last == 1);
        } else if (value is bool) {
          permissions[key] = value;
        }
      });
      snapshot[moduleName] = permissions;
    }

    return snapshot;
  }

  /// Function Name: [employeeByEmail]
  ///
  /// Purpose: Find a loaded employee record by email, case-insensitively.
  ///
  /// Why this exists: three widgets did this with `firstWhereOrNull` on
  /// `Get.find<MainCoreEmployeeController>().allEmployeesEntities`. That
  /// extension came from `package:get` (banned) and `collection` is only a
  /// transitive dependency here, so the lookup is a plain loop and lives on the
  /// cubit rather than in the UI layer.
  ///
  /// Parameters:
  /// - [email]: The address to match.
  ///
  /// Returns: The matching employee entity, or `null`.
  dynamic employeeByEmail(String email) {
    if (email.isEmpty) return null;

    final employees = AppControllers.employee.allEmployeesEntities;
    if (employees == null) return null;

    final String needle = email.toLowerCase();
    for (final dynamic e in employees) {
      if (e.email?.toString().toLowerCase() == needle) return e;
    }
    return null;
  }

  /// Function Name: [resolveCreatedByName]
  ///
  /// Purpose: Turn a `Created_By` email into a display name for the roles table.
  ///
  /// Why this exists: the same lookup lived in `table_widget.dart` behind a
  /// `try { ... } catch (_) {}` — a swallowed error in a widget (§11.2/§11.5).
  /// It also read the locale from `Get.locale`; the caller now passes it, so no
  /// GetX dependency remains.
  ///
  /// Parameters:
  /// - [createdBy]: The stored creator email.
  /// - [isArabic]: Whether to prefer the Arabic name fields.
  ///
  /// Returns: [String] full name, or a name parsed from the email as fallback.
  String resolveCreatedByName(String createdBy, {required bool isArabic}) {
    if (createdBy.isEmpty) return '-';

    try {
      final dynamic employee = employeeByEmail(createdBy);

      if (employee != null) {
        if (isArabic) {
          final String arName = '${employee.firstNameInArabic ?? ''} '
                  '${employee.middleNameInArabic ?? ''} '
                  '${employee.lastNameInArabic ?? ''}'
              .trim();
          if (arName.isNotEmpty) return arName;
        }
        final String enName = '${employee.firstName ?? ''} '
                '${employee.middleName ?? ''} '
                '${employee.lastName ?? ''}'
            .trim();
        if (enName.isNotEmpty) return enName;
      }
    } catch (e) {
      debugPrint('resolveCreatedByName: lookup failed for "$createdBy": $e');
    }

    return _nameFromEmail(createdBy);
  }

  /// Fallback used by [resolveCreatedByName] when no employee record matches.
  String _nameFromEmail(String email) {
    if (email.isEmpty) return '-';
    if (!email.contains('@')) return email;

    final String username = email.split('@').first;
    return username
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Function Name: [formatRoleDate]
  ///
  /// Purpose: Format a role timestamp for display.
  ///
  /// Why this exists: `table_widget.dart` called `DateFormat(...).format(...)`
  /// inside a `try/catch` because the locale data may not be initialised.
  /// Formatting policy is not a widget concern (§11.2).
  ///
  /// Parameters:
  /// - [date]: The value to format; `null` renders as `-`.
  /// - [isArabic]: Selects the `ar` or `en` locale.
  ///
  /// Returns: [String] formatted date, or `-` when unavailable.
  String formatRoleDate(DateTime? date, {required bool isArabic}) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en').format(date);
    } catch (e) {
      debugPrint('formatRoleDate: locale data unavailable ($e)');
      return '-';
    }
  }

  /// Function Name: [loadActivePermissionsFor]
  ///
  /// Purpose: List the enabled permission names for one module of one role.
  ///
  /// Why this exists: `table_widget.dart` constructed its own `RoleRepository`
  /// and ran the read inside a widget-level `try/catch`, bypassing the cubit
  /// entirely (§11.2/§16). The widget now awaits this instead.
  ///
  /// Parameters:
  /// - [roleId]: Role document id.
  /// - [moduleName]: Module whose permissions to read.
  ///
  /// Returns: [Future<List<String>>] display-formatted permission names;
  /// empty on failure.
  Future<List<String>> loadActivePermissionsFor({
    required String roleId,
    required String moduleName,
  }) async {
    try {
      final result = await roleRepository.getRolePermissions(
        roleId: roleId,
        module: moduleName,
      );

      if (result.isLeft()) return const <String>[];

      final Map<String, dynamic>? moduleData = result.getOrElse(() => null);
      if (moduleData == null) return const <String>[];

      final List<String> activePermissions = <String>[];
      moduleData.forEach((key, value) {
        if (key == 'Role_Id' || key == 'timestamps') return;

        bool isActive = false;
        if (value is List && value.isNotEmpty) {
          final last = value.last;
          isActive = (last == true || last == 1 || last == '1');
        } else if (value is bool) {
          isActive = value;
        }

        if (isActive) {
          activePermissions.add(_formatPermissionNameForDisplay(key));
        }
      });

      return activePermissions;
    } catch (e, stackTrace) {
      debugPrint('loadActivePermissionsFor($roleId/$moduleName) failed: $e\n$stackTrace');
      return const <String>[];
    }
  }

  /// Function Name: [exportRolesToCsv]
  ///
  /// Purpose: Write a generated CSV payload somewhere the user can open it.
  ///
  /// Why this exists: `export_role_widget.dart` performed the filesystem write
  /// inside the widget behind a `try/catch` (§11.2). The widget now supplies
  /// the rendered CSV text and reacts to the result.
  ///
  /// FIXED 30/8/2026 — reported as "export in roles does not export". It did:
  /// this wrote to `getApplicationDocumentsDirectory()`, which under
  /// `com.apple.security.app-sandbox` is the container's Documents folder, NOT
  /// `~/Documents`. The write succeeded, the success dialog played, and the file
  /// sat in `~/Library/Containers/com.example.knowticedPlus/Data/Documents/`
  /// where nobody looks. [ExportDirectory.resolve] now picks the real Downloads
  /// folder, the same one the Knowledge Hub download uses.
  ///
  /// The UTF-8 BOM went in at the same time. Role names carry Arabic
  /// (`currentRoleNameAr`), and Excel reads a BOM-less UTF-8 CSV as the local
  /// codepage — the Arabic columns opened as mojibake. Every other CSV writer in
  /// the app already prefixes it.
  ///
  /// FIXED 8/9/2026 — reported again as "export does not work, nothing
  /// downloads", this time on PHONES. The 30/8 fix above is desktop-only:
  ///
  /// - Android: [ExportDirectory.resolve] writes straight into
  ///   `/storage/emulated/0/Download`. Scoped storage (API 29+) forbids that,
  ///   so `File.writeAsBytes` threw `Permission denied` and the export ended on
  ///   an error SnackBar — which the export dialog's own modal barrier covered,
  ///   so from the user's side the button simply did nothing.
  /// - iOS: the write SUCCEEDED, into the app's private Documents folder. There
  ///   is no user-visible Downloads on iOS and this app does not publish its
  ///   Documents folder to the Files app, so the file existed but could not be
  ///   reached from anywhere.
  ///
  /// Both platforms now stage the CSV in the temp folder and hand it to the
  /// system save sheet through `flutter_file_dialog` — SAF on Android, the
  /// share/"Save to Files" sheet on iOS — which is exactly what the Knowledge
  /// Hub download does (`knowledge_hub_file_operations.dart`) and the one path
  /// that needs no storage permission on any Android version. The user picks
  /// the destination, so there is no "where did it go" to answer.
  ///
  /// Desktop is unchanged: real Downloads via [ExportDirectory].
  ///
  /// Parameters:
  /// - [fileName]: User-entered name; `.csv` is appended when missing.
  /// - [csvContent]: The fully rendered CSV body.
  ///
  /// Returns: [Future<Either<String, String>>] Left = error message,
  /// Right = the saved file path, or [exportCancelled] when the user dismissed
  /// the system save sheet — nothing was written and nothing went wrong, so the
  /// caller shows neither a success nor an error.
  ///
  /// MOVED 10/9/2026 — the implementation is now `CSVHelper.exportForUser`, so
  /// the phone export screens get the same fixes instead of a second copy of
  /// this method's history. This is a thin forward; the contract is unchanged.
  Future<Either<String, String>> exportRolesToCsv({
    required String fileName,
    required String csvContent,
  }) {
    return CSVHelper().exportForUser(
      fileName: fileName,
      csvContent: csvContent,
    );
  }

  /// The [Right] value [exportRolesToCsv] returns when the user dismissed the
  /// system save sheet without choosing a destination. Kept as an alias of
  /// `CSVHelper.exportCancelled` so the existing call sites read unchanged.
  static const String exportCancelled = CSVHelper.exportCancelled;

  /// Function Name: [moduleEnumsFor]
  ///
  /// Purpose: Map stored module names to [Modules], dropping names this build
  /// does not know how to render.
  ///
  /// Why this exists: [stringToModuleEnum] throws on an unknown name, so every
  /// caller wrapped it in `try/catch` — including three widgets and a page,
  /// which §11.2 forbids from containing `try`. The skip rule is a business
  /// decision, not a rendering one, so it lives here and the UI just calls this.
  ///
  /// Parameters:
  /// - [moduleNames]: Stored module names, e.g. `Current_Selected_Modules`.
  ///
  /// Returns: [List<Modules>] in input order, unknown names omitted.
  List<Modules> moduleEnumsFor(Iterable<String> moduleNames) {
    final List<Modules> result = <Modules>[];
    for (final String name in moduleNames) {
      try {
        result.add(stringToModuleEnum(name));
      } catch (e) {
        // Unknown/retired module name — not renderable, so skip it. Logged so
        // a genuinely missing case (as 'hr' once was) is still discoverable.
        debugPrint('moduleEnumsFor: skipping unknown module "$name"');
      }
    }
    return result;
  }

  /// Inverse of [stringToModuleEnum], used to test membership of
  /// [selectedModules] while the user picks modules for a new role.
  String moduleEnumToSelectionString(Modules module) {
    switch (module) {
      case Modules.services: return 'services';
      case Modules.employees: return 'employees';
      case Modules.tasks: return 'tasks';
      case Modules.todo: return 'todo';
      case Modules.notes: return 'notes';
      case Modules.events: return 'events';
      case Modules.requests: return 'requests';
      case Modules.knowledgeHub: return 'knowledge_hub';
      case Modules.qiyas: return 'qiyas';
      case Modules.inventory: return 'inventory';
      case Modules.messages: return 'messages';
      case Modules.database: return 'database';
      case Modules.formBuilder: return 'services_app';
      case Modules.grc: return 'grc';
      case Modules.tracking: return 'tracking';
      case Modules.notification: return 'notification';
      case Modules.hr: return 'hr';
      case Modules.crm: return 'crm';
      case Modules.timeTracker: return 'time_tracker'; // ADDED 8/10/2026
      case Modules.roles: return 'roles';
      case Modules.settings: return 'settings';
      default: return 'settings';
    }
  }

  updateRole() async {
    if (selectedRole == null) return;

    // Retired keys first: they are invisible in the editor, so letting them
    // reach the scan below produces an error the user cannot clear.
    pruneRetiredPermissions();

    bool hasViolations = false;
    List<String> violations = [];

    for (String moduleName in selectedModules) {
      if (modulePermissions.containsKey(moduleName)) {
        Map<String, bool> modulePerms = modulePermissions[moduleName]!;

        modulePerms.forEach((permKey, permValue) {
          if (permValue == true && !isPermissionAllowedByAdmin(moduleName, permKey)) {
            hasViolations = true;
            violations.add("$moduleName.$permKey");
          }
        });
      }
    }

    if (hasViolations) {
      emitSafely(RoleError(
          "Cannot update role: The following permissions are restricted by administrator:\n${violations.join('\n')}"
      ));
      return;
    }

    Either<Failure, dynamic> result = await roleRepository.updateRole(
      role: selectedRole!,
      status: isActive ? RoleStatus.active : RoleStatus.inactive,
      currentUserEmail: AppControllers.employee.employeeEntity!.email!,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      roleNameAr: roleNameControllerAr.text,
      roleImage: roleImage?.path,

      selectedModules: selectedModules,
      modulePermissions: modulePermissions,
      restrictedCountryCodes: restrictedCountryCodes,
    );

    if (result.isRight()) {
      searchController.clear();

      // ✅ FIX: Invalidate this role's cache so preload fetches fresh data
      _rolePermissionsCache.remove(selectedRole!.roleId);

      await getUnDeletedRoles();
      await _refreshSignedInUserPermissionsIfAffected();
      emitSafely(RoleUpdated());
    } else {
      emitSafely(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
    }
  }

  /// Function Name: [_refreshSignedInUserPermissionsIfAffected]
  ///
  /// Purpose: Reload the signed-in employee's permission cache when the role
  ///          just saved is their OWN role.
  ///
  /// ADDED 23/8/2026. `MainCoreEmployeeController` loads
  /// `_modulePermissionsCache` once at startup and nothing invalidated it when
  /// a role was edited. So an admin who switched a Social Permission off and
  /// saved kept seeing the fields it guards — Email, Academic History, Skills
  /// and Hobbies on the org-chart profile — until the app was restarted, and it
  /// looked as though the switch had not saved at all.
  ///
  /// Only the signed-in user's own role matters here: editing anyone else's
  /// role changes nothing about what THIS session may see, and the affected
  /// users pick it up when they next sign in. The role is matched by name,
  /// which is what `loadEmployeeRole` itself matches on.
  ///
  /// Best-effort: a failure to refresh must not fail the save that already
  /// succeeded, so the screens keep the permissions they had.
  Future<void> _refreshSignedInUserPermissionsIfAffected() async {
    final String? savedRoleName = selectedRole?.currentRoleName;
    if (savedRoleName == null || savedRoleName.isEmpty) return;

    if (!AppControllers.isEmployeeRegistered) return;

    final String? currentRoleName =
        AppControllers.employee.employeeEntity?.role;
    if (currentRoleName == null) return;

    if (currentRoleName.trim().toLowerCase() !=
        savedRoleName.trim().toLowerCase()) {
      return;
    }

    await AppControllers.employee.refreshRolePermissions();
  }

  deleteRole() async {
    if (selectedRole == null) {
      emitSafely(RoleError('No role selected'));
      return;
    }

    Either<FirebaseFailure, dynamic> result = await roleRepository.deleteRole(
      role: selectedRole!,
      currentUserEmail: AppControllers.employee.employeeEntity!.email!,
    );

    if (result.isRight()) {

      // CLEAR SEARCH TEXT HERE
      searchController.clear();
      _rolePermissionsCache.remove(selectedRole!.roleId);
      await getUnDeletedRoles();
      emitSafely(RoleDeleted());
    } else {
      String errorMessage = result.fold((l) => l.errMessage, (r) => 'Unknown error');
      emitSafely(RoleError(errorMessage));
    }
  }

  /// Function Name: [saveDraft]
  ///
  /// Purpose: Persist the in-progress role as a draft.
  ///
  /// Contract change: this used to be `Future<void>` and could throw — the
  /// creator email was read with `!` on two nullable hops, so a missing
  /// employee record blew up mid-save. `dialog.dart` compensated with a
  /// `try/catch` around the call, which §11.2 forbids in the UI layer. It now
  /// validates first, never throws, and reports the outcome.
  ///
  /// Returns: [Future<bool>] `true` when the draft was written; `false` after
  /// a `RoleError` has been emitted.
  Future<bool> saveDraft() async {
    final String? currentUserEmail =
        AppControllers.employee.employeeEntity?.email;

    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      emitSafely(RoleError(
        'Your account details are unavailable, so the draft was not saved.',
      ));
      return false;
    }

    if (selectedRole != null && selectedRole!.currentStatus == RoleStatus.draft) {

      Either<Failure, dynamic> result = await roleRepository.updateRole(
        role: selectedRole!,
        currentUserEmail: currentUserEmail,
        roleDescription: roleDescriptionController.text,
        roleDescriptionAr: roleDescriptionControllerAr.text,
        roleNameAr: roleNameControllerAr.text,
        roleImage: roleImage?.path,
        selectedModules: selectedModules,
        modulePermissions: modulePermissions,
        restrictedCountryCodes: restrictedCountryCodes,
      );

      if (result.isRight()) {

        // CLEAR SEARCH TEXT HERE
        searchController.clear();

        await getUnDeletedRoles();
        emitSafely(RoleDraftSaved());
        return true;
      } else {
        emitSafely(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
        return false;
      }
    } else {

      Either<Failure, dynamic> result = await roleRepository.addNewRole(
        selectedModules: selectedModules,
        roleName: roleNameController.text,
        roleNameAr: roleNameControllerAr.text,
        roleDescription: roleDescriptionController.text,
        roleDescriptionAr: roleDescriptionControllerAr.text,
        createdBy: currentUserEmail,
        roleImage: roleImage?.path,
        modulePermissions: modulePermissions,
        restrictedCountryCodes: restrictedCountryCodes,
        status: RoleStatus.draft,
      );

      if (result.isRight()) {

        // CLEAR SEARCH TEXT HERE
        searchController.clear();

        await initAddingRoleController();
        await getUnDeletedRoles();
        emitSafely(RoleDraftSaved());
        return true;
      } else {
        emitSafely(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
        return false;
      }
    }
  }

  bool isAdminAccessActive(Modules module) {
    return adminAccessModules.contains(module);
  }

  void toggleAdminAccess({required Modules module}) {
    if (adminAccessModules.contains(module)) {
      adminAccessModules.remove(module);
    } else {
      adminAccessModules.add(module);
    }
    emitSafely(RoleSwitchToggled());
  }

  bool isSectionActive(Modules module, ModulePermissionsSections section) {
    String moduleName = moduleEnumToString(module);

    if (!modulePermissions.containsKey(moduleName)) {
      return false;
    }

    if (section is ModulePermissionsSectionsPermission) {
      String sectionKey = _convertToDbFormat((section as ModulePermissionsSectionsPermission).getDataBaseName);
      return modulePermissions[moduleName]?[sectionKey] ?? false;
    }

    return false;
  }

  void toggleSectionPermissionState({
    required Modules module,
    required ModulePermissionsSections section,
  }) async {
    String moduleName = moduleEnumToString(module);
    bool currentState = isSectionActive(module, section);
    bool newState = !currentState;

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
    }

    if (section is ModulePermissionsSectionsPermission) {
      String sectionKey = _convertToDbFormat((section as ModulePermissionsSectionsPermission).getDataBaseName);

      if (newState == true && !isPermissionAllowedByAdmin(moduleName, sectionKey)) {
        emitSafely(RoleError(
            "Cannot enable this section: It is restricted by the administrator."
        ));
        return;
      }

      modulePermissions[moduleName]![sectionKey] = newState;
    }

    for (var permission in section.sectionPermissions) {
      String permissionKey = _convertToDbFormat((permission as ModulePermissionsSectionsPermission).getDataBaseName);

      if (newState == true && !isPermissionAllowedByAdmin(moduleName, permissionKey)) {
        continue;
      }

      modulePermissions[moduleName]![permissionKey] = newState;
    }

    emitSafely(RoleSwitchToggled());
  }

  bool isSwitchActive(
      Modules module,
      ModulePermissionsSections section,
      ModulePermissionsSectionsPermission permission,
      ) {
    String moduleName = moduleEnumToString(module);
    String permissionKey = _convertToDbFormat(permission.getDataBaseName);

    return modulePermissions[moduleName]?[permissionKey] ?? false;
  }

  void toggleSwitchState({
    required Modules module,
    required ModulePermissionsSections section,
    required ModulePermissionsSectionsPermission permission,
  }) async {
    String moduleName = moduleEnumToString(module);
    String permissionKey = _convertToDbFormat(permission.getDataBaseName);

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
    }

    bool currentValue = modulePermissions[moduleName]![permissionKey] ?? false;
    bool newValue = !currentValue;

    if (newValue == true && !isPermissionAllowedByAdmin(moduleName, permissionKey)) {
      emitSafely(RoleError(
          "Cannot enable '${permission.getDataBaseName}': This permission is restricted by the administrator."
      ));
      return;
    }

    modulePermissions[moduleName]![permissionKey] = newValue;

    emitSafely(RoleSwitchToggled());
  }

  String _convertToDbFormat(String displayName) {
    return displayName.trim().replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> activateDraftRole() async {

    if (selectedRole == null) {
      throw Exception("No role selected");
    }

    RoleHistoryModel updatedRole = selectedRole!.copyWith(
      status: RoleStatus.active.name,
      selectedModules: selectedModules,
    );

    Either<Failure, dynamic> result = await roleRepository.updateRole(
      role: updatedRole,
      currentUserEmail: AppControllers.employee.employeeEntity!.email!,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      roleNameAr: roleNameControllerAr.text,
      roleImage: roleImage?.path,
      selectedModules: selectedModules,
      modulePermissions: modulePermissions,
      restrictedCountryCodes: restrictedCountryCodes,
    );

    if (result.isRight()) {

      // CLEAR SEARCH TEXT HERE
      searchController.clear();

      await initAddingRoleController();
      await getUnDeletedRoles();
      await _refreshSignedInUserPermissionsIfAffected();
      emitSafely(RoleActivated());
    } else {
      emitSafely(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
    }
  }

  List<Map<String, dynamic>> getRoleHistory(RoleHistoryModel role) {
    List<Map<String, dynamic>> history = [];

    for (int i = 0; i < role.timestamps.length; i++) {
      Map<String, dynamic> historyEntry = {
        'timestamp': DateTime.fromMillisecondsSinceEpoch(role.timestamps[i]),
        'roleName': i < role.roleName.length ? role.roleName[i] : '',
        'roleNameAr': i < role.roleNameAr.length ? role.roleNameAr[i] : '',
        'roleDescription': i < role.roleDescription.length ? role.roleDescription[i] : '',
        'roleDescriptionAr': i < role.roleDescriptionAr.length ? role.roleDescriptionAr[i] : '',
        'status': i < role.status.length ? role.status[i] : '',
        'roleImage': i < role.roleImage.length ? role.roleImage[i] : '',
        'selectedModules': i < role.selectedModules.length ? role.selectedModules[i] : [],
      };
      history.add(historyEntry);
    }

    return history;
  }

  List<Map<String, dynamic>> getRoleChangesByDateRange(
      RoleHistoryModel role, DateTime startDate, DateTime endDate) {
    List<Map<String, dynamic>> changes = [];

    for (int i = 0; i < role.timestamps.length; i++) {
      DateTime changeDate = DateTime.fromMillisecondsSinceEpoch(role.timestamps[i]);
      if (changeDate.isAfter(startDate) && changeDate.isBefore(endDate)) {
        Map<String, dynamic> change = {
          'timestamp': changeDate,
          'roleName': i < role.roleName.length ? role.roleName[i] : '',
          'roleNameAr': i < role.roleNameAr.length ? role.roleNameAr[i] : '',
          'roleDescription': i < role.roleDescription.length ? role.roleDescription[i] : '',
          'roleDescriptionAr': i < role.roleDescriptionAr.length ? role.roleDescriptionAr[i] : '',
          'status': i < role.status.length ? role.status[i] : '',
          'roleImage': i < role.roleImage.length ? role.roleImage[i] : '',
          'selectedModules': i < role.selectedModules.length ? role.selectedModules[i] : [],
        };
        changes.add(change);
      }
    }

    return changes;
  }

  bool isModuleSelected(String moduleName) {
    return selectedModules.contains(moduleName);
  }

  Map<String, bool> getModulePermissions(String moduleName) {
    return Map<String, bool>.from(modulePermissions[moduleName] ?? {});
  }

  bool getPermissionValue(String moduleName, String permission) {
    return modulePermissions[moduleName]?[permission] ?? false;
  }

  void addModule(String moduleName) async {
    if (!selectedModules.contains(moduleName)) {
      selectedModules.add(moduleName);
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
      emitSafely(RoleModuleSelected());
    }
  }

  void removeModule(String moduleName) {
    if (moduleName == 'settings') {
      return;
    }

    selectedModules.remove(moduleName);
    modulePermissions.remove(moduleName);
    emitSafely(RoleModuleSelected());
  }

  void updateModulePermissions(String moduleName, Map<String, bool> permissions) {
    if (modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName]!.addAll(permissions);
      emitSafely(RolePermissionUpdated());
    }
  }

  Future<void> loadModulePermissions(String moduleName) async {
    if (selectedRole == null) return;

    String roleId = selectedRole!.currentRoleName;
    Either<FirebaseFailure, Map<String, dynamic>?> result =
    await roleRepository.getRolePermissions(roleId: roleId, module: moduleName);

    if (result.isRight()) {
      Map<String, dynamic>? permissions = result.getOrElse(() => null);
      if (permissions != null) {
        modulePermissions[moduleName] = {};
        permissions.forEach((key, value) {
          if (key != 'Role_Id' && key != 'timestamps' && value is List && value.isNotEmpty) {
            modulePermissions[moduleName]![key] = value.last == true;
          }
        });
        emitSafely(RolePermissionLoaded());
      }
    }
  }

  Future<void> saveModulePermissions(String moduleName) async {
    if (selectedRole == null || !modulePermissions.containsKey(moduleName)) return;

    String roleId = selectedRole!.currentRoleName;
    Either<FirebaseFailure, String> result = await roleRepository.updateModulePermissions(
      roleId: roleId,
      module: moduleName,
      permissions: modulePermissions[moduleName]!,
    );

    if (result.isRight()) {
      emitSafely(RolePermissionSaved());
    } else {
      emitSafely(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
    }
  }

  bool validateSelectedModules() {
    if (selectedModules.isEmpty) return false;

    for (String module in selectedModules) {
      if (!availableModules.contains(module)) {
        return false;
      }
    }

    return true;
  }

  List<String> getAvailableModules() {
    return availableModules.where((module) => !selectedModules.contains(module)).toList();
  }

  List<String> getDemoActiveModules() {
    return modulesCubit.getDemoActiveModules();
  }

  void clearAllPermissions() async {
    modulePermissions.clear();
    selectedModules.clear();
    await ensureSettingsSelected();
    emitSafely(RolePermissionsCleared());
  }

  Map<String, dynamic> exportRoleConfiguration() {
    return {
      'roleName': roleNameController.text,
      'roleNameAr': roleNameControllerAr.text,
      'roleDescription': roleDescriptionController.text,
      'roleDescriptionAr': roleDescriptionControllerAr.text,
      'selectedModules': selectedModules,
      'modulePermissions': modulePermissions,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  void importRoleConfiguration(Map<String, dynamic> config) async {
    roleNameController.text = config['roleName'] ?? '';
    roleNameControllerAr.text = config['roleNameAr'] ?? '';
    roleDescriptionController.text = config['roleDescription'] ?? '';
    roleDescriptionControllerAr.text = config['roleDescriptionAr'] ?? '';
    selectedModules = List<String>.from(config['selectedModules'] ?? []);

    if (config['modulePermissions'] != null) {
      modulePermissions.clear();
      Map<String, dynamic> permissions = config['modulePermissions'];
      permissions.forEach((module, perms) {
        modulePermissions[module] = Map<String, bool>.from(perms);
      });
    }

    await ensureSettingsSelected();

    emitSafely(RoleConfigurationImported());
  }

  Map<String, dynamic> getRoleStatistics() {
    return {
      'totalRoles': roles.length,
      'activeRoles': roles.where((r) => r.currentStatus == RoleStatus.active).length,
      'draftRoles': roles.where((r) => r.currentStatus == RoleStatus.draft).length,
      'selectedModulesCount': selectedModules.length,
      'totalPermissionsCount': modulePermissions.values
          .map((perms) => perms.length)
          .fold(0, (sum, count) => sum + count),
    };
  }

  @Deprecated('Use new architecture methods instead')
  Map<Modules, Map<ModulePermissionsSections, Set<ModulePermissionsSectionsPermission>>>
  activeSwitches = {};

  @Deprecated('Use new architecture methods instead')
  Set<Modules> adminAccessModules = {};

  @Deprecated('Use new architecture methods instead')
  Map<Modules, Set<ModulePermissionsSections>> moduleSectionsHasFullAccess = {};

  @Deprecated('Use selectModule(String) instead')
  void selectModuleEnum(Modules module) {
    String moduleName = _moduleEnumToString(module);
    selectModule(moduleName);
  }

  String? get roleName => selectedRole?.currentRoleName;
}