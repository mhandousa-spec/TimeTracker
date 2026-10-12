/// Module: messaging / connections / presentation/controller/connections_controller.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_controller.dart
/// Purpose: Connections controller — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../../../core/helper/message_module/interface/entity/user_connection_interface_parameters.dart';
import '../../../m1_chat/data/repository/single_chat_repository.dart';
import '../../../m1_chat/presentation/controller/main_controllers/master_chat_cubit.dart';
import '../../../m1_chat/presentation/controller/main_controllers/single_chat_cubit.dart';
import '../../../m1_chat/presentation/ui/pages/chat_mobile_view.dart';
import '../../../m3_groups/presentation/controller/groups_controller.dart';
import '../../../m4_messaging_home/domain/enums/sort_enum.dart';
import '../../domain/base_repository/base_connections_repository.dart';
import '../../domain/entities/single_connection_entity.dart';
import '../../domain/usecases/create_new_connection_use_case.dart';
import '../../domain/usecases/get_all_app_users_in_connection_form.dart';

// ─────────────────────────────────────────────────────────────
// State classes
// ─────────────────────────────────────────────────────────────

abstract class ConnectionsState {}

class ConnectionsInitial extends ConnectionsState {}

class ConnectionsLoading extends ConnectionsState {}

class ConnectionsLoaded extends ConnectionsState {
  final List<SingleConnectionEntity> connections;
  final List<SingleConnectionEntity> filteredConnections;
  final SingleConnectionEntity? selectedConnection;
  final Map<String, int> categoriesUsersCount;

  ConnectionsLoaded({
    required this.connections,
    required this.filteredConnections,
    this.selectedConnection,
    required this.categoriesUsersCount,
  });

  ConnectionsLoaded copyWith({
    List<SingleConnectionEntity>? connections,
    List<SingleConnectionEntity>? filteredConnections,
    SingleConnectionEntity? selectedConnection,
    Map<String, int>? categoriesUsersCount,
    bool clearSelectedConnection = false,
  }) {
    return ConnectionsLoaded(
      connections: connections ?? this.connections,
      filteredConnections: filteredConnections ?? this.filteredConnections,
      selectedConnection: clearSelectedConnection
          ? null
          : selectedConnection ?? this.selectedConnection,
      categoriesUsersCount: categoriesUsersCount ?? this.categoriesUsersCount,
    );
  }
}

class ConnectionsError extends ConnectionsState {
  final String message;
  ConnectionsError(this.message);
}

// ─────────────────────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────────────────────

class ConnectionsCubit extends Cubit<ConnectionsState> {
  final ConnectionsRepositoryInterface repository;

  ConnectionsCubit({required this.repository}) : super(ConnectionsInitial());

  late BaseMessagingInterfaceParameters currentUser;

  /// ✅ Guard: safely check if currentUser has been initialized
  bool get isCurrentUserInitialized {
    try {
      final _ = currentUser;
      return true;
    } catch (_) {
      return false;
    }
  }

  late Future<List<UserConnectionInterfaceParameters>> Function()
  getAllUsersDate;
  List<UserCategory>? categories;

  Map<String, int> categoriesUsersCount = {};
  SingleConnectionEntity? _selectedConnection;
  SingleConnectionEntity? get selectedConnection => _selectedConnection;
  List<SingleConnectionEntity> _connections = [];
  List<SingleConnectionEntity> get connections => _connections;
  List<SingleConnectionEntity> filteredConnections = [];

  late TextEditingController searchController;
  SortEnum? sortType;
  late UserCategory selectedTab;

  void initialize({
    required TextEditingController searchController,
    required SortEnum? sortType,
    required UserCategory selectedTab,
  }) {
    this.searchController = searchController;
    this.sortType = sortType;
    this.selectedTab = selectedTab;
  }

  // ─────────────────────────────────────────────────────────
  // getAllAppUsersInConnectionForm
  // ─────────────────────────────────────────────────────────
  // FIXED 21/9/2026 — "Direct Message is empty on this account".
  //
  // Every call (HomePageHelper calls this on each build of the Messages
  // page, openChatWithUser calls it too) used to (1) wipe `_connections` and
  // `filteredConnections` straight away and (2) attach ANOTHER listener
  // without cancelling the previous one. The list reads the
  // `filteredConnections` field, so from the wipe until the new stream's
  // first event it was empty — and if that first event never re-emitted a
  // state (or an older listener, even one bound to the account signed in
  // before, fired last) the Direct Message list stayed empty while the
  // category counts, which come from the last emitted state, still showed
  // chats. Now there is ONE live subscription, and the lists are only
  // cleared when the signed-in user actually changed.
  StreamSubscription<dynamic>? _connectionsSubscription;
  String? _connectionsLoadedFor;

  // FIXED 24/9/2026 — realtime chat list. If the connections stream errored
  // or completed, the list (last message, unread count, new chats) froze
  // until the app was restarted. It now re-attaches itself with back-off.
  Timer? _connectionsRetryTimer;
  int _connectionsRetryAttempt = 0;

  void _scheduleConnectionsResubscribe() {
    if (isClosed) return;
    _connectionsRetryTimer?.cancel();
    final int seconds = 1 <<
        (_connectionsRetryAttempt < 4 ? _connectionsRetryAttempt : 4);
    _connectionsRetryAttempt++;
    _connectionsRetryTimer = Timer(Duration(seconds: seconds), () {
      if (isClosed) return;
      getAllAppUsersInConnectionForm();
    });
  }

  @override
  Future<void> close() async {
    _connectionsRetryTimer?.cancel();
    await _connectionsSubscription?.cancel();
    return super.close();
  }

  /// Drops everything that belongs to the previous signed-in user.
  ///
  /// ADDED 30/9/2026 (Messages QA p.1 — "this chat is related to another user,
  /// every direct chat must belong to one specific user"). This cubit is a
  /// permanent GetX instance that outlives a sign-out, so after switching
  /// accounts it still held the old user's chat list, their open conversation
  /// ([_selectedConnection]) and a live listener on their connections. Called
  /// from `MessagingInitController.useGroupAndSingleMessaging` on every sign-in.
  Future<void> resetForNewUser() async {
    _connectionsRetryTimer?.cancel();
    _connectionsRetryAttempt = 0;
    _connections = [];
    filteredConnections = [];
    _selectedConnection = null;
    _connectionsLoadedFor = null;
    categoriesUsersCount = {};
    final StreamSubscription<dynamic>? old = _connectionsSubscription;
    _connectionsSubscription = null;
    if (!isClosed) emit(ConnectionsInitial());
    await old?.cancel();
  }

  Future<void> getAllAppUsersInConnectionForm() async {
    _connectionsRetryTimer?.cancel();
    await _connectionsSubscription?.cancel();
    _connectionsSubscription = null;
    if (_connectionsLoadedFor != currentUser.userId) {
      _connections = [];
      filteredConnections = [];
      _connectionsLoadedFor = currentUser.userId;
    }

    log('🔄 getAllAppUsersInConnectionForm: starting stream...');

    _connectionsSubscription =
        GetAllAppUsersInConnectionFormUseCase(connectionRepository: repository)
        .execute(
      currentUserId: currentUser.userId,
      getAllUsers: getAllUsersDate,
      categories: categories!,
    )
        .listen((event) {
      if (isClosed) return;
      log("📡 stream at connections at controller level is called");

      if (event.isRight()) {
        _connectionsRetryAttempt = 0;
        _connections = event.getOrElse(() => []);
        log("✅ Total connections loaded: ${_connections.length}");

        for (var c in _connections) {
          log(
              "  → name: ${c.primaryLanguageName} | messageType: ${c.messageType} | isNone: ${c.messageType == MessageTypes.none}");
        }

        _getCategoriesUsersCount();
        filteredSingleConnections();
        _updateSelectedConnection();

        log(
            "✅ filteredConnections after filter: ${filteredConnections.length}");

        emit(ConnectionsLoaded(
          connections: _connections,
          filteredConnections: filteredConnections,
          selectedConnection: _selectedConnection,
          categoriesUsersCount: categoriesUsersCount,
        ));
      } else {
        log('❌ error: ${event.leftMap((l) => l.errMessage)}');
        // Keep showing the last good list; just reconnect.
        if (_connections.isEmpty) {
          emit(ConnectionsError(
              event.fold((l) => l.errMessage, (r) => 'Unknown error')));
        }
        _scheduleConnectionsResubscribe();
      }
    }, onError: (Object error, StackTrace stackTrace) {
      // Error handling moved out of the domain use case (§11.2): the stream
      // now surfaces failures here so the cubit can emit an error state.
      log('❌ stream error in getAllAppUsersInConnectionForm: $error');
      if (isClosed) return;
      if (_connections.isEmpty) emit(ConnectionsError(error.toString()));
      _scheduleConnectionsResubscribe();
    }, onDone: () {
      log('⚠️ connections stream closed — reconnecting');
      _scheduleConnectionsResubscribe();
    }, cancelOnError: false);

    log('📤 getAllAppUsersInConnectionForm: listener attached');
  }

  // ─────────────────────────────────────────────────────────
  // createNewConnection
  // ─────────────────────────────────────────────────────────
  Future<Either<Failure, void>> createNewConnection({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters newConnectionUser,
  }) async {
    log('🔗 creating new connection');
    return await CreateNewConnectionUseCase(connectionRepository: repository)
        .createNewConnection(
      currentUser: currentUser,
      newConnectionUser: newConnectionUser,
    );
  }

  // ─────────────────────────────────────────────────────────
  // filteredSingleConnections
  // ─────────────────────────────────────────────────────────
  void filteredSingleConnections() {
    log(
        '🔍 filteredSingleConnections: searchText="${searchController.text}"');
    filteredConnections = [];

    if (searchController.text.isEmpty) {
      noSearchFilteredData();
    } else {
      searchFilteredData();
    }

    sortConnections();

    log("🔍 filteredSingleConnections result: ${filteredConnections.length}");

    if (state is ConnectionsLoaded) {
      emit((state as ConnectionsLoaded).copyWith(
        filteredConnections: filteredConnections,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────
  // searchFilteredData
  // ─────────────────────────────────────────────────────────
  void searchFilteredData() {
    log("🔎 searchFilteredData: _connections.length=${_connections.length}");
    for (SingleConnectionEntity connection in _connections) {
      bool isSelected = false;

      isSelected |= connection.primaryLanguageName
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

      if (connection.secondaryLanguageName != null)
        isSelected |= connection.secondaryLanguageName!
            .toLowerCase()
            .contains(searchController.text.toLowerCase());

      if (connection.primaryLanguageSubInfo != null)
        isSelected |= connection.primaryLanguageSubInfo!
            .toLowerCase()
            .contains(searchController.text.toLowerCase());

      if (connection.secondaryLanguageSubInfo != null)
        isSelected |= connection.secondaryLanguageSubInfo!
            .toLowerCase()
            .contains(searchController.text.toLowerCase());

      if (selectedTab.categoryId != categories![0].categoryId) {
        isSelected &=
            connection.userCategory?.categoryId == selectedTab.categoryId;
      }

      if (isSelected) {
        filteredConnections.add(connection);
      }
    }
    log("🔎 searchFilteredData result: ${filteredConnections.length}");
  }

  // ─────────────────────────────────────────────────────────
  // noSearchFilteredData
  // ─────────────────────────────────────────────────────────
  void noSearchFilteredData() {
    log(
        "📋 noSearchFilteredData: _connections.length=${_connections.length}");
    filteredConnections = [];

    for (SingleConnectionEntity connection in _connections) {
      bool isSelected = true;

      // ⚠️ Comment out the line below to also show connections with no messages yet:
      isSelected &= connection.messageType != MessageTypes.none;

      log(
          "  📌 ${connection.primaryLanguageName} | messageType: ${connection.messageType} | passes filter: $isSelected");

      if (selectedTab.categoryId != categories![0].categoryId) {
        isSelected &=
            connection.userCategory?.categoryId == selectedTab.categoryId;
      }

      if (isSelected) {
        log("  ✅ added: ${connection.primaryLanguageName}");
        filteredConnections.add(connection);
      }
    }

    log("📋 noSearchFilteredData result: ${filteredConnections.length}");
  }

  // ─────────────────────────────────────────────────────────
  // selectSingleConnection
  // ─────────────────────────────────────────────────────────
  // FIXED 24/9/2026 — groups could not be opened after a direct message.
  // The chat panel (TabletChatSide / TabletLayoutBody) shows the single chat
  // whenever a connection is selected, and nothing ever cleared it, so a
  // click on a group changed GroupsCubit but the panel kept the single chat.
  // Selecting a group now clears the selected connection, and vice versa.
  void clearSelectedConnection() {
    _selectedConnection = null;
    if (state is ConnectionsLoaded) {
      emit((state as ConnectionsLoaded)
          .copyWith(clearSelectedConnection: true));
    }
  }

  void selectSingleConnection(SingleConnectionEntity connection) {
    _selectedConnection = connection;

    if (state is ConnectionsLoaded) {
      emit((state as ConnectionsLoaded).copyWith(
        selectedConnection: connection,
      ));
    }
  }

  void _updateSelectedConnection() {
    if (_selectedConnection == null) return;
    try {
      for (var connection in _connections) {
        if (connection.connectionId == _selectedConnection?.connectionId) {
          _selectedConnection = connection;
          break;
        }
      }
    } catch (e) {
      log('⚠️ _updateSelectedConnection error: $e');
    }
  }

  void _getCategoriesUsersCount() {
    if (categories == null) {
      log('⚠️ _getCategoriesUsersCount: categories is null, skipping');
      return;
    }

    categoriesUsersCount = {};
    for (var category in categories!) {
      categoriesUsersCount[category.categoryId] = 0;
    }

    for (var connection in _connections) {
      if (connection.userCategory != null &&
          connection.messageType != MessageTypes.none) {
        categoriesUsersCount[categories![0].categoryId] =
            (categoriesUsersCount[categories![0].categoryId] ?? 0) + 1;
        categoriesUsersCount[connection.userCategory!.categoryId] =
            (categoriesUsersCount[connection.userCategory!.categoryId] ?? 0) +
                1;
      }
    }

    log("📊 categoriesUsersCount: $categoriesUsersCount");
  }

  List<SingleConnectionEntity> getAllConnections() {
    log("📦 getAllConnections: ${_connections.length}");
    return _connections;
  }

  void sortConnections() {
    if (sortType == null) {
      log("⏭️ sortConnections: sortType is null, skipping");
      return;
    }
    switch (sortType!) {
      case SortEnum.ReadMessages:
        filteredConnections.sort(
                (a, b) => b.myNumUnreadMessage.compareTo(a.myNumUnreadMessage));
        break;
      case SortEnum.UnRead:
        filteredConnections.sort(
                (a, b) => a.myNumUnreadMessage.compareTo(b.myNumUnreadMessage));
        break;
    }
  }

  Future<void> selectConnection(
      SingleConnectionEntity connection, BuildContext context) async {
    log("🚀 selectConnection: ${connection.primaryLanguageName}");
    // Deselect any open group so the two selections never compete.
    if (Get.isRegistered<GroupsCubit>()) {
      Get.find<GroupsCubit>().clearSelectedGroup();
    }
    selectSingleConnection(connection);

    final singleChatCubit = context.read<SingleChatCubit>();

    await singleChatCubit.startChat(
      otherSideData: _selectedConnection!,
      currentUserData: currentUser,
    );

    singleChatCubit.getFirstUnreadIndex();

    if (MediaQuery.of(context).size.width >= 600) {
      log("📱 selectConnection: tablet mode, staying on same page");
    } else {
      log("📱 selectConnection: mobile mode, navigating to chat...");

      // ── Pure Bloc: push ChatMobileView with the active cubits (§3) ──
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatMobileView(
            masterChatCubit: singleChatCubit,
            connectionsCubit: this,
          ),
        ),
      );
    }
  }
}