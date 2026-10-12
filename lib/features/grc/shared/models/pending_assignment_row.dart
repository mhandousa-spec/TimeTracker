/// A staged Policy + Controls picker row on a GRC champion/owner
/// edit/reassign page. Selections here are local UI state only until
/// [commitPendingAssignmentRows] copies them into the page's real
/// assignment list. Extracted because both control_champion and
/// control_owner declared this class, byte-for-byte, in two files each.
library;

import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';

class PendingAssignmentRow {
  String? policyId;
  List<String> controlIds = [];
}

/// Copies staged [pendingRows] into [target], skipping rows with no policy
/// or no selected controls, and skipping any policy+control pair already
/// present in [target] so committing twice never creates a duplicate.
void commitPendingAssignmentRows({
  required List<PendingAssignmentRow> pendingRows,
  required List<AssigningControlEntity> target,
}) {
  for (final row in pendingRows) {
    if (row.policyId == null || row.controlIds.isEmpty) continue;
    for (final cid in row.controlIds) {
      final exists = target
          .any((ac) => ac.policyId == row.policyId && ac.controlId == cid);
      if (!exists) {
        target.add(AssigningControlEntity(
          policyId: row.policyId!,
          controlId: cid,
        ));
      }
    }
  }
}
