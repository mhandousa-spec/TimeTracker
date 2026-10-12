/// Firestore document field keys reused verbatim by 2 or more GRC models.
/// Keys used by only one model stay as private static consts on that
/// model instead of here — see Code Quality Standards.md's Model Class
/// rule ("static constants for database keys, not hardcoded literals").
library;

abstract class GrcFirestoreKeys {
  /// Used by ControlModel, AssigningControlModel, PolicyModel.
  static const String policyId = 'Policy_ID';

  /// Used by GRCModuleModel, GrcRequestModel, PolicyModel.
  static const String moduleId = 'Module_ID';

  /// Used by ControlModel, ChampionModel, OwnerModel, GRCModuleModel,
  /// PolicyModel — every model with a change-history list of editors.
  static const String modifiers = 'Modifiers';

  /// Used by the same 5 models as [modifiers], always alongside it.
  static const String modificationDate = 'Modification_Date';

  /// Used by ChampionModel and OwnerModel for their assigning-controls
  /// history list.
  static const String assigningControls = 'Assigning_Controls';
}
