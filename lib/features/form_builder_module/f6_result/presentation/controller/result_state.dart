import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/user_grid_item.dart';

abstract class ResultState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ResultInitial extends ResultState {}

class ResultLoading extends ResultState {}

class ResultLoaded extends ResultState {
  final FormEntity? formEntity;
  final UserGridItem? selectedUser;
  final List<UserGridItem> pendingUsers;
  final List<UserGridItem> filteredPendingUsers;
  final List<UserGridItem> submittedUsers;
  final List<UserGridItem> filteredSubmittedUsers;
  final List<AnalyticsEntity> analyticsData;
  final bool isSubmitted;
  final bool isReadOnly;
  final List<PageControllerModel> pages;
  final String? selectedDepartmentFilter;
  final TextEditingController searchController;
  final TextEditingController textEditingController;
  final TabController tabController;
  final bool isPendingScreen;
  final bool isGridView;
  final bool isUser;

  ResultLoaded({
    this.formEntity,
    this.selectedUser,
    required this.pendingUsers,
    required this.filteredPendingUsers,
    required this.submittedUsers,
    required this.filteredSubmittedUsers,
    required this.analyticsData,
    this.isSubmitted = true,
    this.isReadOnly = true,
    required this.pages,
    this.selectedDepartmentFilter,
    required this.searchController,
    required this.textEditingController,
    required this.tabController,
    this.isPendingScreen = true,
    this.isGridView = true,
    this.isUser = true,
  });

  ResultLoaded copyWith({
    FormEntity? formEntity,
    UserGridItem? selectedUser,
    List<UserGridItem>? pendingUsers,
    List<UserGridItem>? filteredPendingUsers,
    List<UserGridItem>? submittedUsers,
    List<UserGridItem>? filteredSubmittedUsers,
    List<AnalyticsEntity>? analyticsData,
    bool? isSubmitted,
    bool? isReadOnly,
    List<PageControllerModel>? pages,
    String? selectedDepartmentFilter,
    bool clearDepartmentFilter = false,
    bool? isPendingScreen,
    bool? isGridView,
    bool? isUser,
  }) {
    return ResultLoaded(
      formEntity: formEntity ?? this.formEntity,
      selectedUser: selectedUser ?? this.selectedUser,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      filteredPendingUsers: filteredPendingUsers ?? this.filteredPendingUsers,
      submittedUsers: submittedUsers ?? this.submittedUsers,
      filteredSubmittedUsers: filteredSubmittedUsers ?? this.filteredSubmittedUsers,
      analyticsData: analyticsData ?? this.analyticsData,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      pages: pages ?? this.pages,
      selectedDepartmentFilter: clearDepartmentFilter
          ? null
          : (selectedDepartmentFilter ?? this.selectedDepartmentFilter),
      searchController: searchController,
      textEditingController: textEditingController,
      tabController: tabController,
      isPendingScreen: isPendingScreen ?? this.isPendingScreen,
      isGridView: isGridView ?? this.isGridView,
      isUser: isUser ?? this.isUser,
    );
  }

  @override
  List<Object?> get props => [
    formEntity,
    selectedUser,
    pendingUsers,
    filteredPendingUsers,
    submittedUsers,
    filteredSubmittedUsers,
    analyticsData,
    isSubmitted,
    isReadOnly,
    pages,
    selectedDepartmentFilter,
    isPendingScreen,
    isGridView,
    isUser,
  ];
}

class ResultError extends ResultState {
  final String message;

  ResultError(this.message);

  @override
  List<Object?> get props => [message];
}