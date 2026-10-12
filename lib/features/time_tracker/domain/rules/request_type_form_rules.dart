/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_form_rules.dart
/// Purpose: Declares `RequestTypeFormError` + `RequestTypeFormRules` (what
///          the Create / Edit Request Type form must satisfy) and
///          `RequestTypeList` (search + status filter of the Request Types
///          tab).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:43870` / `661:44042`: Request Name + Arabic twin (both
/// required — the app is bilingual), Description + Arabic twin (optional,
/// 500 max each), approval / requirement switches, "Deducts From Vacation
/// Balance" (FINAL SPEC `Is_Deducted_From_Vacation_Balance`) and the two
/// availability limits. A limit switched ON needs at least one chip.
/// Pure Dart, unit-tested.

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

enum RequestTypeFormError {
  nameEnRequired,
  nameArRequired,
  descriptionTooLong,
  locationsRequired,
  departmentsRequired,
}

class RequestTypeFormRules {
  const RequestTypeFormRules._();

  static const int maxDescriptionLength = 500;

  /// Function Name: [validate]
  ///
  /// Purpose: Every problem of [type]. [limitLocations] / [limitDepartments]
  /// are the form's availability switches.
  ///
  /// Return type: [Set<RequestTypeFormError>]
  static Set<RequestTypeFormError> validate(
    RequestType type, {
    required bool limitLocations,
    required bool limitDepartments,
  }) =>
      <RequestTypeFormError>{
        if (type.nameEn.trim().isEmpty) RequestTypeFormError.nameEnRequired,
        if (type.nameAr.trim().isEmpty) RequestTypeFormError.nameArRequired,
        if (type.descriptionEn.length > maxDescriptionLength ||
            type.descriptionAr.length > maxDescriptionLength)
          RequestTypeFormError.descriptionTooLong,
        if (limitLocations && type.locationIds.isEmpty)
          RequestTypeFormError.locationsRequired,
        if (limitDepartments && type.departmentIds.isEmpty)
          RequestTypeFormError.departmentsRequired,
      };
}

class RequestTypeList {
  const RequestTypeList._();

  /// Function Name: [filter]
  ///
  /// Purpose: The types matching [query] (either name / description) and
  /// [status] (null = every status, removed included — "All" means all).
  ///
  /// Return type: [List<RequestType>]
  static List<RequestType> filter(
    List<RequestType> types, {
    String query = '',
    RequestTypeStatus? status,
  }) {
    final String q = query.trim().toLowerCase();
    final List<RequestType> out = <RequestType>[
      for (final RequestType t in types)
        if ((status == null || t.status == status) &&
            (q.isEmpty ||
                '${t.nameEn} ${t.nameAr} ${t.descriptionEn} ${t.descriptionAr}'
                    .toLowerCase()
                    .contains(q)))
          t,
    ];
    // Newest first (creation date, then id for a stable order).
    out.sort((RequestType a, RequestType b) {
      final DateTime? x = a.audit.createdAt;
      final DateTime? y = b.audit.createdAt;
      if (x == null || y == null) return a.id.compareTo(b.id);
      return y.compareTo(x);
    });
    return out;
  }
}
