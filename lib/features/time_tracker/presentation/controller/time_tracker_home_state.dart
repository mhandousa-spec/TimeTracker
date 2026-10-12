/// Module: time_tracker / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_home_state.dart
/// Purpose: Declares `TimeTrackerHomeState` (+ `TimeTrackerHomeStatus`) —
///          the module main page: the tabs this user may see, the selected
///          tab, whether the profile card is expanded, whether they can check
///          in, and who owns the set-up data.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
/// Updated: 8/10/2026 - phase 2: `selectedTab`, `headerExpanded`.
///
/// One immutable state + `copyWith` + status enum (playbook §3).

import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';

enum TimeTrackerHomeStatus { initial, loading, success, failure }

class TimeTrackerHomeState {
  const TimeTrackerHomeState({
    this.status = TimeTrackerHomeStatus.initial,
    this.tabs = const <TimeTrackerTab>[],
    this.selectedTab,
    this.headerExpanded = true,
    this.canCheckIn = false,
    this.hasHrDashboard = false,
    this.companyHasHr = false,
    this.errorMessage = '',
  });

  final TimeTrackerHomeStatus status;
  final List<TimeTrackerTab> tabs;

  /// The open tab (null when the user sees no tab at all).
  final TimeTrackerTab? selectedTab;

  /// "Hide" / "Expand" of the profile card (Figma 661:13832 = collapsed).
  final bool headerExpanded;
  final bool canCheckIn;

  /// The dashboard tab is titled "Overview" (HR view available).
  final bool hasHrDashboard;

  /// HR owns locations / shifts / assignments.
  final bool companyHasHr;
  final String errorMessage;

  bool get isLoading =>
      status == TimeTrackerHomeStatus.initial ||
      status == TimeTrackerHomeStatus.loading;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [TimeTrackerHomeState]
  TimeTrackerHomeState copyWith({
    TimeTrackerHomeStatus? status,
    List<TimeTrackerTab>? tabs,
    TimeTrackerTab? selectedTab,
    bool? headerExpanded,
    bool? canCheckIn,
    bool? hasHrDashboard,
    bool? companyHasHr,
    String? errorMessage,
  }) =>
      TimeTrackerHomeState(
        status: status ?? this.status,
        tabs: tabs ?? this.tabs,
        selectedTab: selectedTab ?? this.selectedTab,
        headerExpanded: headerExpanded ?? this.headerExpanded,
        canCheckIn: canCheckIn ?? this.canCheckIn,
        hasHrDashboard: hasHrDashboard ?? this.hasHrDashboard,
        companyHasHr: companyHasHr ?? this.companyHasHr,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
