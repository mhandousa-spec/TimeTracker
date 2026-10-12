// Module: home/h3_app_drawer
//
//*************************** FILE INFO ****************************///
// File Name: app_drawer_state.dart
// Purpose: Declares `AppDrawerState`.
// Author: Knowticed Plus team
// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

part of './app_drawer_cubit.dart';

sealed class AppDrawerState {
  const AppDrawerState();
}

final class AppDrawerInitial extends AppDrawerState {
  const AppDrawerInitial();
}

final class AppDrawerLoaded extends AppDrawerState {
  final List<Modules> allowedDrawerModules;
  final int selectedIndex;
  final bool isLoadingModules;

  /// Whether drawer reordering mode is on.
  ///
  /// This used to be a module-global `RxBool isDrawerReorderingActive` declared
  /// in `custom_drawer.dart` and mutated from the home-layout editor in another
  /// feature. It is real drawer state, so it lives here.
  final bool isReorderingActive;

  const AppDrawerLoaded({
    required this.allowedDrawerModules,
    required this.selectedIndex,
    required this.isLoadingModules,
    this.isReorderingActive = false,
  });
}
