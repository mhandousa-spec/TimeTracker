/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: get_grc_dashboard_use_case.dart
/// Purpose: Declares `GetGrcDashboardUseCase` — loads the modules, policies
///          and controls a GRC dashboard needs through the EXISTING GRC use
///          cases and returns them as a [GrcDashboardData].
/// Author: Amr Mesbah
/// Created: 16/9/2026
///
/// No new data source or repository, so the dashboard reads exactly what the
/// policies tab and policy details page read.
///
/// Failure policy (same as PolicyCubit._loadControlsSummaries):
/// * the module list (main) or the module's policies (module) failing is a
///   real failure → `Left`;
/// * one policy's controls failing is skipped; on the main dashboard one
///   module's policies failing is skipped too.
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_dashboard_stats.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_status.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';

class GetGrcDashboardUseCase {
  const GetGrcDashboardUseCase({
    required GetAllGRCModulesUseCase getAllModulesUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _getAllModules = getAllModulesUseCase,
        _getAllPolicies = getAllPoliciesUseCase,
        _getAllControls = getAllControlsUseCase;

  final GetAllGRCModulesUseCase _getAllModules;
  final GetAllPoliciesUseCase _getAllPolicies;
  final GetAllControlsUseCase _getAllControls;

  Future<Either<Failure, GrcDashboardData>> forModule(
    GRCModuleEntity module,
  ) async {
    final snapshot = await _loadSnapshot(module);
    return snapshot.map(
      (snap) => GrcDashboardData(
        scope: GrcDashboardScope.module,
        snapshots: [snap],
      ),
    );
  }

  Future<Either<Failure, GrcDashboardData>> forAllModules() async {
    final modulesResult = await _getAllModules.execute();

    return modulesResult.fold<Future<Either<Failure, GrcDashboardData>>>(
      (failure) async => Left(failure),
      (modules) async {
        final live = modules
            .where((m) =>
                GrcModuleStatus.fromString(m.status) != GrcModuleStatus.removed)
            .toList();
        final results = await Future.wait(live.map(_loadSnapshot));
        final snapshots = <GrcModuleSnapshot>[
          for (final r in results)
            ...r.fold<List<GrcModuleSnapshot>>(
              (_) => const <GrcModuleSnapshot>[],
              (s) => <GrcModuleSnapshot>[s],
            ),
        ];
        return Right<Failure, GrcDashboardData>(GrcDashboardData(
          scope: GrcDashboardScope.main,
          snapshots: snapshots,
        ));
      },
    );
  }

  Future<Either<Failure, GrcModuleSnapshot>> _loadSnapshot(
    GRCModuleEntity module,
  ) async {
    final policiesResult =
        await _getAllPolicies.call(moduleId: module.moduleId);

    return policiesResult.fold<Future<Either<Failure, GrcModuleSnapshot>>>(
      (failure) async => Left(failure),
      (policies) async => Right<Failure, GrcModuleSnapshot>(GrcModuleSnapshot(
        module: module,
        policies: policies,
        controlsByPolicy: await _loadControls(module.moduleId, policies),
      )),
    );
  }

  Future<Map<String, List<ControlEntity>>> _loadControls(
    String moduleId,
    List<PolicyEntity> policies,
  ) async {
    if (policies.isEmpty) return const {};
    final results = await Future.wait(
      policies.map(
        (p) => _getAllControls.call(moduleId: moduleId, policyId: p.id),
      ),
    );
    final map = <String, List<ControlEntity>>{};
    for (var i = 0; i < policies.length; i++) {
      results[i].fold((_) {}, (controls) => map[policies[i].id] = controls);
    }
    return map;
  }
}
