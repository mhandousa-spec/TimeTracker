// lib/features/grc/control_owner/domain/entities/owner_entity.dart
/// Module: Control Owner Management
/// Description: Flat (non-list) representation of a Control Owner record,
///              derived from the latest revision of [OwnerModel].
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: AssigningControlEntity, OwnerStatus

import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'owner_status.dart';

/// class name: [OwnerEntity]
///
/// purpose: holds the current (latest) values of a Control Owner record.
///          [controlOwnerPermissions] is current-state only (not history)
///          and is positionally parallel to [assigningControls] —
///          controlOwnerPermissions[i] belongs to assigningControls[i].
/// Per-control owner permission (stored in Control_Owners_Permissions).
///
/// ADDED 28/9/2026 (GRC bug report p2, "Give score" switch). Stored only when
/// the switch is OFF, so every owner created before the switch existed — an
/// empty permission list — keeps scoring exactly as before. When present the
/// owner may only approve / reject the evidence; the Module Owner gives the
/// score from Approvals → Give Score.
const String kOwnerScoreByModuleOwner = 'Score_By_Module_Owner';

class OwnerEntity {
  final String ownerEmail;
  final List<AssigningControlEntity> assigningControls;
  final List<List<String>> controlOwnerPermissions;
  final OwnerStatus status;

  // Tracking fields (latest values only)
  final DateTime createdAt;
  final DateTime modificationDate;
  final String lastModifier;

  /// Whether this owner scores [controlId] under [policyId] themselves.
  bool canGiveScore({required String policyId, required String controlId}) {
    for (var i = 0; i < assigningControls.length; i++) {
      final ac = assigningControls[i];
      if (ac.policyId == policyId && ac.controlId == controlId) {
        if (i >= controlOwnerPermissions.length) return true;
        return !controlOwnerPermissions[i].contains(kOwnerScoreByModuleOwner);
      }
    }
    return true;
  }

  const OwnerEntity({
    required this.ownerEmail,
    required this.assigningControls,
    required this.controlOwnerPermissions,
    required this.status,
    required this.createdAt,
    required this.modificationDate,
    required this.lastModifier,
  });
}
