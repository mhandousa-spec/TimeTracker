// ****************** FILE INFO ******************
// File Name: crm_teams_repository.dart
// Purpose: Repository implementation for managing CRM Teams. Employees are
//          sourced from the real MainCoreEmployeeController (Firestore-backed)
//          instead of mock data.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/enums/crm_team_status_enum.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/interfaces/crm_teams_base_repository.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmTeamsRepository implements CrmTeamsBaseRepository {
  List<CrmTeamModel> _teamsCache = <CrmTeamModel>[];
  final StreamController<List<CrmTeamModel>> _teamsController =
      StreamController<List<CrmTeamModel>>.broadcast();

  @override
  Stream<Either<Failure, List<CrmTeamModel>>> watchTeams() async* {
    yield Right<Failure, List<CrmTeamModel>>(
        List<CrmTeamModel>.from(_teamsCache));
    yield* _teamsController.stream.map(
      (List<CrmTeamModel> teams) =>
          Right<Failure, List<CrmTeamModel>>(teams),
    );
  }

  @override
  Future<Either<Failure, List<CrmTeamModel>>> getTeams() async {
    try {
      return Right<Failure, List<CrmTeamModel>>(
          List<CrmTeamModel>.from(_teamsCache));
    } catch (e) {
      return Left<Failure, List<CrmTeamModel>>(FeatureFailure(e.toString()));
    }
  }

  /// Loads all active employees from the real [MainCoreEmployeeController]
  /// and maps each [EmployeeEntityPro] to a [CrmTeamMemberModel].
  ///
  /// Falls back to an empty list if the controller is not yet registered
  /// (e.g. during unit tests or before login completes).
  @override
  Future<Either<Failure, List<CrmTeamMemberModel>>> getAvailableEmployees() async {
    try {
      if (!Get.isRegistered<MainCoreEmployeeController>()) {
        return const Right<Failure, List<CrmTeamMemberModel>>(<CrmTeamMemberModel>[]);
      }

      final MainCoreEmployeeController controller =
          Get.find<MainCoreEmployeeController>();

      final List<EmployeeEntityPro> entities =
          controller.allEmployeesEntities ?? <EmployeeEntityPro>[];

      // Filter to active employees only and map to CrmTeamMemberModel
      final List<CrmTeamMemberModel> members = entities
          .where((EmployeeEntityPro e) =>
              e.id != null &&
              e.id!.isNotEmpty &&
              (e.status?.toLowerCase() == 'active' ||
                  e.status == null))
          .map(CrmTeamMemberModel.fromEmployeeEntity)
          .toList();

      return Right<Failure, List<CrmTeamMemberModel>>(members);
    } catch (e) {
      return Left<Failure, List<CrmTeamMemberModel>>(
          FeatureFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CrmTeamModel>> createTeam(CrmTeamModel team) async {
    try {
      final List<CrmTeamModel> current =
          List<CrmTeamModel>.from(_teamsCache);
      final CrmTeamModel newTeam = team.copyWith(
        id: 'team_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      current.insert(0, newTeam);
      _teamsCache = current;
      _teamsController.add(_teamsCache);
      return Right<Failure, CrmTeamModel>(newTeam);
    } catch (e) {
      return Left<Failure, CrmTeamModel>(FeatureFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CrmTeamModel>> updateTeam(CrmTeamModel team) async {
    try {
      final List<CrmTeamModel> current =
          List<CrmTeamModel>.from(_teamsCache);
      final int index =
          current.indexWhere((CrmTeamModel t) => t.id == team.id);
      if (index != -1) {
        final CrmTeamModel updated = team.copyWith(updatedAt: DateTime.now());
        current[index] = updated;
        _teamsCache = current;
        _teamsController.add(_teamsCache);
        return Right<Failure, CrmTeamModel>(updated);
      }
      return const Left<Failure, CrmTeamModel>(
          FeatureFailure('Team not found'));
    } catch (e) {
      return Left<Failure, CrmTeamModel>(FeatureFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTeam(String teamId) async {
    try {
      final List<CrmTeamModel> current =
          List<CrmTeamModel>.from(_teamsCache);
      current.removeWhere((CrmTeamModel t) => t.id == teamId);
      _teamsCache = current;
      _teamsController.add(_teamsCache);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FeatureFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CrmTeamModel>> toggleTeamStatus(
      String teamId) async {
    try {
      final List<CrmTeamModel> current =
          List<CrmTeamModel>.from(_teamsCache);
      final int index =
          current.indexWhere((CrmTeamModel t) => t.id == teamId);
      if (index != -1) {
        final CrmTeamModel existing = current[index];
        final CrmTeamStatus newStatus =
            existing.isActive ? CrmTeamStatus.inactive : CrmTeamStatus.active;
        final CrmTeamModel updated = existing.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        current[index] = updated;
        _teamsCache = current;
        _teamsController.add(_teamsCache);
        return Right<Failure, CrmTeamModel>(updated);
      }
      return const Left<Failure, CrmTeamModel>(
          FeatureFailure('Team not found'));
    } catch (e) {
      return Left<Failure, CrmTeamModel>(FeatureFailure(e.toString()));
    }
  }
}
