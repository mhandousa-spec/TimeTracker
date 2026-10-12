// Module: home/h2_nav_bar
//
//*************************** FILE INFO ****************************///
// File Name: nav_bar_state.dart
// Purpose: Declares `NavBarState`.
// Author: Knowticed Plus team
// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

part of './nav_bar_cubit.dart';

sealed class NavBarState {
  const NavBarState();
}

final class NavBarInitial extends NavBarState {
  const NavBarInitial();
}

final class NavBarLoaded extends NavBarState {
  final List<Modules> navBarModules;
  final List<Modules> moreListModules;
  final bool isLoadingModules;

  const NavBarLoaded({
    required this.navBarModules,
    required this.moreListModules,
    required this.isLoadingModules,
  });
}
