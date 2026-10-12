/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_file_pick_guard.dart
/// Purpose: Declares `TimeTrackerFilePickGuard` — ONE platform file / image
///          picker in flight at a time for every Time Tracker upload and
///          import (request form, transaction form, group picture, CSV /
///          Excel imports).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (QA KP-TT-012)
///
/// QA KP-TT-012 (Major): picking a new attachment in the request form
/// failed 4 times out of 5 with `PlatformException(multiple_request,
/// Cancelled by a second request)`. The native `file_picker` keeps ONE
/// pending call: a second `pickFiles` while one is still pending (double
/// tap, a re-entrant call, or a native picker that is still closing) is
/// refused with that code.
///   * [run] lets ONE pick through at a time, module-wide (the native picker
///     is a single shared resource); a call while one is open is ignored
///     (answers null, like a cancelled pick) — never a second native call;
///   * when the native side still answers `multiple_request` (the previous
///     native picker has not finished closing — `file_picker` 10.x keeps its
///     pending call until the picker reports back), the pick is retried
///     ONCE after [retryDelay]; a second refusal is reported to the form
///     ("Could not upload the file. Please try again.").
/// The forms also disable their Upload button while a pick / upload runs.
///
/// No `try` here (house rule): the retry is a `Future.catchError`.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TimeTrackerFilePickGuard {
  const TimeTrackerFilePickGuard._();

  /// The plugin error code of a refused second request.
  static const String multipleRequestCode = 'multiple_request';

  /// How long to let a closing native picker finish before the one retry
  /// (tests set it to zero).
  static Duration retryDelay = const Duration(milliseconds: 600);

  static bool _busy = false;

  /// A pick is open now.
  static bool get isBusy => _busy;

  /// Function Name: [run]
  ///
  /// Purpose: Open the picker through [pick] unless one is already open.
  ///
  /// Parameters:
  ///   [Future<T?> Function()] pick: the actual picker call.
  ///
  /// Return type: [Future<T?>] — null when ignored (a pick is already open)
  /// or cancelled; other errors propagate to the caller.
  static Future<T?> run<T>(Future<T?> Function() pick) {
    if (_busy) return Future<T?>.value();
    _busy = true;
    return _attempt<T>(pick)
        .catchError((Object error) => _retry<T>(pick), test: isMultipleRequest)
        .whenComplete(() => _busy = false);
  }

  /// One call of [pick] as a `Future<T?>` of its own (the picker's future
  /// may be a narrower `Future<T>`, which `catchError` could not complete
  /// with the retry's `T?`); a synchronous throw becomes an error event.
  static Future<T?> _attempt<T>(Future<T?> Function() pick) async => await pick();

  /// The one retry, after [retryDelay].
  static Future<T?> _retry<T>(Future<T?> Function() pick) async {
    await Future<void>.delayed(retryDelay);
    return pick();
  }

  /// Function Name: [isMultipleRequest]
  ///
  /// Purpose: [error] is the plugin's "Cancelled by a second request".
  ///
  /// Return type: [bool]
  static bool isMultipleRequest(Object error) =>
      error is PlatformException && error.code == multipleRequestCode;

  /// Tests only: forget a pick left open by a failed test.
  @visibleForTesting
  static void reset() => _busy = false;
}
