/// Module: GRC Control Bulk Upload
/// Description: One editable row in the Control bulk upload preview table.
///              Wraps a TextEditingController per field plus per-field
///              validation, mirroring
///              lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_row_form.dart,
///              extended with Frequency matching, Control Champion/Owner
///              email lookup, and Applied Departments/Department Weight
///              validation. [validate] takes the known employee emails and
///              department names as plain parameters (not fetched via
///              GetX internally) so this class is a pure, directly
///              unit-testable function of its inputs.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: policy_bulk_date_format.dart, control_excel_parser.dart

import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_frequency.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:flutter/material.dart';

/// The Frequency sheet cell must case-insensitively match one of these;
/// the matching entry (canonical casing) is what gets persisted.
final List<String> controlBulkUploadFrequencyOptions = ControlFrequency.allValues;

/// class name: [ControlBulkRowForm]
///
/// purpose: hold the live-editable state of one bulk-upload Control row and
///          validate it: required fields, Start < End Date, Weight > 0,
///          Frequency match, Champion/Owner email lookup, and the Applied
///          Departments/Department Weight pair.
class ControlBulkRowForm {
  ControlBulkRowForm({
    String controlNameEn = '',
    String controlNameAr = '',
    String controlNumberEn = '',
    String controlNumberAr = '',
    String controlDescriptionEn = '',
    String controlDescriptionAr = '',
    String startDate = '',
    String endDate = '',
    String controlWeight = '',
    String frequency = '',
    String controlChampion = '',
    String controlOwner = '',
    String appliedDepartments = '',
    String departmentWeight = '',
  })  : controlNameEnController = TextEditingController(text: controlNameEn),
        controlNameArController = TextEditingController(text: controlNameAr),
        controlNumberEnController = TextEditingController(text: controlNumberEn),
        controlNumberArController = TextEditingController(text: controlNumberAr),
        controlDescriptionEnController =
            TextEditingController(text: controlDescriptionEn),
        controlDescriptionArController =
            TextEditingController(text: controlDescriptionAr),
        startDateController = TextEditingController(text: startDate),
        endDateController = TextEditingController(text: endDate),
        controlWeightController = TextEditingController(text: controlWeight),
        frequencyController = TextEditingController(text: frequency),
        controlChampionController = TextEditingController(text: controlChampion),
        controlOwnerController = TextEditingController(text: controlOwner),
        appliedDepartmentsController =
            TextEditingController(text: appliedDepartments),
        departmentWeightController =
            TextEditingController(text: departmentWeight);

  factory ControlBulkRowForm.fromParsedRow(ControlBulkRow row) => ControlBulkRowForm(
        controlNameEn: row.controlNameEn,
        controlNameAr: row.controlNameAr,
        controlNumberEn: row.controlNumberEn,
        controlNumberAr: row.controlNumberAr,
        controlDescriptionEn: row.controlDescriptionEn,
        controlDescriptionAr: row.controlDescriptionAr,
        startDate: row.startDate,
        endDate: row.endDate,
        controlWeight: row.controlWeight,
        frequency: row.frequency,
        controlChampion: row.controlChampion,
        controlOwner: row.controlOwner,
        appliedDepartments: row.appliedDepartments,
        departmentWeight: row.departmentWeight,
      );

  final TextEditingController controlNameEnController;
  final TextEditingController controlNameArController;
  final TextEditingController controlNumberEnController;
  final TextEditingController controlNumberArController;
  final TextEditingController controlDescriptionEnController;
  final TextEditingController controlDescriptionArController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController controlWeightController;
  final TextEditingController frequencyController;
  final TextEditingController controlChampionController;
  final TextEditingController controlOwnerController;
  final TextEditingController appliedDepartmentsController;
  final TextEditingController departmentWeightController;

  /// Scroll target for the "jump to next error" navigation.
  final GlobalKey key = GlobalKey();

  /// One [FocusNode] per editable field, keyed the same as [errors].
  final Map<String, FocusNode> focusNodes = {
    'controlNameEn': FocusNode(),
    'controlNameAr': FocusNode(),
    'controlNumberEn': FocusNode(),
    'controlNumberAr': FocusNode(),
    'controlDescriptionEn': FocusNode(),
    'controlDescriptionAr': FocusNode(),
    'startDate': FocusNode(),
    'endDate': FocusNode(),
    'controlWeight': FocusNode(),
    'frequency': FocusNode(),
    'controlChampion': FocusNode(),
    'controlOwner': FocusNode(),
    'appliedDepartments': FocusNode(),
    'departmentWeight': FocusNode(),
  };

  /// The result of the most recent [validate] call.
  Map<String, String> errors = {};

  /// The canonical-cased Frequency value to persist, set by [validate]
  /// whenever there's no 'frequency' error.
  String? resolvedFrequency;

  /// Parsed, validated Champion/Owner emails — empty unless [validate] has
  /// run and found no error on the matching field.
  List<String> championEmails = [];
  List<String> ownerEmails = [];

  /// Parsed, validated department names/weights (same length, same
  /// order) — empty unless [validate] has run and the Applied Departments
  /// cell itself has no error (a bad *sum* still leaves these populated;
  /// see 'departmentWeight' in [errors] for that case).
  List<String> departmentNames = [];
  List<double> departmentWeights = [];

  /// function name: [validate]
  ///
  /// purpose: recompute [errors] (and the derived [resolvedFrequency] /
  ///          [championEmails] / [ownerEmails] / [departmentNames] /
  ///          [departmentWeights]) from the controllers' current text.
  ///
  /// parameters:
  ///            [Set<String>] knownEmployeeEmails: every real employee email, for Champion/Owner lookup
  ///            [Set<String>] knownDepartmentNames: every real department name (English + Arabic), for Applied Departments lookup
  ///
  /// return type: [Map<String, String>] - the recomputed [errors] map (field key -> message)
  Map<String, String> validate({
    required Set<String> knownEmployeeEmails,
    required Set<String> knownDepartmentNames,
    required bool equalWeights,
    required DateTime policyStartDate,
    required DateTime policyEndDate,
  }) {
    final next = <String, String>{};

    void requireField(String key, String value) {
      if (value.trim().isEmpty) next[key] = 'Required';
    }

    requireField('controlNameEn', controlNameEnController.text);
    requireField('controlNameAr', controlNameArController.text);
    requireField('controlNumberEn', controlNumberEnController.text);
    requireField('controlNumberAr', controlNumberArController.text);
    requireField('controlDescriptionEn', controlDescriptionEnController.text);
    requireField('controlDescriptionAr', controlDescriptionArController.text);
    requireField('startDate', startDateController.text);
    requireField('frequency', frequencyController.text);

    final start = parsePolicyBulkDate(startDateController.text);
    if (!next.containsKey('startDate') && start == null) {
      next['startDate'] = 'Invalid date (dd-MM-yyyy)';
    }

    final endText = endDateController.text.trim();
    final end = endText.isEmpty ? null : parsePolicyBulkDate(endText);
    if (endText.isNotEmpty && end == null) {
      next['endDate'] = 'Invalid date (dd-MM-yyyy)';
    }

    if (start != null && end != null && !start.isBefore(end)) {
      next['startDate'] = 'Start Date must be before End Date';
      next['endDate'] = 'Start Date must be before End Date';
    }

    if (start != null && !next.containsKey('startDate')) {
      if (start.isBefore(policyStartDate)) {
        next['startDate'] = 'Start date cannot be before the Policy start date.';
      } else if (start.isAfter(policyEndDate)) {
        next['startDate'] = 'Start date cannot be after the Policy end date.';
      }
    }

    if (end != null && !next.containsKey('endDate')) {
      if (end.isBefore(policyStartDate)) {
        next['endDate'] = 'End date cannot be before the Policy start date.';
      } else if (end.isAfter(policyEndDate)) {
        next['endDate'] = 'End date cannot be after the Policy end date.';
      }
    }

    final weight = double.tryParse(controlWeightController.text.trim());
    if (weight == null || weight <= 0) {
      next['controlWeight'] = 'Must be a positive number';
    }

    resolvedFrequency = null;
    if (!next.containsKey('frequency')) {
      final typed = frequencyController.text.trim();
      final matched = ControlFrequency.fromString(typed);
      if (matched != null) {
        resolvedFrequency = matched.value;
      } else {
        next['frequency'] =
            'Must be one of: ${controlBulkUploadFrequencyOptions.join(', ')}';
      }
    }

    championEmails = _validateEmails(
      fieldKey: 'controlChampion',
      text: controlChampionController.text,
      knownEmployeeEmails: knownEmployeeEmails,
      errors: next,
    );
    ownerEmails = _validateEmails(
      fieldKey: 'controlOwner',
      text: controlOwnerController.text,
      knownEmployeeEmails: knownEmployeeEmails,
      errors: next,
    );

    _validateDepartments(next, knownDepartmentNames, equalWeights: equalWeights);

    errors = next;
    return errors;
  }

  List<String> _splitList(String text) => text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  List<String> _validateEmails({
    required String fieldKey,
    required String text,
    required Set<String> knownEmployeeEmails,
    required Map<String, String> errors,
  }) {
    final emails = _splitList(text);
    if (emails.isEmpty) return [];

    final unknown = emails.where((e) => !knownEmployeeEmails.contains(e)).toList();
    if (unknown.isNotEmpty) {
      errors[fieldKey] = 'Unknown employee email(s): ${unknown.join(', ')}';
      return [];
    }
    return emails;
  }

  /// function name: [_validateDepartments]
  ///
  /// purpose: validate the Applied Departments/Department Weight pair.
  ///          When [equalWeights] is true, Department Weight is not read as
  ///          input — each department in Applied Departments gets an equal
  ///          share (100 / count), and that computed share is written back
  ///          into [departmentWeightController] so the (read-only, in the
  ///          preview table) cell displays it, recomputed on every call —
  ///          i.e. every time Applied Departments changes. When false,
  ///          behaves exactly as before: structural problems (missing one
  ///          side, count mismatch, unknown department name) error
  ///          'appliedDepartments' (and, for the first two,
  ///          'departmentWeight' too, since neither cell is trustworthy in
  ///          those cases). Once the names/count are known good, a
  ///          non-numeric or non-100-summing weight list errors only
  ///          'departmentWeight'.
  void _validateDepartments(
    Map<String, String> errors,
    Set<String> knownDepartmentNames, {
    required bool equalWeights,
  }) {
    final namesText = appliedDepartmentsController.text.trim();
    departmentNames = [];
    departmentWeights = [];

    if (equalWeights) {
      if (namesText.isEmpty) {
        departmentWeightController.text = '';
        return;
      }

      final names = _splitList(namesText);
      if (names.isEmpty) {
        departmentWeightController.text = '';
        return;
      }

      final unknown = names.where((n) => !knownDepartmentNames.contains(n)).toList();
      if (unknown.isNotEmpty) {
        errors['appliedDepartments'] = 'Unknown department(s): ${unknown.join(', ')}';
        departmentWeightController.text = '';
        return;
      }

      departmentNames = names;
      final share = 100 / names.length;
      departmentWeights = List.filled(names.length, share);
      departmentWeightController.text =
          List.filled(names.length, formatControlWeight(share)).join(', ');
      return;
    }

    final weightsText = departmentWeightController.text.trim();
    if (namesText.isEmpty && weightsText.isEmpty) return;

    final names = _splitList(namesText);
    final weightStrings = _splitList(weightsText);

    if (names.isEmpty || weightStrings.isEmpty) {
      const message = 'Applied Departments and Department Weight must both be filled in';
      errors['appliedDepartments'] = message;
      errors['departmentWeight'] = message;
      return;
    }

    if (names.length != weightStrings.length) {
      const message = 'Applied Departments and Department Weight must have the same count';
      errors['appliedDepartments'] = message;
      errors['departmentWeight'] = message;
      return;
    }

    final unknown = names.where((n) => !knownDepartmentNames.contains(n)).toList();
    if (unknown.isNotEmpty) {
      errors['appliedDepartments'] = 'Unknown department(s): ${unknown.join(', ')}';
      return;
    }

    final weights = weightStrings.map(double.tryParse).toList();
    if (weights.any((w) => w == null)) {
      errors['departmentWeight'] = 'Department Weight must be numbers';
      return;
    }

    departmentNames = names;
    departmentWeights = weights.map((w) => w!).toList();

    final total = departmentWeights.fold<double>(0, (sum, w) => sum + w);
    if (total != 100) {
      errors['departmentWeight'] =
          'Department Weight must sum to 100 (currently ${total.toStringAsFixed(0)})';
    }
  }

  /// The current Control Weight as a number, or 0 if it doesn't parse.
  double get weightValue => double.tryParse(controlWeightController.text.trim()) ?? 0;

  /// function name: [dispose]
  ///
  /// purpose: release every controller and focus node owned by this row.
  void dispose() {
    controlNameEnController.dispose();
    controlNameArController.dispose();
    controlNumberEnController.dispose();
    controlNumberArController.dispose();
    controlDescriptionEnController.dispose();
    controlDescriptionArController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    controlWeightController.dispose();
    frequencyController.dispose();
    controlChampionController.dispose();
    controlOwnerController.dispose();
    appliedDepartmentsController.dispose();
    departmentWeightController.dispose();
    for (final node in focusNodes.values) {
      node.dispose();
    }
  }
}
