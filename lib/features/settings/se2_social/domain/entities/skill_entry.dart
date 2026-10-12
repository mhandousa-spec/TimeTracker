/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: skill_entry.dart
/// Purpose: One skill on an employee's social profile.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N02. A skill was previously spread across three
/// parallel structures on the controller — `skillsFields[i]['skillName']`,
/// `skillsControllers[i]` and `skillss[i]` — that the UI had to keep in sync by
/// hand at every keystroke (CR-SKEL-SE2-N18).

import 'package:flutter/foundation.dart';

@immutable
class SkillEntry {
  const SkillEntry({this.name = '', this.level = ''});

  /// Firestore stores a skill as `{'items': [name, level?]}`.
  static const String fieldItems = 'items';

  final String name;

  /// Optional proficiency. Persisted as the second element of `items`.
  final String level;

  bool get isEmpty => name.trim().isEmpty;

  /// The read-only label the list used to build by hand: `name - level`, or
  /// just `name` when there is no level.
  String get label =>
      level.trim().isEmpty ? name : '${name.trim()} - ${level.trim()}';

  SkillEntry copyWith({String? name, String? level}) =>
      SkillEntry(name: name ?? this.name, level: level ?? this.level);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillEntry && other.name == name && other.level == level;

  @override
  int get hashCode => Object.hash(name, level);

  @override
  String toString() => 'SkillEntry($name, $level)';
}
