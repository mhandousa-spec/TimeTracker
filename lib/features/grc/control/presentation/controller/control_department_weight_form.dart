/// Module: GRC Policy Management
/// Description: Department selection + per-department weight state for the
///              Add/Edit Control form, extracted from AddEditControlPage so
///              the page itself only holds UI-orchestration state.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter, DepartmentWeight, formatControlWeight
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own controller class
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_department_weight_form.dart
/// Purpose: Contains ControlDepartmentWeightForm, which owns the Department
///          multi-select selection, the Equal Weights toggle, and every
///          per-department weight TextEditingController — plus the
///          reconciliation rules for all three (checking "All", equal
///          split, add/remove a department). None of its methods call
///          setState; the page wraps each call with its own setState so
///          this class stays free of any Flutter widget/State dependency.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:knowticed_plus/features/grc/control/domain/entities/control_department_weight.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:flutter/widgets.dart';

/// class name: [ControlDepartmentWeightForm]
///
/// purpose: - [selectedDepartments] holds every checked value from the
///            Department multi-select, including the [allDepartmentsValue]
///            sentinel when "All" is checked. [realSelectedDepartments]
///            strips that sentinel out.
///          - Checking "All" (or manually checking every real department)
///            selects every department and forces [equalWeights] on, since
///            an all-department split is always equal by definition.
///          - Otherwise [equalWeights] is user-controlled: true auto-splits
///            100 evenly across the selected departments, false requires a
///            manual weight per department (summing to 100) via
///            [departmentWeightControllers].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlDepartmentWeightForm {
  static const String allDepartmentsValue = 'All';

  bool equalWeights = true;
  List<String> selectedDepartments = [];
  final Map<String, TextEditingController> departmentWeightControllers = {};

  /// Every checked department, minus the [allDepartmentsValue] sentinel.
  List<String> get realSelectedDepartments =>
      selectedDepartments.where((d) => d != allDepartmentsValue).toList();

  bool get isAllDepartmentsSelected =>
      selectedDepartments.contains(allDepartmentsValue);

  double get totalDepartmentsWeight => departmentWeightControllers.values
      .fold<double>(0, (sum, c) => sum + (double.tryParse(c.text.trim()) ?? 0));

  bool get isDepartmentsWeightValid =>
      equalWeights ||
      realSelectedDepartments.isEmpty ||
      totalDepartmentsWeight == 100;

  /// The department names to send to the cubit on save.
  List<String> get departmentsForSave => realSelectedDepartments;

  /// The manual per-department weights to send to the cubit on save. `null`
  /// when [equalWeights] is true, since the model generates an equal split
  /// on its own.
  List<double>? get departmentWeightsForSave {
    if (equalWeights) return null;
    return realSelectedDepartments
        .map((d) =>
            double.tryParse(departmentWeightControllers[d]?.text.trim() ?? '') ??
            0)
        .toList();
  }

  /// Prefills selection + weights from an existing Control being edited.
  /// Rows (and their weight fields) are hidden entirely once "All" is
  /// selected, so only builds controllers otherwise. The persisted weight
  /// is shown as-is — when [equalWeights] is true that's already an equal
  /// split.
  void prefillFromExisting({
    required List<DepartmentWeight> departments,
    required bool equalWeights,
    required int totalDepartmentsCount,
  }) {
    this.equalWeights = equalWeights;
    final existingDepartmentNames = departments.map((d) => d.department).toList();
    final wasAllDepartments = existingDepartmentNames.isNotEmpty &&
        existingDepartmentNames.length == totalDepartmentsCount;
    selectedDepartments = [
      if (wasAllDepartments) allDepartmentsValue,
      ...existingDepartmentNames,
    ];
    if (!wasAllDepartments) {
      for (final d in departments) {
        departmentWeightControllers[d.department] =
            TextEditingController(text: formatControlWeight(d.weight));
      }
    }
  }

  /// Keeps [departmentWeightControllers] in sync with the currently
  /// selected (non-"All") departments: adds a controller for newly selected
  /// departments and disposes/removes controllers for deselected ones.
  void syncDepartmentWeightControllers() {
    final selected = realSelectedDepartments.toSet();
    departmentWeightControllers.removeWhere((department, controller) {
      final stale = !selected.contains(department);
      if (stale) controller.dispose();
      return stale;
    });
    for (final department in selected) {
      departmentWeightControllers.putIfAbsent(
          department, () => TextEditingController(text: '0'));
    }
  }

  /// Overwrites every selected department's weight controller with its
  /// share of an equal 100-way split, matching [DepartmentWeight.equalSplit]
  /// (the same helper the backend uses on save) so what's shown here is
  /// exactly what gets persisted.
  void applyEqualSplitToControllers() {
    for (final entry in DepartmentWeight.equalSplit(realSelectedDepartments)) {
      departmentWeightControllers[entry.department]?.text =
          formatControlWeight(entry.weight);
    }
  }

  void onEqualWeightsChanged(bool value) {
    if (isAllDepartmentsSelected) return;
    equalWeights = value;
    syncDepartmentWeightControllers();
    if (value) applyEqualSplitToControllers();
  }

  /// function name: [onDepartmentsChanged]
  ///
  /// purpose: reconcile the raw toggle event from the Department
  ///          multi-select against the business rule that "All" and "every
  ///          real department individually checked" are the same state,
  ///          and that state always forces [equalWeights] on.
  ///
  /// parameters:
  ///            [List<String>] newSelection: the full new selection reported by the dropdown
  ///            [List<String>] availableDepartmentNames: every real (non-"All") department name
  void onDepartmentsChanged(
      List<String> newSelection, List<String> availableDepartmentNames) {
    final justChecked =
        newSelection.where((d) => !selectedDepartments.contains(d)).toList();
    final justUnchecked =
        selectedDepartments.where((d) => !newSelection.contains(d)).toList();
    final toggled = justChecked.isNotEmpty
        ? justChecked.first
        : (justUnchecked.isNotEmpty ? justUnchecked.first : null);

    if (toggled == allDepartmentsValue) {
      if (justChecked.contains(allDepartmentsValue)) {
        selectedDepartments = [
          allDepartmentsValue,
          ...availableDepartmentNames,
        ];
        equalWeights = true;
      } else {
        selectedDepartments = [];
      }
    } else {
      final realSelection =
          newSelection.where((d) => d != allDepartmentsValue).toList();
      if (availableDepartmentNames.isNotEmpty &&
          realSelection.length == availableDepartmentNames.length) {
        selectedDepartments = [allDepartmentsValue, ...realSelection];
        equalWeights = true;
      } else {
        selectedDepartments = realSelection;
      }
    }
    if (isAllDepartmentsSelected) {
      for (final c in departmentWeightControllers.values) {
        c.dispose();
      }
      departmentWeightControllers.clear();
    } else {
      syncDepartmentWeightControllers();
      if (equalWeights) applyEqualSplitToControllers();
    }
  }

  void onRemoveDepartment(String department) {
    selectedDepartments = selectedDepartments
        .where((d) => d != department && d != allDepartmentsValue)
        .toList();
    departmentWeightControllers.remove(department)?.dispose();
    if (equalWeights) applyEqualSplitToControllers();
  }

  void dispose() {
    for (final c in departmentWeightControllers.values) {
      c.dispose();
    }
  }
}
