/// Module: roles / r2_user_management / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: delete_user_permission_use_case.dart
/// Purpose: Declares `DeleteUserPermissionUseCase`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';


class DeleteUserPermissionUseCase {
  final UserManagementAccessRepository repository;

  DeleteUserPermissionUseCase(this.repository);

  Future<Either<Failure, dynamic>> execute({
    required UserPermissionEntity permission,
    required String employeeEmail,
    required String currentUserEmail,
  }) async {
    return await repository.deleteEmployeePermission(
      employeeId: permission.employeeId,
      currentUserEmail: currentUserEmail,
    );
  }
}
