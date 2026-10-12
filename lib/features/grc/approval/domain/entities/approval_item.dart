import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'approval_entity.dart';

/// One row on the Department Manager's Approvals list: a Pending Approval,
/// the Assignment Control it decides, and that control's Control/Policy
/// details.
class ApprovalItem {
  final ApprovalEntity approval;
  final AssignmentControlEntity assignmentControl;
  final ControlEntity control;
  final PolicyEntity policy;

  const ApprovalItem({
    required this.approval,
    required this.assignmentControl,
    required this.control,
    required this.policy,
  });
}
