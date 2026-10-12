/// Module: Assignment Controls (Control Champion)
/// Description: BLoC Cubit that loads and exposes the Submission History
///              (one card per distinct file ever submitted) for a single
///              Control+Champion Assignment Control, shown on
///              MyAuditDetailsPage's Submission tab. Deliberately separate
///              from MyAuditCubit: MyAuditDetailsPage is pushed with the
///              *same* MyAuditCubit instance the My Audits list page uses
///              (BlocProvider.value in my_audits_list_page.dart), so
///              emitting a history-only state on that shared cubit would
///              leave the list page's own BlocBuilder (which only
///              recognizes MyAuditListLoaded) showing a broken/loading view
///              the next time the user navigates back to it.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-29
/// Dependencies: flutter_bloc, GetSubmissionHistoryUseCase, SubmissionHistoryEntry
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/use_cases/get_submission_history_usecase.dart';

part 'submission_history_state.dart';

class SubmissionHistoryCubit extends Cubit<SubmissionHistoryState> {
  SubmissionHistoryCubit({
    required GetSubmissionHistoryUseCase getSubmissionHistoryUseCase,
  })  : _getSubmissionHistoryUseCase = getSubmissionHistoryUseCase,
        super(SubmissionHistoryInitial());

  final GetSubmissionHistoryUseCase _getSubmissionHistoryUseCase;

  Future<void> loadHistory({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) async {
    emit(SubmissionHistoryLoading());
    final result = await _getSubmissionHistoryUseCase.call(
      moduleId: moduleId,
      controlId: controlId,
      championEmail: championEmail,
    );
    result.fold(
      (failure) => emit(SubmissionHistoryFailure(failure.message)),
      (entries) => emit(SubmissionHistoryLoaded(entries)),
    );
  }
}
