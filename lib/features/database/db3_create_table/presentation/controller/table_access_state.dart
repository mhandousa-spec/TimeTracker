/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_access_state.dart
/// Purpose: Declares `TableAccessState` and `TableAccessStatus`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026

part of './table_access_cubit.dart';

enum TableAccessStatus { initial, submitting, success, failure }

@immutable
class TableAccessState {
  const TableAccessState({
    required this.table,
    this.grant = const DatabaseAccessGrant(members: <DatabaseMember>[]),
    this.original,
    this.recordId = '',
    this.memberFields = const <String, List<String>>{},
    this.removedMembers = const <RemovedAccessMember>[],
    this.employees = const <DatabaseMember>[],
    this.departments = const <DatabaseDepartment>[],
    this.searchQuery = '',
    this.departmentFilter,
    this.isLoading = true,
    this.status = TableAccessStatus.initial,
    this.errorMessage,
  });

  final DatabaseTableEntity table;

  /// THE rule being edited. One, not a list.
  ///
  /// db1's review screen renders one grant per department because its Figma
  /// draws department tabs; the table screens (7398:13651 / 14122 / 14553) draw
  /// a single Permissions block, a single date pair and a single Viewable
  /// Fields control over one flat list of people. So this screen edits one
  /// grant and `save` writes one document — the subcollection is REPLACED, so
  /// any extra rows an earlier writer left behind are swept in the same batch.
  final DatabaseAccessGrant grant;

  /// Viewable Fields PER MEMBER — employee id -> column ids.
  ///
  /// Figma 7398:14122 (cards) and 7398:14296 (list) give every person their own
  /// Viewable Fields control, which the single [grant] cannot express: two
  /// people on one table can be shown different columns, and that is the whole
  /// point of the screen.
  ///
  /// An employee with no entry falls back to [grant.viewableFields] — the set
  /// chosen on step 1 — so picking ten people and narrowing the columns once
  /// still does the obvious thing. See [fieldsFor].
  ///
  /// Saved as one grant document per DISTINCT field set, not one per person:
  /// ten people who see the same columns are one rule, and writing ten
  /// identical documents would make that rule ten things to keep in step.
  final Map<String, List<String>> memberFields;

  /// The rule as loaded. [isDirty] compares against this and "Discard Changes"
  /// restores it. Null until the first load lands.
  final DatabaseAccessGrant? original;

  /// Document id of the grant being edited, so a save rewrites the same row
  /// instead of creating a fresh one on every edit.
  final String recordId;

  /// People whose access was taken away in this session.
  ///
  /// Kept rather than simply dropped, for the same reason db2 keeps them: the
  /// Access table's "Removed" status is a row about someone who no longer has a
  /// grant, and deleting them from `members` on save would make that row
  /// impossible to render. See `RemovedAccessMember`.
  final List<RemovedAccessMember> removedMembers;

  final List<DatabaseMember> employees;
  final List<DatabaseDepartment> departments;

  final String searchQuery;

  /// Narrows the picker to one department. Null is "all departments".
  final String? departmentFilter;

  final bool isLoading;
  final TableAccessStatus status;
  final String? errorMessage;

  // ── Derived ──────────────────────────────────────────────────────────────

  bool get isSubmitting => status == TableAccessStatus.submitting;

  List<DatabaseMember> get selectedMembers => grant.members;

  bool isSelected(DatabaseMember member) => grant.members.contains(member);

  /// The directory after the search box and the department dropdown.
  ///
  /// Matched against BOTH names regardless of the UI locale: someone searching
  /// an Arabic interface for "Mona" is searching for a colleague they know by
  /// the English spelling, and refusing to find them would be a bug they could
  /// not explain.
  List<DatabaseMember> get visibleEmployees {
    final String needle = searchQuery.trim().toLowerCase();
    final String? department = departmentFilter;

    return employees.where((DatabaseMember m) {
      if (department != null && m.departmentId != department) return false;
      if (needle.isEmpty) return true;
      return m.nameEn.toLowerCase().contains(needle) ||
          m.nameAr.toLowerCase().contains(needle);
    }).toList(growable: false);
  }

  /// Drives whether the pill reads "Select All" or "Deselect All".
  ///
  /// Scoped to what is VISIBLE, not to the whole directory: the button sits
  /// beside a search box, and "Select All" that quietly picked 400 filtered-out
  /// people would be the most destructive control on the screen.
  bool get allVisibleSelected {
    final List<DatabaseMember> visible = visibleEmployees;
    if (visible.isEmpty) return false;
    return visible.every(grant.members.contains);
  }

  /// What the Viewable Fields control offers: this table's own columns.
  ///
  /// Unnamed columns are skipped — a table saved with a blank heading would
  /// otherwise put an empty row in the menu that nobody can tell apart from the
  /// next one.
  /// The columns [member] may see. Falls back to the grant's own set.
  List<String> fieldsFor(DatabaseMember member) =>
      memberFields[member.employeeId] ?? grant.viewableFields;

  /// True once the permission and the two dates are known.
  ///
  /// They are NOT edited on the review screen (7398:14122 draws neither), so
  /// they arrive from the grant that was created earlier and this screen simply
  /// carries them. The rule fields are rendered ONLY when this is false — a
  /// table nobody has ever granted access to has no permission to inherit, and
  /// without one Save could never enable.
  bool get hasInheritedRule =>
      grant.permission != null &&
      grant.startDate != null &&
      grant.endDate != null;

  List<ViewableFieldOption> get fieldOptions => <ViewableFieldOption>[
        for (final TableColumn column in table.columns)
          if (column.isNamed)
            ViewableFieldOption(id: column.id, label: column.name.trim()),
      ];

  /// "Total Departments / 3" — distinct departments among the picked people,
  /// not among the whole directory.
  int get totalDepartments => grant.members
      .map((DatabaseMember m) => m.departmentId)
      .whereType<String>()
      .where((String id) => id.isNotEmpty)
      .toSet()
      .length;

  /// Every grant field is required before access can be given: a level, both
  /// dates, and somebody to give it to. Viewable Fields is NOT in that list —
  /// choosing none means the whole table, which is a valid answer.
  bool get canSave => grant.isComplete && !grant.hasInvalidDateRange;

  bool get isDirty {
    final DatabaseAccessGrant? loaded = original;
    if (loaded == null) return grant.members.isNotEmpty;

    return grant.permission != loaded.permission ||
        grant.startDate != loaded.startDate ||
        grant.endDate != loaded.endDate ||
        removedMembers.isNotEmpty ||
        !_sameMembers(grant.members, loaded.members) ||
        !_sameFields(grant.viewableFields, loaded.viewableFields);
  }

  /// Membership, not order — the picker appends in tap order and a reload
  /// returns Firestore's, so comparing sequences would call every freshly
  /// opened screen dirty.
  static bool _sameMembers(List<DatabaseMember> a, List<DatabaseMember> b) {
    if (a.length != b.length) return false;
    return a.toSet().containsAll(b);
  }

  static bool _sameFields(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    return a.toSet().containsAll(b);
  }

  String departmentNameFor(String? id, {required bool isArabic}) {
    if (id == null || id.isEmpty) return '';
    for (final DatabaseDepartment d in departments) {
      if (d.id == id) return isArabic ? d.nameAr : d.nameEn;
    }
    return '';
  }

  TableAccessState copyWith({
    DatabaseTableEntity? table,
    DatabaseAccessGrant? grant,
    DatabaseAccessGrant? original,
    String? recordId,
    Map<String, List<String>>? memberFields,
    List<RemovedAccessMember>? removedMembers,
    List<DatabaseMember>? employees,
    List<DatabaseDepartment>? departments,
    String? searchQuery,
    String? departmentFilter,
    bool? isLoading,
    TableAccessStatus? status,
    String? errorMessage,
    bool clearDepartmentFilter = false,
    bool clearErrorMessage = false,
  }) {
    return TableAccessState(
      table: table ?? this.table,
      grant: grant ?? this.grant,
      original: original ?? this.original,
      recordId: recordId ?? this.recordId,
      memberFields: memberFields ?? this.memberFields,
      removedMembers: removedMembers ?? this.removedMembers,
      employees: employees ?? this.employees,
      departments: departments ?? this.departments,
      searchQuery: searchQuery ?? this.searchQuery,
      departmentFilter: clearDepartmentFilter
          ? null
          : (departmentFilter ?? this.departmentFilter),
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
