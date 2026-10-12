/// Module: database / db2_database_details / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_record.dart
/// Purpose: Declares `DatabaseAccessGrantRecord` and `RemovedAccessMember`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// One document out of a database's `Access_Grants` subcollection, as this
/// module reads and writes it.
///
/// WHY THIS WRAPS `DatabaseAccessGrant` INSTEAD OF REPLACING IT
/// -----------------------------------------------------------
/// db1 already models a grant — permission, window, members — and the create
/// wizard writes exactly that shape. Re-declaring it here would give the app
/// two definitions of the same document, and the first field either side added
/// would break the other. So the grant travels unchanged and this adds the two
/// things only the details module needs:
///
///   * [id]              the document id, so an edit can rewrite the right row
///   * [removedMembers]  people whose access was taken away
///
/// WHY REMOVED PEOPLE ARE KEPT
/// ---------------------------
/// The Access table has a "Removed" chip and a red "Removed" status
/// (Figma `Group 1597882843`). Dropping someone from `members` on save would
/// make that chip permanently count zero — the row it is supposed to show is
/// the row that was just deleted. So a removal MOVES the person into
/// [removedMembers] with the window they used to hold and the moment it ended,
/// and the table renders them greyed out with the red badge.
///
/// They are stored under a separate `removed_members` key rather than as
/// members carrying a flag, so that every existing reader — including db1's
/// `DatabaseAccessGrant.fromMap`, which ignores keys it does not know — keeps
/// treating `members` as "people who currently have access". A revoked
/// employee must never leak back into a permission check because a caller
/// forgot to filter on a flag.

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

class DatabaseAccessGrantRecord {
  const DatabaseAccessGrantRecord({
    required this.grant,
    this.id = '',
    this.removedMembers = const <RemovedAccessMember>[],
    this.grantedBy,
    this.grantedByNameEn,
    this.grantedByNameAr,
  });

  /// Firestore document id. Empty for a grant assembled in memory that has not
  /// been written yet.
  final String id;

  final DatabaseAccessGrant grant;

  final List<RemovedAccessMember> removedMembers;

  /// Employee id of whoever granted this access — the "Access Grantor" column.
  ///
  /// Null on every grant written by the create wizard, which does not record
  /// it. The Access screen falls back to the database's `createdBy` in that
  /// case, which is who granted it: at creation time the only person who could
  /// have.
  final String? grantedBy;
  final String? grantedByNameEn;
  final String? grantedByNameAr;

  String localizedGrantorName({required bool isArabic}) {
    if (isArabic) {
      return (grantedByNameAr?.isNotEmpty ?? false)
          ? grantedByNameAr!
          : (grantedByNameEn ?? '');
    }
    return (grantedByNameEn?.isNotEmpty ?? false)
        ? grantedByNameEn!
        : (grantedByNameAr ?? '');
  }

  DatabaseAccessGrantRecord copyWith({
    String? id,
    DatabaseAccessGrant? grant,
    List<RemovedAccessMember>? removedMembers,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) {
    return DatabaseAccessGrantRecord(
      id: id ?? this.id,
      grant: grant ?? this.grant,
      removedMembers: removedMembers ?? this.removedMembers,
      grantedBy: grantedBy ?? this.grantedBy,
      grantedByNameEn: grantedByNameEn ?? this.grantedByNameEn,
      grantedByNameAr: grantedByNameAr ?? this.grantedByNameAr,
    );
  }
}

/// A person who used to be on a grant.
///
/// Carries the window and level they HELD, not the grant's current ones: the
/// grant may have been re-dated since, and the table has to report what that
/// person actually had, not what their replacement has.
class RemovedAccessMember {
  const RemovedAccessMember({
    required this.member,
    this.permission,
    this.startDate,
    this.endDate,
    this.removedAt,
    this.departmentId,
    this.departmentNameEn,
    this.departmentNameAr,
  });

  final DatabaseMember member;
  final DatabasePermissionLevel? permission;
  final DateTime? startDate;
  final DateTime? endDate;

  /// When the access was taken away. Null on rows written before this was
  /// recorded; the table then shows the status without a date rather than
  /// inventing one.
  final DateTime? removedAt;

  /// Snapshot of the grant's department at removal time, so the row keeps its
  /// Department column after the grant itself is gone.
  final String? departmentId;
  final String? departmentNameEn;
  final String? departmentNameAr;

  /// Builds the removal entry for [member] leaving [grant].
  factory RemovedAccessMember.from(
    DatabaseMember member,
    DatabaseAccessGrant grant, {
    DateTime? removedAt,
  }) =>
      RemovedAccessMember(
        member: member,
        permission: grant.permission,
        startDate: grant.startDate,
        endDate: grant.endDate,
        removedAt: removedAt ?? DateTime.now(),
        departmentId: grant.departmentId,
        departmentNameEn: grant.departmentNameEn,
        departmentNameAr: grant.departmentNameAr,
      );

  String localizedDepartmentName({required bool isArabic}) {
    if (isArabic) {
      return (departmentNameAr?.isNotEmpty ?? false)
          ? departmentNameAr!
          : (departmentNameEn ?? '');
    }
    return (departmentNameEn?.isNotEmpty ?? false)
        ? departmentNameEn!
        : (departmentNameAr ?? '');
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'member': member.toMap(),
        'permission': permission?.storageKey,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'removed_at': removedAt?.toIso8601String(),
        'department_id': departmentId,
        'department_name_en': departmentNameEn,
        'department_name_ar': departmentNameAr,
      };

  factory RemovedAccessMember.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> rawMember =
        (map['member'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return RemovedAccessMember(
      member: DatabaseMember.fromMap(rawMember),
      permission:
          DatabasePermissionLevel.fromStorageKey(map['permission'] as String?),
      startDate: DateTime.tryParse((map['start_date'] as String?) ?? ''),
      endDate: DateTime.tryParse((map['end_date'] as String?) ?? ''),
      removedAt: DateTime.tryParse((map['removed_at'] as String?) ?? ''),
      departmentId: map['department_id'] as String?,
      departmentNameEn: map['department_name_en'] as String?,
      departmentNameAr: map['department_name_ar'] as String?,
    );
  }

  /// Identity is the employee, same rule as [DatabaseMember] — re-removing
  /// someone must not add a second row for them.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemovedAccessMember && other.member == member);

  @override
  int get hashCode => member.hashCode;
}
