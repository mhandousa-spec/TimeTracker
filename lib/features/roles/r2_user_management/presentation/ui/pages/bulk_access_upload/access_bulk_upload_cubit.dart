/// Module: roles / r2_user_management / presentation / ui / pages / bulk_access_upload
///
///*************************** FILE INFO ****************************///
/// File Name: access_bulk_upload_cubit.dart
/// Purpose: Holds the User Management import review rows and activates them.
/// Author: Knowticed Plus team
/// Created At: 21/9/2026 — see access_bulk_upload_parser.dart.
///
/// WHY `updateUserPermission`, ONE ROW AT A TIME
/// ---------------------------------------------
/// It is the same call the Employee Details "Edit" button makes, so an imported
/// row gets exactly what a hand edit gets: the Services user-limit check, the
/// history arrays appended rather than overwritten, the employee's role kept
/// in step, and the access-changed notification. The legacy
/// `UploadFileTabletRoles.uploadToFirebase` wrote Firestore directly and
/// skipped all four. The bulk `updateSelectedMembers` path is not usable here
/// because it assigns ONE role to every member, while each import row names
/// its own.
///
/// Rows that succeed are removed from the table; rows that fail stay, so the
/// user can fix and re-activate only those.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/bulk_access_upload/access_bulk_upload_parser.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/bulk_access_upload/access_bulk_upload_rows.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

part 'access_bulk_upload_state.dart';

class AccessBulkUploadCubit extends Cubit<AccessBulkUploadState> {
  AccessBulkUploadCubit({
    required UserManagementAccessRepository repository,
    required List<AccessBulkRawRow> rawRows,
    required List<EmployeeEntityPro> employees,
    required List<RoleHistoryModel> roles,
    required Map<String, UserPermissionEntity> currentAccessByEmployeeId,
    required String currentUserEmail,
  })  : _repository = repository,
        _currentUserEmail = currentUserEmail,
        _rows = AccessBulkUploadRows(
          rawRows,
          employees: employees,
          roles: grantableRoles(roles),
          currentAccessByEmployeeId: currentAccessByEmployeeId,
          currentUserEmail: currentUserEmail,
        ),
        super(AccessBulkUploadEditing());

  final UserManagementAccessRepository _repository;
  final String _currentUserEmail;
  final AccessBulkUploadRows _rows;

  AccessBulkUploadRows get rowsData => _rows;

  void _changed() {
    if (!isClosed) emit(AccessBulkUploadEditing());
  }

  void toggleRowSelected(int index) {
    _rows.toggleSelected(index);
    _changed();
  }

  void addRow() {
    _rows.addBlankRow();
    _changed();
  }

  void removeSelectedRows() {
    _rows.removeSelected();
    _changed();
  }

  void duplicateSelectedRow() {
    _rows.duplicateSelected();
    _changed();
  }

  /// After an identity cell is typed into.
  void revalidate() {
    _rows.revalidateAll();
    _changed();
  }

  void setRole(int index, String? roleName) {
    _rows.rows[index].desiredRole = roleName;
    revalidate();
  }

  void setAccessGranted(int index, DateTime? date) {
    _rows.rows[index].accessGranted = date;
    revalidate();
  }

  void setAccessRevoked(int index, DateTime? date) {
    _rows.rows[index].accessRevoked = date;
    revalidate();
  }

  Future<void> activate() async {
    if (!_rows.isValid) return;
    emit(AccessBulkUploadSubmitting());

    // Storage format, never localized — see the note on the Edit button in
    // employee_details_methods2.dart.
    final DateFormat storage = DateFormat(Constants.userAccessDateFormat, 'en');

    int succeeded = 0;
    final List<String> failures = <String>[];
    final List<int> done = <int>[];

    for (int i = 0; i < _rows.rows.length; i++) {
      final AccessBulkRowForm row = _rows.rows[i];

      final Either<Failure, dynamic> result =
          await _repository.updateUserPermission(
        employeeId: row.employee!.id!,
        currentUserEmail: _currentUserEmail,
        accessName: row.desiredRole!,
        accessBegin: storage.format(row.accessGranted!),
        accessEnd: storage.format(row.accessRevoked!),
      );

      result.fold(
        (Failure failure) => failures.add(
            '${row.employee!.email ?? row.employee!.id}: ${failure.errMessage}'),
        (_) {
          succeeded++;
          done.add(i);
        },
      );
    }

    for (final int index in done.reversed) {
      _rows.removeAt(index);
    }

    if (!isClosed) {
      emit(AccessBulkUploadResult(succeeded: succeeded, failures: failures));
    }
  }

  @override
  Future<void> close() {
    _rows.dispose();
    return super.close();
  }
}
