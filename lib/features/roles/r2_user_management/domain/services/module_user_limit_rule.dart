/// Module: roles / r2_user_management / domain / services
///
///*************************** FILE INFO ****************************///
/// File Name: module_user_limit_rule.dart
/// Purpose: The per-module (and total) user-limit rule set in Knowticed Admin,
///          as pure Dart — no Firestore, no Flutter — so it is unit-tested.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 — per-module user limits enforced in the client.
///
/// WHERE THE NUMBERS COME FROM
/// ---------------------------
/// Knowticed Admin (clients feature) writes, on `Demo_Requests/{companyId}`:
///   * `Demo_Details.Modules_User_Limits` = {module_key: int}
///     e.g. {knowledge_hub: 10, services: 20}. A module with NO entry has NO
///     limit. Admin keys use its licence names (`tracking`, `database`,
///     `form_builder`), so both sides go through [ModuleNameAliases.canonical].
///   * `Demo_Details.Number_Of_Users` = the company total, stored as a history
///     map {Values: [20], Timestamps: [...]} — the LAST value is current.
///
/// WHO HOLDS A SEAT
/// ----------------
/// One [SeatRecord] per employee (the `User_Management` document — the data
/// layer hands the seeded Master Admin in from `Users_Access` when they have no
/// `User_Management` document). A record holds a seat while:
///   * its current role is not empty and not `removed` (revoked), and
///   * its end date (`To_Date`) has not passed — an unreadable end date counts
///     as still active, the same call `getUserAccessStatus` makes, and
///   * the employee's deactivation date (when known) has not passed.
/// A SCHEDULED grant (start date in the future) already holds its seat: the
/// role is written to the account the moment it is saved, so letting it out of
/// the count would let an admin pre-date past every limit.
///
/// THE RULE
/// --------
/// A change (one or more [ProposedAssignment]s) is blocked when, for ANY module
/// with a limit, the number of seat holders whose role includes that module
/// AFTER the change is above the limit AND above what it was before the change.
/// The total `Number_Of_Users` is checked the same way over all seat holders.
///
/// "and above what it was before" is deliberate: re-saving the dates of a user
/// who already holds the seat, or moving them between two roles that both
/// carry the module, adds no seat and is never blocked — even if Admin has
/// since lowered the limit below the current usage. Only changes that ADD
/// seats to a full module are refused.
///
/// FAIL CLOSED
/// -----------
/// A limit that is present but unreadable, or a role the rule cannot find,
/// yields a violation (never a silent pass) whenever the change would add a
/// seat it cannot verify.
library;

import 'dart:math' as math;

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';

/// Parses one stored access date (`From_Date` / `To_Date` / deactivation).
typedef AccessDateParser = DateTime? Function(String raw);

// ═══════════════════════════════════════════════════════════════════════════
// Reading stored values — every field may be a history list
// ═══════════════════════════════════════════════════════════════════════════

/// Function group: the CURRENT value of a stored field.
///
/// Firestore fields in this app come in three shapes, all of which appear in
/// live data (checked 9/10/2026):
///   * a plain value                        — `'Employee'`, `20`
///   * a history list, last entry current    — `['employee', 'Employee']`
///   * a history map                         — `{Values: [20], Timestamps: [...]}`
abstract final class StoredValue {
  const StoredValue._();

  /// The current value of [raw] as a trimmed string, or null when empty.
  static String? currentString(Object? raw) {
    if (raw == null) return null;
    if (raw is String) {
      final String text = raw.trim();
      return text.isEmpty ? null : text;
    }
    if (raw is num || raw is bool) return raw.toString();
    if (raw is List) return raw.isEmpty ? null : currentString(raw.last);
    if (raw is Map) return currentString(raw['Values'] ?? raw['values']);
    return null;
  }

  /// The current value of [raw] as a whole number, or null when it is absent
  /// or cannot be read as one.
  static int? currentInt(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.isFinite ? raw.toInt() : null;
    if (raw is String) return int.tryParse(raw.trim());
    if (raw is List) return raw.isEmpty ? null : currentInt(raw.last);
    if (raw is Map) return currentInt(raw['Values'] ?? raw['values']);
    return null;
  }

  /// The current module list of a role's `Selected_Modules`.
  ///
  /// Unlike a scalar history, a FLAT list of strings is the value itself;
  /// only a list of lists (the role history format) is a history.
  static List<String> currentModules(Object? raw) {
    if (raw == null) return const <String>[];
    if (raw is String) return <String>[raw];
    if (raw is Map) return currentModules(raw['Values'] ?? raw['values']);
    if (raw is List) {
      if (raw.isEmpty) return const <String>[];
      if (raw.last is List || raw.last is Map) return currentModules(raw.last);
      return raw
          .where((Object? e) => e != null && e.toString().trim().isNotEmpty)
          .map((Object? e) => e.toString().trim())
          .toList();
    }
    return const <String>[];
  }

  /// Every string ever stored in a history field — current one last.
  static List<String> allStrings(Object? raw) {
    if (raw == null) return const <String>[];
    if (raw is String) return raw.trim().isEmpty ? const <String>[] : <String>[raw.trim()];
    if (raw is List) return raw.expand(allStrings).toList();
    if (raw is Map) return allStrings(raw['Values'] ?? raw['values']);
    return const <String>[];
  }
}

/// Function Name: [defaultParseAccessDate]
///
/// Purpose: The fallback date reader for [SeatRecord.fromAccessDoc] when the
/// caller passes none — ISO, the storage format `MMM dd, yyyy`
/// (`Constants.userAccessDateFormat`) and `dd/MM/yyyy`.
///
/// Locale-free on purpose (no `DateFormat`), so it works before
/// `initializeDateFormatting` and in plain unit tests. The repository passes
/// its own `parseAccessDate`, which also reads Arabic month names.
///
/// Returns: [DateTime?] null when the text matches none of the formats.
DateTime? defaultParseAccessDate(String raw) {
  final String text = raw.trim();
  if (text.isEmpty) return null;

  final DateTime? iso = DateTime.tryParse(text);
  if (iso != null) return iso;

  final RegExpMatch? named =
      RegExp(r'^([A-Za-z]{3,})\.?\s+(\d{1,2}),?\s+(\d{4})$').firstMatch(text);
  if (named != null) {
    final int? month = _englishMonths[named.group(1)!.substring(0, 3).toLowerCase()];
    final int? day = int.tryParse(named.group(2)!);
    final int? year = int.tryParse(named.group(3)!);
    if (month != null && day != null && year != null) {
      return DateTime(year, month, day);
    }
  }

  final List<String> parts = text.split('/');
  if (parts.length == 3) {
    final int? day = int.tryParse(parts[0].trim());
    final int? month = int.tryParse(parts[1].trim());
    final int? year = int.tryParse(parts[2].trim());
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
  }
  return null;
}

const Map<String, int> _englishMonths = <String, int>{
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

// ═══════════════════════════════════════════════════════════════════════════
// Inputs
// ═══════════════════════════════════════════════════════════════════════════

/// The limits Knowticed Admin set for one company.
class LicenceLimits {
  const LicenceLimits({
    this.moduleLimits = const <String, int>{},
    this.invalidModules = const <String>{},
    this.totalUsers,
    this.totalInvalid = false,
    this.limitsUnreadable = false,
  });

  /// Canonical module name → max users. No entry = no limit.
  final Map<String, int> moduleLimits;

  /// Modules whose limit is present but unreadable (not a whole number ≥ 0).
  final Set<String> invalidModules;

  /// `Number_Of_Users`, or null when Admin set none.
  final int? totalUsers;

  /// `Number_Of_Users` is present but unreadable.
  final bool totalInvalid;

  /// `Modules_User_Limits` is present but is not a map at all.
  final bool limitsUnreadable;

  /// Nothing to enforce.
  bool get isEmpty =>
      moduleLimits.isEmpty &&
      invalidModules.isEmpty &&
      totalUsers == null &&
      !totalInvalid &&
      !limitsUnreadable;

  /// Settings is always on and Admin dropped its limit (Admin review
  /// 23/9/2026 — `moduleUserLimits.remove('settings')`); an old document that
  /// still carries one must not cap every role in the company.
  static const Set<String> _neverLimited = <String>{'settings'};

  /// Function Name: [LicenceLimits.fromDemoRequest]
  ///
  /// Purpose: Read the limits from a `Demo_Requests/{companyId}` document.
  ///
  /// Parameters:
  /// - [doc]: the document data, or null when it does not exist.
  ///
  /// Returns: [LicenceLimits] — empty when the document or `Demo_Details` is
  /// missing (no entry = no limit).
  factory LicenceLimits.fromDemoRequest(Map<String, dynamic>? doc) {
    final Object? details = doc?['Demo_Details'];
    if (details is! Map) return const LicenceLimits();

    final Map<String, int> limits = <String, int>{};
    final Set<String> invalid = <String>{};
    bool unreadable = false;

    Object? rawLimits = details['Modules_User_Limits'];
    // Tolerate a history-wrapped map ({Values: [{...}]}) should Admin ever
    // switch this field to the history format the rest of Demo_Details uses.
    if (rawLimits is Map &&
        (rawLimits.containsKey('Values') || rawLimits.containsKey('values'))) {
      final Object? values = rawLimits['Values'] ?? rawLimits['values'];
      rawLimits = values is List && values.isNotEmpty ? values.last : values;
    }

    if (rawLimits is Map) {
      rawLimits.forEach((Object? key, Object? value) {
        if (key == null) return;
        final String module = ModuleNameAliases.canonical(key.toString());
        if (module.isEmpty || _neverLimited.contains(module)) return;
        if (value == null) return; // an explicit null is "no limit"
        final int? limit = StoredValue.currentInt(value);
        if (limit == null || limit < 0) {
          invalid.add(module);
          return;
        }
        // Two spellings of one module (`database` and `database_builder`):
        // the stricter limit wins.
        final int? existing = limits[module];
        limits[module] = existing == null ? limit : math.min(existing, limit);
      });
    } else if (rawLimits != null) {
      unreadable = true;
    }

    final Object? rawTotal = details['Number_Of_Users'];
    final int? total = StoredValue.currentInt(rawTotal);
    final bool totalInvalid = rawTotal != null && (total == null || total < 0);

    return LicenceLimits(
      moduleLimits: limits,
      invalidModules: invalid.difference(limits.keys.toSet()),
      totalUsers: totalInvalid ? null : total,
      totalInvalid: totalInvalid,
      limitsUnreadable: unreadable,
    );
  }
}

/// Which modules each role carries, looked up by role NAME.
///
/// `User_Management.Role` stores the role's name (sometimes lower-cased by the
/// caller that wrote it), not its id, so the index is keyed by a normalised
/// name. A role's earlier names are indexed too, so a user still carrying the
/// name a role had before it was renamed is counted against that role.
class RoleModulesIndex {
  RoleModulesIndex._(this._byKey);

  /// An index with the given role name → modules entries (names are
  /// normalised, modules canonicalised). For tests and callers that already
  /// hold parsed roles.
  factory RoleModulesIndex.of(Map<String, Iterable<String>> roles) {
    final Map<String, Set<String>> byKey = <String, Set<String>>{};
    roles.forEach((String name, Iterable<String> modules) {
      final String key = keyOf(name);
      if (key.isEmpty) return;
      byKey
          .putIfAbsent(key, () => <String>{})
          .addAll(modules.map(ModuleNameAliases.canonical));
    });
    return RoleModulesIndex._(byKey);
  }

  final Map<String, Set<String>> _byKey;

  /// Role-name fields in the order `RoleHistoryModel.fromMap` reads them.
  static const List<String> _nameFields = <String>[
    'Role_Name',
    'Name',
    'Access_Name',
    'roleName',
  ];

  /// Function Name: [keyOf]
  ///
  /// Purpose: The comparison key for a role name — lower-case, whitespace
  /// collapsed, invisible marks removed (the same key `access_details.dart`
  /// de-duplicates the Role Type dropdown on).
  static String keyOf(String name) => name
      .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060\uFEFF]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();

  /// Function Name: [RoleModulesIndex.fromRoleDocs]
  ///
  /// Purpose: Build the index from role documents (`Roles` and
  /// `Subscription_Admin`), keyed by document id.
  ///
  /// Current names are indexed first, earlier names only where no current
  /// name claims them, and document ids last. Two documents with the same
  /// name (a role present in both collections) merge their modules. A role
  /// whose current status is `deleted` grants nothing and is skipped.
  factory RoleModulesIndex.fromRoleDocs(
      Iterable<MapEntry<String, Map<String, dynamic>>> docs) {
    final Map<String, Set<String>> current = <String, Set<String>>{};
    final Map<String, Set<String>> historic = <String, Set<String>>{};
    final Map<String, Set<String>> byId = <String, Set<String>>{};

    for (final MapEntry<String, Map<String, dynamic>> doc in docs) {
      final Map<String, dynamic> data = doc.value;
      final String status =
          (StoredValue.currentString(data['Status']) ?? '').toLowerCase();
      if (status == 'deleted') continue;

      // Same precedence as RoleHistoryModel.fromMap.
      final Set<String> modules = StoredValue.currentModules(
              data['Selected_Modules'] ?? data['selectedModules'])
          .map(ModuleNameAliases.canonical)
          .where((String m) => m.isNotEmpty)
          .toSet();

      Object? nameField;
      for (final String field in _nameFields) {
        final Object? value = data[field];
        if (StoredValue.currentString(value) != null) {
          nameField = value;
          break;
        }
      }

      final String currentKey = keyOf(StoredValue.currentString(nameField) ?? '');
      if (currentKey.isNotEmpty) {
        current.putIfAbsent(currentKey, () => <String>{}).addAll(modules);
      }
      for (final String name in StoredValue.allStrings(nameField)) {
        final String key = keyOf(name);
        if (key.isEmpty || key == currentKey) continue;
        historic.putIfAbsent(key, () => <String>{}).addAll(modules);
      }
      final String idKey = keyOf(doc.key);
      if (idKey.isNotEmpty) {
        byId.putIfAbsent(idKey, () => <String>{}).addAll(modules);
      }
    }

    final Map<String, Set<String>> byKey = <String, Set<String>>{...current};
    historic.forEach((String key, Set<String> modules) {
      byKey.putIfAbsent(key, () => modules);
    });
    byId.forEach((String key, Set<String> modules) {
      byKey.putIfAbsent(key, () => modules);
    });
    return RoleModulesIndex._(byKey);
  }

  /// The canonical modules of [roleName], or null when no role has that name.
  Set<String>? modulesOf(String roleName) => _byKey[keyOf(roleName)];
}

/// One employee's access, as stored.
class SeatRecord {
  const SeatRecord({
    required this.employeeId,
    required this.role,
    this.accessEnd,
  });

  final String employeeId;

  /// The current role name (`Role`, last value).
  final String role;

  /// The current end date (`To_Date`, last value); null when absent or
  /// unreadable — such a record is treated as still active.
  final DateTime? accessEnd;

  /// Function Name: [SeatRecord.fromAccessDoc]
  ///
  /// Purpose: Read one `User_Management` (or `Users_Access`) document. Every
  /// field may be a history list or a {Values: [...]} map — the LAST value is
  /// the current one.
  factory SeatRecord.fromAccessDoc(
    String employeeId,
    Map<String, dynamic> data, {
    AccessDateParser? parseDate,
  }) {
    final String? rawEnd = StoredValue.currentString(data['To_Date']);
    return SeatRecord(
      employeeId: employeeId,
      role: StoredValue.currentString(data['Role']) ?? '',
      accessEnd:
          rawEnd == null ? null : (parseDate ?? defaultParseAccessDate)(rawEnd),
    );
  }
}

/// One user about to be given [role] (a grant, a role change, or a re-save
/// that extends their access).
class ProposedAssignment {
  const ProposedAssignment({required this.employeeId, required this.role});

  final String employeeId;
  final String role;
}

// ═══════════════════════════════════════════════════════════════════════════
// Outputs
// ═══════════════════════════════════════════════════════════════════════════

enum LimitViolationKind {
  /// A module's limit would be exceeded.
  module,

  /// The company's `Number_Of_Users` would be exceeded.
  totalUsers,

  /// A module's limit is set but unreadable, and the change adds a seat to it.
  moduleUnverifiable,

  /// `Number_Of_Users` is set but unreadable, and the change adds a user.
  totalUnverifiable,

  /// `Modules_User_Limits` itself is unreadable, and the change adds seats.
  limitsUnverifiable,

  /// The role being assigned does not exist, so its modules are unknown.
  unknownRole,
}

class LimitViolation {
  const LimitViolation({
    required this.kind,
    this.module,
    this.role,
    this.limit = 0,
    this.assigned = 0,
    this.requested = 0,
  });

  final LimitViolationKind kind;

  /// Canonical module name ([LimitViolationKind.module] /
  /// [LimitViolationKind.moduleUnverifiable]).
  final String? module;

  /// The role name ([LimitViolationKind.unknownRole]).
  final String? role;

  final int limit;

  /// Seats in use BEFORE the change.
  final int assigned;

  /// Seats that would be in use AFTER the change.
  final int requested;

  /// Seats still free before the change (never negative).
  int get remaining => math.max(0, limit - assigned);
}

class LimitVerdict {
  const LimitVerdict(this.violations);

  static const LimitVerdict ok = LimitVerdict(<LimitViolation>[]);

  final List<LimitViolation> violations;

  bool get allowed => violations.isEmpty;
}

/// "Time Tracker: 8 of 10" — [module] is null for the company total.
class ModuleUsage {
  const ModuleUsage({this.module, required this.assigned, required this.limit});

  final String? module;
  final int assigned;
  final int limit;
}

// ═══════════════════════════════════════════════════════════════════════════
// The rule
// ═══════════════════════════════════════════════════════════════════════════

abstract final class ModuleUserLimitRule {
  const ModuleUserLimitRule._();

  /// The role value a revoked access carries
  /// (`Constants.removedEmployeePermission`).
  static const String revokedRole = 'removed';

  static bool _isRevoked(String role) {
    final String r = role.trim().toLowerCase();
    return r.isEmpty || r == revokedRole;
  }

  /// Function Name: [seatHolders]
  ///
  /// Purpose: Employee id → current role of everyone holding a seat at [now].
  ///
  /// When [records] carries two records for one employee the LATER one wins
  /// (the data layer lists fallback sources first and `User_Management`
  /// last), and it wins even when it is the inactive one.
  static Map<String, String> seatHolders(
    Iterable<SeatRecord> records,
    DateTime now, {
    Map<String, DateTime?> deactivatedOn = const <String, DateTime?>{},
  }) {
    final Map<String, SeatRecord> latest = <String, SeatRecord>{};
    for (final SeatRecord record in records) {
      if (record.employeeId.trim().isEmpty) continue;
      latest[record.employeeId] = record;
    }

    final Map<String, String> holders = <String, String>{};
    latest.forEach((String id, SeatRecord record) {
      if (_isRevoked(record.role)) return;
      final DateTime? end = record.accessEnd;
      if (end != null && now.isAfter(end)) return;
      final DateTime? deactivated = deactivatedOn[id];
      if (deactivated != null && now.isAfter(deactivated)) return;
      holders[id] = record.role;
    });
    return holders;
  }

  static int _count(
    Map<String, String> holders,
    String module,
    Set<String>? Function(String role) modulesOf,
  ) {
    int count = 0;
    for (final String role in holders.values) {
      if (modulesOf(role)?.contains(module) ?? false) count++;
    }
    return count;
  }

  /// Function Name: [evaluate]
  ///
  /// Purpose: Decide whether [proposed] may be written.
  ///
  /// Parameters:
  /// - [limits]: what Admin set.
  /// - [roles]: role name → modules.
  /// - [records]: everyone's current access (see [seatHolders]).
  /// - [proposed]: the assignments about to be saved. Each is treated as an
  ///   active seat after the change; a proposed `removed` role frees the seat.
  /// - [now]: the clock.
  /// - [deactivatedOn]: employee id → deactivation date, when known.
  ///
  /// Returns: [LimitVerdict] — [LimitVerdict.allowed] or every violation.
  static LimitVerdict evaluate({
    required LicenceLimits limits,
    required RoleModulesIndex roles,
    required Iterable<SeatRecord> records,
    required Iterable<ProposedAssignment> proposed,
    required DateTime now,
    Map<String, DateTime?> deactivatedOn = const <String, DateTime?>{},
  }) {
    if (limits.isEmpty) return LimitVerdict.ok;

    final Map<String, String> before =
        seatHolders(records, now, deactivatedOn: deactivatedOn);
    final Map<String, String> after = Map<String, String>.of(before);
    for (final ProposedAssignment p in proposed) {
      if (p.employeeId.trim().isEmpty) continue;
      if (_isRevoked(p.role)) {
        after.remove(p.employeeId);
      } else {
        after[p.employeeId] = p.role;
      }
    }

    final Map<String, Set<String>?> cache = <String, Set<String>?>{};
    Set<String>? modulesOf(String role) =>
        cache.putIfAbsent(role, () => roles.modulesOf(role));

    final List<LimitViolation> violations = <LimitViolation>[];

    // ── An assigned role nobody can find: its modules are unknown ──────────
    final bool moduleLimitsInPlay = limits.moduleLimits.isNotEmpty ||
        limits.invalidModules.isNotEmpty ||
        limits.limitsUnreadable;
    if (moduleLimitsInPlay) {
      final Set<String> reported = <String>{};
      for (final ProposedAssignment p in proposed) {
        if (_isRevoked(p.role)) continue;
        if (modulesOf(p.role) != null) continue;
        if (reported.add(RoleModulesIndex.keyOf(p.role))) {
          violations.add(LimitViolation(
              kind: LimitViolationKind.unknownRole, role: p.role));
        }
      }
    }

    // ── Per-module limits ──────────────────────────────────────────────────
    final List<String> limited = limits.moduleLimits.keys.toList()..sort();
    for (final String module in limited) {
      final int limit = limits.moduleLimits[module]!;
      final int was = _count(before, module, modulesOf);
      final int will = _count(after, module, modulesOf);
      if (will > limit && will > was) {
        violations.add(LimitViolation(
          kind: LimitViolationKind.module,
          module: module,
          limit: limit,
          assigned: was,
          requested: will,
        ));
      }
    }

    final List<String> unreadable = limits.invalidModules.toList()..sort();
    for (final String module in unreadable) {
      if (_count(after, module, modulesOf) > _count(before, module, modulesOf)) {
        violations.add(LimitViolation(
            kind: LimitViolationKind.moduleUnverifiable, module: module));
      }
    }

    if (limits.limitsUnreadable) {
      final Set<String> touched = <String>{
        for (final String role in after.values) ...?modulesOf(role),
      };
      final bool addsSeat = touched.any((String m) =>
          _count(after, m, modulesOf) > _count(before, m, modulesOf));
      if (addsSeat) {
        violations.add(
            const LimitViolation(kind: LimitViolationKind.limitsUnverifiable));
      }
    }

    // ── Company total ──────────────────────────────────────────────────────
    final int usersBefore = before.length;
    final int usersAfter = after.length;
    final int? total = limits.totalUsers;
    if (total != null && usersAfter > total && usersAfter > usersBefore) {
      violations.add(LimitViolation(
        kind: LimitViolationKind.totalUsers,
        limit: total,
        assigned: usersBefore,
        requested: usersAfter,
      ));
    }
    if (limits.totalInvalid && usersAfter > usersBefore) {
      violations.add(
          const LimitViolation(kind: LimitViolationKind.totalUnverifiable));
    }

    return LimitVerdict(violations);
  }

  /// Function Name: [usageForRole]
  ///
  /// Purpose: Current usage of every LIMITED module [roleName] carries, in
  /// module-name order — what the Role Type picker shows under the role.
  static List<ModuleUsage> usageForRole({
    required String roleName,
    required LicenceLimits limits,
    required RoleModulesIndex roles,
    required Iterable<SeatRecord> records,
    required DateTime now,
    Map<String, DateTime?> deactivatedOn = const <String, DateTime?>{},
  }) {
    final Set<String>? modules = roles.modulesOf(roleName);
    if (modules == null || limits.moduleLimits.isEmpty) {
      return const <ModuleUsage>[];
    }
    final Map<String, String> holders =
        seatHolders(records, now, deactivatedOn: deactivatedOn);
    final List<String> limited = modules
        .where(limits.moduleLimits.containsKey)
        .toList()
      ..sort();
    return <ModuleUsage>[
      for (final String module in limited)
        ModuleUsage(
          module: module,
          assigned: _count(holders, module, roles.modulesOf),
          limit: limits.moduleLimits[module]!,
        ),
    ];
  }

  /// Function Name: [totalUsage]
  ///
  /// Purpose: Current usage of the company total, or null when Admin set none.
  static ModuleUsage? totalUsage({
    required LicenceLimits limits,
    required Iterable<SeatRecord> records,
    required DateTime now,
    Map<String, DateTime?> deactivatedOn = const <String, DateTime?>{},
  }) {
    final int? total = limits.totalUsers;
    if (total == null) return null;
    return ModuleUsage(
      assigned: seatHolders(records, now, deactivatedOn: deactivatedOn).length,
      limit: total,
    );
  }
}

/// Everything the rule needs, read once — what the User Management screens
/// hold to show usage and pre-check a selection before Save.
///
/// The authoritative check is NOT this snapshot: it is repeated inside the
/// Firestore transaction that writes the grant (see `LicenceSeatGuard`).
class LicenceUsageSnapshot {
  const LicenceUsageSnapshot({
    required this.limits,
    required this.roles,
    required this.records,
    this.deactivatedOn = const <String, DateTime?>{},
  });

  final LicenceLimits limits;
  final RoleModulesIndex roles;
  final List<SeatRecord> records;
  final Map<String, DateTime?> deactivatedOn;

  LimitVerdict check(Iterable<ProposedAssignment> proposed, {DateTime? now}) =>
      ModuleUserLimitRule.evaluate(
        limits: limits,
        roles: roles,
        records: records,
        proposed: proposed,
        now: now ?? DateTime.now(),
        deactivatedOn: deactivatedOn,
      );

  List<ModuleUsage> usageForRole(String roleName, {DateTime? now}) =>
      ModuleUserLimitRule.usageForRole(
        roleName: roleName,
        limits: limits,
        roles: roles,
        records: records,
        now: now ?? DateTime.now(),
        deactivatedOn: deactivatedOn,
      );

  ModuleUsage? totalUsage({DateTime? now}) => ModuleUserLimitRule.totalUsage(
        limits: limits,
        records: records,
        now: now ?? DateTime.now(),
        deactivatedOn: deactivatedOn,
      );
}
