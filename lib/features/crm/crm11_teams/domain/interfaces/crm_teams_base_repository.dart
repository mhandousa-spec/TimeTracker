// ****************** FILE INFO ******************
// File Name: crm_teams_base_repository.dart
// Purpose: Abstract repository contract for CRM Team Management operations.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';

abstract class CrmTeamsBaseRepository {
  Stream<Either<Failure, List<CrmTeamModel>>> watchTeams();
  Future<Either<Failure, List<CrmTeamModel>>> getTeams();
  Future<Either<Failure, List<CrmTeamMemberModel>>> getAvailableEmployees();
  Future<Either<Failure, CrmTeamModel>> createTeam(CrmTeamModel team);
  Future<Either<Failure, CrmTeamModel>> updateTeam(CrmTeamModel team);
  Future<Either<Failure, void>> deleteTeam(String teamId);
  Future<Either<Failure, CrmTeamModel>> toggleTeamStatus(String teamId);
}
