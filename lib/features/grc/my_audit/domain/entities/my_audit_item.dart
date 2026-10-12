import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'my_audit_entity.dart';
import 'my_audit_tab.dart';

/// One row on the Control Owner's My Audits list. [audit] and
/// [assignmentControl] are both null only for a derived-Overdue row (the
/// Champion never submitted, so no Approval/My_Audit chain exists yet) —
/// there is nothing to open or act on for those.
class MyAuditItem {
  final MyAuditEntity? audit;
  final AssignmentControlEntity? assignmentControl;
  final ControlEntity control;
  final PolicyEntity policy;
  final MyAuditTab tab;

  /// GRC bug report p2/p3: false when this control's owner was added with
  /// "Give Score" off — they may only approve / reject, and the Module Owner
  /// gives the score from Approvals → Give Score.
  final bool ownerCanScore;

  const MyAuditItem({
    required this.audit,
    required this.assignmentControl,
    required this.control,
    required this.policy,
    required this.tab,
    this.ownerCanScore = true,
  });

  MyAuditItem withOwnerCanScore(bool value) => MyAuditItem(
        audit: audit,
        assignmentControl: assignmentControl,
        control: control,
        policy: policy,
        tab: tab,
        ownerCanScore: value,
      );
}
