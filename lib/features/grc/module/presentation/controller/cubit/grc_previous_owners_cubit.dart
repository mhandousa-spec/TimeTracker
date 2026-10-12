/// Module: GRC Module Management
/// Description: BLoC Cubit that manages the Previous Module Owners page's
///              state. Delegates to GetGRCModuleOwnerHistoryUseCase and
///              emits typed GrcPreviousOwnersState subclasses.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: flutter_bloc, GetGRCModuleOwnerHistoryUseCase, GRCModuleOwnerHistoryEntry
/// Revision History: 2026-07-13 - Initial creation
library;

import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_owner_history_entry.dart';
import 'package:knowticed_plus/features/grc/module/domain/use_cases/get_grc_module_owner_history_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'grc_previous_owners_state.dart';

/// class name: [GrcPreviousOwnersCubit]
///
/// purpose: load and expose the completed owner history for one GRC Module.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 13/7/2026
class GrcPreviousOwnersCubit extends Cubit<GrcPreviousOwnersState> {
  GrcPreviousOwnersCubit({
    required GetGRCModuleOwnerHistoryUseCase getOwnerHistoryUseCase,
  })  : _getOwnerHistoryUseCase = getOwnerHistoryUseCase,
        super(GrcPreviousOwnersInitial());

  final GetGRCModuleOwnerHistoryUseCase _getOwnerHistoryUseCase;

  Future<void> loadHistory(String moduleId) async {
    emit(GrcPreviousOwnersLoading());
    final result = await _getOwnerHistoryUseCase.execute(moduleId);
    result.fold(
      (failure) => emit(GrcPreviousOwnersFailure(failure.message)),
      (entries) => emit(GrcPreviousOwnersLoaded(entries)),
    );
  }
}
