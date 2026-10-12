/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_model.dart
/// Purpose: Declares `RequestTypeModel` — Firestore <-> `RequestType`
///          mapping for one `Request_Types/{id}` history document.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Field names are FINAL SPEC §2 verbatim (+ `Created_By` / `Modified_By`).
/// `Location_Ids` / `Department_Ids` entries are wrapped `{Values: [...]}`.

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

typedef _F = TimeTrackerFieldCodec;

class RequestTypeModel {
  const RequestTypeModel._();

  static const String fRequestTypeId = 'Request_Type_Id';
  static const String fNameEn = 'Name_En';
  static const String fNameAr = 'Name_Ar';
  static const String fDescriptionEn = 'Description_En';
  static const String fDescriptionAr = 'Description_Ar';
  static const String fIsHrApproval = 'Is_HR_Approval_Required';
  static const String fIsManagerApproval = 'Is_Manager_Approval_Required';
  static const String fIsDescriptionRequired = 'Is_Description_Required';
  static const String fIsAttachmentRequired = 'Is_Attachment_Required';
  static const String fIsDeducted = 'Is_Deducted_From_Vacation_Balance';
  static const String fLocationIds = 'Location_Ids';
  static const String fDepartmentIds = 'Department_Ids';
  static const String fStatus = 'Request_Type_Status';

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  ///
  /// Return type: [RequestType]
  static RequestType fromMap(String id, Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    return RequestType(
      id: id.isNotEmpty ? id : _F.string(now(fRequestTypeId)),
      nameEn: _F.string(now(fNameEn)),
      nameAr: _F.string(now(fNameAr)),
      descriptionEn: _F.string(now(fDescriptionEn)),
      descriptionAr: _F.string(now(fDescriptionAr)),
      isHrApprovalRequired: _F.boolean(now(fIsHrApproval)),
      isManagerApprovalRequired: _F.boolean(now(fIsManagerApproval)),
      isDescriptionRequired: _F.boolean(now(fIsDescriptionRequired)),
      isAttachmentRequired: _F.boolean(now(fIsAttachmentRequired)),
      isDeductedFromVacationBalance: _F.boolean(now(fIsDeducted)),
      locationIds: _F.strings(now(fLocationIds)),
      departmentIds: _F.strings(now(fDepartmentIds)),
      status: RequestTypeStatus.fromStorageKey(_F.string(now(fStatus))),
      audit: _F.auditOf(map),
    );
  }

  /// Function Name: [row]
  ///
  /// Purpose: Field name -> new value for every field of one history row.
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> row(
    RequestType type, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fRequestTypeId: id,
        fNameEn: type.nameEn.trim(),
        fNameAr: type.nameAr.trim(),
        fDescriptionEn: type.descriptionEn.trim(),
        fDescriptionAr: type.descriptionAr.trim(),
        fIsHrApproval: type.isHrApprovalRequired,
        fIsManagerApproval: type.isManagerApprovalRequired,
        fIsDescriptionRequired: type.isDescriptionRequired,
        fIsAttachmentRequired: type.isAttachmentRequired,
        fIsDeducted: type.isDeductedFromVacationBalance,
        fLocationIds: _F.wrap(List<Object?>.of(type.locationIds)),
        fDepartmentIds: _F.wrap(List<Object?>.of(type.departmentIds)),
        fStatus: type.status.storageKey,
        ...audit.fields,
      };
}
