/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_cubit.dart
/// Purpose: Loads the calendar's events and exposes them as state.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Added for CR-SKEL-CAL-N06 / N08. The feature had **no** `presentation/
/// controller/` at all: both pages constructed `CalendarDataService` in
/// `initState` and ran the multi-step fetch inside a `try` in the widget. The
/// two copies had also drifted — `home_calendar_page` fetched seven sources,
/// `calendar_screen` only five, so role-management and user-access events were
/// missing from the full calendar screen but present on the home card.

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/features/calendar/c1_calendar/data/data_source/calendar_data_service.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

part './calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required MainCoreDepartmentCubit departmentCubit,
    CalendarDataService? dataService,
  })  : _dataService = dataService ??
            CalendarDataService(departmentCubit: departmentCubit),
        super(const CalendarState());

  final CalendarDataService _dataService;

  @override
  void emit(CalendarState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// How long any single event source gets before it is abandoned for this
  /// load. Seven independent Firestore queries mean seven chances to hang; one
  /// of them stalling used to hold the whole calendar on its spinner
  /// indefinitely, because `Future.wait` only completes when every future does.
  static const Duration _perSourceTimeout = Duration(seconds: 12);

  /// Function Name: [load]
  ///
  /// Purpose: Fetch every event source for one user and publish them as they
  /// arrive.
  ///
  /// Parameters:
  /// - [currentUserEmail]: the signed-in user. An empty value yields an empty
  ///   calendar rather than an error — that is what both pages did.
  ///
  /// PERFORMANCE / ROBUSTNESS 22/8/2026 — "loading too much" on the home card.
  ///
  /// The seven sources were already fetched concurrently, but through a bare
  /// `Future.wait`, which has two properties that produced the endless
  /// spinner:
  ///
  ///  1. **All-or-nothing timing.** Nothing was published until the *slowest*
  ///     of the seven finished, so six fast queries were held hostage by one
  ///     slow one. There is no reason for that: the calendar renders fine with
  ///     a partial set and simply gains dots as the rest land.
  ///  2. **All-or-nothing failure.** `Future.wait` rejects as soon as any one
  ///     future throws, discarding the results of the six that succeeded — the
  ///     calendar went from "loading" straight to empty-with-an-error.
  ///
  /// Each source now runs guarded and time-boxed, publishes into the state the
  /// moment it returns, and a source that fails or times out costs only its
  /// own events.
  Future<void> load({required String currentUserEmail}) async {
    if (currentUserEmail.isEmpty) {
      emit(state.copyWith(
        status: CalendarStatus.success,
        events: const <CalendarEventModel>[],
      ));
      return;
    }

    emit(state.copyWith(
      status: CalendarStatus.loading,
      events: const <CalendarEventModel>[],
      errorMessage: null,
    ));

    final List<CalendarEventModel> collected = <CalendarEventModel>[];
    final List<String> failures = <String>[];

    final Map<String, Future<List<CalendarEventModel>> Function()> sources =
        <String, Future<List<CalendarEventModel>> Function()>{
      'services': () => _dataService.getServicesCalendarEvents(
          currentUserEmail: currentUserEmail),
      'approvals': () => _dataService.getApprovalCalendarEvents(
          currentUserEmail: currentUserEmail),
      'qiyas': () => _dataService.getQiyasCalendarEvents(
          currentUserEmail: currentUserEmail),
      'knowledge hub': () => _dataService.getKnowledgeHubCalendarEvents(
          currentUserEmail: currentUserEmail),
      'todo': () => _dataService.getTodoCalendarEvents(
          currentUserEmail: currentUserEmail),
      // ADDED 9/10/2026 — Time Tracker phase 6: approved leaves, pending
      // requests, transactions, late / absent days, approvals waiting.
      'time tracker': () => _dataService.getTimeTrackerCalendarEvents(
          currentUserEmail: currentUserEmail),
      'role management': () => _dataService.getRoleManagementCalendarEvents(
          currentUserEmail: currentUserEmail),
      'user access': () => _dataService.getUserAccessCalendarEvents(
          currentUserEmail: currentUserEmail),
      // ADDED 25/8/2026 — the eighth source. Settings change requests
      // (profile / health insurance / emergency contact): pending review for
      // whoever holds `Users_Requests`, and the request's own lifecycle for
      // the employee who raised it.
      'settings requests': () => _dataService.getSettingsCalendarEvents(
          currentUserEmail: currentUserEmail),
      // ADDED 13/9/2026 — the ninth source. GRC module activation dates: the
      // date itself, a reminder 14 days out, and a card when the date moves.
      'grc': () => _dataService.getGrcCalendarEvents(
          currentUserEmail: currentUserEmail),
      // ADDED 14/9/2026 — the tenth source. GRC policy start/end dates: the
      // start date, a card when it moves, the end date, a reminder 14 days
      // before expiry, an "expires today" on the day, and a card when the end
      // date moves. Kept as its own source so one failing does not take the
      // module's activation cards down with it.
      'grc policy': () => _dataService.getGrcPolicyCalendarEvents(
          currentUserEmail: currentUserEmail),
      // ADDED 16/9/2026 — the eleventh source. GRC controls, Control
      // Champions, Control Owners and reassignment requests: assignment start
      // dates, submission due dates (defined / 14 days / today / overdue),
      // date moves, and pending / approved reassignments.
      'grc control': () => _dataService.getGrcControlCalendarEvents(
          currentUserEmail: currentUserEmail),
      // ADDED 27/9/2026 — entries written by the Home "Apply all modules"
      // button (DemoAccountsSeeder): one of every calendar event type.
      'seeded demo': () => _dataService.getSeededCalendarEvents(
          currentUserEmail: currentUserEmail),
    };

    await Future.wait(
      sources.entries.map(
        (MapEntry<String, Future<List<CalendarEventModel>> Function()> entry) =>
            _collect(entry.key, entry.value, collected, failures),
      ),
    );

    if (isClosed) return;

    emit(state.copyWith(
      // A partial calendar is still a usable calendar, so anything less than a
      // total wipe-out reads as success. Only "every source failed" is a
      // failure the user needs told about.
      status: failures.length == sources.length
          ? CalendarStatus.failure
          : CalendarStatus.success,
      events: _sorted(collected),
      errorMessage: failures.isEmpty
          ? null
          : 'Could not load: ${failures.join(', ')}.',
    ));
  }

  /// Function Name: [_collect]
  ///
  /// Purpose: Run one event source, append whatever it returns to [collected],
  /// and publish the running total straight away.
  ///
  /// Errors and timeouts are recorded in [failures] and swallowed, so one bad
  /// source cannot take the other six down with it.
  Future<void> _collect(
    String label,
    Future<List<CalendarEventModel>> Function() fetch,
    List<CalendarEventModel> collected,
    List<String> failures,
  ) async {
    try {
      final List<CalendarEventModel> events =
          await fetch().timeout(_perSourceTimeout);

      if (isClosed) return;

      collected.addAll(events);

      // Publish as we go: the month grid and its dots fill in progressively
      // instead of the card sitting on a spinner until the last query lands.
      emit(state.copyWith(events: _sorted(collected)));
    } catch (e, stackTrace) {
      failures.add(label);
      debugPrint('CalendarCubit: "$label" events failed — $e\n$stackTrace');
    }
  }

  /// A date-ordered copy, so [state.events] is never the same growing list the
  /// loads are still appending to.
  List<CalendarEventModel> _sorted(List<CalendarEventModel> events) =>
      List<CalendarEventModel>.from(events)
        ..sort((CalendarEventModel a, CalendarEventModel b) =>
            a.date.compareTo(b.date));
}
