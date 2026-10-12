/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: current_user_context.dart
/// Purpose: Declares `CurrentUserContext`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// ******************* FILE INFO *******************
// File Name: current_user_context
// Description: Holder for the current signed-in user's identity.
//              Populated by the presentation layer (MainCoreEmployeeController)
//              at login so that data/* (repository, prefs helpers) can read the
//              current user's email WITHOUT importing presentation controllers.
//              This breaks the data -> presentation dependency (R01).
// Module: core / helper / main_helper
// Note: relocated here from services_management_module/main_controller/data/
//       data_source so it can be shared by modules outside that feature.
// *************************************************

class CurrentUserContext {
  CurrentUserContext._();

  /// Email of the currently signed-in user. Set by the presentation layer
  /// whenever the active employee changes; cleared (set to null) on sign-out.
  static String? email;
}
