/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: request_type.dart
/// Purpose: Declares `RequestType` — one kind of leave request (Sick Leave,
///          Annual Vacation, …) defined on the Request Types tab.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// FINAL SPEC §2 `Request_Types/{id}`. The approval switches decide the
/// approval cycle (`ApprovalRouter`); `Is_Deducted_From_Vacation_Balance`
/// decides whether approval consumes vacation days (`VacationBalanceRules`).
/// Empty [locationIds] / [departmentIds] = available everywhere ("Limit …
/// Availability" switched off).
///
/// Plain immutable Dart: no Firestore, no Flutter.
/// Updated: 9/10/2026 - phase 3: [RequestType.name] / [RequestType.description]
/// (app language with fallback) for the Request Types tab.

import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

class RequestType {
  const RequestType({
    required this.id,
    required this.nameEn,
    this.nameAr = '',
    this.descriptionEn = '',
    this.descriptionAr = '',
    this.isHrApprovalRequired = true,
    this.isManagerApprovalRequired = true,
    this.isDescriptionRequired = false,
    this.isAttachmentRequired = false,
    this.isDeductedFromVacationBalance = false,
    this.locationIds = const <String>[],
    this.departmentIds = const <String>[],
    this.status = RequestTypeStatus.active,
    this.audit = AuditInfo.none,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final bool isHrApprovalRequired;
  final bool isManagerApprovalRequired;
  final bool isDescriptionRequired;
  final bool isAttachmentRequired;
  final bool isDeductedFromVacationBalance;
  final List<String> locationIds;
  final List<String> departmentIds;
  final RequestTypeStatus status;
  final AuditInfo audit;

  /// Function Name: [isAvailableFor]
  ///
  /// Purpose: Whether an employee at [locationId] in [departmentId] may pick
  /// this type in the request form: it must be active and pass both
  /// availability limits.
  ///
  /// Parameters:
  ///   [String] locationId: the employee's assigned location ('' if none).
  ///   [String] departmentId: the employee's department.
  ///
  /// Return type: [bool]
  bool isAvailableFor({
    required String locationId,
    required String departmentId,
  }) {
    if (status != RequestTypeStatus.active) return false;
    if (locationIds.isNotEmpty && !locationIds.contains(locationId)) {
      return false;
    }
    if (departmentIds.isNotEmpty && !departmentIds.contains(departmentId)) {
      return false;
    }
    return true;
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [RequestType]
  RequestType copyWith({
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    bool? isHrApprovalRequired,
    bool? isManagerApprovalRequired,
    bool? isDescriptionRequired,
    bool? isAttachmentRequired,
    bool? isDeductedFromVacationBalance,
    List<String>? locationIds,
    List<String>? departmentIds,
    RequestTypeStatus? status,
  }) =>
      RequestType(
        id: id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        descriptionEn: descriptionEn ?? this.descriptionEn,
        descriptionAr: descriptionAr ?? this.descriptionAr,
        isHrApprovalRequired: isHrApprovalRequired ?? this.isHrApprovalRequired,
        isManagerApprovalRequired:
            isManagerApprovalRequired ?? this.isManagerApprovalRequired,
        isDescriptionRequired:
            isDescriptionRequired ?? this.isDescriptionRequired,
        isAttachmentRequired: isAttachmentRequired ?? this.isAttachmentRequired,
        isDeductedFromVacationBalance:
            isDeductedFromVacationBalance ?? this.isDeductedFromVacationBalance,
        locationIds: locationIds ?? this.locationIds,
        departmentIds: departmentIds ?? this.departmentIds,
        status: status ?? this.status,
        audit: audit,
      );

  /// Function Name: [name] / [description]
  ///
  /// Purpose: The value in the app language, falling back to the other one.
  ///
  /// Return type: [String]
  String name({required bool isArabic}) => _pick(isArabic ? nameAr : nameEn, isArabic ? nameEn : nameAr);
  String description({required bool isArabic}) =>
      _pick(isArabic ? descriptionAr : descriptionEn, isArabic ? descriptionEn : descriptionAr);

  static String _pick(String first, String fallback) =>
      first.trim().isNotEmpty ? first.trim() : fallback.trim();
}
