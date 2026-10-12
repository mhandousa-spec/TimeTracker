/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: employee_group_model.dart
/// Purpose: Declares `EmployeeGroupModel` — Firestore <-> `EmployeeGroup`
///          mapping for one `Groups/{id}` history document.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Field names are FINAL SPEC §2 verbatim, plus `Is_Deleted` (soft delete —
/// the spec has a Delete_Group switch but no deletion field; STATUS.md
/// assumption A4) and the audit trio. `Member_Emails` entries are wrapped.
/// Updated: 9/10/2026 - decision 32: `Group_Name_Ar` / `Description_Ar`.

import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';

typedef _F = TimeTrackerFieldCodec;

class EmployeeGroupModel {
  const EmployeeGroupModel._();

  static const String fGroupId = 'Group_Id';
  static const String fGroupName = 'Group_Name';
  static const String fGroupNameAr = 'Group_Name_Ar';
  static const String fDescription = 'Description';
  static const String fDescriptionAr = 'Description_Ar';
  static const String fGroupImage = 'Group_Image';
  static const String fMemberEmails = 'Member_Emails';
  static const String fLocationId = 'Location_Id';
  static const String fStartDate = 'Start_Date';
  static const String fIsDeleted = 'Is_Deleted';

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  ///
  /// Return type: [EmployeeGroup]
  static EmployeeGroup fromMap(String id, Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    return EmployeeGroup(
      id: id.isNotEmpty ? id : _F.string(now(fGroupId)),
      name: _F.string(now(fGroupName)),
      nameAr: _F.string(now(fGroupNameAr)),
      description: _F.string(now(fDescription)),
      descriptionAr: _F.string(now(fDescriptionAr)),
      imageUrl: _F.string(now(fGroupImage)),
      memberEmails: _F.strings(now(fMemberEmails)),
      locationId: _F.string(now(fLocationId)),
      startDate: _F.date(now(fStartDate)),
      rules: AttendanceRulesFields.from(map),
      isDeleted: _F.boolean(now(fIsDeleted)),
      audit: _F.auditOf(map),
    );
  }

  /// Function Name: [row]
  ///
  /// Purpose: Field name -> new value for every field of one history row.
  /// Member emails are lower-cased and de-duplicated.
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> row(
    EmployeeGroup group, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fGroupId: id,
        fGroupName: group.name.trim(),
        fGroupNameAr: group.nameAr.trim(),
        fDescription: group.description.trim(),
        fDescriptionAr: group.descriptionAr.trim(),
        fGroupImage: group.imageUrl,
        fMemberEmails: _F.wrap(<Object?>[
          ...<String>{
            for (final String e in group.memberEmails)
              if (e.trim().isNotEmpty) e.trim().toLowerCase(),
          },
        ]),
        fLocationId: group.locationId,
        fStartDate: _F.timestamp(group.startDate),
        ...AttendanceRulesFields.to(group.rules),
        fIsDeleted: group.isDeleted,
        ...audit.fields,
      };
}
