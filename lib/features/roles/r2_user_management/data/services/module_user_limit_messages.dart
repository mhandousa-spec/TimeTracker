/// Module: roles / r2_user_management / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: module_user_limit_messages.dart
/// Purpose: EN/AR text for the per-module user-limit rule, and the typed
///          [ModuleUserLimitFailure] the repository returns when it blocks.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 — per-module user limits enforced in the client.
///
/// Built on `S.current` because the repository has no BuildContext and its
/// failure message is what every caller already shows (the Add-Access
/// warning dialog, the Edit snackbar, the bulk-import result list). The
/// numbers are rendered in Arabic-Indic digits in Arabic, as the Access
/// Details dates are.
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The failure an assignment returns when a user limit blocks it.
///
/// [message] is already localized; [verdict] is there for callers that want
/// the numbers.
class ModuleUserLimitFailure extends FeatureFailure {
  ModuleUserLimitFailure(this.verdict)
      : super(ModuleUserLimitMessages.verdict(verdict));

  final LimitVerdict verdict;
}

abstract final class ModuleUserLimitMessages {
  const ModuleUserLimitMessages._();

  static bool get _isArabic =>
      Intl.getCurrentLocale().toLowerCase().startsWith('ar');

  /// A number as the current language writes it.
  static String number(int value) =>
      _isArabic ? value.toString().toArabicNumbers() : value.toString();

  /// Function Name: [moduleName]
  ///
  /// Purpose: The display name of a module key, any spelling.
  ///
  /// Same labels as `ModulePermissionsWidget._getModuleDisplayName`, keyed
  /// on the canonical name so `tracking` and `time_tracker` both read
  /// "Time Tracker".
  static String moduleName(String module) {
    final S s = S.current;
    switch (ModuleNameAliases.canonical(module)) {
      case 'services':
        return s.services;
      case 'todo':
        return s.todo;
      case 'notes':
        return s.notes;
      case 'knowledge_hub':
        return s.knowledge_hub;
      case 'notification':
        return s.notifications;
      case 'qiyas':
        return s.qiyas;
      case 'grc':
        return s.grc;
      case 'inventory':
        return s.inventory;
      case 'messages':
        return s.messages;
      case 'services_app':
        return s.services_app;
      case 'roles':
        return s.roles;
      case 'settings':
        return s.settings;
      case 'employees':
        return s.employees;
      case 'tasks':
        return s.tasks;
      case 'events':
        return s.events;
      case 'requests':
        return s.requests;
      case 'time_tracker':
        return s.timeTracker;
      case 'database_builder':
        return s.database_builder;
      case 'hr':
        return s.hr;
      case 'crm':
        return s.crm;
      default:
        return module
            .replaceAll('_', ' ')
            .split(' ')
            .where((String w) => w.isNotEmpty)
            .map((String w) => '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  /// Function Name: [violation]
  ///
  /// Purpose: One violation as a sentence, e.g.
  /// "Time Tracker allows 10 users. 10 are already assigned."
  /// When seats are still free (a multi-select that overshoots), the free
  /// count follows: "... 8 are already assigned. Only 2 more can be added."
  static String violation(LimitViolation v) {
    final S s = S.current;
    switch (v.kind) {
      case LimitViolationKind.module:
        return _withSeatsLeft(
          s.userLimitModuleReached(
              moduleName(v.module ?? ''), number(v.limit), number(v.assigned)),
          v.remaining,
        );
      case LimitViolationKind.totalUsers:
        return _withSeatsLeft(
          s.userLimitTotalReached(number(v.limit), number(v.assigned)),
          v.remaining,
        );
      case LimitViolationKind.moduleUnverifiable:
        return s.userLimitModuleUnverifiable(moduleName(v.module ?? ''));
      case LimitViolationKind.totalUnverifiable:
        return s.userLimitTotalUnverifiable;
      case LimitViolationKind.limitsUnverifiable:
        return s.userLimitCheckFailed;
      case LimitViolationKind.unknownRole:
        return s.userLimitUnknownRole(v.role ?? '');
    }
  }

  static String _withSeatsLeft(String sentence, int remaining) =>
      remaining > 0
          ? '$sentence ${S.current.userLimitSeatsLeft(number(remaining))}'
          : sentence;

  /// Every violation of [verdict], one per line ('' when allowed).
  static String verdict(LimitVerdict verdict) =>
      verdict.violations.map(violation).toSet().join('\n');

  /// "Time Tracker: 8 of 10 users" / "Users: 18 of 20".
  static String usage(ModuleUsage usage) => usage.module == null
      ? S.current.userLimitTotalUsage(number(usage.assigned), number(usage.limit))
      : S.current.userLimitModuleUsage(moduleName(usage.module!),
          number(usage.assigned), number(usage.limit));

  /// The limit could not be checked (read failed, offline, rules refused) —
  /// nothing was granted.
  static String get checkFailed => S.current.userLimitCheckFailed;

  /// While the usage snapshot loads.
  static String get checking => S.current.userLimitChecking;
}
