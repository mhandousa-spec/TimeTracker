// ****************** FILE INFO ******************
// File Name: crm_teams_state.dart
// Purpose: State definition for CRM Team Management Cubit.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';

class CrmTeamsState {
  final bool isLoading;
  final List<CrmTeamModel> teams;
  final List<CrmTeamMemberModel> availableEmployees;
  final int selectedTab; // 0: All, 1: Active, 2: Inactive
  final String searchQuery;
  final String? filterType;
  final String? sortOption; // 'name_asc', 'name_desc', 'date_asc', 'date_desc'
  final bool isGridView;
  final String? errorMessage;
  final String? successMessage;

  const CrmTeamsState({
    this.isLoading = false,
    this.teams = const <CrmTeamModel>[],
    this.availableEmployees = const <CrmTeamMemberModel>[],
    this.selectedTab = 0,
    this.searchQuery = '',
    this.filterType,
    this.sortOption,
    this.isGridView = true,
    this.errorMessage,
    this.successMessage,
  });

  CrmTeamsState copyWith({
    bool? isLoading,
    List<CrmTeamModel>? teams,
    List<CrmTeamMemberModel>? availableEmployees,
    int? selectedTab,
    String? searchQuery,
    String? filterType,
    String? sortOption,
    bool? isGridView,
    String? errorMessage,
    String? successMessage,
    bool clearFilter = false,
  }) {
    return CrmTeamsState(
      isLoading: isLoading ?? this.isLoading,
      teams: teams ?? this.teams,
      availableEmployees: availableEmployees ?? this.availableEmployees,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: clearFilter ? null : (filterType ?? this.filterType),
      sortOption: sortOption ?? this.sortOption,
      isGridView: isGridView ?? this.isGridView,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
