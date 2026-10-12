/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_grant.dart
/// Purpose: Declares `DatabaseAccessGrant`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// One access rule: a permission level, a validity window, and the people it
/// applies to.
///
/// The Figma has two shapes of Review screen and this entity covers both:
///
///   * 7398:17988 — ONE grant with [departmentId] null. Members were picked
///     individually, so there is a single Permissions dropdown and a single
///     date pair for everyone.
///
///   * 7398:18213 — ONE grant PER DEPARTMENT, each with its own Permissions
///     dropdown and dates. That screen's tabs ("5 Marketing", "7 Finance")
///     are one grant each, and the summary tile reads "Custom" when their
///     levels disagree.
///
/// Modelling both as a list of grants means the Review screens differ only in
/// how many they render, not in what they hold.

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

class DatabaseAccessGrant {
  const DatabaseAccessGrant({
    required this.members,
    this.departmentId,
    this.departmentNameEn,
    this.departmentNameAr,
    this.permission,
    this.startDate,
    this.endDate,
    this.viewableFields = const <String>[],
  });

  /// Null when access was granted to individually-picked people rather than
  /// to a whole department (the 7398:17988 shape).
  final String? departmentId;
  final String? departmentNameEn;
  final String? departmentNameAr;

  /// Null until the user chooses one — the dropdown's empty state reads
  /// "Choose Permissions" in the Figma, so null is a real state, not a
  /// missing default.
  final DatabasePermissionLevel? permission;

  final DateTime? startDate;
  final DateTime? endDate;

  final List<DatabaseMember> members;

  /// Which of the table's columns the people on this grant may see — the
  /// "Viewable Fields" control (Figma 7398:14663 / 19078), ADDED 16/8/2026.
  ///
  /// Stored as COLUMN IDS, not names: a column can be renamed and the grant has
  /// to keep pointing at the same field. `TableColumn.id` is what goes in here.
  ///
  /// EMPTY MEANS "EVERYTHING", NOT "NOTHING".
  /// A grant written before this field existed reads back as an empty list, and
  /// those grants gave their holders the whole table. Treating empty as "no
  /// fields" would silently blind every existing user the moment this shipped.
  /// The screens say so too: the control's own empty state reads "All fields",
  /// not "None". Revoking sight of a table is what removing the grant is for.
  ///
  /// Always empty on a DATABASE grant written by the create wizard: a database
  /// has no tables at creation, so there are no columns to choose from yet.
  final List<String> viewableFields;

  bool get isDepartmentScoped => departmentId != null;

  /// True when this grant restricts what its holders can see. The summary tile
  /// and the field's own label both read off this rather than re-deriving
  /// "empty means all" at each call site.
  bool get hasFieldRestriction => viewableFields.isNotEmpty;

  int get memberCount => members.length;

  /// A grant is only complete once it has a level, both dates and at least
  /// one person. "Grant Access" stays disabled while any grant fails this.
  bool get isComplete =>
      permission != null &&
      startDate != null &&
      endDate != null &&
      members.isNotEmpty;

  /// True once the user has filled ANY of the rule fields — a permission level
  /// or either date — regardless of whether anyone has been picked yet.
  ///
  /// ADDED 16/8/2026 so a half-filled rule is not thrown away. On the By
  /// Department screen the rule is filled BEFORE the people (the fields sit
  /// above the employee list), so a grant can legitimately hold dates and no
  /// members for as long as it takes to scroll down and tick someone. Dropping
  /// it as "empty" at that moment blanks the fields the user is still looking
  /// at. See `CreateDatabaseCubit._replaceGrant`.
  bool get hasRule =>
      permission != null || startDate != null || endDate != null;

  /// True when the window is back to front, or has no width at all. Checked
  /// separately from [isComplete] so the screen can say *why* it is refusing.
  ///
  /// TIGHTENED 16/8/2026: this used to be `endDate.isBefore(startDate)`, which
  /// accepted a window that started and ended on the SAME DAY. The end date is
  /// the last day of access, so same-day is a grant that expires the day it is
  /// given — almost always a mis-tap on the second picker, and impossible to
  /// tell apart from a real intention after the fact. The end must now be
  /// strictly after the start.
  ///
  /// Compared by DAY, not by timestamp. The picker returns midnight, but a
  /// grant read back from Firestore carries whatever time it was stored with,
  /// and two dates on the same calendar day that differ by an hour must not
  /// read as a valid one-hour window.
  bool get hasInvalidDateRange {
    final DateTime? start = startDate;
    final DateTime? end = endDate;
    if (start == null || end == null) return false;
    return !dateOnly(end).isAfter(dateOnly(start));
  }

  /// [value] with its time of day dropped. Public because the date pickers
  /// need the same notion of "a day" when they compute their bounds — two
  /// definitions of midnight is how a field ends up rejecting what its own
  /// picker just offered.
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String localizedDepartmentName({required bool isArabic}) {
    if (isArabic) {
      return (departmentNameAr?.isNotEmpty ?? false)
          ? departmentNameAr!
          : (departmentNameEn ?? '');
    }
    return (departmentNameEn?.isNotEmpty ?? false)
        ? departmentNameEn!
        : (departmentNameAr ?? '');
  }

  DatabaseAccessGrant copyWith({
    String? departmentId,
    String? departmentNameEn,
    String? departmentNameAr,
    DatabasePermissionLevel? permission,
    DateTime? startDate,
    DateTime? endDate,
    List<DatabaseMember>? members,
    List<String>? viewableFields,
    bool clearPermission = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return DatabaseAccessGrant(
      departmentId: departmentId ?? this.departmentId,
      departmentNameEn: departmentNameEn ?? this.departmentNameEn,
      departmentNameAr: departmentNameAr ?? this.departmentNameAr,
      permission: clearPermission ? null : (permission ?? this.permission),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      members: members ?? this.members,
      // No `clearViewableFields` flag: an empty list is already the "no
      // restriction" value, so passing `<String>[]` says it outright. The flags
      // above exist because null and "unset" are different for those three.
      viewableFields: viewableFields ?? this.viewableFields,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'department_id': departmentId,
        'department_name_en': departmentNameEn,
        'department_name_ar': departmentNameAr,
        'permission': permission?.storageKey,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'members':
            members.map((DatabaseMember m) => m.toMap()).toList(growable: false),
        // Denormalised so the list screen can show a count without reading
        // every member row.
        'member_count': members.length,
        'viewable_fields': viewableFields,
      };

  factory DatabaseAccessGrant.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawMembers =
        (map['members'] as List<dynamic>?) ?? const <dynamic>[];

    return DatabaseAccessGrant(
      departmentId: map['department_id'] as String?,
      departmentNameEn: map['department_name_en'] as String?,
      departmentNameAr: map['department_name_ar'] as String?,
      permission:
          DatabasePermissionLevel.fromStorageKey(map['permission'] as String?),
      startDate: DateTime.tryParse((map['start_date'] as String?) ?? ''),
      endDate: DateTime.tryParse((map['end_date'] as String?) ?? ''),
      members: rawMembers
          .whereType<Map<String, dynamic>>()
          .map(DatabaseMember.fromMap)
          .toList(growable: false),
      // Absent on every grant written before 16/8/2026, which reads back as an
      // empty list — "all fields", the access those grants actually gave.
      viewableFields: ((map['viewable_fields'] as List<dynamic>?) ??
              const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}
