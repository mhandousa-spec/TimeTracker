/// Module: database / db2_database_details / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_row.dart
/// Purpose: Declares `DatabaseAccessRow`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// ONE LINE of the Access table — Figma 7398:10662 (iPad V) / 7398:10875
/// (iPad H), full column set in `Group 1597882843`:
///
///   Employee Picture | Employee Name | Department | Access Grantor |
///   Start Date Of Access | End Date Of Access | Access Type | Access Status
///
/// A grant is a GROUP (one department, or one person, with one window); the
/// table is a list of PEOPLE. This type is that flattening, done once in the
/// cubit so the table widget renders a list instead of walking a nested
/// structure and re-deriving a status per cell.
///
/// It is also what the Export button writes: one row here is one row of the
/// CSV, in the same order, so what lands in the file is what was on screen —
/// including whatever the chips and the search box were narrowing it to.

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/enums/database_access_status.dart';

class DatabaseAccessRow {
  const DatabaseAccessRow({
    required this.member,
    required this.status,
    this.departmentName = '',
    this.grantorName = '',
    this.permission,
    this.startDate,
    this.endDate,
    this.removedAt,
  });

  final DatabaseMember member;

  /// Resolved for TODAY (or persisted, for a removed row) — see
  /// [DatabaseAccessStatus].
  final DatabaseAccessStatus status;

  /// Already resolved to a display name. The member snapshot only holds the
  /// department ID, and a raw Firestore key in a table cell reads as
  /// corruption — the same reason `MemberGrid` refuses to fall back to it.
  final String departmentName;

  /// "Access Grantor" — who gave this person access.
  final String grantorName;

  /// "Access Type" in the Figma's column header, which is the permission LEVEL
  /// ("Full Access", "View"), not the database's open/restricted/personal
  /// access type. Two different things with almost the same name; the field is
  /// called `permission` here so the code cannot confuse them.
  final DatabasePermissionLevel? permission;

  final DateTime? startDate;
  final DateTime? endDate;

  /// Only set on a [DatabaseAccessStatus.removed] row.
  final DateTime? removedAt;

  bool get isRemoved => status.isRemoved;

  /// Does this row match the table's search box?
  ///
  /// Matches on name in BOTH languages plus the department, because the person
  /// searching may be typing the name they know rather than the name in the
  /// current UI locale.
  bool matches(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    return member.nameEn.toLowerCase().contains(q) ||
        member.nameAr.contains(query.trim()) ||
        departmentName.toLowerCase().contains(q) ||
        grantorName.toLowerCase().contains(q) ||
        (member.email?.toLowerCase().contains(q) ?? false);
  }
}
