/// Module: time_tracker / tt7_groups / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: group_form_state.dart
/// Purpose: Declares `GroupFormState` (+ `GroupFormError`) — the Create /
///          Edit Group draft, whether its errors are shown and the picture
///          upload progress.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:95712` (create) / `661:96092` (edit) + a Members picker (the
/// Figma form has none, but a group needs members — its details page lists
/// them). Rules shared with the Grant Access dialog (`AssignmentRules`).
/// Create grey until valid; Save grey until something changed (owner rules).

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';

/// Updated: 9/10/2026 - decision 32: the Arabic name is required too (the
/// Locations rule); descriptions in both languages.
enum GroupFormError { nameRequired, nameArRequired, descriptionTooLong, membersRequired }

class GroupFormState {
  const GroupFormState({
    required this.draft,
    this.original,
    this.showErrors = false,
    this.isUploading = false,
    this.uploadFailed = false,
  });

  static const int maxDescriptionLength = 500;

  final EmployeeGroup draft;

  /// The stored group being edited (null = creating).
  final EmployeeGroup? original;
  final bool showErrors;
  final bool isUploading;
  final bool uploadFailed;

  bool get isEdit => original != null;

  Set<GroupFormError> get groupErrors => <GroupFormError>{
        if (draft.name.trim().isEmpty) GroupFormError.nameRequired,
        if (draft.nameAr.trim().isEmpty) GroupFormError.nameArRequired,
        if (draft.description.length > maxDescriptionLength ||
            draft.descriptionAr.length > maxDescriptionLength)
          GroupFormError.descriptionTooLong,
        if (draft.memberEmails.isEmpty) GroupFormError.membersRequired,
      };

  Set<AssignmentError> get ruleErrors => AssignmentRules.validate(
        locationId: draft.locationId,
        startDate: draft.startDate,
        rules: draft.rules,
      );

  bool get isDirty {
    final EmployeeGroup? b = original;
    if (b == null) return true;
    final EmployeeGroup a = draft;
    String key(EmployeeGroup g) => <Object?>[
          g.name.trim(), g.nameAr.trim(), g.description.trim(), g.descriptionAr.trim(), g.imageUrl,
          (List<String>.of(g.memberEmails)..sort()).join(','), g.rules.isCustom,
          g.locationId, g.startDate?.toIso8601String().substring(0, 10), g.rules.isBreakAllowed,
          g.rules.breakMinutes, g.rules.isPauseAllowed, g.rules.pauseMinutes, g.rules.isDifferentLocationAllowed,
          g.rules.allowedLocationIds.join(','),
        ].join('|');
    return key(a) != key(b);
  }

  bool get canSubmit => groupErrors.isEmpty && ruleErrors.isEmpty && isDirty && !isUploading;

  bool shows(GroupFormError e) => showErrors && groupErrors.contains(e);
  bool showsRule(AssignmentError e) => showErrors && ruleErrors.contains(e);

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [GroupFormState]
  GroupFormState copyWith({
    EmployeeGroup? draft,
    bool? showErrors,
    bool? isUploading,
    bool? uploadFailed,
  }) =>
      GroupFormState(
        draft: draft ?? this.draft,
        original: original,
        showErrors: showErrors ?? this.showErrors,
        isUploading: isUploading ?? this.isUploading,
        uploadFailed: uploadFailed ?? this.uploadFailed,
      );
}
