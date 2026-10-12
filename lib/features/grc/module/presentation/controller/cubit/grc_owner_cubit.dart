import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'grc_owner_state.dart';

class OwnerData {
  final String id;
  final String name;
  final String email;
  final String department;
  final String jobTitle;
  final String photo;
  bool isSelected;

  OwnerData({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.jobTitle,
    required this.photo,
    this.isSelected = false,
  });
}

class GrcOwnerCubit extends Cubit<GrcOwnerState> {
  GrcOwnerCubit() : super(GrcOwnerInitial());

  final TextEditingController searchController = TextEditingController();

  List<OwnerData> _allOwners = [];
  List<OwnerData> filteredOwners = [];
  String _searchQuery = '';
  List<String>? _selectedDepartmentNames;
  List<String> _excludedEmails = const [];

  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerEmails = const [],
    String? selectedDepartmentName,
    List<String>? selectedDepartmentNames,
    List<String> excludeEmails = const [],
  }) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return;
    final ctrl = Get.find<MainCoreEmployeeController>();
    final employees = ctrl.allEmployeesEntities ?? [];
    _allOwners = employees.map((e) {
      return OwnerData(
        id: e.id ?? '',
        name: EmployeeHelper.getEmployeeLocalizedName(employee: e, context: context),
        email: e.email ?? '',
        department: EmployeeHelper.getEmployeeLocalizeDepartment(employee: e, context: context),
        jobTitle: EmployeeHelper.getEmployeeLocalizedTitle(employee: e, context: context)?.toString() ?? '',
        photo: EmployeeHelper.getEmployeeImage(employee: e),
        isSelected: initialOwnerEmails.contains(e.email ?? ''),
      );
    }).toList();
    _selectedDepartmentNames = selectedDepartmentNames ??
        (selectedDepartmentName == null ? null : [selectedDepartmentName]);
    _excludedEmails = excludeEmails;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  /// Restricts the visible owners to those belonging to [departmentName].
  /// Pass null to clear the department filter and show everyone again.
  void filterByDepartment(String? departmentName) {
    filterByDepartments(departmentName == null ? null : [departmentName]);
  }

  /// Restricts the visible owners to those belonging to any department in
  /// [departmentNames]. Pass null (or empty) to clear the filter and show
  /// everyone again. A Control can be scoped to several departments at
  /// once, unlike a Module (single department), hence the list form.
  void filterByDepartments(List<String>? departmentNames) {
    if (_listEquals(_selectedDepartmentNames, departmentNames)) return;
    _selectedDepartmentNames = departmentNames;
    _applyFilters();
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Hides whoever is in [emails] from the picker entirely — used so a
  /// person already picked as this Control's Champion can't also be picked
  /// as its Owner (and vice versa). Pass an empty list to clear.
  void filterByExcludedEmails(List<String> emails) {
    if (_listEquals(_excludedEmails, emails)) return;
    _excludedEmails = emails;
    _applyFilters();
  }

  void _applyFilters() {
    filteredOwners = _sortSelectedFirst(_allOwners.where((o) {
      final matchesDepartment = _selectedDepartmentNames == null ||
          _selectedDepartmentNames!.isEmpty ||
          _selectedDepartmentNames!.contains(o.department);
      final matchesSearch = _searchQuery.isEmpty ||
          o.name.toLowerCase().contains(_searchQuery) ||
          o.department.toLowerCase().contains(_searchQuery) ||
          o.jobTitle.toLowerCase().contains(_searchQuery);
      final notExcluded = !_excludedEmails.contains(o.email);
      return matchesDepartment && matchesSearch && notExcluded;
    }).toList());
    emit(GrcOwnerLoaded());
  }

  /// Ticked people first, everyone else after, each group keeping the order it
  /// already had.
  ///
  /// ADDED 13/9/2026. The picker lists every employee, so an owner chosen from
  /// halfway down scrolled out of sight the moment the user moved on — there
  /// was no way to see who was picked without scrolling the whole list and
  /// hunting for ticks.
  ///
  /// Partitioned rather than sorted on purpose: `List.sort` is NOT stable in
  /// Dart, so sorting on a boolean would shuffle people arbitrarily within
  /// each group and the list would reorder itself for no visible reason.
  /// Two `where` passes preserve the incoming order exactly.
  List<OwnerData> _sortSelectedFirst(List<OwnerData> owners) {
    return <OwnerData>[
      ...owners.where((OwnerData o) => o.isSelected),
      ...owners.where((OwnerData o) => !o.isSelected),
    ];
  }

  /// When [singleSelect] is true, selecting one person clears every other
  /// selection first (so exactly one, or zero, [OwnerData] ends up selected)
  /// instead of the default multi-select toggle.
  void toggleOwner(int index, {bool singleSelect = false}) {
    final tapped = filteredOwners[index];
    if (singleSelect) {
      final wasSelected = tapped.isSelected;
      for (final owner in _allOwners) {
        owner.isSelected = false;
      }
      tapped.isSelected = !wasSelected;
    } else {
      tapped.isSelected = !tapped.isSelected;
    }

    // Re-partition so the person just ticked moves to the front immediately,
    // rather than only after the next search or department change. `tapped`
    // was captured by reference before this, so reordering the list cannot
    // make the index stale.
    //
    // NOTE: the grid does visibly reflow on each tap — that is the point of
    // selected-first, but it means the card under the pointer changes after a
    // tap, so this is not a list to tick through quickly without looking.
    filteredOwners = _sortSelectedFirst(filteredOwners);
    emit(GrcOwnerLoaded());
  }

  /// Same as [toggleOwner] but by identity rather than by index into
  /// [filteredOwners] — for callers that render a different subset than
  /// [filteredOwners] (e.g. the collapsed single-select view, which shows
  /// only the chosen person).
  void toggleOwnerData(OwnerData tapped, {bool singleSelect = false}) {
    final int index = filteredOwners.indexOf(tapped);
    if (index >= 0) {
      toggleOwner(index, singleSelect: singleSelect);
      return;
    }
    // Not in the filtered list (hidden by the search text): flip it directly.
    if (singleSelect) {
      final bool wasSelected = tapped.isSelected;
      for (final owner in _allOwners) {
        owner.isSelected = false;
      }
      tapped.isSelected = !wasSelected;
    } else {
      tapped.isSelected = !tapped.isSelected;
    }
    filteredOwners = _sortSelectedFirst(filteredOwners);
    emit(GrcOwnerLoaded());
  }

  List<OwnerData> get selectedOwners =>
      _allOwners.where((o) => o.isSelected).toList();

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
