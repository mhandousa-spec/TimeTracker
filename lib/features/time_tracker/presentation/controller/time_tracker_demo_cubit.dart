/// Module: time_tracker / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_cubit.dart
/// Purpose: Declares `TimeTrackerDemoCubit` + `TimeTrackerDemoState` — the
///          DEBUG-ONLY "Load demo data" / "Remove demo data" actions of the
///          🧪 button in the Time Tracker header.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — demo data, like To-Do's
///            `TodoListCubit.loadDemoTodos` / `removeDemoTodos`)
///
/// Only reachable from a widget built under `kDebugMode`. All work is done
/// by `TimeTrackerDemoService`; this cubit keeps the busy flag (a second tap
/// is ignored) and turns failures into a clean result. Deleting the demo
/// PDFs is best effort: a file that is already gone does not fail Remove.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_service.dart';

/// Busy while a load / remove runs.
class TimeTrackerDemoState {
  const TimeTrackerDemoState({this.isBusy = false});

  final bool isBusy;
}

/// The outcome shown to the developer.
class TimeTrackerDemoOutcome {
  const TimeTrackerDemoOutcome({
    required this.ok,
    this.documents = 0,
    this.files = 0,
    this.alreadyLoaded = false,
    this.errorMessage = '',
  });

  final bool ok;
  final int documents;
  final int files;
  final bool alreadyLoaded;
  final String errorMessage;
}

class TimeTrackerDemoCubit extends Cubit<TimeTrackerDemoState> {
  TimeTrackerDemoCubit({required TimeTrackerDemoService service})
      : _service = service,
        super(const TimeTrackerDemoState());

  final TimeTrackerDemoService _service;

  @override
  void emit(TimeTrackerDemoState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [load]
  ///
  /// Purpose: Write the demo data (free texts in the app language).
  ///
  /// Return type: [Future<TimeTrackerDemoOutcome>]
  Future<TimeTrackerDemoOutcome> load({required bool isArabic}) async {
    if (state.isBusy) return const TimeTrackerDemoOutcome(ok: false);
    emit(const TimeTrackerDemoState(isBusy: true));
    try {
      final TtDemoResult r = await _service.load(isArabic: isArabic);
      return TimeTrackerDemoOutcome(
        ok: true,
        documents: r.documents,
        files: r.files,
        alreadyLoaded: r.alreadyLoaded,
      );
    } catch (error) {
      return TimeTrackerDemoOutcome(ok: false, errorMessage: error.toString());
    } finally {
      emit(const TimeTrackerDemoState());
    }
  }

  /// Function Name: [remove]
  ///
  /// Purpose: Delete every demo document, then (best effort) its PDFs.
  ///
  /// Return type: [Future<TimeTrackerDemoOutcome>]
  Future<TimeTrackerDemoOutcome> remove() async {
    if (state.isBusy) return const TimeTrackerDemoOutcome(ok: false);
    emit(const TimeTrackerDemoState(isBusy: true));
    try {
      final TtDemoResult r = await _service.remove();
      int files = 0;
      for (final String url in r.fileUrls) {
        try {
          await _service.deleteFile(url);
          files++;
        } catch (_) {
          // Already gone / no access: the document is deleted, the file is
          // only test data — Remove still succeeds (reported count is lower).
          continue;
        }
      }
      return TimeTrackerDemoOutcome(ok: true, documents: r.documents, files: files);
    } catch (error) {
      return TimeTrackerDemoOutcome(ok: false, errorMessage: error.toString());
    } finally {
      emit(const TimeTrackerDemoState());
    }
  }
}
