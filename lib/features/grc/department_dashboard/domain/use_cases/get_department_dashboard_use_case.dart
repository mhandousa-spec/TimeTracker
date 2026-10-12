/// Module: GRC / Dashboard Of All Departments
/// Description: Loads a module's policies, their controls and the people
///              assigned to each control, for the Departments tab.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
/// Dependencies: GetAllPoliciesUseCase, GetAllControlsUseCase,
///               GetAllOwnersUseCase, GetAllChampionsUseCase
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/domain/entities/department_dashboard_data.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';

/// class name: [GetDepartmentDashboardUseCase]
///
/// purpose: one call that returns a ready [DepartmentDashboardData]. Only the
///          policy read can fail the whole load; a policy whose controls
///          cannot be read, or an owner / champion list that fails, just
///          leaves those pieces empty.
class GetDepartmentDashboardUseCase {
  const GetDepartmentDashboardUseCase({
    required GetAllPoliciesUseCase getAllPolicies,
    required GetAllControlsUseCase getAllControls,
    required GetAllOwnersUseCase getAllOwners,
    required GetAllChampionsUseCase getAllChampions,
  })  : _getAllPolicies = getAllPolicies,
        _getAllControls = getAllControls,
        _getAllOwners = getAllOwners,
        _getAllChampions = getAllChampions;

  final GetAllPoliciesUseCase _getAllPolicies;
  final GetAllControlsUseCase _getAllControls;
  final GetAllOwnersUseCase _getAllOwners;
  final GetAllChampionsUseCase _getAllChampions;

  Future<Either<Failure, DepartmentDashboardData>> call({
    required String moduleId,
  }) async {
    final policiesResult = await _getAllPolicies.call(moduleId: moduleId);
    return policiesResult.fold<Future<Either<Failure, DepartmentDashboardData>>>(
      (failure) async => Left(failure),
      (policies) async {
        final results = await Future.wait<Object>([
          _loadControls(moduleId, policies),
          _getAllOwners.call(moduleId: moduleId),
          _getAllChampions.call(moduleId: moduleId),
        ]);
        final controlsByPolicy = results[0] as Map<String, List<ControlEntity>>;
        final owners = (results[1] as Either<Failure, List<OwnerEntity>>)
            .fold((_) => const <OwnerEntity>[], (o) => o);
        final champions = (results[2] as Either<Failure, List<ChampionEntity>>)
            .fold((_) => const <ChampionEntity>[], (c) => c);

        String key(String policyId, String controlId) => '$policyId/$controlId';
        final ownerOf = <String, String>{
          for (final o in owners)
            for (final a in o.assigningControls)
              key(a.policyId, a.controlId): o.ownerEmail,
        };
        final championOf = <String, String>{
          for (final c in champions)
            for (final a in c.assigningControls)
              key(a.policyId, a.controlId): c.championEmail,
        };

        final refs = <DepartmentControlRef>[
          for (final p in policies)
            for (final c in controlsByPolicy[p.id] ?? const <ControlEntity>[])
              DepartmentControlRef(
                policy: p,
                control: c,
                ownerEmail: ownerOf[key(p.id, c.id)],
                championEmail: championOf[key(p.id, c.id)],
              ),
        ];
        return Right<Failure, DepartmentDashboardData>(
          DepartmentDashboardData(policies: policies, controls: refs),
        );
      },
    );
  }

  Future<Map<String, List<ControlEntity>>> _loadControls(
    String moduleId,
    List<PolicyEntity> policies,
  ) async {
    if (policies.isEmpty) return <String, List<ControlEntity>>{};
    final results = await Future.wait(
      policies.map((p) => _getAllControls.call(moduleId: moduleId, policyId: p.id)),
    );
    final map = <String, List<ControlEntity>>{};
    for (var i = 0; i < policies.length; i++) {
      results[i].fold((_) {}, (controls) => map[policies[i].id] = controls);
    }
    return map;
  }
}
