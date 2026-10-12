/// Module: messaging / home / presentation/controller/messaging_home_controller.dart
/// ************************* FILE INFO *************************** ///
/// File Name: messaging_home_controller.dart
/// Purpose: Messaging home controller — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';

import '../../../../../core/helper/message_module/interface/entity/user_category.dart';

import '../../domain/enums/sort_enum.dart';

// State classes
abstract class MessagingHomeState {}

class MessagingHomeInitial extends MessagingHomeState {}

class MessagingHomeLoaded extends MessagingHomeState {
  final UserCategory selectedTab;
  final SortEnum? sort;
  final String selectedAllTab;
  final bool? showAdditionalInfo;

  MessagingHomeLoaded({
    required this.selectedTab,
    this.sort,
    required this.selectedAllTab,
    this.showAdditionalInfo,
  });

  MessagingHomeLoaded copyWith({
    UserCategory? selectedTab,
    SortEnum? sort,
    String? selectedAllTab,
    bool? showAdditionalInfo,
    bool clearSort = false,
  }) {
    return MessagingHomeLoaded(
      selectedTab: selectedTab ?? this.selectedTab,
      sort: clearSort ? null : (sort ?? this.sort),
      selectedAllTab: selectedAllTab ?? this.selectedAllTab,
      showAdditionalInfo: showAdditionalInfo ?? this.showAdditionalInfo,
    );
  }
}

// Cubit with dependency injection
class MessagingHomeCubit extends Cubit<MessagingHomeState> {
  final ConnectionsCubit connectionsCubit;
  final GroupsCubit groupsCubit;

  MessagingHomeCubit({
    required this.connectionsCubit,
    required this.groupsCubit,
  }) : super(MessagingHomeInitial());

  List<UserCategory>? categories;
  late UserCategory _selectedTab;
  UserCategory get selectedTab => _selectedTab;

  SortEnum? _sort;
  SortEnum? get sort => _sort;

  final searchController = TextEditingController();

  String _selectedAllTab = "Direct Messages";
  String get selectedAllTab => _selectedAllTab;

  List<String> allTabs = [
    'Direct Messages',
    'Groups',
  ];

  bool? showAdditionalInfo;

  void initialize({required UserCategory initialTab}) {
    _selectedTab = initialTab;
    emit(MessagingHomeLoaded(
      selectedTab: _selectedTab,
      sort: _sort,
      selectedAllTab: _selectedAllTab,
      showAdditionalInfo: showAdditionalInfo,
    ));
  }

  void updateAllTabs(int index) {
    _selectedAllTab = allTabs[index];
    _emitLoadedState(updateId: 'allTabs');
  }

  void filterAllChats() {
    filterGroupChats();
    filterSingleChats();
  }

  void filterGroupChats() {
    groupsCubit.filterGroups();
  }

  void filterSingleChats() {
    connectionsCubit.filteredSingleConnections();
  }

  void filterByCategory(UserCategory category) {
    _selectedTab = category;
    connectionsCubit.selectedTab = category; // Update the connections cubit's selected tab
    _emitLoadedState();
    connectionsCubit.filteredSingleConnections();
  }

  void sortChats(dynamic value) {
    if (_sort == value)
      _sort = null;
    else
      _sort = value;

    _emitLoadedState(clearSort: _sort == null);
    connectionsCubit.filteredSingleConnections();
    groupsCubit.filterGroups();
  }

  // Helper method to emit loaded state
  void _emitLoadedState({String? updateId, bool clearSort = false}) {
    if (state is MessagingHomeLoaded) {
      emit((state as MessagingHomeLoaded).copyWith(
        selectedTab: _selectedTab,
        sort: _sort,
        selectedAllTab: _selectedAllTab,
        showAdditionalInfo: showAdditionalInfo,
        clearSort: clearSort,
      ));
    } else {
      emit(MessagingHomeLoaded(
        selectedTab: _selectedTab,
        sort: _sort,
        selectedAllTab: _selectedAllTab,
        showAdditionalInfo: showAdditionalInfo,
      ));
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}