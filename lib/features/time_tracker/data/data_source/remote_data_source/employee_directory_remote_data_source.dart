/// Module: time_tracker / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: employee_directory_remote_data_source.dart
/// Purpose: Declares `EmployeeDirectoryRemoteDataSource` — READ-ONLY lookup
///          of one employee's `Supervisor` (direct manager email) in
///          `Demo/{cid}/Employees_Info/{employeeId}`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// The org chart (lib/features/org_chart_module) links an employee to their
/// manager only through this field; it is an indexed-history list whose last
/// entry is the current manager's business email (a bare string is accepted
/// too). This class never writes. Same empty-company guard as the module's
/// other data sources. Throws on failure (no try/catch — the resolver's job).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';

class EmployeeDirectoryRemoteDataSource {
  EmployeeDirectoryRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// The employee field that holds the direct manager's email.
  static const String fSupervisor = 'Supervisor';

  /// Function Name: [fetchSupervisorEmail]
  ///
  /// Purpose: The current `Supervisor` of `Employees_Info/{employeeId}`.
  ///
  /// Parameters:
  ///   [String] employeeId: the document id.
  ///
  /// Return type: [Future<String>] — '' when the document or field is
  /// missing (or the id is unusable).
  Future<String> fetchSupervisorEmail(String employeeId) async {
    final String id = employeeId.trim();
    if (id.isEmpty || id.contains('/')) return '';
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the '
        'employee directory cannot be read.',
      );
    }
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(getBaseUrl(ApiConstants.employeesInfo))
        .doc(id)
        .get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return '';
    final Object? value = TimeTrackerHistoryCodec.lastOf(data, fSupervisor);
    return value is String ? value : '';
  }
}
