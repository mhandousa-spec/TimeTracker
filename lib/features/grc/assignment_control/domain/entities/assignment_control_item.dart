import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';

/// One row on the Champion's Assignment Controls list: a Control this
/// champion is assigned to, its parent Policy, its (possibly absent)
/// Assignment_Controls submission, and the tab it currently belongs to.
/// [ownerEmail] is resolved independently of [assignment] — the Control
/// Owner is shown on the details page even before any evidence has ever
/// been submitted.
class AssignmentControlItem {
  final ControlEntity control;
  final PolicyEntity policy;
  final AssignmentControlEntity? assignment;
  final AssignmentControlTab tab;
  final String? ownerEmail;

  const AssignmentControlItem({
    required this.control,
    required this.policy,
    required this.assignment,
    required this.tab,
    required this.ownerEmail,
  });
}
