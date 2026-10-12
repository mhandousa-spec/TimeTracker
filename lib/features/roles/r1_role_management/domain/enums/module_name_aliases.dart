/// Module: roles / r1_role_management / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: module_name_aliases.dart
/// Purpose: One canonical name per module, and every stored spelling of it.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// The same module is written differently in different places, and the code
/// silently assumed one spelling per lookup:
///
///   * a role document's `Current_Selected_Modules` carries `form_builder`;
///   * `RoleCubit.moduleEnumToString(Modules.formBuilder)` emits `services_app`;
///   * `RoleRepository._getPermissionCollectionName` only answers to
///     `services_app`;
///   * the company template in `Demo_Permissions/{companyId}` is keyed
///     `form_builder`.
///
/// THE BUG THIS FIXES
/// ------------------
/// A role listing `form_builder` could not be saved. Its permissions loaded
/// into `modulePermissions['form_builder']` — filled from the company template,
/// so every one of them `true` — while every switch the user could see wrote to
/// `modulePermissions['services_app']`, a different bucket. `form_builder` was
/// not in `RoleCubit.availableModules`, so no admin template was ever loaded
/// under that key, and `isPermissionAllowedByAdmin` denies an unknown module by
/// default. `updateRole` then reported all fifteen permissions as "restricted
/// by administrator" — and turning every visible switch off could not clear it,
/// because none of those switches touched that bucket.
///
/// Normalising the name at every boundary collapses the buckets into one.
///
/// ADDING A MODULE: put the alias here, not in a `case` somewhere. Every lookup
/// keyed by module name should go through [canonical] first.
abstract final class ModuleNameAliases {
  const ModuleNameAliases._();

  /// Stored spelling → the name the code uses for that module.
  ///
  /// The canonical side is whatever `RoleCubit.moduleEnumToString` emits, since
  /// that is what the permission collections and the switch pages key on.
  static const Map<String, String> _aliases = <String, String>{
    'form_builder': 'services_app',
    'formbuilder': 'services_app',
    'database': 'database_builder',
    'knowledgehub': 'knowledge_hub',
    // ADDED 7/10/2026 — To-Do. Canonical `todo` matches the licence key in
    // `Demo_Requests` and the `todo_module_permissions` collection.
    'to_do': 'todo',
    'todo_list': 'todo',
    // ADDED 8/10/2026 — Time Tracker. Canonical `time_tracker` matches
    // `Demo_Permissions/{cid}.time_tracker` and the
    // `time_tracker_module_permissions` collection (FINAL SPEC §1).
    'timetracker': 'time_tracker',
    // ADDED 8/10/2026 — owner decision 17: Knowticed Admin still licenses the
    // module as `tracking` (until Amr renames it to `time_tracker`), so the
    // client reads `tracking` as Time Tracker and the module shows for
    // companies licensed in Admin today.
    'tracking': 'time_tracker',
    'time-tracker': 'time_tracker',
    'time tracker': 'time_tracker',
  };

  /// Function Name: [canonical]
  ///
  /// Purpose: The one name the code uses for a module, whatever spelling it
  ///          arrived in.
  ///
  /// Parameters:
  /// - [moduleName]: A module name from storage, the UI, or a caller.
  ///
  /// Returns: [String] the canonical name — the trimmed, lower-cased input when
  /// it has no alias.
  static String canonical(String moduleName) {
    final String key = moduleName.trim().toLowerCase();
    return _aliases[key] ?? key;
  }

  /// Function Name: [spellingsOf]
  ///
  /// Purpose: Every name a module may be stored under, canonical first.
  ///
  /// For probing a Firestore document whose keys were written by an earlier
  /// version of the app (or by hand): ask for the canonical name and fall
  /// through the aliases rather than concluding the module has no data.
  ///
  /// Parameters:
  /// - [moduleName]: Any spelling of the module.
  ///
  /// Returns: [List<String>] the canonical name followed by its aliases.
  static List<String> spellingsOf(String moduleName) {
    final String canonicalName = canonical(moduleName);

    return <String>[
      canonicalName,
      ..._aliases.entries
          .where((MapEntry<String, String> e) => e.value == canonicalName)
          .map((MapEntry<String, String> e) => e.key),
    ];
  }
}
