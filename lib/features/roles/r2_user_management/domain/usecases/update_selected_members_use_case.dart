/// Module: roles / r2_user_management / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: update_selected_members_use_case.dart
/// Purpose: Declares `UpdateSelectedMembersUseCase`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:dartz/dartz.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/controllers/notification_controller.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';

import 'package:knowticed_plus/core/custom/76-date_time_in_arabic.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';


class UpdateSelectedMembersUseCase {
  final UserManagementAccessRepository repository;

  UpdateSelectedMembersUseCase(this.repository);

  Future<Either<Failure, dynamic>> execute({
    required String currentUserEmail,
    required String accessName,
    required String startDate,
    required String endDate,
    required List<EmployeeEntityPro> selectedMembers,
  }) async {
    return await repository.updateSelectedMembersPermission(
      currentUserEmail: currentUserEmail,
      accessName: accessName,
      startDate: startDate,
      endDate: endDate,
      selectedMembers: selectedMembers,
    );
  }
}
