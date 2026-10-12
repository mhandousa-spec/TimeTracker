/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_member.dart
/// Purpose: Declares `DatabaseMember`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// One person granted access to a database — the card rendered across the
/// Access Management and Review screens (Figma 7398:7396, 7398:18600,
/// 7398:17988, 7398:18213).
///
/// WHY THIS EXISTS INSTEAD OF PASSING EmployeeEntityPro AROUND
/// ----------------------------------------------------------
/// `EmployeeEntityPro` carries about seventy fields — passport numbers,
/// academic history, driving licence, saved passwords. None of that belongs
/// in a database's access list, and writing it into the access document
/// would copy personal data into a second collection that has no reason to
/// hold it.
///
/// So the flow keeps a narrow snapshot: enough to draw the card and to write
/// the grant. Use [DatabaseMember.fromEmployee] at the point of selection.
///
/// It is a SNAPSHOT, deliberately. If someone is renamed or moves department
/// after the grant is written, the stored row keeps the values as they were
/// at grant time; [employeeId] is the key to re-resolve current values when
/// that matters.

class DatabaseMember {
  const DatabaseMember({
    required this.employeeId,
    required this.nameEn,
    required this.nameAr,
    this.email,
    this.departmentId,
    this.jobTitleEn,
    this.jobTitleAr,
    this.photoUrl,
  });

  final String employeeId;

  final String nameEn;
  final String nameAr;

  final String? email;
  final String? departmentId;

  final String? jobTitleEn;
  final String? jobTitleAr;

  /// Remote avatar URL. Null renders the gender-neutral placeholder, same as
  /// the employee cards elsewhere in the app.
  final String? photoUrl;

  String localizedName({required bool isArabic}) {
    if (isArabic) return nameAr.isNotEmpty ? nameAr : nameEn;
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  String localizedJobTitle({required bool isArabic}) {
    final String? preferred = isArabic ? jobTitleAr : jobTitleEn;
    final String? fallback = isArabic ? jobTitleEn : jobTitleAr;
    final String? chosen =
        (preferred != null && preferred.isNotEmpty) ? preferred : fallback;
    return chosen ?? '';
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'employee_id': employeeId,
        'name_en': nameEn,
        'name_ar': nameAr,
        'email': email,
        'department_id': departmentId,
        'job_title_en': jobTitleEn,
        'job_title_ar': jobTitleAr,
        'photo_url': photoUrl,
      };

  factory DatabaseMember.fromMap(Map<String, dynamic> map) => DatabaseMember(
        employeeId: (map['employee_id'] as String?) ?? '',
        nameEn: (map['name_en'] as String?) ?? '',
        nameAr: (map['name_ar'] as String?) ?? '',
        email: map['email'] as String?,
        departmentId: map['department_id'] as String?,
        jobTitleEn: map['job_title_en'] as String?,
        jobTitleAr: map['job_title_ar'] as String?,
        photoUrl: map['photo_url'] as String?,
      );

  /// Identity is the employee, not the object. Everything downstream
  /// (`Set<DatabaseMember>`, `contains`, deduping a department's members
  /// against an individually-picked one) depends on this — without it the
  /// same person added from two screens counts twice in the summary tile.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DatabaseMember && other.employeeId == employeeId);

  @override
  int get hashCode => employeeId.hashCode;
}
