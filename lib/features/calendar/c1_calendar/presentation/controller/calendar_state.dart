/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_state.dart
/// Purpose: States for CalendarCubit.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026

part of './calendar_cubit.dart';

enum CalendarStatus { initial, loading, success, failure }

@immutable
class CalendarState {
  const CalendarState({
    this.status = CalendarStatus.initial,
    this.events = const <CalendarEventModel>[],
    this.errorMessage,
  });

  final CalendarStatus status;

  /// Every event the signed-in user can see, sorted by date.
  final List<CalendarEventModel> events;

  /// Why the last load failed. Both pages used to swallow this in an empty
  /// `catch` and simply stop the spinner, so a failed load looked exactly like
  /// an empty calendar (CR-SKEL-CAL-N08).
  final String? errorMessage;

  bool get isLoading => status == CalendarStatus.loading;

  CalendarState copyWith({
    CalendarStatus? status,
    List<CalendarEventModel>? events,
    Object? errorMessage = _unset,
  }) {
    return CalendarState(
      status: status ?? this.status,
      events: events ?? this.events,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// Sentinel so `copyWith` can tell "leave unchanged" from "set to null".
const Object _unset = Object();
