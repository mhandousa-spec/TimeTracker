/// Module: GRC Assignee Bulk Upload (shared by Control Owner + Control Champion)
/// Description: One editable row in the bulk upload preview table. Wraps a
///              TextEditingController per field, plus the FocusNode/GlobalKey
///              needed for "jump to next error" navigation, and validates:
///              Email must belong to a real system user, Policy Name must
///              match an existing Policy in the module, and every
///              comma-separated Control Name must be a Control that belongs
///              to that Policy. On success, [resolvedPolicyId] and
///              [resolvedControlIds] are populated for submit() to use.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-26
/// Dependencies: flutter/material.dart, EmployeeEntityPro, PolicyEntity, ControlEntity

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_excel_parser.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:flutter/material.dart';

class AssigneeBulkRowForm {
  AssigneeBulkRowForm({
    String email = '',
    String policyName = '',
    String controlNames = '',
  })  : emailController = TextEditingController(text: email),
        policyNameController = TextEditingController(text: policyName),
        controlNamesController = TextEditingController(text: controlNames);

  factory AssigneeBulkRowForm.fromParsedRow(AssigneeBulkRow row) =>
      AssigneeBulkRowForm(
        email: row.email,
        policyName: row.policyName,
        controlNames: row.controlNames,
      );

  final TextEditingController emailController;
  final TextEditingController policyNameController;
  final TextEditingController controlNamesController;

  /// Scroll target for the "jump to next error" navigation.
  final GlobalKey key = GlobalKey();

  /// One [FocusNode] per editable field, keyed the same as [errors].
  final Map<String, FocusNode> focusNodes = {
    'email': FocusNode(),
    'policyName': FocusNode(),
    'controlNames': FocusNode(),
  };

  /// The result of the most recent [validate] call.
  Map<String, String> errors = {};

  /// Populated by [validate] only when the row has no errors — the Policy id
  /// the typed Policy Name resolved to.
  String? resolvedPolicyId;

  /// Populated by [validate] only when the row has no errors — one Control
  /// id per comma-separated name in [controlNamesController], in order.
  List<String> resolvedControlIds = [];

  /// function name: [validate]
  ///
  /// purpose: recompute [errors] from the controllers' current text against
  ///          the live directory of users/policies/controls: Email must
  ///          match a real employee, Policy Name must match an existing
  ///          Policy (English or Arabic name), and every comma-separated
  ///          Control Name must match a Control belonging to that Policy.
  ///
  /// parameters:
  ///            [List<EmployeeEntityPro>] employees: every known system user
  ///            [List<PolicyEntity>] allPolicies: every Policy in the module
  ///            [Map<String, List<ControlEntity>>] policyControls: policyId -> its Controls
  ///
  /// return type: [Map<String, String>] - the recomputed errors map (field key -> message)
  Map<String, String> validate({
    required List<EmployeeEntityPro> employees,
    required List<PolicyEntity> allPolicies,
    required Map<String, List<ControlEntity>> policyControls,
  }) {
    final next = <String, String>{};
    resolvedPolicyId = null;
    resolvedControlIds = [];

    final email = emailController.text.trim();
    if (email.isEmpty) {
      next['email'] = 'Required';
    } else if (!employees.any(
        (e) => (e.email ?? '').toLowerCase() == email.toLowerCase())) {
      next['email'] = 'No matching user for this email';
    }

    final policyName = policyNameController.text.trim();
    PolicyEntity? policy;
    if (policyName.isEmpty) {
      next['policyName'] = 'Required';
    } else {
      for (final p in allPolicies) {
        if (p.policyNameEn.trim().toLowerCase() == policyName.toLowerCase() ||
            p.policyNameAr.trim().toLowerCase() == policyName.toLowerCase()) {
          policy = p;
          break;
        }
      }
      if (policy == null) {
        next['policyName'] = 'Policy not found';
      } else {
        resolvedPolicyId = policy.id;
      }
    }

    final controlNamesRaw = controlNamesController.text.trim();
    if (controlNamesRaw.isEmpty) {
      next['controlNames'] = 'Required';
    } else if (policy != null) {
      final names = controlNamesRaw
          .split(',')
          .map((n) => n.trim())
          .where((n) => n.isNotEmpty)
          .toList();
      final available = policyControls[policy.id] ?? [];
      final missing = <String>[];
      final resolvedIds = <String>[];
      for (final name in names) {
        ControlEntity? match;
        for (final c in available) {
          if (c.controlsNameEn.trim().toLowerCase() == name.toLowerCase() ||
              c.controlsNameAr.trim().toLowerCase() == name.toLowerCase()) {
            match = c;
            break;
          }
        }
        if (match == null) {
          missing.add(name);
        } else {
          resolvedIds.add(match.id);
        }
      }
      if (missing.isNotEmpty) {
        next['controlNames'] =
            'Not found under this policy: ${missing.join(', ')}';
      } else {
        resolvedControlIds = resolvedIds;
      }
    }

    errors = next;
    return errors;
  }

  /// function name: [dispose]
  ///
  /// purpose: release every controller and focus node owned by this row.
  void dispose() {
    emailController.dispose();
    policyNameController.dispose();
    controlNamesController.dispose();
    for (final node in focusNodes.values) {
      node.dispose();
    }
  }
}
