// ****************** FILE INFO ******************
// File Name: crm_teams_cubit.dart
// Purpose: Controller & state manager for CRM Team Management operations.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/repository/crm_teams_repository.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/interfaces/crm_teams_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/controller/crm_teams_state.dart';


class CrmTeamsCubit extends Cubit<CrmTeamsState> {
  final CrmTeamsBaseRepository _repository;
  StreamSubscription<Either<Failure, List<CrmTeamModel>>>? _teamsSubscription;

  CrmTeamsCubit({CrmTeamsBaseRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<CrmTeamsBaseRepository>()
                ? Get.find<CrmTeamsBaseRepository>()
                : CrmTeamsRepository()),
        super(const CrmTeamsState());

  void init() {
    emit(state.copyWith(isLoading: true));
    _teamsSubscription?.cancel();
    _teamsSubscription = _repository.watchTeams().listen(
      (Either<Failure, List<CrmTeamModel>> result) {
        result.fold(
          (Failure failure) => emit(state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          )),
          (List<CrmTeamModel> teams) => emit(state.copyWith(
            isLoading: false,
            teams: teams,
          )),
        );
      },
    );

    _loadAvailableEmployees();
  }

  /// Loads real employees from [MainCoreEmployeeController] via the repository.
  /// Call [refreshEmployees] whenever the employee list may have changed.
  Future<void> _loadAvailableEmployees() async {
    final Either<Failure, List<CrmTeamMemberModel>> res =
        await _repository.getAvailableEmployees();
    res.fold(
      (Failure failure) => null,
      (List<CrmTeamMemberModel> employees) => emit(state.copyWith(
        availableEmployees: employees,
      )),
    );
  }

  /// Public entry point to reload the employee list on demand
  /// (e.g. after the ActiveDirectory syncs new employees).
  Future<void> refreshEmployees() => _loadAvailableEmployees();

  void setSelectedTab(int index) {
    emit(state.copyWith(selectedTab: index));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilterType(String? type) {
    emit(state.copyWith(filterType: type, clearFilter: type == null));
  }

  void setSortOption(String? sort) {
    emit(state.copyWith(sortOption: sort));
  }

  void setViewMode(bool isGridView) {
    emit(state.copyWith(isGridView: isGridView));
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  int get totalAllCount => state.teams.length;
  int get totalActiveCount =>
      state.teams.where((CrmTeamModel t) => t.isActive).length;
  int get totalInactiveCount =>
      state.teams.where((CrmTeamModel t) => t.isInactive).length;

  /// Returns only employees eligible to be Team Managers under the business rules:
  /// C-level executive roles (CEO, COO, CFO, CTO, CHRO, CMO, CSO, CDO, CCO, CXO)
  /// or any role containing "manager" / "manger".
  List<CrmTeamMemberModel> get eligibleManagers =>
      state.availableEmployees.where((CrmTeamMemberModel e) => e.isManagerEligible).toList();

  /// Returns all available employees eligible to be team members.
  List<CrmTeamMemberModel> get allMembers => state.availableEmployees;

  List<CrmTeamModel> get visibleTeams {

    List<CrmTeamModel> list = List<CrmTeamModel>.from(state.teams);

    // 1. Status tab filter
    if (state.selectedTab == 1) {
      list = list.where((CrmTeamModel t) => t.isActive).toList();
    } else if (state.selectedTab == 2) {
      list = list.where((CrmTeamModel t) => t.isInactive).toList();
    }

    // 2. Type filter
    if (state.filterType != null && state.filterType!.isNotEmpty) {
      list = list
          .where((CrmTeamModel t) =>
              t.teamType.toLowerCase() == state.filterType!.toLowerCase())
          .toList();
    }

    // 3. Search query
    final String query = state.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((CrmTeamModel t) {
        final bool nameEnMatch = t.nameEn.toLowerCase().contains(query);
        final bool nameArMatch = t.nameAr.toLowerCase().contains(query);
        final bool typeMatch = t.teamType.toLowerCase().contains(query);
        final bool managerMatch =
            t.manager?.name.toLowerCase().contains(query) ?? false;
        return nameEnMatch || nameArMatch || typeMatch || managerMatch;
      }).toList();
    }

    // 4. Sorting
    if (state.sortOption == 'name_asc') {
      list.sort((a, b) => a.displayName.compareTo(b.displayName));
    } else if (state.sortOption == 'name_desc') {
      list.sort((a, b) => b.displayName.compareTo(a.displayName));
    } else if (state.sortOption == 'date_asc') {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      // Default: newest first (date_desc)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  Future<bool> createTeam(CrmTeamModel team) async {
    emit(state.copyWith(isLoading: true));
    final Either<Failure, CrmTeamModel> result =
        await _repository.createTeam(team);
    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (CrmTeamModel created) {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Team created successfully',
        ));
        return true;
      },
    );
  }

  Future<bool> updateTeam(CrmTeamModel team) async {
    emit(state.copyWith(isLoading: true));
    final Either<Failure, CrmTeamModel> result =
        await _repository.updateTeam(team);
    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (CrmTeamModel updated) {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Team updated successfully',
        ));
        return true;
      },
    );
  }

  Future<bool> deleteTeam(String teamId) async {
    emit(state.copyWith(isLoading: true));
    final Either<Failure, void> result =
        await _repository.deleteTeam(teamId);
    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Team deleted successfully',
        ));
        return true;
      },
    );
  }

  Future<bool> toggleTeamStatus(String teamId) async {
    final Either<Failure, CrmTeamModel> result =
        await _repository.toggleTeamStatus(teamId);
    return result.fold(
      (Failure failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (CrmTeamModel updated) => true,
    );
  }

  @override
  Future<void> close() {
    _teamsSubscription?.cancel();
    return super.close();
  }
}
