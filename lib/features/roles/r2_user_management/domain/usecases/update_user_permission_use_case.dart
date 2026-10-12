/// Module: roles / r2_user_management / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: update_user_permission_use_case.dart
/// Purpose: Declares `UpdateUserPermissionUseCase`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/new_permission_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';


class UpdateUserPermissionUseCase {
  final UserManagementAccessRepository repository;

  UpdateUserPermissionUseCase(this.repository);

  Future<Either<Failure, dynamic>> execute({
    required String employeeId,
    required String currentUserEmail,
    String? accessName,
    String? accessBegin,
    String? accessEnd,
  }) async {
    return await repository.updateUserPermission(
      employeeId: employeeId,
      currentUserEmail: currentUserEmail,
      accessName: accessName,
      accessBegin: accessBegin,
      accessEnd: accessEnd,
    );
  }
}
