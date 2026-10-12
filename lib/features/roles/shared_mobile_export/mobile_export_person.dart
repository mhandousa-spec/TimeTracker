/// Module: roles / shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_person.dart
/// Purpose: Declares `MobileExportPerson`.
/// Author: Knowticed Plus team
/// Created At: 9/9/2026
///
/// The employee row the two mobile export flows show, reduced to the four
/// fields the Figma card actually draws (MESBAH / ROLE MANAGEMENT, nodes
/// 6975:23900 and 6976:24560): avatar, name, department, job title.
///
/// It exists because the two flows read from different sources — Active
/// Directory previews rows of the uploaded CSV (`List<List<dynamic>>`, no
/// entity anywhere), System Logs previews the people behind
/// `SystemLogsModel` — and neither of those is a `UserPermissionEntity`, which
/// is what `PersonStateView` takes. One value type in front of the card keeps
/// a single widget serving both instead of two near-identical cards.

class MobileExportPerson {
  const MobileExportPerson({
    required this.id,
    required this.name,
    required this.department,
    required this.jobTitle,
    this.imagePath = '',
    this.gender,
  });

  /// Stable identity for selection — the employee id, or the e-mail when the
  /// source has no id. Selection is keyed on this rather than on the list
  /// index, so a search that reorders the list cannot move a tick.
  final String id;

  final String name;
  final String department;
  final String jobTitle;

  /// Photo URL when there is one; anything that is not an http(s) URL makes
  /// the card fall back to the gender avatar, exactly as `PersonStateView`
  /// does.
  final String imagePath;

  /// 'male' / 'female'. Null falls back to the female avatar, matching
  /// `PersonStateView._buildAvatar`.
  final String? gender;

  /// Everything the preview search box matches against, lower-cased once.
  String get searchIndex =>
      '$name $department $jobTitle'.toLowerCase();
}
