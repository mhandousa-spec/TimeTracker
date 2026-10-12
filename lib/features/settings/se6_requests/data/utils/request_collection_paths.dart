/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_collection_paths.dart
/// Purpose: Resolve the tenant-aware paths the request flow reads and writes.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N11. `'${getBaseUrl('Modules')}/roles'` was assembled
/// at six call sites across four files, and `getBaseUrl('Employees_Info')` at
/// three more. One of those call sites had drifted: the submit page used to
/// build `{baseUri}/Modules/roles/Employees/{id}` for the employee document, a
/// collection that does not exist, which is where "Employee document not found"
/// came from.

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

abstract final class RequestCollectionPaths {
  const RequestCollectionPaths._();

  static const String _rolesDocName = 'roles';

  /// `{baseUri}/Modules/roles` — the document the request collection hangs off.
  static String get rolesDoc =>
      '${getBaseUrl(FirebaseCollections.modulesKey)}/$_rolesDocName';

  /// The sub-collection of [rolesDoc] holding one document per submission.
  static String get requestsCollection => FirebaseCollections.employeesRequest;

  /// `{baseUri}/Modules/roles/Employees_Request_Comments` — the inquiry and
  /// comment thread shown on the request details screen.
  ///
  /// A flat collection filtered by [commentRequestIdField] rather than a
  /// sub-collection of the request document: `UniversalCommentSection` takes
  /// one collection path plus a filter map, and this keeps every thread
  /// queryable from a single place.
  static String get requestCommentsCollection =>
      '$rolesDoc/${FirebaseCollections.employeesRequestComments}';

  /// The field on a comment document naming the request it belongs to.
  static const String commentRequestIdField = 'Request_Id';

  /// `{baseUri}/Employees_Info` — the employee profile documents.
  static String get employeesInfo => getBaseUrl('Employees_Info');

  /// `{baseUri}/Employees_Info/{id}` for one employee.
  static String employeeDoc(String employeeId) =>
      '$employeesInfo/$employeeId';
}
