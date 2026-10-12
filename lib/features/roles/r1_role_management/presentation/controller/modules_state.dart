/// Module: roles / r1_role_management / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: modules_state.dart
/// Purpose: Declares `ModulesState`, `ModulesInitial`, `ModulesLoading` (+2 more).
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of './modules_cubit.dart';

sealed class ModulesState {
  const ModulesState();
}

final class ModulesInitial extends ModulesState {
  const ModulesInitial();
}

final class ModulesLoading extends ModulesState {
  const ModulesLoading();
}

/// The built module/access lists for the currently selected role.
///
/// [modules] holds the role's *inactive* modules (the ones offered for
/// granting) and [accesses] holds the *active* ones. [modulesEdit] and
/// [accessesEdit] are the per-row edit flags, index-aligned with their lists.
final class ModulesReady extends ModulesState {
  final List<ModuleItem> modules;
  final List<bool> modulesEdit;
  final List<AccessData> accesses;
  final List<bool> accessesEdit;
  final List<String> activeModules;
  final List<String> inactiveModules;

  const ModulesReady({
    required this.modules,
    required this.modulesEdit,
    required this.accesses,
    required this.accessesEdit,
    required this.activeModules,
    required this.inactiveModules,
  });

  const ModulesReady.empty()
      : modules = const [],
        modulesEdit = const [],
        accesses = const [],
        accessesEdit = const [],
        activeModules = const [],
        inactiveModules = const [];

  ModulesReady copyWith({
    List<ModuleItem>? modules,
    List<bool>? modulesEdit,
    List<AccessData>? accesses,
    List<bool>? accessesEdit,
    List<String>? activeModules,
    List<String>? inactiveModules,
  }) {
    return ModulesReady(
      modules: modules ?? this.modules,
      modulesEdit: modulesEdit ?? this.modulesEdit,
      accesses: accesses ?? this.accesses,
      accessesEdit: accessesEdit ?? this.accessesEdit,
      activeModules: activeModules ?? this.activeModules,
      inactiveModules: inactiveModules ?? this.inactiveModules,
    );
  }
}

final class ModulesError extends ModulesState {
  final String message;

  const ModulesError(this.message);
}
