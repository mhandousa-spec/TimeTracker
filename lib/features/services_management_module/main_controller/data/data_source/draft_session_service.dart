// ******************* FILE INFO *******************
// File Name: draft_session_service
// Description: Holds transient draft-tracking session state for the services flow.
// Module: services_management_module / data / helper
// *************************************************

/// Transient, in-memory session state describing the draft the user is
/// currently editing.
///
/// This was previously kept as mutable fields on `ServicesManagerCubit`, which
/// mixed orchestration with session bookkeeping (§16). Extracting it into a
/// dedicated, injectable service keeps the cubit focused on emitting states.
class DraftSessionService {
  String? _currentDraftId;
  int? _currentDraftPage;

  String? get currentDraftId => _currentDraftId;
  int? get currentDraftPage => _currentDraftPage;

  void setCurrentDraft(String? draftId, int? page) {
    _currentDraftId = draftId;
    _currentDraftPage = page;
  }

  void clear() {
    _currentDraftId = null;
    _currentDraftPage = null;
  }
}
