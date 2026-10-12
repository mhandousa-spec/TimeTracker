// ****************** FILE INFO ******************
// File Name: crm_client_activities_state.dart
// Purpose: UI state for client activities.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';

class CrmClientActivitiesState {
  final bool isLoading;
  final bool isSaving;
  final bool isGrid;
  final String status;
  final String query;
  final String? sort;
  final String? error;
  final List<CrmClientActivityModel> activities;
  final List<CrmCategoryModel> categories;
  final List<CrmTagModel> tags;
  const CrmClientActivitiesState(
      {this.isLoading = false,
      this.isSaving = false,
      this.isGrid = false,
      this.status = 'all',
      this.query = '',
      this.sort,
      this.error,
      this.activities = const [],
      this.categories = const [],
      this.tags = const []});
  CrmClientActivitiesState copyWith(
          {bool? isLoading,
          bool? isSaving,
          bool? isGrid,
          String? status,
          String? query,
          String? sort,
          bool clearSort = false,
          String? error,
          bool clearError = false,
          List<CrmClientActivityModel>? activities,
          List<CrmCategoryModel>? categories,
          List<CrmTagModel>? tags}) =>
      CrmClientActivitiesState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          isGrid: isGrid ?? this.isGrid,
          status: status ?? this.status,
          query: query ?? this.query,
          sort: clearSort ? null : (sort ?? this.sort),
          error: clearError ? null : (error ?? this.error),
          activities: activities ?? this.activities,
          categories: categories ?? this.categories,
          tags: tags ?? this.tags);
}
