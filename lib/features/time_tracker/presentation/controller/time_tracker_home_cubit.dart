/// Module: time_tracker / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_home_cubit.dart
/// Purpose: Declares `TimeTrackerHomeCubit` — loads whether the company has
///          HR, works out the tabs the signed-in user may see, keeps the
///          selected tab / header state, and starts the absent-day sweep.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
/// Updated: 8/10/2026 - phase 2: tab selection, Hide / Expand, and the
///          fire-and-forget `AbsentDaySweeper` run (owner decision 20).
/// Updated: 9/10/2026 - phase 4: [init] `preferredTab` (a notification's
///          View lands on the Requests / Approvals tab under the details).
///
/// Async work starts in [init] (called by the entry), never in the
/// constructor. Emit-after-close is guarded (playbook §3).

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/absent_day_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_state.dart';

class TimeTrackerHomeCubit extends Cubit<TimeTrackerHomeState> {
  TimeTrackerHomeCubit({
    required TimeTrackerAccess access,
    required WorkSetupSourceResolver resolver,
    AbsentDaySweeper? sweeper,
  })  : _access = access,
        _resolver = resolver,
        _sweeper = sweeper,
        super(const TimeTrackerHomeState());

  final TimeTrackerAccess _access;
  final WorkSetupSourceResolver _resolver;
  final AbsentDaySweeper? _sweeper;

  /// The last sweep's failure ('' = none / not run). Kept for diagnostics;
  /// a failed sweep never blocks the page — the next open retries.
  String lastSweepError = '';

  @override
  void emit(TimeTrackerHomeState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Read the company licence, publish the visible tabs, then run
  /// the absent-day sweep in the background. [preferredTab] is selected
  /// when the user may see it.
  ///
  /// Return type: [Future<void>]
  Future<void> init({TimeTrackerTab? preferredTab}) async {
    emit(state.copyWith(status: TimeTrackerHomeStatus.loading, errorMessage: ''));
    try {
      final bool hasHr = await _resolver.hasHrModule();
      final List<TimeTrackerTab> tabs = _access.visibleTabs(companyHasHr: hasHr);
      final TimeTrackerTab? selected = preferredTab ?? state.selectedTab;
      emit(TimeTrackerHomeState(
        status: TimeTrackerHomeStatus.success,
        companyHasHr: hasHr,
        tabs: tabs,
        selectedTab: selected != null && tabs.contains(selected)
            ? selected
            : (tabs.isEmpty ? null : tabs.first),
        headerExpanded: state.headerExpanded,
        canCheckIn: _access.canCheckInAndOut,
        hasHrDashboard: _access.canViewHrDashboard,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: TimeTrackerHomeStatus.failure,
        errorMessage: error.toString(),
      ));
      return;
    }
    // Fire-and-forget: the page never waits for the sweep.
    sweepAbsentDays();
  }

  /// Function Name: [sweepAbsentDays]
  ///
  /// Purpose: Write the signed-in user's missing `absent` days (owner
  /// decision 20). Failures are recorded in [lastSweepError] only.
  ///
  /// Return type: [Future<int>] — days created.
  Future<int> sweepAbsentDays() async {
    final AbsentDaySweeper? sweeper = _sweeper;
    if (sweeper == null || !_access.canCheckInAndOut) return 0;
    try {
      lastSweepError = '';
      return await sweeper.sweep();
    } catch (error) {
      lastSweepError = error.toString();
      return 0;
    }
  }

  /// Function Name: [selectTab]
  ///
  /// Purpose: Open [tab] (ignored when the user may not see it).
  ///
  /// Return type: [void]
  void selectTab(TimeTrackerTab tab) {
    if (!state.tabs.contains(tab) || tab == state.selectedTab) return;
    emit(state.copyWith(selectedTab: tab));
  }

  /// Function Name: [toggleHeader]
  ///
  /// Purpose: Hide / Expand the profile card.
  ///
  /// Return type: [void]
  void toggleHeader() =>
      emit(state.copyWith(headerExpanded: !state.headerExpanded));
}
